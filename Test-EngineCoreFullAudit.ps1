$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Root = 'C:\corecraftgenesis-github'
$EngineCoreRoot = Join-Path $Root 'products\enginecore'
$ReportPath = Join-Path $Root 'enginecore-full-audit.json'

Set-Location -LiteralPath $Root

Write-Host ''
Write-Host ('=' * 76) -ForegroundColor Cyan
Write-Host ' ENGINECORE FULL AUDIT' -ForegroundColor Cyan
Write-Host ('=' * 76) -ForegroundColor Cyan
Write-Host "Root: $EngineCoreRoot"
Write-Host ''

if (-not (Test-Path -LiteralPath $EngineCoreRoot -PathType Container)) {
    throw "EngineCore-Verzeichnis nicht gefunden: $EngineCoreRoot"
}

$Pages = @(
    [pscustomobject]@{
        Area          = 'Architecture'
        Number        = '01'
        RelativePath  = 'architecture\index.html'
        Route         = '/products/enginecore/architecture/'
        PreviousRoute = $null
        NextRoute     = '/products/enginecore/runtime/'
    }
    [pscustomobject]@{
        Area          = 'Runtime'
        Number        = '02'
        RelativePath  = 'runtime\index.html'
        Route         = '/products/enginecore/runtime/'
        PreviousRoute = '/products/enginecore/architecture/'
        NextRoute     = '/products/enginecore/modules/'
    }
    [pscustomobject]@{
        Area          = 'Modules'
        Number        = '03'
        RelativePath  = 'modules\index.html'
        Route         = '/products/enginecore/modules/'
        PreviousRoute = '/products/enginecore/runtime/'
        NextRoute     = '/products/enginecore/validation/'
    }
    [pscustomobject]@{
        Area          = 'Validation'
        Number        = '04'
        RelativePath  = 'validation\index.html'
        Route         = '/products/enginecore/validation/'
        PreviousRoute = '/products/enginecore/modules/'
        NextRoute     = '/products/enginecore/diagnostics/'
    }
    [pscustomobject]@{
        Area          = 'Diagnostics'
        Number        = '05'
        RelativePath  = 'diagnostics\index.html'
        Route         = '/products/enginecore/diagnostics/'
        PreviousRoute = '/products/enginecore/validation/'
        NextRoute     = '/products/enginecore/developer/'
    }
)

$AuditResults = [System.Collections.Generic.List[object]]::new()
$PageSummary = [System.Collections.Generic.List[object]]::new()

function Add-AuditResult {
    param(
        [Parameter(Mandatory)]
        [string]$Area,

        [Parameter(Mandatory)]
        [string]$Check,

        [Parameter(Mandatory)]
        [bool]$Passed,

        [Parameter(Mandatory)]
        [ValidateSet('ERROR', 'WARN')]
        [string]$Severity,

        [string]$Detail = ''
    )

    $AuditResults.Add(
        [pscustomobject]@{
            Area     = $Area
            Check    = $Check
            Result   = if ($Passed) { 'PASS' } else { 'FAIL' }
            Severity = $Severity
            Detail   = $Detail
        }
    )
}

Write-Host 'PAGE VALIDATION'
Write-Host ('-' * 76)

