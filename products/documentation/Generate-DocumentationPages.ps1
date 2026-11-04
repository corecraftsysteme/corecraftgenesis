#Requires -Version 7.0

<#
.SYNOPSIS
    Erzeugt sieben vollständige Documentation-Unterseiten.

.DESCRIPTION
    Erstellt:
      getting-started\index.html
      architecture\index.html
      guides\index.html
      reference\index.html
      standards\index.html
      releases\index.html
      developer\index.html

    Verwendet die gemeinsamen Documentation-Assets.

    Die bestehende Hauptseite index.html wird nicht verändert.

.EXITCODES
    0 = erfolgreich
    1 = Fehler
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\documentation"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# KONFIGURATION
# ============================================================

$MainIndex = Join-Path $Root "index.html"

$ExpectedAssets = @(
    "assets\css\documentation.css"
    "assets\js\documentation.js"
    "assets\js\ui.js"
    "data\sections.json"
    "data\resources.json"
    "data\architecture.json"
)

# ============================================================
# SEITENDEFINITIONEN
# ============================================================

$Pages = @(

    [pscustomobject]@{
        Id = "getting-started"
        Title = "Documentation Getting Started"
        Eyebrow = "Documentation / Getting Started"
        Description = "Einstieg und Orientierung für die technische Dokumentation von CoreCraft Genesis."
        Lead = "Getting Started bietet einen klaren Einstieg in Dokumentationsbereiche, technische Ressourcen und wiederholbare Arbeitsabläufe."
        IntroTitle = "Der strukturierte Einstieg"
        IntroText = "Der Einstieg führt von der Orientierung über die Auswahl eines Dokumentationsbereichs bis zur gezielten Nutzung von Anleitungen, Referenzen und Standards."
        DataFile = "sections.json"

        Components = @(
            "Documentation Overview|Überblick über Bereiche, Inhalte und technische Ressourcen."
            "Quick Start|Direkter Einstieg in die wichtigsten Dokumentationsabläufe."
            "Product Areas|Orientierung innerhalb der CoreCraft-Genesis-Produktbereiche."
            "Navigation|Klare Wege zwischen Guides, Referenz, Standards und Releases."
            "Validation|Prüfung von Dateien, Links, Daten und technischen Strukturen."
            "Next Steps|Definierte nächste Schritte für Entwicklung und Veröffentlichung."
        )

        Principles = @(
            "Mit einer klaren Übersicht beginnen"
            "Dokumentationsbereiche gezielt auswählen"
            "Anleitungen in nachvollziehbarer Reihenfolge verwenden"
            "Referenzen für technische Details heranziehen"
            "Ergebnisse vor der Veröffentlichung validieren"
        )
    }

    [pscustomobject]@{
        Id = "architecture"
        Title = "Documentation Architecture"
        Eyebrow = "Documentation / Architecture"
        Description = "Architektur und strukturelle Organisation der CoreCraft-Genesis-Dokumentation."
        Lead = "Documentation Architecture beschreibt Aufbau, Verantwortlichkeiten, Verbindungen und gemeinsame technische Grundlagen."
        IntroTitle = "Modulare Dokumentationsarchitektur"
        IntroText = "Eine klare Architektur trennt Einstiegsinhalte, Anleitungen, Referenzen, Standards, Release-Informationen und technische Pflege."
        DataFile = "architecture.json"

        Components = @(
            "Information Architecture|Strukturierung von Themen, Bereichen und Navigationswegen."
            "Content Layers|Trennung von Einstieg, Anleitung, Referenz und Standard."
            "Product Documentation|Dokumentation einzelner Produkt- und Systembereiche."
            "Shared Resources|Gemeinsame Assets, Daten und technische Vorlagen."
            "Navigation Model|Konsistente Verbindungen zwischen Dokumentationsbereichen."
            "Audit Layer|Prüfung von Seiten, Routen, Links, Assets und Daten."
        )

        Principles = @(
            "Dokumentationsbereiche eindeutig trennen"
            "Gemeinsame Strukturen konsistent verwenden"
            "Navigationswege nachvollziehbar gestalten"
            "Daten und Darstellung getrennt verwalten"
            "Architekturänderungen dokumentieren und prüfen"
        )
    }

    [pscustomobject]@{
        Id = "guides"
        Title = "Documentation Guides"
        Eyebrow = "Documentation / Guides"
        Description = "Praktische Schritt-für-Schritt-Anleitungen für technische Abläufe und Veröffentlichungen."
        Lead = "Guides übersetzen technische Ziele in nachvollziehbare, wiederholbare und prüfbare Arbeitsschritte."
        IntroTitle = "Praktische technische Anleitungen"
        IntroText = "Eine gute Anleitung beschreibt Voraussetzungen, einzelne Schritte, erwartete Ergebnisse, Risiken und eine abschließende Prüfung."
        DataFile = "resources.json"

        Components = @(
            "Setup Guides|Vorbereitung von Verzeichnissen, Dateien und technischen Voraussetzungen."
            "Build Guides|Schrittweise Durchführung von Build- und Prüfabläufen."
            "Audit Guides|Anleitungen für lokale, siteweite und öffentliche Audits."
            "Deployment Guides|Kontrollierte Veröffentlichung und anschließende Live-Prüfung."
            "Troubleshooting Guides|Gezielte Analyse und Behebung technischer Fehler."
            "Release Guides|Wiederholbare Freigabeabläufe mit klaren Kontrollpunkten."
        )

        Principles = @(
            "Voraussetzungen vor den Schritten nennen"
            "Jeden Schritt eindeutig formulieren"
            "Erwartete Ergebnisse sichtbar machen"
            "Risiken und mögliche Fehlerquellen angeben"
            "Die Anleitung mit einer Prüfung abschließen"
        )
    }

    [pscustomobject]@{
        Id = "reference"
        Title = "Documentation Reference"
        Eyebrow = "Documentation / Reference"
        Description = "Strukturierte technische Referenzen für Dateien, Routen, Daten, Befehle und Systembereiche."
        Lead = "Reference stellt technische Informationen kompakt, eindeutig und dauerhaft auffindbar bereit."
        IntroTitle = "Technische Referenzinformationen"
        IntroText = "Referenzen dienen der gezielten Suche nach konkreten Befehlen, Pfaden, Datenformaten, Statuswerten und technischen Definitionen."
        DataFile = "resources.json"

        Components = @(
            "Command Reference|Befehle, Parameter und erwartete Ausgaben."
            "File Reference|Dateien, Verzeichnisse und technische Verantwortlichkeiten."
            "Route Reference|Lokale und öffentliche Webseitenrouten."
            "Data Reference|JSON-Strukturen, Felder und Datenbedeutungen."
            "Status Reference|PASS-, FAIL- und weitere technische Zustände."
            "Naming Reference|Benennungsregeln für Dateien, Bereiche und Artefakte."
        )

        Principles = @(
            "Referenzen kurz und eindeutig halten"
            "Pfade und Bezeichnungen exakt angeben"
            "Parameter und Einheiten vollständig nennen"
            "Beispiele klar von Regeln unterscheiden"
            "Veraltete Referenzen sichtbar aktualisieren"
        )
    }

    [pscustomobject]@{
        Id = "standards"
        Title = "Documentation Standards"
        Eyebrow = "Documentation / Standards"
        Description = "Standards für Struktur, Sprache, Formate, Qualität und technische Prüfung."
        Lead = "Documentation Standards definieren gemeinsame Regeln für verständliche, konsistente und auditierbare Inhalte."
        IntroTitle = "Gemeinsame Dokumentationsstandards"
        IntroText = "Standards sichern eine einheitliche Struktur, klare Sprache, konsistente Benennung und reproduzierbare Qualität."
        DataFile = "sections.json"

        Components = @(
            "Structure Standard|Einheitlicher Aufbau für Seiten und Dokumentationsbereiche."
            "Writing Standard|Klare, präzise und zielgruppengerechte Sprache."
            "Naming Standard|Konsistente Namen für Dateien, Routen und technische Begriffe."
            "Data Standard|Definierte Strukturen für JSON und technische Metadaten."
            "Audit Standard|Verbindliche Prüfungen vor Veröffentlichung und Release."
            "Version Standard|Nachvollziehbare Änderung, Versionierung und Freigabe."
        )

        Principles = @(
            "Einfache und verständliche Sprache verwenden"
            "Benennungen konsistent halten"
            "Technische Aussagen eindeutig formulieren"
            "Strukturierte Daten vor Nutzung validieren"
            "Veröffentlichungen durch Audits absichern"
        )
    }

    [pscustomobject]@{
        Id = "releases"
        Title = "Documentation Releases"
        Eyebrow = "Documentation / Releases"
        Description = "Release-Informationen, Versionsstände, Änderungen und technische Freigaben."
        Lead = "Releases dokumentiert veröffentlichte Zustände, wichtige Änderungen und die zugehörigen technischen Prüfungen."
        IntroTitle = "Nachvollziehbare Veröffentlichungen"
        IntroText = "Eine Release-Dokumentation verbindet Version, Commit, Änderungen, Prüfstatus und veröffentlichten Zustand."
        DataFile = "resources.json"

        Components = @(
            "Release Summary|Kurze Übersicht über Umfang und Ziel einer Veröffentlichung."
            "Change Log|Nachvollziehbare Liste wichtiger Änderungen."
            "Commit Reference|Zuordnung einer Veröffentlichung zu einem Git-Commit."
            "Validation Status|Dokumentation der bestandenen lokalen Prüfungen."
            "Production Status|Ergebnis des Produktions-Builds und der Freigabe."
            "Live Verification|Prüfung der veröffentlichten Seiten und Routen."
        )

        Principles = @(
            "Jede Veröffentlichung eindeutig benennen"
            "Commit und Versionsstand dokumentieren"
            "Änderungen kurz und konkret beschreiben"
            "Prüfergebnisse vor Veröffentlichung festhalten"
            "Live-Status nach dem Deployment kontrollieren"
        )
    }

    [pscustomobject]@{
        Id = "developer"
        Title = "Documentation Developer"
        Eyebrow = "Documentation / Developer"
        Description = "Technische Ressourcen für Pflege, Erweiterung und Prüfung der Dokumentationsplattform."
        Lead = "Der Developer-Bereich beschreibt gemeinsame Grundlagen für Generatoren, Assets, Daten, Audits und Veröffentlichungen."
        IntroTitle = "Erweiterbare Dokumentationsplattform"
        IntroText = "Neue Dokumentationsbereiche sollten gemeinsame Assets, Datenstrukturen, Navigationsmodelle und Prüfverfahren wiederverwenden."
        DataFile = "sections.json"

        Components = @(
            "Shared Assets|Gemeinsames CSS und JavaScript für konsistente Dokumentationsseiten."
            "Structured Data|JSON-Dateien für Bereiche, Ressourcen und Architektur."
            "Page Generator|Deterministische Erzeugung vollständiger Unterseiten."
            "Local Audit|Prüfung von Seiten, Daten, Links, Routen und Assets."
            "Production Build|Verbindung von Git-, HTML-, JSON- und Site-Prüfungen."
            "Live Audit|Kontrolle der veröffentlichten Documentation-Routen."
        )

        Principles = @(
            "Gemeinsame Assets wiederverwenden"
            "Neue Bereiche strukturiert definieren"
            "PowerShell-Syntax vor Ausführung prüfen"
            "Lokale Audits vor dem Commit durchführen"
            "Production-Build und Live-Audit abschließen"
        )
    }
)

