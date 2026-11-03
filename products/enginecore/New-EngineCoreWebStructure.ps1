#Requires -Version 7.0

<#
.SYNOPSIS
    Erstellt die CoreCraft Genesis EngineCore-Webstruktur.

.DESCRIPTION
    Legt die benoetigten EngineCore-Verzeichnisse an.

    WICHTIG:
    - Bestehende Dateien werden NICHT ueberschrieben.
    - Die vorhandene index.html bleibt unveraendert.
    - Fehlende Startdateien werden als leere Dateien angelegt.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$EngineCoreRoot = "C:\corecraftgenesis-github\products\enginecore"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - ENGINECORE STRUCTURE SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# ROOT PRUEFEN
# ============================================================

if (-not (Test-Path -LiteralPath $EngineCoreRoot -PathType Container)) {
    throw "EngineCore-Root nicht gefunden: $EngineCoreRoot"
}

Write-Host "[PASS] EngineCore-Root vorhanden." -ForegroundColor Green

$MainIndex = Join-Path $EngineCoreRoot "index.html"

if (Test-Path -LiteralPath $MainIndex -PathType Leaf) {

    $MainIndexFile = Get-Item -LiteralPath $MainIndex

    Write-Host (
        "[PASS] Bestehende index.html erkannt ({0} Bytes)." -f
        $MainIndexFile.Length
    ) -ForegroundColor Green

    Write-Host "[INFO] Die bestehende index.html wird nicht veraendert." -ForegroundColor Cyan
}
else {
    Write-Host "[WARN] Keine bestehende EngineCore-index.html gefunden." -ForegroundColor Yellow
}

# ============================================================
# VERZEICHNISSTRUKTUR
# ============================================================

$Directories = @(
    "architecture"
    "runtime"
    "modules"
    "validation"
    "diagnostics"
    "developer"
    "demos"

    "assets"
    "assets\css"
    "assets\js"

    "data"
)

Write-Host ""
Write-Host "DIRECTORY SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $Directories) {

    $FullPath = Join-Path $EngineCoreRoot $RelativePath

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
# ERWARTETE DATEIEN
# ============================================================

$ExpectedFiles = @(
    "architecture\index.html"
    "runtime\index.html"
    "modules\index.html"
    "validation\index.html"
    "diagnostics\index.html"
    "developer\index.html"
    "demos\index.html"

    "assets\css\enginecore.css"

    "assets\js\enginecore.js"
    "assets\js\ui.js"

    "data\modules.json"
    "data\capabilities.json"
    "data\architecture.json"
)

Write-Host ""
Write-Host "FILE SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $EngineCoreRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $File = Get-Item -LiteralPath $FullPath

        Write-Host (
            "[EXISTS] {0} ({1} bytes)" -f
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
# VALIDIERUNG
# ============================================================

Write-Host ""
Write-Host "STRUCTURE VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$DirectoryFailures = @()

foreach ($RelativePath in $Directories) {

    $FullPath = Join-Path $EngineCoreRoot $RelativePath

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

$FileFailures = @()

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $EngineCoreRoot $RelativePath

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
# INVENTUR
# ============================================================

$AllDirectories = @(
    Get-ChildItem `
        -LiteralPath $EngineCoreRoot `
        -Directory `
        -Recurse
)

$AllFiles = @(
    Get-ChildItem `
        -LiteralPath $EngineCoreRoot `
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

# ============================================================
# FINAL SUMMARY
# ============================================================

$TotalFailures = (
    $DirectoryFailures.Count +
    $FileFailures.Count
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ENGINECORE STRUCTURE SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Directories        : {0}" -f $AllDirectories.Count)
Write-Host ("Files              : {0}" -f $AllFiles.Count)
Write-Host ("HTML               : {0}" -f $HtmlFiles.Count)
Write-Host ("CSS                : {0}" -f $CssFiles.Count)
Write-Host ("JavaScript         : {0}" -f $JsFiles.Count)
Write-Host ("JSON               : {0}" -f $JsonFiles.Count)
Write-Host ("Missing directories: {0}" -f $DirectoryFailures.Count)
Write-Host ("Missing files      : {0}" -f $FileFailures.Count)
Write-Host ("Total failures     : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host "[PASS] ENGINECORE STRUCTURE SETUP COMPLETE" -ForegroundColor Green
    Write-Host "============================================================"

    exit 0
}

Write-Host "[FAIL] ENGINECORE STRUCTURE SETUP FAILED" -ForegroundColor Red
Write-Host "============================================================"

exit 1