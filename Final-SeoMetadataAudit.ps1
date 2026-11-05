[CmdletBinding()]
param(
    [string]$RepositoryRoot = "C:\corecraftgenesis-github",
    [string]$ReportFileName = "seo-metadata-audit.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$BaseUrl = (
    "https:" +
    [char]47 +
    [char]47 +
    "corecraftgenesis.ch"
)

$MinimumTitleLength = 15
$MaximumTitleLength = 70
$MinimumDescriptionLength = 50
$MaximumDescriptionLength = 170

function Write-Section {
    param(
        [Parameter(Mandatory)]
        [string]$Title
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("-" * 60)
}

function Get-RelativeFilePath {
    param(
        [Parameter(Mandatory)]
        [string]$Root,

        [Parameter(Mandatory)]
        [string]$Path
    )

    return [IO.Path]::GetRelativePath(
        [IO.Path]::GetFullPath($Root),
        [IO.Path]::GetFullPath($Path)
    )
}

function Get-ExpectedUrl {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $Normalized = $RelativePath.Replace(
        "\",
        "/"
    )

    if ($Normalized -eq "index.html") {
        return "$BaseUrl/"
    }

    if ($Normalized -eq "404.html") {
        return "$BaseUrl/404.html"
    }

    if ($Normalized.EndsWith("/index.html")) {
        $Route = $Normalized.Substring(
            0,
            $Normalized.Length - "index.html".Length
        )

        return "$BaseUrl/$Route"
    }

    return "$BaseUrl/$Normalized"
}

function Normalize-HtmlText {
    param(
        [AllowEmptyString()]
        [string]$Value
    )

    if ($null -eq $Value) {
        return ""
    }

    $Text = $Value -replace '<[^>]+>', ' '
    $Text = [Net.WebUtility]::HtmlDecode($Text)
    $Text = $Text -replace '\s+', ' '

    return $Text.Trim()
}

function Get-TitleValue {
    param(
        [Parameter(Mandatory)]
        [string]$Html
    )

    if (
        $Html -match
        '(?is)<title\b[^>]*>(?<value>.*?)</title>'
    ) {
        return Normalize-HtmlText `
            -Value $Matches["value"]
    }

    return ""
}

function Get-MetaValue {
    param(
        [Parameter(Mandatory)]
        [string]$Html,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $EscapedName = [regex]::Escape($Name)

    $NameBeforeContent = (
        '(?is)<meta\b' +
        '(?=[^>]*\bname\s*=\s*["'']' +
        $EscapedName +
        '["''])' +
        '(?=[^>]*\bcontent\s*=\s*["'']' +
        '(?<value>[^"'']*)["''])' +
        '[^>]*>'
    )

    if ($Html -match $NameBeforeContent) {
        return [Net.WebUtility]::HtmlDecode(
            $Matches["value"].Trim()
        )
    }

    return ""
}

function Get-CanonicalValue {
    param(
        [Parameter(Mandatory)]
        [string]$Html
    )

    $Pattern = (
        '(?is)<link\b' +
        '(?=[^>]*\brel\s*=\s*["'']' +
        '[^"'']*\bcanonical\b[^"'']*["''])' +
        '(?=[^>]*\bhref\s*=\s*["'']' +
        '(?<value>[^"'']+)["''])' +
        '[^>]*>'
    )

    if ($Html -match $Pattern) {
        return [Net.WebUtility]::HtmlDecode(
            $Matches["value"].Trim()
        )
    }

    return ""
}

function Get-HtmlLanguage {
    param(
        [Parameter(Mandatory)]
        [string]$Html
    )

    if (
        $Html -match
        '(?is)<html\b[^>]*\blang\s*=\s*["''](?<value>[^"'']+)["'']'
    ) {
        return $Matches["value"].Trim()
    }

    return ""
}

function Get-HeadingInfo {
    param(
        [Parameter(Mandatory)]
        [string]$Html,

        [Parameter(Mandatory)]
        [ValidateSet("h1", "h2")]
        [string]$Heading
    )

    $Pattern = (
        '(?is)<' +
        $Heading +
        '\b[^>]*>(?<value>.*?)</' +
        $Heading +
        '>'
    )

    $MatchesFound = @(
        [regex]::Matches(
            $Html,
            $Pattern
        )
    )

    $FirstText = ""

    if ($MatchesFound.Count -gt 0) {
        $FirstText = Normalize-HtmlText `
            -Value $MatchesFound[0].Groups["value"].Value
    }

    return [pscustomobject]@{
        Count     = $MatchesFound.Count
        FirstText = $FirstText
    }
}

function Test-NoIndex {
    param(
        [AllowEmptyString()]
        [string]$Robots
    )

    if (
        $null -eq $Robots -or
        $Robots.Trim().Length -eq 0
    ) {
        return $false
    }

    $Directives = @(
        $Robots.ToLowerInvariant() -split '[,;\s]+'
    )

    return $Directives -contains "noindex"
}

function Add-Finding {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [Collections.Generic.List[object]]$Collection,

        [Parameter(Mandatory)]
        [string]$File,

        [Parameter(Mandatory)]
        [ValidateSet("FAIL", "WARN", "INFO")]
        [string]$Severity,

        [Parameter(Mandatory)]
        [string]$Rule,

        [Parameter(Mandatory)]
        [string]$Detail
    )

    $Collection.Add(
        [pscustomobject]@{
            File     = $File
            Severity = $Severity
            Rule     = $Rule
            Detail   = $Detail
        }
    )
}

