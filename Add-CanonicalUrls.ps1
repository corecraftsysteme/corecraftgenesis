[CmdletBinding()]
param(
    [switch]$Apply,

    [string]$RepositoryRoot = "C:\corecraftgenesis-github"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$BaseUrl = (
    "https:" +
    [char]47 +
    [char]47 +
    "corecraftgenesis.ch"
)

$ExcludedDirectories = @(
    ".git"
    ".github"
    ".vscode"
)

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$BackupRoot = Join-Path `
    "C:\corecraftgenesis-backups" `
    "canonical-$Timestamp"

function Get-RelativePagePath {
    param(
        [Parameter(Mandatory)]
        [string]$Root,

        [Parameter(Mandatory)]
        [string]$Path
    )

    return [IO.Path]::GetRelativePath(
        [IO.Path]::GetFullPath($Root),
        [IO.Path]::GetFullPath($Path)
    )
}

function Test-ExcludedPath {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    foreach ($Directory in $ExcludedDirectories) {
        if (
            $RelativePath -eq $Directory -or
            $RelativePath -like "$Directory\*" -or
            $RelativePath -like "$Directory/*"
        ) {
            return $true
        }
    }

    return $false
}

function Get-CanonicalUrl {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $Normalized = $RelativePath.Replace(
        "\",
        "/"
    )

    if ($Normalized -eq "index.html") {
        return "$BaseUrl/"
    }

    if ($Normalized.EndsWith("/index.html")) {
        $Route = $Normalized.Substring(
            0,
            $Normalized.Length - "index.html".Length
        )

        return "$BaseUrl/$Route"
    }

    return "$BaseUrl/$Normalized"
}

function Get-CanonicalTag {
    param(
        [Parameter(Mandatory)]
        [string]$CanonicalUrl
    )

    $Left = [string][char]60
    $Right = [string][char]62

    return (
        $Left +
        'link rel="canonical" href="' +
        $CanonicalUrl +
        '"' +
        $Right
    )
}

function Copy-PageBackup {
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
Write-Host " CORECRAFT GENESIS - CANONICAL URL AUTOMATION"
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

$Pages = @(
    Get-ChildItem `
        -LiteralPath $RepositoryRoot `
        -Filter "*.html" `
        -File `
        -Recurse |
    Where-Object {
        $RelativePath = Get-RelativePagePath `
            -Root $RepositoryRoot `
            -Path $_.FullName

        -not (
            Test-ExcludedPath `
                -RelativePath $RelativePath
        )
    } |
    Sort-Object FullName
)

$Results = [Collections.Generic.List[object]]::new()

$InsertCount = 0
$UpdateCount = 0
$UnchangedCount = 0
$SkippedCount = 0
$FailureCount = 0

foreach ($Page in $Pages) {
    $RelativePath = Get-RelativePagePath `
        -Root $RepositoryRoot `
        -Path $Page.FullName

    if ($RelativePath -ieq "404.html") {
        $SkippedCount++

        $Results.Add(
            [pscustomobject]@{
                File      = $RelativePath
                Action    = "SKIP"
                Canonical = ""
                Detail    = "404-Seite bleibt ohne Canonical."
            }
        )

        continue
    }

    $Html = Get-Content `
        -LiteralPath $Page.FullName `
        -Raw

    if (
        $null -eq $Html -or
        $Html.Trim().Length -eq 0
    ) {
        $FailureCount++

        $Results.Add(
            [pscustomobject]@{
                File      = $RelativePath
                Action    = "FAIL"
                Canonical = ""
                Detail    = "HTML-Datei ist leer."
            }
        )

        continue
    }

    if ($Html -notmatch '(?is)</head\s*>') {
        $FailureCount++

        $Results.Add(
            [pscustomobject]@{
                File      = $RelativePath
                Action    = "FAIL"
                Canonical = ""
                Detail    = "Schliessendes head-Element fehlt."
            }
        )

        continue
    }

    $CanonicalUrl = Get-CanonicalUrl `
        -RelativePath $RelativePath

    $CanonicalTag = Get-CanonicalTag `
        -CanonicalUrl $CanonicalUrl

$CanonicalPattern = (
    '(?is)<link\b' +
    '(?=[^>]*\brel\s*=\s*["'']' +
    '[^"'']*\bcanonical\b[^"'']*["''])' +
    '[^>]*>'
)

$ExistingCanonicalTags = @(
    [regex]::Matches(
        $Html,
        $CanonicalPattern
    )
)

    if ($ExistingCanonicalTags.Count -gt 1) {
        $FailureCount++

        $Results.Add(
            [pscustomobject]@{
                File      = $RelativePath
                Action    = "FAIL"
                Canonical = $CanonicalUrl
                Detail    = (
                    "{0} Canonical-Tags vorhanden." -f
                    $ExistingCanonicalTags.Count
                )
            }
        )

        continue
    }

    $UpdatedHtml = $Html
    $Action = ""

    if ($ExistingCanonicalTags.Count -eq 1) {
        $ExistingTag = $ExistingCanonicalTags[0].Value

if (
    $ExistingTag.Contains($CanonicalUrl)
) {
    $UnchangedCount++
    $Action = "UNCHANGED"
}
        else {
            $UpdatedHtml = $Html.Replace(
                $ExistingTag,
                $CanonicalTag
            )

            $UpdateCount++
            $Action = "UPDATE"
        }
    }
    else {
        $UpdatedHtml = $Html -replace (
            '(?is)</head\s*>',
            "  $CanonicalTag`r`n</head>"
        )

        $InsertCount++
        $Action = "INSERT"
    }

    if (
        $Apply -and
        $Action -in @(
            "INSERT",
            "UPDATE"
        )
    ) {
        Copy-PageBackup `
            -SourcePath $Page.FullName `
            -RelativePath $RelativePath

        [IO.File]::WriteAllText(
            $Page.FullName,
            $UpdatedHtml,
            [Text.UTF8Encoding]::new($false)
        )
    }

    $Results.Add(
        [pscustomobject]@{
            File      = $RelativePath
            Action    = $Action
            Canonical = $CanonicalUrl
            Detail    = if ($Apply) {
                "Verarbeitung abgeschlossen."
            }
            else {
                "Vorschau, Datei nicht veraendert."
            }
        }
    )
}

Write-Host ""
Write-Host "CANONICAL RESULTS"
Write-Host "------------------------------------------------------------"

$Results |
    Format-Table `
        Action,
        File,
        Canonical `
        -AutoSize `
        -Wrap

Write-Host ""
Write-Host "============================================================"
Write-Host " CANONICAL AUTOMATION SUMMARY"
Write-Host "============================================================"
Write-Host ("HTML pages        : {0}" -f $Pages.Count)
Write-Host ("Insert            : {0}" -f $InsertCount)
Write-Host ("Update            : {0}" -f $UpdateCount)
Write-Host ("Unchanged         : {0}" -f $UnchangedCount)
Write-Host ("Skipped           : {0}" -f $SkippedCount)
Write-Host ("Failures          : {0}" -f $FailureCount)
Write-Host ("Apply mode        : {0}" -f $Apply)

if ($Apply) {
    Write-Host ("Backup            : {0}" -f $BackupRoot)
}

Write-Host "============================================================"

if ($FailureCount -gt 0) {
    Write-Host "[FAIL] CANONICAL AUTOMATION FAILED" -ForegroundColor Red
    exit 1
}

if ($Apply) {
    Write-Host "[PASS] CANONICAL URLS APPLIED" -ForegroundColor Green
}
else {
    Write-Host "[PASS] CANONICAL PREVIEW COMPLETE" -ForegroundColor Green
}

exit 0