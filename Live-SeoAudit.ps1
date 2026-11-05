[CmdletBinding()]
param(
    [string]$RepositoryRoot = "C:\corecraftgenesis-github",
    [string]$BaseUrl = "https://corecraftgenesis.ch",
    [string]$ReportFileName = "live-seo-audit.json",
    [int]$TimeoutSeconds = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([Parameter(Mandatory)][string]$Title)
    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("-" * 60)
}

function Add-Finding {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()]
        [Collections.Generic.List[object]]$Collection,
        [Parameter(Mandatory)][ValidateSet("FAIL", "WARN", "INFO")]
        [string]$Severity,
        [Parameter(Mandatory)][string]$Rule,
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Detail
    )
    $Collection.Add([pscustomobject]@{
        Severity = $Severity
        Rule     = $Rule
        Url      = $Url
        Detail   = $Detail
    })
}

function Normalize-Text {
    param([AllowEmptyString()][string]$Value)
    if ($null -eq $Value) { return "" }
    $Text = $Value -replace '<[^>]+>', ' '
    $Text = [Net.WebUtility]::HtmlDecode($Text)
    return ($Text -replace '\s+', ' ').Trim()
}

function Get-TitleValue {
    param([Parameter(Mandatory)][string]$Html)
    if ($Html -match '(?is)<title\b[^>]*>(?<value>.*?)</title>') {
        return Normalize-Text -Value $Matches['value']
    }
    return ""
}

function Get-HtmlAttribute {
    param(
        [Parameter(Mandatory)]
        [string]$Tag,

        [Parameter(Mandatory)]
        [string]$AttributeName
    )

    $EscapedName = [regex]::Escape(
        $AttributeName
    )

    $Pattern = (
        '(?is)\b' +
        $EscapedName +
        '\s*=\s*' +
        '(?:"(?<double>[^"]*)"|' +
        "'(?<single>[^']*)'|" +
        '(?<plain>[^\s>]+))'
    )

    $Match = [regex]::Match(
        $Tag,
        $Pattern
    )

    if (-not $Match.Success) {
        return ""
    }

    if ($Match.Groups["double"].Success) {
        return [Net.WebUtility]::HtmlDecode(
            $Match.Groups["double"].Value.Trim()
        )
    }

    if ($Match.Groups["single"].Success) {
        return [Net.WebUtility]::HtmlDecode(
            $Match.Groups["single"].Value.Trim()
        )
    }

    return [Net.WebUtility]::HtmlDecode(
        $Match.Groups["plain"].Value.Trim()
    )
}