Write-Host ""
Write-Host "============================================================"
Write-Host " CORECRAFT GENESIS - SEO METADATA AUDIT"
Write-Host "============================================================"

if (
    -not (
        Test-Path `
            -LiteralPath $RepositoryRoot `
            -PathType Container
    )
) {
    Write-Host "[FAIL] Repository-Root fehlt." -ForegroundColor Red
    exit 1
}

Write-Section "REFERENCE PARSER VALIDATION"

$ReferenceExpectations = @(
    [pscustomobject]@{
        File     = "404.html"
        Title    = "404 | Seite nicht gefunden | CoreCraft Genesis"
        NoIndex  = $true
    }

    [pscustomobject]@{
        File     = "index.html"
        Title    = "CoreCraft Genesis | Engineering, Intelligence & Digital Infrastructure"
        NoIndex  = $false
    }

    [pscustomobject]@{
        File     = "products\developer-tools\index.html"
        Title    = "Developer Tools | CoreCraft Genesis"
        NoIndex  = $false
    }

    [pscustomobject]@{
        File     = "products\developer-tools\validators\json\index.html"
        Title    = "JSON Validator | CoreCraft Genesis"
        NoIndex  = $false
    }
)

$ReferenceFailures = 0

foreach ($Reference in $ReferenceExpectations) {
    $ReferencePath = Join-Path `
        $RepositoryRoot `
        $Reference.File

    if (
        -not (
            Test-Path `
                -LiteralPath $ReferencePath `
                -PathType Leaf
        )
    ) {
        Write-Host (
            "[FAIL] Referenzdatei fehlt: {0}" -f
            $Reference.File
        ) -ForegroundColor Red

        $ReferenceFailures++
        continue
    }

    $ReferenceHtml = Get-Content `
        -LiteralPath $ReferencePath `
        -Raw

    $DetectedTitle = Get-TitleValue `
        -Html $ReferenceHtml

    $DetectedRobots = Get-MetaValue `
        -Html $ReferenceHtml `
        -Name "robots"

    $DetectedNoIndex = Test-NoIndex `
        -Robots $DetectedRobots

    $TitleValid = (
        $DetectedTitle -ceq
        $Reference.Title
    )

    $RobotsValid = (
        $DetectedNoIndex -eq
        $Reference.NoIndex
    )

    if ($TitleValid -and $RobotsValid) {
        Write-Host (
            "[PASS] {0}" -f
            $Reference.File
        ) -ForegroundColor Green
    }
    else {
        Write-Host (
            "[FAIL] {0}" -f
            $Reference.File
        ) -ForegroundColor Red

        Write-Host (
            "  Title expected : {0}" -f
            $Reference.Title
        )

        Write-Host (
            "  Title detected : {0}" -f
            $DetectedTitle
        )

        Write-Host (
            "  NoIndex expected: {0}" -f
            $Reference.NoIndex
        )

        Write-Host (
            "  NoIndex detected: {0}" -f
            $DetectedNoIndex
        )

        $ReferenceFailures++
    }
}

if ($ReferenceFailures -gt 0) {
    Write-Host ""
    Write-Host (
        "[FAIL] Referenzparser nicht verlaesslich. Fehler: {0}" -f
        $ReferenceFailures
    ) -ForegroundColor Red

    exit 1
}

Write-Host (
    "[PASS] Alle Referenzseiten korrekt erkannt."
) -ForegroundColor Green

Write-Section "HTML INVENTORY"

$Pages = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Filter "*.html" `
        -File `
        -Recurse |
    Where-Object {
        $Relative = Get-RelativeFilePath `
            -Root $RepositoryRoot `
            -Path $_.FullName

        -not (
            $Relative -like ".git\*" -or
            $Relative -like ".github\*" -or
            $Relative -like ".vscode\*"
        )
    } |
    Sort-Object FullName
)

Write-Host (
    "HTML pages found : {0}" -f
    $Pages.Count
)

$Findings = [Collections.Generic.List[object]]::new()
$PageResults = [Collections.Generic.List[object]]::new()

Write-Section "PAGE METADATA VALIDATION"

