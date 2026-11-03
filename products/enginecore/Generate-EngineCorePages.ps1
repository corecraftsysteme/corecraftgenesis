#Requires -Version 7.0

<#
.SYNOPSIS
    Generiert die sieben CoreCraft Genesis EngineCore-Unterseiten.

.DESCRIPTION
    Erzeugt:
      architecture\index.html
      runtime\index.html
      modules\index.html
      validation\index.html
      diagnostics\index.html
      developer\index.html
      demos\index.html

    Die bestehende EngineCore-Hauptseite wird nicht veraendert.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = "C:\corecraftgenesis-github\products\enginecore"

# ============================================================
# KONFIGURATION
# ============================================================

$Pages = @(
    [pscustomobject]@{
        Id = "architecture"
        Title = "EngineCore Architecture"
        Eyebrow = "Architecture"
        Lead = "Explore the structural model behind EngineCore and its modular product architecture."
        Description = "Structural overview of EngineCore, its layers, responsibilities and product boundaries."
        Points = @(
            "Defined architectural layers"
            "Explicit component boundaries"
            "Modular product structure"
            "Clear interfaces between EngineCore areas"
        )
    },
    [pscustomobject]@{
        Id = "runtime"
        Title = "EngineCore Runtime"
        Eyebrow = "Runtime"
        Lead = "Explore the EngineCore runtime layer and its execution-oriented product model."
        Description = "Runtime concepts, lifecycle organization and execution-oriented EngineCore components."
        Points = @(
            "Runtime-oriented architecture"
            "Defined execution lifecycle"
            "State-aware processing model"
            "Structured runtime responsibilities"
        )
    },
    [pscustomobject]@{
        Id = "modules"
        Title = "EngineCore Modules"
        Eyebrow = "Modules"
        Lead = "Explore EngineCore as a modular system composed of clearly separated technical areas."
        Description = "Overview of the modular EngineCore structure and its independently defined product areas."
        Points = @(
            "Modular component model"
            "Explicit module responsibilities"
            "Independent product areas"
            "Consistent integration structure"
        )
    },
    [pscustomobject]@{
        Id = "validation"
        Title = "EngineCore Validation"
        Eyebrow = "Validation"
        Lead = "Validation provides a dedicated EngineCore area for integrity and consistency controls."
        Description = "EngineCore validation concepts for structured integrity, consistency and controlled verification."
        Points = @(
            "Structured validation model"
            "Integrity-oriented controls"
            "Consistent verification boundaries"
            "Deterministic validation concepts"
        )
    },
    [pscustomobject]@{
        Id = "diagnostics"
        Title = "EngineCore Diagnostics"
        Eyebrow = "Diagnostics"
        Lead = "Diagnostics provides visibility into EngineCore state, behavior and technical operation."
        Description = "Diagnostic and observability concepts for understanding EngineCore operation."
        Points = @(
            "Operational visibility"
            "State inspection"
            "Diagnostic information"
            "Structured observability"
        )
    },
    [pscustomobject]@{
        Id = "developer"
        Title = "EngineCore Developer"
        Eyebrow = "Developer"
        Lead = "Technical resources for developers building with and around the EngineCore product structure."
        Description = "Developer-oriented information for understanding EngineCore modules, data and integration surfaces."
        Points = @(
            "Developer-oriented architecture"
            "Shared EngineCore assets"
            "Structured JSON data"
            "Consistent module routes"
        )
    },
    [pscustomobject]@{
        Id = "demos"
        Title = "EngineCore Demos"
        Eyebrow = "Demos"
        Lead = "Explore demonstrations and examples based on the EngineCore product architecture."
        Description = "A dedicated product area for EngineCore demonstrations, examples and future interactive scenarios."
        Points = @(
            "EngineCore demonstrations"
            "Architecture examples"
            "Runtime examples"
            "Expandable demonstration environment"
        )
    }
)

# ============================================================
# ROOT VALIDIEREN
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - ENGINECORE PAGE GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    throw "EngineCore-Root nicht gefunden: $Root"
}

$MainIndex = Join-Path $Root "index.html"

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    throw "EngineCore-Hauptseite fehlt: $MainIndex"
}

$MainIndexLength = (Get-Item -LiteralPath $MainIndex).Length

Write-Host (
    "[PASS] Bestehende Hauptseite erkannt ({0} Bytes)." -f
    $MainIndexLength
) -ForegroundColor Green

# ============================================================
# ERFORDERLICHE ASSETS PRUEFEN
# ============================================================

$RequiredAssets = @(
    "assets\css\enginecore.css"
    "assets\js\enginecore.js"
    "assets\js\ui.js"
    "data\modules.json"
    "data\capabilities.json"
    "data\architecture.json"
)

