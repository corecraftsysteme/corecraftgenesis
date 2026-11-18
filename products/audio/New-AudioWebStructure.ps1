#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Root,

    [Parameter(Mandatory)]
    [string]$SiteRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "CoreCraft Genesis - Audio Web Structure" -ForegroundColor Cyan
Write-Host "Root: $Root"
Write-Host ""

# ============================================================
# VERZEICHNISSE
# ============================================================

$Directories = @(
    "tools"
    "tools\analyzer"
    "tools\oscillator"
    "tools\signal-monitor"

    "demos"
    "demos\signal-chain"
    "demos\audiostate"

    "assets"
    "assets\css"
    "assets\js"
    "assets\worklets"
    "assets\audio"
    "assets\audio\samples"

    "data"
)

New-Item `
    -ItemType Directory `
    -Path $Root `
    -Force |
    Out-Null

foreach ($RelativeDirectory in $Directories) {
    $Directory = Join-Path $Root $RelativeDirectory

    New-Item `
        -ItemType Directory `
        -Path $Directory `
        -Force |
        Out-Null

    Write-Host "[DIR   ] $RelativeDirectory" -ForegroundColor DarkCyan
}

# ============================================================
# BACKUP
# ============================================================

$BackupRoot = Join-Path $Root (
    "_backup_audio_web_{0}" -f (
        Get-Date -Format "yyyyMMdd_HHmmss"
    )
)

New-Item `
    -ItemType Directory `
    -Path $BackupRoot `
    -Force |
    Out-Null

function Set-AudioFile {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Content
    )

    $Path = Join-Path $Root $RelativePath

    $Parent = Split-Path $Path -Parent

    if (-not (Test-Path -LiteralPath $Parent -PathType Container)) {
        New-Item `
            -ItemType Directory `
            -Path $Parent `
            -Force |
            Out-Null
    }

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $BackupName = $RelativePath -replace '[\\/:*?"<>|]', "_"
        $BackupPath = Join-Path $BackupRoot $BackupName

        Copy-Item `
            -LiteralPath $Path `
            -Destination $BackupPath `
            -Force

        Write-Host "[BACKUP] $RelativePath" -ForegroundColor DarkYellow
    }

    Set-Content `
        -LiteralPath $Path `
        -Value $Content `
        -Encoding utf8

    Write-Host "[CREATE] $RelativePath" -ForegroundColor Green
}

# ============================================================
# GEMEINSAMES CSS
# ============================================================

$AudioCss = @'
:root {
  --bg: #05070a;
  --surface: #0c1118;
  --surface-light: #111924;
  --line: #1d2938;
  --text: #f4f7fb;
  --muted: #95a2b3;
  --blue: #4ea1ff;
  --green: #42d392;
  --red: #ff657a;
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
  min-height: 100vh;

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

button,
input,
select {
  font: inherit;
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
  font-size: 1.1rem;
  font-weight: 750;
  letter-spacing: -.03em;
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

.breadcrumb {
  padding-top: 45px;

  color: var(--muted);
  font-size: .85rem;
}

.breadcrumb span {
  margin: 0 8px;
  color: #526174;
}

.breadcrumb a:hover {
  color: var(--blue);
}

.hero {
  min-height: 540px;

  display: grid;
  grid-template-columns: 1.1fr .9fr;
  align-items: center;

  gap: 70px;
  padding: 70px 0 100px;
}

.eyebrow,
.section-label {
  color: var(--blue);

  text-transform: uppercase;
  letter-spacing: .13em;

  font-size: .77rem;
  font-weight: 700;
}

.eyebrow {
  margin-bottom: 20px;
}

h1 {
  max-width: 920px;

  font-size: clamp(3.1rem, 8vw, 6.5rem);
  line-height: .94;
  letter-spacing: -.06em;
}

h2 {
  max-width: 900px;

  margin: 12px 0 22px;

  font-size: clamp(2rem, 5vw, 3.8rem);
  line-height: 1.05;
  letter-spacing: -.045em;
}

.hero p,
.lead {
  color: var(--muted);
}

.hero p {
  max-width: 720px;
  margin: 30px 0;

  font-size: 1.12rem;
}

.lead {
  max-width: 780px;
  margin-bottom: 40px;

  font-size: 1.05rem;
}

section {
  padding: 90px 0;
}

.panel {
  padding: 32px;

  background:
    linear-gradient(
      145deg,
      rgba(78,161,255,.08),
      transparent
    ),
    var(--surface);

  border: 1px solid var(--line);
  border-radius: 18px;
}

.status {
  margin-bottom: 24px;

  color: var(--green);
  font-family: monospace;
  font-size: .8rem;
}

.status.error {
  color: var(--red);
}

.status-row {
  display: flex;
  justify-content: space-between;
  gap: 20px;

  padding: 14px 0;

  border-top: 1px solid var(--line);

  font-family: monospace;
  font-size: .82rem;
}

.status-row span:last-child {
  color: var(--green);
  text-align: right;
}

.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}

.card {
  min-height: 260px;

  display: flex;
  flex-direction: column;

  padding: 28px;

  background: var(--surface);

  border: 1px solid var(--line);
  border-radius: 14px;

  transition: .22s ease;
}

.card:hover {
  transform: translateY(-4px);

  background: var(--surface-light);
  border-color: #3a5878;
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

.card-link {
  margin-top: auto;
  padding-top: 24px;

  color: var(--blue);
  font-size: .9rem;
}

.workspace {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 20px;
}

.visualizer {
  min-height: 340px;

  padding: 20px;

  background: #030508;

  border: 1px solid var(--line);
  border-radius: 14px;
}

canvas {
  display: block;

  width: 100%;
  height: 300px;

  background:
    linear-gradient(
      rgba(78,161,255,.04) 1px,
      transparent 1px
    ),
    linear-gradient(
      90deg,
      rgba(78,161,255,.04) 1px,
      transparent 1px
    );

  background-size: 30px 30px;

  border: 1px solid #172333;
  border-radius: 8px;
}

.controls {
  display: grid;
  align-content: start;
  gap: 12px;

  padding: 24px;

  background: var(--surface);

  border: 1px solid var(--line);
  border-radius: 14px;
}

.control-group {
  display: grid;
  gap: 8px;

  padding-bottom: 18px;
  margin-bottom: 6px;

  border-bottom: 1px solid var(--line);
}

.control-group label {
  color: var(--muted);
  font-size: .85rem;
}

.control-value {
  color: var(--blue);
  font-family: monospace;
}

.button-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;

  min-height: 44px;
  padding: 11px 18px;

  background: transparent;
  color: var(--text);

  border: 1px solid var(--line);
  border-radius: 8px;

  cursor: pointer;

  font-weight: 650;

  transition: .2s ease;
}

.button:hover {
  transform: translateY(-1px);
  border-color: #45617e;
}

.button-primary {
  background: var(--blue);
  border-color: var(--blue);
  color: #001326;
}

.button-danger {
  color: #ff9baa;
  border-color: #6d2632;
}

input[type="range"] {
  width: 100%;
  accent-color: var(--blue);
}

select,
input[type="number"] {
  width: 100%;

  padding: 10px 12px;

  background: #080d13;
  color: var(--text);

  border: 1px solid var(--line);
  border-radius: 7px;
}

.flow {
  display: grid;
  gap: 12px;
}

.flow-node {
  padding: 18px 20px;

  background: var(--surface);

  border: 1px solid var(--line);
  border-radius: 10px;
}

.flow-node.active {
  border-color: var(--blue);
  box-shadow: 0 0 0 1px rgba(78,161,255,.25);
}

.flow-arrow {
  color: var(--blue);
  text-align: center;
  font-family: monospace;
}

footer {
  padding: 45px 0;

  color: var(--muted);

  border-top: 1px solid var(--line);
}

.footer-grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 40px;
}