foreach ($Page in $Pages) {
    $File = Join-Path $EngineCoreRoot $Page.RelativePath
    $FileExists = Test-Path -LiteralPath $File -PathType Leaf

    Add-AuditResult `
        -Area $Page.Area `
        -Check 'Datei vorhanden' `
        -Passed $FileExists `
        -Severity 'ERROR' `
        -Detail $File

    if (-not $FileExists) {
        Write-Host "[FAIL] $($Page.Area): Datei fehlt" -ForegroundColor Red
        continue
    }

    $Content = Get-Content -LiteralPath $File -Raw -Encoding UTF8
    $FileInfo = Get-Item -LiteralPath $File

    $NotEmpty = -not [string]::IsNullOrWhiteSpace($Content)

    Add-AuditResult $Page.Area 'Datei nicht leer' $NotEmpty 'ERROR'

    if (-not $NotEmpty) {
        Write-Host "[FAIL] $($Page.Area): Datei ist leer" -ForegroundColor Red
        continue
    }

    $CanonicalUrl = (
        'https://' +
        'corecraftgenesis.ch' +
        $Page.Route
    )

    $TitleMatch = [regex]::Match(
        $Content,
        '(?is)<title>\s*(.*?)\s*</title>'
    )

    $H1Match = [regex]::Match(
        $Content,
        '(?is)<h1\b[^>]*>\s*(.*?)\s*</h1>'
    )

    $H1Text = [regex]::Replace(
        $H1Match.Groups[1].Value,
        '<[^>]+>',
        ' '
    )

    $H1Text = [System.Net.WebUtility]::HtmlDecode($H1Text)
    $H1Text = [regex]::Replace($H1Text, '\s+', ' ').Trim()

    $TitleText = [System.Net.WebUtility]::HtmlDecode(
        $TitleMatch.Groups[1].Value
    ).Trim()

    $CanonicalMatch = [regex]::Match(
        $Content,
        '(?is)<link\b(?=[^>]*\brel\s*=\s*["'']canonical["''])[^>]*\bhref\s*=\s*["'']([^"'']+)["''][^>]*>'
    )

    $CanonicalValue = $CanonicalMatch.Groups[1].Value.Trim()

    Add-AuditResult $Page.Area 'DOCTYPE vorhanden' (
        $Content -match '(?i)<!DOCTYPE html>'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'HTML-Element vorhanden' (
        $Content -match '(?i)<html(?:\s|>)'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Sprachattribut vorhanden' (
        $Content -match '(?i)<html\b[^>]*\blang\s*=\s*["''][^"'']+["'']'
    ) 'WARN'

    Add-AuditResult $Page.Area 'Head vorhanden' (
        $Content -match '(?i)<head(?:\s|>)'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'UTF-8 festgelegt' (
        $Content -match '(?i)<meta\s+charset\s*=\s*["'']?utf-8'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Viewport vorhanden' (
        $Content -match '(?i)<meta\s+name\s*=\s*["'']viewport["'']'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Title vorhanden' (
        $TitleMatch.Success -and
        -not [string]::IsNullOrWhiteSpace($TitleText)
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Title enthält EngineCore' (
        $TitleText -match '(?i)EngineCore'
    ) 'WARN' $TitleText

    Add-AuditResult $Page.Area "Title enthält $($Page.Area)" (
        $TitleText -match [regex]::Escape($Page.Area)
    ) 'WARN' $TitleText

    Add-AuditResult $Page.Area 'Meta-Description vorhanden' (
        $Content -match '(?is)<meta\s+name\s*=\s*["'']description["''][^>]*\bcontent\s*=\s*["''][^"'']+["'']'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Robots-Meta vorhanden' (
        $Content -match '(?is)<meta\s+name\s*=\s*["'']robots["''][^>]*>'
    ) 'WARN'

    Add-AuditResult $Page.Area 'Canonical vorhanden' (
        $CanonicalMatch.Success
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Canonical korrekt' (
        $CanonicalValue -eq $CanonicalUrl
    ) 'ERROR' $CanonicalValue

    Add-AuditResult $Page.Area 'Body vorhanden' (
        $Content -match '(?i)<body(?:\s|>)'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Header vorhanden' (
        $Content -match '(?i)<header(?:\s|>)'
    ) 'WARN'

    Add-AuditResult $Page.Area 'Navigation vorhanden' (
        $Content -match '(?i)<nav(?:\s|>)'
    ) 'WARN'

    Add-AuditResult $Page.Area 'Main-Bereich vorhanden' (
        $Content -match '(?i)<main(?:\s|>)'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Genau eine H1 vorhanden' (
        ([regex]::Matches($Content, '(?i)<h1(?:\s|>)')).Count -eq 1
    ) 'ERROR'

    Add-AuditResult $Page.Area 'H1 enthält Bereichsbezeichnung' (
        $H1Text -match [regex]::Escape($Page.Area)
    ) 'WARN' $H1Text

    Add-AuditResult $Page.Area 'Footer vorhanden' (
        $Content -match '(?i)<footer(?:\s|>)'
    ) 'WARN'

    Add-AuditResult $Page.Area 'Selbstlink vorhanden' (
        $Content -match (
            'href\s*=\s*["'']' +
            [regex]::Escape($Page.Route) +
            '["'']'
        )
    ) 'WARN' $Page.Route

    if ($null -ne $Page.PreviousRoute) {
        Add-AuditResult $Page.Area 'Link zum vorherigen Bereich' (
            $Content -match (
                'href\s*=\s*["'']' +
                [regex]::Escape($Page.PreviousRoute) +
                '["'']'
            )
        ) 'ERROR' $Page.PreviousRoute
    }

    if ($null -ne $Page.NextRoute) {
        Add-AuditResult $Page.Area 'Link zum nächsten Bereich' (
            $Content -match (
                'href\s*=\s*["'']' +
                [regex]::Escape($Page.NextRoute) +
                '["'']'
            )
        ) 'ERROR' $Page.NextRoute
    }

    Add-AuditResult $Page.Area 'Keine codierten HTML-Tags' (
        $Content -notmatch '&lt;/?[a-zA-Z][^&]*&gt;'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Keine Links in href-Attributen' (
        $Content -notmatch 'href\s*=\s*["'']\s*<a\b'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Keine Chat-Artefakte' (
        $Content -notmatch 'ChatInputEntity|fai-|data-lexical-text|spellcheck="false"'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Kein JavaScript-Link' (
        $Content -notmatch '(?i)href\s*=\s*["'']\s*javascript:'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Kein leerer href-Wert' (
        $Content -notmatch '(?i)href\s*=\s*["'']\s*["'']'
    ) 'WARN'

    Add-AuditResult $Page.Area 'Schliessender Main-Tag' (
        $Content -match '(?i)</main>'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'Schliessender Body-Tag' (
        $Content -match '(?i)</body>'
    ) 'ERROR'

    Add-AuditResult $Page.Area 'HTML sauber geschlossen' (
        $Content -match '(?i)</html>\s*$'
    ) 'ERROR'

    $PageSummary.Add(
        [pscustomobject]@{
            Area       = $Page.Area
            Number     = $Page.Number
            File       = $Page.RelativePath
            SizeKB     = [math]::Round($FileInfo.Length / 1KB, 2)
            Title      = $TitleText
            H1         = $H1Text
            Canonical  = $CanonicalValue
            SHA256     = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
        }
    )

    Write-Host "[CHECKED] $($Page.RelativePath)" -ForegroundColor Green
}

Write-Host ''
Write-Host 'CROSS-PAGE CONSISTENCY'
Write-Host ('-' * 76)

$ExistingPages = @(
    $Pages | Where-Object {
        Test-Path `
            -LiteralPath (Join-Path $EngineCoreRoot $_.RelativePath) `
            -PathType Leaf
    }
)

$CanonicalValues = @(
    $PageSummary |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.Canonical) } |
        Select-Object -ExpandProperty Canonical
)

$DuplicateCanonicals = @(
    $CanonicalValues |
        Group-Object |
        Where-Object Count -gt 1
)

Add-AuditResult `
    -Area 'CrossPage' `
    -Check 'Keine doppelten Canonical-URLs' `
    -Passed ($DuplicateCanonicals.Count -eq 0) `
    -Severity 'ERROR' `
    -Detail (
        ($DuplicateCanonicals | ForEach-Object Name) -join '; '
    )

$Titles = @(
    $PageSummary |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.Title) } |
        Select-Object -ExpandProperty Title
)

