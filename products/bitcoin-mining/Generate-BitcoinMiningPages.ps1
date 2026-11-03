#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = "C:\corecraftgenesis-github\products\bitcoin-mining"
$MainIndex = Join-Path $Root "index.html"

$RequiredAssets = @(
    "assets\css\bitcoin-mining.css"
    "assets\js\bitcoin-mining.js"
    "assets\js\ui.js"
    "data\capabilities.json"
    "data\architecture.json"
    "data\metrics.json"
)

$Pages = @(
    [pscustomobject]@{
        Id = "architecture"
        Title = "Bitcoin Mining Architecture"
        Lead = "Struktur für Hardware, Energie, Betrieb, Monitoring und technische Mining-Daten."
        Description = "Architekturmodell und technische Bereiche einer strukturierten Bitcoin-Mining-Umgebung."
        DataFile = "architecture.json"
        Items = @(
            "Hardware Layer"
            "Energy Layer"
            "Operations Layer"
            "Monitoring Layer"
            "Economics Layer"
            "Audit Layer"
        )
    }

    [pscustomobject]@{
        Id = "hardware"
        Title = "Bitcoin Mining Hardware"
        Lead = "Technische Infrastruktur für Miner, Stromversorgung, Netzwerk, Kühlung und Betriebsumgebung."
        Description = "Hardware-Infrastruktur und technische Komponenten für Bitcoin Mining."
        DataFile = "capabilities.json"
        Items = @(
            "Mining Units"
            "Power Distribution"
            "Cooling"
            "Network"
            "Environment"
            "Hardware Inventory"
        )
    }

    [pscustomobject]@{
        Id = "operations"
        Title = "Bitcoin Mining Operations"
        Lead = "Strukturierte Betriebsabläufe für Verfügbarkeit, Wartung und kontrollierte technische Änderungen."
        Description = "Betriebsmodell für Wartung, Verfügbarkeit und technische Mining-Prozesse."
        DataFile = "capabilities.json"
        Items = @(
            "Startup"
            "Continuous Operation"
            "Maintenance"
            "Incident Response"
            "Change Control"
            "Final Validation"
        )
    }

    [pscustomobject]@{
        Id = "energy"
        Title = "Bitcoin Mining Energy"
        Lead = "Technische Betrachtung von Leistungsaufnahme, Effizienz, Versorgung und thermischen Betriebswerten."
        Description = "Energiebezogene Kennzahlen und technische Infrastruktur für Bitcoin Mining."
        DataFile = "metrics.json"
        Items = @(
            "Power Draw"
            "Energy Consumption"
            "Efficiency"
            "Capacity"
            "Thermal Load"
            "Energy Monitoring"
        )
    }

    [pscustomobject]@{
        Id = "monitoring"
        Title = "Bitcoin Mining Monitoring"
        Lead = "Monitoring für Hashrate, Leistung, Effizienz, Temperatur und Verfügbarkeit."
        Description = "Monitoring und Beobachtbarkeit technischer Bitcoin-Mining-Systeme."
        DataFile = "metrics.json"
        Items = @(
            "Hashrate"
            "Power"
            "Efficiency"
            "Temperature"
            "Uptime"
            "Event Trace"
        )
    }

    [pscustomobject]@{
        Id = "economics"
        Title = "Bitcoin Mining Economics"
        Lead = "Technische Kosten-, Leistungs- und Betriebsmodelle für dokumentierte Mining-Szenarien."
        Description = "Technische Betriebs- und Kostenmodelle für Bitcoin Mining ohne Ertragsversprechen."
        DataFile = "metrics.json"
        Items = @(
            "Energy Cost"
            "Hardware Cost"
            "Operating Cost"
            "Performance Inputs"
            "Scenario Comparison"
            "Assumption Audit"
        )
    }

    [pscustomobject]@{
        Id = "developer"
        Title = "Bitcoin Mining Developer"
        Lead = "Technische Ressourcen, strukturierte Daten, gemeinsame Assets und Prüfwerkzeuge."
        Description = "Entwicklerressourcen für den Bitcoin-Mining-Produktbereich."
        DataFile = "capabilities.json"
        Items = @(
            "Shared Assets"
            "Structured Data"
            "Page Generation"
            "Local Audit"
            "Live Audit"
            "Git Workflow"
        )
    }
)