footer h4 {
  margin-bottom: 14px;
  color: white;
}

footer a {
  display: block;
  margin: 7px 0;
  font-size: .9rem;
}

footer a:hover {
  color: white;
}

.copyright {
  margin-top: 40px;
  padding-top: 25px;

  border-top: 1px solid var(--line);

  font-size: .82rem;
}

@media (max-width: 900px) {
  .hero,
  .workspace {
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
    min-height: auto;
    padding-top: 45px;
  }

  .status-row {
    flex-direction: column;
    gap: 4px;
  }

  .status-row span:last-child {
    text-align: left;
  }
}
'@

Set-AudioFile `
    -RelativePath "assets\css\audio.css" `
    -Content $AudioCss

# ============================================================
# AUDIO WORKLET
# ============================================================

$AudioProcessor = @'
class CoreCraftAudioProcessor extends AudioWorkletProcessor {

    static get parameterDescriptors() {
        return [
            {
                name: "gain",
                defaultValue: 1,
                minValue: 0,
                maxValue: 2,
                automationRate: "a-rate"
            }
        ];
    }

    process(inputs, outputs, parameters) {
        const input = inputs[0];
        const output = outputs[0];
        const gainValues = parameters.gain;

        if (!input || !output) {
            return true;
        }

        for (
            let channelIndex = 0;
            channelIndex < output.length;
            channelIndex++
        ) {
            const inputChannel = input[channelIndex];
            const outputChannel = output[channelIndex];

            if (!inputChannel || !outputChannel) {
                continue;
            }

            for (
                let sampleIndex = 0;
                sampleIndex < outputChannel.length;
                sampleIndex++
            ) {
                const gain =
                    gainValues.length === 1
                        ? gainValues[0]
                        : gainValues[sampleIndex];

                outputChannel[sampleIndex] =
                    inputChannel[sampleIndex] * gain;
            }
        }

        return true;
    }
}

registerProcessor(
    "corecraft-audio-processor",
    CoreCraftAudioProcessor
);
'@

Set-AudioFile `
    -RelativePath "assets\worklets\audio-processor.js" `
    -Content $AudioProcessor

# ============================================================
# HTML-TEMPLATE
# ============================================================

function New-AudioPage {
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [string]$Label,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string]$Route,

        [Parameter(Mandatory)]
        [string]$Body,

        [AllowEmptyString()]
        [string]$Script = ""
    )

    return @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <title>$Title | CoreCraft Genesis</title>

  <meta
    name="description"
    content="$Description"
  >

  <link
    rel="stylesheet"
    href="/products/audio/assets/css/audio.css"
  >
</head>

<body>

