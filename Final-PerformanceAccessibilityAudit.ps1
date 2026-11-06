[CmdletBinding()]
param(
    [string]$RepositoryRoot = "C:\corecraftgenesis-github",
    [string]$ReportFileName = "performance-accessibility-audit.json",
    [long]$LargeHtmlBytes = 102400,
    [long]$LargeCssBytes = 153600,
    [long]$LargeJavaScriptBytes = 204800,
    [long]$LargeImageBytes = 512000,
    [long]$LargeFontBytes = 512000,
    [long]$LargeMediaBytes = 5242880,
    [long]$LargeOtherBytes = 1048576,
    [int]$LargeInlineBlockCharacters = 10000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ExcludedTopLevelDirectories = @(
    ".git"
    ".github"
    ".vscode"
    "node_modules"
    "playwright-report"
    "test-results"
    "blob-report"
    "tests"
)

function Test-IsProductionPath {
    param(
        [Parameter(Mandatory)]
        [string]$FullName
    )

    $RelativePath = [IO.Path]::GetRelativePath(
        $RepositoryRoot,
        $FullName
    )

    $TopLevelDirectory = (
        $RelativePath -split '[\\/]'
    )[0]

    return $TopLevelDirectory -notin $ExcludedTopLevelDirectories
}

function Write-Section {
    param([Parameter(Mandatory)][string]$Title)

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("-" * 60)
}

function Get-RelativePathSafe {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][string]$Path
    )

    return [IO.Path]::GetRelativePath(
        [IO.Path]::GetFullPath($Root),
        [IO.Path]::GetFullPath($Path)
    )
}