# ============================================================
# GEMEINSAME NAVIGATION
# ============================================================

$Navigation = @'
<nav class="doc-nav" aria-label="Documentation Navigation">

  <a class="doc-brand" href="/products/documentation/">
    CoreCraft <span>Documentation</span>
  </a>

  <div class="doc-nav-links">
    <a data-doc-nav href="/products/documentation/getting-started/">Getting Started</a>
    <a data-doc-nav href="/products/documentation/architecture/">Architecture</a>
    <a data-doc-nav href="/products/documentation/guides/">Guides</a>
    <a data-doc-nav href="/products/documentation/reference/">Reference</a>
    <a data-doc-nav href="/products/documentation/standards/">Standards</a>
    <a data-doc-nav href="/products/documentation/releases/">Releases</a>
    <a data-doc-nav href="/products/documentation/developer/">Developer</a>
  </div>

</nav>
'@

# ============================================================
# PRECHECK
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DOCUMENTATION - COMPLETE PAGE GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    throw "Documentation-Root fehlt: $Root"
}

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    throw "Documentation-Hauptseite fehlt: $MainIndex"
}

$MainHashBefore = (
    Get-FileHash `
        -LiteralPath $MainIndex `
        -Algorithm SHA256
).Hash

Write-Host "[PASS] Hauptseite erkannt und geschuetzt." -ForegroundColor Green

