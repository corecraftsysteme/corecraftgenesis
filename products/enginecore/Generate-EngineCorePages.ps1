#Requires -Version 7.0

<#
.SYNOPSIS
    Erzeugt sieben vollständige EngineCore-Unterseiten.

.DESCRIPTION
    Generiert:
      architecture\index.html
      runtime\index.html
      modules\index.html
      validation\index.html
      diagnostics\index.html
      developer\index.html
      demos\index.html

    Die EngineCore-Hauptseite wird nicht verändert.

.EXITCODES
    0 = erfolgreich
    1 = Fehler
#>

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis-github\products\enginecore"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# HILFSFUNKTIONEN
# ============================================================

function Write-Section {
    param(
        [Parameter(Mandatory)]
        [string]$Title
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------"
}

function Convert-ToHtmlList {
    param(
        [Parameter(Mandatory)]
        [string[]]$Items
    )

    $Lines = foreach ($Item in $Items) {
        "              <li>$Item</li>"
    }

    return ($Lines -join "`r`n")
}

function Convert-ToHtmlCards {
    param(
        [Parameter(Mandatory)]
        [object[]]$Cards
    )

    $Lines = foreach ($Card in $Cards) {
@"
          <article class="ec-card">
            <span class="ec-status">$($Card.Label)</span>

            <h3>$($Card.Title)</h3>

            <p>
              $($Card.Text)
            </p>
          </article>
"@
    }

    return ($Lines -join "`r`n")
}

# ============================================================
# KONFIGURATION
# ============================================================

$MainIndex = Join-Path $Root "index.html"

$RequiredAssets = @(
    "assets\css\enginecore.css"
    "assets\js\enginecore.js"
    "assets\js\ui.js"
    "data\modules.json"
    "data\capabilities.json"
    "data\architecture.json"
)

$Navigation = @'
      <nav class="ec-nav" aria-label="EngineCore Navigation">

        <a class="ec-brand" href="/products/enginecore/">
          EngineCore
        </a>

        <div class="ec-nav-links">
          <a data-ec-nav href="/products/enginecore/architecture/">
            Architecture
          </a>

          <a data-ec-nav href="/products/enginecore/runtime/">
            Runtime
          </a>

          <a data-ec-nav href="/products/enginecore/modules/">
            Modules
          </a>

          <a data-ec-nav href="/products/enginecore/validation/">
            Validation
          </a>

          <a data-ec-nav href="/products/enginecore/diagnostics/">
            Diagnostics
          </a>

          <a data-ec-nav href="/products/enginecore/developer/">
            Developer
          </a>

          <a data-ec-nav href="/products/enginecore/demos/">
            Demos
          </a>
        </div>

      </nav>
'@

$AreaNavigation = @'
        <div class="ec-card">

          <h2>Weitere EngineCore-Bereiche</h2>

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
'@

# ============================================================
# SEITENINHALTE
# ============================================================

$Pages = @(

    [pscustomobject]@{
        Id = "architecture"
        Title = "EngineCore Architecture"
        Eyebrow = "EngineCore / Architecture"
        Description = "Architekturmodell, technische Schichten, Verantwortlichkeiten und definierte Grenzen innerhalb von EngineCore."
        Lead = "Die EngineCore-Architektur strukturiert Runtime, Module, Validierung und Diagnose in klar abgegrenzte technische Bereiche."
        IntroTitle = "Strukturierte Systemarchitektur"
        IntroText = "EngineCore wird als modularer Produktbereich aufgebaut. Jede Schicht erhält eine definierte Verantwortung, nachvollziehbare Übergänge und eigene Prüfbereiche."
        Principles = @(
            "Klare Trennung zwischen Architektur, Runtime und Modulen"
            "Definierte Verantwortlichkeiten für jeden Systembereich"
            "Nachvollziehbare Übergänge zwischen Zuständen und Komponenten"
            "Gemeinsame Validierungs- und Diagnosegrundlagen"
            "Erweiterbare Struktur für zukünftige EngineCore-Module"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "LAYER 01"
                Title = "Architecture Layer"
                Text = "Definiert die übergeordnete EngineCore-Struktur und die Grenzen der einzelnen Produktbereiche."
            }
            [pscustomobject]@{
                Label = "LAYER 02"
                Title = "Runtime Layer"
                Text = "Beschreibt Ausführung, Lebenszyklus, Zustände und kontrollierte Runtime-Prozesse."
            }
            [pscustomobject]@{
                Label = "LAYER 03"
                Title = "Validation Layer"
                Text = "Prüft Integrität, Konsistenz und erwartete technische Eigenschaften."
            }
            [pscustomobject]@{
                Label = "LAYER 04"
                Title = "Diagnostics Layer"
                Text = "Stellt technische Zustände und relevante Diagnoseinformationen nachvollziehbar bereit."
            }
            [pscustomobject]@{
                Label = "LAYER 05"
                Title = "Developer Layer"
                Text = "Bündelt technische Informationen für Entwicklung, Erweiterung und Integration."
            }
            [pscustomobject]@{
                Label = "LAYER 06"
                Title = "Demonstration Layer"
                Text = "Stellt Beispiele und nachvollziehbare technische Demonstrationen bereit."
            }
        )
        DataFile = "/products/enginecore/data/architecture.json"
    }

    [pscustomobject]@{
        Id = "runtime"
        Title = "EngineCore Runtime"
        Eyebrow = "EngineCore / Runtime"
        Description = "Runtime-Modell für strukturierte Ausführung, Zustandsverwaltung, Lebenszyklus und kontrollierte Verarbeitung."
        Lead = "Die EngineCore Runtime bildet den ausführungsorientierten Kern für nachvollziehbare Zustände und reproduzierbare Systemabläufe."
        IntroTitle = "Kontrollierte Ausführung"
        IntroText = "Die Runtime organisiert Initialisierung, Ausführung, Zustandsübergänge, Validierung und Abschluss als klar definierte technische Phasen."
        Principles = @(
            "Definierte Initialisierung vor der Ausführung"
            "Explizite Runtime-Zustände und Übergänge"
            "Kontrollierte Verarbeitung modularer Komponenten"
            "Validierung vor kritischen Zustandsänderungen"
            "Nachvollziehbarer Abschluss und Diagnosezustand"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "PHASE 01"
                Title = "Initialize"
                Text = "Lädt Konfiguration, registriert Komponenten und stellt den erwarteten Startzustand her."
            }
            [pscustomobject]@{
                Label = "PHASE 02"
                Title = "Validate"
                Text = "Prüft Voraussetzungen und technische Abhängigkeiten vor der Verarbeitung."
            }
            [pscustomobject]@{
                Label = "PHASE 03"
                Title = "Execute"
                Text = "Führt den definierten Runtime-Prozess innerhalb kontrollierter Grenzen aus."
            }
            [pscustomobject]@{
                Label = "PHASE 04"
                Title = "Observe"
                Text = "Erfasst relevante Zustände und Diagnoseinformationen während der Ausführung."
            }
            [pscustomobject]@{
                Label = "PHASE 05"
                Title = "Finalize"
                Text = "Schließt den Prozess kontrolliert ab und stellt den finalen Zustand bereit."
            }
            [pscustomobject]@{
                Label = "PHASE 06"
                Title = "Recover"
                Text = "Unterstützt definierte Wiederherstellungswege bei fehlerhaften Zuständen."
            }
        )
        DataFile = "/products/enginecore/data/capabilities.json"
    }

    [pscustomobject]@{
        Id = "modules"
        Title = "EngineCore Modules"
        Eyebrow = "EngineCore / Modules"
        Description = "Modulare EngineCore-Komponenten mit klaren Zuständigkeiten, Routen und technischen Produktgrenzen."
        Lead = "EngineCore besteht aus unabhängigen, aber aufeinander abgestimmten Produktbereichen und technischen Modulen."
        IntroTitle = "Modulare Produktstruktur"
        IntroText = "Module können getrennt dokumentiert, validiert und erweitert werden. Gemeinsame Regeln sorgen gleichzeitig für konsistente Integration."
        Principles = @(
            "Jedes Modul besitzt eine definierte Verantwortung"
            "Module werden über klare Schnittstellen verbunden"
            "Gemeinsame Regeln verhindern uneindeutige Zustände"
            "Neue Module können kontrolliert ergänzt werden"
            "Modulstatus und Validierung bleiben nachvollziehbar"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "MODULE"
                Title = "Runtime"
                Text = "Ausführungsorientierter Bereich für Lebenszyklus und Zustandsverwaltung."
            }
            [pscustomobject]@{
                Label = "MODULE"
                Title = "Validation"
                Text = "Technischer Prüfbereich für Integrität und Konsistenz."
            }
            [pscustomobject]@{
                Label = "MODULE"
                Title = "Diagnostics"
                Text = "Bereich für Beobachtbarkeit, Zustandsprüfung und Diagnose."
            }
            [pscustomobject]@{
                Label = "MODULE"
                Title = "Developer"
                Text = "Ressourcen für Entwicklung, Erweiterung und technische Integration."
            }
            [pscustomobject]@{
                Label = "MODULE"
                Title = "Data"
                Text = "Strukturierte JSON-Daten für Module, Architektur und Fähigkeiten."
            }
            [pscustomobject]@{
                Label = "MODULE"
                Title = "Demos"
                Text = "Beispiele zur Darstellung definierter EngineCore-Konzepte."
            }
        )
        DataFile = "/products/enginecore/data/modules.json"
    }

    [pscustomobject]@{
        Id = "validation"
        Title = "EngineCore Validation"
        Eyebrow = "EngineCore / Validation"
        Description = "Validierungsmodell für Integrität, Konsistenz, erwartete Zustände und kontrollierte technische Freigaben."
        Lead = "Validation stellt sicher, dass EngineCore-Komponenten, Daten und Zustände den definierten Erwartungen entsprechen."
        IntroTitle = "Integrität vor Freigabe"
        IntroText = "Validierung findet nicht nur am Ende statt. Sie begleitet Initialisierung, Übergänge, Ausführung und Abschluss eines technischen Prozesses."
        Principles = @(
            "Datei- und Strukturvalidierung"
            "Prüfung von JSON-Syntax und erwarteten Daten"
            "Kontrolle interner Routen und Asset-Referenzen"
            "Validierung definierter Runtime-Zustände"
            "Aussagekräftige PASS- und FAIL-Ergebnisse"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "CONTROL 01"
                Title = "Structure Validation"
                Text = "Prüft erwartete Verzeichnisse, Dateien und technische Projektstrukturen."
            }
            [pscustomobject]@{
                Label = "CONTROL 02"
                Title = "Data Validation"
                Text = "Validiert JSON-Dateien und strukturierte EngineCore-Daten."
            }
            [pscustomobject]@{
                Label = "CONTROL 03"
                Title = "Route Validation"
                Text = "Kontrolliert lokale und veröffentlichte EngineCore-Routen."
            }
            [pscustomobject]@{
                Label = "CONTROL 04"
                Title = "Reference Validation"
                Text = "Prüft interne Links sowie CSS- und JavaScript-Referenzen."
            }
            [pscustomobject]@{
                Label = "CONTROL 05"
                Title = "Runtime Validation"
                Text = "Bewertet erwartete Zustände vor, während und nach der Ausführung."
            }
            [pscustomobject]@{
                Label = "CONTROL 06"
                Title = "Final Result"
                Text = "Erzeugt ein eindeutiges und nachvollziehbares Gesamtergebnis."
            }
        )
        DataFile = "/products/enginecore/data/capabilities.json"
    }

    [pscustomobject]@{
        Id = "diagnostics"
        Title = "EngineCore Diagnostics"
        Eyebrow = "EngineCore / Diagnostics"
        Description = "Diagnosebereich für Zustände, technische Ereignisse, Fehlerbilder und nachvollziehbare Systeminformationen."
        Lead = "Diagnostics verbessert die Sichtbarkeit technischer Zustände und unterstützt die systematische Fehleranalyse."
        IntroTitle = "Technische Beobachtbarkeit"
        IntroText = "Eine robuste Diagnose zeigt nicht nur, dass ein Fehler aufgetreten ist. Sie beschreibt Bereich, Zustand, Zeitpunkt und betroffene technische Komponente."
        Principles = @(
            "Klare PASS-, INFO-, WARN- und FAIL-Zustände"
            "Nachvollziehbare technische Ereignisse"
            "Strukturierte Fehler- und Statusinformationen"
            "Trennung zwischen Ursache, Wirkung und Ergebnis"
            "Prüfbare Abschlusszusammenfassungen"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "SIGNAL"
                Title = "State Inspection"
                Text = "Zeigt den aktuellen Zustand von Komponenten und Runtime-Bereichen."
            }
            [pscustomobject]@{
                Label = "SIGNAL"
                Title = "Event Trace"
                Text = "Ordnet technische Ereignisse in eine nachvollziehbare Reihenfolge ein."
            }
            [pscustomobject]@{
                Label = "SIGNAL"
                Title = "Failure Context"
                Text = "Ergänzt Fehler um technische Herkunft und betroffenen Bereich."
            }
            [pscustomobject]@{
                Label = "SIGNAL"
                Title = "Reference Audit"
                Text = "Prüft Links, Assets und erwartete technische Ziele."
            }
            [pscustomobject]@{
                Label = "SIGNAL"
                Title = "Runtime Status"
                Text = "Stellt Laufzeitstatus und relevante Übergänge strukturiert dar."
            }
            [pscustomobject]@{
                Label = "SIGNAL"
                Title = "Final Summary"
                Text = "Fasst Ergebnisse in einer kompakten Abschlussausgabe zusammen."
            }
        )
        DataFile = "/products/enginecore/data/architecture.json"
    }

    [pscustomobject]@{
        Id = "developer"
        Title = "EngineCore Developer"
        Eyebrow = "EngineCore / Developer"
        Description = "Technische Ressourcen für Entwicklung, Erweiterung, Integration und kontrollierte Pflege der EngineCore-Struktur."
        Lead = "Der Developer-Bereich bündelt Routen, Daten, Assets und technische Regeln für die weitere EngineCore-Entwicklung."
        IntroTitle = "Entwicklung mit klaren Verträgen"
        IntroText = "EngineCore-Erweiterungen sollten bestehende Routen, Datenstrukturen und gemeinsame Assets respektieren und durch Audits überprüfbar bleiben."
        Principles = @(
            "Gemeinsame CSS- und JavaScript-Assets verwenden"
            "Routen und Dateistrukturen deterministisch erzeugen"
            "JSON-Dateien vor der Veröffentlichung validieren"
            "Bestehende Hauptseiten vor unbeabsichtigtem Überschreiben schützen"
            "Lokale und veröffentlichte Seiten getrennt prüfen"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Shared Assets"
                Text = "Gemeinsames CSS und JavaScript für konsistente EngineCore-Seiten."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Structured Data"
                Text = "JSON-Dateien für Module, Fähigkeiten und Architektur."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Page Generator"
                Text = "Deterministische Erzeugung vollständiger EngineCore-Unterseiten."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Local Audit"
                Text = "Prüfung von Seiten, Links, Assets, Routen und JSON."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Live Audit"
                Text = "HTTP-Prüfung der veröffentlichten EngineCore-Routen."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Git Workflow"
                Text = "Kontrollierte Versionierung, Synchronisierung und Veröffentlichung."
            }
        )
        DataFile = "/products/enginecore/data/modules.json"
    }

    [pscustomobject]@{
        Id = "demos"
        Title = "EngineCore Demos"
        Eyebrow = "EngineCore / Demos"
        Description = "Demonstrationsbereich für nachvollziehbare EngineCore-Abläufe, Zustände, Validierung und technische Beispiele."
        Lead = "Die Demos machen zentrale EngineCore-Konzepte anhand klar abgegrenzter technischer Szenarien sichtbar."
        IntroTitle = "Nachvollziehbare Demonstrationen"
        IntroText = "Demos sollten definierte Eingaben, erwartete Zustände und eindeutige Ergebnisse verwenden. Dadurch bleiben Beispiele reproduzierbar und auditierbar."
        Principles = @(
            "Definierte Ausgangslage und erwartetes Ergebnis"
            "Klar sichtbare Zustandsübergänge"
            "Validierung nach jedem relevanten Schritt"
            "Keine stillen oder nicht dokumentierten Fehler"
            "Abschluss mit eindeutigem PASS- oder FAIL-Ergebnis"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "DEMO 01"
                Title = "Runtime Lifecycle"
                Text = "Demonstriert Initialisierung, Ausführung und kontrollierten Abschluss."
            }
            [pscustomobject]@{
                Label = "DEMO 02"
                Title = "State Transition"
                Text = "Zeigt nachvollziehbare Übergänge zwischen definierten Zuständen."
            }
            [pscustomobject]@{
                Label = "DEMO 03"
                Title = "Validation Flow"
                Text = "Veranschaulicht strukturierte Prüfungen vor einer technischen Freigabe."
            }
            [pscustomobject]@{
                Label = "DEMO 04"
                Title = "Diagnostics"
                Text = "Zeigt Diagnoseausgaben für erfolgreiche und fehlerhafte Zustände."
            }
            [pscustomobject]@{
                Label = "DEMO 05"
                Title = "Recovery"
                Text = "Demonstriert einen kontrollierten Wiederherstellungsweg."
            }
            [pscustomobject]@{
                Label = "DEMO 06"
                Title = "Audit Result"
                Text = "Fasst technische Einzelergebnisse in einem finalen Audit zusammen."
            }
        )
        DataFile = "/products/enginecore/data/capabilities.json"
    }
)

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT GENESIS - COMPLETE ENGINECORE PAGES" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# PRECHECK
# ============================================================

