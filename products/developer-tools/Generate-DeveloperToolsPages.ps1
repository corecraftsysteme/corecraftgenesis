#Requires -Version 7.0

<#
.SYNOPSIS
    Erzeugt sieben vollständige Developer-Tools-Unterseiten.

.DESCRIPTION
    Erstellt:
      automation\index.html
      validators\index.html
      generators\index.html
      diagnostics\index.html
      data-tools\index.html
      web-tools\index.html
      developer\index.html

    Die bestehende Hauptseite index.html wird nicht verändert.

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

$MainIndex = Join-Path $Root "index.html"

$ExpectedAssets = @(
    "assets\css\developer-tools.css"
    "assets\js\developer-tools.js"
    "assets\js\ui.js"
    "data\capabilities.json"
    "data\tools.json"
    "data\architecture.json"
)

# ============================================================
# SEITEN
# ============================================================

$Pages = @(

    [pscustomobject]@{
        Id = "automation"
        Title = "Developer Tools Automation"
        Eyebrow = "Developer Tools / Automation"
        Description = "Automatisierung wiederholbarer Entwicklungs-, Prüf- und Veröffentlichungsprozesse."
        Lead = "Der Automation-Bereich bündelt wiederholbare technische Abläufe für Setup, Validierung, Build und Release."
        IntroTitle = "Reproduzierbare Automatisierung"
        IntroText = "Automatisierte Prozesse reduzieren manuelle Wiederholungen und sorgen dafür, dass definierte technische Schritte in derselben Reihenfolge ausgeführt werden."
        DataFile = "tools.json"
        Components = @(
            "Task Automation|Wiederholbare technische Aufgaben strukturiert ausführen."
            "Build Automation|Prüf- und Build-Schritte in definierter Reihenfolge ausführen."
            "Release Workflow|Validierung, Git-Status und Release-Prüfungen kombinieren."
            "File Operations|Datei- und Verzeichnisoperationen kontrolliert automatisieren."
            "Audit Execution|Bestehende Prüfskripte automatisiert aufrufen und auswerten."
            "Result Reporting|PASS-, FAIL- und Statusinformationen eindeutig zusammenfassen."
        )
        Principles = @(
            "Wiederholbare Abläufe eindeutig definieren"
            "Fehlerzustände früh erkennen und melden"
            "Keine stillen Fehler akzeptieren"
            "Automatisierung vor Veröffentlichung validieren"
            "Ergebnisse nachvollziehbar dokumentieren"
        )
    }

    [pscustomobject]@{
        Id = "validators"
        Title = "Developer Tools Validators"
        Eyebrow = "Developer Tools / Validators"
        Description = "Validierungswerkzeuge für Dateien, strukturierte Daten, Routen und technische Projektzustände."
        Lead = "Validators prüfen technische Erwartungen, bevor Dateien, Daten oder Seiten veröffentlicht werden."
        IntroTitle = "Validierung vor Freigabe"
        IntroText = "Eine Validierung sollte klar zeigen, was geprüft wurde, welches Ergebnis erwartet wurde und warum ein Zustand bestanden oder fehlgeschlagen ist."
        DataFile = "capabilities.json"
        Components = @(
            "File Validator|Existenz, Größe und erwartete Dateien prüfen."
            "JSON Validator|JSON-Syntax und strukturierte Datendateien kontrollieren."
            "Route Validator|Erwartete lokale und veröffentlichte Routen prüfen."
            "Asset Validator|CSS-, JavaScript- und weitere lokale Referenzen kontrollieren."
            "Structure Validator|Erwartete Verzeichnis- und Projektstrukturen überprüfen."
            "Result Validator|PASS- und FAIL-Ergebnisse konsistent zusammenführen."
        )
        Principles = @(
            "Prüfbedingungen vor der Ausführung definieren"
            "Fehler mit konkretem Ziel und Ursache melden"
            "Struktur und Inhalt getrennt validieren"
            "Validierung reproduzierbar halten"
            "Finales Ergebnis eindeutig ausgeben"
        )
    }

    [pscustomobject]@{
        Id = "generators"
        Title = "Developer Tools Generators"
        Eyebrow = "Developer Tools / Generators"
        Description = "Deterministische Generatoren für Seiten, Assets, Daten und wiederholbare Projektartefakte."
        Lead = "Generators erzeugen wiederkehrende technische Strukturen aus definierten Eingaben und gemeinsamen Vorlagen."
        IntroTitle = "Deterministische Generierung"
        IntroText = "Ein Generator sollte bei identischen Eingaben eine vorhersehbare Struktur erzeugen und bestehende geschützte Dateien nicht unbeabsichtigt verändern."
        DataFile = "tools.json"
        Components = @(
            "Page Generator|Vollständige HTML-Seiten nach gemeinsamer Struktur erzeugen."
            "Asset Generator|CSS-, JavaScript- und gemeinsame Ressourcen erstellen."
            "Data Generator|Strukturierte JSON-Dateien reproduzierbar erzeugen."
            "Structure Generator|Verzeichnisse und erwartete Startdateien anlegen."
            "Template Generator|Wiederverwendbare technische Ausgangsstrukturen erstellen."
            "Manifest Generator|Datei- und Prüfinformationen strukturiert zusammenstellen."
        )
        Principles = @(
            "Eingaben und Ausgabeziele eindeutig definieren"
            "Bestehende geschützte Dateien nicht überschreiben"
            "Generierte Dateien anschließend validieren"
            "Gemeinsame Vorlagen konsistent verwenden"
            "Generatoren wiederholt ausführbar gestalten"
        )
    }

    [pscustomobject]@{
        Id = "diagnostics"
        Title = "Developer Tools Diagnostics"
        Eyebrow = "Developer Tools / Diagnostics"
        Description = "Diagnosewerkzeuge für technische Zustände, Fehlerursachen und nachvollziehbare Prüfergebnisse."
        Lead = "Diagnostics erleichtert die gezielte Analyse von Fehlern, Zuständen und technischen Abweichungen."
        IntroTitle = "Gezielte technische Diagnose"
        IntroText = "Diagnoseausgaben sollten nicht nur einen Fehler melden, sondern die betroffene Komponente, den Zustand und die relevante Ursache möglichst klar eingrenzen."
        DataFile = "tools.json"
        Components = @(
            "Syntax Diagnostics|Parser- und Syntaxfehler mit Position und Kontext sichtbar machen."
            "Runtime Diagnostics|Laufzeitfehler und technische Zustände nachvollziehbar erfassen."
            "File Diagnostics|Fehlende, leere oder unerwartete Dateien identifizieren."
            "Route Diagnostics|Nicht erreichbare oder falsch konfigurierte Routen erkennen."
            "State Diagnostics|Technische Zustände und Übergänge kontrollieren."
            "Audit Summary|Einzelergebnisse in einer finalen Diagnose zusammenführen."
        )
        Principles = @(
            "Fehler möglichst nahe an der Ursache melden"
            "Zeile, Datei oder Komponente eindeutig nennen"
            "Diagnose und Reparatur voneinander trennen"
            "Erfolgreiche Prüfungen ebenfalls sichtbar machen"
            "Finale Zusammenfassung bereitstellen"
        )
    }

    [pscustomobject]@{
        Id = "data-tools"
        Title = "Developer Tools Data Tools"
        Eyebrow = "Developer Tools / Data Tools"
        Description = "Werkzeuge für strukturierte Daten, JSON-Validierung, Transformation und technische Datenqualität."
        Lead = "Data Tools unterstützen die strukturierte Erstellung, Prüfung und Verarbeitung technischer Datendateien."
        IntroTitle = "Strukturierte Daten kontrollieren"
        IntroText = "Technische Daten sollten gültig, eindeutig strukturiert, versionierbar und durch automatisierte Prüfungen nachvollziehbar sein."
        DataFile = "architecture.json"
        Components = @(
            "JSON Processing|Strukturierte JSON-Daten lesen, erzeugen und validieren."
            "Schema Validation|Erwartete Datenstrukturen kontrollieren."
            "Data Transformation|Technische Daten in definierte Zielformate überführen."
            "Configuration Data|Konfigurationswerte strukturiert dokumentieren."
            "Metadata Tools|Datei- und Systemmetadaten konsistent verwalten."
            "Data Audit|Struktur, Vollständigkeit und Lesbarkeit technischer Daten prüfen."
        )
        Principles = @(
            "Datenformate eindeutig festlegen"
            "JSON-Dateien vor Verwendung validieren"
            "Keine synthetischen Produktionsdaten ohne Kennzeichnung verwenden"
            "Änderungen versionierbar halten"
            "Daten und Darstellung getrennt behandeln"
        )
    }

    [pscustomobject]@{
        Id = "web-tools"
        Title = "Developer Tools Web Tools"
        Eyebrow = "Developer Tools / Web Tools"
        Description = "Werkzeuge für statische Websites, Links, Routen, Assets und Produktionsprüfungen."
        Lead = "Web Tools bündeln technische Prüfungen für statische Seiten, interne Navigation und veröffentlichbare Webstrukturen."
        IntroTitle = "Webseiten systematisch prüfen"
        IntroText = "Eine veröffentlichbare Website benötigt gültige Seiten, funktionierende interne Links, vorhandene Assets und nachvollziehbare Produktionsprüfungen."
        DataFile = "tools.json"
        Components = @(
            "Link Audit|Interne Links über mehrere HTML-Seiten hinweg prüfen."
            "Asset Audit|Lokale CSS-, JavaScript- und Medienreferenzen kontrollieren."
            "Route Audit|Erwartete Seiten und Produktadressen validieren."
            "HTML Inventory|HTML-Seiten inventarisieren und leere Dateien erkennen."
            "Production Validation|Site-Audits mit Git- und Datenprüfungen kombinieren."
            "Live Audit|Veröffentlichte Seiten per HTTP kontrollieren."
        )
        Principles = @(
            "Interne Links vor jedem Release prüfen"
            "Lokale Assets vollständig validieren"
            "Leere HTML-Dateien als Fehler behandeln"
            "Lokale und öffentliche Prüfung trennen"
            "Produktionsfreigabe erst nach vollständigem PASS"
        )
    }

    [pscustomobject]@{
        Id = "developer"
        Title = "Developer Tools Developer"
        Eyebrow = "Developer Tools / Developer"
        Description = "Technische Ressourcen für Erweiterung, Integration und Pflege der Developer-Tools-Plattform."
        Lead = "Der Developer-Bereich beschreibt gemeinsame Standards für Erweiterungen, Assets, Daten und technische Prüfwerkzeuge."
        IntroTitle = "Erweiterbare Developer-Tools-Plattform"
        IntroText = "Neue Werkzeuge sollten dieselben gemeinsamen Strukturen, Namensregeln, Datenformate und Audit-Verfahren verwenden."
        DataFile = "capabilities.json"
        Components = @(
            "Shared Assets|Gemeinsames CSS und JavaScript für konsistente Tool-Seiten."
            "Structured Data|JSON-Dateien für Fähigkeiten, Tools und Architektur."
            "PowerShell Tooling|Automatisierte technische Workflows und Prüfungen."
            "Audit Integration|Neue Bereiche in bestehende Site- und Produkt-Audits integrieren."
            "Git Workflow|Änderungen kontrolliert versionieren und veröffentlichen."
            "Production Workflow|Build-, Audit- und Live-Prüfungen miteinander verbinden."
        )
        Principles = @(
            "Gemeinsame Strukturen wiederverwenden"
            "Neue Tools nachvollziehbar dokumentieren"
            "PowerShell-Syntax vor Ausführung prüfen"
            "Lokale Audits vor Git-Commit durchführen"
            "Produktionsfreigabe mit Production-Build absichern"
        )
    }
)