$DuplicateTitles = @(
    $Titles |
        Group-Object |
        Where-Object Count -gt 1
)

Add-AuditResult `
    -Area 'CrossPage' `
    -Check 'Keine doppelten Seitentitel' `
    -Passed ($DuplicateTitles.Count -eq 0) `
    -Severity 'WARN' `
    -Detail (
        ($DuplicateTitles | ForEach-Object Name) -join '; '
    )

Add-AuditResult `
    -Area 'CrossPage' `
    -Check 'Alle fünf Kernseiten vorhanden' `
    -Passed ($ExistingPages.Count -eq $Pages.Count) `
    -Severity 'ERROR' `
    -Detail "$($ExistingPages.Count)/$($Pages.Count)"

$ErrorFailures = @(
    $AuditResults |
        Where-Object {
            $_.Result -eq 'FAIL' -and
            $_.Severity -eq 'ERROR'
        }
)

$WarningFailures = @(
    $AuditResults |
        Where-Object {
            $_.Result -eq 'FAIL' -and
            $_.Severity -eq 'WARN'
        }
)

$PassedChecks = @(
    $AuditResults |
        Where-Object Result -eq 'PASS'
)

$FinalPassed = $ErrorFailures.Count -eq 0

$Report = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    root = $EngineCoreRoot
    summary = [ordered]@{
        pagesExpected = $Pages.Count
        pagesFound = $ExistingPages.Count
        totalChecks = $AuditResults.Count
        passedChecks = $PassedChecks.Count
        errorFailures = $ErrorFailures.Count
        warnings = $WarningFailures.Count
        auditPassed = $FinalPassed
    }
    pages = @($PageSummary)
    findings = @(
        $AuditResults |
            Where-Object Result -eq 'FAIL'
    )
    checks = @($AuditResults)
}

