#Requires -Version 7.0

<#
.SYNOPSIS
    Erstellt die CoreCraft Genesis Documentation-Webstruktur.

.DESCRIPTION
    Erstellt sieben Documentation-Unterbereiche,
    gemeinsame Assets und strukturierte Datendateien.

    Die bestehende index.html wird nicht veraendert.

.EXITCODES
    0 = Struktur erfolgreich erstellt und validiert
    1 = Fehler
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\documentation"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$MainIndex = Join-Path $Root "index.html"

$Directories = @(
    "getting-started"
    "architecture"
    "guides"
    "reference"
    "standards"
    "releases"
    "developer"

    "assets"
    "assets\css"
    "assets\js"

    "data"
)

$ExpectedFiles = @(
    "getting-started\index.html"
    "architecture\index.html"
    "guides\index.html"
    "reference\index.html"
    "standards\index.html"
    "releases\index.html"
    "developer\index.html"

    "assets\css\documentation.css"

    "assets\js\documentation.js"
    "assets\js\ui.js"

    "data\sections.json"
    "data\resources.json"
    "data\architecture.json"
)

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DOCUMENTATION - WEB STRUCTURE SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# ROOT VALIDATION
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {

    Write-Host (
        "[FAIL] Documentation-Root fehlt: {0}" -f
        $Root
    ) -ForegroundColor Red

    exit 1
}

Write-Host "[PASS] Documentation-Root vorhanden." -ForegroundColor Green

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
# VERZEICHNISSE
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
# DATEIEN
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
# DIRECTORY VALIDATION
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
# FILE VALIDATION
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
# INVENTUR NACH SETUP
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

$EmptyFiles = @(
    $AllFiles |
    Where-Object Length -eq 0
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
Write-Host " DOCUMENTATION - STRUCTURE SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Directories        : {0}" -f $AllDirectories.Count)
Write-Host ("Files              : {0}" -f $AllFiles.Count)
Write-Host ("HTML               : {0}" -f $HtmlFiles.Count)
Write-Host ("CSS                : {0}" -f $CssFiles.Count)
Write-Host ("JavaScript         : {0}" -f $JsFiles.Count)
Write-Host ("JSON               : {0}" -f $JsonFiles.Count)
Write-Host ("PowerShell         : {0}" -f $PowerShellFiles.Count)
Write-Host ("Empty files        : {0}" -f $EmptyFiles.Count)

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
        "[PASS] DOCUMENTATION STRUCTURE SETUP COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] DOCUMENTATION STRUCTURE SETUP FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1