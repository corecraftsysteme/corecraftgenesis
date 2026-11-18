#requires -Version 7.0

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis.ch\products\audio"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "CoreCraft Genesis - Audio Subpage Setup" -ForegroundColor Cyan
Write-Host "Root: $Root"
Write-Host ""

# ------------------------------------------------------------
# KONFIGURATION
# ------------------------------------------------------------

$Pages = @(
    [ordered]@{
        Slug = "audiostate"
        Number = "01"
        Label = "Audio Architecture"
        Title = "AudioState Architecture"
        Hero = "Controlled audio states."
        Description = @"
AudioState Architecture strukturiert Audiozustände, Übergänge,
Verantwortlichkeiten und Verarbeitungsschritte innerhalb eines
nachvollziehbaren technischen Modells.
"@
        Status = "AUDIOSTATE READY"
        Features = @(
            [ordered]@{
                Number = "01"
                Title = "State Definition"
                Text = "Explizite Definition von Audiozuständen wie Idle, Ready, Running, Suspended und Error."
            }
            [ordered]@{
                Number = "02"
                Title = "State Transitions"
                Text = "Kontrollierte Übergänge zwischen definierten Audiozuständen und Verarbeitungsschritten."
            }
            [ordered]@{
                Number = "03"
                Title = "State Ownership"
                Text = "Klare Zuordnung der Verantwortung für Zustand, Verarbeitung und Ergebnis."
            }
            [ordered]@{
                Number = "04"
                Title = "Event Handling"
                Text = "Strukturierte Verarbeitung technischer Ereignisse und Zustandsänderungen."
            }
            [ordered]@{
                Number = "05"
                Title = "Persistence"
                Text = "Nachvollziehbare Speicherung und Wiederherstellung relevanter Audiozustände."
            }
            [ordered]@{
                Number = "06"
                Title = "Traceability"
                Text = "Dokumentierte Zustandsfolgen für Diagnose, Prüfung und technische Auswertung."
            }
        )
        Workflow = @(
            "Audioquelle initialisieren"
            "Audiozustand bestimmen"
            "Übergang validieren"
            "Verarbeitung ausführen"
            "Ergebnis dokumentieren"
        )
    }

    [ordered]@{
        Slug = "dsp"
        Number = "02"
        Label = "Digital Signal Processing"
        Title = "Digital Signal Processing"
        Hero = "Structured signal processing."
        Description = @"
Der DSP-Bereich beschreibt kontrollierte Signalverarbeitung,
modulare Verarbeitungsketten, Parameterverwaltung und technische
Analyse digitaler Audiosignale.
"@
        Status = "DSP PIPELINE READY"
        Features = @(
            [ordered]@{
                Number = "01"
                Title = "Signal Input"
                Text = "Kontrollierte Aufnahme oder Übergabe digitaler Audiosignale."
            }
            [ordered]@{
                Number = "02"
                Title = "Filtering"
                Text = "Strukturierte Filterstufen für Frequenz- und Signalbearbeitung."
            }
            [ordered]@{
                Number = "03"
                Title = "Level Control"
                Text = "Verwaltung von Pegeln, Verstärkung und technischen Grenzwerten."
            }
            [ordered]@{
                Number = "04"
                Title = "Frequency Analysis"
                Text = "Analyse von Frequenzbereichen und Signalmerkmalen."
            }
            [ordered]@{
                Number = "05"
                Title = "Processing Chain"
                Text = "Modulare Reihenfolge einzelner Verarbeitungskomponenten."
            }
            [ordered]@{
                Number = "06"
                Title = "Signal Output"
                Text = "Kontrollierte Ausgabe und Weitergabe des verarbeiteten Signals."
            }
        )
        Workflow = @(
            "Signal empfangen"
            "Signalparameter erfassen"
            "Verarbeitungskette aufbauen"
            "DSP-Komponenten ausführen"
            "Ausgangssignal prüfen"
        )
    }

    [ordered]@{
        Slug = "orchestration"
        Number = "03"
        Label = "Audio Orchestration"
        Title = "Audio Orchestration"
        Hero = "Coordinated audio workflows."
        Description = @"
Audio Orchestration koordiniert Audio-Komponenten, technische
Abhängigkeiten, Verarbeitungsschritte und Übergaben innerhalb
eines gemeinsamen Audio-Workflows.
"@
        Status = "ORCHESTRATION ACTIVE"
        Features = @(
            [ordered]@{
                Number = "01"
                Title = "Component Registry"
                Text = "Zentrale Erfassung verfügbarer Audio-Komponenten und ihrer Verantwortlichkeiten."
            }
            [ordered]@{
                Number = "02"
                Title = "Dependency Control"
                Text = "Kontrollierte Verwaltung technischer Abhängigkeiten zwischen Komponenten."
            }
            [ordered]@{
                Number = "03"
                Title = "Execution Order"
                Text = "Definierte Reihenfolge für Audio- und Verarbeitungsschritte."
            }
            [ordered]@{
                Number = "04"
                Title = "Handoff Contracts"
                Text = "Explizite Übergaberegeln zwischen Modulen und Verarbeitungsebenen."
            }
            [ordered]@{
                Number = "05"
                Title = "Workflow State"
                Text = "Nachvollziehbarer Gesamtzustand eines orchestrierten Audio-Workflows."
            }
            [ordered]@{
                Number = "06"
                Title = "Result Coordination"
                Text = "Zusammenführung und Prüfung technischer Teilergebnisse."
            }
        )
        Workflow = @(
            "Komponenten registrieren"
            "Abhängigkeiten prüfen"
            "Ausführungsreihenfolge bestimmen"
            "Module koordinieren"
            "Gesamtergebnis übergeben"
        )
    }

    [ordered]@{
        Slug = "validation"
        Number = "04"
        Label = "State Validation"
        Title = "State Validation"
        Hero = "Validatable audio states."
        Description = @"
State Validation prüft Audiozustände, Parameter, Übergänge und
technische Ergebnisse anhand expliziter Regeln und definierter
Akzeptanzbedingungen.
"@
        Status = "VALIDATION ENABLED"
        Features = @(
            [ordered]@{
                Number = "01"
                Title = "Schema Validation"
                Text = "Prüfung strukturierter Audio- und Zustandsdaten gegen definierte Schemata."
            }
            [ordered]@{
                Number = "02"
                Title = "Transition Rules"
                Text = "Validierung erlaubter und nicht erlaubter Zustandsübergänge."
            }
            [ordered]@{
                Number = "03"
                Title = "Parameter Limits"
                Text = "Kontrolle technischer Werte, Bereiche und Grenzbedingungen."
            }
            [ordered]@{
                Number = "04"
                Title = "Integrity Checks"
                Text = "Prüfung auf Vollständigkeit, Konsistenz und technische Integrität."
            }
            [ordered]@{
                Number = "05"
                Title = "Error Classification"
                Text = "Eindeutige Klassifizierung erkannter Validierungsfehler."
            }
            [ordered]@{
                Number = "06"
                Title = "Validation Reports"
                Text = "Strukturierte Ausgabe von Prüfergebnissen und Abweichungen."
            }
        )
        Workflow = @(
            "Eingangsdaten erfassen"
            "Schema prüfen"
            "Übergangsregeln validieren"
            "Integrität bestätigen"
            "Prüfbericht erzeugen"
        )
    }

    [ordered]@{
        Slug = "scaling"
        Number = "05"
        Label = "Scaling and Failover"
        Title = "Scaling and Failover"
        Hero = "Resilient audio infrastructure."
        Description = @"
Scaling and Failover beschreibt technische Modelle für
Lastverteilung, Kapazitätssteuerung, Fehlererkennung,
Wiederherstellung und widerstandsfähige Audio-Systeme.
"@
        Status = "RESILIENCE READY"
        Features = @(
            [ordered]@{
                Number = "01"
                Title = "Capacity Management"
                Text = "Kontrollierte Verwaltung verfügbarer Verarbeitungskapazitäten."
            }
            [ordered]@{
                Number = "02"
                Title = "Load Distribution"
                Text = "Verteilung technischer Audio-Workloads auf verfügbare Komponenten."
            }
            [ordered]@{
                Number = "03"
                Title = "Health Monitoring"
                Text = "Überwachung relevanter Zustände und technischer Verfügbarkeit."
            }
            [ordered]@{
                Number = "04"
                Title = "Failure Detection"
                Text = "Erkennung definierter Fehler- und Ausfallzustände."
            }
            [ordered]@{
                Number = "05"
                Title = "Failover"
                Text = "Kontrollierte Übergabe auf alternative Komponenten oder Verarbeitungspfade."
            }
            [ordered]@{
                Number = "06"
                Title = "Recovery"
                Text = "Strukturierte Wiederherstellung nach Fehlern oder Unterbrechungen."
            }
        )
        Workflow = @(
            "Kapazität erfassen"
            "Systemzustand überwachen"
            "Ausfall erkennen"
            "Failover auslösen"
            "Verarbeitung wiederherstellen"
        )
    }

    [ordered]@{
        Slug = "diagnostics"
        Number = "06"
        Label = "Audio Diagnostics"
        Title = "Audio Diagnostics"
        Hero = "Traceable audio diagnostics."
        Description = @"
Audio Diagnostics stellt strukturierte Verfahren für
Signalbeobachtung, Zustandsanalyse, Fehlerklassifizierung,
Berichterstellung und technische Nachvollziehbarkeit bereit.
"@
        Status = "DIAGNOSTICS ONLINE"
        Features = @(
            [ordered]@{
                Number = "01"
                Title = "Signal Monitoring"
                Text = "Beobachtung technischer Signalwerte und Verarbeitungszustände."
            }
            [ordered]@{
                Number = "02"
                Title = "State Inspection"
                Text = "Analyse aktueller und vorheriger Audiozustände."
            }
            [ordered]@{
                Number = "03"
                Title = "Event Logs"
                Text = "Dokumentation wichtiger technischer Ereignisse und Übergänge."
            }
            [ordered]@{
                Number = "04"
                Title = "Error Analysis"
                Text = "Strukturierte Untersuchung erkannter Fehler und Abweichungen."
            }
            [ordered]@{
                Number = "05"
                Title = "Diagnostic Reports"
                Text = "Erzeugung nachvollziehbarer technischer Diagnoseberichte."
            }
            [ordered]@{
                Number = "06"
                Title = "Audit Trail"
                Text = "Vollständige Nachverfolgung relevanter Zustände und Verarbeitungsschritte."
            }
        )
        Workflow = @(
            "Messwerte erfassen"
            "Zustände analysieren"
            "Abweichungen klassifizieren"
            "Ursache dokumentieren"
            "Diagnosebericht erzeugen"
        )
    }
)

