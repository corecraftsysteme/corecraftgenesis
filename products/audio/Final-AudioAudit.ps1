#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Root
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ReportPath = Join-Path $Root "final-audit.json"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CoreCraft Genesis - FINAL AUDIO AUDIT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Root: $Root"
Write-Host ""

# ============================================================
# 1. ROOT PRUEFEN
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] Audio-Root fehlt:" -ForegroundColor Red
    Write-Host "       $Root"
    exit 1
}

Write-Host "[PASS] Audio-Root vorhanden." -ForegroundColor Green
Write-Host ""

# ============================================================
# 2. ERWARTETE DATEIEN
# ============================================================

$ExpectedFiles = @(
    "index.html"

    "audiostate\index.html"
    "dsp\index.html"
    "orchestration\index.html"
    "validation\index.html"
    "scaling\index.html"
    "diagnostics\index.html"

    "tools\index.html"
    "tools\analyzer\index.html"
    "tools\oscillator\index.html"
    "tools\signal-monitor\index.html"

    "demos\index.html"
    "demos\signal-chain\index.html"
    "demos\audiostate\index.html"

    "assets\css\audio.css"

    "assets\js\audio-core.js"
    "assets\js\audio-analyzer.js"
    "assets\js\audio-state.js"
    "assets\js\ui.js"

    "assets\worklets\audio-processor.js"
    "assets\audio\samples\README.md"

    "data\modules.json"
    "data\capabilities.json"
    "data\tools.json"

    "README.md"
)

Write-Host "FILE AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$FileResults = foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $Root $RelativePath
    $Exists = Test-Path -LiteralPath $FullPath -PathType Leaf

    if (-not $Exists) {

        [pscustomobject]@{
            Status = "MISSING"
            Bytes  = 0
            File   = $RelativePath
            Path   = $FullPath
        }

        continue
    }

    $Item = Get-Item -LiteralPath $FullPath
    $Content = Get-Content -LiteralPath $FullPath -Raw

    $HasContent = -not [System.String]::IsNullOrWhiteSpace(
        $Content
    )

    $Status = if (
        $Item.Length -gt 0 -and
        $HasContent
    ) {
        "PASS"
    }
    else {
        "EMPTY"
    }

    [pscustomobject]@{
        Status = $Status
        Bytes  = $Item.Length
        File   = $RelativePath
        Path   = $FullPath
    }
}

$FileResults |
    Format-Table Status, Bytes, File -AutoSize

# ============================================================
# 3. HTML AUDIT
# ============================================================

Write-Host ""
Write-Host "HTML AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$HtmlFiles = @(
    Get-ChildItem `
        -LiteralPath $Root `
        -Filter "index.html" `
        -File `
        -Recurse
)

$HtmlResults = foreach ($File in $HtmlFiles) {

    $Content = Get-Content `
        -LiteralPath $File.FullName `
        -Raw

    $HasDoctype =
        $Content -match '(?i)<!DOCTYPE\s+html>'

    $HasHtmlStart =
        $Content -match '(?i)<html'

    $HasHead =
        $Content -match '(?i)<head>'

    $HasTitle =
        $Content -match '(?is)<title>.+?</title>'

    $HasBody =
        $Content -match '(?i)<body>'

    $HasHtmlEnd =
        $Content -match '(?i)</html>'

    $Valid = (
        $HasDoctype -and
        $HasHtmlStart -and
        $HasHead -and
        $HasTitle -and
        $HasBody -and
        $HasHtmlEnd
    )

    $Status = if ($Valid) {
        "PASS"
    }
    else {
        "INVALID"
    }

    [pscustomobject]@{
        Status  = $Status
        Doctype = $HasDoctype
        Title   = $HasTitle
        Body    = $HasBody
        HtmlEnd = $HasHtmlEnd
        File    = $File.FullName.Substring(
            $Root.Length + 1
        )
    }
}

$HtmlResults |
    Format-Table `
        Status,
        Doctype,
        Title,
        Body,
        HtmlEnd,
        File `
        -AutoSize

# ============================================================
# 4. JSON AUDIT
# ============================================================

Write-Host ""
Write-Host "JSON AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$JsonFiles = @(
    "data\modules.json"
    "data\capabilities.json"
    "data\tools.json"
)