<header>
  <div class="container">
    <nav>

      <a class="brand" href="/">
        CoreCraft <span>Genesis</span>
      </a>

      <div class="nav-links">
        <a href="/products/">Produkte</a>
        <a class="active" href="/products/audio/">Audio</a>
        <a href="/products/audio/tools/">Tools</a>
        <a href="/products/audio/demos/">Demos</a>
        <a href="/docs/">Docs</a>
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
        $Title
      </h1>

      <p>
        $Description
      </p>

      <div class="button-row">

        <a class="button button-primary" href="#content">
          Bereich öffnen
        </a>

        <a class="button" href="/products/audio/">
          Audio-Übersicht
        </a>

      </div>

    </div>

    <div class="panel">

      <div class="status">
        ● AUDIO MODULE READY
      </div>

      <div class="status-row">
        <span>ROUTE</span>
        <span>$Route</span>
      </div>

      <div class="status-row">
        <span>PRODUCT</span>
        <span>AUDIO</span>
      </div>

      <div class="status-row">
        <span>STRUCTURE</span>
        <span>MODULAR</span>
      </div>

      <div class="status-row">
        <span>STATUS</span>
        <span>ACTIVE</span>
      </div>

    </div>

  </section>

  <section class="container" id="content">
$Body
  </section>

</main>

<footer>
  <div class="container">

    <div class="footer-grid">

      <div>

        <div class="brand">
          CoreCraft <span>Genesis</span>
        </div>

        <p style="margin-top:15px;max-width:360px;">
          Audio Engineering, Signal Processing,
          Diagnostics and Web Audio Tools.
        </p>

      </div>

      <div>

        <h4>Audio</h4>

        <a href="/products/audio/">
          Übersicht
        </a>

        <a href="/products/audio/tools/">
          Tools
        </a>

        <a href="/products/audio/demos/">
          Demos
        </a>

      </div>

      <div>

        <h4>CoreCraft</h4>

        <a href="/products/">
          Produkte
        </a>

        <a href="/docs/">
          Docs
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

$Script
</body>
</html>
"@
}

# ============================================================
# TOOLS-ÜBERSICHT
# ============================================================

$ToolsBody = @'
    <div class="section-label">
      Audio Tools
    </div>

    <h2>
      Browserbasierte Audio-Werkzeuge.
    </h2>

    <p class="lead">
      Technische Werkzeuge für Audioanalyse,
      Signalerzeugung und Zustandsbeobachtung.
    </p>

    <div class="grid">

      <a
        class="card"
        href="/products/audio/tools/analyzer/"
      >
        <span class="card-number">
          01 · ANALYSIS
        </span>

        <h3>
          Audio Analyzer
        </h3>

        <p>
          Frequenzanalyse und Echtzeitdarstellung
          kontrollierter Audiosignale.
        </p>

        <span class="card-link">
          Analyzer öffnen →
        </span>
      </a>

      <a
        class="card"
        href="/products/audio/tools/oscillator/"
      >
        <span class="card-number">
          02 · GENERATOR
        </span>

        <h3>
          Audio Oscillator
        </h3>

        <p>
          Erzeugt Testsignale mit einstellbarer
          Frequenz, Wellenform und Lautstärke.
        </p>

        <span class="card-link">
          Oscillator öffnen →
        </span>
      </a>

      <a
        class="card"
        href="/products/audio/tools/signal-monitor/"
      >
        <span class="card-number">
          03 · MONITOR
        </span>

        <h3>
          Signal Monitor
        </h3>

        <p>
          Zeigt AudioContext-Zustand, Abtastrate
          und Master-Lautstärke.
        </p>

        <span class="card-link">
          Monitor öffnen →
        </span>
      </a>

    </div>
'@