# ------------------------------------------------------------
# HILFSFUNKTIONEN
# ------------------------------------------------------------

function ConvertTo-HtmlText {
    param(
        [AllowEmptyString()]
        [string]$Text
    )

    return [System.Net.WebUtility]::HtmlEncode($Text.Trim())
}

function New-FeatureCardsHtml {
    param(
        [Parameter(Mandatory)]
        [array]$Features
    )

    $Cards = foreach ($Feature in $Features) {
        $Number = ConvertTo-HtmlText $Feature.Number
        $Title = ConvertTo-HtmlText $Feature.Title
        $Text = ConvertTo-HtmlText $Feature.Text

@"
        <article class="card">
          <span class="card-number">$Number</span>
          <h3>$Title</h3>
          <p>$Text</p>
        </article>
"@
    }

    return $Cards -join "`r`n"
}

function New-WorkflowHtml {
    param(
        [Parameter(Mandatory)]
        [array]$Workflow
    )

    $Rows = for ($Index = 0; $Index -lt $Workflow.Count; $Index++) {
        $Number = "{0:D2}" -f ($Index + 1)
        $Text = ConvertTo-HtmlText $Workflow[$Index]

@"
        <div class="workflow-row">
          <span>$Number</span>
          <strong>$Text</strong>
        </div>
"@
    }

    return $Rows -join "`r`n"
}

