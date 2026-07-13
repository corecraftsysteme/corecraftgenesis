<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>CoreCraftGenesis — Artefakte Store</title>
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
    .card h2 {
      margin-top: 0;
      margin-bottom: .5rem;
    }
    .small {
      opacity: .7;
      font-size: .9rem;
      margin-top: .5rem;
    }
    .store-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 1.5rem;
    }
    .store-item {
      border: 1px solid #23282d;
      border-radius: 10px;
      padding: 1rem;
      background: rgba(5,7,10,0.9);
    }
    .store-item h3 {
      margin-top: 0;
      margin-bottom: .4rem;
    }
    .store-item .tagline {
      font-size: .85rem;
      opacity: .75;
      margin-bottom: .6rem;
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
  <h1>Artefakte — Store Integration</h1>
  <p class="small">Verknüpfung der symbolischen Genesis‑Artefakte mit dem externen Store.</p>

  <div class="card">
    <h2>Store‑Übersicht</h2>
    <p>
      Der Artefakte‑Store bündelt alle symbolischen Objekte der Genesis‑Engine
      (Determinism Seal, Operator‑Patches, Hoodies, Metall‑Sticker) und stellt sie
      über eine externe Commerce‑Plattform bereit.
    </p>
    <p class="small">
      Aktueller Store‑Endpunkt:
      <br>
      <a href="https://theagency.threadless.com" target="_blank">
        theagency.threadless.com
      </a>
    </p>
  </div>

  <div class="card">
    <h2>Artefakte im Store</h2>
    <div class="store-grid">
      <div class="store-item">
        <h3>Determinism Seal</h3>
        <p class="tagline">Sticker, Metall‑Tags, Prints.</p>
        <p>Markiert deterministische, audit‑stabile Vorgänge in der Genesis‑Engine.</p>
      </div>

      <div class="store-item">
        <h3>Operator‑Patches</h3>
        <p class="tagline">Gestickte Patches, Insignien.</p>
        <p>Rituelle Identifikatoren für Operatoren, Rollen und Berechtigungen.</p>
      </div>

      <div class="store-item">
        <h3>Genesis‑Hoodies</h3>
        <p class="tagline">Textile Artefakte.</p>
        <p>Symbolische Kleidungsstücke für Operatoren und Ritual‑Teilnehmer.</p>
      </div>

      <div class="store-item">
        <h3>Metall‑Sticker</h3>
        <p class="tagline">Lasergravierte Tags.</p>
        <p>Artefakte für Geräte, Validator‑Nodes und physische Ritual‑Objekte.</p>
      </div>
    </div>
  </div>

  <div class="card">
    <h2>Integration in die Genesis‑Engine</h2>
    <ul>
      <li>Artefakte werden im <code>artefacts-manifest.json</code> referenziert.</li>
      <li>Operator‑Layer nutzt Patches und Hoodies als Identitäts‑Artefakte.</li>
      <li>Audit‑Layer markiert WORM‑Pipelines mit dem Determinism Seal.</li>
      <li>Hardware‑Layer nutzt Metall‑Sticker für physische Markierung.</li>
    </ul>
  </div>

  <div class="card">
    <h2>Lizenz & Attribution</h2>
    <p class="small">
      Code: MIT / CC0<br>
      Skeletton™: Archneton License v1.0<br>
      Autor: Daniel Aecherli (M.O.D.S.)
    </p>
  </div>

  <div class="footer">
    © CoreCraft Genesis — audit‑sealed  
    <br>
    artefacts.corecraftgenesis.ch
  </div>

</div>

</body>
</html>
