<#
    EngineCore Deployment Script
    CoreCraft Genesis · Deterministic Deployment Layer
    Version: 2026-09-20
#>

Write-Host "[EngineCore][DEPLOY] Initialisiere Deployment..." -ForegroundColor Cyan

$Base = "C:\corecraftgenesis.ch"

# --- Ordnerliste ---
$Folders = @(
    "auditchain",
    "commodity-matrix",
    "mainchain",
    "hyperspace-ledger",
    "hyperspace-governance"
)

# --- HTML-Templates ---
$AuditChainHTML = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>AuditChain · CoreCraft Genesis</title>
  <link rel="stylesheet" href="../portal.css">
</head>
<body>
<?php include("../super-nav.html"); ?>
<header><h1>AuditChain</h1></header>
<section><h2>Mandat</h2><p>Globale Integritäts-Schicht.</p></section>
<section><h2>Blocktypen</h2></section>
<section><h2>Revisionsgraph</h2></section>
<section><h2>Integritäts-Proofs</h2></section>
<section><h2>Externe Verankerung</h2></section>
</body>
</html>
"@

$LedgerHTML = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>Hyperspace Ledger · CoreCraft Genesis</title>
  <link rel="stylesheet" href="../portal.css">
</head>
<body>
<?php include("../super-nav.html"); ?>
<header><h1>Hyperspace Ledger</h1></header>
<section><h2>Commit-Aggregation</h2></section>
<section><h2>AuditChain-Verknüpfung</h2></section>
</body>
</html>
"@

$GovernanceHTML = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>Hyperspace Governance · CoreCraft Genesis</title>
  <link rel="stylesheet" href="../portal.css">
</head>
<body>
<?php include("../super-nav.html"); ?>
<header><h1>Hyperspace Governance</h1></header>
<section><h2>Audit-Regeln</h2></section>
<section><h2>Governance-Sessions</h2></section>
</body>
</html>
"@

$CommodityHTML = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>Commodity-Matrix · CoreCraft Genesis</title>
  <link rel="stylesheet" href="../portal.css">
</head>
<body>
<?php include("../super-nav.html"); ?>
<header><h1>Commodity-Matrix</h1></header>
<section><h2>AuditChain-Verbindung</h2></section>
<section><h2>Integritäts-Proofs</h2></section>
</body>
</html>
"@

$MainchainHTML = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>Mainchain · CoreCraft Genesis</title>
  <link rel="stylesheet" href="../portal.css">
</head>
<body>
<?php include("../super-nav.html"); ?>
<header><h1>Mainchain</h1></header>
<section><h2>Verankerungs-Strategie</h2></section>
<section><h2>Broadcast-Authentizität</h2></section>
</body>
</html>
"@

# --- Deployment ---
foreach ($Folder in $Folders) {

    $Path = Join-Path $Base $Folder

    if (!(Test-Path $Path)) {
        Write-Host "[EngineCore][DEPLOY] Erzeuge Ordner: $Folder" -ForegroundColor Green
        New-Item -ItemType Directory -Path $Path | Out-Null
    } else {
        Write-Host "[EngineCore][DEPLOY] Ordner existiert: $Folder" -ForegroundColor Yellow
    }

    $IndexFile = Join-Path $Path "index.html"

    if (!(Test-Path $IndexFile)) {
        Write-Host "[EngineCore][DEPLOY] Erzeuge index.html für $Folder" -ForegroundColor Green

        switch ($Folder) {
            "auditchain"           { $AuditChainHTML     | Out-File $IndexFile -Encoding UTF8 }
            "hyperspace-ledger"    { $LedgerHTML         | Out-File $IndexFile -Encoding UTF8 }
            "hyperspace-governance"{ $GovernanceHTML     | Out-File $IndexFile -Encoding UTF8 }
            "commodity-matrix"     { $CommodityHTML      | Out-File $IndexFile -Encoding UTF8 }
            "mainchain"            { $MainchainHTML      | Out-File $IndexFile -Encoding UTF8 }
        }
    } else {
        Write-Host "[EngineCore][DEPLOY] index.html existiert bereits: $Folder" -ForegroundColor Yellow
    }
}

Write-Host "[EngineCore][DEPLOY] Deployment abgeschlossen." -ForegroundColor Cyan