function Test-ExcludedRelativePath {
    param([Parameter(Mandatory)][string]$RelativePath)

    $Normalized = $RelativePath.Replace("/", "\")
    $ExcludedPrefixes = @(
        ".git\",
        ".github\",
        ".vscode\",
        "node_modules\",
        "vendor\",
        "dist\",
        "build\"
        "playwright-report",
"test-results",
"blob-report",
"node_modules",
".git",
".github",
".vscode",
"tests"
    )

    foreach ($Prefix in $ExcludedPrefixes) {
        if ($Normalized.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Add-Finding {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()]
        [Collections.Generic.List[object]]$Collection,

        [Parameter(Mandatory)]
        [ValidateSet("FAIL", "WARN", "INFO")]
        [string]$Severity,

        [Parameter(Mandatory)][string]$Rule,
        [Parameter(Mandatory)][string]$File,
        [Parameter(Mandatory)][string]$Detail
    )

    $Collection.Add(
        [pscustomobject]@{
            Severity = $Severity
            Rule     = $Rule
            File     = $File
            Detail   = $Detail
        }
    )
}

function Get-AttributeValue {
    param(
        [Parameter(Mandatory)][string]$Tag,
        [Parameter(Mandatory)][string]$AttributeName
    )

    $EscapedName = [regex]::Escape($AttributeName)
    $Pattern = (
        '(?is)\b' +
        $EscapedName +
        '\s*=\s*' +
        '(?:"(?<double>[^"]*)"|' +
        "'(?<single>[^']*)'|" +
        '(?<plain>[^\s>]+))'
    )

    $Match = [regex]::Match($Tag, $Pattern)

    if (-not $Match.Success) {
        return ""
    }

    foreach ($GroupName in @("double", "single", "plain")) {
        if ($Match.Groups[$GroupName].Success) {
            return [Net.WebUtility]::HtmlDecode(
                $Match.Groups[$GroupName].Value.Trim()
            )
        }
    }

    return ""
}

function Test-AttributePresent {
    param(
        [Parameter(Mandatory)][string]$Tag,
        [Parameter(Mandatory)][string]$AttributeName
    )

    $EscapedName = [regex]::Escape($AttributeName)
    return [regex]::IsMatch(
        $Tag,
        '(?is)\b' + $EscapedName + '(?:\s*=|\s|/?>)'
    )
}

function Get-ElementText {
    param(
        [Parameter(Mandatory)][string]$Html,
        [Parameter(Mandatory)][string]$ElementName
    )

    $EscapedName = [regex]::Escape($ElementName)
    $Pattern = (
        '(?is)<' +
        $EscapedName +
        '\b[^>]*>(?<value>.*?)</' +
        $EscapedName +
        '\s*>'
    )

    $Match = [regex]::Match($Html, $Pattern)

    if (-not $Match.Success) {
        return ""
    }

    $Text = [regex]::Replace(
        $Match.Groups["value"].Value,
        '<[^>]+>',
        ' '
    )

    $Text = [Net.WebUtility]::HtmlDecode($Text)
    return ([regex]::Replace($Text, '\s+', ' ')).Trim()
}

function Get-FileCategory {
    param([Parameter(Mandatory)][IO.FileInfo]$File)

    $Extension = $File.Extension.ToLowerInvariant()

    switch ($Extension) {
        ".html" { return "HTML" }
        ".htm"  { return "HTML" }
        ".css"  { return "CSS" }
        ".js"   { return "JavaScript" }
        ".mjs"  { return "JavaScript" }
        ".json" { return "JSON" }
        ".png"  { return "Image" }
        ".jpg"  { return "Image" }
        ".jpeg" { return "Image" }
        ".gif"  { return "Image" }
        ".webp" { return "Image" }
        ".svg"  { return "Image" }
        ".ico"  { return "Image" }
        ".woff" { return "Font" }
        ".woff2" { return "Font" }
        ".ttf"  { return "Font" }
        ".otf"  { return "Font" }
        ".eot"  { return "Font" }
        ".mp3"  { return "Media" }
        ".wav"  { return "Media" }
        ".ogg"  { return "Media" }
        ".m4a"  { return "Media" }
        ".mp4"  { return "Media" }
        ".webm" { return "Media" }
        ".mov"  { return "Media" }
        default  { return "Other" }
    }
}

function Get-LargeThreshold {
    param([Parameter(Mandatory)][string]$Category)

    switch ($Category) {
        "HTML"       { return $LargeHtmlBytes }
        "CSS"        { return $LargeCssBytes }
        "JavaScript" { return $LargeJavaScriptBytes }
        "Image"      { return $LargeImageBytes }
        "Font"       { return $LargeFontBytes }
        "Media"      { return $LargeMediaBytes }
        default       { return $LargeOtherBytes }
    }
}

function Resolve-LocalReference {
    param(
        [Parameter(Mandatory)][string]$Reference,
        [Parameter(Mandatory)][string]$HtmlFilePath
    )

    $Value = [Net.WebUtility]::HtmlDecode($Reference).Trim()

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    if (
        $Value.StartsWith("#") -or
        $Value.StartsWith("mailto:", [StringComparison]::OrdinalIgnoreCase) -or
        $Value.StartsWith("tel:", [StringComparison]::OrdinalIgnoreCase) -or
        $Value.StartsWith("javascript:", [StringComparison]::OrdinalIgnoreCase) -or
        $Value.StartsWith("data:", [StringComparison]::OrdinalIgnoreCase) -or
        $Value.StartsWith("http://", [StringComparison]::OrdinalIgnoreCase) -or
        $Value.StartsWith("https://", [StringComparison]::OrdinalIgnoreCase) -or
        $Value.StartsWith("//")
    ) {
        return $null
    }

    $Value = ($Value -split '[?#]', 2)[0]

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    if ($Value.StartsWith("/")) {
        $Candidate = Join-Path $RepositoryRoot $Value.TrimStart("/").Replace("/", "\")
    }
    else {
        $Parent = Split-Path -Parent $HtmlFilePath
        $Candidate = Join-Path $Parent $Value.Replace("/", "\")
    }

    try {
        return [IO.Path]::GetFullPath($Candidate)
    }
    catch {
        return $Candidate
    }
}

function Test-LabelForControl {
    param(
        [Parameter(Mandatory)][string]$Html,
        [Parameter(Mandatory)][string]$Tag,
        [Parameter(Mandatory)][string]$ControlType
    )

    $Id = Get-AttributeValue -Tag $Tag -AttributeName "id"
    $AriaLabel = Get-AttributeValue -Tag $Tag -AttributeName "aria-label"
    $AriaLabelledBy = Get-AttributeValue -Tag $Tag -AttributeName "aria-labelledby"
    $Title = Get-AttributeValue -Tag $Tag -AttributeName "title"

    if (
        -not [string]::IsNullOrWhiteSpace($AriaLabel) -or
        -not [string]::IsNullOrWhiteSpace($AriaLabelledBy) -or
        -not [string]::IsNullOrWhiteSpace($Title)
    ) {
        return $true
    }

    if (-not [string]::IsNullOrWhiteSpace($Id)) {
        $EscapedId = [regex]::Escape($Id)
        if (
            [regex]::IsMatch(
                $Html,
                '(?is)<label\b[^>]*\bfor\s*=\s*["'']' + $EscapedId + '["''][^>]*>'
            )
        ) {
            return $true
        }
    }

    # A control nested directly inside a label is considered labelled.
    $EscapedTag = [regex]::Escape($Tag)
    if (
        [regex]::IsMatch(
            $Html,
            '(?is)<label\b[^>]*>.*?' + $EscapedTag + '.*?</label>'
        )
    ) {
        return $true
    }

    if ($ControlType -eq "input") {
        $InputType = Get-AttributeValue -Tag $Tag -AttributeName "type"
        if ($InputType -in @("hidden", "submit", "reset", "button", "image")) {
            return $true
        }
    }

    return $false
}

Write-Host ""
Write-Host "============================================================"
Write-Host " CORECRAFT GENESIS - PERFORMANCE & ACCESSIBILITY AUDIT"
Write-Host "============================================================"

if (-not (Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
    Write-Host "[FAIL] Repository-Root nicht gefunden: $RepositoryRoot" -ForegroundColor Red
    exit 1
}

$ReportPath = Join-Path $RepositoryRoot $ReportFileName
$Findings = [Collections.Generic.List[object]]::new()
$PageResults = [Collections.Generic.List[object]]::new()

Write-Section "RESOURCE INVENTORY"

$Files = @(
    Get-ChildItem -LiteralPath $RepositoryRoot -File -Recurse |
    Where-Object {
        $Relative = Get-RelativePathSafe -Root $RepositoryRoot -Path $_.FullName
        -not (Test-ExcludedRelativePath -RelativePath $Relative)
    } |
    Sort-Object FullName
)

$Inventory = @(
    foreach ($File in $Files) {
        $Relative = Get-RelativePathSafe -Root $RepositoryRoot -Path $File.FullName
        $Category = Get-FileCategory -File $File

        [pscustomobject]@{
            File      = $Relative
            Category  = $Category
            Extension = $File.Extension.ToLowerInvariant()
            SizeBytes = $File.Length
            SizeKB    = [math]::Round($File.Length / 1KB, 2)
        }
    }
)

$InventorySummary = @(
    $Inventory |
    Group-Object Category |
    Sort-Object Name |
    ForEach-Object {
        [pscustomobject]@{
            Category  = $_.Name
            Files     = $_.Count
            SizeBytes = [long](($_.Group | Measure-Object SizeBytes -Sum).Sum)
            SizeMB    = [math]::Round((($_.Group | Measure-Object SizeBytes -Sum).Sum) / 1MB, 3)
        }
    }
)

$InventorySummary | Format-Table Category, Files, SizeMB -AutoSize

$LargeAssets = @(
    foreach ($Item in $Inventory) {
        $Threshold = Get-LargeThreshold -Category $Item.Category
        if ($Item.SizeBytes -gt $Threshold) {
            $Severity = if ($Item.SizeBytes -gt ($Threshold * 2)) { "FAIL" } else { "WARN" }
            Add-Finding `
                -Collection $Findings `
                -Severity $Severity `
                -Rule "LARGE_ASSET" `
                -File $Item.File `
                -Detail ("{0} MB; Grenzwert {1} MB ({2})." -f `
                    ([math]::Round($Item.SizeBytes / 1MB, 3)), `
                    ([math]::Round($Threshold / 1MB, 3)), `
                    $Item.Category)

            $Item
        }
    }
)

$HtmlFiles = @($Files | Where-Object { (Get-FileCategory -File $_) -eq "HTML" })
$CssFiles = @($Files | Where-Object { (Get-FileCategory -File $_) -eq "CSS" })
$JavaScriptFiles = @($Files | Where-Object { (Get-FileCategory -File $_) -eq "JavaScript" })
$ImageFiles = @($Files | Where-Object { (Get-FileCategory -File $_) -eq "Image" })
$FontFiles = @($Files | Where-Object { (Get-FileCategory -File $_) -eq "Font" })
$JsonFiles = @($Files | Where-Object { (Get-FileCategory -File $_) -eq "JSON" })
$MediaFiles = @($Files | Where-Object { (Get-FileCategory -File $_) -eq "Media" })

Write-Host ("HTML files        : {0}" -f $HtmlFiles.Count)
Write-Host ("CSS files         : {0}" -f $CssFiles.Count)
Write-Host ("JavaScript files  : {0}" -f $JavaScriptFiles.Count)
Write-Host ("Images            : {0}" -f $ImageFiles.Count)
Write-Host ("Fonts             : {0}" -f $FontFiles.Count)
Write-Host ("JSON files        : {0}" -f $JsonFiles.Count)
Write-Host ("Media files       : {0}" -f $MediaFiles.Count)
Write-Host ("Repository size   : {0} MB" -f ([math]::Round((($Inventory | Measure-Object SizeBytes -Sum).Sum) / 1MB, 3)))
Write-Host ("Large assets      : {0}" -f $LargeAssets.Count)

Write-Section "HTML PERFORMANCE & ACCESSIBILITY VALIDATION"

foreach ($HtmlFile in $HtmlFiles) {
    $RelativePath = Get-RelativePathSafe -Root $RepositoryRoot -Path $HtmlFile.FullName
    $Html = Get-Content -LiteralPath $HtmlFile.FullName -Raw

    if ([string]::IsNullOrWhiteSpace($Html)) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule HTML_EMPTY -File $RelativePath -Detail "HTML-Datei ist leer."
        continue
    }

    $PageFindingStart = $Findings.Count

    $HtmlOpenMatch = [regex]::Match($Html, '(?is)<html\b[^>]*>')
    $Language = if ($HtmlOpenMatch.Success) {
        Get-AttributeValue -Tag $HtmlOpenMatch.Value -AttributeName "lang"
    }
    else {
        ""
    }

    if ([string]::IsNullOrWhiteSpace($Language)) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule MISSING_LANG -File $RelativePath -Detail "html lang fehlt."
    }

    $Title = Get-ElementText -Html $Html -ElementName "title"
    if ([string]::IsNullOrWhiteSpace($Title)) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule MISSING_TITLE -File $RelativePath -Detail "title fehlt oder ist leer."
    }

    if (-not [regex]::IsMatch($Html, '(?is)<main\b[^>]*>')) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule MISSING_MAIN -File $RelativePath -Detail "main-Landmark fehlt."
    }

    $H1Matches = @([regex]::Matches($Html, '(?is)<h1\b[^>]*>.*?</h1>'))
    if ($H1Matches.Count -eq 0) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule MISSING_H1 -File $RelativePath -Detail "H1 fehlt."
    }
    elseif ($H1Matches.Count -gt 1) {
        Add-Finding -Collection $Findings -Severity WARN -Rule MULTIPLE_H1 -File $RelativePath -Detail "$($H1Matches.Count) H1-Elemente vorhanden."
    }

    $HeadingMatches = @([regex]::Matches($Html, '(?is)<h(?<level>[1-6])\b[^>]*>'))
    $LastLevel = 0
    foreach ($Heading in $HeadingMatches) {
        $CurrentLevel = [int]$Heading.Groups["level"].Value
        if ($LastLevel -gt 0 -and $CurrentLevel -gt ($LastLevel + 1)) {
            Add-Finding `
                -Collection $Findings `
                -Severity WARN `
                -Rule HEADING_LEVEL_SKIP `
                -File $RelativePath `
                -Detail "Ueberschriftenebene springt von H$LastLevel zu H$CurrentLevel."
        }
        $LastLevel = $CurrentLevel
    }

    $ImageMatches = @([regex]::Matches($Html, '(?is)<img\b[^>]*>'))
    $MissingAltCount = 0
    foreach ($ImageMatch in $ImageMatches) {
        if (-not (Test-AttributePresent -Tag $ImageMatch.Value -AttributeName "alt")) {
            $MissingAltCount++
        }
    }
    if ($MissingAltCount -gt 0) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule MISSING_ALT -File $RelativePath -Detail "$MissingAltCount Bild(er) ohne alt-Attribut."
    }

    $AnchorMatches = @([regex]::Matches($Html, '(?is)<a\b(?<attrs>[^>]*)>(?<content>.*?)</a>'))
    $EmptyLinkCount = 0
    foreach ($Anchor in $AnchorMatches) {
        $Text = [regex]::Replace($Anchor.Groups["content"].Value, '<[^>]+>', ' ')
        $Text = ([Net.WebUtility]::HtmlDecode($Text) -replace '\s+', ' ').Trim()
        $FullTag = $Anchor.Value
        $AriaLabel = Get-AttributeValue -Tag $FullTag -AttributeName "aria-label"
        $TitleAttribute = Get-AttributeValue -Tag $FullTag -AttributeName "title"
        $ImageAlt = ""
        $NestedImage = [regex]::Match($Anchor.Groups["content"].Value, '(?is)<img\b[^>]*>')
        if ($NestedImage.Success) {
            $ImageAlt = Get-AttributeValue -Tag $NestedImage.Value -AttributeName "alt"
        }

        if (
            [string]::IsNullOrWhiteSpace($Text) -and
            [string]::IsNullOrWhiteSpace($AriaLabel) -and
            [string]::IsNullOrWhiteSpace($TitleAttribute) -and
            [string]::IsNullOrWhiteSpace($ImageAlt)
        ) {
            $EmptyLinkCount++
        }
    }
    if ($EmptyLinkCount -gt 0) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule EMPTY_LINK -File $RelativePath -Detail "$EmptyLinkCount Link(s) ohne zugänglichen Namen."
    }

    $ButtonMatches = @([regex]::Matches($Html, '(?is)<button\b[^>]*>(?<content>.*?)</button>'))
    $EmptyButtonCount = 0
    foreach ($Button in $ButtonMatches) {
        $Text = [regex]::Replace($Button.Groups["content"].Value, '<[^>]+>', ' ')
        $Text = ([Net.WebUtility]::HtmlDecode($Text) -replace '\s+', ' ').Trim()
        $AriaLabel = Get-AttributeValue -Tag $Button.Value -AttributeName "aria-label"
        $TitleAttribute = Get-AttributeValue -Tag $Button.Value -AttributeName "title"

        if (
            [string]::IsNullOrWhiteSpace($Text) -and
            [string]::IsNullOrWhiteSpace($AriaLabel) -and
            [string]::IsNullOrWhiteSpace($TitleAttribute)
        ) {
            $EmptyButtonCount++
        }
    }
    if ($EmptyButtonCount -gt 0) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule EMPTY_BUTTON -File $RelativePath -Detail "$EmptyButtonCount Button(s) ohne zugänglichen Namen."
    }

    $FormControlMatches = @(
        [regex]::Matches($Html, '(?is)<(?<type>input|select|textarea)\b[^>]*>')
    )
    $UnlabelledControlCount = 0
    foreach ($Control in $FormControlMatches) {
        if (
            -not (Test-LabelForControl `
                -Html $Html `
                -Tag $Control.Value `
                -ControlType $Control.Groups["type"].Value.ToLowerInvariant())
        ) {
            $UnlabelledControlCount++
        }
    }
    if ($UnlabelledControlCount -gt 0) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule FORM_LABEL_MISSING -File $RelativePath -Detail "$UnlabelledControlCount Formularfeld(er) ohne erkennbare Beschriftung."
    }

    $StyleBlocks = @([regex]::Matches($Html, '(?is)<style\b[^>]*>(?<content>.*?)</style>'))
    foreach ($StyleBlock in $StyleBlocks) {
        if ($StyleBlock.Groups["content"].Value.Length -gt $LargeInlineBlockCharacters) {
            Add-Finding -Collection $Findings -Severity WARN -Rule LARGE_INLINE_STYLE -File $RelativePath -Detail "Inline-Style umfasst $($StyleBlock.Groups['content'].Value.Length) Zeichen."
        }
    }

    $ScriptBlocks = @([regex]::Matches($Html, '(?is)<script\b(?![^>]*\bsrc\s*=)[^>]*>(?<content>.*?)</script>'))
    foreach ($ScriptBlock in $ScriptBlocks) {
        if ($ScriptBlock.Groups["content"].Value.Length -gt $LargeInlineBlockCharacters) {
            Add-Finding -Collection $Findings -Severity WARN -Rule LARGE_INLINE_SCRIPT -File $RelativePath -Detail "Inline-Skript umfasst $($ScriptBlock.Groups['content'].Value.Length) Zeichen."
        }
    }

    $StylesheetReferences = @(
        [regex]::Matches($Html, '(?is)<link\b[^>]*>') |
        ForEach-Object {
            $Rel = Get-AttributeValue -Tag $_.Value -AttributeName "rel"
            $Href = Get-AttributeValue -Tag $_.Value -AttributeName "href"
            if ($Rel -match '(?i)(^|\s)stylesheet(\s|$)' -and -not [string]::IsNullOrWhiteSpace($Href)) {
                $Href
            }
        }
    )

    $ScriptReferences = @(
        [regex]::Matches($Html, '(?is)<script\b[^>]*>') |
        ForEach-Object {
            $Src = Get-AttributeValue -Tag $_.Value -AttributeName "src"
            if (-not [string]::IsNullOrWhiteSpace($Src)) {
                $Src
            }
        }
    )

    $DuplicateStylesheets = @(
        $StylesheetReferences |
        Group-Object |
        Where-Object Count -gt 1
    )
    foreach ($Duplicate in $DuplicateStylesheets) {
        Add-Finding -Collection $Findings -Severity WARN -Rule DUPLICATE_STYLESHEET -File $RelativePath -Detail "Stylesheet '$($Duplicate.Name)' wird $($Duplicate.Count)-mal referenziert."
    }

    $DuplicateScripts = @(
        $ScriptReferences |
        Group-Object |
        Where-Object Count -gt 1
    )
    foreach ($Duplicate in $DuplicateScripts) {
        Add-Finding -Collection $Findings -Severity WARN -Rule DUPLICATE_SCRIPT -File $RelativePath -Detail "Skript '$($Duplicate.Name)' wird $($Duplicate.Count)-mal referenziert."
    }

    $AssetReferences = [Collections.Generic.List[string]]::new()
    foreach ($Reference in $StylesheetReferences) { $AssetReferences.Add($Reference) }
    foreach ($Reference in $ScriptReferences) { $AssetReferences.Add($Reference) }

    foreach ($ImageMatch in $ImageMatches) {
        $Source = Get-AttributeValue -Tag $ImageMatch.Value -AttributeName "src"
        if (-not [string]::IsNullOrWhiteSpace($Source)) {
            $AssetReferences.Add($Source)
        }

        $SourceSet = Get-AttributeValue -Tag $ImageMatch.Value -AttributeName "srcset"
        if (-not [string]::IsNullOrWhiteSpace($SourceSet)) {
            foreach ($Candidate in ($SourceSet -split ',')) {
                $CandidateUrl = (($Candidate.Trim()) -split '\s+')[0]
                if (-not [string]::IsNullOrWhiteSpace($CandidateUrl)) {
                    $AssetReferences.Add($CandidateUrl)
                }
            }
        }
    }

    foreach ($MediaTag in [regex]::Matches($Html, '(?is)<(?:source|video|audio)\b[^>]*>')) {
        $Source = Get-AttributeValue -Tag $MediaTag.Value -AttributeName "src"
        if (-not [string]::IsNullOrWhiteSpace($Source)) {
            $AssetReferences.Add($Source)
        }
    }

    $MissingAssetCount = 0
    foreach ($Reference in @($AssetReferences | Sort-Object -Unique)) {
        $ResolvedPath = Resolve-LocalReference -Reference $Reference -HtmlFilePath $HtmlFile.FullName
        if ($null -ne $ResolvedPath -and -not (Test-Path -LiteralPath $ResolvedPath -PathType Leaf)) {
            $MissingAssetCount++
            Add-Finding -Collection $Findings -Severity FAIL -Rule MISSING_ASSET -File $RelativePath -Detail "Lokales Asset fehlt: $Reference"
        }
    }

    $PageFindingCount = $Findings.Count - $PageFindingStart

    $PageResults.Add(
        [pscustomobject]@{
            File                   = $RelativePath
            SizeBytes              = $HtmlFile.Length
            Language               = $Language
            Title                  = $Title
            H1Count                = $H1Matches.Count
            HeadingCount           = $HeadingMatches.Count
            ImageCount             = $ImageMatches.Count
            MissingAltCount        = $MissingAltCount
            LinkCount              = $AnchorMatches.Count
            EmptyLinkCount         = $EmptyLinkCount
            ButtonCount            = $ButtonMatches.Count
            EmptyButtonCount       = $EmptyButtonCount
            FormControlCount       = $FormControlMatches.Count
            UnlabelledControlCount = $UnlabelledControlCount
            StylesheetCount        = $StylesheetReferences.Count
            ScriptReferenceCount   = $ScriptReferences.Count
            MissingAssetCount      = $MissingAssetCount
            FindingCount           = $PageFindingCount
        }
    )

    Write-Host ("[CHECKED] {0}" -f $RelativePath) -ForegroundColor DarkGray
}

