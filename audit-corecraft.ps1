<#
    EngineCore Genesis Audit Script
    Vollständige Strukturprüfung aller Genesis-Schichten
    Version: 2026-09-20
#>

Write-Host "[EngineCore][AUDIT] Starte Genesis-Audit..." -ForegroundColor Cyan

$Base = "C:\corecraftgenesis.ch"

# Erwartete Genesis-Schichten
$ExpectedFolders = @(
    "auditchain",
    "commodity-matrix",
    "mainchain",
    "hyperspace-ledger",
    "hyperspace-governance",
    "hyperspace-runtime",
    "hyperspace-dsp",
    "genesis-operational-layer",
    "genesis-documentation",
    "hyperspace-portal"
)

# Pflichtdateien
$RequiredFiles = @(
    "header.html",
    "super-nav.html",
    "portal.css",
    "index.html"
)

# Audit-Report
$Report = @()

# --- Ordnerprüfung ---
Write-Host "[EngineCore][AUDIT] Prüfe Ordnerstruktur..." -ForegroundColor Yellow

foreach ($Folder in $ExpectedFolders) {
    $Path = Join-Path $Base $Folder

    if (Test-Path $Path) {
        $Report += "[OK] Ordner vorhanden: $Folder"
    } else {
        $Report += "[FEHLT] Ordner fehlt: $Folder"
    }
}

# --- Datei-Prüfung ---
Write-Host "[EngineCore][AUDIT] Prüfe globale Dateien..." -ForegroundColor Yellow

foreach ($File in $RequiredFiles) {
    $FilePath = Join-Path $Base $File

    if (Test-Path $FilePath) {
        $Report += "[OK] Datei vorhanden: $File"
    } else {
        $Report += "[FEHLT] Datei fehlt: $File"
    }
}

# --- HTML-Indexprüfung ---
Write-Host "[EngineCore][AUDIT] Prüfe HTML-Indexseiten..." -ForegroundColor Yellow

foreach ($Folder in $ExpectedFolders) {
    $IndexPath = Join-Path (Join-Path $Base $Folder) "index.html"

    if (Test-Path $IndexPath) {
        $Report += "[OK] index.html vorhanden in: $Folder"
    } else {
        $Report += "[FEHLT] index.html fehlt in: $Folder"
    }
}

# --- Navigation prüfen ---
Write-Host "[EngineCore][AUDIT] Prüfe Navigation (super-nav.html)..." -ForegroundColor Yellow

$NavPath = Join-Path $Base "super-nav.html"
$NavContent = ""

if (Test-Path $NavPath) {
    $NavContent = Get-Content $NavPath -Raw

    foreach ($Folder in $ExpectedFolders) {
        if ($NavContent -match $Folder) {
            $Report += "[OK] Navigation enthält Link: $Folder"
        } else {
            $Report += "[WARNUNG] Navigation enthält KEINEN Link: $Folder"
        }
    }
} else {
    $Report += "[FEHLT] super-nav.html nicht gefunden – Navigation kann nicht geprüft werden."
}

# --- Audit-Report ausgeben ---
Write-Host "`n[EngineCore][AUDIT] --- Audit Report ---" -ForegroundColor Cyan

foreach ($Line in $Report) {
    if ($Line -match "OK") {
        Write-Host $Line -ForegroundColor Green
    } elseif ($Line -match "WARNUNG") {
        Write-Host $Line -ForegroundColor Yellow
    } else {
        Write-Host $Line -ForegroundColor Red
    }
}

Write-Host "`n[EngineCore][AUDIT] Audit abgeschlossen." -ForegroundColor Cyan
