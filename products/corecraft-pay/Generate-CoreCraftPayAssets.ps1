#Requires -Version 7.0

<#
.SYNOPSIS
    Generiert die gemeinsamen Assets und Datendateien
    fuer CoreCraft Pay.

.DESCRIPTION
    Erzeugt:
      assets\css\corecraft-pay.css
      assets\js\corecraft-pay.js
      assets\js\ui.js
      data\capabilities.json
      data\integrations.json
      data\architecture.json

    Die bestehende Hauptseite wird nicht veraendert.

.EXITCODES
    0 = erfolgreich
    1 = Fehler
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\corecraft-pay"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# PFADE
# ============================================================

$MainIndex = Join-Path $Root "index.html"

$CssDirectory = Join-Path $Root "assets\css"
$JsDirectory = Join-Path $Root "assets\js"
$DataDirectory = Join-Path $Root "data"

$CssPath = Join-Path $CssDirectory "corecraft-pay.css"
$CoreJsPath = Join-Path $JsDirectory "corecraft-pay.js"
$UiJsPath = Join-Path $JsDirectory "ui.js"

$CapabilitiesPath = Join-Path $DataDirectory "capabilities.json"
$IntegrationsPath = Join-Path $DataDirectory "integrations.json"
$ArchitecturePath = Join-Path $DataDirectory "architecture.json"

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT PAY - ASSET GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# PRECHECK
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] CoreCraft-Pay-Root fehlt." -ForegroundColor Red
    exit 1
}

Write-Host "[PASS] CoreCraft-Pay-Root vorhanden." -ForegroundColor Green

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    Write-Host "[FAIL] Hauptseite fehlt." -ForegroundColor Red
    exit 1
}

$MainHashBefore = (
    Get-FileHash -LiteralPath $MainIndex -Algorithm SHA256
).Hash

Write-Host "[PASS] Hauptseite erkannt und geschützt." -ForegroundColor Green