$ToolsHtml = New-AudioPage `
    -Title "Audio Tools" `
    -Label "CoreCraft Audio Toolkit" `
    -Description "Browserbasierte Werkzeuge für Audioanalyse, Signalerzeugung und technische Signalbeobachtung." `
    -Route "/products/audio/tools/" `
    -Body $ToolsBody

Set-AudioFile `
    -RelativePath "tools\index.html" `
    -Content $ToolsHtml

# ============================================================
# ANALYZER
# ============================================================

$AnalyzerBody = @'
    <div class="section-label">
      Frequency Analysis
    </div>

    <h2>
      Frequenzdaten visualisieren.
    </h2>

    <p class="lead">
      Der Analyzer erzeugt ein kontrolliertes Testsignal
      und stellt dessen Frequenzdaten in Echtzeit dar.
    </p>

    <div class="workspace">

      <div class="visualizer">

        <canvas
          id="analyzer-canvas"
          width="900"
          height="300"
        ></canvas>

      </div>

      <div class="controls">

        <div class="status" id="analyzer-status">
          ● IDLE
        </div>

        <div class="control-group">

          <label for="analyzer-frequency">
            Frequenz
          </label>

          <input
            id="analyzer-frequency"
            type="range"
            min="40"
            max="2000"
            value="440"
            step="1"
          >

          <span
            class="control-value"
            id="analyzer-frequency-value"
          >
            440 Hz
          </span>

        </div>

        <button
          class="button button-primary"
          id="analyzer-start"
          type="button"
        >
          Analyzer starten
        </button>

        <button
          class="button button-danger"
          id="analyzer-stop"
          type="button"
        >
          Stoppen
        </button>

      </div>

    </div>
'@

$AnalyzerScript = @'
<script type="module">
import {
    createAudioContext,
    getMasterGain,
    resumeAudioContext
} from "/products/audio/assets/js/audio-core.js";

import {
    createAudioAnalyzer
} from "/products/audio/assets/js/audio-analyzer.js";

const canvas =
    document.querySelector("#analyzer-canvas");

const drawingContext =
    canvas.getContext("2d");

const startButton =
    document.querySelector("#analyzer-start");

const stopButton =
    document.querySelector("#analyzer-stop");

const frequencyInput =
    document.querySelector("#analyzer-frequency");

const frequencyOutput =
    document.querySelector(
        "#analyzer-frequency-value"
    );

const statusOutput =
    document.querySelector("#analyzer-status");

let oscillator = null;
let gainNode = null;
let analyzer = null;
let animationId = null;

function setStatus(value) {
    statusOutput.textContent = `● ${value}`;
}

function drawFrequencyData() {
    if (!analyzer) {
        return;
    }

    const values = analyzer.getFrequencyData();

    drawingContext.clearRect(
        0,
        0,
        canvas.width,
        canvas.height
    );

    const barWidth =
        canvas.width / values.length;

    for (
        let index = 0;
        index < values.length;
        index++
    ) {
        const value = values[index];

        const height =
            (value / 255) * canvas.height;

        drawingContext.fillStyle = "#4ea1ff";

        drawingContext.fillRect(
            index * barWidth,
            canvas.height - height,
            Math.max(1, barWidth - 1),
            height
        );
    }

    animationId =
        requestAnimationFrame(drawFrequencyData);
}

frequencyInput.addEventListener(
    "input",
    () => {
        const frequency =
            Number(frequencyInput.value);

        frequencyOutput.textContent =
            `${frequency} Hz`;

        if (oscillator) {
            oscillator.frequency.value = frequency;
        }
    }
);

startButton.addEventListener(
    "click",
    async () => {
        if (oscillator) {
            return;
        }

        const context = createAudioContext();

        await resumeAudioContext();

        oscillator = context.createOscillator();
        gainNode = context.createGain();

        oscillator.type = "sine";

        oscillator.frequency.value =
            Number(frequencyInput.value);

        gainNode.gain.value = 0.1;

        analyzer = createAudioAnalyzer(
            context,
            {
                fftSize: 2048,
                smoothingTimeConstant: 0.82
            }
        );

        oscillator.connect(gainNode);
        analyzer.connectSource(gainNode);
        analyzer.connectOutput(getMasterGain());

        oscillator.start();

        setStatus("RUNNING");
        drawFrequencyData();
    }
);

stopButton.addEventListener(
    "click",
    () => {
        if (animationId) {
            cancelAnimationFrame(animationId);
            animationId = null;
        }

        if (oscillator) {
            oscillator.stop();
            oscillator.disconnect();
            oscillator = null;
        }

        if (gainNode) {
            gainNode.disconnect();
            gainNode = null;
        }

        if (analyzer) {
            analyzer.disconnectSource();
            analyzer.disconnectOutput();
            analyzer = null;
        }

        drawingContext.clearRect(
            0,
            0,
            canvas.width,
            canvas.height
        );

        setStatus("STOPPED");
    }
);
</script>
'@

$AnalyzerHtml = New-AudioPage `
    -Title "Audio Analyzer" `
    -Label "Frequency Analysis" `
    -Description "Browserbasierte Frequenzanalyse und Visualisierung kontrollierter Audiosignale." `
    -Route "/products/audio/tools/analyzer/" `
    -Body $AnalyzerBody `
    -Script $AnalyzerScript

Set-AudioFile `
    -RelativePath "tools\analyzer\index.html" `
    -Content $AnalyzerHtml

# ============================================================
# OSCILLATOR
# ============================================================

$OscillatorBody = @'
    <div class="section-label">
      Signal Generator
    </div>

    <h2>
      Kontrolliertes Testsignal.
    </h2>

    <p class="lead">
      Der Oscillator erzeugt ein Audiosignal mit
      wählbarer Wellenform, Frequenz und Lautstärke.
    </p>

    <div class="workspace">

      <div class="panel">

        <div class="status" id="oscillator-status">
          ● IDLE
        </div>

        <div class="status-row">
          <span>FREQUENCY</span>
          <span id="frequency-output">440 Hz</span>
        </div>

        <div class="status-row">
          <span>WAVEFORM</span>
          <span id="wave-output">SINE</span>
        </div>

        <div class="status-row">
          <span>GAIN</span>
          <span id="gain-output">0.10</span>
        </div>

      </div>

      <div class="controls">

        <div class="control-group">

          <label for="wave-input">
            Wellenform
          </label>

          <select id="wave-input">
            <option value="sine">Sine</option>
            <option value="square">Square</option>
            <option value="sawtooth">Sawtooth</option>
            <option value="triangle">Triangle</option>
          </select>

        </div>

        <div class="control-group">

          <label for="frequency-input">
            Frequenz
          </label>

          <input
            id="frequency-input"
            type="range"
            min="20"
            max="2000"
            value="440"
            step="1"
          >

        </div>

        <div class="control-group">

          <label for="gain-input">
            Lautstärke
          </label>

          <input
            id="gain-input"
            type="range"
            min="0"
            max="0.3"
            value="0.1"
            step="0.01"
          >

        </div>

        <button
          class="button button-primary"
          id="oscillator-start"
          type="button"
        >
          Signal starten
        </button>

        <button
          class="button button-danger"
          id="oscillator-stop"
          type="button"
        >
          Signal stoppen
        </button>

      </div>

    </div>
'@

$OscillatorScript = @'
<script type="module">
import {
    createAudioContext,
    getMasterGain,
    resumeAudioContext
} from "/products/audio/assets/js/audio-core.js";

const waveInput =
    document.querySelector("#wave-input");

const frequencyInput =
    document.querySelector("#frequency-input");

const gainInput =
    document.querySelector("#gain-input");

const frequencyOutput =
    document.querySelector("#frequency-output");

const waveOutput =
    document.querySelector("#wave-output");

const gainOutput =
    document.querySelector("#gain-output");

const statusOutput =
    document.querySelector("#oscillator-status");

const startButton =
    document.querySelector("#oscillator-start");

const stopButton =
    document.querySelector("#oscillator-stop");

let oscillator = null;
let gainNode = null;

function updateDisplay() {
    frequencyOutput.textContent =
        `${frequencyInput.value} Hz`;

    waveOutput.textContent =
        waveInput.value.toUpperCase();

    gainOutput.textContent =
        Number(gainInput.value).toFixed(2);
}

function stopSignal() {
    if (oscillator) {
        oscillator.stop();
        oscillator.disconnect();
        oscillator = null;
    }

    if (gainNode) {
        gainNode.disconnect();
        gainNode = null;
    }

    statusOutput.textContent = "● STOPPED";
}

waveInput.addEventListener(
    "change",
    () => {
        updateDisplay();

        if (oscillator) {
            oscillator.type = waveInput.value;
        }
    }
);

frequencyInput.addEventListener(
    "input",
    () => {
        updateDisplay();

        if (oscillator) {
            oscillator.frequency.value =
                Number(frequencyInput.value);
        }
    }
);

gainInput.addEventListener(
    "input",
    () => {
        updateDisplay();

        if (gainNode) {
            gainNode.gain.value =
                Number(gainInput.value);
        }
    }
);

startButton.addEventListener(
    "click",
    async () => {
        if (oscillator) {
            return;
        }

        const context = createAudioContext();

        await resumeAudioContext();

        oscillator = context.createOscillator();
        gainNode = context.createGain();

        oscillator.type = waveInput.value;

        oscillator.frequency.value =
            Number(frequencyInput.value);

        gainNode.gain.value =
            Number(gainInput.value);

        oscillator.connect(gainNode);
        gainNode.connect(getMasterGain());

        oscillator.start();

        statusOutput.textContent = "● RUNNING";
    }
);

stopButton.addEventListener(
    "click",
    stopSignal
);

updateDisplay();
</script>
'@

$OscillatorHtml = New-AudioPage `
    -Title "Audio Oscillator" `
    -Label "Signal Generator" `
    -Description "Technischer Web-Audio-Oscillator für kontrollierte Testsignale." `
    -Route "/products/audio/tools/oscillator/" `
    -Body $OscillatorBody `
    -Script $OscillatorScript

Set-AudioFile `
    -RelativePath "tools\oscillator\index.html" `
    -Content $OscillatorHtml

# ============================================================
# SIGNAL MONITOR
# ============================================================

$MonitorBody = @'
    <div class="section-label">
      Audio System Monitor
    </div>

    <h2>
      AudioContext überwachen.
    </h2>

    <p class="lead">
      Der Signal Monitor zeigt Zustand, Abtastrate
      und Master-Lautstärke der Audio-Umgebung.
    </p>

    <div class="panel">

      <div class="status" data-audio-state>
        IDLE
      </div>

      <div class="status-row">
        <span>CONTEXT</span>
        <span data-audio-context-state>
          uninitialized
        </span>
      </div>

      <div class="status-row">
        <span>SAMPLE RATE</span>
        <span data-audio-sample-rate>-</span>
      </div>

      <div class="status-row">
        <span>MASTER VOLUME</span>
        <span data-audio-master-volume>-</span>
      </div>

      <div
        class="button-row"
        style="margin-top:25px;"
      >

        <button
          class="button"
          data-audio-init
          type="button"
        >
          Initialisieren
        </button>

        <button
          class="button button-primary"
          data-audio-start
          type="button"
        >
          Starten
        </button>

        <button
          class="button"
          data-audio-suspend
          type="button"
        >
          Pausieren
        </button>

        <button
          class="button button-danger"
          data-audio-stop
          type="button"
        >
          Schließen
        </button>

      </div>

      <div
        class="control-group"
        style="margin-top:25px;"
      >

        <label for="monitor-volume">
          Master-Lautstärke
        </label>

        <input
          id="monitor-volume"
          data-audio-volume
          type="range"
          min="0"
          max="1"
          value="1"
          step="0.01"
        >

      </div>

    </div>
'@

$MonitorScript = @'
<script
  type="module"
  src="/products/audio/assets/js/ui.js">
</script>
'@

$MonitorHtml = New-AudioPage `
    -Title "Signal Monitor" `
    -Label "Audio System Monitor" `
    -Description "Technische Zustandsanzeige für AudioContext, Abtastrate und Master-Lautstärke." `
    -Route "/products/audio/tools/signal-monitor/" `
    -Body $MonitorBody `
    -Script $MonitorScript

Set-AudioFile `
    -RelativePath "tools\signal-monitor\index.html" `
    -Content $MonitorHtml

# ============================================================
# DEMOS-ÜBERSICHT
# ============================================================

$DemosBody = @'
    <div class="section-label">
      Audio Demos
    </div>

    <h2>
      Technische Demonstrationen.
    </h2>

    <p class="lead">
      Die Demos zeigen den Signalfluss und kontrollierte
      AudioState-Übergänge.
    </p>

    <div class="grid">

      <a
        class="card"
        href="/products/audio/demos/signal-chain/"
      >
        <span class="card-number">
          01 · FLOW
        </span>

        <h3>
          Signal Chain
        </h3>

        <p>
          Visualisiert einen modularen
          Web-Audio-Signalpfad.
        </p>

        <span class="card-link">
          Signal Chain öffnen →
        </span>
      </a>

      <a
        class="card"
        href="/products/audio/demos/audiostate/"
      >
        <span class="card-number">
          02 · STATE
        </span>

        <h3>
          AudioState Demo
        </h3>

        <p>
          Demonstriert kontrollierte und
          validierbare Zustandsübergänge.
        </p>

        <span class="card-link">
          AudioState öffnen →
        </span>
      </a>

    </div>
'@

$DemosHtml = New-AudioPage `
    -Title "Audio Demos" `
    -Label "Interactive Demonstrations" `
    -Description "Technische Demonstrationen für AudioState und Web-Audio-Signalfluss." `
    -Route "/products/audio/demos/" `
    -Body $DemosBody

