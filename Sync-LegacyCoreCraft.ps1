[CmdletBinding()]
param(
    [ValidateSet("Audit", "Apply")]
    [string]$Mode = "Audit",

    [string]$Source = "C:\corecraftgenesis.ch",

    [string]$Destination = "C:\corecraftgenesis-github"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$ReviewRoot = Join-Path `
    $Destination `
    "_migration-review\$Timestamp"

$DifferentRoot = Join-Path `
    $ReviewRoot `
    "different-source-files"

$ReportPath = Join-Path `
    $ReviewRoot `
    "synchronization-report.csv"

$ManifestPath = Join-Path `
    $ReviewRoot `
    "synchronization-manifest.json"

$LogPath = Join-Path `
    $ReviewRoot `
    "synchronization.log"

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet(
            "INFO",
            "PASS",
            "COPY",
            "REVIEW",
            "SKIP",
            "FAIL"
        )]
        [string]$Level = "INFO"
    )

    $Line = "[{0}] [{1}] {2}" -f `
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), `
        $Level, `
        $Message

    Add-Content `
        -LiteralPath $LogPath `
        -Value $Line `
        -Encoding utf8

    $Color = switch ($Level) {
        "PASS"   { "Green" }
        "COPY"   { "Green" }
        "REVIEW" { "Yellow" }
        "SKIP"   { "DarkGray" }
        "FAIL"   { "Red" }
        default  { "Gray" }
    }

    Write-Host $Line -ForegroundColor $Color
}

function Get-Sha256 {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    return (
        Get-FileHash `
            -LiteralPath $Path `
            -Algorithm SHA256
    ).Hash
}