$Report |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath $ReportPath `
        -Encoding UTF8

Write-Host ''
Write-Host 'PAGE SUMMARY'
Write-Host ('-' * 76)

$PageSummary |
    Select-Object Area, Number, SizeKB, Title, H1 |
    Format-Table -AutoSize -Wrap

Write-Host ''
Write-Host 'AUDIT FINDINGS'
Write-Host ('-' * 76)

$Findings = @(
    $AuditResults |
        Where-Object Result -eq 'FAIL'
)

if ($Findings.Count -eq 0) {
    Write-Host '[PASS] Keine Findings.' -ForegroundColor Green
}
else {
    $Findings |
        Select-Object Severity, Area, Check, Detail |
        Format-Table -AutoSize -Wrap
}

Write-Host ''
Write-Host ('=' * 76) -ForegroundColor Cyan
Write-Host ' ENGINECORE AUDIT SUMMARY' -ForegroundColor Cyan
Write-Host ('=' * 76) -ForegroundColor Cyan
Write-Host "Erwartete Seiten : $($Pages.Count)"
Write-Host "Gefundene Seiten : $($ExistingPages.Count)"
Write-Host "Prüfungen        : $($AuditResults.Count)"
Write-Host "Bestanden         : $($PassedChecks.Count)"
Write-Host "Fehler            : $($ErrorFailures.Count)"
Write-Host "Warnungen         : $($WarningFailures.Count)"
Write-Host "Bericht           : $ReportPath"

if ($FinalPassed) {
    Write-Host 'AUDIT PASSED       : True' -ForegroundColor Green
    Write-Host '[PASS] ENGINECORE FULL AUDIT COMPLETE' -ForegroundColor Green
}
else {
    Write-Host 'AUDIT PASSED       : False' -ForegroundColor Red
    Write-Host '[FAIL] ENGINECORE FULL AUDIT FAILED' -ForegroundColor Red
    exit 1
}
