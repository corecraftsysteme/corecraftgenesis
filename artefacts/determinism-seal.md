<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>CoreCraftGenesis — Determinism Seal</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <link rel="stylesheet" href="../portal-core.css">
  <style>
    .card {
      border: 1px solid #333;
      border-radius: 12px;
      padding: 1.25rem 1.5rem;
      background: rgba(255,255,255,0.02);
      margin-bottom: 1.5rem;
    }
    .symbol-wrap {
      display: flex;
      gap: 2rem;
      align-items: center;
      flex-wrap: wrap;
    }
    .symbol-svg {
      background: #05070a;
      border-radius: 12px;
      padding: 1rem;
      border: 1px solid #23282d;
    }
    .small {
      opacity: .7;
      font-size: .9rem;
      margin-top: .5rem;
    }
  </style>
</head>

<body>

<div id="header"></div>
<script>
  fetch("../header.html")
    .then(r => r.text())
    .then(h => document.getElementById("header").innerHTML = h);
</script>

<div class="wrap">
  <span class="tag">CoreCraftGenesis</span>
  <h1>Determinism Seal — Symbol Viewer</h1>
  <p class="small">SVG‑Darstellung des zentralen Genesis‑Artefakts.</p>

  <div class="card">
    <h2>Symbol</h2>
    <div class="symbol-wrap">
      <div class="symbol-svg">
        <!-- Minimalistisches Determinism‑Seal SVG -->
        <svg width="220" height="220" viewBox="0 0 220 220"
             xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="grad-core" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#4fc3f7"/>
              <stop offset="100%" stop-color="#82b1ff"/>
            </linearGradient>
          </defs>

          <!-- Outer ring -->
          <circle cx="110" cy="110" r="95"
                  fill="none"
                  stroke="#263238"
                  stroke-width="6"/>

          <!-- Inner ring -->
          <circle cx="110" cy="110" r="70"
                  fill="none"
                  stroke="url(#grad-core)"
                  stroke-width="5"/>

          <!-- Deterministic triangle -->
          <polygon points="110,55 60,150 160,150"
                   fill="none"
                   stroke="#ffffff"
                   stroke-width="4"/>

          <!-- Center node -->
          <circle cx="110" cy="110" r="8"
                  fill="#ffffff"/>

          <!-- Radial ticks -->
          <line x1="110" y1="20"  x2="110" y2="35"  stroke="#455a64" stroke-width="3"/>
          <line x1="110" y1="185" x2="110" y2="200" stroke="#455a64" stroke-width="3"/>
          <line x1="20"  y1="110" x2="35"  y2="110" stroke="#455a64" stroke-width="3"/>
          <line x1="185" y1="110" x2="200" y2="110" stroke="#455a64" stroke-width="3"/>

          <!-- Label -->
          <text x="110" y="205"
                font-family="system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                font-size="11"
                fill="#90caf9"
                text-anchor="middle">
            DETERMINISM SEAL
          </text>
        </svg>
      </div>

      <div>
        <p>
          Das <strong>Determinism Seal</strong> markiert deterministische, audit‑stabile Vorgänge
          innerhalb der Genesis‑Engine.  
          Der äußere Ring steht für den narrativen Rahmen, der innere Ring für die Engine‑Core‑Logik,
          das Dreieck für den deterministischen Pfad und der zentrale Punkt für den Ursprung.
        </p>
        <p class="small">
          Dieses SVG kann direkt als <code>determinism-seal.svg</code> im Repository abgelegt
          und für Sticker, Patches, Prints und UI‑Badges verwendet werden.
        </p>
      </div>
    </div>
  </div>

  <div class="card">
    <h2>Verwendung</h2>
    <ul>
      <li>Markierung von WORM‑Audit‑Pipelines.</li>
      <li>Badges für Operator‑Dashboards.</li>
      <li>Sticker und Metall‑Tags für Hardware.</li>
      <li>Branding für Genesis‑Hoodies und Patches.</li>
    </ul>
  </div>

  <div class="footer">
    © CoreCraft Genesis — audit‑sealed  
    <br>
    artefacts.corecraftgenesis.ch
  </div>

</div>

</body>
</html>