function New-AudioPageHtml {
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Page
    )

    $Slug = ConvertTo-HtmlText $Page.Slug
    $Number = ConvertTo-HtmlText $Page.Number
    $Label = ConvertTo-HtmlText $Page.Label
    $Title = ConvertTo-HtmlText $Page.Title
    $Hero = ConvertTo-HtmlText $Page.Hero
    $Description = ConvertTo-HtmlText $Page.Description
    $Status = ConvertTo-HtmlText $Page.Status

    $FeatureCards = New-FeatureCardsHtml -Features $Page.Features
    $WorkflowRows = New-WorkflowHtml -Workflow $Page.Workflow

    return @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>$Title | CoreCraft Genesis</title>

  <meta name="description" content="$Description">

  <style>
    :root {
      --bg: #05070a;
      --surface: #0c1118;
      --surface-light: #111924;
      --line: #1d2938;
      --text: #f4f7fb;
      --muted: #95a2b3;
      --blue: #4ea1ff;
      --green: #42d392;
      --max: 1180px;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html {
      scroll-behavior: smooth;
    }

    body {
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
          circle at 70% -10%,
          #102c4a 0,
          transparent 28%
        ),
        var(--bg);

      color: var(--text);
      line-height: 1.6;
    }

    a {
      color: inherit;
      text-decoration: none;
    }

    .container {
      width: min(92%, var(--max));
      margin: auto;
    }

    header {
      position: sticky;
      top: 0;
      z-index: 100;

      background: rgba(5, 7, 10, .88);
      backdrop-filter: blur(18px);

      border-bottom: 1px solid rgba(255,255,255,.06);
    }

    nav {
      min-height: 72px;

      display: flex;
      align-items: center;
      justify-content: space-between;

      gap: 30px;
    }

    .brand {
      font-weight: 750;
      letter-spacing: -.03em;
      font-size: 1.1rem;
    }

    .brand span {
      color: var(--blue);
    }

    .nav-links {
      display: flex;
      align-items: center;
      flex-wrap: wrap;

      gap: 25px;

      color: var(--muted);
      font-size: .92rem;
    }

    .nav-links a:hover,
    .nav-links .active {
      color: white;
    }

    .nav-button {
      padding: 9px 16px;

      border: 1px solid var(--line);
      border-radius: 8px;
    }

    .breadcrumb {
      padding-top: 45px;

      color: var(--muted);
      font-size: .85rem;
    }

    .breadcrumb a:hover {
      color: var(--blue);
    }

    .breadcrumb span {
      margin: 0 8px;
      color: #526174;
    }

    .hero {
      min-height: 620px;

      display: grid;
      grid-template-columns: 1.1fr .9fr;
      align-items: center;

      gap: 70px;
      padding: 70px 0 110px;
    }

    .eyebrow,
    .section-label {
      color: var(--blue);

      text-transform: uppercase;
      letter-spacing: .13em;

      font-weight: 700;
      font-size: .77rem;
    }

    .eyebrow {
      margin-bottom: 20px;
    }

    h1 {
      max-width: 900px;

      font-size: clamp(3.4rem, 8vw, 7rem);
      line-height: .92;
      letter-spacing: -.065em;
    }

    h2 {
      max-width: 900px;

      margin: 12px 0 22px;

      font-size: clamp(2.2rem, 5vw, 4rem);
      line-height: 1.05;
      letter-spacing: -.045em;
    }

    .hero p {
      max-width: 720px;
      margin: 30px 0;

      color: var(--muted);
      font-size: 1.15rem;
    }

    .lead {
      max-width: 780px;
      margin-bottom: 45px;

      color: var(--muted);
      font-size: 1.07rem;
    }

    .buttons {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
    }

    .button {
      display: inline-flex;
      align-items: center;
      justify-content: center;

      padding: 13px 20px;

      border: 1px solid var(--line);
      border-radius: 8px;

      font-size: .93rem;
      font-weight: 650;

      transition: .2s ease;
    }

    .button-primary {
      background: var(--blue);
      border-color: var(--blue);
      color: #001326;
    }

    .button:hover {
      transform: translateY(-2px);
      border-color: #45617e;
    }

    .system-panel {
      padding: 35px;

      background:
        linear-gradient(
          145deg,
          rgba(78,161,255,.08),
          transparent
        ),
        var(--surface);

      border: 1px solid var(--line);
      border-radius: 20px;
    }

    .status {
      margin-bottom: 25px;

      color: var(--green);
      font-family: monospace;
      font-size: .8rem;
    }

    .system-path {
      margin-bottom: 20px;

      color: var(--muted);
      font-family: monospace;
      font-size: .8rem;
    }

    .system-item {
      display: flex;
      justify-content: space-between;
      gap: 20px;

      padding: 15px 0;

      border-top: 1px solid var(--line);

      font-family: monospace;
      font-size: .82rem;
    }

    .system-item span:last-child {
      color: var(--green);
      text-align: right;
    }

    section {
      padding: 100px 0;
    }

    .capabilities {
      background: rgba(255,255,255,.015);

      border-top: 1px solid var(--line);
      border-bottom: 1px solid var(--line);
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 18px;
    }

    .card {
      min-height: 260px;
      padding: 28px;

      background: var(--surface);

      border: 1px solid var(--line);
      border-radius: 14px;

      transition: .22s ease;
    }

    .card:hover {
      transform: translateY(-4px);

      border-color: #3a5878;
      background: var(--surface-light);
    }

    .card-number {
      color: var(--blue);
      font-family: monospace;
      font-size: .75rem;
    }

    .card h3 {
      margin: 25px 0 10px;
      font-size: 1.22rem;
    }

    .card p {
      color: var(--muted);
      font-size: .93rem;
    }

    .workflow-layout {
      display: grid;
      grid-template-columns: .85fr 1.15fr;
      gap: 70px;
      align-items: start;
    }

    .workflow-list {
      border-top: 1px solid var(--line);
    }

    .workflow-row {
      display: grid;
      grid-template-columns: 70px 1fr;
      gap: 20px;

      padding: 20px 0;

      border-bottom: 1px solid var(--line);
    }

    .workflow-row span {
      color: var(--blue);
      font-family: monospace;
    }

    .cta {
      padding: 60px;

      background:
        linear-gradient(
          125deg,
          rgba(78,161,255,.15),
          transparent
        ),
        var(--surface);

      border: 1px solid var(--line);
      border-radius: 22px;
    }

    footer {
      padding: 55px 0;

      border-top: 1px solid var(--line);

      color: var(--muted);
    }

    .footer-grid {
      display: grid;
      grid-template-columns: 2fr 1fr 1fr 1fr;
      gap: 40px;
    }

    footer h4 {
      color: white;
      margin-bottom: 15px;
    }

    footer a {
      display: block;
      margin: 8px 0;
      font-size: .9rem;
    }

    footer a:hover {
      color: white;
    }

    .footer-description {
      max-width: 360px;
      margin-top: 15px;
    }

    .copyright {
      margin-top: 45px;
      padding-top: 30px;

      border-top: 1px solid var(--line);

      font-size: .82rem;
    }

    @media (max-width: 900px) {
      .hero,
      .workflow-layout {
        min-height: auto;
        grid-template-columns: 1fr;
      }

      .grid {
        grid-template-columns: 1fr 1fr;
      }

      .footer-grid {
        grid-template-columns: 1fr 1fr;
      }
    }

    @media (max-width: 600px) {
      .nav-links {
        display: none;
      }

      .grid,
      .footer-grid {
        grid-template-columns: 1fr;
      }

      .hero {
        padding-top: 45px;
      }

      .cta {
        padding: 35px 25px;
      }

      .system-item {
        flex-direction: column;
        gap: 3px;
      }

      .system-item span:last-child {
        text-align: left;
      }
    }
  </style>
