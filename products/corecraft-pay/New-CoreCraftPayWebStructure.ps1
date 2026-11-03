#Requires -Version 7.0

<#
.SYNOPSIS
    Erstellt die CoreCraft-Pay-Webstruktur.

.DESCRIPTION
    Legt die vorgesehenen Unterseiten, Asset-Ordner und
    Datendateien fuer CoreCraft Pay an.

    Die bestehende Hauptseite index.html wird nicht
    ueberschrieben oder veraendert.

.EXITCODES
    0 = Struktur erfolgreich erstellt und validiert
    1 = Validierungsfehler
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$PayRoot = "C:\corecraftgenesis-github\products\corecraft-pay"

$Directories = @(
    "architecture"
    "payments"
    "checkout"
    "integrations"
    "security"
    "developer"
    "demos"

    "assets"
    "assets\css"
    "assets\js"

    "data"
)

$ExpectedFiles = @(
    "architecture\index.html"
    "payments\index.html"
    "checkout\index.html"
    "integrations\index.html"
    "security\index.html"
    "developer\index.html"
    "demos\index.html"

    "assets\css\corecraft-pay.css"

    "assets\js\corecraft-pay.js"
    "assets\js\ui.js"

    "data\capabilities.json"
    "data\integrations.json"
    "data\architecture.json"
)

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT PAY - WEB STRUCTURE SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# ROOT VALIDIEREN
# ============================================================

if (-not (Test-Path -LiteralPath $PayRoot -PathType Container)) {

    Write-Host (
        "[FAIL] CoreCraft-Pay-Root nicht gefunden: {0}" -f
        $PayRoot
    ) -ForegroundColor Red

    exit 1
}

Write-Host "[PASS] CoreCraft-Pay-Root vorhanden." -ForegroundColor Green

# ============================================================
# HAUPTSEITE SCHUETZEN
# ============================================================

$MainIndex = Join-Path $PayRoot "index.html"

$MainIndexExists = Test-Path `
    -LiteralPath $MainIndex `
    -PathType Leaf

if ($MainIndexExists) {

    $MainIndexFile = Get-Item -LiteralPath $MainIndex

    $MainHashBefore = (
        Get-FileHash `
            -LiteralPath $MainIndex `
            -Algorithm SHA256
    ).Hash

    Write-Host (
        "[PASS] Bestehende index.html erkannt ({0} Bytes)." -f
        $MainIndexFile.Length
    ) -ForegroundColor Green

    Write-Host (
        "[INFO] Bestehende Hauptseite wird nicht veraendert."
    ) -ForegroundColor Cyan
}
else {

    $MainHashBefore = $null

    Write-Host (
        "[FAIL] CoreCraft-Pay-Hauptseite fehlt."
    ) -ForegroundColor Red

    exit 1
}

# ============================================================
# VERZEICHNISSE ANLEGEN
# ============================================================

Write-Host ""
Write-Host "DIRECTORY SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $Directories) {

    $FullPath = Join-Path $PayRoot $RelativePath

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
# STARTDATEIEN ANLEGEN
# ============================================================

Write-Host ""
Write-Host "FILE SETUP" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $PayRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $ExistingFile = Get-Item -LiteralPath $FullPath

        Write-Host (
            "[EXISTS] {0} ({1} Bytes)" -f
            $RelativePath,
            $ExistingFile.Length
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

    $FullPath = Join-Path $PayRoot $RelativePath

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

    $FullPath = Join-Path $PayRoot $RelativePath

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
# HAUPTSEITE ERNEUT PRUEFEN
# ============================================================

Write-Host ""
Write-Host "MAIN PAGE PROTECTION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$MainIndexProtected = $false

if (Test-Path -LiteralPath $MainIndex -PathType Leaf) {

    $MainHashAfter = (
        Get-FileHash `
            -LiteralPath $MainIndex `
            -Algorithm SHA256
    ).Hash

    $MainIndexProtected = (
        $MainHashBefore -eq $MainHashAfter
    )
}

if ($MainIndexProtected) {

    $MainIndexLength = (
        Get-Item -LiteralPath $MainIndex
    ).Length

    Write-Host (
        "[PASS] Hauptseite unveraendert ({0} Bytes)." -f
        $MainIndexLength
    ) -ForegroundColor Green
}
else {

    Write-Host (
        "[FAIL] Hauptseite wurde veraendert."
    ) -ForegroundColor Red
}

# ============================================================
# INVENTUR
# ============================================================

$AllDirectories = @(
    Get-ChildItem `
        -LiteralPath $PayRoot `
        -Directory `
        -Recurse
)

$AllFiles = @(
    Get-ChildItem `
        -LiteralPath $PayRoot `
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
# FINAL SUMMARY
# ============================================================

$TotalFailures = (
    $DirectoryFailures.Count +
    $FileFailures.Count
)

if (-not $MainIndexProtected) {
    $TotalFailures++
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT PAY - STRUCTURE SUMMARY" -ForegroundColor Cyan
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
    $MainIndexProtected
)

Write-Host (
    "Total failures     : {0}" -f
    $TotalFailures
)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host (
        "[PASS] CORECRAFT PAY STRUCTURE SETUP COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] CORECRAFT PAY STRUCTURE SETUP FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1