foreach ($Page in $Pages) {
    $RelativePath = Get-RelativeFilePath `
        -Root $RepositoryRoot `
        -Path $Page.FullName

    $Html = Get-Content `
        -LiteralPath $Page.FullName `
        -Raw

    if (
        $null -eq $Html -or
        $Html.Trim().Length -eq 0
    ) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "FAIL" `
            -Rule "HTML_EMPTY" `
            -Detail "HTML-Datei ist leer."

        continue
    }

    $Title = Get-TitleValue `
        -Html $Html

    $Description = Get-MetaValue `
        -Html $Html `
        -Name "description"

    $Robots = Get-MetaValue `
        -Html $Html `
        -Name "robots"

    $Viewport = Get-MetaValue `
        -Html $Html `
        -Name "viewport"

    $Canonical = Get-CanonicalValue `
        -Html $Html

    $Language = Get-HtmlLanguage `
        -Html $Html

    $H1 = Get-HeadingInfo `
        -Html $Html `
        -Heading "h1"

    $H2 = Get-HeadingInfo `
        -Html $Html `
        -Heading "h2"

    $NoIndex = Test-NoIndex `
        -Robots $Robots

    $ExpectedUrl = Get-ExpectedUrl `
        -RelativePath $RelativePath

    $Is404 = (
        $RelativePath -ieq "404.html"
    )

    if ($Title.Length -eq 0) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "FAIL" `
            -Rule "TITLE_MISSING" `
            -Detail "Kein title-Element vorhanden."
    }
    elseif ($Title.Length -lt $MinimumTitleLength) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "WARN" `
            -Rule "TITLE_SHORT" `
            -Detail "Titel hat $($Title.Length) Zeichen."
    }
    elseif ($Title.Length -gt $MaximumTitleLength) {
        Add-gs `
            -File $RelativePath `
            -Severity "WARN" `
            -Rule "TITLE_LONG" `
            -Detail "Titel hat $($Title.Length) Zeichen."
    }

    if ($Description.Length -eq 0) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "FAIL" `
            -Rule "DESCRIPTION_MISSING" `
            -Detail "Keine Meta Description vorhanden."
    }
    elseif ($Description.Length -lt $MinimumDescriptionLength) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "WARN" `
            -Rule "DESCRIPTION_SHORT" `
            -Detail "Beschreibung hat $($Description.Length) Zeichen."
    }
    elseif ($Description.Length -gt $MaximumDescriptionLength) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "WARN" `
            -Rule "DESCRIPTION_LONG" `
            -Detail "Beschreibung hat $($Description.Length) Zeichen."
    }

    if ($Viewport.Length -eq 0) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "FAIL" `
            -Rule "VIEWPORT_MISSING" `
            -Detail "Viewport-Meta-Tag fehlt."
    }

    if ($Language.Length -eq 0) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "FAIL" `
            -Rule "LANG_MISSING" `
            -Detail "lang-Attribut fehlt."
    }

    if ($H1.Count -eq 0) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "FAIL" `
            -Rule "H1_MISSING" `
            -Detail "H1-Ueberschrift fehlt."
    }
    elseif ($H1.Count -gt 1) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "WARN" `
            -Rule "H1_MULTIPLE" `
            -Detail "$($H1.Count) H1-Ueberschriften vorhanden."
    }

    if ($H2.Count -eq 0) {
        Add-Finding `
            -Collection $Findings `
            -File $RelativePath `
            -Severity "INFO" `
            -Rule "H2_MISSING" `
            -Detail "Keine H2-Ueberschrift vorhanden."
    }

    if ($Is404) {
        if (-not $NoIndex) {
            Add-Finding `
                -Collection $Findings `
                -File $RelativePath `
                -Severity "FAIL" `
                -Rule "404_INDEXABLE" `
                -Detail "404-Seite besitzt kein noindex."
        }
    }
    else {
        if ($NoIndex) {
            Add-Finding `
                -Collection $Findings `
                -File $RelativePath `
                -Severity "WARN" `
                -Rule "PAGE_NOINDEX" `
                -Detail "Regulaere Seite besitzt noindex."
        }

        if ($Canonical.Length -eq 0) {
            Add-Finding `
                -Collection $Findings `
                -File $RelativePath `
                -Severity "WARN" `
                -Rule "CANONICAL_MISSING" `
                -Detail "Keine Canonical-URL definiert."
        }
        elseif (
            $Canonical.TrimEnd("/") -ne
            $ExpectedUrl.TrimEnd("/")
        ) {
            Add-Finding `
                -Collection $Findings `
                -File $RelativePath `
                -Severity "WARN" `
                -Rule "CANONICAL_MISMATCH" `
                -Detail "Erwartet: $ExpectedUrl | Gefunden: $Canonical"
        }
    }

    $PageResults.Add(
        [pscustomobject]@{
            File              = $RelativePath
            ExpectedUrl       = $ExpectedUrl
            Title             = $Title
            TitleLength       = $Title.Length
            Description       = $Description
            DescriptionLength = $Description.Length
            Canonical         = $Canonical
            Robots            = $Robots
            NoIndex           = $NoIndex
            Language          = $Language
            H1Count           = $H1.Count
            H1Text            = $H1.FirstText
            H2Count           = $H2.Count
        }
    )

    Write-Host (
        "[CHECKED] {0}" -f
        $RelativePath
    ) -ForegroundColor DarkGray
}

