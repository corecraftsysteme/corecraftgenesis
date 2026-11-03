#Requires -Version 7.0

<#
.SYNOPSIS
    Finaler Asset-Audit fuer CoreCraft Genesis Audio.

.DESCRIPTION
    Prueft:
    - Repository- und Audio-Root
    - erwartete Kern-Assets
    - leere Asset-Dateien
    - JSON-Syntax
    - lokale Asset-Referenzen in HTML-Dateien
    - CSS-, JavaScript-, JSON-, Audio- und Bildreferenzen

    Das Skript veraendert keine Projektdateien.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$RepositoryRoot = "C:\corecraftgenesis-github"
$AudioRoot = Join-Path $RepositoryRoot "products\audio"

$ExpectedAssets = @(
    "assets\css\audio.css"
    "assets\js\audio-core.js"
    "assets\js\audio-analyzer.js"
    "assets\js\audio-state.js"
    "assets\js\ui.js"
    "assets\worklets\audio-processor.js"
    "data\capabilities.json"
    "data\modules.json"
    "data\tools.json"
)

$AssetExtensions = @(
    ".css"
    ".js"
    ".json"
    ".wav"
    ".mp3"
    ".ogg"
    ".flac"
    ".webm"
    ".png"
    ".jpg"
    ".jpeg"
    ".svg"
    ".webp"
)

# ============================================================
# HILFSFUNKTIONEN
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

function Write-AuditResult {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("PASS", "FAIL", "INFO")]
        [string]$Status,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = switch ($Status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "INFO" { "Cyan" }
    }

    Write-Host "[$Status] $Message" -ForegroundColor $Color
}

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - FINAL AUDIO ASSET AUDIT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. ROOT VALIDATION
# ============================================================

Write-Section "ROOT VALIDATION"

if (-not (Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
    Write-AuditResult "FAIL" "Repository nicht gefunden: $RepositoryRoot"
    exit 1
}

Write-AuditResult "PASS" "Repository-Root vorhanden."

if (-not (Test-Path -LiteralPath $AudioRoot -PathType Container)) {
    Write-AuditResult "FAIL" "Audio-Root nicht gefunden: $AudioRoot"
    exit 1
}

Write-AuditResult "PASS" "Audio-Root vorhanden."

# ============================================================
# 2. EXPECTED CORE ASSETS
# ============================================================

Write-Section "EXPECTED CORE ASSETS"

$ExpectedResults = @()

foreach ($RelativePath in $ExpectedAssets) {

    $FullPath = Join-Path $AudioRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $File = Get-Item -LiteralPath $FullPath

        if ($File.Length -gt 0) {
            $Status = "PASS"
            $Message = "Datei vorhanden"
        }
        else {
            $Status = "FAIL"
            $Message = "Datei ist leer"
        }

        $ExpectedResults += [pscustomobject]@{
            Status = $Status
            Asset = $RelativePath
            Bytes = $File.Length
            Message = $Message
            Path = $FullPath
        }
    }
    else {

        $ExpectedResults += [pscustomobject]@{
            Status = "FAIL"
            Asset = $RelativePath
            Bytes = 0
            Message = "Datei fehlt"
            Path = $FullPath
        }
    }
}

foreach ($Result in $ExpectedResults) {

    $Color = if ($Result.Status -eq "PASS") {
        "Green"
    }
    else {
        "Red"
    }

    Write-Host (
        "[{0}] {1,-42} {2,8} bytes - {3}" -f
        $Result.Status,
        $Result.Asset,
        $Result.Bytes,
        $Result.Message
    ) -ForegroundColor $Color
}

# ============================================================
# 3. ASSET INVENTORY
# ============================================================

Write-Section "ASSET INVENTORY"

$AssetFiles = @(
    Get-ChildItem `
        -LiteralPath $AudioRoot `
        -File `
        -Recurse `
        -ErrorAction Stop |
    Where-Object {
        $_.Extension.ToLowerInvariant() -in $AssetExtensions
    }
)

$EmptyAssets = @(
    $AssetFiles |
    Where-Object {
        $_.Length -eq 0
    }
)

Write-Host ("Asset files found : {0}" -f $AssetFiles.Count)

if ($EmptyAssets.Count -eq 0) {
    Write-AuditResult "PASS" "Keine leeren Asset-Dateien."
}
else {

    Write-AuditResult "FAIL" (
        "{0} leere Asset-Datei(en) gefunden." -f $EmptyAssets.Count
    )

    $EmptyAssets |
        Select-Object FullName, Length |
        Format-Table -AutoSize
}

# ============================================================
# 4. JSON VALIDATION
# ============================================================

Write-Section "JSON VALIDATION"

$JsonFiles = @(
    Get-ChildItem `
        -LiteralPath $AudioRoot `
        -Filter "*.json" `
        -File `
        -Recurse `
        -ErrorAction Stop
)

$JsonResults = @()

foreach ($JsonFile in $JsonFiles) {

    try {

        $RawJson = Get-Content `
            -LiteralPath $JsonFile.FullName `
            -Raw `
            -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($RawJson)) {
            throw "JSON-Datei ist leer."
        }

        $null = $RawJson |
            ConvertFrom-Json -ErrorAction Stop

        $JsonResults += [pscustomobject]@{
            Status = "PASS"
            File = $JsonFile.FullName.Substring(
                $AudioRoot.Length
            ).TrimStart("\")
            Message = "Gueltiges JSON"
        }
    }
    catch {

        $JsonResults += [pscustomobject]@{
            Status = "FAIL"
            File = $JsonFile.FullName.Substring(
                $AudioRoot.Length
            ).TrimStart("\")
            Message = $_.Exception.Message
        }
    }
}