function Get-MetaValue {
    param(
        [Parameter(Mandatory)]
        [string]$Html,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $MetaTags = @(
        [regex]::Matches(
            $Html,
            '(?is)<meta\b[^>]*>'
        )
    )

    foreach ($MetaMatch in $MetaTags) {
        $Tag = $MetaMatch.Value

        $DetectedName = Get-HtmlAttribute `
            -Tag $Tag `
            -AttributeName "name"

        if ($DetectedName -ieq $Name) {
            return Get-HtmlAttribute `
                -Tag $Tag `
                -AttributeName "content"
        }
    }

    return ""
}

function Get-CanonicalValues {
    param([Parameter(Mandatory)][string]$Html)
    $Pattern = '(?is)<link\b(?=[^>]*\brel\s*=\s*["''][^"'']*\bcanonical\b[^"'']*["''])(?=[^>]*\bhref\s*=\s*["''](?<value>[^"'']+)["''])[^>]*>'
    return @([regex]::Matches($Html, $Pattern) | ForEach-Object {
        [Net.WebUtility]::HtmlDecode($_.Groups['value'].Value.Trim())
    })
}

function Test-NoIndex {
    param([AllowEmptyString()][string]$Robots)
    if ([string]::IsNullOrWhiteSpace($Robots)) { return $false }
    return @($Robots.ToLowerInvariant() -split '[,;\s]+' | Where-Object { $_ -eq 'noindex' }).Count -gt 0
}

function Invoke-LiveRequest {
    param([Parameter(Mandatory)][string]$Uri)
    $Stopwatch = [Diagnostics.Stopwatch]::StartNew()
    try {
        $Response = Invoke-WebRequest -Uri $Uri -Method Get -MaximumRedirection 10 -TimeoutSec $TimeoutSeconds -SkipHttpErrorCheck -ErrorAction Stop
        $Stopwatch.Stop()
        return [pscustomobject]@{
            Success      = $true
            StatusCode   = [int]$Response.StatusCode
            FinalUri     = [string]$Response.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
            Content      = [string]$Response.Content
            ContentType  = [string]$Response.Headers['Content-Type']
            DurationMs   = $Stopwatch.ElapsedMilliseconds
            ErrorMessage = ""
        }
    }
    catch {
        $Stopwatch.Stop()
        return [pscustomobject]@{
            Success      = $false
            StatusCode   = 0
            FinalUri     = $Uri
            Content      = ""
            ContentType  = ""
            DurationMs   = $Stopwatch.ElapsedMilliseconds
            ErrorMessage = $_.Exception.Message
        }
    }
}

function Convert-UrlToLocalPath {
    param([Parameter(Mandatory)][uri]$Uri)
    $Route = [uri]::UnescapeDataString($Uri.AbsolutePath).TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($Route)) {
        return Join-Path $RepositoryRoot 'index.html'
    }
    if ($Route.EndsWith('/')) {
        return Join-Path $RepositoryRoot ($Route.Replace('/', '\') + 'index.html')
    }
    return Join-Path $RepositoryRoot $Route.Replace('/', '\')
}

Write-Host ""
Write-Host "============================================================"
Write-Host " CORECRAFT GENESIS - LIVE SEO AUDIT"
Write-Host "============================================================"

if (-not (Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
    throw "Repository-Root nicht gefunden: $RepositoryRoot"
}

$BaseUrl = $BaseUrl.TrimEnd('/')
$RobotsUrl = "$BaseUrl/robots.txt"
$SitemapUrl = "$BaseUrl/sitemap.xml"
$MissingUrl = "$BaseUrl/__corecraft-live-seo-audit-missing__/"
$ReportPath = Join-Path $RepositoryRoot $ReportFileName

$Findings = [Collections.Generic.List[object]]::new()
$PageResults = [Collections.Generic.List[object]]::new()

Write-Section "ROBOTS VALIDATION"
$RobotsResponse = Invoke-LiveRequest -Uri $RobotsUrl
if (-not $RobotsResponse.Success -or $RobotsResponse.StatusCode -ne 200) {
    Add-Finding -Collection $Findings -Severity FAIL -Rule ROBOTS_HTTP -Url $RobotsUrl -Detail "robots.txt nicht mit HTTP 200 abrufbar."
} else {
    $ExpectedSitemapLine = "Sitemap: $SitemapUrl"
    if (-not $RobotsResponse.Content.Contains('User-agent: *')) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule ROBOTS_USER_AGENT -Url $RobotsUrl -Detail "User-agent: * fehlt."
    }
    if (-not $RobotsResponse.Content.Contains($ExpectedSitemapLine)) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule ROBOTS_SITEMAP -Url $RobotsUrl -Detail "Sitemap-Verweis fehlt oder ist falsch."
    }
    if ($RobotsResponse.Content -match '(?is)<a\b|fai-ChatInputEntity|target\s*=') {
        Add-Finding -Collection $Findings -Severity FAIL -Rule ROBOTS_HTML -Url $RobotsUrl -Detail "HTML-Markup in robots.txt gefunden."
    }
}

Write-Section "SITEMAP VALIDATION"
$SitemapResponse = Invoke-LiveRequest -Uri $SitemapUrl
$SitemapUrls = @()
if (-not $SitemapResponse.Success -or $SitemapResponse.StatusCode -ne 200) {
    Add-Finding -Collection $Findings -Severity FAIL -Rule SITEMAP_HTTP -Url $SitemapUrl -Detail "sitemap.xml nicht mit HTTP 200 abrufbar."
} else {
    try {
        [xml]$Sitemap = $SitemapResponse.Content
        $Ns = [Xml.XmlNamespaceManager]::new($Sitemap.NameTable)
        $Ns.AddNamespace('sm', 'http://www.sitemaps.org/schemas/sitemap/0.9')
        $SitemapUrls = @($Sitemap.SelectNodes('//sm:url/sm:loc', $Ns) | ForEach-Object { $_.InnerText.Trim() })
        if ($Sitemap.DocumentElement.LocalName -ne 'urlset') {
            Add-Finding -Collection $Findings -Severity FAIL -Rule SITEMAP_ROOT -Url $SitemapUrl -Detail "urlset-Root fehlt."
        }
        if ($SitemapUrls.Count -eq 0) {
            Add-Finding -Collection $Findings -Severity FAIL -Rule SITEMAP_EMPTY -Url $SitemapUrl -Detail "Keine Sitemap-URLs gefunden."
        }
        foreach ($Url in $SitemapUrls) {
            if (-not $Url.StartsWith("$BaseUrl/", [StringComparison]::OrdinalIgnoreCase)) {
                Add-Finding -Collection $Findings -Severity FAIL -Rule SITEMAP_HOST -Url $Url -Detail "URL verwendet nicht die erwartete Basisadresse."
            }
            if ($Url -match '/404(?:\.html)?/?$') {
                Add-Finding -Collection $Findings -Severity FAIL -Rule SITEMAP_404 -Url $Url -Detail "404-Seite darf nicht in der Sitemap stehen."
            }
        }
    }
    catch {
        Add-Finding -Collection $Findings -Severity FAIL -Rule SITEMAP_XML -Url $SitemapUrl -Detail $_.Exception.Message
    }
}

Write-Section "LIVE PAGE VALIDATION"
foreach ($Url in $SitemapUrls) {
    $Response = Invoke-LiveRequest -Uri $Url
    $Title = ""
    $Description = ""
    $Robots = ""
    $Canonicals = @()
    $LocalMatch = $false
    $LocalDetail = ""

    if (-not $Response.Success) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule HTTP_REQUEST -Url $Url -Detail $Response.ErrorMessage
    }
    elseif ($Response.StatusCode -lt 200 -or $Response.StatusCode -ge 400) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule HTTP_STATUS -Url $Url -Detail "HTTP $($Response.StatusCode)"
    }
    else {
        $Title = Get-TitleValue -Html $Response.Content
        $Description = Get-MetaValue -Html $Response.Content -Name 'description'
        $Robots = Get-MetaValue -Html $Response.Content -Name 'robots'
        $Canonicals = @(
    Get-CanonicalValues -Html $Response.Content
)

        if ([string]::IsNullOrWhiteSpace($Title)) {
            Add-Finding -Collection $Findings -Severity FAIL -Rule TITLE_MISSING -Url $Url -Detail "Title fehlt."
        }
        if ([string]::IsNullOrWhiteSpace($Description)) {
            Add-Finding -Collection $Findings -Severity FAIL -Rule DESCRIPTION_MISSING -Url $Url -Detail "Meta Description fehlt."
        }
        if (Test-NoIndex -Robots $Robots) {
            Add-Finding -Collection $Findings -Severity FAIL -Rule PAGE_NOINDEX -Url $Url -Detail "Indexierbare Sitemap-Seite besitzt noindex."
        }
        if ($Canonicals.Count -ne 1) {
            Add-Finding -Collection $Findings -Severity FAIL -Rule CANONICAL_COUNT -Url $Url -Detail "$($Canonicals.Count) Canonical-Tags gefunden."
        }
        elseif ($Canonicals[0].TrimEnd('/') -cne $Url.TrimEnd('/')) {
            Add-Finding -Collection $Findings -Severity FAIL -Rule CANONICAL_MISMATCH -Url $Url -Detail "Canonical: $($Canonicals[0])"
        }

        $LocalPath = Convert-UrlToLocalPath -Uri ([uri]$Url)
        if (Test-Path -LiteralPath $LocalPath -PathType Leaf) {
            $LocalHtml = Get-Content -LiteralPath $LocalPath -Raw
            $LocalTitle = Get-TitleValue -Html $LocalHtml
            $LocalDescription = Get-MetaValue -Html $LocalHtml -Name 'description'
            $LocalCanonical = @(Get-CanonicalValues -Html $LocalHtml)
            $LocalTitleNormalized = $LocalTitle.Normalize(
    [Text.NormalizationForm]::FormC
).Trim()

$LiveTitleNormalized = $Title.Normalize(
    [Text.NormalizationForm]::FormC
).Trim()

$LocalDescriptionNormalized = (
    $LocalDescription.Normalize(
        [Text.NormalizationForm]::FormC
    ) -replace '\s+', ' '
).Trim()

$LiveDescriptionNormalized = (
    $Description.Normalize(
        [Text.NormalizationForm]::FormC
    ) -replace '\s+', ' '
).Trim()

$LocalCanonicalNormalized = $LocalCanonical[0].TrimEnd("/")
$LiveCanonicalNormalized = $Url.TrimEnd("/")

$LocalMatch = (
    $LocalTitleNormalized -ceq $LiveTitleNormalized -and
    $LocalDescriptionNormalized -ceq $LiveDescriptionNormalized -and
    $LocalCanonical.Count -eq 1 -and
    $LocalCanonicalNormalized -ceq $LiveCanonicalNormalized
)
            if (-not $LocalMatch) {
                $LocalDetail = "Lokale und Live-Metadaten stimmen nicht ueberein."
                Add-Finding -Collection $Findings -Severity FAIL -Rule LOCAL_LIVE_MISMATCH -Url $Url -Detail $LocalDetail
            }
        }
        else {
            $LocalDetail = "Keine lokale Vergleichsdatei gefunden: $LocalPath"
            Add-Finding -Collection $Findings -Severity WARN -Rule LOCAL_FILE_MISSING -Url $Url -Detail $LocalDetail
        }
    }

    $PageResults.Add([pscustomobject]@{
        Url           = $Url
        StatusCode    = $Response.StatusCode
        FinalUrl      = $Response.FinalUri
        DurationMs    = $Response.DurationMs
        Title         = $Title
        Description   = $Description
        Canonical     = if ($Canonicals.Count -eq 1) { $Canonicals[0] } else { "" }
        CanonicalCount = $Canonicals.Count
        NoIndex       = Test-NoIndex -Robots $Robots
        LocalMatch    = $LocalMatch
        Detail        = $LocalDetail
    })

    $Color = if ($Response.StatusCode -ge 200 -and $Response.StatusCode -lt 400) { 'DarkGreen' } else { 'Red' }
    Write-Host ("[CHECKED] HTTP {0} {1}" -f $Response.StatusCode, $Url) -ForegroundColor $Color
}