Write-Section "PRECHECK"

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] EngineCore-Root fehlt: $Root" -ForegroundColor Red
    exit 1
}

Write-Host "[PASS] EngineCore-Root vorhanden." -ForegroundColor Green

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    Write-Host "[FAIL] EngineCore-Hauptseite fehlt." -ForegroundColor Red
    exit 1
}

$MainHashBefore = (
    Get-FileHash -LiteralPath $MainIndex -Algorithm SHA256
).Hash

Write-Host "[PASS] Hauptseite erkannt und geschützt." -ForegroundColor Green

$AssetFailures = @()

foreach ($RelativePath in $RequiredAssets) {
    $FullPath = Join-Path $Root $RelativePath

    if (
        (Test-Path -LiteralPath $FullPath -PathType Leaf) -and
        ((Get-Item -LiteralPath $FullPath).Length -gt 0)
    ) {
        Write-Host "[PASS] $RelativePath" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] $RelativePath" -ForegroundColor Red
        $AssetFailures += $RelativePath
    }
}

if ($AssetFailures.Count -gt 0) {
    Write-Host "[FAIL] Asset-Precheck fehlgeschlagen." -ForegroundColor Red
    exit 1
}

# ============================================================
# SEITEN GENERIEREN
# ============================================================

Write-Section "PAGE GENERATION"