</head>

<body>

<header>
  <div class="container">
    <nav>

      <a class="brand" href="/">
        CoreCraft <span>Genesis</span>
      </a>

      <div class="nav-links">
        <a class="active" href="/products/">Produkte</a>
        <a href="/solutions/">Solutions</a>
        <a href="/docs/">Docs</a>
        <a href="/pricing/">Preise</a>
        <a href="/blog/">Research</a>
        <a href="/about/">Über uns</a>
        <a class="nav-button" href="/account/">Account</a>
      </div>

    </nav>
  </div>
</header>

<main>

  <div class="container breadcrumb">

    <a href="/">Home</a>
    <span>/</span>

    <a href="/products/">Produkte</a>
    <span>/</span>

    <a href="/products/audio/">Audio</a>
    <span>/</span>

    $Title

  </div>

  <section class="container hero">

    <div>

      <div class="eyebrow">
        $Label
      </div>

      <h1>
        $Hero
      </h1>

      <p>
        $Description
      </p>

      <div class="buttons">

        <a class="button button-primary" href="#capabilities">
          Funktionen ansehen
        </a>

        <a class="button" href="#workflow">
          Workflow öffnen
        </a>

      </div>

    </div>

    <div class="system-panel">

      <div class="status">
        ● $Status
      </div>

      <div class="system-path">
        /products/audio/$Slug/
      </div>

      <div class="system-item">
        <span>MODULE</span>
        <span>$Title</span>
      </div>

      <div class="system-item">
        <span>PRODUCT</span>
        <span>AUDIO</span>
      </div>

      <div class="system-item">
        <span>STRUCTURE</span>
        <span>MODULAR</span>
      </div>

      <div class="system-item">
        <span>VALIDATION</span>
        <span>ENABLED</span>
      </div>

      <div class="system-item">
        <span>STATUS</span>
        <span>ACTIVE</span>
      </div>

    </div>

  </section>

  <section class="capabilities" id="capabilities">

    <div class="container">

      <div class="section-label">
        Audio Capability $Number
      </div>

      <h2>
        $Title
      </h2>

      <p class="lead">
        Der Bereich ist in klar definierte technische
        Funktionen und Verantwortlichkeiten gegliedert.
      </p>

      <div class="grid">