Write-Section "CSS ACCESSIBILITY SIGNALS"

$CombinedCss = ""
if ($CssFiles.Count -gt 0) {
    $CombinedCss = ($CssFiles | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
}

if ($CssFiles.Count -eq 0) {
    Add-Finding -Collection $Findings -Severity INFO -Rule NO_CSS_FILES -File "(repository)" -Detail "Keine CSS-Dateien gefunden."
}
else {
    if ($CombinedCss -notmatch '(?i):focus(?:-visible)?\b') {
        Add-Finding -Collection $Findings -Severity WARN -Rule FOCUS_STYLE_NOT_FOUND -File "(stylesheets)" -Detail "Keine explizite :focus- oder :focus-visible-Regel gefunden. Manuell pruefen."
    }

    if ($CombinedCss -notmatch '(?i)prefers-reduced-motion') {
        Add-Finding -Collection $Findings -Severity INFO -Rule REDUCED_MOTION_NOT_FOUND -File "(stylesheets)" -Detail "Keine prefers-reduced-motion-Regel gefunden. Bei Animationen manuell pruefen."
    }
}

$Failures = @($Findings | Where-Object Severity -eq "FAIL")
$Warnings = @($Findings | Where-Object Severity -eq "WARN")
$Information = @($Findings | Where-Object Severity -eq "INFO")

Write-Section "AUDIT FINDINGS"

if ($Findings.Count -eq 0) {
    Write-Host "[PASS] Keine automatisierbaren Befunde." -ForegroundColor Green
}
else {
    $Findings |
        Sort-Object Severity, Rule, File |
        Format-Table Severity, Rule, File, Detail -AutoSize -Wrap
}

Write-Section "REPORT GENERATION"

$Report = [pscustomobject]@{
    GeneratedUtc   = (Get-Date).ToUniversalTime().ToString("o")
    RepositoryRoot = $RepositoryRoot
    Thresholds     = [pscustomobject]@{
        LargeHtmlBytes              = $LargeHtmlBytes
        LargeCssBytes               = $LargeCssBytes
        LargeJavaScriptBytes        = $LargeJavaScriptBytes
        LargeImageBytes             = $LargeImageBytes
        LargeFontBytes              = $LargeFontBytes
        LargeMediaBytes             = $LargeMediaBytes
        LargeOtherBytes             = $LargeOtherBytes
        LargeInlineBlockCharacters  = $LargeInlineBlockCharacters
    }
    Summary = [pscustomobject]@{
        TotalFiles          = $Files.Count
        HtmlFiles           = $HtmlFiles.Count
        CssFiles            = $CssFiles.Count
        JavaScriptFiles     = $JavaScriptFiles.Count
        Images              = $ImageFiles.Count
        Fonts               = $FontFiles.Count
        JsonFiles           = $JsonFiles.Count
        MediaFiles          = $MediaFiles.Count
        RepositorySizeBytes = [long](($Inventory | Measure-Object SizeBytes -Sum).Sum)
        LargeAssets         = $LargeAssets.Count
        Failures            = $Failures.Count
        Warnings            = $Warnings.Count
        Information         = $Information.Count
        TotalFindings       = $Findings.Count
        AuditPassed         = ($Failures.Count -eq 0)
    }
    InventorySummary = @($InventorySummary)
    LargestFiles = @(
        $Inventory |
        Sort-Object SizeBytes -Descending |
        Select-Object -First 30
    )
    Pages    = @($PageResults)
    Findings = @($Findings)
    ManualReviewRequired = @(
        "Tastaturbedienung und Tab-Reihenfolge",
        "Sichtbarer und nicht verdeckter Fokus",
        "Farbkontraste",
        "Zoom und Reflow",
        "Mobile Darstellung",
        "Screenreader-Verstaendlichkeit",
        "Fehlermeldungen und dynamische Statusaenderungen",
        "Touch-Zielgroessen",
        "Bedeutung und Qualitaet von Alternativtexten"
    )
}

$Report |
    ConvertTo-Json -Depth 10 |
    Set-Content -LiteralPath $ReportPath -Encoding utf8NoBOM

Write-Host ("[PASS] Bericht erstellt: {0}" -f $ReportPath) -ForegroundColor Green

Write-Host ""
Write-Host "============================================================"
Write-Host " PERFORMANCE & ACCESSIBILITY AUDIT SUMMARY"
Write-Host "============================================================"
Write-Host ("HTML pages          : {0}" -f $HtmlFiles.Count)
Write-Host ("CSS files           : {0}" -f $CssFiles.Count)
Write-Host ("JavaScript files    : {0}" -f $JavaScriptFiles.Count)
Write-Host ("Images              : {0}" -f $ImageFiles.Count)
Write-Host ("Fonts               : {0}" -f $FontFiles.Count)
Write-Host ("Media files         : {0}" -f $MediaFiles.Count)
Write-Host ("Large assets        : {0}" -f $LargeAssets.Count)
Write-Host ("Failures            : {0}" -f $Failures.Count)
Write-Host ("Warnings            : {0}" -f $Warnings.Count)
Write-Host ("Information         : {0}" -f $Information.Count)
Write-Host ("Total findings      : {0}" -f $Findings.Count)
Write-Host ("Report              : {0}" -f $ReportPath)
Write-Host ("AUDIT PASSED        : {0}" -f ($Failures.Count -eq 0))
Write-Host "============================================================"

Write-Host ""
Write-Host "MANUAL REVIEW STILL REQUIRED" -ForegroundColor Yellow
Write-Host "- Tastatur und Fokus"
Write-Host "- Kontrast, Zoom und Reflow"
Write-Host "- Mobile und Touch-Bedienung"
Write-Host "- Screenreader und dynamische Statusmeldungen"

if ($Failures.Count -eq 0) {
    Write-Host "[PASS] PERFORMANCE & ACCESSIBILITY AUDIT COMPLETE" -ForegroundColor Green
    exit 0
}

Write-Host "[FAIL] PERFORMANCE & ACCESSIBILITY AUDIT FAILED" -ForegroundColor Red
exit 1