Write-Section "DUPLICATE LIVE METADATA"
$DuplicateTitles = @($PageResults | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Title) } | Group-Object Title | Where-Object Count -gt 1)
foreach ($Group in $DuplicateTitles) {
    foreach ($Page in $Group.Group) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule TITLE_DUPLICATE -Url $Page.Url -Detail "Titel wird auf $($Group.Count) Seiten verwendet."
    }
}
$DuplicateDescriptions = @($PageResults | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Description) } | Group-Object Description | Where-Object Count -gt 1)
foreach ($Group in $DuplicateDescriptions) {
    foreach ($Page in $Group.Group) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule DESCRIPTION_DUPLICATE -Url $Page.Url -Detail "Beschreibung wird auf $($Group.Count) Seiten verwendet."
    }
}

Write-Section "404 VALIDATION"
$MissingResponse = Invoke-LiveRequest -Uri $MissingUrl
if (-not $MissingResponse.Success) {
    Add-Finding -Collection $Findings -Severity FAIL -Rule NOT_FOUND_REQUEST -Url $MissingUrl -Detail $MissingResponse.ErrorMessage
} else {
    $MissingRobots = Get-MetaValue -Html $MissingResponse.Content -Name 'robots'
    if ($MissingResponse.StatusCode -ne 404) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule NOT_FOUND_STATUS -Url $MissingUrl -Detail "Erwartet HTTP 404, erhalten HTTP $($MissingResponse.StatusCode)."
    }
    if (-not (Test-NoIndex -Robots $MissingRobots)) {
        Add-Finding -Collection $Findings -Severity FAIL -Rule NOT_FOUND_NOINDEX -Url $MissingUrl -Detail "404-Seite besitzt kein noindex."
    }
}

