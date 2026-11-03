#Requires -Version 7.0

<#
.SYNOPSIS
    Generiert die gemeinsamen Developer-Tools-Assets.

.DESCRIPTION
    Erstellt CSS, JavaScript und strukturierte JSON-Daten
    fuer den Developer-Tools-Produktbereich.

    Die bestehende Hauptseite index.html wird nicht veraendert.

.EXITCODES
    0 = erfolgreich
    1 = Fehler
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\developer-tools"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# PFADE
# ============================================================

$MainIndex = Join-Path $Root "index.html"

$CssPath = Join-Path `
    $Root `
    "assets\css\developer-tools.css"

$DeveloperJsPath = Join-Path `
    $Root `
    "assets\js\developer-tools.js"

$UiJsPath = Join-Path `
    $Root `
    "assets\js\ui.js"

$CapabilitiesPath = Join-Path `
    $Root `
    "data\capabilities.json"

$ToolsPath = Join-Path `
    $Root `
    "data\tools.json"

$ArchitecturePath = Join-Path `
    $Root `
    "data\architecture.json"

$ExpectedFiles = @(
    "assets\css\developer-tools.css"
    "assets\js\developer-tools.js"
    "assets\js\ui.js"
    "data\capabilities.json"
    "data\tools.json"
    "data\architecture.json"
)

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DEVELOPER TOOLS - ASSET GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# PRECHECK
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] Developer-Tools-Root fehlt." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    Write-Host "[FAIL] Hauptseite fehlt." -ForegroundColor Red
    exit 1
}

$MainHashBefore = (
    Get-FileHash `
        -LiteralPath $MainIndex `
        -Algorithm SHA256
).Hash

Write-Host "[PASS] Developer-Tools-Root vorhanden." -ForegroundColor Green
Write-Host "[PASS] Hauptseite erkannt und geschuetzt." -ForegroundColor Green

# ============================================================
# CSS
# ============================================================

$CssContent = @'
:root {
    --dev-bg: #05070a;
    --dev-surface: #0c1118;
    --dev-surface-alt: #111924;
    --dev-line: #1d2938;
    --dev-text: #f4f7fb;
    --dev-muted: #95a2b3;
    --dev-blue: #4ea1ff;
    --dev-green: #42d392;
    --dev-blue-soft: rgba(78, 161, 255, 0.10);
    --dev-green-soft: rgba(66, 211, 146, 0.10);
    --dev-max: 1180px;
    --dev-radius: 14px;
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
            rgba(78, 161, 255, 0.15),
            transparent 30rem
        ),
        var(--dev-bg);

    color: var(--dev-text);
    line-height: 1.6;
}

a {
    color: inherit;
    text-decoration: none;
}

a:hover,
a:focus-visible {
    color: var(--dev-blue);
}

.dev-shell {
    width: min(92%, var(--dev-max));
    margin-inline: auto;
}

.dev-header {
    position: sticky;
    top: 0;
    z-index: 100;

    background: rgba(5, 7, 10, 0.90);
    border-bottom: 1px solid rgba(255,255,255,0.06);

    backdrop-filter: blur(18px);
}

.dev-nav {
    min-height: 72px;

    display: flex;
    align-items: center;
    justify-content: space-between;

    gap: 2rem;
}

.dev-brand {
    font-size: 1.05rem;
    font-weight: 750;
    letter-spacing: -0.03em;
}

.dev-brand span {
    color: var(--dev-blue);
}

.dev-nav-links {
    display: flex;
    align-items: center;
    flex-wrap: wrap;

    gap: 1.2rem;

    color: var(--dev-muted);
    font-size: 0.9rem;
}

.dev-nav-links a:hover,
.dev-nav-links a[aria-current="page"] {
    color: var(--dev-text);
}

.dev-hero {
    min-height: 560px;

    display: flex;
    flex-direction: column;
    justify-content: center;

    padding: 5rem 0;
}

.dev-eyebrow,
.dev-label {
    color: var(--dev-blue);

    font-size: 0.78rem;
    font-weight: 700;
    letter-spacing: 0.13em;

    text-transform: uppercase;
}

.dev-hero h1 {
    max-width: 900px;

    margin: 0.7rem 0 1.5rem;

    font-size: clamp(3rem, 7vw, 6.5rem);
    line-height: 0.95;
    letter-spacing: -0.055em;
}

.dev-lead {
    max-width: 780px;

    color: var(--dev-muted);
    font-size: 1.08rem;
}

.dev-actions {
    display: flex;
    flex-wrap: wrap;

    gap: 0.75rem;
    margin-top: 2rem;
}

