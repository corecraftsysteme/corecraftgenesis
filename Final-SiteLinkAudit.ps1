#Requires -Version 7.0

<#
.SYNOPSIS
    Finaler siteweiter Link-Audit fuer CoreCraft Genesis.

.DESCRIPTION
    Prueft rekursiv alle HTML-Dateien im Repository auf:
    - interne href-Verweise
    - lokale src-Verweise
    - vorhandene Zielseiten
    - vorhandene Assets
    - leere HTML-Dateien

    Externe URLs, mailto:, tel:, javascript: und reine
    Fragment-Links werden nicht lokal aufgeloest.

.EXITCODES
    0 = PASS
    1 = FAIL
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RelativePath {
    param(
        [string]$Base,
        [string]$Path
    )

    return [System.IO.Path]::GetRelativePath(
        $Base,
        $Path
    )
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - FINAL SITE LINK AUDIT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# ROOT
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] Repository-Root fehlt: $Root" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[PASS] Repository-Root vorhanden." -ForegroundColor Green

# ============================================================
# HTML INVENTUR
# ============================================================

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

Write-Host ""
Write-Host "HTML INVENTORY" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"
Write-Host ("HTML pages found : {0}" -f $HtmlFiles.Count)
Write-Host ("Empty HTML files : {0}" -f $EmptyHtmlFiles.Count)

if ($EmptyHtmlFiles.Count -gt 0) {

    Write-Host ""
    Write-Host "EMPTY HTML FILES" -ForegroundColor Red

    $EmptyHtmlFiles |
        ForEach-Object {
            Write-Host (
                "[FAIL] {0}" -f
                (Get-RelativePath -Base $Root -Path $_.FullName)
            ) -ForegroundColor Red
        }
}

# ============================================================
# LINK- UND ASSET-ERKENNUNG
# ============================================================

$ReferencePattern = '(?<attr>href|src)\s*=\s*["''](?<value>[^"'']+)["'']'

$Results = @()

