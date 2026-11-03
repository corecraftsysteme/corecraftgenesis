#Requires -Version 7.0

<#
.SYNOPSIS
    Finaler Live-Audit fuer CoreCraft Genesis Audio.

.DESCRIPTION
    Prueft die neun zentralen Audio-Webseiten der
    veroeffentlichten CoreCraft-Genesis-Website.

    Geprueft werden:
    - HTTP-Erreichbarkeit
    - HTTP-Status 200
    - empfangene Seitengroesse
    - HTML-Titel
    - vollstaendige Anzahl erwarteter URLs

    Exitcode:
      0 = Audit bestanden
      1 = Audit fehlgeschlagen
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$BaseUrl = "https://corecraftgenesis.ch/products/audio"

$Paths = @(
    ""
    "audiostate"
    "dsp"
    "orchestration"
    "validation"
    "scaling"
    "diagnostics"
    "tools"
    "demos"
)

$ExpectedUrlCount = 9
$TimeoutSeconds = 30

# ============================================================
# ALTE VARIABLEN ENTFERNEN
# ============================================================

Remove-Variable `
    -Name Urls, Results, Passed, Failures, Response `
    -ErrorAction SilentlyContinue

# ============================================================
# URLS GENERIEREN
# ============================================================

$Urls = @(
    foreach ($Path in $Paths) {

        if ([string]::IsNullOrWhiteSpace($Path)) {
            "$BaseUrl/"
        }
        else {
            "$BaseUrl/$Path/"
        }
    }
)

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - FINAL LIVE AUDIO AUDIT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host ("Base URL      : {0}" -f $BaseUrl)
Write-Host ("Expected URLs : {0}" -f $ExpectedUrlCount)
Write-Host ("Generated URLs: {0}" -f $Urls.Count)
Write-Host ""

# ============================================================
# URL-LISTE PRUEFEN
# ============================================================

if ($Urls.Count -ne $ExpectedUrlCount) {

    Write-Host (
        "[FAIL] Erwartet wurden {0} URLs, erzeugt wurden {1}." -f
        $ExpectedUrlCount,
        $Urls.Count
    ) -ForegroundColor Red

    exit 1
}

Write-Host "[PASS] URL-Liste vollstaendig." -ForegroundColor Green

# ============================================================
# LIVE HTTP AUDIT
# ============================================================

Write-Host ""
Write-Host "LIVE HTTP AUDIT" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$Results = @(
    foreach ($Url in $Urls) {

        Write-Host ("[CHECK] {0}" -f $Url) -ForegroundColor DarkGray

        try {

            $Response = Invoke-WebRequest `
                -Uri $Url `
                -Method Get `
                -MaximumRedirection 5 `
                -TimeoutSec $TimeoutSeconds `
                -ErrorAction Stop

            $StatusCode = [int]$Response.StatusCode
            $Content = [string]$Response.Content

            $Bytes = [System.Text.Encoding]::UTF8.GetByteCount(
                $Content
            )

            $Title = ""

            if (
                $Content -match
                '(?is)<title[^>]*>(.*?)</title>'
            ) {
                $Title = $Matches[1].Trim()
            }

            $Status = if ($StatusCode -eq 200) {
                "PASS"
            }
            else {
                "CHECK"
            }

            [pscustomobject]@{
                Status     = $Status
                StatusCode = $StatusCode
                Bytes      = $Bytes
                Title      = $Title
                URL        = $Url
                Error      = ""
            }
        }
        catch {

            $StatusCode = $null
            $ErrorMessage = $_.Exception.Message

            $ResponseProperty = $_.Exception.PSObject.Properties[
                "Response"
            ]

            if (
                $null -ne $ResponseProperty -and
                $null -ne $ResponseProperty.Value
            ) {

                $ErrorResponse = $ResponseProperty.Value

                $StatusProperty = $ErrorResponse.PSObject.Properties[
                    "StatusCode"
                ]

                if (
                    $null -ne $StatusProperty -and
                    $null -ne $StatusProperty.Value
                ) {
                    try {
                        $StatusCode = [int]$StatusProperty.Value
                    }
                    catch {
                        $StatusCode = $null
                    }
                }
            }

            [pscustomobject]@{
                Status     = "FAIL"
                StatusCode = $StatusCode
                Bytes      = 0
                Title      = ""
                URL        = $Url
                Error      = $ErrorMessage
            }
        }
    }
)

# ============================================================
# ERGEBNISSE KLASSIFIZIEREN
# ============================================================

$Passed = @(
    $Results |
    Where-Object {
        $_.Status -eq "PASS"
    }
)

$Failures = @(
    $Results |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

# ============================================================
# ERGEBNISTABELLE
# ============================================================

Write-Host ""
Write-Host "LIVE AUDIT RESULTS" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$Results |
    Format-Table `
        Status,
        StatusCode,
        Bytes,
        Title,
        URL `
        -AutoSize `
        -Wrap

# ============================================================
# FEHLERDETAILS
# ============================================================

if ($Failures.Count -gt 0) {

    Write-Host ""
    Write-Host "FAILED OR UNEXPECTED RESPONSES" -ForegroundColor Red
    Write-Host "------------------------------------------------------------"

    $Failures |
        Format-Table `
            Status,
            StatusCode,
            URL,
            Error `
            -AutoSize `
            -Wrap
}

# ============================================================
# FINAL SUMMARY
# ============================================================

Write-Host ""
Write-Host "FINAL SUMMARY" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

Write-Host (
    "URLs expected : {0}" -f
    $ExpectedUrlCount
)

Write-Host (
    "URLs generated: {0}" -f
    $Urls.Count
)

Write-Host (
    "URLs checked  : {0}" -f
    $Results.Count
)

Write-Host (
    "Passed        : {0}" -f
    $Passed.Count
)

Write-Host (
    "Failed/Check  : {0}" -f
    $Failures.Count
)

# ============================================================
# FINAL RESULT
# ============================================================

$AuditPassed = (
    $Urls.Count -eq $ExpectedUrlCount -and
    $Results.Count -eq $ExpectedUrlCount -and
    $Passed.Count -eq $ExpectedUrlCount -and
    $Failures.Count -eq 0
)

Write-Host ""
Write-Host "============================================================"

if ($AuditPassed) {

    Write-Host "[PASS] LIVE AUDIO AUDIT COMPLETE" -ForegroundColor Green
    Write-Host "============================================================"

    exit 0
}
else {

    Write-Host "[FAIL] LIVE AUDIO AUDIT NOT COMPLETE" -ForegroundColor Red
    Write-Host "============================================================"

    exit 1
}