function Get-RelativeFilePath {
    param(
        [Parameter(Mandatory)]
        [string]$Root,

        [Parameter(Mandatory)]
        [string]$FullName
    )

    return $FullName.Substring(
        $Root.TrimEnd("\").Length
    ).TrimStart("\")
}

Write-Host ""
Write-Host "============================================================"
Write-Host " CORECRAFT LEGACY SYNCHRONIZATION"
Write-Host "============================================================"
Write-Host ""
Write-Host "Mode        : $Mode"
Write-Host "Source      : $Source"
Write-Host "Destination : $Destination"
Write-Host ""

if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
    throw "Quellordner wurde nicht gefunden: $Source"
}

if (-not (Test-Path -LiteralPath $Destination -PathType Container)) {
    throw "Zielordner wurde nicht gefunden: $Destination"
}

if (-not (Test-Path -LiteralPath (Join-Path $Destination ".git"))) {
    throw "Das Ziel ist kein Git-Repository: $Destination"
}

New-Item `
    -ItemType Directory `
    -Path $ReviewRoot `
    -Force |
Out-Null

New-Item `
    -ItemType Directory `
    -Path $DifferentRoot `
    -Force |
Out-Null

Write-Log `
    -Level INFO `
    -Message "Synchronisation gestartet."

$DestinationBranch = git -C $Destination branch --show-current

if ($LASTEXITCODE -ne 0) {
    throw "Git-Branch im Zielrepository konnte nicht ermittelt werden."
}

$DestinationHead = git -C $Destination rev-parse HEAD

if ($LASTEXITCODE -ne 0) {
    throw "Git-HEAD im Zielrepository konnte nicht ermittelt werden."
}

$DestinationStatusBefore = @(
    git -C $Destination status --porcelain
)

$DestinationWasClean = [string]::IsNullOrWhiteSpace(
    ($DestinationStatusBefore -join "")
)

Write-Log `
    -Level INFO `
    -Message "Zielbranch: $DestinationBranch"

Write-Log `
    -Level INFO `
    -Message "Ziel-HEAD: $DestinationHead"

if ($DestinationWasClean) {
    Write-Log `
        -Level PASS `
        -Message "Zielrepository war vor der Synchronisation sauber."
}
else {
    Write-Log `
        -Level REVIEW `
        -Message "Zielrepository enthält bereits lokale Änderungen."
}

if ($Mode -eq "Apply" -and -not $DestinationWasClean) {
    throw @"
Apply wurde abgebrochen.

Das Zielrepository enthält lokale Änderungen.
Bitte zuerst committen, sichern oder verwerfen.

Ziel:
$Destination
"@
}

$ExcludedDirectoryNames = @(
    ".git",
    "node_modules",
    "playwright-report",
    "test-results"
)

$SourceFiles = @(
    Get-ChildItem `
        -LiteralPath $Source `
        -File `
        -Recurse `
        -Force `
        -ErrorAction Stop |
    Where-Object {
        $FilePath = $_.FullName

        -not (
            $ExcludedDirectoryNames |
            Where-Object {
                $FilePath -match (
                    "\\{0}(\\|$)" -f [regex]::Escape($_)
                )
            }
        )
    }
)

Write-Log `
    -Level INFO `
    -Message "Gefundene Quelldateien: $($SourceFiles.Count)"

$Results = [System.Collections.Generic.List[object]]::new()

$IdenticalCount = 0
$MissingCount   = 0
$DifferentCount = 0
$CopiedCount    = 0
$ReviewCount    = 0
$FailureCount   = 0

foreach ($SourceFile in $SourceFiles) {
    try {
        $RelativePath = Get-RelativeFilePath `
            -Root $Source `
            -FullName $SourceFile.FullName

        $DestinationFile = Join-Path `
            $Destination `
            $RelativePath

        $SourceHash = Get-Sha256 `
            -Path $SourceFile.FullName

        if (-not (Test-Path -LiteralPath $DestinationFile -PathType Leaf)) {
            $MissingCount++

            $Action = if ($Mode -eq "Apply") {
                "COPIED_TO_DESTINATION"
            }
            else {
                "AUDIT_ONLY"
            }

            if ($Mode -eq "Apply") {
                $DestinationDirectory = Split-Path `
                    -Path $DestinationFile `
                    -Parent

                New-Item `
                    -ItemType Directory `
                    -Path $DestinationDirectory `
                    -Force |
                Out-Null

                Copy-Item `
                    -LiteralPath $SourceFile.FullName `
                    -Destination $DestinationFile `
                    -Force

                $CopiedHash = Get-Sha256 `
                    -Path $DestinationFile

                if ($CopiedHash -ne $SourceHash) {
                    throw "Hashabweichung nach dem Kopieren."
                }

                $CopiedCount++

                Write-Log `
                    -Level COPY `
                    -Message "Fehlende Datei kopiert: $RelativePath"
            }
            else {
                Write-Log `
                    -Level INFO `
                    -Message "Fehlt im Ziel: $RelativePath"
            }

      $Results.Add(
                [PSCustomObject]@{
                    Status          = "MISSING"
                    Action          = $Action
                    RelativePath    = $RelativePath
                    SourceBytes     = $SourceFile.Length
                    DestinationBytes = $null
                    SourceSHA256    = $SourceHash
                    DestinationSHA256 = $null
                }
            )

            continue
        }

        $DestinationItem = Get-Item `
            -LiteralPath $DestinationFile

        $DestinationHash = Get-Sha256 `
            -Path $DestinationFile

        if ($SourceHash -eq $DestinationHash) {
            $IdenticalCount++

            Write-Log `
                -Level SKIP `
                -Message "Identisch: $RelativePath"

            $Results.Add(
                [PSCustomObject]@{
                    Status            = "IDENTICAL"
                    Action            = "SKIPPED"
                    RelativePath      = $RelativePath
                    SourceBytes       = $SourceFile.Length
                    DestinationBytes  = $DestinationItem.Length
                    SourceSHA256      = $SourceHash
                    DestinationSHA256 = $DestinationHash
                }
            )

            continue
        }

        $DifferentCount++

        $ReviewFile = Join-Path `
            $DifferentRoot `
            $RelativePath

        $ReviewDirectory = Split-Path `
            -Path $ReviewFile `
            -Parent

        New-Item `
            -ItemType Directory `
            -Path $ReviewDirectory `
            -Force |
        Out-Null

        Copy-Item `
            -LiteralPath $SourceFile.FullName `
            -Destination $ReviewFile `
            -Force

        $ReviewHash = Get-Sha256 `
            -Path $ReviewFile

        if ($ReviewHash -ne $SourceHash) {
            throw "Hashabweichung beim Erstellen der Review-Kopie."
        }

        $ReviewCount++

        Write-Log `
            -Level REVIEW `
            -Message "Abweichende Quelldatei gesichert: $RelativePath"

        $Results.Add(
            [PSCustomObject]@{
                Status            = "DIFFERENT"
                Action            = "COPIED_TO_REVIEW"
                RelativePath      = $RelativePath
                SourceBytes       = $SourceFile.Length
                DestinationBytes  = $DestinationItem.Length
                SourceSHA256      = $SourceHash
                DestinationSHA256 = $DestinationHash
            }
        )
    }
    catch {
        $FailureCount++

        Write-Log `
            -Level FAIL `
            -Message "$($SourceFile.FullName): $($_.Exception.Message)"

        $Results.Add(
            [PSCustomObject]@{
                Status            = "FAILED"
                Action            = "NONE"
                RelativePath      = $SourceFile.FullName
                SourceBytes       = $SourceFile.Length
                DestinationBytes  = $null
                SourceSHA256      = $null
                DestinationSHA256 = $null
            }
        )
    }
}

$Results |
    Sort-Object Status, RelativePath |
    Export-Csv `
        -LiteralPath $ReportPath `
        -NoTypeInformation `
        -Encoding utf8

$DestinationStatusAfter = @(
    git -C $Destination status --porcelain
)

$Manifest = [ordered]@{
    schemaVersion = "1.0.0"
    generatedAt   = (Get-Date).ToString("o")
    mode          = $Mode
    source        = $Source
    destination   = $Destination
    destinationBranch = $DestinationBranch
    destinationHeadBefore = $DestinationHead
    destinationWasClean = $DestinationWasClean
    sourceFileCount = $SourceFiles.Count
    summary = [ordered]@{
        identical = $IdenticalCount
        missing   = $MissingCount
        different = $DifferentCount
        copiedToDestination = $CopiedCount
        copiedToReview = $ReviewCount
        failures = $FailureCount
    }
    reviewRoot = $ReviewRoot
    reportPath = $ReportPath
    logPath    = $LogPath
    destinationStatusAfter = @($DestinationStatusAfter)
}

$Manifest |
    ConvertTo-Json -Depth 8 |
    Set-Content `
        -LiteralPath $ManifestPath `
        -Encoding utf8

Write-Host ""
Write-Host "============================================================"
Write-Host " SYNCHRONIZATION SUMMARY"
Write-Host "============================================================"
Write-Host ""

[PSCustomObject]@{
    Mode                = $Mode
    SourceFiles         = $SourceFiles.Count
    Identical           = $IdenticalCount
    Missing             = $MissingCount
    Different           = $DifferentCount
    CopiedToDestination = $CopiedCount
    CopiedToReview      = $ReviewCount
    Failures            = $FailureCount
    ReviewRoot          = $ReviewRoot
    Report              = $ReportPath
    Manifest            = $ManifestPath
} | Format-List

if ($FailureCount -gt 0) {
    Write-Host ""
    Write-Host "FINAL FAIL: $FailureCount Datei(en) konnten nicht verarbeitet werden." `
        -ForegroundColor Red

    exit 1
}

if ($Mode -eq "Audit") {
    Write-Host ""
    Write-Host "AUDIT PASS: Es wurden keine Zieldateien verändert." `
        -ForegroundColor Green

    Write-Host "Für die kontrollierte Übernahme fehlender Dateien:" `
        -ForegroundColor Cyan

    Write-Host `
        '.\Sync-LegacyCoreCraft.ps1 -Mode Apply' `
        -ForegroundColor White
}
else {
    Write-Host ""
    Write-Host "APPLY PASS: Fehlende Dateien wurden übernommen." `
        -ForegroundColor Green

    Write-Host "Abweichende Dateien wurden nicht überschrieben." `
        -ForegroundColor Yellow

    Write-Host "Review-Ordner: $DifferentRoot" `
        -ForegroundColor Yellow
}