$Failures = @($Findings | Where-Object Severity -eq 'FAIL')
$Warnings = @($Findings | Where-Object Severity -eq 'WARN')
$Information = @($Findings | Where-Object Severity -eq 'INFO')

Write-Section "LIVE SEO FINDINGS"
$Findings | Sort-Object Severity, Rule, Url | Format-Table Severity, Rule, Url, Detail -AutoSize -Wrap

$Report = [pscustomobject]@{
    GeneratedUtc = (Get-Date).ToUniversalTime().ToString('o')
    BaseUrl = $BaseUrl
    Summary = [pscustomobject]@{
        SitemapUrls = $SitemapUrls.Count
        PagesChecked = $PageResults.Count
        Failures = $Failures.Count
        Warnings = $Warnings.Count
        Information = $Information.Count
        DuplicateTitleGroups = $DuplicateTitles.Count
        DuplicateDescriptionGroups = $DuplicateDescriptions.Count
        LiveSeoReady = ($Failures.Count -eq 0)
    }
    Robots = $RobotsResponse
    Sitemap = [pscustomobject]@{
        Url = $SitemapUrl
        StatusCode = $SitemapResponse.StatusCode
        UrlCount = $SitemapUrls.Count
    }
    MissingPage = [pscustomobject]@{
        Url = $MissingUrl
        StatusCode = $MissingResponse.StatusCode
    }
    Pages = @($PageResults)
    Findings = @($Findings)
}

$Report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ReportPath -Encoding utf8NoBOM

Write-Host ""
Write-Host "============================================================"
Write-Host " LIVE SEO AUDIT SUMMARY"
Write-Host "============================================================"
Write-Host ("Sitemap URLs       : {0}" -f $SitemapUrls.Count)
Write-Host ("Pages checked      : {0}" -f $PageResults.Count)
Write-Host ("Failures           : {0}" -f $Failures.Count)
Write-Host ("Warnings           : {0}" -f $Warnings.Count)
Write-Host ("Duplicate titles   : {0}" -f $DuplicateTitles.Count)
Write-Host ("Duplicate descs    : {0}" -f $DuplicateDescriptions.Count)
Write-Host ("404 status         : {0}" -f $MissingResponse.StatusCode)
Write-Host ("Report             : {0}" -f $ReportPath)
Write-Host ("LIVE SEO READY     : {0}" -f ($Failures.Count -eq 0))
Write-Host "============================================================"

if ($Failures.Count -eq 0) {
    Write-Host "[PASS] LIVE SEO AUDIT COMPLETE" -ForegroundColor Green
    exit 0
}

Write-Host "[FAIL] LIVE SEO AUDIT FAILED" -ForegroundColor Red
exit 1
