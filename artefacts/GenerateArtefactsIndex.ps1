param(
    [string]$ArtefactsPath = ".",
    [string]$OutputFile    = "index.html",
    [string]$Title         = "CoreCraftGenesis — Artefakte",
    [string]$Tag           = "CoreCraftGenesis"
)

# Artefakte einsammeln (nur Dateien, keine .git, keine versteckten)
$items = Get-ChildItem -Path $ArtefactsPath -File |
    Where-Object { $_.Name -ne $OutputFile }

# HTML bauen
$html = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>$Title</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="../portal-core.css">
  <style>
    table { width: 100%; border-collapse: collapse; margin-top: 1.5rem; }
    th, td { padding: 10px; border-bottom: 1px solid #23282d; }
    th { color: #8fb0d6; text-align: left; }
    .card { border: 1px solid #333; border-radius: 12px;
            padding: 1.25rem 1.5rem; background: rgba(255,255,255,0.02);
            margin-bottom: 1.5rem; }
    .small { opacity: .7; font-size: .9rem; margin-top: .5rem; }
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
  <span class="tag">$Tag</span>
  <h1>Artefakte — Public Index</h1>
  <p class="small">Automatisch generierte Übersicht der Artefakt‑Objekte.</p>

  <div class="card">
    <h2>Index</h2>
    <p>Alle Artefakte im Repository mit Dateimetadaten.</p>

    <table>
      <tr>
        <th>Name</th>
        <th>Last commit message</th>
        <th>Last commit date</th>
      </tr>
"@

foreach ($item in $items) {
    $name  = $item.Name
    $date  = $item.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
    # Commit‑Message kann hier nur generisch sein; echte Messages kommen von GitHub UI
    $msg   = "Artefact updated"

    $html += "      <tr>`n"
    $html += "        <td>$name</td>`n"
    $html += "        <td>$msg</td>`n"
    $html += "        <td>$date</td>`n"
    $html += "      </tr>`n"
}

$html += @"
    </table>
  </div>

  <div class="footer">
    © CoreCraft Genesis — audit‑sealed<br>
    artefacts.corecraftgenesis.ch
  </div>

</div>

</body>
</html>
"@

# Schreiben
$html | Out-File -FilePath (Join-Path $ArtefactsPath $OutputFile) -Encoding UTF8
Write-Host "Artefacts index generated at $((Join-Path $ArtefactsPath $OutputFile))"