$FeatureCards
      </div>

    </div>

  </section>

  <section class="container" id="workflow">

    <div class="workflow-layout">

      <div>

        <div class="section-label">
          Technical Workflow
        </div>

        <h2>
          Strukturierter Ablauf.
        </h2>

        <p class="lead">
          Der Workflow bildet die wichtigsten technischen
          Schritte dieses Audio-Bereichs in einer
          nachvollziehbaren Reihenfolge ab.
        </p>

      </div>

      <div class="workflow-list">
$WorkflowRows
      </div>

    </div>

  </section>

  <section class="container">

    <div class="cta">

      <div class="section-label">
        CoreCraft Genesis Audio
      </div>

      <h2>
        $Title weiter erkunden.
      </h2>

      <p class="lead">
        Kehre zur Audio-Übersicht zurück, öffne die
        Dokumentation oder wechsle zu einem anderen
        Audio-Modul.
      </p>

      <div class="buttons">

        <a class="button button-primary" href="/products/audio/">
          Audio-Übersicht
        </a>

        <a class="button" href="/docs/">
          Dokumentation
        </a>

        <a class="button" href="/contact/">
          Kontakt
        </a>

      </div>

    </div>

  </section>

</main>

<footer>

  <div class="container">

    <div class="footer-grid">

      <div>

        <div class="brand">
          CoreCraft <span>Genesis</span>
        </div>

        <p class="footer-description">
          Engineering Deterministic Systems,
          Digital Infrastructure,
          Blockchain Intelligence and Knowledge Products.
        </p>

      </div>

      <div>

        <h4>Audio</h4>

        <a href="/products/audio/audiostate/">
          AudioState
        </a>

        <a href="/products/audio/dsp/">
          DSP
        </a>

        <a href="/products/audio/orchestration/">
          Orchestration
        </a>

        <a href="/products/audio/validation/">
          Validation
        </a>

      </div>

      <div>

        <h4>Resilience</h4>

        <a href="/products/audio/scaling/">
          Scaling &amp; Failover
        </a>

        <a href="/products/audio/diagnostics/">
          Diagnostics
        </a>

        <a href="/products/audio/">
          Audio Overview
        </a>

        <a href="/products/">
          All Products
        </a>

      </div>

      <div>

        <h4>CoreCraft</h4>

        <a href="/docs/">
          Docs
        </a>

        <a href="/downloads/">
          Downloads
        </a>

        <a href="/support/">
          Support
        </a>

        <a href="/contact/">
          Kontakt
        </a>

      </div>

    </div>

    <div class="copyright">
      © 2026 CoreCraft Genesis · Audio · $Title
    </div>

  </div>

