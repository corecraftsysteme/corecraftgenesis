#Requires -Version 7.0

<#
.SYNOPSIS
    Generiert die gemeinsamen Assets und Datendateien
    fuer CoreCraft Genesis EngineCore.

.DESCRIPTION
    Erzeugt:
      assets\css\enginecore.css
      assets\js\enginecore.js
      assets\js\ui.js
      data\modules.json
      data\capabilities.json
      data\architecture.json

    Anschliessend werden Existenz, Dateigroesse
    und JSON-Syntax validiert.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = "C:\corecraftgenesis-github\products\enginecore"

$CssDirectory  = Join-Path $Root "assets\css"
$JsDirectory   = Join-Path $Root "assets\js"
$DataDirectory = Join-Path $Root "data"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - ENGINECORE ASSET GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# ROOT UND VERZEICHNISSE
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    throw "EngineCore-Root nicht gefunden: $Root"
}

foreach ($Directory in @(
    $CssDirectory
    $JsDirectory
    $DataDirectory
)) {
    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
}

Write-Host "[PASS] Zielverzeichnisse vorhanden." -ForegroundColor Green

# ============================================================
# 1. ENGINECORE.CSS
# ============================================================

$CssPath = Join-Path $CssDirectory "enginecore.css"

$CssContent = @'
:root {
    --ec-bg: #071018;
    --ec-surface: #0d1822;
    --ec-surface-alt: #111f2b;
    --ec-border: #243746;
    --ec-text: #eef5f8;
    --ec-muted: #9eb0bd;
    --ec-accent: #50d8c8;
    --ec-accent-soft: rgba(80, 216, 200, 0.12);
    --ec-success: #62d394;
    --ec-warning: #f1c75b;
    --ec-danger: #ef7a7a;
    --ec-max-width: 1180px;
    --ec-radius: 12px;
    --ec-shadow: 0 18px 50px rgba(0, 0, 0, 0.22);
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    margin: 0;
    background:
        radial-gradient(circle at top right, rgba(80, 216, 200, 0.08), transparent 30rem),
        var(--ec-bg);
    color: var(--ec-text);
    font-family:
        Inter,
        "Segoe UI",
        Arial,
        sans-serif;
    line-height: 1.6;
}

a {
    color: var(--ec-accent);
    text-decoration: none;
}

a:hover,
a:focus-visible {
    text-decoration: underline;
}

img {
    max-width: 100%;
}

.ec-shell {
    width: min(calc(100% - 2rem), var(--ec-max-width));
    margin-inline: auto;
}

.ec-header {
    position: sticky;
    top: 0;
    z-index: 50;
    background: rgba(7, 16, 24, 0.94);
    border-bottom: 1px solid var(--ec-border);
    backdrop-filter: blur(14px);
}

.ec-nav {
    min-height: 68px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1.5rem;
}

.ec-brand {
    color: var(--ec-text);
    font-weight: 750;
    letter-spacing: 0.02em;
}

.ec-nav-links {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 1rem;
}

.ec-nav-links a {
    color: var(--ec-muted);
}

.ec-nav-links a:hover,
.ec-nav-links a[aria-current="page"] {
    color: var(--ec-text);
}

.ec-hero {
    padding: 6rem 0 4rem;
}

.ec-eyebrow {
    color: var(--ec-accent);
    font-size: 0.82rem;
    font-weight: 700;
    letter-spacing: 0.14em;
    text-transform: uppercase;
}

.ec-hero h1 {
    max-width: 850px;
    margin: 0.5rem 0 1rem;
    font-size: clamp(2.4rem, 6vw, 5rem);
    line-height: 1.04;
    letter-spacing: -0.045em;
}

.ec-lead {
    max-width: 780px;
    color: var(--ec-muted);
    font-size: 1.16rem;
}

.ec-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
    margin-top: 2rem;
}

.ec-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 44px;
    padding: 0.7rem 1rem;
    border: 1px solid var(--ec-accent);
    border-radius: 8px;
    background: var(--ec-accent);
    color: #04110f;
    font-weight: 700;
    cursor: pointer;
}

.ec-button:hover {
    text-decoration: none;
    filter: brightness(1.07);
}

.ec-button-secondary {
    background: transparent;
    color: var(--ec-accent);
}

.ec-section {
    padding: 2rem 0 4rem;
}

.ec-section h2 {
    margin-top: 0;
    font-size: clamp(1.6rem, 4vw, 2.4rem);
}

.ec-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 1rem;
}

.ec-card {
    min-width: 0;
    padding: 1.35rem;
    border: 1px solid var(--ec-border);
    border-radius: var(--ec-radius);
    background: linear-gradient(
        145deg,
        var(--ec-surface),
        var(--ec-surface-alt)
    );
    box-shadow: var(--ec-shadow);
}

.ec-card h3 {
    margin-top: 0;
}

.ec-card p {
    color: var(--ec-muted);
}

.ec-status {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.32rem 0.65rem;
    border: 1px solid var(--ec-border);
    border-radius: 999px;
    background: var(--ec-accent-soft);
    color: var(--ec-accent);
    font-size: 0.82rem;
    font-weight: 700;
}