$GenerationResults = @()

foreach ($Page in $Pages) {

    $Directory = Join-Path $Root $Page.Id
    $OutputPath = Join-Path $Directory "index.html"

    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }

    $PrincipleList = Convert-ToHtmlList -Items $Page.Principles
    $CardsHtml = Convert-ToHtmlCards -Cards $Page.Cards

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
        $($Page.Eyebrow)
      </div>

      <h1>$($Page.Title)</h1>

      <p class="ec-lead">
        $($Page.Lead)
      </p>

      <div class="ec-actions">

        <a
          class="ec-button"
          href="#overview"
        >
          Bereich ansehen
        </a>

        <a
          class="ec-button ec-button-secondary"
          href="/products/enginecore/"
        >
          EngineCore Übersicht
        </a>

      </div>

    </div>
  </section>

  <section class="ec-section" id="overview">
    <div class="ec-shell">

      <div class="ec-card">

        <span class="ec-status">
          ACTIVE ENGINECORE AREA
        </span>

        <h2>$($Page.IntroTitle)</h2>

        <p class="ec-lead">
          $($Page.IntroText)
        </p>

      </div>

    </div>
  </section>

  <section class="ec-section">
    <div class="ec-shell">

      <h2>Kernbereiche</h2>

      <div class="ec-grid">
