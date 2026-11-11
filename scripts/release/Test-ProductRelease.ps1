[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path $PSScriptRoot "..\..\config\product.json")
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================"
Write-Host " CoreCraft Genesis - Product Release Gate"
Write-Host "============================================================"

try {
    # ------------------------------------------------------------
    # 1. Konfigurationsdatei auflösen
    # ------------------------------------------------------------

    $ConfigPath = [System.IO.Path]::GetFullPath($ConfigPath)

    Write-Host "[INFO] Config: $ConfigPath"

    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        throw "product.json wurde nicht gefunden: $ConfigPath"
    }

    # ------------------------------------------------------------
    # 2. JSON laden und validieren
    # ------------------------------------------------------------

    try {
        $json = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8
        $config = $json | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "product.json enthält ungültiges JSON: $($_.Exception.Message)"
    }

    $errors = [System.Collections.Generic.List[string]]::new()

    # ------------------------------------------------------------
    # 3. Product prüfen
    # ------------------------------------------------------------

    if ($null -eq $config.product) {
        $errors.Add("product fehlt.")
    }
    else {
        if ([string]::IsNullOrWhiteSpace([string]$config.product.name)) {
            $errors.Add("product.name fehlt.")
        }

        if ($config.product.active -ne $true) {
            $errors.Add("product.active muss true sein.")
        }

        if ($null -eq $config.product.version) {
            $errors.Add("product.version fehlt.")
        }
    }

    # ------------------------------------------------------------
    # 4. Developer Tools prüfen
    # ------------------------------------------------------------

    if ($null -eq $config.developerTools) {
        $errors.Add("developerTools fehlt.")
    }
    else {
        if ($null -eq $config.developerTools.validators) {
            $errors.Add("developerTools.validators fehlt.")
        }
        else {
            $requiredValidators = @(
                "json",
                "schema",
                "file"
            )

            foreach ($validator in $requiredValidators) {
                if ($validator -notin @($config.developerTools.validators)) {
                    $errors.Add(
                        "Pflicht-Validator '$validator' fehlt."
                    )
                }
            }
        }

        if ($config.developerTools.diagnostics.sha256 -ne $true) {
            $errors.Add(
                "developerTools.diagnostics.sha256 muss true sein."
            )
        }

        if ($config.developerTools.dataTools.formatter -ne $true) {
            $errors.Add(
                "developerTools.dataTools.formatter muss true sein."
            )
        }

        if ($config.developerTools.dataTools.inspector -ne $true) {
            $errors.Add(
                "developerTools.dataTools.inspector muss true sein."
            )
        }
    }

    # ------------------------------------------------------------
    # 5. Release prüfen
    # ------------------------------------------------------------

    if ($null -eq $config.release) {
        $errors.Add("release fehlt.")
    }
    else {
        if ([System.String]::IsNullOrWhiteSpace([string]$config.release.status)) {
            $errors.Add("release.status fehlt.")
        }
        elseif ($config.release.status -ne "stable") {
            $errors.Add(
                "release.status muss 'stable' sein. Aktuell: '$($config.release.status)'"
            )
        }

        if ($config.release.ready -ne $true) {
            $errors.Add("release.ready muss true sein.")
        }
    }

    # ------------------------------------------------------------
    # 6. Ergebnis
    # ------------------------------------------------------------

    if ($errors.Count -gt 0) {
        Write-Host ""
        Write-Host "[FAIL] Product Release Gate" -ForegroundColor Red

        foreach ($message in $errors) {
            Write-Host "  - $message" -ForegroundColor Red
        }

        Write-Host ""
        Write-Host "RELEASE BLOCKED" -ForegroundColor Red

        exit 1
    }

    Write-Host ""
    Write-Host "[PASS] Product Release Gate" -ForegroundColor Green
    Write-Host ""

    Write-Host "Product : $($config.product.name)"
    Write-Host "Version : $($config.product.version)"
    Write-Host "Active  : $($config.product.active)"
    Write-Host "Status  : $($config.release.status)"
    Write-Host "Ready   : $($config.release.ready)"

    Write-Host ""
    Write-Host "RELEASE CONFIGURATION APPROVED" -ForegroundColor Green

    exit 0
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Product Release Gate" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "RELEASE BLOCKED" -ForegroundColor Red

    exit 1
}