Set-AudioFile `
    -RelativePath "demos\index.html" `
    -Content $DemosHtml

# ============================================================
# SIGNAL CHAIN
# ============================================================

$SignalChainBody = @'
    <div class="section-label">
      Signal Flow
    </div>

    <h2>
      Modulare Signal Chain.
    </h2>

    <p class="lead">
      Die Demo zeigt einen einfachen Signalpfad von
      der Signalerzeugung bis zum Audio-Ausgang.
    </p>

    <div class="flow">

      <div class="flow-node active">
        <strong>01 · Oscillator</strong>
        <p>Erzeugt das technische Testsignal.</p>
      </div>

      <div class="flow-arrow">↓</div>

      <div class="flow-node">
        <strong>02 · Gain</strong>
        <p>Steuert den Signalpegel.</p>
      </div>

      <div class="flow-arrow">↓</div>

      <div class="flow-node">
        <strong>03 · Analyzer</strong>
        <p>Erfasst Frequenz- und Zeitbereichsdaten.</p>
      </div>

      <div class="flow-arrow">↓</div>

      <div class="flow-node">
        <strong>04 · Master Output</strong>
        <p>Übergibt das Signal an den Audio-Ausgang.</p>
      </div>

    </div>
'@

$SignalChainHtml = New-AudioPage `
    -Title "Signal Chain Demo" `
    -Label "Audio Processing Flow" `
    -Description "Technische Darstellung eines modularen Web-Audio-Signalpfads." `
    -Route "/products/audio/demos/signal-chain/" `
    -Body $SignalChainBody

Set-AudioFile `
    -RelativePath "demos\signal-chain\index.html" `
    -Content $SignalChainHtml

# ============================================================
# AUDIOSTATE-DEMO
# ============================================================

$AudioStateBody = @'
    <div class="section-label">
      State Machine
    </div>

    <h2>
      Kontrollierte Audiozustände.
    </h2>

    <p class="lead">
      Die Demo verwendet das AudioState-Modul und zeigt
      gültige sowie ungültige Zustandsübergänge.
    </p>

    <div class="panel">

      <div class="status" id="state-output">
        ● IDLE
      </div>

      <div class="status-row">
        <span>CURRENT STATE</span>
        <span id="current-state">idle</span>
      </div>

      <div class="status-row">
        <span>ALLOWED</span>
        <span id="allowed-states">
          ready, error, closed
        </span>
      </div>

      <div
        class="button-row"
        style="margin-top:25px;"
      >

        <button
          class="button"
          data-state="ready"
          type="button"
        >
          Ready
        </button>

        <button
          class="button button-primary"
          data-state="running"
          type="button"
        >
          Running
        </button>

        <button
          class="button"
          data-state="suspended"
          type="button"
        >
          Suspended
        </button>

        <button
          class="button button-danger"
          data-state="error"
          type="button"
        >
          Error
        </button>

      </div>

    </div>
'@

$AudioStateScript = @'
<script type="module">
import {
    getAudioState,
    setAudioState,
    getAllowedTransitions,
    subscribeAudioState
} from "/products/audio/assets/js/audio-state.js";

const stateOutput =
    document.querySelector("#state-output");

const currentStateOutput =
    document.querySelector("#current-state");

const allowedOutput =
    document.querySelector("#allowed-states");

function renderState() {
    const state = getAudioState();

    stateOutput.classList.remove("error");

    stateOutput.textContent =
        `● ${state.toUpperCase()}`;

    currentStateOutput.textContent = state;

    allowedOutput.textContent =
        getAllowedTransitions().join(", ");
}

document
    .querySelectorAll("[data-state]")
    .forEach((button) => {
        button.addEventListener(
            "click",
            () => {
                try {
                    setAudioState(
                        button.dataset.state,
                        "demo-transition"
                    );
                }
                catch (error) {
                    stateOutput.classList.add("error");

                    stateOutput.textContent =
                        `● INVALID: ${error.message}`;
                }
            }
        );
    });

subscribeAudioState(renderState);
renderState();
</script>
'@

$AudioStateHtml = New-AudioPage `
    -Title "AudioState Demo" `
    -Label "Deterministic State Model" `
    -Description "Interaktive Demonstration kontrollierter AudioState-Übergänge." `
    -Route "/products/audio/demos/audiostate/" `
    -Body $AudioStateBody `
    -Script $AudioStateScript

Set-AudioFile `
    -RelativePath "demos\audiostate\index.html" `
    -Content $AudioStateHtml

# ============================================================
# JSON-DATEIEN
# ============================================================

$Modules = [ordered]@{
    schemaVersion = "1.0.0"
    product = "audio"

    modules = @(
        [ordered]@{
            id = "audiostate"
            name = "AudioState Architecture"
            route = "/products/audio/audiostate/"
            status = "active"
        }

        [ordered]@{
            id = "dsp"
            name = "Digital Signal Processing"
            route = "/products/audio/dsp/"
            status = "active"
        }

        [ordered]@{
            id = "orchestration"
            name = "Audio Orchestration"
            route = "/products/audio/orchestration/"
            status = "active"
        }

        [ordered]@{
            id = "validation"
            name = "State Validation"
            route = "/products/audio/validation/"
            status = "active"
        }

        [ordered]@{
            id = "scaling"
            name = "Scaling and Failover"
            route = "/products/audio/scaling/"
            status = "active"
        }

        [ordered]@{
            id = "diagnostics"
            name = "Audio Diagnostics"
            route = "/products/audio/diagnostics/"
            status = "active"
        }
    )
}

$ModulesJson = $Modules |
    ConvertTo-Json -Depth 10

Set-AudioFile `
    -RelativePath "data\modules.json" `
    -Content $ModulesJson

$Capabilities = [ordered]@{
    schemaVersion = "1.0.0"
    product = "audio"

    capabilities = @(
        [ordered]@{
            id = "state-management"
            name = "Audio State Management"
            module = "audiostate"
            status = "active"
        }

        [ordered]@{
            id = "signal-processing"
            name = "Digital Signal Processing"
            module = "dsp"
            status = "active"
        }

        [ordered]@{
            id = "workflow-control"
            name = "Audio Workflow Control"
            module = "orchestration"
            status = "active"
        }

        [ordered]@{
            id = "state-validation"
            name = "State Validation"
            module = "validation"
            status = "active"
        }

        [ordered]@{
            id = "resilience"
            name = "Scaling and Failover"
            module = "scaling"
            status = "active"
        }

        [ordered]@{
            id = "diagnostics"
            name = "Audio Diagnostics"
            module = "diagnostics"
            status = "active"
        }
    )
}

$CapabilitiesJson = $Capabilities |
    ConvertTo-Json -Depth 10

Set-AudioFile `
    -RelativePath "data\capabilities.json" `
    -Content $CapabilitiesJson

$Tools = [ordered]@{
    schemaVersion = "1.0.0"
    product = "audio"

    tools = @(
        [ordered]@{
            id = "analyzer"
            name = "Audio Analyzer"
            route = "/products/audio/tools/analyzer/"
            type = "analysis"
            status = "active"
        }

        [ordered]@{
            id = "oscillator"
            name = "Audio Oscillator"
            route = "/products/audio/tools/oscillator/"
            type = "generator"
            status = "active"
        }

        [ordered]@{
            id = "signal-monitor"
            name = "Signal Monitor"
            route = "/products/audio/tools/signal-monitor/"
            type = "monitor"
            status = "active"
        }
    )

    demos = @(
        [ordered]@{
            id = "signal-chain"
            name = "Signal Chain Demo"
            route = "/products/audio/demos/signal-chain/"
            status = "active"
        }

        [ordered]@{
            id = "audiostate"
            name = "AudioState Demo"
            route = "/products/audio/demos/audiostate/"
            status = "active"
        }
    )
}

$ToolsJson = $Tools |
    ConvertTo-Json -Depth 10

Set-AudioFile `
    -RelativePath "data\tools.json" `
    -Content $ToolsJson

# ============================================================
# README OHNE HERE-STRING
# ============================================================

$ReadmeLines = @(
    "# CoreCraft Genesis Audio"
    ""
    "## Zweck"
    ""
    "Der Audio-Bereich stellt technische Produktseiten,"
    "browserbasierte Audio-Werkzeuge, Demonstrationen"
    "und strukturierte Konfigurationsdaten bereit."
    ""
    "## Hauptmodule"
    ""
    "- AudioState Architecture"
    "- Digital Signal Processing"
    "- Audio Orchestration"
    "- State Validation"
    "- Scaling and Failover"
    "- Audio Diagnostics"
    ""
    "## Tools"
    ""
    "- Audio Analyzer"
    "- Audio Oscillator"
    "- Signal Monitor"
    ""
    "## Demos"
    ""
    "- Signal Chain Demo"
    "- AudioState Demo"
    ""
    "## JavaScript-Module"
    ""
    "- assets/js/audio-core.js"
    "- assets/js/audio-analyzer.js"
    "- assets/js/audio-state.js"
    "- assets/js/ui.js"
    ""
    "## AudioWorklet"
    ""
    "- assets/worklets/audio-processor.js"
    ""
    "## Daten"
    ""
    "- data/modules.json"
    "- data/capabilities.json"
    "- data/tools.json"
    ""
    "## Lokaler Test"
    ""
    "Website über einen lokalen Webserver öffnen."
    ""
    "PowerShell:"
    ""
    "Set-Location `"$SiteRoot`""
    "python -m http.server 8080"
    ""
    "Danach die Website über den lokalen Port 8080 öffnen."
    ""
    "## Validierung"
    ""
    "1. Dateien prüfen"
    "2. JSON prüfen"
    "3. JavaScript prüfen"
    "4. interne Routen prüfen"
    "5. Browser-Konsole prüfen"
    "6. AudioContext prüfen"
)