# ============================================================
# GEMEINSAME NAVIGATION
# ============================================================

$Navigation = @'
<nav class="dev-nav" aria-label="Developer Tools Navigation">

  <a class="dev-brand" href="/products/developer-tools/">
    Developer <span>Tools</span>
  </a>

  <div class="dev-nav-links">
    <a data-dev-nav href="/products/developer-tools/automation/">Automation</a>
    <a data-dev-nav href="/products/developer-tools/validators/">Validators</a>
    <a data-dev-nav href="/products/developer-tools/generators/">Generators</a>
    <a data-dev-nav href="/products/developer-tools/diagnostics/">Diagnostics</a>
    <a data-dev-nav href="/products/developer-tools/data-tools/">Data Tools</a>
    <a data-dev-nav href="/products/developer-tools/web-tools/">Web Tools</a>
    <a data-dev-nav href="/products/developer-tools/developer/">Developer</a>
  </div>

</nav>
'@

# ============================================================
# PRECHECK
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DEVELOPER TOOLS - COMPLETE PAGE GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    throw "Developer-Tools-Root fehlt: $Root"
}

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    throw "Developer-Tools-Hauptseite fehlt: $MainIndex"
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
        <article class="dev-card">
          <span class="dev-status">
            DEVELOPER TOOL
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
    href="/products/developer-tools/assets/css/developer-tools.css"
  >
