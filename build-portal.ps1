<#
    EngineCore Genesis Portal Builder
    Automatische Portal-Startseite für alle Genesis-Schichten
    Version: 2026-09-20
#>

Write-Host "[EngineCore][PORTAL] Starte Portal-Build..." -ForegroundColor Cyan

$Base = "C:\corecraftgenesis.ch"
$PortalFile = Join-Path $Base "portal.html"

# Alle Ordner im Genesis-Verzeichnis
$Folders = Get-ChildItem -Path $Base -Directory | Select-Object -ExpandProperty Name

# HTML-Header
$Header = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>CoreCraft Genesis Portal</title>
  <link rel="stylesheet" href="portal.css">
</head>
<body>
<?php include("super-nav.html"); ?>
<header>
  <h1>CoreCraft Genesis Portal</h1>
  <p>Institutionelle Übersicht aller Genesis-Schichten</p>
</header>
<section>
  <h2>Genesis-Schichten</h2>
  <ul>
"@

# HTML-Footer
$Footer = @"
  </ul>
</section>
</body>
</html>
"@

# Portal-Inhalt generieren
$Body = ""

foreach ($Folder in $Folders) {

    $IndexPath = Join-Path (Join-Path $Base $Folder) "index.html"

    if (Test-Path $IndexPath) {
        $Body += "    <li><a href=""$Folder/index.html"">$Folder</a> – OK</li>`n"
    } else {
        $Body += "    <li><span style='color:red;'>$Folder – index.html fehlt</span></li>`n"
    }
}

# Schreiben der Portal-Datei
Write-Host "[EngineCore][PORTAL] Erzeuge portal.html..." -ForegroundColor Green
$Header + $Body + $Footer | Out-File $PortalFile -Encoding UTF8

Write-Host "[EngineCore][PORTAL] Portal-Build abgeschlossen." -ForegroundColor Cyan