Write-Host ""
Write-Host "ASSET PRECHECK" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$AssetFailures = @()

foreach ($RelativePath in $RequiredAssets) {

    $FullPath = Join-Path $Root $RelativePath

    if (
        (Test-Path -LiteralPath $FullPath -PathType Leaf) -and
        ((Get-Item -LiteralPath $FullPath).Length -gt 0)
    ) {
        Write-Host (
            "[PASS] {0}" -f $RelativePath
        ) -ForegroundColor Green
    }
    else {
        Write-Host (
            "[FAIL] {0}" -f $RelativePath
        ) -ForegroundColor Red

        $AssetFailures += $RelativePath
    }
}

if ($AssetFailures.Count -gt 0) {
    throw "EngineCore Asset-Precheck fehlgeschlagen."
}

# ============================================================
# NAVIGATION
# ============================================================

$Navigation = @'
<nav class="ec-nav" aria-label="EngineCore Navigation">
    <a class="ec-brand" href="/products/enginecore/">EngineCore</a>

    <div class="ec-nav-links">
        <a data-ec-nav href="/products/enginecore/architecture/">Architecture</a>
        <a data-ec-nav href="/products/enginecore/runtime/">Runtime</a>
        <a data-ec-nav href="/products/enginecore/modules/">Modules</a>
        <a data-ec-nav href="/products/enginecore/validation/">Validation</a>
        <a data-ec-nav href="/products/enginecore/diagnostics/">Diagnostics</a>
        <a data-ec-nav href="/products/enginecore/developer/">Developer</a>
        <a data-ec-nav href="/products/enginecore/demos/">Demos</a>
    </div>
</nav>
'@

# ============================================================
# SEITEN GENERIEREN
# ============================================================

Write-Host ""
Write-Host "PAGE GENERATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$GenerationResults = @()

foreach ($Page in $Pages) {

    $Directory = Join-Path $Root $Page.Id
    $OutputPath = Join-Path $Directory "index.html"

    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        New-Item `
            -ItemType Directory `
            -Path $Directory `
            -Force |
            Out-Null
    }

    $ListItems = (
        $Page.Points |
        ForEach-Object {
            "                    <li>$_</li>"
        }
    ) -join [Environment]::NewLine

    $Html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>$($Page.Title) | CoreCraft Genesis</title>

    <meta
        name="description"
        content="$($Page.Description)"
    >

    <link
        rel="stylesheet"
        href="/products/enginecore/assets/css/enginecore.css"
    >
</head>

<body data-page="$($Page.Id)">

<header class="ec-header">
    <div class="ec-shell">
$Navigation
    </div>
</header>

<main>

    <section class="ec-hero">
        <div class="ec-shell">

            <div class="ec-eyebrow">
                EngineCore / $($Page.Eyebrow)
            </div>

            <h1>$($Page.Title)</h1>

            <p class="ec-lead">
                $($Page.Lead)
            </p>

            <div class="ec-actions">
                <a
                    class="ec-button"
                    href="/products/enginecore/"
                >
                    EngineCore Overview
                </a>

                <a
                    class="ec-button ec-button-secondary"
                    href="/products/"
                >
                    All Products
                </a>
            </div>

        </div>
    </section>

    <section class="ec-section">
        <div class="ec-shell">

            <div class="ec-grid">

                <article class="ec-card">

                    <span class="ec-status">
                        EngineCore
                    </span>

                    <h2>$($Page.Eyebrow)</h2>

                    <p>
                        $($Page.Description)
                    </p>

                </article>

                <article class="ec-card">

                    <h2>Core Concepts</h2>

                    <ul class="ec-list">
$ListItems
                    </ul>

                </article>

                <article class="ec-card">

                    <h2>Product Architecture</h2>

                    <p>
                        This area is part of the shared EngineCore
                        product structure and uses the same navigation,
                        styling and technical assets as the other
                        EngineCore modules.
                    </p>

                </article>

            </div>

        </div>
    </section>

    <section class="ec-section">
        <div class="ec-shell">

            <div class="ec-card">

                <h2>EngineCore Areas</h2>

                <div class="ec-nav-links">

                    <a href="/products/enginecore/architecture/">
                        Architecture
                    </a>

                    <a href="/products/enginecore/runtime/">
                        Runtime
                    </a>

                    <a href="/products/enginecore/modules/">
                        Modules
                    </a>

                    <a href="/products/enginecore/validation/">
                        Validation
                    </a>

                    <a href="/products/enginecore/diagnostics/">
                        Diagnostics
                    </a>

                    <a href="/products/enginecore/developer/">
                        Developer
                    </a>

                    <a href="/products/enginecore/demos/">
                        Demos
                    </a>

                </div>

            </div>

        </div>
    </section>

</main>

<footer class="ec-footer">
    <div class="ec-shell">

        <p>
            &copy;
            <span data-ec-year></span>
            CoreCraft Genesis.
            EngineCore technical product environment.
        </p>

    </div>
</footer>

<script src="/products/enginecore/assets/js/enginecore.js"></script>
<script src="/products/enginecore/assets/js/ui.js"></script>

</body>
</html>
"@

    Set-Content `
        -LiteralPath $OutputPath `
        -Value $Html `
        -Encoding utf8

    $WrittenFile = Get-Item -LiteralPath $OutputPath

    $GenerationResults += [pscustomobject]@{
        Page  = $Page.Id
        Path  = $OutputPath
        Bytes = $WrittenFile.Length
    }

    Write-Host (
        "[CREATE] {0,-24} {1,8} bytes" -f
        ($Page.Id + "\index.html"),
        $WrittenFile.Length
    ) -ForegroundColor Green
}