</head>

<body data-page="$($Page.Id)">

<header class="dev-header">
  <div class="dev-shell">
$Navigation
  </div>
</header>

<main>

  <section class="dev-hero">
    <div class="dev-shell">

      <div class="dev-eyebrow">
        $($Page.Eyebrow)
      </div>

      <h1>$($Page.Title)</h1>

      <p class="dev-lead">
        $($Page.Lead)
      </p>

      <div class="dev-actions">

        <a
          class="dev-button"
          href="#overview"
        >
          Bereich ansehen
        </a>

        <a
          class="dev-button dev-button-secondary"
          href="/products/developer-tools/"
        >
          Developer Tools Übersicht
        </a>

      </div>

    </div>
  </section>

  <section class="dev-section" id="overview">
    <div class="dev-shell">

      <div class="dev-panel">

        <span class="dev-status">
          ACTIVE DEVELOPER TOOLS AREA
        </span>

        <h2>$($Page.IntroTitle)</h2>

        <p class="dev-lead">
          $($Page.IntroText)
        </p>

      </div>

    </div>
  </section>

  <section class="dev-section">
    <div class="dev-shell">

      <div class="dev-label">
        Technical Components
      </div>

      <h2>Kernbereiche</h2>

      <div class="dev-grid">
$CardsHtml
      </div>

    </div>
  </section>

  <section class="dev-section">
    <div class="dev-shell">

      <div class="dev-grid">

        <article class="dev-card">

          <span class="dev-status">
            PRINCIPLES
          </span>

          <h2>Technische Grundsätze</h2>

          <ul class="dev-list">
