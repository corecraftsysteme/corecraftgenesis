[CmdletBinding()]
param(
    [string]$RepositoryRoot = "C:\corecraftgenesis-github",
    [int]$Port = 4173
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TestDirectory = Join-Path $RepositoryRoot "tests\browser"
$TestFile = Join-Path $TestDirectory "file-validator.spec.js"
$ConfigFile = Join-Path $RepositoryRoot "playwright.config.js"
$PageFile = Join-Path $RepositoryRoot "products\developer-tools\validators\file\index.html"

foreach ($RequiredPath in @($RepositoryRoot, $TestFile, $ConfigFile, $PageFile)) {
    if (-not (Test-Path -LiteralPath $RequiredPath)) {
        throw "Erforderlicher Pfad fehlt: $RequiredPath"
    }
}

$Node = Get-Command node -ErrorAction SilentlyContinue
$Npx = Get-Command npx -ErrorAction SilentlyContinue
$Python = Get-Command python -ErrorAction SilentlyContinue

if ($null -eq $Node) { throw "Node.js wurde nicht gefunden." }
if ($null -eq $Npx) { throw "npx wurde nicht gefunden." }
if ($null -eq $Python) { throw "Python wurde nicht gefunden." }

Set-Location $RepositoryRoot

if (-not (Test-Path -LiteralPath ".\node_modules\@playwright\test")) {
    Write-Host "[INFO] Installiere @playwright/test lokal..." -ForegroundColor Cyan
    & $Npx.Source --yes playwright@latest install chromium
    if ($LASTEXITCODE -ne 0) { throw "Chromium-Installation fehlgeschlagen." }

    npm install --save-dev @playwright/test
    if ($LASTEXITCODE -ne 0) { throw "@playwright/test-Installation fehlgeschlagen." }
}
else {
    & $Npx.Source playwright install chromium
    if ($LASTEXITCODE -ne 0) { throw "Chromium-Bereitstellung fehlgeschlagen." }
}

$Server = $null
try {
    $Server = Start-Process `
        -FilePath $Python.Source `
        -ArgumentList @("-m", "http.server", $Port, "--bind", "127.0.0.1", "--directory", $RepositoryRoot) `
        -PassThru `
        -WindowStyle Hidden

    $Ready = $false
    for ($Attempt = 1; $Attempt -le 30; $Attempt++) {
        Start-Sleep -Milliseconds 500
        try {
            $Response = Invoke-WebRequest `
                -Uri "http://127.0.0.1:$Port/products/developer-tools/validators/file/" `
                -TimeoutSec 2 `
                -UseBasicParsing
            if ($Response.StatusCode -eq 200) {
                $Ready = $true
                break
            }
        }
        catch {
            # Server ist eventuell noch nicht bereit.
        }
    }

    if (-not $Ready) {
        throw "Lokaler Testserver wurde nicht rechtzeitig bereit."
    }

    Write-Host "[PASS] Lokaler Testserver ist bereit." -ForegroundColor Green

    & $Npx.Source playwright test "tests/browser/file-validator.spec.js" --config "playwright.config.js"
    $TestExitCode = $LASTEXITCODE

    if ($TestExitCode -ne 0) {
        throw "Automatisierter Browser-Test fehlgeschlagen. Exit-Code: $TestExitCode"
    }

    Write-Host "[PASS] FILE VALIDATOR BROWSER TEST COMPLETE" -ForegroundColor Green
}
finally {
    if ($null -ne $Server -and -not $Server.HasExited) {
        Stop-Process -Id $Server.Id -Force -ErrorAction SilentlyContinue
    }
}