$Navigation = @'
<nav class="mining-nav" aria-label="Bitcoin Mining Navigation">
  <a class="mining-brand" href="/products/bitcoin-mining/">
    Bitcoin <span>Mining</span>
  </a>

  <div class="mining-nav-links">
    <a data-mining-nav href="/products/bitcoin-mining/architecture/">Architecture</a>
    <a data-mining-nav href="/products/bitcoin-mining/hardware/">Hardware</a>
    <a data-mining-nav href="/products/bitcoin-mining/operations/">Operations</a>
    <a data-mining-nav href="/products/bitcoin-mining/energy/">Energy</a>
    <a data-mining-nav href="/products/bitcoin-mining/monitoring/">Monitoring</a>
    <a data-mining-nav href="/products/bitcoin-mining/economics/">Economics</a>
    <a data-mining-nav href="/products/bitcoin-mining/developer/">Developer</a>
  </div>
</nav>
'@

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BITCOIN MINING - PAGE GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    throw "Bitcoin-Mining-Root fehlt: $Root"
}

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    throw "Bitcoin-Mining-Hauptseite fehlt: $MainIndex"
}

$MainHashBefore = (
    Get-FileHash -LiteralPath $MainIndex -Algorithm SHA256
).Hash

Write-Host "[PASS] Hauptseite erkannt und geschuetzt." -ForegroundColor Green

Write-Host ""
Write-Host "ASSET PRECHECK" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $RequiredAssets) {
    $FullPath = Join-Path $Root $RelativePath

    if (
        -not (Test-Path -LiteralPath $FullPath -PathType Leaf) -or
        (Get-Item -LiteralPath $FullPath).Length -eq 0
    ) {
        throw "Asset fehlt oder ist leer: $RelativePath"
    }

    Write-Host "[PASS] $RelativePath" -ForegroundColor Green
}

Write-Host ""
Write-Host "PAGE GENERATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$Generated = @()

foreach ($Page in $Pages) {

    $Directory = Join-Path $Root $Page.Id
    $OutputPath = Join-Path $Directory "index.html"

    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }

    $Cards = foreach ($Item in $Page.Items) {
@"
        <article class="mining-card">
          <span class="mining-status">MINING</span>
          <h3>$Item</h3>
          <p>
            Technischer Bestandteil des Bereichs $($Page.Title).
          </p>
        </article>
"@
    }

    $CardsHtml = $Cards -join "`r`n"

    $Html = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>$($Page.Title) | CoreCraft Genesis</title>

  <meta
    name="description"
    content="$($Page.Description)"
  >

  <link
    rel="stylesheet"
    href="/products/bitcoin-mining/assets/css/bitcoin-mining.css"
  >
</head>

<body data-page="$($Page.Id)">

<header class="mining-header">
  <div class="mining-shell">
    $Navigation
  </div>
</header>

<main>

  <section class="mining-hero">
    <div class="mining-shell">

      <div class="mining-eyebrow">
        Bitcoin Mining / $($Page.Id)
      </div>

      <h1>$($Page.Title)</h1>

      <p class="mining-lead">
        $($Page.Lead)
      </p>

      <div class="mining-actions">
        <a
          class="mining-button"
          href="#overview"
        >
          Bereich ansehen
        </a>

        <a
          class="mining-button mining-button-secondary"
          href="/products/bitcoin-mining/"
        >
          Mining Übersicht
        </a>
      </div>

    </div>
  </section>

  <section class="mining-section" id="overview">
    <div class="mining-shell">

      <div class="mining-label">
        Technical Components
      </div>

      <h2>Kernbereiche</h2>

      <p class="mining-lead">
        Dieser Bereich ist Teil der modularen
        Bitcoin-Mining-Produktstruktur von CoreCraft Genesis.
      </p>

      <div class="mining-grid">
$CardsHtml
      </div>

    </div>
  </section>

  <section class="mining-section">
    <div class="mining-shell">

      <div class="mining-grid">

        <article class="mining-card">
          <span class="mining-status">DATA</span>

          <h2>Strukturierte Daten</h2>

          <p>
            Zugehörige technische Daten stehen als validierte
            JSON-Datei zur Verfügung.
          </p>

          <p>
            <a href="/products/bitcoin-mining/data/$($Page.DataFile)">
              $($Page.DataFile) öffnen
            </a>
          </p>
        </article>

        <article class="mining-card">
          <span class="mining-status">VALIDATION</span>

          <h2>Lokale Prüfung</h2>

          <p>
            Seiten, interne Links, Routen, JSON-Dateien und
            Asset-Verweise werden vor der Veröffentlichung geprüft.
          </p>
        </article>

        <article class="mining-card">
          <span class="mining-status">LIVE</span>

          <h2>Deployment-Prüfung</h2>

          <p>
            Nach der Veröffentlichung werden die öffentlichen
            Mining-Routen separat per HTTP geprüft.
          </p>
        </article>

      </div>

    </div>
  </section>

  <section class="mining-section">
    <div class="mining-shell">

      <div class="mining-card">

        <h2>Weitere Mining-Bereiche</h2>

        <div class="mining-nav-links">
          <a href="/products/bitcoin-mining/architecture/">Architecture</a>
          <a href="/products/bitcoin-mining/hardware/">Hardware</a>
          <a href="/products/bitcoin-mining/operations/">Operations</a>
          <a href="/products/bitcoin-mining/energy/">Energy</a>
          <a href="/products/bitcoin-mining/monitoring/">Monitoring</a>
          <a href="/products/bitcoin-mining/economics/">Economics</a>
          <a href="/products/bitcoin-mining/developer/">Developer</a>
        </div>

      </div>

    </div>
  </section>