Write-Section "DUPLICATE VALIDATION"

$DuplicateTitleGroups = @(
    $PageResults |
    Where-Object {
        $_.Title.Length -gt 0
    } |
    Group-Object Title |
    Where-Object {
        $_.Count -gt 1
    }
)

foreach ($Group in $DuplicateTitleGroups) {
    foreach ($PageResult in $Group.Group) {
        Add-Finding `
            -Collection $Findings `
            -File $PageResult.File `
            -Severity "WARN" `
            -Rule "TITLE_DUPLICATE" `
            -Detail "Titel wird auf $($Group.Count) Seiten verwendet."
    }
}

$DuplicateDescriptionGroups = @(
    $PageResults |
    Where-Object {
        $_.Description.Length -gt 0
    } |
    Group-Object Description |
    Where-Object {
        $_.Count -gt 1
    }
)

foreach ($Group in $DuplicateDescriptionGroups) {
    foreach ($PageResult in $Group.Group) {
        Add-Finding `
            -Collection $Findings `
            -File $PageResult.File `
            -Severity "WARN" `
            -Rule "DESCRIPTION_DUPLICATE" `
            -Detail "Beschreibung wird auf $($Group.Count) Seiten verwendet."
    }
}

$Failures = @(
    $Findings |
    Where-Object {
        $_.Severity -eq "FAIL"
    }
)

$Warnings = @(
    $Findings |
    Where-Object {
        $_.Severity -eq "WARN"
    }
)

$Information = @(
    $Findings |
    Where-Object {
        $_.Severity -eq "INFO"
    }
)

Write-Section "SEO FINDINGS"

if ($Findings.Count -eq 0) {
    Write-Host "[PASS] Keine SEO-Befunde." -ForegroundColor Green
}

$Findings |
    Sort-Object Severity, File, Rule |
    Format-Table `
        Severity,
        Rule,
        File,
        Detail `
        -AutoSize `
        -Wrap

Write-Section "REPORT GENERATION"

$ReportPath = Join-Path `
    $RepositoryRoot `
    $ReportFileName

$Report = [pscustomobject]@{
    GeneratedUtc = (Get-Date).ToUniversalTime().ToString("o")
    RepositoryRoot = $RepositoryRoot
    BaseUrl = $BaseUrl

    Summary = [pscustomobject]@{
        HtmlPages = $Pages.Count
        ReferenceFailures = $ReferenceFailures
        MetadataFailures = $Failures.Count
        MetadataWarnings = $Warnings.Count
        MetadataInformation = $Information.Count
        DuplicateTitleGroups = $DuplicateTitleGroups.Count
        DuplicateDescriptionGroups = $DuplicateDescriptionGroups.Count
        TotalFindings = $Findings.Count
    }

    Pages = @($PageResults)
    Findings = @($Findings)
}

$Report |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath $ReportPath `
        -Encoding utf8NoBOM

Write-Host (
    "[PASS] Bericht erstellt: {0}" -f
    $ReportPath
) -ForegroundColor Green

Write-Host ""
Write-Host "============================================================"
Write-Host " FINAL SEO METADATA AUDIT SUMMARY"
Write-Host "============================================================"
Write-Host ("HTML pages          : {0}" -f $Pages.Count)
Write-Host ("Reference failures  : {0}" -f $ReferenceFailures)
Write-Host ("Metadata failures   : {0}" -f $Failures.Count)
Write-Host ("Metadata warnings   : {0}" -f $Warnings.Count)
Write-Host ("Metadata info       : {0}" -f $Information.Count)
Write-Host ("Duplicate titles    : {0}" -f $DuplicateTitleGroups.Count)
Write-Host ("Duplicate descs     : {0}" -f $DuplicateDescriptionGroups.Count)
Write-Host ("Total findings      : {0}" -f $Findings.Count)
Write-Host ("Report               : {0}" -f $ReportPath)
Write-Host "============================================================"

if ($Failures.Count -eq 0) {
    Write-Host "[PASS] SEO METADATA AUDIT COMPLETE" -ForegroundColor Green
    exit 0
}

Write-Host "[FAIL] SEO METADATA AUDIT FAILED" -ForegroundColor Red
exit 1