</footer>

</body>
</html>
"@
}

# ------------------------------------------------------------
# VORBEREITUNG
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    New-Item `
        -ItemType Directory `
        -Path $Root `
        -Force | Out-Null

    Write-Host "[CREATE] Root: $Root" -ForegroundColor Green
}

$BackupRoot = Join-Path $Root (
    "_backup_audio_subpages_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss")
)

New-Item `
    -ItemType Directory `
    -Path $BackupRoot `
    -Force | Out-Null

Write-Host "[CREATE] Backup: $BackupRoot" -ForegroundColor DarkGray
Write-Host ""

# ------------------------------------------------------------
# SEITEN ERSTELLEN
# ------------------------------------------------------------

$CreationResults = foreach ($Page in $Pages) {
    $Directory = Join-Path $Root $Page.Slug
    $IndexFile = Join-Path $Directory "index.html"

    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        New-Item `
            -ItemType Directory `
            -Path $Directory `
            -Force | Out-Null

        Write-Host "[DIR   ] $Directory" -ForegroundColor Cyan
    }

    if (Test-Path -LiteralPath $IndexFile -PathType Leaf) {
        $BackupFile = Join-Path $BackupRoot (
            "{0}_index.html" -f $Page.Slug
        )

        Copy-Item `
            -LiteralPath $IndexFile `
            -Destination $BackupFile `
            -Force

        Write-Host "[BACKUP] $BackupFile" -ForegroundColor DarkYellow
    }

    $Html = New-AudioPageHtml -Page $Page

    Set-Content `
        -LiteralPath $IndexFile `
        -Value $Html `
        -Encoding utf8

    $Item = Get-Item -LiteralPath $IndexFile

    Write-Host "[CREATE] $IndexFile" -ForegroundColor Green

    [pscustomobject]@{
        Module = $Page.Title
        Route = "/products/audio/$($Page.Slug)/"
        File = $IndexFile
        Bytes = $Item.Length
    }
}

# ------------------------------------------------------------
# VALIDIERUNG
# ------------------------------------------------------------

Write-Host ""
Write-Host "Validiere erzeugte Dateien ..." -ForegroundColor Cyan
Write-Host ""

$ValidationResults = foreach ($Result in $CreationResults) {
    $Content = Get-Content -LiteralPath $Result.File -Raw

    $HasDoctype = $Content -match '(?i)<!DOCTYPE html>'
    $HasHtmlStart = $Content -match '(?i)<html lang="de">'
    $HasHead = $Content -match '(?i)<head>'
    $HasBody = $Content -match '(?i)<body>'
    $HasTitle = $Content -match '(?i)<title>.+?</title>'
    $HasHtmlEnd = $Content -match '(?i)</html>'
    $HasBreadcrumb = $Content -match '/products/audio/'
    $EnoughContent = $Result.Bytes -gt 5000

    $Status = if (
        $HasDoctype -and
        $HasHtmlStart -and
        $HasHead -and
        $HasBody -and
        $HasTitle -and
        $HasHtmlEnd -and
        $HasBreadcrumb -and
        $EnoughContent
    ) {
        "PASS"
    }
    else {
        "INVALID"
    }

    [pscustomobject]@{
        Status = $Status
        Module = $Result.Module
        Bytes = $Result.Bytes
        Doctype = $HasDoctype
        Title = $HasTitle
        HtmlEnd = $HasHtmlEnd
        Route = $Result.Route
        File = $Result.File
    }
}

$ValidationResults |
    Format-Table `
        Status,
        Module,
        Bytes,
        Doctype,
        Title,
        HtmlEnd,
        Route `
        -AutoSize

# ------------------------------------------------------------
# REPORTS
# ------------------------------------------------------------

$CsvReport = Join-Path $Root "audio-subpages-report.csv"
$JsonReport = Join-Path $Root "audio-subpages-report.json"

$ValidationResults |
    Export-Csv `
        -LiteralPath $CsvReport `
        -NoTypeInformation `
        -Encoding utf8

