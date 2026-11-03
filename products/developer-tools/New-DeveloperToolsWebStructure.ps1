#Requires -Version 7.0

<#
.SYNOPSIS
    Erstellt die CoreCraft Genesis Developer-Tools-Webstruktur.

.DESCRIPTION
    Erstellt sieben Unterbereiche, gemeinsame Assets und
    strukturierte JSON-Datendateien.

    Die bestehende index.html wird nicht veraendert.

.EXITCODES
    0 = Struktur erfolgreich erstellt und validiert
    1 = Fehler
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\developer-tools"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$MainIndex = Join-Path $Root "index.html"

$Directories = @(
    "automation"
    "validators"
    "generators"
    "diagnostics"
    "data-tools"
    "web-tools"
    "developer"
    "assets"
    "assets\css"
    "assets\js"
    "data"
)

$ExpectedFiles = @(
    "automation\index.html"
    "validators\index.html"
    "generators\index.html"
    "diagnostics\index.html"
    "data-tools\index.html"
    "web-tools\index.html"
    "developer\index.html"
    "assets\css\developer-tools.css"
    "assets\js\developer-tools.js"
    "assets\js\ui.js"
    "data\capabilities.json"
    "data\tools.json"
    "data\architecture.json"
)

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DEVELOPER TOOLS - WEB STRUCTURE SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# ROOT VALIDIERUNG
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] Developer-Tools-Root fehlt: $Root" -ForegroundColor Red
    exit 1
}

Write-Host "[PASS] Developer-Tools-Root vorhanden." -ForegroundColor Green

# ============================================================
# HAUPTSEITE SCHUETZEN
# ============================================================

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
# VERZEICHNISSE ERSTELLEN
# ============================================================

Write-Host ""
Write-Host "DIRECTORY SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $Directories) {

    $FullPath = Join-Path $Root $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Container) {

        Write-Host (
            "[EXISTS] {0}" -f
            $RelativePath
        ) -ForegroundColor DarkGray
    }
    else {

        New-Item `
            -ItemType Directory `
            -Path $FullPath `
            -Force |
            Out-Null

        Write-Host (
            "[CREATE] {0}" -f
            $RelativePath
        ) -ForegroundColor Green
    }
}

# ============================================================
# DATEIEN ERSTELLEN
# ============================================================

Write-Host ""
Write-Host "FILE SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $Root $RelativePath

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
            "[CREATE] {0}" -f
            $RelativePath
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

    $FullPath = Join-Path $Root $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Container) {

        Write-Host (
            "[PASS] DIR  {0}" -f
            $RelativePath
        ) -ForegroundColor Green
    }
    else {

        Write-Host (
            "[FAIL] DIR  {0}" -f
            $RelativePath
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

    $FullPath = Join-Path $Root $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        Write-Host (
            "[PASS] FILE {0}" -f
            $RelativePath
        ) -ForegroundColor Green
    }
    else {

        Write-Host (
            "[FAIL] FILE {0}" -f
            $RelativePath
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
# INVENTUR
# ============================================================

$AllDirectories = @(
    Get-ChildItem `
        -LiteralPath $Root `
        -Directory `
        -Recurse
)

$AllFiles = @(
    Get-ChildItem `
        -LiteralPath $Root `
        -File `
        -Recurse
)

$HtmlFiles = @(
    $AllFiles |
    Where-Object Extension -eq ".html"
)

$CssFiles = @(
    $AllFiles |
    Where-Object Extension -eq ".css"
)

$JsFiles = @(
    $AllFiles |
    Where-Object Extension -eq ".js"
)

$JsonFiles = @(
    $AllFiles |
    Where-Object Extension -eq ".json"
)

$PowerShellFiles = @(
    $AllFiles |
    Where-Object Extension -eq ".ps1"
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
Write-Host " DEVELOPER TOOLS - STRUCTURE SUMMARY" -ForegroundColor Cyan
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
        "[PASS] DEVELOPER TOOLS STRUCTURE SETUP COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] DEVELOPER TOOLS STRUCTURE SETUP FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1