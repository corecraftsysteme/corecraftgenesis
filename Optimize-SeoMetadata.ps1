[CmdletBinding()]
param(
    [switch]$Apply,

    [string]$RepositoryRoot = "C:\corecraftgenesis-github"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$MinimumDescriptionLength = 50
$MaximumDescriptionLength = 170
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$BackupRoot = Join-Path `
    "C:\corecraftgenesis-backups" `
    "seo-metadata-$Timestamp"

$DescriptionUpdates = [ordered]@{
    "about\index.html" = "Erfahren Sie mehr über CoreCraft Genesis, unsere technische Ausrichtung, digitalen Produkte und systematische Entwicklungsarbeit."

    "account\index.html" = "Verwalten Sie Ihr CoreCraft-Genesis-Konto, persönliche Einstellungen, Zugänge und zugehörige digitale Produktinformationen."

    "blog\index.html" = "Entdecken Sie technische Beiträge, Produktneuigkeiten, Analysen und Entwicklungsberichte aus dem CoreCraft-Genesis-Ökosystem."

    "contact\index.html" = "Kontaktieren Sie CoreCraft Genesis für Fragen zu Produkten, Dokumentation, technischen Lösungen, Lizenzen oder Support."

    "docs\enginecore\index.html" = "Technische EngineCore-Dokumentation zu Architektur, Runtime, Modulen, Validierung und deterministischen Systemabläufen."

    "docs\index.html" = "Zentrale Dokumentation für CoreCraft Genesis mit technischen Anleitungen, Referenzen, Architekturen und Produktinformationen."

    "downloads\index.html" = "Downloads für CoreCraft-Genesis-Produkte, technische Dokumentationen, Dateien, Vorlagen und veröffentlichte Ressourcen."

    "index.html" = "CoreCraft Genesis entwickelt technische Produkte, Dokumentation, Developer Tools und digitale Infrastrukturen für reproduzierbare Systeme."

    "legal\imprint\index.html" = "Impressum von CoreCraft Genesis mit den rechtlich erforderlichen Angaben, Kontaktinformationen und Verantwortlichkeiten."

    "legal\privacy\index.html" = "Datenschutzerklärung von CoreCraft Genesis mit Informationen zur Verarbeitung, Nutzung und zum Schutz personenbezogener Daten."

    "pricing\index.html" = "Preise und Leistungsübersicht für CoreCraft-Genesis-Produkte, technische Pakete, Dokumentationen und digitale Lösungen."

    "products\audio\diagnostics\index.html" = "Audio Diagnostics für technische Signalprüfungen, Zustandsanalysen, Fehlererkennung und nachvollziehbare Audio-Workflows."

    "referral\index.html" = "Das CoreCraft-Genesis-Empfehlungsprogramm bietet Informationen zu Teilnahme, Weiterempfehlungen und verfügbaren Vorteilen."

    "referral\join\index.html" = "Am CoreCraft-Genesis-Empfehlungsprogramm teilnehmen und technische Produkte sowie digitale Lösungen weiterempfehlen."

    "referral\terms\index.html" = "Bedingungen des CoreCraft-Genesis-Empfehlungsprogramms mit Regeln, Voraussetzungen und wichtigen Teilnahmeinformationen."

    "shop\index.html" = "CoreCraft-Genesis-Shop für technische Produkte, Dokumentationen, Developer Tools, Vorlagen und digitale Ressourcen."

    "solutions\index.html" = "Technische Lösungen von CoreCraft Genesis für Entwicklung, Dokumentation, Infrastruktur, Validierung und digitale Produkte."

    "support\index.html" = "Support für CoreCraft-Genesis-Produkte mit technischer Hilfe, Dokumentation, Kontaktwegen und wichtigen Ressourcen."
}

$TitleUpdates = [ordered]@{
    "docs\enginecore\index.html" =
        "EngineCore Dokumentation | CoreCraft Genesis"
}

function Copy-BackupFile {
    param(
        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $BackupPath = Join-Path `
        $BackupRoot `
        $RelativePath

    $BackupDirectory = Split-Path `
        -Parent `
        $BackupPath

    New-Item `
        -ItemType Directory `
        -Path $BackupDirectory `
        -Force |
        Out-Null

    Copy-Item `
        -LiteralPath $SourcePath `
        -Destination $BackupPath `
        -Force
}

Write-Host ""
Write-Host "============================================================"
Write-Host " CORECRAFT GENESIS - SEO METADATA OPTIMIZATION"
Write-Host "============================================================"

if (
    -not (
        Test-Path `
            -LiteralPath $RepositoryRoot `
            -PathType Container
    )
) {
    throw "Repository-Root nicht gefunden: $RepositoryRoot"
}

$ValidationFailures = 0

Write-Host ""
Write-Host "DESCRIPTION VALIDATION"
Write-Host "------------------------------------------------------------"

foreach ($Entry in $DescriptionUpdates.GetEnumerator()) {
    $Length = $Entry.Value.Length
    $Valid = (
        $Length -ge $MinimumDescriptionLength -and
        $Length -le $MaximumDescriptionLength
    )

    if ($Valid) {
        Write-Host (
            "[PASS] {0} - {1} Zeichen" -f
            $Entry.Key,
            $Length
        ) -ForegroundColor Green
    }
    else {
        Write-Host (
            "[FAIL] {0} - {1} Zeichen" -f
            $Entry.Key,
            $Length
        ) -ForegroundColor Red

        $ValidationFailures++
    }
}

if ($ValidationFailures -gt 0) {
    Write-Host ""
    Write-Host (
        "[FAIL] {0} Beschreibungen ausserhalb der Grenzwerte." -f
        $ValidationFailures
    ) -ForegroundColor Red

    exit 1
}

$TargetFiles = @(
    @($DescriptionUpdates.Keys) +
    @($TitleUpdates.Keys) |
    Sort-Object -Unique
)

$Results = [Collections.Generic.List[object]]::new()

$ChangedFiles = 0
$UnchangedFiles = 0
$Failures = 0

Write-Host ""
Write-Host "FILE PROCESSING"
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $TargetFiles) {
    $FullPath = Join-Path `
        $RepositoryRoot `
        $RelativePath

    if (
        -not (
            Test-Path `
                -LiteralPath $FullPath `
                -PathType Leaf
        )
    ) {
        $Failures++

        $Results.Add(
            [pscustomobject]@{
                File   = $RelativePath
                Action = "FAIL"
                Detail = "Datei nicht gefunden."
            }
        )

        continue
    }

    $Html = Get-Content `
        -LiteralPath $FullPath `
        -Raw

    $UpdatedHtml = $Html
    $Changes = [Collections.Generic.List[string]]::new()

    if ($DescriptionUpdates.Contains($RelativePath)) {
        $Description = $DescriptionUpdates[$RelativePath]

        $DescriptionPattern = (
            '(?is)<meta\b' +
            '(?=[^>]*\bname\s*=\s*["'']description["''])' +
            '[^>]*>'
        )

        if ($UpdatedHtml -notmatch $DescriptionPattern) {
            $Failures++

            $Results.Add(
                [pscustomobject]@{
                    File   = $RelativePath
                    Action = "FAIL"
                    Detail = "Meta Description nicht gefunden."
                }
            )

            continue
        }

        $DescriptionTag = (
            '<meta name="description" content="' +
            $Description +
            '">'
        )

        $UpdatedHtml = $UpdatedHtml -replace (
            $DescriptionPattern,
            $DescriptionTag
        )

        $Changes.Add("DESCRIPTION")
    }

    if ($TitleUpdates.Contains($RelativePath)) {
        $NewTitle = $TitleUpdates[$RelativePath]
        $TitlePattern = '(?is)<title\b[^>]*>.*?</title>'

        if ($UpdatedHtml -notmatch $TitlePattern) {
            $Failures++

            $Results.Add(
                [pscustomobject]@{
                    File   = $RelativePath
                    Action = "FAIL"
                    Detail = "Title-Element nicht gefunden."
                }
            )

            continue
        }

        $UpdatedHtml = $UpdatedHtml -replace (
            $TitlePattern,
            "<title>$NewTitle</title>"
        )

        $Changes.Add("TITLE")
    }

    if ($UpdatedHtml -ceq $Html) {
        $UnchangedFiles++

        $Results.Add(
            [pscustomobject]@{
                File   = $RelativePath
                Action = "UNCHANGED"
                Detail = "Keine Inhaltsaenderung erforderlich."
            }
        )

        continue
    }

    $ChangedFiles++

    if ($Apply) {
        Copy-BackupFile `
            -SourcePath $FullPath `
            -RelativePath $RelativePath

        [IO.File]::WriteAllText(
            $FullPath,
            $UpdatedHtml,
            [Text.UTF8Encoding]::new($false)
        )
    }

    $Results.Add(
        [pscustomobject]@{
            File   = $RelativePath
            Action = if ($Apply) {
                "UPDATED"
            }
            else {
                "PREVIEW"
            }

            Detail = (
                $Changes -join ", "
            )
        }
    )
}

$Results |
    Format-Table `
        Action,
        File,
        Detail `
        -AutoSize `
        -Wrap

Write-Host ""
Write-Host "============================================================"
Write-Host " SEO METADATA OPTIMIZATION SUMMARY"
Write-Host "============================================================"
Write-Host ("Target files      : {0}" -f $TargetFiles.Count)
Write-Host ("Changed files     : {0}" -f $ChangedFiles)
Write-Host ("Unchanged files   : {0}" -f $UnchangedFiles)
Write-Host ("Failures          : {0}" -f $Failures)
Write-Host ("Apply mode        : {0}" -f $Apply)

if ($Apply) {
    Write-Host ("Backup            : {0}" -f $BackupRoot)
}

Write-Host "============================================================"

if ($Failures -gt 0) {
    Write-Host "[FAIL] SEO METADATA OPTIMIZATION FAILED" -ForegroundColor Red
    exit 1
}

if ($Apply) {
    Write-Host "[PASS] SEO METADATA OPTIMIZATION APPLIED" -ForegroundColor Green
}
else {
    Write-Host "[PASS] SEO METADATA PREVIEW COMPLETE" -ForegroundColor Green
}

exit 0