</main>

<footer class="mining-footer">
  <div class="mining-shell">

    <p>
      &copy;
      <span data-mining-year>2026</span>
      CoreCraft Genesis · $($Page.Title)
    </p>

    <p>
      <a href="/products/">Alle Produkte</a>
      ·
      <a href="/docs/">Dokumentation</a>
      ·
      <a href="/contact/">Kontakt</a>
    </p>

  </div>
</footer>

<script src="/products/bitcoin-mining/assets/js/bitcoin-mining.js"></script>
<script src="/products/bitcoin-mining/assets/js/ui.js"></script>

</body>
</html>
"@

    Set-Content `
        -LiteralPath $OutputPath `
        -Value $Html `
        -Encoding utf8

    $File = Get-Item -LiteralPath $OutputPath

    $Generated += [pscustomobject]@{
        Page = $Page.Id
        Bytes = $File.Length
        Path = $OutputPath
    }

    Write-Host (
        "[CREATE] {0,-30} {1,8} bytes" -f
        "$($Page.Id)\index.html",
        $File.Length
    ) -ForegroundColor Green
}

Write-Host ""
Write-Host "PAGE VALIDATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$Failures = @()

foreach ($Page in $Pages) {

    $RelativePath = "$($Page.Id)\index.html"
    $FullPath = Join-Path $Root $RelativePath

    $Status = "PASS"
    $Reason = "Vollstaendig"

    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
        $Status = "FAIL"
        $Reason = "Datei fehlt"
    }
    else {

        $File = Get-Item -LiteralPath $FullPath
        $Content = Get-Content -LiteralPath $FullPath -Raw

        if ($File.Length -lt 4000) {
            $Status = "FAIL"
            $Reason = "Datei zu klein"
        }

        $RequiredPatterns = @(
            '<!DOCTYPE html>'
            '<title>'
            'bitcoin-mining\.css'
            'bitcoin-mining\.js'
            'ui\.js'
            'Weitere Mining-Bereiche'
        )

        foreach ($Pattern in $RequiredPatterns) {
            if ($Content -notmatch $Pattern) {
                $Status = "FAIL"
                $Reason = "Erwarteter Inhalt fehlt: $Pattern"
                break
            }
        }
    }

    if ($Status -eq "FAIL") {
        $Failures += $RelativePath
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
        $Reason
    ) -ForegroundColor $Color
}

$MainHashAfter = (
    Get-FileHash -LiteralPath $MainIndex -Algorithm SHA256
).Hash

$MainProtected = (
    $MainHashBefore -eq $MainHashAfter
)

Write-Host ""
Write-Host "MAIN PAGE PROTECTION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

if ($MainProtected) {
    Write-Host "[PASS] Hauptseite blieb unveraendert." -ForegroundColor Green
}
else {
    Write-Host "[FAIL] Hauptseite wurde veraendert." -ForegroundColor Red
}

$TotalFailures = $Failures.Count

if (-not $MainProtected) {
    $TotalFailures++
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BITCOIN MINING - PAGE SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Pages expected : {0}" -f $Pages.Count)
Write-Host ("Pages generated: {0}" -f $Generated.Count)
Write-Host ("Pages passed   : {0}" -f ($Pages.Count - $Failures.Count))
Write-Host ("Pages failed   : {0}" -f $Failures.Count)
Write-Host ("Main protected : {0}" -f $MainProtected)
Write-Host ("Total failures : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {
    Write-Host "[PASS] COMPLETE BITCOIN MINING PAGES GENERATED" -ForegroundColor Green
    Write-Host "============================================================"
    exit 0
}

Write-Host "[FAIL] BITCOIN MINING PAGE GENERATION FAILED" -ForegroundColor Red
Write-Host "============================================================"

exit 1