Write-Host ""
Write-Host "ASSET PRECHECK" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

foreach ($RelativePath in $ExpectedAssets) {

    $FullPath = Join-Path $Root $RelativePath

    if (
        -not (Test-Path -LiteralPath $FullPath -PathType Leaf) -or
        (Get-Item -LiteralPath $FullPath).Length -eq 0
    ) {
        throw "Asset fehlt oder ist leer: $RelativePath"
    }

    Write-Host "[PASS] $RelativePath" -ForegroundColor Green
}

# ============================================================
# SEITEN GENERIEREN
# ============================================================

Write-Host ""
Write-Host "PAGE GENERATION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$Generated = @()

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

    $Cards = foreach ($Component in $Page.Components) {

        $Parts = $Component -split '\|', 2

        $ComponentTitle = $Parts[0]
        $ComponentText = $Parts[1]

@"
        <article class="doc-card">
          <span class="doc-status">
            DOCUMENTATION
          </span>

          <h3>$ComponentTitle</h3>

          <p>
            $ComponentText
          </p>
        </article>
"@
    }

    $CardsHtml = $Cards -join "`r`n"

    $PrincipleItems = foreach ($Principle in $Page.Principles) {
        "              <li>$Principle</li>"
    }

    $PrinciplesHtml = $PrincipleItems -join "`r`n"

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
    href="/products/documentation/assets/css/documentation.css"
  >