.ec-list {
    padding-left: 1.15rem;
}

.ec-list li + li {
    margin-top: 0.45rem;
}

.ec-data {
    overflow-x: auto;
    padding: 1rem;
    border: 1px solid var(--ec-border);
    border-radius: var(--ec-radius);
    background: #061018;
    color: #cfe6e2;
    font-family:
        "Cascadia Code",
        Consolas,
        monospace;
    font-size: 0.9rem;
}

.ec-footer {
    margin-top: 3rem;
    padding: 2rem 0;
    border-top: 1px solid var(--ec-border);
    color: var(--ec-muted);
}

.ec-hidden {
    display: none !important;
}

@media (max-width: 900px) {
    .ec-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media (max-width: 640px) {
    .ec-nav {
        align-items: flex-start;
        flex-direction: column;
        padding: 1rem 0;
    }

    .ec-nav-links {
        flex-direction: column;
        align-items: flex-start;
    }

    .ec-hero {
        padding-top: 3.5rem;
    }

    .ec-grid {
        grid-template-columns: 1fr;
    }
}
'@

Set-Content `
    -LiteralPath $CssPath `
    -Value $CssContent `
    -Encoding utf8

# ============================================================
# 2. ENGINECORE.JS
# ============================================================

$EngineCoreJsPath = Join-Path $JsDirectory "enginecore.js"

$EngineCoreJsContent = @'
"use strict";

window.EngineCore = (() => {
    const VERSION = "1.0.0";

    const state = {
        initialized: false,
        startedAt: null,
        page: null
    };

    function normalizePageName(value) {
        if (typeof value !== "string") {
            return "unknown";
        }

        const name = value.trim().toLowerCase();

        return name.length > 0 ? name : "unknown";
    }

    function init(options = {}) {
        if (state.initialized) {
            return getState();
        }

        state.initialized = true;
        state.startedAt = new Date().toISOString();
        state.page = normalizePageName(options.page || document.body.dataset.page);

        document.documentElement.dataset.enginecore = "ready";

        window.dispatchEvent(
            new CustomEvent("enginecore:ready", {
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
            new CustomEvent(`enginecore:${name}`, {
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
    -LiteralPath $EngineCoreJsPath `
    -Value $EngineCoreJsContent `
    -Encoding utf8

# ============================================================
# 3. UI.JS
# ============================================================

$UiJsPath = Join-Path $JsDirectory "ui.js"

$UiJsContent = @'
"use strict";

window.EngineCoreUI = (() => {
    function setCurrentNavigation() {
        const currentPath = window.location.pathname.replace(/\/+$/, "/");

        document.querySelectorAll("[data-ec-nav]").forEach((link) => {
            const linkPath = new URL(link.href, window.location.origin)
                .pathname
                .replace(/\/+$/, "/");

            if (linkPath === currentPath) {
                link.setAttribute("aria-current", "page");
            } else {
                link.removeAttribute("aria-current");
            }
        });
    }

    function bindToggleButtons() {
        document.querySelectorAll("[data-ec-toggle]").forEach((button) => {
            const selector = button.getAttribute("data-ec-toggle");

            if (!selector) {
                return;
            }

            const target = document.querySelector(selector);

            if (!target) {
                return;
            }

            button.addEventListener("click", () => {
                const hidden = target.classList.toggle("ec-hidden");
                button.setAttribute("aria-expanded", String(!hidden));
            });
        });
    }

    function updateYear() {
        const year = String(new Date().getFullYear());

        document.querySelectorAll("[data-ec-year]").forEach((element) => {
            element.textContent = year;
        });
    }

    function init() {
        setCurrentNavigation();
        bindToggleButtons();
        updateYear();

        if (window.EngineCore) {
            window.EngineCore.init({
                page: document.body.dataset.page
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init, {
            once: true
        });
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
# 4. MODULES.JSON
# ============================================================

$ModulesPath = Join-Path $DataDirectory "modules.json"

$ModulesContent = @'
{
  "schemaVersion": "1.0",
  "product": "EngineCore",
  "modules": [
    {
      "id": "architecture",
      "name": "Architecture",
      "route": "/products/enginecore/architecture/",
      "description": "Structural overview of the EngineCore product."
    },
    {
      "id": "runtime",
      "name": "Runtime",
      "route": "/products/enginecore/runtime/",
      "description": "Runtime concepts and execution lifecycle."
    },
    {
      "id": "modules",
      "name": "Modules",
      "route": "/products/enginecore/modules/",
      "description": "Modular EngineCore component overview."
    },
    {
      "id": "validation",
      "name": "Validation",
      "route": "/products/enginecore/validation/",
      "description": "Validation and integrity concepts."
    },
    {
      "id": "diagnostics",
      "name": "Diagnostics",
      "route": "/products/enginecore/diagnostics/",
      "description": "Observability and diagnostic information."
    },
    {
      "id": "developer",
      "name": "Developer",
      "route": "/products/enginecore/developer/",
      "description": "Developer-oriented EngineCore resources."
    },
    {
      "id": "demos",
      "name": "Demos",
      "route": "/products/enginecore/demos/",
      "description": "EngineCore demonstrations and examples."
    }
  ]
}
'@

Set-Content `
    -LiteralPath $ModulesPath `
    -Value $ModulesContent `
    -Encoding utf8

# ============================================================
# 5. CAPABILITIES.JSON
# ============================================================

$CapabilitiesPath = Join-Path $DataDirectory "capabilities.json"

$CapabilitiesContent = @'
{
  "schemaVersion": "1.0",
  "product": "EngineCore",
  "capabilities": [
    {
      "id": "modularity",
      "name": "Modular Structure",
      "description": "Organizes EngineCore functionality into defined product areas."
    },
    {
      "id": "runtime",
      "name": "Runtime Layer",
      "description": "Provides a dedicated product area for runtime concepts."
    },
    {
      "id": "validation",
      "name": "Validation",
      "description": "Provides a dedicated area for validation and integrity information."
    },
    {
      "id": "diagnostics",
      "name": "Diagnostics",
      "description": "Provides diagnostics and observability documentation."
    },
    {
      "id": "developer",
      "name": "Developer Resources",
      "description": "Provides technical resources for development and integration."
    },
    {
      "id": "demonstration",
      "name": "Demonstrations",
      "description": "Provides examples and demonstrations through a dedicated product route."
    }
  ]
}
'@

Set-Content `
    -LiteralPath $CapabilitiesPath `
    -Value $CapabilitiesContent `
    -Encoding utf8

# ============================================================
# 6. ARCHITECTURE.JSON
# ============================================================

$ArchitecturePath = Join-Path $DataDirectory "architecture.json"

$ArchitectureContent = @'
{
  "schemaVersion": "1.0",
  "product": "EngineCore",
  "architecture": {
    "layers": [
      {
        "order": 1,
        "id": "architecture",
        "name": "Architecture",
        "route": "/products/enginecore/architecture/"
      },
      {
        "order": 2,
        "id": "runtime",
        "name": "Runtime",
        "route": "/products/enginecore/runtime/"
      },
      {
        "order": 3,
        "id": "modules",
        "name": "Modules",
        "route": "/products/enginecore/modules/"
      },
      {
        "order": 4,
        "id": "validation",
        "name": "Validation",
        "route": "/products/enginecore/validation/"
      },
      {
        "order": 5,
        "id": "diagnostics",
        "name": "Diagnostics",
        "route": "/products/enginecore/diagnostics/"
      },
      {
        "order": 6,
        "id": "developer",
        "name": "Developer",
        "route": "/products/enginecore/developer/"
      },
      {
        "order": 7,
        "id": "demos",
        "name": "Demos",
        "route": "/products/enginecore/demos/"
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
# VALIDIERUNG
# ============================================================

Write-Host ""
Write-Host "ASSET VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$ExpectedFiles = @(
    "assets\css\enginecore.css"
    "assets\js\enginecore.js"
    "assets\js\ui.js"
    "data\modules.json"
    "data\capabilities.json"
    "data\architecture.json"
)

$FileFailures = @()

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $Root $RelativePath

    if (Test-Path -LiteralPath $FullPath -PathType Leaf) {

        $File = Get-Item -LiteralPath $FullPath

        if ($File.Length -gt 0) {
            Write-Host (
                "[PASS] {0,-38} {1,8} bytes" -f
                $RelativePath,
                $File.Length
            ) -ForegroundColor Green
        }
        else {
            Write-Host (
                "[FAIL] {0} ist leer." -f $RelativePath
            ) -ForegroundColor Red

            $FileFailures += $RelativePath
        }
    }
    else {
        Write-Host (
            "[FAIL] {0} fehlt." -f $RelativePath
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

$JsonFiles = @(
    $ModulesPath
    $CapabilitiesPath
    $ArchitecturePath
)

$JsonFailures = @()

foreach ($JsonPath in $JsonFiles) {

    try {
        $RawJson = Get-Content -LiteralPath $JsonPath -Raw

        if ([string]::IsNullOrWhiteSpace($RawJson)) {
            throw "JSON-Datei ist leer."
        }

        $null = $RawJson | ConvertFrom-Json -ErrorAction Stop

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
# FINAL SUMMARY
# ============================================================

$TotalFailures = (
    $FileFailures.Count +
    $JsonFailures.Count
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ENGINECORE ASSET SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ("Expected files : {0}" -f $ExpectedFiles.Count)
Write-Host ("File failures  : {0}" -f $FileFailures.Count)
Write-Host ("JSON files     : {0}" -f $JsonFiles.Count)
Write-Host ("JSON failures  : {0}" -f $JsonFailures.Count)
Write-Host ("Total failures : {0}" -f $TotalFailures)
Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {
    Write-Host "[PASS] ENGINECORE ASSET GENERATION COMPLETE" -ForegroundColor Green
    Write-Host "============================================================"
    exit 0
}

Write-Host "[FAIL] ENGINECORE ASSET GENERATION FAILED" -ForegroundColor Red
Write-Host "============================================================"
exit 1