.dev-button {
    min-height: 44px;

    display: inline-flex;
    align-items: center;
    justify-content: center;

    padding: 0.75rem 1rem;

    border: 1px solid var(--dev-blue);
    border-radius: 8px;

    background: var(--dev-blue);
    color: #001326;

    font-weight: 700;
}

.dev-button-secondary {
    background: transparent;
    color: var(--dev-text);
    border-color: var(--dev-line);
}

.dev-section {
    padding: 2rem 0 5rem;
}

.dev-section h2 {
    margin: 0.6rem 0 1.2rem;

    font-size: clamp(2rem, 5vw, 3.6rem);
    line-height: 1.05;
    letter-spacing: -0.04em;
}

.dev-grid {
    display: grid;
    grid-template-columns:
        repeat(3, minmax(0, 1fr));

    gap: 1rem;
}

.dev-card {
    min-width: 0;
    padding: 1.5rem;

    background:
        linear-gradient(
            145deg,
            var(--dev-surface),
            var(--dev-surface-alt)
        );

    border: 1px solid var(--dev-line);
    border-radius: var(--dev-radius);

    transition:
        transform 0.2s ease,
        border-color 0.2s ease;
}

.dev-card:hover {
    transform: translateY(-3px);
    border-color: #395979;
}

.dev-card h3 {
    margin: 1rem 0 0.6rem;
}

.dev-card p {
    color: var(--dev-muted);
}

.dev-status {
    display: inline-flex;
    align-items: center;

    padding: 0.32rem 0.65rem;

    color: var(--dev-green);
    background: var(--dev-green-soft);

    border: 1px solid rgba(66,211,146,0.25);
    border-radius: 999px;

    font-size: 0.76rem;
    font-weight: 700;
}

.dev-panel {
    padding: 1.5rem;

    background: var(--dev-blue-soft);
    border: 1px solid var(--dev-line);
    border-radius: var(--dev-radius);
}

.dev-list {
    padding-left: 1.2rem;
}

.dev-list li + li {
    margin-top: 0.5rem;
}

.dev-code {
    overflow-x: auto;

    padding: 1rem;

    background: #030609;
    color: #cce5ff;

    border: 1px solid var(--dev-line);
    border-radius: 10px;

    font-family:
        "Cascadia Code",
        Consolas,
        monospace;

    font-size: 0.88rem;
}

.dev-footer {
    margin-top: 4rem;
    padding: 2rem 0;

    border-top: 1px solid var(--dev-line);

    color: var(--dev-muted);
}

.dev-hidden {
    display: none !important;
}

