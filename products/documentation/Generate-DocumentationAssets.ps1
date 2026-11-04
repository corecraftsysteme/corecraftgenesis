#Requires -Version 7.0

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\documentation"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$MainIndex = Join-Path $Root "index.html"

$CssPath = Join-Path $Root "assets\css\documentation.css"
$DocumentationJsPath = Join-Path $Root "assets\js\documentation.js"
$UiJsPath = Join-Path $Root "assets\js\ui.js"

$SectionsPath = Join-Path $Root "data\sections.json"
$ResourcesPath = Join-Path $Root "data\resources.json"
$ArchitecturePath = Join-Path $Root "data\architecture.json"

$ExpectedFiles = @(
    "assets\css\documentation.css"
    "assets\js\documentation.js"
    "assets\js\ui.js"
    "data\sections.json"
    "data\resources.json"
    "data\architecture.json"
)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DOCUMENTATION - ASSET GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# PRECHECK
# ============================================================

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] Documentation-Root fehlt." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    Write-Host "[FAIL] Hauptseite fehlt." -ForegroundColor Red
    exit 1
}

$MainHashBefore = (
    Get-FileHash -LiteralPath $MainIndex -Algorithm SHA256
).Hash

Write-Host "[PASS] Documentation-Root vorhanden." -ForegroundColor Green
Write-Host "[PASS] Hauptseite erkannt und geschuetzt." -ForegroundColor Green

# ============================================================
# CSS
# ============================================================

$CssContent = @'
:root {
    --doc-bg: #05070a;
    --doc-surface: #0c1118;
    --doc-surface-alt: #111924;
    --doc-line: #1d2938;
    --doc-text: #f4f7fb;
    --doc-muted: #95a2b3;
    --doc-blue: #4ea1ff;
    --doc-green: #42d392;
    --doc-blue-soft: rgba(78, 161, 255, 0.10);
    --doc-green-soft: rgba(66, 211, 146, 0.10);
    --doc-max: 1180px;
    --doc-radius: 14px;
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
        var(--doc-bg);

    color: var(--doc-text);
    line-height: 1.6;
}

a {
    color: inherit;
    text-decoration: none;
}

a:hover,
a:focus-visible {
    color: var(--doc-blue);
}

.doc-shell {
    width: min(92%, var(--doc-max));
    margin-inline: auto;
}

.doc-header {
    position: sticky;
    top: 0;
    z-index: 100;

    background: rgba(5, 7, 10, 0.90);
    border-bottom: 1px solid rgba(255,255,255,0.06);

    backdrop-filter: blur(18px);
}

.doc-nav {
    min-height: 72px;

    display: flex;
    align-items: center;
    justify-content: space-between;

    gap: 2rem;
}

.doc-brand {
    font-size: 1.05rem;
    font-weight: 750;
    letter-spacing: -0.03em;
}

.doc-brand span {
    color: var(--doc-blue);
}

.doc-nav-links {
    display: flex;
    align-items: center;
    flex-wrap: wrap;

    gap: 1.2rem;

    color: var(--doc-muted);
    font-size: 0.9rem;
}

.doc-nav-links a:hover,
.doc-nav-links a[aria-current="page"] {
    color: var(--doc-text);
}

.doc-hero {
    min-height: 560px;

    display: flex;
    flex-direction: column;
    justify-content: center;

    padding: 5rem 0;
}

.doc-eyebrow,
.doc-label {
    color: var(--doc-blue);

    font-size: 0.78rem;
    font-weight: 700;
    letter-spacing: 0.13em;

    text-transform: uppercase;
}

.doc-hero h1 {
    max-width: 900px;

    margin: 0.7rem 0 1.5rem;

    font-size: clamp(3rem, 7vw, 6.5rem);
    line-height: 0.95;
    letter-spacing: -0.055em;
}

.doc-lead {
    max-width: 780px;

    color: var(--doc-muted);
    font-size: 1.08rem;
}