foreach ($Directory in @(
    $CssDirectory
    $JsDirectory
    $DataDirectory
)) {
    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        New-Item `
            -ItemType Directory `
            -Path $Directory `
            -Force |
            Out-Null
    }
}

Write-Host "[PASS] Zielverzeichnisse vorhanden." -ForegroundColor Green

# ============================================================
# CSS
# ============================================================

$CssContent = @'
:root {
    --pay-bg: #05070a;
    --pay-surface: #0c1118;
    --pay-surface-alt: #111924;
    --pay-line: #1d2938;
    --pay-text: #f4f7fb;
    --pay-muted: #95a2b3;
    --pay-blue: #4ea1ff;
    --pay-green: #42d392;
    --pay-blue-soft: rgba(78, 161, 255, 0.10);
    --pay-green-soft: rgba(66, 211, 146, 0.10);
    --pay-danger: #ef7a7a;
    --pay-warning: #f1c75b;
    --pay-max: 1180px;
    --pay-radius: 14px;
    --pay-shadow: 0 18px 55px rgba(0, 0, 0, 0.24);
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    margin: 0;

    font-family:
        Inter,
        ui-sans-serif,
        system-ui,
        -apple-system,
        BlinkMacSystemFont,
        "Segoe UI",
        sans-serif;

    color: var(--pay-text);
    line-height: 1.6;

    background:
        radial-gradient(
            circle at 75% -10%,
            rgba(78, 161, 255, 0.16),
            transparent 30rem
        ),
        var(--pay-bg);
}

a {
    color: inherit;
    text-decoration: none;
}

a:hover,
a:focus-visible {
    color: var(--pay-blue);
}

.pay-shell {
    width: min(92%, var(--pay-max));
    margin-inline: auto;
}

.pay-header {
    position: sticky;
    top: 0;
    z-index: 100;

    background: rgba(5, 7, 10, 0.9);
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);

    backdrop-filter: blur(18px);
}

.pay-nav {
    min-height: 72px;

    display: flex;
    align-items: center;
    justify-content: space-between;

    gap: 2rem;
}

.pay-brand {
    font-size: 1.05rem;
    font-weight: 750;
    letter-spacing: -0.03em;
}

.pay-brand span {
    color: var(--pay-blue);
}

.pay-nav-links {
    display: flex;
    flex-wrap: wrap;
    align-items: center;

    gap: 1.2rem;

    color: var(--pay-muted);
    font-size: 0.9rem;
}

.pay-nav-links a:hover,
.pay-nav-links a[aria-current="page"] {
    color: var(--pay-text);
}

.pay-hero {
    min-height: 560px;

    display: flex;
    flex-direction: column;
    justify-content: center;

    padding: 5rem 0;
}

.pay-eyebrow,
.pay-label {
    color: var(--pay-blue);

    font-size: 0.78rem;
    font-weight: 700;
    letter-spacing: 0.13em;

    text-transform: uppercase;
}

.pay-hero h1 {
    max-width: 900px;

    margin: 0.7rem 0 1.5rem;

    font-size: clamp(3rem, 7vw, 6.5rem);
    line-height: 0.95;
    letter-spacing: -0.055em;
}

.pay-lead {
    max-width: 760px;

    color: var(--pay-muted);
    font-size: 1.08rem;
}

.pay-actions {
    display: flex;
    flex-wrap: wrap;

    gap: 0.75rem;
    margin-top: 2rem;
}

.pay-button {
    min-height: 44px;

    display: inline-flex;
    align-items: center;
    justify-content: center;

    padding: 0.75rem 1rem;

    border: 1px solid var(--pay-blue);
    border-radius: 8px;

    background: var(--pay-blue);
    color: #001326;

    font-weight: 700;
}

.pay-button:hover {
    color: #001326;
    filter: brightness(1.08);
}

.pay-button-secondary {
    background: transparent;
    color: var(--pay-text);
    border-color: var(--pay-line);
}

.pay-button-secondary:hover {
    color: var(--pay-blue);
}

.pay-section {
    padding: 2rem 0 5rem;
}

.pay-section h2 {
    margin: 0.6rem 0 1.2rem;

    font-size: clamp(2rem, 5vw, 3.6rem);
    line-height: 1.05;
    letter-spacing: -0.04em;
}

.pay-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));

    gap: 1rem;
}

.pay-card {
    min-width: 0;

    padding: 1.5rem;

    background:
        linear-gradient(
            145deg,
            var(--pay-surface),
            var(--pay-surface-alt)
        );

    border: 1px solid var(--pay-line);
    border-radius: var(--pay-radius);

    box-shadow: var(--pay-shadow);

    transition:
        transform 0.2s ease,
        border-color 0.2s ease;
}

.pay-card:hover {
    transform: translateY(-3px);
    border-color: #395979;
}

.pay-card h3 {
    margin-top: 1rem;
    margin-bottom: 0.6rem;
}

.pay-card p {
    color: var(--pay-muted);
}

.pay-status {
    display: inline-flex;
    align-items: center;

    padding: 0.32rem 0.65rem;

    color: var(--pay-green);
    background: var(--pay-green-soft);

    border: 1px solid rgba(66, 211, 146, 0.25);
    border-radius: 999px;

    font-size: 0.76rem;
    font-weight: 700;
}

.pay-list {
    padding-left: 1.2rem;
}

.pay-list li + li {
    margin-top: 0.5rem;
}

.pay-panel {
    padding: 1.5rem;

    background: var(--pay-blue-soft);
    border: 1px solid var(--pay-line);
    border-radius: var(--pay-radius);
}

.pay-code {
    overflow-x: auto;

    padding: 1rem;

    background: #030609;
    border: 1px solid var(--pay-line);
    border-radius: 10px;

    color: #cce5ff;

    font-family:
        "Cascadia Code",
        Consolas,
        monospace;

    font-size: 0.88rem;
}

.pay-footer {
    margin-top: 4rem;
    padding: 2rem 0;

    border-top: 1px solid var(--pay-line);

    color: var(--pay-muted);
}

.pay-hidden {
    display: none !important;
}

@media (max-width: 900px) {
    .pay-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media (max-width: 640px) {
    .pay-nav {
        align-items: flex-start;
        flex-direction: column;

        padding: 1rem 0;
    }

    .pay-nav-links {
        align-items: flex-start;
        flex-direction: column;
    }

    .pay-grid {
        grid-template-columns: 1fr;
    }

    .pay-hero {
        min-height: auto;
        padding-top: 4rem;
    }
}
'@

Set-Content `
    -LiteralPath $CssPath `
    -Value $CssContent `
    -Encoding utf8

# ============================================================
# CORECRAFT-PAY.JS
# ============================================================

$CoreJsContent = @'
"use strict";

window.CoreCraftPay = (() => {
    const VERSION = "1.0.0";

    const state = {
        initialized: false,
        startedAt: null,
        page: null
    };

    function normalizePage(value) {
        if (typeof value !== "string") {
            return "unknown";
        }

        const page = value.trim().toLowerCase();

        return page.length > 0 ? page : "unknown";
    }

    function init(options = {}) {
        if (state.initialized) {
            return getState();
        }

        state.initialized = true;
        state.startedAt = new Date().toISOString();
        state.page = normalizePage(
            options.page || document.body.dataset.page
        );

        document.documentElement.dataset.corecraftPay = "ready";

        window.dispatchEvent(
            new CustomEvent("corecraftpay:ready", {
                detail: getState()
            })
        );

        return getState();
    }

    function getState() {
        return Object.freeze({
            initialized: state.initialized,
            startedAt: state.startedAt,
            page: state.page,
            version: VERSION
        });
    }

    async function loadJson(url) {
        if (!url) {
            throw new Error("A JSON URL is required.");
        }

        const response = await fetch(url, {
            method: "GET",
            headers: {
                Accept: "application/json"
            }
        });

        if (!response.ok) {
            throw new Error(
                `Request failed: ${response.status} ${response.statusText}`
            );
        }

        return response.json();
    }

    function emit(name, detail = {}) {
        if (!name) {
            throw new Error("An event name is required.");
        }

        window.dispatchEvent(
            new CustomEvent(`corecraftpay:${name}`, {
                detail
            })
        );
    }

    return Object.freeze({
        version: VERSION,
        init,
        getState,
        loadJson,
        emit
    });
})();
'@

Set-Content `
    -LiteralPath $CoreJsPath `
    -Value $CoreJsContent `
    -Encoding utf8

# ============================================================
# UI.JS
# ============================================================

$UiJsContent = @'
"use strict";

window.CoreCraftPayUI = (() => {
    function normalizePath(path) {
        if (!path) {
            return "/";
        }

        return path.replace(/\/+$/, "") + "/";
    }

    function setCurrentNavigation() {
        const currentPath = normalizePath(
            window.location.pathname
        );

        document
            .querySelectorAll("[data-pay-nav]")
            .forEach((link) => {
                const linkPath = normalizePath(
                    new URL(link.href, window.location.origin).pathname
                );

                if (linkPath === currentPath) {
                    link.setAttribute(
                        "aria-current",
                        "page"
                    );
                } else {
                    link.removeAttribute(
                        "aria-current"
                    );
                }
            });
    }

    function updateYear() {
        const year = String(
            new Date().getFullYear()
        );

        document
            .querySelectorAll("[data-pay-year]")
            .forEach((element) => {
                element.textContent = year;
            });
    }

    function bindToggles() {
        document
            .querySelectorAll("[data-pay-toggle]")
            .forEach((button) => {
                const selector = button.getAttribute(
                    "data-pay-toggle"
                );

                if (!selector) {
                    return;
                }

                const target = document.querySelector(
                    selector
                );

                if (!target) {
                    return;
                }

                button.addEventListener(
                    "click",
                    () => {
                        const hidden =
                            target.classList.toggle(
                                "pay-hidden"
                            );

                        button.setAttribute(
                            "aria-expanded",
                            String(!hidden)
                        );
                    }
                );
            });
    }

    function init() {
        setCurrentNavigation();
        updateYear();
        bindToggles();

        if (window.CoreCraftPay) {
            window.CoreCraftPay.init({
                page: document.body.dataset.page
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener(
            "DOMContentLoaded",
            init,
            {
                once: true
            }
        );
    } else {
        init();
    }

    return Object.freeze({
        init,
        setCurrentNavigation
    });
})();
'@

Set-Content `
    -LiteralPath $UiJsPath `
    -Value $UiJsContent `
    -Encoding utf8

# ============================================================
# CAPABILITIES.JSON
# ============================================================

$CapabilitiesContent = @'
{
  "schemaVersion": "1.0",
  "product": "CoreCraft Pay",
  "capabilities": [
    {
      "id": "architecture",
      "name": "Payment Architecture",
      "route": "/products/corecraft-pay/architecture/",
      "description": "Structural product area for CoreCraft Pay architecture."
    },
    {
      "id": "payments",
      "name": "Payments",
      "route": "/products/corecraft-pay/payments/",
      "description": "Product area for payment-oriented workflows and concepts."
    },
    {
      "id": "checkout",
      "name": "Checkout",
      "route": "/products/corecraft-pay/checkout/",
      "description": "Product area for checkout-oriented user flows."
    },
    {
      "id": "integrations",
      "name": "Integrations",
      "route": "/products/corecraft-pay/integrations/",
      "description": "Product area for integration-oriented documentation."
    },
    {
      "id": "security",
      "name": "Security",
      "route": "/products/corecraft-pay/security/",
      "description": "Product area for security architecture and operational controls."
    },
    {
      "id": "developer",
      "name": "Developer",
      "route": "/products/corecraft-pay/developer/",
      "description": "Developer resources for the CoreCraft Pay product area."
    },
    {
      "id": "demos",
      "name": "Demos",
      "route": "/products/corecraft-pay/demos/",
      "description": "Demonstrations and examples for CoreCraft Pay."
    }
  ]
}
'@

Set-Content `
    -LiteralPath $CapabilitiesPath `
    -Value $CapabilitiesContent `
    -Encoding utf8

# ============================================================
# INTEGRATIONS.JSON
# ============================================================

$IntegrationsContent = @'
{
  "schemaVersion": "1.0",
  "product": "CoreCraft Pay",
  "integrations": [
    {
      "id": "web-checkout",
      "name": "Web Checkout",
      "category": "checkout",
      "status": "documented"
    },
    {
      "id": "payment-interface",
      "name": "Payment Interface",
      "category": "payments",
      "status": "documented"
    },
    {
      "id": "developer-interface",
      "name": "Developer Interface",
      "category": "developer",
      "status": "documented"
    },
    {
      "id": "event-model",
      "name": "Event Model",
      "category": "integration",
      "status": "documented"
    }
  ]
}
'@

Set-Content `
    -LiteralPath $IntegrationsPath `
    -Value $IntegrationsContent `
    -Encoding utf8

# ============================================================
# ARCHITECTURE.JSON
# ============================================================

$ArchitectureContent = @'
{
  "schemaVersion": "1.0",
  "product": "CoreCraft Pay",
  "architecture": {
    "areas": [
      {
        "order": 1,
        "id": "architecture",
        "name": "Architecture",
        "route": "/products/corecraft-pay/architecture/"
      },
      {
        "order": 2,
        "id": "payments",
        "name": "Payments",
        "route": "/products/corecraft-pay/payments/"
      },
      {
        "order": 3,
        "id": "checkout",
        "name": "Checkout",
        "route": "/products/corecraft-pay/checkout/"
      },
      {
        "order": 4,
        "id": "integrations",
        "name": "Integrations",
        "route": "/products/corecraft-pay/integrations/"
      },
      {
        "order": 5,
        "id": "security",
        "name": "Security",
        "route": "/products/corecraft-pay/security/"
      },
      {
        "order": 6,
        "id": "developer",
        "name": "Developer",
        "route": "/products/corecraft-pay/developer/"
      },
      {
        "order": 7,
        "id": "demos",
        "name": "Demos",
        "route": "/products/corecraft-pay/demos/"
      }
    ]
  }
}
'@

Set-Content `
    -LiteralPath $ArchitecturePath `
    -Value $ArchitectureContent `
    -Encoding utf8

# ============================================================
# DATEIVALIDIERUNG
# ============================================================

Write-Host ""
Write-Host "ASSET VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$ExpectedFiles = @(
    "assets\css\corecraft-pay.css"
    "assets\js\corecraft-pay.js"
    "assets\js\ui.js"
    "data\capabilities.json"
    "data\integrations.json"
    "data\architecture.json"
)

$FileFailures = @()

foreach ($RelativePath in $ExpectedFiles) {
    $FullPath = Join-Path $Root $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {
        $File = Get-Item -LiteralPath $FullPath

        if ($File.Length -gt 0) {
            Write-Host (
                "[PASS] {0,-40} {1,8} bytes" -f
                $RelativePath,
                $File.Length
            ) -ForegroundColor Green
        } else {
            Write-Host (
                "[FAIL] {0} ist leer." -f
                $RelativePath
            ) -ForegroundColor Red

            $FileFailures += $RelativePath
        }
    } else {
        Write-Host (
            "[FAIL] {0} fehlt." -f
            $RelativePath
        ) -ForegroundColor Red

        $FileFailures += $RelativePath
    }
}

# ============================================================
# JSON VALIDIERUNG
# ============================================================

Write-Host ""
Write-Host "JSON VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$JsonPaths = @(
    $CapabilitiesPath
    $IntegrationsPath
    $ArchitecturePath
)

$JsonFailures = @()

foreach ($JsonPath in $JsonPaths) {
    try {
        $RawJson = Get-Content `
            -LiteralPath $JsonPath `
            -Raw `
            -ErrorAction Stop

        if ([string]::IsNullOrWhiteSpace($RawJson)) {
            throw "JSON-Datei ist leer."
        }

        $null = $RawJson |
            ConvertFrom-Json `
                -ErrorAction Stop

        Write-Host (
            "[PASS] {0}" -f
            (Split-Path $JsonPath -Leaf)
        ) -ForegroundColor Green
    }
    catch {
        Write-Host (
            "[FAIL] {0}: {1}" -f
            (Split-Path $JsonPath -Leaf),
            $_.Exception.Message
        ) -ForegroundColor Red

        $JsonFailures += $JsonPath
    }
}

# ============================================================
# HAUPTSEITE SCHUTZPRUEFUNG
# ============================================================

Write-Host ""
Write-Host "MAIN PAGE PROTECTION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$MainHashAfter = (
    Get-FileHash -LiteralPath $MainIndex -Algorithm SHA256
).Hash

$MainProtected = (
    $MainHashBefore -eq $MainHashAfter
)

if ($MainProtected) {
    Write-Host "[PASS] Hauptseite unveraendert." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Hauptseite wurde veraendert." -ForegroundColor Red
}

# ============================================================
# FINAL SUMMARY
# ============================================================

$TotalFailures = (
    $FileFailures.Count +
    $JsonFailures.Count
)

if (-not $MainProtected) {
    $TotalFailures++
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT PAY - ASSET SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Expected files : {0}" -f $ExpectedFiles.Count)
Write-Host ("File failures  : {0}" -f $FileFailures.Count)
Write-Host ("JSON files     : {0}" -f $JsonPaths.Count)
Write-Host ("JSON failures  : {0}" -f $JsonFailures.Count)
Write-Host ("Main protected : {0}" -f $MainProtected)
Write-Host ("Total failures : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {
    Write-Host (
        "[PASS] CORECRAFT PAY ASSET GENERATION COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] CORECRAFT PAY ASSET GENERATION FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1