$CardsHtml
      </div>

    </div>
  </section>

  <section class="ec-section">
    <div class="ec-shell">

      <div class="ec-grid">

        <article class="ec-card">

          <h2>Grundsätze</h2>

          <ul class="ec-list">
$PrincipleList
          </ul>

        </article>

        <article class="ec-card">

          <h2>Technische Daten</h2>

          <p>
            Der Bereich verwendet strukturierte EngineCore-Daten
            und gemeinsame technische Assets.
          </p>

          <p>
            <a href="$($Page.DataFile)">
              Zugehörige JSON-Daten öffnen
            </a>
          </p>

        </article>

        <article class="ec-card">

          <h2>Validierung</h2>

          <p>
            Die Seite ist Bestandteil des lokalen und veröffentlichten
            EngineCore-Audits. Routen, Links und Assets werden vor der
            Freigabe kontrolliert.
          </p>

        </article>

      </div>

    </div>
  </section>

  <section class="ec-section">
    <div class="ec-shell">
$AreaNavigation
    </div>
  </section>

</main>

<footer class="ec-footer">
  <div class="ec-shell">

    <p>
      &copy;
      <span data-ec-year>2026</span>
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

<script src="/products/enginecore/assets/js/enginecore.js"></script>
<script src="/products/enginecore/assets/js/ui.js"></script>

