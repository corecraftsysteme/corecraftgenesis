#Requires -Version 7.0

<#
.SYNOPSIS
    Erstellt die CoreCraft Genesis Bitcoin-Mining-Webstruktur.

.DESCRIPTION
    Legt sieben Produktbereiche, gemeinsame Assets und
    strukturierte Datendateien an.

    Die bestehende index.html wird nicht veraendert.

.EXITCODES
    0 = Struktur erfolgreich erstellt und validiert
    1 = Fehler
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$MiningRoot = "C:\corecraftgenesis-github\products\bitcoin-mining"

$Directories = @(
    "architecture"
    "hardware"
    "operations"
    "energy"
    "monitoring"
    "economics"
    "developer"

    "assets"
    "assets\css"
    "assets\js"

    "data"
)

$ExpectedFiles = @(
    "architecture\index.html"
    "hardware\index.html"
    "operations\index.html"
    "energy\index.html"
    "monitoring\index.html"
    "economics\index.html"
    "developer\index.html"

    "assets\css\bitcoin-mining.css"

    "assets\js\bitcoin-mining.js"
    "assets\js\ui.js"

    "data\capabilities.json"
    "data\architecture.json"
    "data\metrics.json"
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BITCOIN MINING - WEB STRUCTURE SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# ROOT
# ============================================================

if (-not (Test-Path -LiteralPath $MiningRoot -PathType Container)) {
    Write-Host "[FAIL] Bitcoin-Mining-Root fehlt: $MiningRoot" -ForegroundColor Red
    exit 1
}

Write-Host "[PASS] Bitcoin-Mining-Root vorhanden." -ForegroundColor Green

# ============================================================
# HAUPTSEITE SCHUETZEN
# ============================================================

$MainIndex = Join-Path $MiningRoot "index.html"

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    Write-Host "[FAIL] Bestehende index.html fehlt." -ForegroundColor Red
    exit 1
}

$MainFile = Get-Item -LiteralPath $MainIndex

$MainHashBefore = (
    Get-FileHash `
        -LiteralPath $MainIndex `
        -Algorithm SHA256
).Hash

Write-Host (
    "[PASS] Bestehende index.html erkannt ({0} Bytes)." -f
    $MainFile.Length
) -ForegroundColor Green

Write-Host "[INFO] Hauptseite wird nicht veraendert." -ForegroundColor Cyan

# ============================================================
# VERZEICHNISSE
# ============================================================

Write-Host ""
Write-Host "DIRECTORY SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $Directories) {

    $FullPath = Join-Path $MiningRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Container) {

        Write-Host (
            "[EXISTS] {0}" -f $RelativePath
        ) -ForegroundColor DarkGray
    }
    else {

        New-Item `
            -ItemType Directory `
            -Path $FullPath `
            -Force |
            Out-Null

        Write-Host (
            "[CREATE] {0}" -f $RelativePath
        ) -ForegroundColor Green
    }
}

# ============================================================
# DATEIEN
# ============================================================

Write-Host ""
Write-Host "FILE SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $MiningRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $File = Get-Item -LiteralPath $FullPath

        Write-Host (
            "[EXISTS] {0} ({1} Bytes)" -f
            $RelativePath,
            $File.Length
        ) -ForegroundColor DarkGray
    }
    else {

        New-Item `
            -ItemType File `
            -Path $FullPath |
            Out-Null

        Write-Host (
            "[CREATE] {0}" -f $RelativePath
        ) -ForegroundColor Green
    }
}

# ============================================================
# VERZEICHNISVALIDIERUNG
# ============================================================

Write-Host ""
Write-Host "DIRECTORY VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$DirectoryFailures = @()

foreach ($RelativePath in $Directories) {

    $FullPath = Join-Path $MiningRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Container) {

        Write-Host (
            "[PASS] DIR  {0}" -f $RelativePath
        ) -ForegroundColor Green
    }
    else {

        Write-Host (
            "[FAIL] DIR  {0}" -f $RelativePath
        ) -ForegroundColor Red

        $DirectoryFailures += $RelativePath
    }
}

# ============================================================
# DATEIVALIDIERUNG
# ============================================================

Write-Host ""
Write-Host "FILE VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$FileFailures = @()

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $MiningRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        Write-Host (
            "[PASS] FILE {0}" -f $RelativePath
        ) -ForegroundColor Green
    }
    else {

        Write-Host (
            "[FAIL] FILE {0}" -f $RelativePath
        ) -ForegroundColor Red

        $FileFailures += $RelativePath
    }
}

# ============================================================
# HAUPTSEITENSCHUTZ
# ============================================================

Write-Host ""
Write-Host "MAIN PAGE PROTECTION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$MainHashAfter = (
    Get-FileHash `
        -LiteralPath $MainIndex `
        -Algorithm SHA256
).Hash

$MainProtected = (
    $MainHashBefore -eq $MainHashAfter
)

if ($MainProtected) {

    Write-Host (
        "[PASS] Hauptseite unveraendert ({0} Bytes)." -f
        (Get-Item -LiteralPath $MainIndex).Length
    ) -ForegroundColor Green
}
else {

    Write-Host "[FAIL] Hauptseite wurde veraendert." -ForegroundColor Red
}

# ============================================================
# INVENTUR NACH ERSTELLUNG
# ============================================================

$AllDirectories = @(
    Get-ChildItem `
        -LiteralPath $MiningRoot `
        -Directory `
        -Recurse
)

$AllFiles = @(
    Get-ChildItem `
        -LiteralPath $MiningRoot `
        -File `
        -Recurse
)

$HtmlFiles = @(
    $AllFiles |
    Where-Object {
        $_.Extension -eq ".html"
    }
)

$CssFiles = @(
    $AllFiles |
    Where-Object {
        $_.Extension -eq ".css"
    }
)

$JsFiles = @(
    $AllFiles |
    Where-Object {
        $_.Extension -eq ".js"
    }
)

$JsonFiles = @(
    $AllFiles |
    Where-Object {
        $_.Extension -eq ".json"
    }
)

$PowerShellFiles = @(
    $AllFiles |
    Where-Object {
        $_.Extension -eq ".ps1"
    }
)

# ============================================================
# SUMMARY
# ============================================================

$TotalFailures = (
    $DirectoryFailures.Count +
    $FileFailures.Count
)

if (-not $MainProtected) {
    $TotalFailures++
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BITCOIN MINING - STRUCTURE SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Directories        : {0}" -f $AllDirectories.Count)
Write-Host ("Files              : {0}" -f $AllFiles.Count)
Write-Host ("HTML               : {0}" -f $HtmlFiles.Count)
Write-Host ("CSS                : {0}" -f $CssFiles.Count)
Write-Host ("JavaScript         : {0}" -f $JsFiles.Count)
Write-Host ("JSON               : {0}" -f $JsonFiles.Count)
Write-Host ("PowerShell         : {0}" -f $PowerShellFiles.Count)

Write-Host (
    "Missing directories: {0}" -f
    $DirectoryFailures.Count
)

Write-Host (
    "Missing files      : {0}" -f
    $FileFailures.Count
)

Write-Host (
    "Main protected     : {0}" -f
    $MainProtected
)

Write-Host (
    "Total failures     : {0}" -f
    $TotalFailures
)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host (
        "[PASS] BITCOIN MINING STRUCTURE SETUP COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] BITCOIN MINING STRUCTURE SETUP FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1