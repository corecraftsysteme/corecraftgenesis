#requires -Version 7.0

[CmdletBinding()]
param(
    [string]$Root = "C:\corecraftgenesis.ch\products"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Products = @(
    [ordered]@{
        Slug = "audio"
        Number = "01"
        Category = "Audio Technology"
        Title = "Audio"
        Hero = "Structured audio technology."
        Description = "Der Audio-Bereich von CoreCraft Genesis bündelt AudioState-Architektur, DSP-bezogene Konzepte, Signalverarbeitung und technische Ressourcen für kontrollierte Audio-Workflows."
        Status = "AUDIO SYSTEMS"
        PrimaryLabel = "Audio-Dokumentation"
        PrimaryUrl = "/docs/audio/"
        Features = @(
            [ordered]@{
                Title = "AudioState Architecture"
                Text = "Strukturierte Verwaltung, Verarbeitung und Übergabe technischer Audiozustände."
            }
            [ordered]@{
                Title = "DSP Concepts"
                Text = "Technische Konzepte und Ressourcen für digitale Signalverarbeitung."
            }
            [ordered]@{
                Title = "Audio Orchestration"
                Text = "Koordination modularer Audio-Komponenten und Verarbeitungsschritte."
            }
            [ordered]@{
                Title = "State Validation"
                Text = "Prüfung definierter Audiozustände und kontrollierter Übergänge."
            }
            [ordered]@{
                Title = "Scaling & Failover"
                Text = "Architekturansätze für skalierbare und widerstandsfähige Audio-Systeme."
            }
            [ordered]@{
                Title = "Audio Diagnostics"
                Text = "Nachvollziehbare Diagnose- und Analyseprozesse für Audio-Komponenten."
            }
        )
        Areas = @(
            "AudioState"
            "Digital Signal Processing"
            "Audio Orchestration"
            "State Compliance"
            "Scaling & Failover"
            "Audio Diagnostics"
        )
    }

    [ordered]@{
        Slug = "bitcoin-mining"
        Number = "02"
        Category = "Mining Infrastructure"
        Title = "Bitcoin Mining"
        Hero = "Intelligence for mining infrastructure."
        Description = "Der Bitcoin-Mining-Bereich bündelt technische Ressourcen für Mining-Infrastruktur, Mempool Intelligence, Gebührenmärkte, Netzwerkbeobachtung und strukturierte Analyseprodukte."
        Status = "MINING INTELLIGENCE"
        PrimaryLabel = "Mining-Ressourcen"
        PrimaryUrl = "/docs/bitcoin-mining/"
        Features = @(
            [ordered]@{
                Title = "Mempool Intelligence"
                Text = "Strukturierte Beobachtung und Auswertung von Mempool- und Transaktionsdaten."
            }
            [ordered]@{
                Title = "Fee Market Research"
                Text = "Technische Analyse von Gebührenstrukturen und Netzwerkbedingungen."
            }
            [ordered]@{
                Title = "Mining Infrastructure"
                Text = "Ressourcen für Aufbau, Dokumentation und Bewertung von Mining-Systemen."
            }
            [ordered]@{
                Title = "Network Monitoring"
                Text = "Beobachtung technischer Netzwerkzustände und relevanter Infrastrukturwerte."
            }
            [ordered]@{
                Title = "Operational Audit"
                Text = "Nachvollziehbare Prüfung von Abläufen, Strukturen und Ergebnissen."
            }
            [ordered]@{
                Title = "Knowledge Packs"
                Text = "Dokumentations- und Analysepakete für Mining-bezogene Projekte."
            }
        )
        Areas = @(
            "Mempool Analysis"
            "Fee Markets"
            "Mining Operations"
            "Network Infrastructure"
            "Operational Audit"
            "Mining Documentation"
        )
    }

    [ordered]@{
        Slug = "corecraft-pay"
        Number = "03"
        Category = "Payment Infrastructure"
        Title = "CoreCraft Pay"
        Hero = "Structured payment architecture."
        Description = "CoreCraft Pay bildet den Produktbereich für Payment Architecture, Wallet-Komponenten, Transaktionsmodelle und technische Konzepte für digitale Zahlungs- und Asset-Infrastruktur."
        Status = "PAYMENT ARCHITECTURE"
        PrimaryLabel = "Payment-Dokumentation"
        PrimaryUrl = "/docs/corecraft-pay/"
        Features = @(
            [ordered]@{
                Title = "Payment Architecture"
                Text = "Strukturierte technische Modelle für digitale Zahlungsprozesse."
            }
            [ordered]@{
                Title = "Transaction Models"
                Text = "Definierte Abläufe für Erstellung, Verarbeitung und Prüfung von Transaktionen."
            }
            [ordered]@{
                Title = "Wallet Components"
                Text = "Technische Bausteine und Konzepte für walletbezogene Funktionen."
            }
            [ordered]@{
                Title = "Validation"
                Text = "Prüfung von Transaktionszuständen und kontrollierten Übergängen."
            }
            [ordered]@{
                Title = "Integration"
                Text = "Modulare Anbindung an Produkte, Dienste und digitale Infrastruktur."
            }
            [ordered]@{
                Title = "Auditability"
                Text = "Nachvollziehbare Zahlungs- und Transaktionsprozesse."
            }
        )
        Areas = @(
            "Payment Processing"
            "Transaction Architecture"
            "Wallet Components"
            "Digital Assets"
            "System Integration"
            "Payment Audit"
        )
    }

    [ordered]@{
        Slug = "developer-tools"
        Number = "04"
        Category = "Developer Resources"
        Title = "Developer Tools"
        Hero = "Tools for structured engineering."
        Description = "Developer Tools umfasst technische Werkzeuge, Prüfskripte, Vorlagen und wiederverwendbare Ressourcen für Entwicklung, Automatisierung, Validierung und reproduzierbare Workflows."
        Status = "DEVELOPER TOOLKIT"
        PrimaryLabel = "Developer-Dokumentation"
        PrimaryUrl = "/docs/developer-tools/"
        Features = @(
            [ordered]@{
                Title = "Automation"
                Text = "Werkzeuge für wiederholbare technische Abläufe und Entwicklungsprozesse."
            }
            [ordered]@{
                Title = "Validation"
                Text = "Prüfwerkzeuge für Dateien, Strukturen, Schemas und technische Ergebnisse."
            }
            [ordered]@{
                Title = "Project Templates"
                Text = "Wiederverwendbare Ausgangsstrukturen für neue technische Projekte."
            }
            [ordered]@{
                Title = "Build Resources"
                Text = "Hilfsmittel für Build-, Test- und Freigabeprozesse."
            }
            [ordered]@{
                Title = "Audit Tools"
                Text = "Werkzeuge für Inventuren, Integritätsprüfungen und nachvollziehbare Reports."
            }
            [ordered]@{
                Title = "Developer Documentation"
                Text = "Technische Anleitungen und Referenzen für die direkte Umsetzung."
            }
        )
        Areas = @(
            "PowerShell Automation"
            "Schema Validation"
            "Build Workflows"
            "Project Templates"
            "Integrity Audits"
            "Developer Guides"
        )
    }

    [ordered]@{
        Slug = "documentation"
        Number = "05"
        Category = "Knowledge Products"
        Title = "Documentation"
        Hero = "Technical knowledge, structured."
        Description = "Der Documentation-Bereich bündelt technische Dokumentationen, Reference Packs, Engineering Guides, Berichte und strukturierte Knowledge-Produkte."
        Status = "KNOWLEDGE SYSTEM"
        PrimaryLabel = "Dokumentation öffnen"
        PrimaryUrl = "/docs/"
        Features = @(
            [ordered]@{
                Title = "Technical Documentation"
                Text = "Strukturierte Dokumentationen für technische Lösungen und Systeme."
            }
            [ordered]@{
                Title = "Reference Packs"
                Text = "Kompakte Referenzpakete mit klar gegliederten technischen Informationen."
            }
            [ordered]@{
                Title = "Engineering Guides"
                Text = "Umsetzungsorientierte Anleitungen für technische Arbeitsabläufe."
            }
            [ordered]@{
                Title = "Architecture Reports"
                Text = "Nachvollziehbare Darstellung von Architektur, Komponenten und Übergaben."
            }
            [ordered]@{
                Title = "Governance Resources"
                Text = "Richtlinien, Rollen, Prüfregeln und strukturierte Freigabekriterien."
            }
            [ordered]@{
                Title = "Download Products"
                Text = "Bereitgestellte Dokumentations- und Wissensprodukte für die weitere Nutzung."
            }
        )
        Areas = @(
            "Technical References"
            "Engineering Guides"
            "Architecture Reports"
            "Governance Documents"
            "Knowledge Packs"
            "Download Resources"
        )
    }

    [ordered]@{
        Slug = "enginecore"
        Number = "06"
        Category = "Runtime Architecture"
        Title = "EngineCore"
        Hero = "Engineering deterministic systems."
        Description = "EngineCore ist die deterministische Runtime-Architektur innerhalb von CoreCraft Genesis für strukturierte Ausführung, State Management, Validierung, Orchestration, Recovery und Audit."
        Status = "RUNTIME READY"
        PrimaryLabel = "EngineCore Docs"
        PrimaryUrl = "/docs/enginecore/"
        Features = @(
            [ordered]@{
                Title = "Deterministic Execution"
                Text = "Definierte Ausführungsabläufe mit kontrollierten Eingaben und Ergebnissen."
            }
            [ordered]@{
                Title = "State Management"
                Text = "Explizite Verwaltung und Übergabe technischer Systemzustände."
            }
            [ordered]@{
                Title = "Validation"
                Text = "Prüfung von Bedingungen, Strukturen und Zustandsübergängen."
            }
            [ordered]@{
                Title = "Orchestration"
                Text = "Koordination modularer Komponenten und Verarbeitungsschritte."
            }
            [ordered]@{
                Title = "Recovery"
                Text = "Strukturierte Behandlung von Fehler- und Wiederherstellungszuständen."
            }
            [ordered]@{
                Title = "Auditability"
                Text = "Nachvollziehbare Abläufe, Übergaben und technische Ergebnisse."
            }
        )
        Areas = @(
            "Runtime Execution"
            "State Management"
            "Validation Layers"
            "System Orchestration"
            "Recovery & Failover"
            "Audit & Traceability"
        )
    }
)

function ConvertTo-HtmlEncodedText {
    param(
        [AllowEmptyString()]
        [string]$Text
    )

    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function New-FeatureCards {
    param(
        [Parameter(Mandatory)]
        [array]$Features
    )

    $Cards = for ($Index = 0; $Index -lt $Features.Count; $Index++) {
        $Feature = $Features[$Index]
        $Number = "{0:D2}" -f ($Index + 1)
        $Title = ConvertTo-HtmlEncodedText $Feature.Title
        $Text = ConvertTo-HtmlEncodedText $Feature.Text

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

function New-AreaItems {
    param(
        [Parameter(Mandatory)]
        [array]$Areas
    )

    $Items = foreach ($Area in $Areas) {
        $EncodedArea = ConvertTo-HtmlEncodedText $Area
        "        <div class=`"area-item`">$EncodedArea</div>"
    }

    return $Items -join "`r`n"
}

function New-ProductPage {
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Product
    )

    $Slug = ConvertTo-HtmlEncodedText $Product.Slug
    $Number = ConvertTo-HtmlEncodedText $Product.Number
    $Category = ConvertTo-HtmlEncodedText $Product.Category
    $Title = ConvertTo-HtmlEncodedText $Product.Title
    $Hero = ConvertTo-HtmlEncodedText $Product.Hero
    $Description = ConvertTo-HtmlEncodedText $Product.Description
    $Status = ConvertTo-HtmlEncodedText $Product.Status
    $PrimaryLabel = ConvertTo-HtmlEncodedText $Product.PrimaryLabel
    $PrimaryUrl = ConvertTo-HtmlEncodedText $Product.PrimaryUrl

    $FeatureCards = New-FeatureCards -Features $Product.Features
    $AreaItems = New-AreaItems -Areas $Product.Areas

@"
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
      font-family: Inter, ui-sans-serif, system-ui, -apple-system,
        BlinkMacSystemFont, "Segoe UI", sans-serif;
      background:
        radial-gradient(circle at 70% -10%, #102c4a 0, transparent 28%),
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

    .brand span,
    .section-label,
    .card-number {
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

    .breadcrumb span {
      margin: 0 8px;
      color: #526174;
    }

    .hero {
      min-height: 650px;
      display: grid;
      grid-template-columns: 1.1fr .9fr;
      align-items: center;
      gap: 70px;
      padding: 70px 0 110px;
    }

    .eyebrow,
    .section-label {
      text-transform: uppercase;
      letter-spacing: .13em;
      font-weight: 700;
      font-size: .77rem;
    }

    .eyebrow {
      color: var(--blue);
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

    .hero p,
    .lead {
      color: var(--muted);
      font-size: 1.07rem;
    }

    .hero p {
      max-width: 720px;
      margin: 30px 0;
      font-size: 1.15rem;
    }

    .lead {
      max-width: 780px;
      margin-bottom: 45px;
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
        linear-gradient(145deg, rgba(78,161,255,.08), transparent),
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
      margin-bottom: 25px;
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

    .features {
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

    .areas {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px;
    }

    .area-item {
      padding: 21px;
      border: 1px solid var(--line);
      border-radius: 10px;
      background: rgba(255,255,255,.018);
      color: #d9e4f0;
    }

    .cta {
      padding: 60px;
      background:
        linear-gradient(125deg, rgba(78,161,255,.15), transparent),
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
      margin-bottom: 15px;
      color: white;
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
      padding-top: 30px;
      margin-top: 45px;
      border-top: 1px solid var(--line);
      font-size: .82rem;
    }

    @media (max-width: 900px) {
      .hero {
        min-height: auto;
        grid-template-columns: 1fr;
      }

      .grid,
      .areas {
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
      .areas,
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
    $Title
  </div>

  <section class="container hero">

    <div>
      <div class="eyebrow">
        $Category
      </div>

      <h1>
        $Hero
      </h1>

      <p>
        $Description
      </p>

      <div class="buttons">
        <a class="button button-primary" href="$PrimaryUrl">
          $PrimaryLabel
        </a>

        <a class="button" href="#capabilities">
          Funktionen ansehen
        </a>
      </div>
    </div>

    <div class="system-panel">
      <div class="status">
        ● $Status
      </div>

      <div class="system-path">
        /products/$Slug/
      </div>

      <div class="system-item">
        <span>PRODUCT</span>
        <span>$Title</span>
      </div>

      <div class="system-item">
        <span>CATEGORY</span>
        <span>$Category</span>
      </div>

      <div class="system-item">
        <span>STRUCTURE</span>
        <span>MODULAR</span>
      </div>

      <div class="system-item">
        <span>DOCUMENTATION</span>
        <span>INTEGRATED</span>
      </div>

      <div class="system-item">
        <span>STATUS</span>
        <span>AVAILABLE</span>
      </div>
    </div>

  </section>

  <section class="features" id="capabilities">
    <div class="container">

      <div class="section-label">
        Product Capabilities
      </div>

      <h2>
        $Title im CoreCraft-Genesis-Ökosystem.
      </h2>

      <p class="lead">
        Dieser Produktbereich stellt spezialisierte technische
        Funktionen, Ressourcen und Dokumentationen innerhalb
        der gemeinsamen CoreCraft-Genesis-Struktur bereit.
      </p>

      <div class="grid">
$FeatureCards
      </div>

    </div>
  </section>

  <section class="container">

    <div class="section-label">
      Product Areas
    </div>

    <h2>
      Technische Schwerpunkte.
    </h2>

    <p class="lead">
      Der Produktbereich ist in klar definierte Themen und
      technische Anwendungsfelder gegliedert.
    </p>

    <div class="areas">
$AreaItems
    </div>

  </section>

  <section class="container">
    <div class="cta">

      <div class="section-label">
        CoreCraft Genesis · $Number
      </div>

      <h2>
        $Title weiter erkunden.
      </h2>

      <p class="lead">
        Öffne die zugehörige Dokumentation, kehre zur
        Produktübersicht zurück oder nimm Kontakt auf.
      </p>

      <div class="buttons">
        <a class="button button-primary" href="$PrimaryUrl">
          $PrimaryLabel
        </a>

        <a class="button" href="/products/">
          Alle Produkte
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
        <h4>Produkte</h4>
        <a href="/products/audio/">Audio</a>
        <a href="/products/enginecore/">EngineCore</a>
        <a href="/products/corecraft-pay/">CoreCraft Pay</a>
        <a href="/products/bitcoin-mining/">Bitcoin Mining</a>
      </div>

      <div>
        <h4>Resources</h4>
        <a href="/products/developer-tools/">Developer Tools</a>
        <a href="/products/documentation/">Documentation</a>
        <a href="/docs/">Docs</a>
        <a href="/downloads/">Downloads</a>
      </div>

      <div>
        <h4>CoreCraft</h4>
        <a href="/about/">Über uns</a>
        <a href="/contact/">Kontakt</a>
        <a href="/support/">Support</a>
        <a href="/legal/imprint/">Impressum</a>
        <a href="/legal/privacy/">Datenschutz</a>
      </div>

    </div>

    <div class="copyright">
      © 2026 CoreCraft Genesis · $Title
    </div>

  </div>
</footer>

</body>
</html>
"@
}

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    throw "Produktverzeichnis wurde nicht gefunden: $Root"
}

$BackupRoot = Join-Path $Root (
    "_backup_product_pages_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss")
)

New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

$Results = foreach ($Product in $Products) {
    $Directory = Join-Path $Root $Product.Slug
    $IndexFile = Join-Path $Directory "index.html"

    if (-not (Test-Path -LiteralPath $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        Write-Host "[DIR    ] $Directory" -ForegroundColor Cyan
    }

    if (Test-Path -LiteralPath $IndexFile -PathType Leaf) {
        $BackupFile = Join-Path $BackupRoot (
            "{0}_index.html" -f $Product.Slug
        )

        Copy-Item `
            -LiteralPath $IndexFile `
            -Destination $BackupFile `
            -Force

        Write-Host "[BACKUP ] $BackupFile" -ForegroundColor DarkYellow
    }

    $Html = New-ProductPage -Product $Product

    Set-Content `
        -LiteralPath $IndexFile `
        -Value $Html `
        -Encoding utf8

    $File = Get-Item -LiteralPath $IndexFile

    Write-Host "[CREATE ] $IndexFile" -ForegroundColor Green

    [pscustomobject]@{
        Product = $Product.Title
        Route = "/products/$($Product.Slug)/"
        File = $IndexFile
        Exists = Test-Path -LiteralPath $IndexFile -PathType Leaf
        Bytes = $File.Length
    }
}

$ReportPath = Join-Path $Root "product-pages-report.csv"

$Results |
    Export-Csv `
        -LiteralPath $ReportPath `
        -NoTypeInformation `
        -Encoding utf8

Write-Host ""
Write-Host "----------------------------------------"
Write-Host "CoreCraft Genesis Product Pages" -ForegroundColor Cyan
Write-Host "----------------------------------------"

$Results | Format-Table Product, Route, Exists, Bytes -AutoSize

$InvalidFiles = @(
    $Results |
    Where-Object {
        -not $_.Exists -or $_.Bytes -lt 1000
    }
)

Write-Host ""

if ($InvalidFiles.Count -eq 0) {
    Write-Host "[PASS] Alle sechs Produktseiten wurden erstellt." `
        -ForegroundColor Green
    Write-Host "[PASS] Alle Dateien enthalten HTML-Inhalt." `
        -ForegroundColor Green
}
else {
    Write-Host "[FAIL] Mindestens eine Produktseite ist unvollständig." `
        -ForegroundColor Red

    $InvalidFiles |
        Format-Table Product, File, Exists, Bytes -AutoSize

    exit 1
}

Write-Host ""
Write-Host "Backup: $BackupRoot" -ForegroundColor DarkGray
Write-Host "Report: $ReportPath" -ForegroundColor DarkGray

exit 0