# ============================================================
# VALIDIERUNG
# ============================================================

Write-Host ""
Write-Host "PAGE VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$ValidationResults = @()

foreach ($Page in $Pages) {

    $RelativePath = "$($Page.Id)\index.html"
    $FullPath = Join-Path $Root $RelativePath

    $Status = "PASS"
    $Message = "OK"

    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
        $Status = "FAIL"
        $Message = "Datei fehlt"
    }
    else {

        $File = Get-Item -LiteralPath $FullPath

        if ($File.Length -eq 0) {
            $Status = "FAIL"
            $Message = "Datei ist leer"
        }
        else {

            $Content = Get-Content `
                -LiteralPath $FullPath `
                -Raw

            if ($Content -notmatch '<!DOCTYPE html>') {
                $Status = "FAIL"
                $Message = "DOCTYPE fehlt"
            }

            if ($Content -notmatch '<title>') {
                $Status = "FAIL"
                $Message = "Title fehlt"
            }

            if (
                $Content -notmatch
                '/products/enginecore/assets/css/enginecore\.css'
            ) {
                $Status = "FAIL"
                $Message = "CSS-Verweis fehlt"
            }

            if (
                $Content -notmatch
                '/products/enginecore/assets/js/enginecore\.js'
            ) {
                $Status = "FAIL"
                $Message = "enginecore.js-Verweis fehlt"
            }

            if (
                $Content -notmatch
                '/products/enginecore/assets/js/ui\.js'
            ) {
                $Status = "FAIL"
                $Message = "ui.js-Verweis fehlt"
            }
        }
    }

    $ValidationResults += [pscustomobject]@{
        Status  = $Status
        Page    = $RelativePath
        Message = $Message
    }

    $Color = if ($Status -eq "PASS") {
        "Green"
    }
    else {
        "Red"
    }

    Write-Host (
        "[{0}] {1,-30} {2}" -f
        $Status,
        $RelativePath,
        $Message
    ) -ForegroundColor $Color
}

# ============================================================
# HAUPTSEITE SCHUTZPRUEFUNG
# ============================================================

Write-Host ""
Write-Host "MAIN PAGE PROTECTION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$MainIndexLengthAfter = (
    Get-Item -LiteralPath $MainIndex
).Length

$MainIndexProtected = (
    $MainIndexLengthAfter -eq $MainIndexLength
)

if ($MainIndexProtected) {

    Write-Host (
        "[PASS] Hauptseite unveraendert ({0} Bytes)." -f
        $MainIndexLengthAfter
    ) -ForegroundColor Green
}
else {

    Write-Host (
        "[FAIL] Groesse der Hauptseite hat sich veraendert."
    ) -ForegroundColor Red
}

# ============================================================
# SUMMARY
# ============================================================

$Failures = @(
    $ValidationResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

$TotalFailures = $Failures.Count

if (-not $MainIndexProtected) {
    $TotalFailures++
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ENGINECORE PAGE GENERATION SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Pages expected : {0}" -f $Pages.Count)
Write-Host ("Pages generated: {0}" -f $GenerationResults.Count)
Write-Host ("Pages passed   : {0}" -f ($Pages.Count - $Failures.Count))
Write-Host ("Pages failed   : {0}" -f $Failures.Count)
Write-Host ("Main protected : {0}" -f $MainIndexProtected)
Write-Host ("Total failures : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host "[PASS] ENGINECORE PAGE GENERATION COMPLETE" -ForegroundColor Green
    Write-Host "============================================================"

    exit 0
}

Write-Host "[FAIL] ENGINECORE PAGE GENERATION FAILED" -ForegroundColor Red
Write-Host "============================================================"

exit 1
