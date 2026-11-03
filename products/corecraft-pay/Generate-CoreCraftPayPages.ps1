#Requires -Version 7.0

<#
.SYNOPSIS
    Erzeugt sieben vollständige CoreCraft-Pay-Unterseiten.

.DESCRIPTION
    Generiert:
      architecture\index.html
      payments\index.html
      checkout\index.html
      integrations\index.html
      security\index.html
      developer\index.html
      demos\index.html

    Die bestehende CoreCraft-Pay-Hauptseite wird nicht verändert.

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

    return ($Lines -join [Environment]::NewLine)
}

function Convert-ToHtmlCards {
    param(
        [Parameter(Mandatory)]
        [object[]]$Cards
    )

    $Lines = foreach ($Card in $Cards) {
@"
          <article class="pay-card">
            <span class="pay-status">$($Card.Label)</span>

            <h3>$($Card.Title)</h3>

            <p>
              $($Card.Text)
            </p>
          </article>
"@
    }

    return ($Lines -join [Environment]::NewLine)
}

# ============================================================
# KONFIGURATION
# ============================================================

$MainIndex = Join-Path $Root "index.html"

$RequiredAssets = @(
    "assets\css\corecraft-pay.css"
    "assets\js\corecraft-pay.js"
    "assets\js\ui.js"
    "data\capabilities.json"
    "data\integrations.json"
    "data\architecture.json"
)

$Navigation = @'
      <nav class="pay-nav" aria-label="CoreCraft Pay Navigation">

        <a class="pay-brand" href="/products/corecraft-pay/">
          CoreCraft <span>Pay</span>
        </a>

        <div class="pay-nav-links">
          <a data-pay-nav href="/products/corecraft-pay/architecture/">
            Architecture
          </a>

          <a data-pay-nav href="/products/corecraft-pay/payments/">
            Payments
          </a>

          <a data-pay-nav href="/products/corecraft-pay/checkout/">
            Checkout
          </a>

          <a data-pay-nav href="/products/corecraft-pay/integrations/">
            Integrations
          </a>

          <a data-pay-nav href="/products/corecraft-pay/security/">
            Security
          </a>

          <a data-pay-nav href="/products/corecraft-pay/developer/">
            Developer
          </a>

          <a data-pay-nav href="/products/corecraft-pay/demos/">
            Demos
          </a>
        </div>

      </nav>
'@

$AreaNavigation = @'
        <div class="pay-card">

          <span class="pay-status">
            CORECRAFT PAY
          </span>

          <h2>Weitere Produktbereiche</h2>

          <div class="pay-nav-links">
            <a href="/products/corecraft-pay/architecture/">
              Architecture
            </a>

            <a href="/products/corecraft-pay/payments/">
              Payments
            </a>

            <a href="/products/corecraft-pay/checkout/">
              Checkout
            </a>

            <a href="/products/corecraft-pay/integrations/">
              Integrations
            </a>

            <a href="/products/corecraft-pay/security/">
              Security
            </a>

            <a href="/products/corecraft-pay/developer/">
              Developer
            </a>

            <a href="/products/corecraft-pay/demos/">
              Demos
            </a>
          </div>

        </div>
'@

# ============================================================
# SEITENDEFINITIONEN
# ============================================================