$PrinciplesHtml
          </ul>

        </article>

        <article class="dev-card">

          <span class="dev-status">
            STRUCTURED DATA
          </span>

          <h2>Datenquelle</h2>

          <p>
            Dieser Bereich verwendet gemeinsame,
            lokal validierte Developer-Tools-Daten.
          </p>

          <p>
            <a href="/products/developer-tools/data/$($Page.DataFile)">
              $($Page.DataFile) öffnen
            </a>
          </p>

        </article>

        <article class="dev-card">

          <span class="dev-status">
            AUDIT
          </span>

          <h2>Qualitätssicherung</h2>

          <p>
            Seiten, JSON-Dateien, interne Links,
            Routen und Asset-Verweise werden vor
            einer Veröffentlichung validiert.
          </p>

        </article>

      </div>

    </div>
  </section>

  <section class="dev-section">
    <div class="dev-shell">

      <div class="dev-card">

        <span class="dev-status">
          DEVELOPER TOOLS
        </span>

        <h2>Weitere Tool-Bereiche</h2>

        <div class="dev-nav-links">
          <a href="/products/developer-tools/automation/">Automation</a>
          <a href="/products/developer-tools/validators/">Validators</a>
          <a href="/products/developer-tools/generators/">Generators</a>
          <a href="/products/developer-tools/diagnostics/">Diagnostics</a>
          <a href="/products/developer-tools/data-tools/">Data Tools</a>
          <a href="/products/developer-tools/web-tools/">Web Tools</a>
          <a href="/products/developer-tools/developer/">Developer</a>
        </div>

      </div>

    </div>
  </section>

</main>

<footer class="dev-footer">
  <div class="dev-shell">

    <p>
      &copy;
      <span data-dev-year>2026</span>
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

<script src="/products/developer-tools/assets/js/developer-tools.js"></script>
<script src="/products/developer-tools/assets/js/ui.js"></script>

</body>
</html>
"@

    Set-Content `
        -LiteralPath $OutputPath `
        -Value $Html `
        -Encoding utf8

    $File = Get-Item -LiteralPath $OutputPath

    $Generated += [pscustomobject]@{
        Page  = $Page.Id
        Bytes = $File.Length
        Path  = $OutputPath
    }

    Write-Host (
        "[CREATE] {0,-30} {1,8} bytes" -f
        "$($Page.Id)\index.html",
        $File.Length
    ) -ForegroundColor Green
}

# ============================================================
# VALIDIERUNG
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
            'developer-tools\.css'
            'developer-tools\.js'
            'ui\.js'
            'Technische Grundsätze'
            'Weitere Tool-Bereiche'
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
Write-Host " DEVELOPER TOOLS - COMPLETE PAGE SUMMARY" -ForegroundColor Cyan
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
        "[PASS] COMPLETE DEVELOPER TOOLS PAGES GENERATED"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] DEVELOPER TOOLS PAGE GENERATION FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1