$JsonResults = foreach ($RelativePath in $JsonFiles) {

    $FullPath = Join-Path $Root $RelativePath

    $Valid = $false
    $Message = ""

    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {

        [pscustomobject]@{
            Status = "MISSING"
            File   = $RelativePath
            Error  = "Datei fehlt"
        }

        continue
    }

    try {

        $JsonContent = Get-Content `
            -LiteralPath $FullPath `
            -Raw

        $null = $JsonContent |
            ConvertFrom-Json `
                -ErrorAction Stop

        $Valid = $true
    }
    catch {
        $Message = $_.Exception.Message
    }

    $Status = if ($Valid) {
        "PASS"
    }
    else {
        "INVALID"
    }

    [pscustomobject]@{
        Status = $Status
        File   = $RelativePath
        Error  = $Message
    }
}

$JsonResults |
    Format-Table Status, File, Error -AutoSize

# ============================================================
# 5. JAVASCRIPT DATEI-AUDIT
# ============================================================

Write-Host ""
Write-Host "JAVASCRIPT AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$JavaScriptFiles = @(
    "assets\js\audio-core.js"
    "assets\js\audio-analyzer.js"
    "assets\js\audio-state.js"
    "assets\js\ui.js"
    "assets\worklets\audio-processor.js"
)

$JavaScriptResults = foreach (
    $RelativePath in $JavaScriptFiles
) {

    $FullPath = Join-Path $Root $RelativePath

    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {

        [pscustomobject]@{
            Status = "MISSING"
            Bytes  = 0
            Lines  = 0
            File   = $RelativePath
        }

        continue
    }

    $Item = Get-Item -LiteralPath $FullPath

    $Content = Get-Content `
        -LiteralPath $FullPath `
        -Raw

    $Lines = @(
        Get-Content -LiteralPath $FullPath
    ).Count

    $HasContent = -not [System.String]::IsNullOrWhiteSpace(
        $Content
    )

    $Valid = (
        $Item.Length -gt 0 -and
        $HasContent
    )

    $Status = if ($Valid) {
        "PASS"
    }
    else {
        "INVALID"
    }

    [pscustomobject]@{
        Status = $Status
        Bytes  = $Item.Length
        Lines  = $Lines
        File   = $RelativePath
    }
}

$JavaScriptResults |
    Format-Table Status, Bytes, Lines, File -AutoSize

# ============================================================
# 6. NODE.JS SYNTAX AUDIT
# ============================================================

Write-Host ""
Write-Host "NODE.JS SYNTAX AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$NodeCommand = Get-Command node `
    -ErrorAction SilentlyContinue

$NodeResults = @()

if ($null -eq $NodeCommand) {

    Write-Host `
        "[SKIP] Node.js wurde nicht gefunden." `
        -ForegroundColor Yellow
}

if ($null -ne $NodeCommand) {

    $NodeResults = foreach (
        $RelativePath in $JavaScriptFiles
    ) {

        $FullPath = Join-Path $Root $RelativePath

        if (-not (
            Test-Path `
                -LiteralPath $FullPath `
                -PathType Leaf
        )) {

            [pscustomobject]@{
                Status = "MISSING"
                File   = $RelativePath
            }

            continue
        }

        & node --check $FullPath 2>$null

        $ExitCode = $LASTEXITCODE

        $Status = if ($ExitCode -eq 0) {
            "PASS"
        }
        else {
            "INVALID"
        }

        [pscustomobject]@{
            Status = $Status
            File   = $RelativePath
        }
    }

    $NodeResults |
        Format-Table Status, File -AutoSize
}

# ============================================================
# 7. CSS AUDIT
# ============================================================

Write-Host ""
Write-Host "CSS AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$CssPath = Join-Path $Root "assets\css\audio.css"

$CssStatus = "MISSING"
$CssBytes = 0

if (Test-Path -LiteralPath $CssPath -PathType Leaf) {

    $CssItem = Get-Item -LiteralPath $CssPath

    $CssContent = Get-Content `
        -LiteralPath $CssPath `
        -Raw

    $CssBytes = $CssItem.Length

    $CssHasContent =
        -not [System.String]::IsNullOrWhiteSpace(
            $CssContent
        )

    $CssBracesOpen = (
        [regex]::Matches(
            $CssContent,
            '\{'
        )
    ).Count

    $CssBracesClose = (
        [regex]::Matches(
            $CssContent,
            '\}'
        )
    ).Count

    $CssStatus = if (
        $CssHasContent -and
        $CssBracesOpen -eq $CssBracesClose
    ) {
        "PASS"
    }
    else {
        "INVALID"
    }
}

$CssResult = [pscustomobject]@{
    Status = $CssStatus
    Bytes  = $CssBytes
    File   = "assets\css\audio.css"
}

$CssResult |
    Format-Table Status, Bytes, File -AutoSize

# ============================================================
# 8. AUDIO ROUTEN AUDIT
# ============================================================

Write-Host ""
Write-Host "AUDIO ROUTE AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$Routes = @(
    "/products/audio/"
    "/products/audio/audiostate/"
    "/products/audio/dsp/"
    "/products/audio/orchestration/"
    "/products/audio/validation/"
    "/products/audio/scaling/"
    "/products/audio/diagnostics/"
    "/products/audio/tools/"
    "/products/audio/tools/analyzer/"
    "/products/audio/tools/oscillator/"
    "/products/audio/tools/signal-monitor/"
    "/products/audio/demos/"
    "/products/audio/demos/signal-chain/"
    "/products/audio/demos/audiostate/"
)

$RouteResults = foreach ($Route in $Routes) {

    $RelativeRoute = $Route.Replace(
        "/products/audio/",
        ""
    ).Trim("/")

    if ([System.String]::IsNullOrWhiteSpace($RelativeRoute)) {
        $IndexFile = "$Root\index.html"
    }

    if (-not [System.String]::IsNullOrWhiteSpace($RelativeRoute)) {
        $IndexFile = "$Root\$RelativeRoute\index.html"
    }

    $Exists = Test-Path `
        -LiteralPath $IndexFile `
        -PathType Leaf

    $Status = if ($Exists) {
        "PASS"
    }
    else {
        "404"
    }

    [pscustomobject]@{
        Status = $Status
        Route  = $Route
        File   = $IndexFile
    }
}

$RouteResults |
    Format-Table Status, Route, File -AutoSize

# ============================================================
# 9. BACKUP-ORDNER INFORMATION
# ============================================================

Write-Host ""
Write-Host "LOCAL BACKUPS" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$BackupDirectories = @(
    Get-ChildItem `
        -LiteralPath $Root `
        -Directory `
        -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "_backup_*"
    }
)

if ($BackupDirectories.Count -eq 0) {
    Write-Host "[INFO] Keine lokalen Backup-Ordner gefunden."
}

if ($BackupDirectories.Count -gt 0) {

    $BackupDirectories |
        Select-Object `
            Name,
            LastWriteTime |
        Format-Table -AutoSize

    Write-Host `
        "[INFO] Backup-Ordner nicht für die öffentliche Website erforderlich." `
        -ForegroundColor Yellow
}

# ============================================================
# 10. GESAMTBEWERTUNG
# ============================================================

$Problems = @()

$Problems += @(
    $FileResults |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

$Problems += @(
    $HtmlResults |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

$Problems += @(
    $JsonResults |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

$Problems += @(
    $JavaScriptResults |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

if ($null -ne $NodeCommand) {

    $Problems += @(
        $NodeResults |
        Where-Object {
            $_.Status -ne "PASS"
        }
    )
}

if ($CssResult.Status -ne "PASS") {
    $Problems += $CssResult
}

$Problems += @(
    $RouteResults |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

# ============================================================
# 11. REPORT
# ============================================================

$FinalStatus = if ($Problems.Count -eq 0) {
    "PASS"
}
else {
    "FAIL"
}

$Report = [ordered]@{
    generatedAt = (Get-Date).ToString("o")
    root = $Root
    status = $FinalStatus
    problemCount = $Problems.Count

    audits = [ordered]@{
        files = $FileResults
        html = $HtmlResults
        json = $JsonResults
        javascript = $JavaScriptResults
        node = $NodeResults
        css = $CssResult
        routes = $RouteResults
    }

    backups = @(
        $BackupDirectories |
        Select-Object `
            Name,
            FullName,
            LastWriteTime
    )

    problems = $Problems
}

$Report |
    ConvertTo-Json -Depth 12 |
    Set-Content `
        -LiteralPath $ReportPath `
        -Encoding utf8

# ============================================================
# 12. FINALES ERGEBNIS
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " FINAL RESULT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if ($Problems.Count -eq 0) {

    Write-Host `
        "[PASS] AUDIO PRODUCT AUDIT COMPLETE" `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Erwartete Dateien vorhanden" `
        -ForegroundColor Green

    Write-Host `
        "[PASS] HTML-Grundstruktur gültig" `
        -ForegroundColor Green

    Write-Host `
        "[PASS] JSON-Dateien gültig" `
        -ForegroundColor Green

    Write-Host `
        "[PASS] JavaScript-Dateien vorhanden" `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Audio-Routen vorhanden" `
        -ForegroundColor Green

    Write-Host ""
    Write-Host `
        "[READY] GitHub-Kandidat" `
        -ForegroundColor Green
}

if ($Problems.Count -gt 0) {

    Write-Host `
        "[FAIL] Audit-Probleme: $($Problems.Count)" `
        -ForegroundColor Red

    Write-Host ""

    $Problems |
        Format-Table -AutoSize

    Write-Host ""
    Write-Host `
        "[BLOCKED] Noch nicht für GitHub freigeben." `
        -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Audit-Bericht:"
Write-Host $ReportPath
Write-Host ""

if ($Problems.Count -eq 0) {
    exit 0
}

exit 1