$ReadmeContent = $ReadmeLines -join "`r`n"

Set-AudioFile `
    -RelativePath "README.md" `
    -Content $ReadmeContent

$SamplesReadmeLines = @(
    "# Audio Samples"
    ""
    "In diesem Verzeichnis können lizenzierte oder"
    "selbst erstellte Audio-Testdateien abgelegt werden."
    ""
    "Empfohlene Formate:"
    ""
    "- WAV"
    "- MP3"
    "- OGG"
    ""
    "Es wurden keine fremden Audioinhalte hinzugefügt."
)

$SamplesReadme = $SamplesReadmeLines -join "`r`n"

Set-AudioFile `
    -RelativePath "assets\audio\samples\README.md" `
    -Content $SamplesReadme

# ============================================================
# VALIDIERUNG
# ============================================================

$ExpectedFiles = @(
    "tools\index.html"
    "tools\analyzer\index.html"
    "tools\oscillator\index.html"
    "tools\signal-monitor\index.html"

    "demos\index.html"
    "demos\signal-chain\index.html"
    "demos\audiostate\index.html"

    "assets\css\audio.css"
    "assets\worklets\audio-processor.js"
    "assets\audio\samples\README.md"

    "data\modules.json"
    "data\capabilities.json"
    "data\tools.json"

    "README.md"
)