foreach ($Result in $JsonResults) {

    if ($Result.Status -eq "PASS") {
    Write-AuditResult "PASS" (
            "{0} - {1}" -f
            $Result.File,
            $Result.Message
        )
    }
    else {
        Write-AuditResult "FAIL" (
            "{0} - {1}" -f
            $Result.File,
            $Result.Message
        )
    }
}

# ============================================================
# 5. HTML ASSET REFERENCE AUDIT
# ============================================================

Write-Section "HTML ASSET REFERENCE AUDIT"

$HtmlFiles = @(
    Get-ChildItem `
        -LiteralPath $AudioRoot `
        -Filter "index.html" `
        -File `
        -Recurse `
        -ErrorAction Stop
)

$ReferenceResults = @()

$AssetPattern = @'
(?i)(?:src|href)\s*=\s*[^"']+\.(?:css|js|json|wav|mp3|ogg|flac|webm|png|jpg|jpeg|svg|webp(?:[?#][^"']*)?)["']
'@

foreach ($HtmlFile in $HtmlFiles) {

    $Html = Get-Content `
        -LiteralPath $HtmlFile.FullName `
        -Raw `
        -ErrorAction Stop

    $Matches = [regex]::Matches(
        $Html,
        $AssetPattern.Trim()
    )

    foreach ($Match in $Matches) {

        $Reference = $Match.Groups[1].Value.Trim()

        if ([string]::IsNullOrWhiteSpace($Reference)) {
            continue
        }

        $IsExternal =
            $Reference.StartsWith(
                "http://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "https://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "data:",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith("//")

        if ($IsExternal) {
            continue
        }

        $CleanReference = ($Reference -split '[?#]')[0]

        if ([string]::IsNullOrWhiteSpace($CleanReference)) {
            continue
        }

        if ($CleanReference.StartsWith("/")) {

            $RelativePath = $CleanReference.TrimStart("/") -replace '/', '\'

            $TargetPath = Join-Path `
                $RepositoryRoot `
                $RelativePath
        }
        else {

            $RelativePath = $CleanReference -replace '/', '\'

            $TargetPath = Join-Path `
                $HtmlFile.DirectoryName `
                $RelativePath
        }

        try {

            $ResolvedTarget = [System.IO.Path]::GetFullPath(
                $TargetPath
            )

            $Exists = Test-Path `
                -LiteralPath $ResolvedTarget `
                -PathType Leaf

            $ReferenceResults += [pscustomobject]@{
                Status = if ($Exists) {
                    "PASS"
                }
                else {
                    "FAIL"
                }

                Page = $HtmlFile.FullName.Substring(
                    $AudioRoot.Length
                ).TrimStart("\")

                Reference = $Reference
                Target = $ResolvedTarget
            }
        }
        catch {

            $ReferenceResults += [pscustomobject]@{
                Status = "FAIL"

                Page = $HtmlFile.FullName.Substring(
                    $AudioRoot.Length
                ).TrimStart("\")

                Reference = $Reference
                Target = $TargetPath
            }
        }
    }
}

$PassedReferences = @(
    $ReferenceResults |
    Where-Object {
        $_.Status -eq "PASS"
    }
)

$BrokenReferences = @(
    $ReferenceResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

Write-Host ("HTML pages checked     : {0}" -f $HtmlFiles.Count)
Write-Host ("Asset references found : {0}" -f $ReferenceResults.Count)

if ($PassedReferences.Count -gt 0) {
    Write-Host (
        "References passed      : {0}" -f
        $PassedReferences.Count
    ) -ForegroundColor Green
}
else {
    Write-Host "References passed      : 0"
}

if ($BrokenReferences.Count -eq 0) {

    Write-Host "References failed      : 0" -ForegroundColor Green
    Write-AuditResult "PASS" "Keine kaputten lokalen Asset-Verweise gefunden."
}
else {

    Write-Host (
        "References failed      : {0}" -f
        $BrokenReferences.Count
    ) -ForegroundColor Red

    Write-Host ""
    Write-Host "BROKEN ASSET REFERENCES" -ForegroundColor Red
    Write-Host "------------------------------------------------------------"

    $BrokenReferences |
        Select-Object Status, Page, Reference, Target |
        Format-Table -AutoSize -Wrap
}

# ============================================================
# 6. FINAL SUMMARY
# ============================================================

Write-Section "FINAL ASSET AUDIT SUMMARY"

$ExpectedFailures = @(
    $ExpectedResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

$JsonFailures = @(
    $JsonResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

$TotalFailures =
    $ExpectedFailures.Count +
    $EmptyAssets.Count +
    $JsonFailures.Count +
    $BrokenReferences.Count

Write-Host ("Expected assets       : {0}" -f $ExpectedResults.Count)
Write-Host ("Expected asset errors : {0}" -f $ExpectedFailures.Count)
Write-Host ("Asset files           : {0}" -f $AssetFiles.Count)
Write-Host ("Empty assets          : {0}" -f $EmptyAssets.Count)
Write-Host ("JSON files            : {0}" -f $JsonFiles.Count)
Write-Host ("JSON errors           : {0}" -f $JsonFailures.Count)
Write-Host ("HTML pages            : {0}" -f $HtmlFiles.Count)
Write-Host ("Asset references      : {0}" -f $ReferenceResults.Count)
Write-Host ("Broken references     : {0}" -f $BrokenReferences.Count)
Write-Host ("Total failures        : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host "[PASS] AUDIO ASSET AUDIT COMPLETE" -ForegroundColor Green
    Write-Host "============================================================"

    exit 0
}
else {

    Write-Host "[FAIL] AUDIO ASSET AUDIT FAILED" -ForegroundColor Red
    Write-Host "============================================================"

    exit 1
}