</head>

<body data-page="$($Page.Id)">

<header class="doc-header">
  <div class="doc-shell">
$Navigation
  </div>
</header>

<main>

  <section class="doc-hero">
    <div class="doc-shell">

      <div class="doc-eyebrow">
        $($Page.Eyebrow)
      </div>

      <h1>$($Page.Title)</h1>

      <p class="doc-lead">
        $($Page.Lead)
      </p>

      <div class="doc-actions">

        <a
          class="doc-button"
          href="#overview"
        >
          Bereich ansehen
        </a>

        <a
          class="doc-button doc-button-secondary"
          href="/products/documentation/"
        >
          Documentation Übersicht
        </a>

      </div>

    </div>
  </section>

  <section class="doc-section" id="overview">
    <div class="doc-shell">

      <div class="doc-panel">

        <span class="doc-status">
          ACTIVE DOCUMENTATION AREA
        </span>

        <h2>$($Page.IntroTitle)</h2>

        <p class="doc-lead">
          $($Page.IntroText)
        </p>

      </div>

    </div>
  </section>

  <section class="doc-section">
    <div class="doc-shell">

      <div class="doc-label">
        Documentation Components
      </div>

      <h2>Kernbereiche</h2>

      <div class="doc-grid">
$CardsHtml
      </div>

    </div>
  </section>

  <section class="doc-section">
    <div class="doc-shell">

      <div class="doc-grid">

        <article class="doc-card">

          <span class="doc-status">
            PRINCIPLES
          </span>

          <h2>Dokumentationsgrundsätze</h2>

          <ul class="doc-list">