$ValidationResults |
    ConvertTo-Json -Depth 5 |
    Set-Content `
        -LiteralPath $JsonReport `
        -Encoding utf8

# ------------------------------------------------------------
# ABSCHLUSS
# ------------------------------------------------------------

$Failed = @(
    $ValidationResults |
    Where-Object Status -ne "PASS"
)

Write-Host ""
Write-Host "------------------------------------------------------------"

if ($Failed.Count -eq 0) {
    Write-Host "[PASS] Alle sechs Audio-Unterseiten wurden erstellt." `
        -ForegroundColor Green

    Write-Host "[PASS] Alle sechs HTML-Dateien wurden validiert." `
        -ForegroundColor Green

    Write-Host "[PASS] CSV-Bericht: $CsvReport" `
        -ForegroundColor Green

    Write-Host "[PASS] JSON-Bericht: $JsonReport" `
        -ForegroundColor Green

    Write-Host "[INFO] Backup: $BackupRoot" `
        -ForegroundColor DarkGray

    exit 0
}

Write-Host "[FAIL] Fehlerhafte Audio-Unterseiten: $($Failed.Count)" `
    -ForegroundColor Red

$Failed |
    Format-Table Status, Module, File -AutoSize

Write-Host "[INFO] Backup: $BackupRoot" `
    -ForegroundColor DarkGray

exit 1