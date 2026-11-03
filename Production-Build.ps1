#Requires -Version 7.0

<#
.SYNOPSIS
    Produktionspruefung fuer CoreCraft Genesis.

.DESCRIPTION
    Fuehrt vor einer Veroeffentlichung zentrale Kontrollen aus:

    - Repository und Git pruefen
    - aktuellen Commit erfassen
    - Working Tree pruefen
    - HTML-Dateien inventarisieren
    - leere HTML-Dateien erkennen
    - JSON-Dateien validieren
    - Final-SiteLinkAudit.ps1 ausfuehren
    - finales Production-Build-Ergebnis ausgeben

    Das Skript veraendert keine Website-Dateien.

.EXITCODES
    0 = Production Build PASS
    1 = Production Build FAIL
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$SiteAudit = Join-Path $Root "Final-SiteLinkAudit.ps1"

$Failures = [System.Collections.Generic.List[string]]::new()

# ============================================================
# HELPER
# ============================================================

function Write-Section {

    param(
        [Parameter(Mandatory)]
        [string]$Title
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------"
}

function Add-BuildFailure {

    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $script:Failures.Add($Message)

    Write-Host (
        "[FAIL] {0}" -f $Message
    ) -ForegroundColor Red
}

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - PRODUCTION BUILD" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# ROOT VALIDATION
# ============================================================

Write-Section "ROOT VALIDATION"

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {

    Write-Host (
        "[FAIL] Repository-Root fehlt: {0}" -f
        $Root
    ) -ForegroundColor Red

    exit 1
}

Write-Host "[PASS] Repository-Root vorhanden." -ForegroundColor Green

Set-Location -LiteralPath $Root

# ============================================================
# GIT VALIDATION
# ============================================================

Write-Section "GIT VALIDATION"

$GitDirectory = Join-Path $Root ".git"

if (-not (Test-Path -LiteralPath $GitDirectory -PathType Container)) {

    Add-BuildFailure "Kein Git-Repository gefunden."

    $GitBranch = "UNKNOWN"
    $GitCommit = "UNKNOWN"
    $GitStatus = @()
}
else {

    Write-Host "[PASS] Git-Repository erkannt." -ForegroundColor Green

    try {

        $GitBranch = (
            git branch --show-current
        ).Trim()

        if ([string]::IsNullOrWhiteSpace($GitBranch)) {
            $GitBranch = "UNKNOWN"
        }

        Write-Host (
            "[PASS] Branch: {0}" -f
            $GitBranch
        ) -ForegroundColor Green
    }
    catch {

        $GitBranch = "UNKNOWN"

        Add-BuildFailure "Git-Branch konnte nicht ermittelt werden."
    }

    try {

        $GitCommit = (
            git rev-parse --short HEAD
        ).Trim()

        Write-Host (
            "[PASS] Commit: {0}" -f
            $GitCommit
        ) -ForegroundColor Green
    }
    catch {

        $GitCommit = "UNKNOWN"

        Add-BuildFailure "Git-Commit konnte nicht ermittelt werden."
    }

    try {

        $GitStatus = @(
            git status --porcelain
        )

        if ($GitStatus.Count -eq 0) {

            Write-Host (
                "[PASS] Working Tree clean."
            ) -ForegroundColor Green
        }
        else {

            Add-BuildFailure (
                "Working Tree enthaelt nicht versionierte oder geaenderte Dateien."
            )

            Write-Host ""

            $GitStatus |
                ForEach-Object {
                    Write-Host "       $_" -ForegroundColor Yellow
                }
        }
    }
    catch {

        $GitStatus = @()

        Add-BuildFailure "Git-Status konnte nicht ermittelt werden."
    }
}

# ============================================================
# HTML VALIDATION
# ============================================================

Write-Section "HTML VALIDATION"

$HtmlFiles = @(
    Get-ChildItem `
        -LiteralPath $Root `
        -Filter "*.html" `
        -File `
        -Recurse `
        -ErrorAction Stop
)

$EmptyHtmlFiles = @(
    $HtmlFiles |
        Where-Object {
            $_.Length -eq 0
        }
)

Write-Host (
    "HTML pages : {0}" -f
    $HtmlFiles.Count
)

if ($HtmlFiles.Count -eq 0) {

    Add-BuildFailure "Keine HTML-Dateien gefunden."
}
elseif ($EmptyHtmlFiles.Count -eq 0) {

    Write-Host (
        "[PASS] Keine leeren HTML-Dateien."
    ) -ForegroundColor Green
}
else {

    Add-BuildFailure (
        "{0} leere HTML-Datei(en) gefunden." -f
        $EmptyHtmlFiles.Count
    )

    foreach ($File in $EmptyHtmlFiles) {

        $RelativePath = [System.IO.Path]::GetRelativePath(
            $Root,
            $File.FullName
        )

        Write-Host (
            "       {0}" -f
            $RelativePath
        ) -ForegroundColor Yellow
    }
}

# ============================================================
# JSON VALIDATION
# ============================================================

Write-Section "JSON VALIDATION"

$JsonFiles = @(
    Get-ChildItem `
        -LiteralPath $Root `
        -Filter "*.json" `
        -File `
        -Recurse `
        -ErrorAction Stop
)

$JsonFailures = [System.Collections.Generic.List[string]]::new()

Write-Host (
    "JSON files : {0}" -f
    $JsonFiles.Count
)

foreach ($JsonFile in $JsonFiles) {

    try {

        $RawJson = Get-Content `
            -LiteralPath $JsonFile.FullName `
            -Raw `
            -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($RawJson)) {
            throw "Datei ist leer."
        }

        $null = $RawJson |
            ConvertFrom-Json `
                -ErrorAction Stop

        $RelativePath = [System.IO.Path]::GetRelativePath(
            $Root,
            $JsonFile.FullName
        )

        Write-Host (
            "[PASS] {0}" -f
            $RelativePath
        ) -ForegroundColor Green
    }
    catch {

        $RelativePath = [System.IO.Path]::GetRelativePath(
            $Root,
            $JsonFile.FullName
        )

        $JsonFailures.Add($RelativePath)

        Write-Host (
            "[FAIL] {0}: {1}" -f
            $RelativePath,
            $_.Exception.Message
        ) -ForegroundColor Red
    }
}

if ($JsonFailures.Count -gt 0) {

    $Failures.Add(
        "{0} JSON-Datei(en) fehlgeschlagen." -f
        $JsonFailures.Count
    )
}

# ============================================================
# SITE LINK AUDIT
# ============================================================

Write-Section "SITE LINK AUDIT"

$SiteAuditPassed = $false
$SiteAuditExitCode = 1

if (-not (Test-Path -LiteralPath $SiteAudit -PathType Leaf)) {

    Add-BuildFailure (
        "Final-SiteLinkAudit.ps1 fehlt."
    )
}
else {

    Write-Host (
        "[INFO] Starte Final-SiteLinkAudit.ps1"
    ) -ForegroundColor Cyan

    try {

        & $SiteAudit

        $SiteAuditExitCode = $LASTEXITCODE

        if ($SiteAuditExitCode -eq 0) {

            $SiteAuditPassed = $true

            Write-Host ""
            Write-Host (
                "[PASS] Site Link Audit bestanden."
            ) -ForegroundColor Green
        }
        else {

            Add-BuildFailure (
                "Site Link Audit meldete Exit-Code {0}." -f
                $SiteAuditExitCode
            )
        }
    }
    catch {

        Add-BuildFailure (
            "Site Link Audit konnte nicht erfolgreich ausgefuehrt werden: {0}" -f
            $_.Exception.Message
        )
    }
}

# ============================================================
# BUILD SUMMARY
# ============================================================

$ProductionReady = (
    $Failures.Count -eq 0
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " PRODUCTION BUILD SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host (
    "Repository        : {0}" -f
    $Root
)

Write-Host (
    "Git branch        : {0}" -f
    $GitBranch
)

Write-Host (
    "Git commit        : {0}" -f
    $GitCommit
)

Write-Host (
    "Working tree clean: {0}" -f
    ($GitStatus.Count -eq 0)
)

Write-Host (
    "HTML pages        : {0}" -f
    $HtmlFiles.Count
)

Write-Host (
    "Empty HTML        : {0}" -f
    $EmptyHtmlFiles.Count
)

Write-Host (
    "JSON files        : {0}" -f
    $JsonFiles.Count
)

Write-Host (
    "JSON failures     : {0}" -f
    $JsonFailures.Count
)

Write-Host (
    "Site audit PASS   : {0}" -f
    $SiteAuditPassed
)

Write-Host (
    "Build failures    : {0}" -f
    $Failures.Count
)

Write-Host (
    "Production ready  : {0}" -f
    $ProductionReady
)

# ============================================================
# FEHLERDETAILS
# ============================================================

if ($Failures.Count -gt 0) {

    Write-Host ""
    Write-Host "BUILD FAILURES" -ForegroundColor Red
    Write-Host "------------------------------------------------------------"

    foreach ($Failure in $Failures) {
        Write-Host (
            "[FAIL] {0}" -f
            $Failure
        ) -ForegroundColor Red
    }
}

# ============================================================
# FINAL RESULT
# ============================================================

Write-Host ""
Write-Host "============================================================"

if ($ProductionReady) {

    Write-Host (
        "[PASS] PRODUCTION BUILD READY FOR DEPLOYMENT"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] PRODUCTION BUILD NOT READY"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1