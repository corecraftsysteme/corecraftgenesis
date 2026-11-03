#Requires -Version 7.0

<#
.SYNOPSIS
    Generiert die gemeinsamen Assets und Datendateien
    fuer den Bitcoin-Mining-Bereich von CoreCraft Genesis.

.DESCRIPTION
    Erzeugt:
      assets\css\bitcoin-mining.css
      assets\js\bitcoin-mining.js
      assets\js\ui.js
      data\capabilities.json
      data\architecture.json
      data\metrics.json

    Die bestehende Hauptseite index.html wird nicht veraendert.

.EXITCODES
    0 = erfolgreich
    1 = Fehler
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\bitcoin-mining"
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

$CssPath = Join-Path $CssDirectory "bitcoin-mining.css"

$MiningJsPath = Join-Path `
    $JsDirectory `
    "bitcoin-mining.js"

$UiJsPath = Join-Path `
    $JsDirectory `
    "ui.js"

$CapabilitiesPath = Join-Path `
    $DataDirectory `
    "capabilities.json"

$ArchitecturePath = Join-Path `
    $DataDirectory `
    "architecture.json"

$MetricsPath = Join-Path `
    $DataDirectory `
    "metrics.json"

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BITCOIN MINING - ASSET GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# PRECHECK
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {

    Write-Host (
        "[FAIL] Bitcoin-Mining-Root fehlt: {0}" -f
        $Root
    ) -ForegroundColor Red

    exit 1
}

Write-Host "[PASS] Bitcoin-Mining-Root vorhanden." -ForegroundColor Green

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {

    Write-Host "[FAIL] Hauptseite fehlt." -ForegroundColor Red

    exit 1
}

$MainHashBefore = (
    Get-FileHash `
        -LiteralPath $MainIndex `
        -Algorithm SHA256
).Hash

Write-Host "[PASS] Hauptseite erkannt und geschuetzt." -ForegroundColor Green

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
    --mining-bg: #05070a;
    --mining-surface: #0c1118;
    --mining-surface-alt: #111924;
    --mining-line: #1d2938;
    --mining-text: #f4f7fb;
    --mining-muted: #95a2b3;
    --mining-orange: #f7931a;
    --mining-orange-soft: rgba(247, 147, 26, 0.10);
    --mining-green: #42d392;
    --mining-green-soft: rgba(66, 211, 146, 0.10);
    --mining-danger: #ef7a7a;
    --mining-warning: #f1c75b;
    --mining-max: 1180px;
    --mining-radius: 14px;
    --mining-shadow: 0 18px 55px rgba(0, 0, 0, 0.24);
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

    background:
        radial-gradient(
            circle at 75% -10%,
            rgba(247, 147, 26, 0.15),
            transparent 30rem
        ),
        var(--mining-bg);

    color: var(--mining-text);
    line-height: 1.6;
}

a {
    color: inherit;
    text-decoration: none;
}

a:hover,
a:focus-visible {
    color: var(--mining-orange);
}

.mining-shell {
    width: min(92%, var(--mining-max));
    margin-inline: auto;
}

.mining-header {
    position: sticky;
    top: 0;
    z-index: 100;

    background: rgba(5, 7, 10, 0.9);

    border-bottom:
        1px solid rgba(255,255,255,0.06);

    backdrop-filter: blur(18px);
}

.mining-nav {
    min-height: 72px;

    display: flex;
    align-items: center;
    justify-content: space-between;

    gap: 2rem;
}

.mining-brand {
    font-size: 1.05rem;
    font-weight: 750;
    letter-spacing: -0.03em;
}

.mining-brand span {
    color: var(--mining-orange);
}

.mining-nav-links {
    display: flex;
    flex-wrap: wrap;
    align-items: center;

    gap: 1.2rem;

    color: var(--mining-muted);
    font-size: 0.9rem;
}

.mining-nav-links a:hover,
.mining-nav-links a[aria-current="page"] {
    color: var(--mining-text);
}

.mining-hero {
    min-height: 560px;

    display: flex;
    flex-direction: column;
    justify-content: center;

    padding: 5rem 0;
}

.mining-eyebrow,
.mining-label {
    color: var(--mining-orange);

    font-size: 0.78rem;
    font-weight: 700;
    letter-spacing: 0.13em;

    text-transform: uppercase;
}