@media (max-width: 900px) {
    .dev-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media (max-width: 640px) {
    .dev-nav {
        align-items: flex-start;
        flex-direction: column;

        padding: 1rem 0;
    }

    .dev-nav-links {
        align-items: flex-start;
        flex-direction: column;
    }

    .dev-grid {
        grid-template-columns: 1fr;
    }

    .dev-hero {
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
# DEVELOPER-TOOLS.JS
# ============================================================

$DeveloperJsContent = @'
"use strict";

window.DeveloperTools = (() => {
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
        state.startedAt = new Date().toISOString();

        state.page = normalizePage(
            options.page ||
            document.body.dataset.page
        );

        document.documentElement.dataset.developerTools =
            "ready";

        window.dispatchEvent(
            new CustomEvent(
                "developertools:ready",
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
            throw new Error("A JSON URL is required.");
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
            throw new Error("An event name is required.");
        }

        window.dispatchEvent(
            new CustomEvent(
                `developertools:${name}`,
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
    -LiteralPath $DeveloperJsPath `
    -Value $DeveloperJsContent `
    -Encoding utf8

# ============================================================
# UI.JS
# ============================================================

$UiJsContent = @'
"use strict";

window.DeveloperToolsUI = (() => {
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
            .querySelectorAll("[data-dev-nav]")
            .forEach((link) => {
                const linkPath = normalizePath(
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
                }
                else {
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
            .querySelectorAll("[data-dev-year]")
            .forEach((element) => {
                element.textContent = year;
            });
    }

    function init() {
        setCurrentNavigation();
        updateYear();

        if (window.DeveloperTools) {
            window.DeveloperTools.init({
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
    }
    else {
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
  "product": "Developer Tools",
  "capabilities": [
    {
      "id": "automation",
      "name": "Automation",
      "route": "/products/developer-tools/automation/",
      "description": "Automation workflows and repeatable engineering processes."
    },
    {
      "id": "validators",
      "name": "Validators",
      "route": "/products/developer-tools/validators/",
      "description": "Validation tools for files, data, routes and technical structures."
    },
    {
      "id": "generators",
      "name": "Generators",
      "route": "/products/developer-tools/generators/",
      "description": "Deterministic generators for repeatable project artifacts."
    },
    {
      "id": "diagnostics",
      "name": "Diagnostics",
      "route": "/products/developer-tools/diagnostics/",
      "description": "Diagnostic utilities for technical states and failures."
    },
    {
      "id": "data-tools",
      "name": "Data Tools",
      "route": "/products/developer-tools/data-tools/",
      "description": "Structured-data utilities and validation resources."
    },
    {
      "id": "web-tools",
      "name": "Web Tools",
      "route": "/products/developer-tools/web-tools/",
      "description": "Utilities for static sites, links, routes and publishing checks."
    },
    {
      "id": "developer",
      "name": "Developer",
      "route": "/products/developer-tools/developer/",
      "description": "Technical resources for extending the Developer Tools platform."
    }
  ]
}
'@

Set-Content `
    -LiteralPath $CapabilitiesPath `
    -Value $CapabilitiesContent `
    -Encoding utf8

# ============================================================
# TOOLS.JSON
# ============================================================

$ToolsContent = @'
{
  "schemaVersion": "1.0",
  "product": "Developer Tools",
  "tools": [
    {
      "id": "automation-runner",
      "name": "Automation Runner",
      "category": "automation",
      "status": "documented"
    },
    {
      "id": "structure-validator",
      "name": "Structure Validator",
      "category": "validators",
      "status": "documented"
    },
    {
      "id": "page-generator",
      "name": "Page Generator",
      "category": "generators",
      "status": "documented"
    },
    {
      "id": "diagnostic-audit",
      "name": "Diagnostic Audit",
      "category": "diagnostics",
      "status": "documented"
    },
    {
      "id": "json-validator",
      "name": "JSON Validator",
      "category": "data-tools",
      "status": "documented"
    },
    {
      "id": "link-audit",
      "name": "Site Link Audit",
      "category": "web-tools",
      "status": "documented"
    }
  ]
}
'@

Set-Content `
    -LiteralPath $ToolsPath `
    -Value $ToolsContent `
    -Encoding utf8

# ============================================================
# ARCHITECTURE.JSON
# ============================================================

$ArchitectureContent = @'
{
  "schemaVersion": "1.0",
  "product": "Developer Tools",
  "architecture": {
    "areas": [
      {
        "order": 1,
        "id": "automation",
        "name": "Automation",
        "route": "/products/developer-tools/automation/"
      },
      {
        "order": 2,
        "id": "validators",
        "name": "Validators",
        "route": "/products/developer-tools/validators/"
      },
      {
        "order": 3,
        "id": "generators",
        "name": "Generators",
        "route": "/products/developer-tools/generators/"
      },
      {
        "order": 4,
        "id": "diagnostics",
        "name": "Diagnostics",
        "route": "/products/developer-tools/diagnostics/"
      },
      {
        "order": 5,
        "id": "data-tools",
        "name": "Data Tools",
        "route": "/products/developer-tools/data-tools/"
      },
      {
        "order": 6,
        "id": "web-tools",
        "name": "Web Tools",
        "route": "/products/developer-tools/web-tools/"
      },
      {
        "order": 7,
        "id": "developer",
        "name": "Developer",
        "route": "/products/developer-tools/developer/"
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
# ASSET VALIDATION
# ============================================================

Write-Host ""
Write-Host "ASSET VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$FileFailures = @()

foreach ($RelativePath in $ExpectedFiles) {

    $FullPath = Join-Path $Root $RelativePath

    if (
        (Test-Path -LiteralPath $FullPath -PathType Leaf) -and
        ((Get-Item -LiteralPath $FullPath).Length -gt 0)
    ) {

        $Length = (
            Get-Item -LiteralPath $FullPath
        ).Length

        Write-Host (
            "[PASS] {0,-42} {1,8} bytes" -f
            $RelativePath,
            $Length
        ) -ForegroundColor Green
    }
    else {

        Write-Host (
            "[FAIL] {0}" -f
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
    $ToolsPath
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
    $MainHashBefore -eq $MainHashAfter
)

if ($MainProtected) {
    Write-Host "[PASS] Hauptseite unveraendert." -ForegroundColor Green
}
else {
    Write-Host "[FAIL] Hauptseite wurde veraendert." -ForegroundColor Red
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
Write-Host " DEVELOPER TOOLS - ASSET SUMMARY" -ForegroundColor Cyan
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
        "[PASS] DEVELOPER TOOLS ASSET GENERATION COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] DEVELOPER TOOLS ASSET GENERATION FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1
