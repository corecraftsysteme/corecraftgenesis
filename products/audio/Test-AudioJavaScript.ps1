#requires -Version 7.0

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis.ch\products\audio"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$JsRoot = Join-Path $Root "assets\js"
$ReportPath = Join-Path $Root "audio-js-report.json"

$TargetFiles = @(
    "audio-core.js"
    "audio-analyzer.js"
    "audio-state.js"
    "ui.js"
)

Write-Host ""
Write-Host "CoreCraft Genesis - Audio JavaScript Audit" `
    -ForegroundColor Cyan

Write-Host "Root: $JsRoot"
Write-Host ""

$Results = foreach ($Name in $TargetFiles) {

    $File = Join-Path $JsRoot $Name
    $Exists = Test-Path -LiteralPath $File -PathType Leaf

    if (-not $Exists) {

        [pscustomobject]@{
            Status = "MISSING"
            File = $Name
            Bytes = 0
            Lines = 0
            Imports = 0
            Exports = 0
            Balanced = $false
            Path = $File
        }

        continue
    }

    $Item = Get-Item -LiteralPath $File
    $Content = Get-Content -LiteralPath $File -Raw
    $Lines = @(Get-Content -LiteralPath $File).Count

    $HasContent = -not :IsNullOrWhiteSpace($Content)
    $EnoughContent = $Item.Length -gt 500

    $ImportCount = @(
        :Matches(
            $Content,
            '(?m)^\s*import\s'
        )
    ).Count

    $ExportCount = @(
        :Matches(
            $Content,
            '(?m)^\s*export\s'
        )
    ).Count

    $OpenBraces = (:Matches($Content, '\{')).Count
    $CloseBraces = (:Matches($Content, '\}')).Count
    $OpenParentheses = (:Matches($Content, '\(')).Count
    $CloseParentheses = (:Matches($Content, '\)')).Count
    $OpenBrackets = (:Matches($Content, '\[')).Count
    $CloseBrackets = (:Matches($Content, '\]')).Count

    $Balanced = (
        $OpenBraces -eq $CloseBraces -and
        $OpenParentheses -eq $CloseParentheses -and
        $OpenBrackets -eq $CloseBrackets
    )

    $Status = if (
        $HasContent -and
        $EnoughContent -and
        $Balanced
    ) {
        "PASS"
    }
    else {
        "INVALID"
    }

    [pscustomobject]@{
        Status = $Status
        File = $Name
        Bytes = $Item.Length
        Lines = $Lines
        Imports = $ImportCount
        Exports = $ExportCount
        Balanced = $Balanced
        Path = $File
    }
}

$Results |
    Format-Table `
        Status,
        File,
        Bytes,
        Lines,
        Imports,
        Exports,
        Balanced `
        -AutoSize

$Results |
    ConvertTo-Json -Depth 5 |
    Set-Content `
        -LiteralPath $ReportPath `
        -Encoding utf8

$Failed = @(
    $Results |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

Write-Host ""
Write-Host "------------------------------------------------------------"

if ($Failed.Count -eq 0) {

    Write-Host `
        "[PASS] Alle vier JavaScript-Dateien sind vorhanden." `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Alle Dateien enthalten JavaScript-Code." `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Klammerprüfung ohne Abweichung." `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Bericht: $ReportPath" `
        -ForegroundColor Green

    exit 0
}

Write-Host `
    "[FAIL] Fehlerhafte oder fehlende Dateien: $($Failed.Count)" `
    -ForegroundColor Red

$Failed |
    Format-Table `
        Status,
        File,
        Bytes,
        Balanced,
        Path `
        -AutoSize

exit 1