$Pages = @(

    [pscustomobject]@{
        Id = "architecture"
        Title = "CoreCraft Pay Architecture"
        Eyebrow = "CoreCraft Pay / Architecture"
        Description = "Architekturmodell, technische Bereiche und definierte Verantwortlichkeiten innerhalb von CoreCraft Pay."
        Lead = "Die CoreCraft-Pay-Architektur strukturiert Zahlungsabläufe, Checkout, Integrationen und Sicherheitskontrollen in klar getrennte Bereiche."
        IntroTitle = "Modulare Zahlungsarchitektur"
        IntroText = "CoreCraft Pay wird als strukturierter Produktbereich mit nachvollziehbaren Komponenten, technischen Übergängen und kontrollierbaren Integrationspunkten aufgebaut."
        Principles = @(
            "Klare Trennung von Payments, Checkout und Integrationen"
            "Definierte Verantwortlichkeiten für jeden Produktbereich"
            "Nachvollziehbare Übergänge zwischen Zahlungszuständen"
            "Gemeinsame Sicherheits- und Validierungsgrundlagen"
            "Erweiterbare Struktur für zukünftige Zahlungsfunktionen"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "LAYER 01"
                Title = "Payment Layer"
                Text = "Strukturiert zahlungsbezogene Abläufe und definierte Zahlungszustände."
            }
            [pscustomobject]@{
                Label = "LAYER 02"
                Title = "Checkout Layer"
                Text = "Beschreibt den kontrollierten Ablauf zwischen Auswahl, Bestätigung und Ergebnis."
            }
            [pscustomobject]@{
                Label = "LAYER 03"
                Title = "Integration Layer"
                Text = "Bündelt externe und interne Integrationspunkte in einer klaren Struktur."
            }
            [pscustomobject]@{
                Label = "LAYER 04"
                Title = "Security Layer"
                Text = "Definiert Sicherheitskontrollen und verantwortliche technische Grenzen."
            }
            [pscustomobject]@{
                Label = "LAYER 05"
                Title = "Developer Layer"
                Text = "Stellt technische Informationen für Entwicklung und Integration bereit."
            }
            [pscustomobject]@{
                Label = "LAYER 06"
                Title = "Audit Layer"
                Text = "Ermöglicht strukturierte Prüfung von Dateien, Routen, Daten und Referenzen."
            }
        )
        DataFile = "/products/corecraft-pay/data/architecture.json"
    }

    [pscustomobject]@{
        Id = "payments"
        Title = "CoreCraft Pay Payments"
        Eyebrow = "CoreCraft Pay / Payments"
        Description = "Strukturierte Zahlungsabläufe, Statusmodelle und kontrollierte Verarbeitung innerhalb von CoreCraft Pay."
        Lead = "Der Payments-Bereich beschreibt nachvollziehbare Abläufe von der Zahlungsanforderung bis zum finalen Ergebnis."
        IntroTitle = "Kontrollierte Zahlungsprozesse"
        IntroText = "Jeder Zahlungsprozess erhält einen klaren Ausgangszustand, definierte Verarbeitungsschritte und ein eindeutig dokumentiertes Ergebnis."
        Principles = @(
            "Definierte Zahlungsanforderungen und Eingabedaten"
            "Eindeutige Status- und Zustandsmodelle"
            "Validierung vor entscheidenden Übergängen"
            "Nachvollziehbare erfolgreiche und fehlerhafte Ergebnisse"
            "Trennung zwischen technischer Verarbeitung und Darstellung"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "STATE 01"
                Title = "Created"
                Text = "Die Zahlungsanforderung wurde erstellt und besitzt eine eindeutige Referenz."
            }
            [pscustomobject]@{
                Label = "STATE 02"
                Title = "Validated"
                Text = "Die erforderlichen Daten wurden geprüft und für die Verarbeitung freigegeben."
            }
            [pscustomobject]@{
                Label = "STATE 03"
                Title = "Processing"
                Text = "Die Zahlungsanforderung befindet sich in kontrollierter Verarbeitung."
            }
            [pscustomobject]@{
                Label = "STATE 04"
                Title = "Completed"
                Text = "Die Verarbeitung wurde mit einem erfolgreichen Endzustand abgeschlossen."
            }
            [pscustomobject]@{
                Label = "STATE 05"
                Title = "Failed"
                Text = "Die Verarbeitung wurde mit einem nachvollziehbaren Fehlerzustand beendet."
            }
            [pscustomobject]@{
                Label = "STATE 06"
                Title = "Reconciled"
                Text = "Das finale Ergebnis wurde geprüft und dem erwarteten Zustand zugeordnet."
            }
        )
        DataFile = "/products/corecraft-pay/data/capabilities.json"
    }

    [pscustomobject]@{
        Id = "checkout"
        Title = "CoreCraft Pay Checkout"
        Eyebrow = "CoreCraft Pay / Checkout"
        Description = "Checkout-Struktur für verständliche Auswahl, Bestätigung, Verarbeitung und Ergebnisdarstellung."
        Lead = "Der Checkout-Bereich organisiert den Weg von der Auswahl bis zur eindeutigen Rückmeldung über den Zahlungsstatus."
        IntroTitle = "Klarer Checkout-Ablauf"
        IntroText = "Ein kontrollierter Checkout reduziert uneindeutige Zustände und führt Nutzer nachvollziehbar durch Auswahl, Prüfung, Bestätigung und Ergebnis."
        Principles = @(
            "Klare Darstellung von Produkt und Zahlungsbetrag"
            "Prüfbare Auswahl vor der Bestätigung"
            "Eindeutige Rückmeldung während der Verarbeitung"
            "Verständlicher Erfolgs- oder Fehlerzustand"
            "Keine Verarbeitung sensibler Zahlungsdaten in statischen Seiten"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "STEP 01"
                Title = "Selection"
                Text = "Produkt, Leistung und relevante Optionen werden übersichtlich dargestellt."
            }
            [pscustomobject]@{
                Label = "STEP 02"
                Title = "Review"
                Text = "Auswahl und Betrag werden vor der Bestätigung erneut zusammengefasst."
            }
            [pscustomobject]@{
                Label = "STEP 03"
                Title = "Confirmation"
                Text = "Der Nutzer bestätigt den vorgesehenen Checkout-Ablauf."
            }
            [pscustomobject]@{
                Label = "STEP 04"
                Title = "Processing"
                Text = "Die Oberfläche zeigt einen klaren und kontrollierten Verarbeitungszustand."
            }
            [pscustomobject]@{
                Label = "STEP 05"
                Title = "Result"
                Text = "Der finale Erfolg oder Fehler wird eindeutig und verständlich angezeigt."
            }
            [pscustomobject]@{
                Label = "STEP 06"
                Title = "Reference"
                Text = "Das Ergebnis kann Referenz dokumentiert werden."
            }
        )
        DataFile = "/products/corecraft-pay/data/capabilities.json"
    }

    [pscustomobject]@{
        Id = "integrations"
        Title = "CoreCraft Pay Integrations"
        Eyebrow = "CoreCraft Pay / Integrations"
        Description = "Integrationsmodell für Checkout, Zahlungsoberflächen, Ereignisse und technische Schnittstellen."
        Lead = "Der Integrationsbereich beschreibt, wie CoreCraft Pay kontrolliert mit Anwendungen und technischen Diensten verbunden werden kann."
        IntroTitle = "Definierte Integrationspunkte"
        IntroText = "Integrationen benötigen klare Zuständigkeiten, dokumentierte Datenstrukturen und validierbare technische Übergänge."
        Principles = @(
            "Dokumentierte Integrationspunkte"
            "Versionierbare Daten- und Ereignismodelle"
            "Trennung von Darstellung und Verarbeitung"
            "Validierung eingehender und ausgehender Daten"
            "Nachvollziehbare Fehler- und Ergebniszustände"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "INTEGRATION"
                Title = "Web Checkout"
                Text = "Verbindet den Checkout-Bereich mit einer webbasierten Produktoberfläche."
            }
            [pscustomobject]@{
                Label = "INTEGRATION"
                Title = "Payment Interface"
                Text = "Definiert einen strukturierten Zugang zu zahlungsbezogenen Funktionen."
            }
            [pscustomobject]@{
                Label = "INTEGRATION"
                Title = "Developer Interface"
                Text = "Stellt nachvollziehbare Informationen für Entwicklung und Integration bereit."
            }
            [pscustomobject]@{
                Label = "INTEGRATION"
                Title = "Event Model"
                Text = "Beschreibt relevante technische Ereignisse und Statusänderungen."
            }
            [pscustomobject]@{
                Label = "INTEGRATION"
                Title = "Status Response"
                Text = "Liefert klare Ergebnisse für erfolgreiche und fehlerhafte Abläufe."
            }
            [pscustomobject]@{
                Label = "INTEGRATION"
                Title = "Audit Information"
                Text = "Ergänzt Integrationsabläufe um prüfbare technische Informationen."
            }
        )
        DataFile = "/products/corecraft-pay/data/integrations.json"
    }

    [pscustomobject]@{
        Id = "security"
        Title = "CoreCraft Pay Security"
        Eyebrow = "CoreCraft Pay / Security"
        Description = "Sicherheitsarchitektur, technische Grenzen und kontrollierte Schutzmaßnahmen für CoreCraft Pay."
        Lead = "Security definiert die technischen Regeln und Grenzen für einen sicheren CoreCraft-Pay-Produktbereich."
        IntroTitle = "Sicherheit durch klare Grenzen"
        IntroText = "Statische Produktseiten dokumentieren Funktionen und Architektur. Sensible Zahlungsinformationen und vertrauliche Zugangsdaten gehören nicht in statische Dateien."
        Principles = @(
            "Keine Speicherung sensibler Zahlungsdaten in statischen Seiten"
            "Keine Zugangsdaten oder Geheimnisse im Repository"
            "Validierung aller veröffentlichten JSON-Dateien"
            "Klare Trennung zwischen Dokumentation und Transaktionssystem"
            "Kontrollierte Revisionen über Git und lokale Audits"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "CONTROL 01"
                Title = "Data Boundary"
                Text = "Trennt öffentliche Produktinformationen von sensiblen Zahlungsdaten."
            }
            [pscustomobject]@{
                Label = "CONTROL 02"
                Title = "Secret Protection"
                Text = "Verhindert die Aufnahme von Zugangsdaten und geheimen Werten in das Repository."
            }
            [pscustomobject]@{
                Label = "CONTROL 03"
                Title = "Input Validation"
                Text = "Definiert die Prüfung von Daten vor einer technischen Verarbeitung."
            }
            [pscustomobject]@{
                Label = "CONTROL 04"
                Title = "Route Audit"
                Text = "Prüft erwartete lokale und veröffentlichte Produktadressen."
            }
            [pscustomobject]@{
                Label = "CONTROL 05"
                Title = "Asset Integrity"
                Text = "Kontrolliert erwartete Dateien sowie CSS- und JavaScript-Referenzen."
            }
            [pscustomobject]@{
                Label = "CONTROL 06"
                Title = "Change Trace"
                Text = "Macht Änderungen über Git-Historie und vollständige Audits nachvollziehbar."
            }
        )
        DataFile = "/products/corecraft-pay/data/architecture.json"
    }

    [pscustomobject]@{
        Id = "developer"
        Title = "CoreCraft Pay Developer"
        Eyebrow = "CoreCraft Pay / Developer"
        Description = "Technische Ressourcen für Entwicklung, Integration und kontrollierte Erweiterung von CoreCraft Pay."
        Lead = "Der Developer-Bereich bündelt gemeinsame Assets, strukturierte Daten, Routen und Regeln für die technische Pflege."
        IntroTitle = "Entwicklung mit klarer Struktur"
        IntroText = "Neue CoreCraft-Pay-Funktionen sollten dieselben gemeinsamen Assets, Routenregeln und Prüfverfahren verwenden."
        Principles = @(
            "Gemeinsame CSS- und JavaScript-Dateien verwenden"
            "Strukturierte JSON-Daten versionieren"
            "Seiten deterministisch über Generatoren erzeugen"
            "Lokale Links und Assets vor dem Commit prüfen"
            "Veröffentlichte Routen nach dem Deployment testen"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Shared Assets"
                Text = "Gemeinsames CSS und JavaScript für konsistente Produktseiten."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Structured Data"
                Text = "JSON-Dateien für Architektur, Fähigkeiten und Integrationen."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Page Generator"
                Text = "Kontrollierte Erzeugung vollständiger CoreCraft-Pay-Unterseiten."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Local Audit"
                Text = "Prüfung von Seiten, Links, Routen, Assets und JSON."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Live Audit"
                Text = "HTTP-Prüfung der veröffentlichten CoreCraft-Pay-Routen."
            }
            [pscustomobject]@{
                Label = "RESOURCE"
                Title = "Git Workflow"
                Text = "Versionierung und nachvollziehbare Veröffentlichung der Produktstruktur."
            }
        )
        DataFile = "/products/corecraft-pay/data/integrations.json"
    }

    [pscustomobject]@{
        Id = "demos"
        Title = "CoreCraft Pay Demos"
        Eyebrow = "CoreCraft Pay / Demos"
        Description = "Demonstrationsbereich für Checkout-Abläufe, Zahlungszustände, Integrationen und technische Prüfungen."
        Lead = "Die Demos zeigen zentrale CoreCraft-Pay-Konzepte anhand klar definierter und nicht produktiver Beispielszenarien."
        IntroTitle = "Nachvollziehbare Produktdemos"
        IntroText = "Demos verwenden ausschließlich beispielhafte Abläufe. Sie verarbeiten keine echten Zahlungsinformationen und führen keine realen Transaktionen aus."
        Principles = @(
            "Ausschließlich demonstrative Beispieldaten"
            "Keine realen Zahlungsinformationen"
            "Definierte Ausgangs- und Ergebniszustände"
            "Klare Darstellung von Statusänderungen"
            "Abschluss mit nachvollziehbarem Demo-Ergebnis"
        )
        Cards = @(
            [pscustomobject]@{
                Label = "DEMO 01"
                Title = "Checkout Flow"
                Text = "Zeigt einen beispielhaften Ablauf von Auswahl bis Ergebnis."
            }
            [pscustomobject]@{
                Label = "DEMO 02"
                Title = "Payment State"
                Text = "Visualisiert beispielhafte Zahlungszustände und Übergänge."
            }
            [pscustomobject]@{
                Label = "DEMO 03"
                Title = "Validation"
                Text = "Demonstriert die Prüfung von Beispieldaten vor der Verarbeitung."
            }
            [pscustomobject]@{
                Label = "DEMO 04"
                Title = "Integration Event"
                Text = "Zeigt ein beispielhaftes technisches Ereignismodell."
            }
            [pscustomobject]@{
                Label = "DEMO 05"
                Title = "Failure State"
                Text = "Stellt einen kontrollierten und nachvollziehbaren Fehlerzustand dar."
            }
            [pscustomobject]@{
                Label = "DEMO 06"
                Title = "Audit Result"
                Text = "Fasst den Demo-Ablauf in einem strukturierten Prüfergebnis zusammen."
            }
        )
        DataFile = "/products/corecraft-pay/data/capabilities.json"
    }
)

# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CORECRAFT PAY - COMPLETE PAGE GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ============================================================
# PRECHECK
# ============================================================

Write-Section "PRECHECK"

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Host "[FAIL] CoreCraft-Pay-Root fehlt." -ForegroundColor Red
    exit 1
}

Write-Host "[PASS] CoreCraft-Pay-Root vorhanden." -ForegroundColor Green

if (-not (Test-Path -LiteralPath $MainIndex -PathType Leaf)) {
    Write-Host "[FAIL] CoreCraft-Pay-Hauptseite fehlt." -ForegroundColor Red
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
    } else {
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
        New-Item `
            -ItemType Directory `
            -Path $Directory `
            -Force |
            Out-Null
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
    href="/products/corecraft-pay/assets/css/corecraft-pay.css"
  >
</head>

<body data-page="$($Page.Id)">

<header class="pay-header">
  <div class="pay-shell">
$Navigation
  </div>
</header>

<main>

  <section class="pay-hero">
    <div class="pay-shell">

      <div class="pay-eyebrow">
        $($Page.Eyebrow)
      </div>

      <h1>$($Page.Title)</h1>

      <p class="pay-lead">
        $($Page.Lead)
      </p>

      <div class="pay-actions">

        <a
          class="pay-button"
          href="#overview"
        >
          Bereich ansehen
        </a>

        <a
          class="pay-button pay-button-secondary"
          href="/products/corecraft-pay/"
        >
          CoreCraft Pay Übersicht
        </a>

      </div>

    </div>
  </section>

  <section class="pay-section" id="overview">
    <div class="pay-shell">

      <div class="pay-panel">

        <span class="pay-status">
          ACTIVE CORECRAFT PAY AREA
        </span>

        <h2>$($Page.IntroTitle)</h2>

        <p class="pay-lead">
          $($Page.IntroText)
        </p>

      </div>

    </div>
  </section>

  <section class="pay-section">
    <div class="pay-shell">

      <div class="pay-label">
        Product Components
      </div>

      <h2>Kernbereiche</h2>

      <div class="pay-grid">
$CardsHtml
      </div>

    </div>
  </section>

  <section class="pay-section">
    <div class="pay-shell">

      <div class="pay-grid">

        <article class="pay-card">

          <span class="pay-status">
            PRINCIPLES
          </span>

          <h2>Grundsätze</h2>

          <ul class="pay-list">
$PrincipleList
          </ul>

        </article>

        <article class="pay-card">

          <span class="pay-status">
            STRUCTURED DATA
          </span>

          <h2>Technische Daten</h2>

          <p>
            Der Bereich verwendet strukturierte CoreCraft-Pay-Daten
            und gemeinsame technische Assets.
          </p>

          <p>
            <a href="$($Page.DataFile)">
              Zugehörige JSON-Daten öffnen
            </a>
          </p>

        </article>

        <article class="pay-card">

          <span class="pay-status">
            VALIDATION
          </span>

          <h2>Prüfung</h2>

          <p>
            Seiten, Routen, Links, JSON-Daten und Asset-Verweise
            werden vor der Veröffentlichung lokal validiert.
          </p>

        </article>

      </div>

    </div>
  </section>

  <section class="pay-section">
    <div class="pay-shell">
$AreaNavigation
    </div>
  </section>

</main>

<footer class="pay-footer">
  <div class="pay-shell">

    <p>
      &copy;
      <span data-pay-year>2026</span>
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

<script src="/products/corecraft-pay/assets/js/corecraft-pay.js"></script>
<script src="/products/corecraft-pay/assets/js/ui.js"></script>

</body>
</html>
"@

    Set-Content `
        -LiteralPath $OutputPath `
        -Value $Html `
        -Encoding utf8

    $GeneratedFile = Get-Item -LiteralPath $OutputPath

    $GenerationResults += [pscustomobject]@{
        Page = $Page.Id
        Path = $OutputPath
        Bytes = $GeneratedFile.Length
    }

    Write-Host (
        "[CREATE] {0,-32} {1,8} bytes" -f
        "$($Page.Id)\index.html",
        $GeneratedFile.Length
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
    } else {
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

        if ($Content -notmatch 'corecraft-pay\.css') {
            $Status = "FAIL"
            $Message = "CSS-Verweis fehlt"
        }

        if ($Content -notmatch 'corecraft-pay\.js') {
            $Status = "FAIL"
            $Message = "corecraft-pay.js-Verweis fehlt"
        }

        if ($Content -notmatch 'ui\.js') {
            $Status = "FAIL"
            $Message = "ui.js-Verweis fehlt"
        }

        if ($Content -notmatch 'Weitere Produktbereiche') {
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
    } else {
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

$MainProtected = (
    $MainHashBefore -eq $MainHashAfter
)

if ($MainProtected) {
    Write-Host "[PASS] Hauptseite blieb unverändert." -ForegroundColor Green
} else {
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
Write-Host " CORECRAFT PAY - PAGE SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ("Pages expected : {0}" -f $Pages.Count)
Write-Host ("Pages generated: {0}" -f $GenerationResults.Count)

Write-Host (
    "Pages passed   : {0}" -f
    ($Pages.Count - $PageFailures.Count)
)

Write-Host ("Pages failed   : {0}" -f $PageFailures.Count)
Write-Host ("Main protected : {0}" -f $MainProtected)
Write-Host ("Total failures : {0}" -f $TotalFailures)

Write-Host ""
Write-Host "============================================================"

if ($TotalFailures -eq 0) {
    Write-Host (
        "[PASS] COMPLETE CORECRAFT PAY PAGES GENERATED"
    ) -ForegroundColor Green

    Write-Host "============================================================"

    exit 0
}

Write-Host (
    "[FAIL] CORECRAFT PAY PAGE GENERATION FAILED"
) -ForegroundColor Red

Write-Host "============================================================"

exit 1