$Results = foreach ($RelativePath in $ExpectedFiles) {
    $Path = Join-Path $Root $RelativePath
    $Exists = Test-Path -LiteralPath $Path -PathType Leaf

    if (-not $Exists) {
        [pscustomobject]@{
            Status = "MISSING"
            Bytes = 0
            File = $RelativePath
            Path = $Path
        }

        continue
    }

    $Item = Get-Item -LiteralPath $Path
    $Content = Get-Content -LiteralPath $Path -Raw

    $HasContent = -not [System.String]::IsNullOrWhiteSpace(
        $Content
    )

    $Status = if (
        $Item.Length -gt 0 -and
        $HasContent
    ) {
        "PASS"
    }
    else {
        "EMPTY"
    }

    [pscustomobject]@{
        Status = $Status
        Bytes = $Item.Length
        File = $RelativePath
        Path = $Path
    }
}

Write-Host ""
Write-Host "Audio Web Structure Audit" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$Results |
    Format-Table `
        Status,
        Bytes,
        File `
        -AutoSize

# ============================================================
# JSON VALIDIEREN
# ============================================================

$JsonFiles = @(
    "data\modules.json"
    "data\capabilities.json"
    "data\tools.json"
)

$JsonResults = foreach ($RelativePath in $JsonFiles) {
    $Path = Join-Path $Root $RelativePath
    $IsValid = $false
    $ErrorMessage = ""

    try {
        Get-Content `
            -LiteralPath $Path `
            -Raw |
            ConvertFrom-Json `
                -ErrorAction Stop |
            Out-Null

        $IsValid = $true
    }
    catch {
        $ErrorMessage = $_.Exception.Message
    }

    [pscustomobject]@{
        Status = if ($IsValid) {
            "PASS"
        }
        else {
            "INVALID"
        }

        File = $RelativePath
        Error = $ErrorMessage
    }
}

Write-Host ""
Write-Host "JSON Validation" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

$JsonResults |
    Format-Table `
        Status,
        File,
        Error `
        -AutoSize

# ============================================================
# REPORT
# ============================================================

$Report = [ordered]@{
    generatedAt = (Get-Date).ToString("o")
    root = $Root
    files = $Results
    jsonValidation = $JsonResults
}

$ReportPath = Join-Path $Root "audio-web-report.json"

$Report |
    ConvertTo-Json -Depth 10 |
    Set-Content `
        -LiteralPath $ReportPath `
        -Encoding utf8

$FailedFiles = @(
    $Results |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

$FailedJson = @(
    $JsonResults |
    Where-Object {
        $_.Status -ne "PASS"
    }
)

Write-Host ""
Write-Host "------------------------------------------------------------"

if (
    $FailedFiles.Count -eq 0 -and
    $FailedJson.Count -eq 0
) {
    Write-Host `
        "[PASS] Alle Audio-Web-Dateien wurden erstellt." `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Alle Dateien enthalten Inhalt." `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Alle JSON-Dateien sind gültig." `
        -ForegroundColor Green

    Write-Host `
        "[PASS] Report: $ReportPath" `
        -ForegroundColor Green

    Write-Host `
        "[INFO] Backup: $BackupRoot" `
        -ForegroundColor DarkGray

    exit 0
}

Write-Host `
    "[FAIL] Fehlende oder ungültige Dateien gefunden." `
    -ForegroundColor Red

Write-Host `
    "[INFO] Report: $ReportPath" `
    -ForegroundColor Yellow

exit 1