.mining-hero h1 {
    max-width: 900px;

    margin: 0.7rem 0 1.5rem;

    font-size: clamp(3rem, 7vw, 6.5rem);
    line-height: 0.95;
    letter-spacing: -0.055em;
}

.mining-lead {
    max-width: 780px;

    color: var(--mining-muted);
    font-size: 1.08rem;
}

.mining-actions {
    display: flex;
    flex-wrap: wrap;

    gap: 0.75rem;
    margin-top: 2rem;
}

.mining-button {
    min-height: 44px;

    display: inline-flex;
    align-items: center;
    justify-content: center;

    padding: 0.75rem 1rem;

    border: 1px solid var(--mining-orange);
    border-radius: 8px;

    background: var(--mining-orange);
    color: #1b0d00;

    font-weight: 700;
}

.mining-button:hover {
    color: #1b0d00;
    filter: brightness(1.08);
}

.mining-button-secondary {
    background: transparent;
    color: var(--mining-text);
    border-color: var(--mining-line);
}

.mining-button-secondary:hover {
    color: var(--mining-orange);
}

.mining-section {
    padding: 2rem 0 5rem;
}

.mining-section h2 {
    margin: 0.6rem 0 1.2rem;

    font-size: clamp(2rem, 5vw, 3.6rem);
    line-height: 1.05;
    letter-spacing: -0.04em;
}

.mining-grid {
    display: grid;
    grid-template-columns:
        repeat(3, minmax(0, 1fr));

    gap: 1rem;
}

.mining-card {
    min-width: 0;
    padding: 1.5rem;

    background:
        linear-gradient(
            145deg,
            var(--mining-surface),
            var(--mining-surface-alt)
        );

    border: 1px solid var(--mining-line);
    border-radius: var(--mining-radius);

    box-shadow: var(--mining-shadow);

    transition:
        transform 0.2s ease,
        border-color 0.2s ease;
}

.mining-card:hover {
    transform: translateY(-3px);
    border-color: #6f522d;
}

.mining-card h3 {
    margin-top: 1rem;
    margin-bottom: 0.6rem;
}

.mining-card p {
    color: var(--mining-muted);
}

.mining-status {
    display: inline-flex;
    align-items: center;

    padding: 0.32rem 0.65rem;

    color: var(--mining-green);
    background: var(--mining-green-soft);

    border:
        1px solid rgba(66, 211, 146, 0.25);

    border-radius: 999px;

    font-size: 0.76rem;
    font-weight: 700;
}

.mining-list {
    padding-left: 1.2rem;
}

.mining-list li + li {
    margin-top: 0.5rem;
}

.mining-panel {
    padding: 1.5rem;

    background: var(--mining-orange-soft);

    border: 1px solid var(--mining-line);
    border-radius: var(--mining-radius);
}

.mining-metric {
    padding: 1rem 0;

    display: flex;
    justify-content: space-between;

    gap: 1rem;

    border-bottom: 1px solid var(--mining-line);
}

.mining-metric:last-child {
    border-bottom: 0;
}

.mining-metric span:first-child {
    color: var(--mining-muted);
}

.mining-metric span:last-child {
    color: var(--mining-orange);

    font-family:
        "Cascadia Code",
        Consolas,
        monospace;
}

.mining-code {
    overflow-x: auto;

    padding: 1rem;

    background: #030609;

    border: 1px solid var(--mining-line);
    border-radius: 10px;

    color: #ffd7a3;

    font-family:
        "Cascadia Code",
        Consolas,
        monospace;

    font-size: 0.88rem;
}

.mining-footer {
    margin-top: 4rem;
    padding: 2rem 0;

    border-top: 1px solid var(--mining-line);

    color: var(--mining-muted);
}

.mining-hidden {
    display: none !important;
}