.doc-actions {
    display: flex;
    flex-wrap: wrap;

    gap: 0.75rem;
    margin-top: 2rem;
}

.doc-button {
    min-height: 44px;

    display: inline-flex;
    align-items: center;
    justify-content: center;

    padding: 0.75rem 1rem;

    border: 1px solid var(--doc-blue);
    border-radius: 8px;

    background: var(--doc-blue);
    color: #001326;

    font-weight: 700;
}

.doc-button-secondary {
    background: transparent;
    color: var(--doc-text);
    border-color: var(--doc-line);
}

.doc-section {
    padding: 2rem 0 5rem;
}

.doc-section h2 {
    margin: 0.6rem 0 1.2rem;

    font-size: clamp(2rem, 5vw, 3.6rem);
    line-height: 1.05;
    letter-spacing: -0.04em;
}

.doc-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 1rem;
}

.doc-card {
    min-width: 0;
    padding: 1.5rem;

    background:
        linear-gradient(
            145deg,
            var(--doc-surface),
            var(--doc-surface-alt)
        );

    border: 1px solid var(--doc-line);
    border-radius: var(--doc-radius);

    transition:
        transform 0.2s ease,
        border-color 0.2s ease;
}

.doc-card:hover {
    transform: translateY(-3px);
    border-color: #395979;
}

.doc-card h3 {
    margin: 1rem 0 0.6rem;
}

.doc-card p {
    color: var(--doc-muted);
}

.doc-status {
    display: inline-flex;
    align-items: center;

    padding: 0.32rem 0.65rem;

    color: var(--doc-green);
    background: var(--doc-green-soft);

    border: 1px solid rgba(66, 211, 146, 0.25);
    border-radius: 999px;

    font-size: 0.76rem;
    font-weight: 700;
}

.doc-panel {
    padding: 1.5rem;

    background: var(--doc-blue-soft);

    border: 1px solid var(--doc-line);
    border-radius: var(--doc-radius);
}

.doc-list {
    padding-left: 1.2rem;
}

.doc-list li + li {
    margin-top: 0.5rem;
}

.doc-code {
    overflow-x: auto;

    padding: 1rem;

    background: #030609;
    color: #cce5ff;

    border: 1px solid var(--doc-line);
    border-radius: 10px;

    font-family:
        "Cascadia Code",
        Consolas,
        monospace;

    font-size: 0.88rem;
}

.doc-footer {
    margin-top: 4rem;
    padding: 2rem 0;

    border-top: 1px solid var(--doc-line);

    color: var(--doc-muted);
}

.doc-hidden {
    display: none !important;
}