</body>
</html>
"@

    Set-Content `
        -LiteralPath $OutputPath `
        -Value $Html `
        -Encoding utf8

    $File = Get-Item -LiteralPath $OutputPath

    $GenerationResults += [pscustomobject]@{
        Page = $Page.Id
        Path = $OutputPath
        Bytes = $File.Length
    }

    Write-Host (
        "[CREATE] {0,-32} {1,8} bytes" -f
        "$($Page.Id)\index.html",
        $File.Length
    ) -ForegroundColor Green
}

# ============================================================
# VALIDIERUNG
# ============================================================

Write-Section "PAGE VALIDATION"

$ValidationResults = @()

foreach ($Page in $Pages) {

    $RelativePath = "$($Page.Id)\index.html"
    $FullPath = Join-Path $Root $RelativePath

    $Status = "PASS"
    $Message = "Vollständig"

    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
        $Status = "FAIL"
        $Message = "Datei fehlt"
    }
    else {
        $File = Get-Item -LiteralPath $FullPath
        $Content = Get-Content -LiteralPath $FullPath -Raw

        if ($File.Length -lt 4000) {
            $Status = "FAIL"
            $Message = "Datei ist unerwartet klein"
        }

        if ($Content -notmatch '<!DOCTYPE html>') {
            $Status = "FAIL"
            $Message = "DOCTYPE fehlt"
        }

        if ($Content -notmatch '<title>') {
            $Status = "FAIL"
            $Message = "Seitentitel fehlt"
        }

        if ($Content -notmatch 'enginecore\.css') {
            $Status = "FAIL"
            $Message = "CSS-Verweis fehlt"
        }

        if ($Content -notmatch 'enginecore\.js') {
            $Status = "FAIL"
            $Message = "enginecore.js-Verweis fehlt"
        }

        if ($Content -notmatch 'ui\.js') {
            $Status = "FAIL"
            $Message = "ui.js-Verweis fehlt"
        }

        if ($Content -notmatch 'Weitere EngineCore-Bereiche') {
            $Status = "FAIL"
            $Message = "Bereichsnavigation fehlt"
        }
    }

    $ValidationResults += [pscustomobject]@{
        Status = $Status
        Page = $RelativePath
        Message = $Message
    }

    $Color = if ($Status -eq "PASS") {
        "Green"
    }
    else {
        "Red"
    }

    Write-Host (
        "[{0}] {1,-32} {2}" -f
        $Status,
        $RelativePath,
        $Message
    ) -ForegroundColor $Color
}

# ============================================================
# HAUPTSEITE SCHUTZPRÜFUNG
# ============================================================

Write-Section "MAIN PAGE PROTECTION"

$MainHashAfter = (
    Get-FileHash -LiteralPath $MainIndex -Algorithm SHA256
).Hash

$MainProtected = $MainHashBefore -eq $MainHashAfter

if ($MainProtected) {
    Write-Host "[PASS] Hauptseite blieb unverändert." -ForegroundColor Green
}
else {
    Write-Host "[FAIL] Hauptseite wurde verändert." -ForegroundColor Red
}

# ============================================================
# FINAL SUMMARY
# ============================================================

$PageFailures = @(
    $ValidationResults |
    Where-Object {
        $_.Status -eq "FAIL"
    }
)

$TotalFailures = $PageFailures.Count

if (-not $MainProtected) {
    $TotalFailures++
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " COMPLETE ENGINECORE PAGE SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Pages expected : {0}" -f $Pages.Count)
Write-Host ("Pages generated: {0}" -f $GenerationResults.Count)
Write-Host ("Pages passed   : {0}" -f ($Pages.Count - $PageFailures.Count))
Write-Host ("Pages failed   : {0}" -f $PageFailures.Count)
Write-Host ("Main protected : {0}" -f $MainProtected)
Write-Host ("Total failures : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {
    Write-Host "[PASS] COMPLETE ENGINECORE PAGES GENERATED" -ForegroundColor Green
    Write-Host "============================================================"
    exit 0
}

Write-Host "[FAIL] ENGINECORE PAGE GENERATION FAILED" -ForegroundColor Red
Write-Host "============================================================"
exit 1