@media (max-width: 900px) {

    .mining-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media (max-width: 640px) {

    .mining-nav {
        align-items: flex-start;
        flex-direction: column;

        padding: 1rem 0;
    }

    .mining-nav-links {
        align-items: flex-start;
        flex-direction: column;
    }

    .mining-grid {
        grid-template-columns: 1fr;
    }

    .mining-hero {
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
# BITCOIN-MINING.JS
# ============================================================

$MiningJsContent = @'
"use strict";

window.BitcoinMining = (() => {
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

        return page.length > 0
            ? page
            : "unknown";
    }

    function init(options = {}) {
        if (state.initialized) {
            return getState();
        }

        state.initialized = true;
        state.startedAt =
            new Date().toISOString();

        state.page = normalizePage(
            options.page ||
            document.body.dataset.page
        );

        document.documentElement.dataset.bitcoinMining =
            "ready";

        window.dispatchEvent(
            new CustomEvent(
                "bitcoinmining:ready",
                {
                    detail: getState()
                }
            )
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
            throw new Error(
                "A JSON URL is required."
            );
        }

        const response = await fetch(
            url,
            {
                method: "GET",
                headers: {
                    Accept: "application/json"
                }
            }
        );

        if (!response.ok) {
            throw new Error(
                `Request failed: ${response.status} ${response.statusText}`
            );
        }

        return response.json();
    }

    function emit(name, detail = {}) {
        if (!name) {
            throw new Error(
                "An event name is required."
            );
        }

        window.dispatchEvent(
            new CustomEvent(
                `bitcoinmining:${name}`,
                {
                    detail
                }
            )
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
    -LiteralPath $MiningJsPath `
    -Value $MiningJsContent `
    -Encoding utf8

# ============================================================
# UI.JS
# ============================================================

$UiJsContent = @'
"use strict";

window.BitcoinMiningUI = (() => {
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
            .querySelectorAll("[data-mining-nav]")
            .forEach((link) => {
                const linkPath =
                    normalizePath(
                        new URL(
                            link.href,
                            window.location.origin
                        ).pathname
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
            .querySelectorAll("[data-mining-year]")
            .forEach((element) => {
                element.textContent = year;
            });
    }

    function bindToggles() {
        document
            .querySelectorAll("[data-mining-toggle]")
            .forEach((button) => {
                const selector =
                    button.getAttribute(
                        "data-mining-toggle"
                    );

                if (!selector) {
                    return;
                }

                const target =
                    document.querySelector(selector);

                if (!target) {
                    return;
                }

                button.addEventListener(
                    "click",
                    () => {
                        const hidden =
                            target.classList.toggle(
                                "mining-hidden"
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

        if (window.BitcoinMining) {
            window.BitcoinMining.init({
                page:
                    document.body.dataset.page
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
  "product": "Bitcoin Mining",
  "capabilities": [
    {
      "id": "architecture",
      "name": "Mining Architecture",
      "route": "/products/bitcoin-mining/architecture/",
      "description": "Structural overview of the Bitcoin Mining product area."
    },
    {
      "id": "hardware",
      "name": "Hardware",
      "route": "/products/bitcoin-mining/hardware/",
      "description": "Hardware-oriented mining infrastructure documentation."
    },
    {
      "id": "operations",
      "name": "Operations",
      "route": "/products/bitcoin-mining/operations/",
      "description": "Operational concepts for structured mining environments."
    },
    {
      "id": "energy",
      "name": "Energy",
      "route": "/products/bitcoin-mining/energy/",
      "description": "Energy-oriented metrics and infrastructure concepts."
    },
    {
      "id": "monitoring",
      "name": "Monitoring",
      "route": "/products/bitcoin-mining/monitoring/",
      "description": "Monitoring and observability concepts for mining systems."
    },
    {
      "id": "economics",
      "name": "Economics",
      "route": "/products/bitcoin-mining/economics/",
      "description": "Technical operating metrics and economic model documentation."
    },
    {
      "id": "developer",
      "name": "Developer",
      "route": "/products/bitcoin-mining/developer/",
      "description": "Developer resources for the Bitcoin Mining product area."
    }
  ]
}
'@

Set-Content `
    -LiteralPath $CapabilitiesPath `
    -Value $CapabilitiesContent `
    -Encoding utf8

# ============================================================
# ARCHITECTURE.JSON
# ============================================================

$ArchitectureContent = @'
{
  "schemaVersion": "1.0",
  "product": "Bitcoin Mining",
  "architecture": {
    "areas": [
      {
        "order": 1,
        "id": "architecture",
        "name": "Architecture",
        "route": "/products/bitcoin-mining/architecture/"
      },
      {
        "order": 2,
        "id": "hardware",
        "name": "Hardware",
        "route": "/products/bitcoin-mining/hardware/"
      },
      {
        "order": 3,
        "id": "operations",
        "name": "Operations",
        "route": "/products/bitcoin-mining/operations/"
      },
      {
        "order": 4,
        "id": "energy",
        "name": "Energy",
        "route": "/products/bitcoin-mining/energy/"
      },
      {
        "order": 5,
        "id": "monitoring",
        "name": "Monitoring",
        "route": "/products/bitcoin-mining/monitoring/"
      },
      {
        "order": 6,
        "id": "economics",
        "name": "Economics",
        "route": "/products/bitcoin-mining/economics/"
      },
      {
        "order": 7,
        "id": "developer",
        "name": "Developer",
        "route": "/products/bitcoin-mining/developer/"
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
# METRICS.JSON
# ============================================================

$MetricsContent = @'
{
  "schemaVersion": "1.0",
  "product": "Bitcoin Mining",
  "metrics": [
    {
      "id": "hashrate",
      "name": "Hashrate",
      "unit": "TH/s",
      "category": "performance"
    },
    {
      "id": "power",
      "name": "Power Draw",
      "unit": "W",
      "category": "energy"
    },
    {
      "id": "efficiency",
      "name": "Efficiency",
      "unit": "J/TH",
      "category": "energy"
    },
    {
      "id": "temperature",
      "name": "Temperature",
      "unit": "C",
      "category": "hardware"
    },
    {
      "id": "uptime",
      "name": "Uptime",
      "unit": "percent",
      "category": "operations"
    }
  ]
}
'@

Set-Content `
    -LiteralPath $MetricsPath `
    -Value $MetricsContent `
    -Encoding utf8

# ============================================================
# ASSET VALIDATION
# ============================================================

Write-Host ""
Write-Host "ASSET VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$ExpectedFiles = @(
    "assets\css\bitcoin-mining.css"
    "assets\js\bitcoin-mining.js"
    "assets\js\ui.js"
    "data\capabilities.json"
    "data\architecture.json"
    "data\metrics.json"
)

$FileFailures = @()

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path `
        $Root `
        $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $File = Get-Item -LiteralPath $FullPath

        if ($File.Length -gt 0) {

            Write-Host (
                "[PASS] {0,-42} {1,8} bytes" -f
                $RelativePath,
                $File.Length
            ) -ForegroundColor Green
        }
        else {

            Write-Host (
                "[FAIL] {0} ist leer." -f
                $RelativePath
            ) -ForegroundColor Red

            $FileFailures += $RelativePath
        }
    }
    else {

        Write-Host (
            "[FAIL] {0} fehlt." -f
            $RelativePath
        ) -ForegroundColor Red

        $FileFailures += $RelativePath
    }
}

# ============================================================
# JSON VALIDATION
# ============================================================

Write-Host ""
Write-Host "JSON VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$JsonPaths = @(
    $CapabilitiesPath
    $ArchitecturePath
    $MetricsPath
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
# HAUPTSEITENSCHUTZ
# ============================================================

Write-Host ""
Write-Host "MAIN PAGE PROTECTION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$MainHashAfter = (
    Get-FileHash `
        -LiteralPath $MainIndex `
        -Algorithm SHA256
).Hash

$MainProtected = (
    $MainHashBefore -eq
    $MainHashAfter
)

if ($MainProtected) {

    Write-Host (
        "[PASS] Hauptseite unveraendert."
    ) -ForegroundColor Green
}
else {

    Write-Host (
        "[FAIL] Hauptseite wurde veraendert."
    ) -ForegroundColor Red
}

# ============================================================
# SUMMARY
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
Write-Host " BITCOIN MINING - ASSET SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host (
    "Expected files : {0}" -f
    $ExpectedFiles.Count
)

Write-Host (
    "File failures  : {0}" -f
    $FileFailures.Count
)

Write-Host (
    "JSON files     : {0}" -f
    $JsonPaths.Count
)

Write-Host (
    "JSON failures  : {0}" -f
    $JsonFailures.Count
)

Write-Host (
    "Main protected : {0}" -f
    $MainProtected
)

Write-Host (
    "Total failures : {0}" -f
    $TotalFailures
)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {

    Write-Host (
        "[PASS] BITCOIN MINING ASSET GENERATION COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] BITCOIN MINING ASSET GENERATION FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1