@media (max-width: 900px) {
    .doc-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media (max-width: 640px) {
    .doc-nav {
        align-items: flex-start;
        flex-direction: column;

        padding: 1rem 0;
    }

    .doc-nav-links {
        align-items: flex-start;
        flex-direction: column;
    }

    .doc-grid {
        grid-template-columns: 1fr;
    }

    .doc-hero {
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
# DOCUMENTATION.JS
# ============================================================

$DocumentationJsContent = @'
"use strict";

window.DocumentationPlatform = (() => {
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

        document.documentElement.dataset.documentation =
            "ready";

        window.dispatchEvent(
            new CustomEvent(
                "documentation:ready",
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
                `documentation:${name}`,
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
    -LiteralPath $DocumentationJsPath `
    -Value $DocumentationJsContent `
    -Encoding utf8

# ============================================================
# UI.JS
# ============================================================

$UiJsContent = @'
"use strict";

window.DocumentationUI = (() => {
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
            .querySelectorAll("[data-doc-nav]")
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
            .querySelectorAll("[data-doc-year]")
            .forEach((element) => {
                element.textContent = year;
            });
    }

    function init() {
        setCurrentNavigation();
        updateYear();

        if (window.DocumentationPlatform) {
            window.DocumentationPlatform.init({
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
# SECTIONS.JSON
# ============================================================

$SectionsContent = @'
{
  "schemaVersion": "1.0",
  "product": "Documentation",
  "sections": [
    {
      "id": "getting-started",
      "name": "Getting Started",
      "route": "/products/documentation/getting-started/",
      "description": "Entry point and orientation for CoreCraft Genesis documentation."
    },
    {
      "id": "architecture",
      "name": "Architecture",
      "route": "/products/documentation/architecture/",
      "description": "Documentation architecture and structural organization."
    },
    {
      "id": "guides",
      "name": "Guides",
      "route": "/products/documentation/guides/",
      "description": "Practical guides and repeatable technical procedures."
    },
    {
      "id": "reference",
      "name": "Reference",
      "route": "/products/documentation/reference/",
      "description": "Structured technical reference material."
    },
    {
      "id": "standards",
      "name": "Standards",
      "route": "/products/documentation/standards/",
      "description": "Documentation standards, formats and quality requirements."
    },
    {
      "id": "releases",
      "name": "Releases",
      "route": "/products/documentation/releases/",
      "description": "Release information, version history and publication status."
    },
    {
      "id": "developer",
      "name": "Developer",
      "route": "/products/documentation/developer/",
      "description": "Resources for maintaining and extending the documentation platform."
    }
  ]
}
'@

Set-Content `
    -LiteralPath $SectionsPath `
    -Value $SectionsContent `
    -Encoding utf8

# ============================================================
# RESOURCES.JSON
# ============================================================

$ResourcesContent = @'
{
  "schemaVersion": "1.0",
  "product": "Documentation",
  "resources": [
    {
      "id": "quick-start",
      "name": "Quick Start",
      "category": "getting-started",
      "status": "documented"
    },
    {
      "id": "architecture-overview",
      "name": "Architecture Overview",
      "category": "architecture",
      "status": "documented"
    },
    {
      "id": "technical-guides",
      "name": "Technical Guides",
      "category": "guides",
      "status": "documented"
    },
    {
      "id": "reference-library",
      "name": "Reference Library",
      "category": "reference",
      "status": "documented"
    },
    {
      "id": "documentation-standards",
      "name": "Documentation Standards",
      "category": "standards",
      "status": "documented"
    },
    {
      "id": "release-notes",
      "name": "Release Notes",
      "category": "releases",
      "status": "documented"
    }
  ]
}
'@

Set-Content `
    -LiteralPath $ResourcesPath `
    -Value $ResourcesContent `
    -Encoding utf8

# ============================================================
# ARCHITECTURE.JSON
# ============================================================

$ArchitectureContent = @'
{
  "schemaVersion": "1.0",
  "product": "Documentation",
  "architecture": {
    "areas": [
      {
        "order": 1,
        "id": "getting-started",
        "name": "Getting Started",
        "route": "/products/documentation/getting-started/"
      },
      {
        "order": 2,
        "id": "architecture",
        "name": "Architecture",
        "route": "/products/documentation/architecture/"
      },
      {
        "order": 3,
        "id": "guides",
        "name": "Guides",
        "route": "/products/documentation/guides/"
      },
      {
        "order": 4,
        "id": "reference",
        "name": "Reference",
        "route": "/products/documentation/reference/"
      },
      {
        "order": 5,
        "id": "standards",
        "name": "Standards",
        "route": "/products/documentation/standards/"
      },
      {
        "order": 6,
        "id": "releases",
        "name": "Releases",
        "route": "/products/documentation/releases/"
      },
      {
        "order": 7,
        "id": "developer",
        "name": "Developer",
        "route": "/products/documentation/developer/"
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
    $SectionsPath
    $ResourcesPath
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
Write-Host " DOCUMENTATION - ASSET SUMMARY" -ForegroundColor Cyan
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
        "[PASS] DOCUMENTATION ASSET GENERATION COMPLETE"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] DOCUMENTATION ASSET GENERATION FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1