Write-Host ""
Write-Host "REFERENCE AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($HtmlFile in $HtmlFiles) {

    $Html = Get-Content `
        -LiteralPath $HtmlFile.FullName `
        -Raw `
        -ErrorAction Stop

    $Matches = [regex]::Matches(
        $Html,
        $ReferencePattern,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    foreach ($Match in $Matches) {

        $Attribute = $Match.Groups["attr"].Value
        $Reference = $Match.Groups["value"].Value.Trim()

        if ([string]::IsNullOrWhiteSpace($Reference)) {
            continue
        }

        # ----------------------------------------------------
        # Externe bzw. nicht lokal pruefbare Referenzen
        # ----------------------------------------------------

        $Ignore = (
            $Reference.StartsWith("#") -or
            $Reference.StartsWith(
                "http://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "https://",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "//",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "mailto:",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "tel:",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "javascript:",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Reference.StartsWith(
                "data:",
                [System.StringComparison]::OrdinalIgnoreCase
            )
        )

        if ($Ignore) {
            continue
        }

        # Query und Fragment entfernen
        $CleanReference = (
            $Reference -split '[?#]'
        )[0]

        if ([string]::IsNullOrWhiteSpace($CleanReference)) {
            continue
        }

        # ----------------------------------------------------
        # ZIELPFAD AUFLOESEN
        # ----------------------------------------------------

        if ($CleanReference.StartsWith("/")) {

            $RelativeTarget = (
                $CleanReference.TrimStart("/") -replace '/', '\'
            )

            $Target = Join-Path `
                $Root `
                $RelativeTarget
        }
        else {

            $RelativeTarget = (
                $CleanReference -replace '/', '\'
            )

            $Target = Join-Path `
                $HtmlFile.DirectoryName `
                $RelativeTarget
        }

        try {
            $Target = [System.IO.Path]::GetFullPath($Target)
        }
        catch {
            $Target = ""
        }

        $Exists = $false
        $ResolvedTarget = $Target

        if (-not [string]::IsNullOrWhiteSpace($Target)) {

            # Direkte Datei
            if (Test-Path -LiteralPath $Target -PathType Leaf) {

                $Exists = $true
            }

            # Verzeichnis -> index.html
            elseif (Test-Path -LiteralPath $Target -PathType Container) {

                $IndexTarget = Join-Path $Target "index.html"

                if (
                    Test-Path `
                        -LiteralPath $IndexTarget `
                        -PathType Leaf
                ) {
                    $Exists = $true
                    $ResolvedTarget = $IndexTarget
                }
            }

            # URL endet mit /
            elseif ($CleanReference.EndsWith("/")) {

                $IndexTarget = Join-Path $Target "index.html"

                if (
                    Test-Path `
                        -LiteralPath $IndexTarget `
                        -PathType Leaf
                ) {
                    $Exists = $true
                    $ResolvedTarget = $IndexTarget
                }
            }

            # Extensionlose Route
            elseif (
                [string]::IsNullOrWhiteSpace(
                    [System.IO.Path]::GetExtension($Target)
                )
            ) {

                $IndexTarget = Join-Path $Target "index.html"

                if (
                    Test-Path `
                        -LiteralPath $IndexTarget `
                        -PathType Leaf
                ) {
                    $Exists = $true
                    $ResolvedTarget = $IndexTarget
                }
            }
        }

        $Results += [pscustomobject]@{
            Status = if ($Exists) {
                "PASS"
            }
            else {
                "FAIL"
            }

            Type = if ($Attribute -ieq "src") {
                "ASSET"
            }
            else {
                "LINK"
            }

            Page = Get-RelativePath `
                -Base $Root `
                -Path $HtmlFile.FullName

            Reference = $Reference

            Target = if (
                [string]::IsNullOrWhiteSpace($ResolvedTarget)
            ) {
                "UNRESOLVED"
            }
            else {
                Get-RelativePath `
                    -Base $Root `
                    -Path $ResolvedTarget
            }
        }
    }
}

# ============================================================
# ERGEBNISSE
# ============================================================

$Passed = @(
    $Results |
    Where-Object {
        $_.Status -eq "PASS"
    }
)

$Failed = @(
    $Results |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

$Links = @(
    $Results |
    Where-Object {
        $_.Type -eq "LINK"
    }
)

$Assets = @(
    $Results |
    Where-Object {
        $_.Type -eq "ASSET"
    }
)

$BrokenLinks = @(
    $Failed |
    Where-Object {
        $_.Type -eq "LINK"
    }
)

$BrokenAssets = @(
    $Failed |
    Where-Object {
        $_.Type -eq "ASSET"
    }
)

Write-Host ("HTML pages checked : {0}" -f $HtmlFiles.Count)
Write-Host ("References checked : {0}" -f $Results.Count)
Write-Host ("References passed  : {0}" -f $Passed.Count)
Write-Host ("References failed  : {0}" -f $Failed.Count)

Write-Host ""
Write-Host ("Internal links     : {0}" -f $Links.Count)
Write-Host ("Broken links       : {0}" -f $BrokenLinks.Count)
Write-Host ("Local assets       : {0}" -f $Assets.Count)
Write-Host ("Broken assets      : {0}" -f $BrokenAssets.Count)

# ============================================================
# FEHLERDETAILS
# ============================================================

if ($Failed.Count -gt 0) {

    Write-Host ""
    Write-Host "BROKEN REFERENCES" -ForegroundColor Red
    Write-Host "------------------------------------------------------------"

    $Failed |
        Sort-Object `
            Type,
            Page,
            Reference |
        Format-Table `
            Status,
            Type,
            Page,
            Reference,
            Target `
            -AutoSize `
            -Wrap
}

# ============================================================
# SUMMARY
# ============================================================
$TotalFailures = (
    $Failed.Count +
    $EmptyHtmlFiles.Count
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " FINAL SITE LINK AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("HTML pages checked : {0}" -f $HtmlFiles.Count)
Write-Host ("Empty HTML files   : {0}" -f $EmptyHtmlFiles.Count)
Write-Host ("Internal links     : {0}" -f $Links.Count)
Write-Host ("Broken links       : {0}" -f $BrokenLinks.Count)
Write-Host ("Local assets       : {0}" -f $Assets.Count)
Write-Host ("Broken assets      : {0}" -f $BrokenAssets.Count)
Write-Host ("Total failures     : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host (
        "[PASS] CORECRAFT GENESIS SITE LINK AUDIT COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] CORECRAFT GENESIS SITE LINK AUDIT FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1