$PrinciplesHtml
          </ul>

        </article>

        <article class="doc-card">

          <span class="doc-status">
            STRUCTURED DATA
          </span>

          <h2>Datenquelle</h2>

          <p>
            Dieser Bereich verwendet gemeinsame,
            lokal validierte Documentation-Daten.
          </p>

          <p>
            <a href="/products/documentation/data/$($Page.DataFile)">
              $($Page.DataFile) öffnen
            </a>
          </p>

        </article>

        <article class="doc-card">

          <span class="doc-status">
            AUDIT
          </span>

          <h2>Qualitätssicherung</h2>

          <p>
            Dokumentationsseiten, JSON-Dateien,
            interne Links, Routen und Asset-Verweise
            werden vor der Veröffentlichung geprüft.
          </p>

        </article>

      </div>

    </div>
  </section>

  <section class="doc-section">
    <div class="doc-shell">

      <div class="doc-card">

        <span class="doc-status">
          DOCUMENTATION
        </span>

        <h2>Weitere Dokumentationsbereiche</h2>

        <div class="doc-nav-links">
          <a href="/products/documentation/getting-started/">Getting Started</a>
          <a href="/products/documentation/architecture/">Architecture</a>
          <a href="/products/documentation/guides/">Guides</a>
          <a href="/products/documentation/reference/">Reference</a>
          <a href="/products/documentation/standards/">Standards</a>
          <a href="/products/documentation/releases/">Releases</a>
          <a href="/products/documentation/developer/">Developer</a>
        </div>

      </div>

    </div>
  </section>

</main>

<footer class="doc-footer">
  <div class="doc-shell">

    <p>
      &copy;
      <span data-doc-year>2026</span>
      CoreCraft Genesis · $($Page.Title)
    </p>

    <p>
      <a href="/products/">Alle Produkte</a>
      ·
      <a href="/docs/">Docs</a>
      ·
      <a href="/contact/">Kontakt</a>
    </p>

  </div>
</footer>

<script src="/products/documentation/assets/js/documentation.js"></script>
<script src="/products/documentation/assets/js/ui.js"></script>

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
        "[CREATE] {0,-34} {1,8} bytes" -f
        "$($Page.Id)\index.html",
        $File.Length
    ) -ForegroundColor Green
}

# ============================================================
# PAGE VALIDATION
# ============================================================

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

        if ($File.Length -lt 6000) {
            $Status = "FAIL"
            $Reason = "Datei ist unerwartet klein"
        }

        $RequiredPatterns = @(
            '<!DOCTYPE html>'
            '<title>'
            'documentation\.css'
            'documentation\.js'
            'ui\.js'
            'Dokumentationsgrundsätze'
            'Weitere Dokumentationsbereiche'
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
        "[{0}] {1,-34} {2}" -f
        $Status,
        $RelativePath,
        $Reason
    ) -ForegroundColor $Color
}

# ============================================================
# HAUPTSEITENSCHUTZ
# ============================================================

$MainHashAfter = (
    Get-FileHash `
        -LiteralPath $MainIndex `
        -Algorithm SHA256
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

# ============================================================
# SUMMARY
# ============================================================

$TotalFailures = $Failures.Count

if (-not $MainProtected) {
    $TotalFailures++
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DOCUMENTATION - COMPLETE PAGE SUMMARY" -ForegroundColor Cyan
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

    Write-Host (
        "[PASS] COMPLETE DOCUMENTATION PAGES GENERATED"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] DOCUMENTATION PAGE GENERATION FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1