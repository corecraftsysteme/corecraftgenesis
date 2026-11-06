[CmdletBinding()]
param(
    [string]$RepositoryRoot = "C:\corecraftgenesis-github"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$HtmlRelative = "products\developer-tools\web-tools\route-checker\index.html"
$JsRelative = "products\developer-tools\web-tools\route-checker\assets\js\route-checker.js"
$HtmlPath = Join-Path $RepositoryRoot $HtmlRelative
$JsPath = Join-Path $RepositoryRoot $JsRelative
$BackupRoot = "C:\corecraftgenesis-backups\route-checker-extraction-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

if (-not (Test-Path -LiteralPath $HtmlPath -PathType Leaf)) {
    throw "HTML-Datei nicht gefunden: $HtmlPath"
}

$Html = Get-Content -LiteralPath $HtmlPath -Raw
$Pattern = '(?is)<script\b(?![^>]*\bsrc\s*=)[^>]*>(?<code>.*?)</script>'
$Matches = @([regex]::Matches($Html, $Pattern))

if ($Matches.Count -ne 1) {
    throw "Abbruch: Erwartet wurde genau 1 Inline-Skript, gefunden: $($Matches.Count)"
}

$Match = $Matches[0]
$Code = $Match.Groups["code"].Value

if ([string]::IsNullOrWhiteSpace($Code)) {
    throw "Abbruch: Inline-Skript ist leer."
}

if ($Code.Length -lt 10000) {
    throw "Abbruch: Skript ist unerwartet klein ($($Code.Length) Zeichen)."
}

$RequiredSignals = @(
    '"use strict"',
    'addEventListener',
    '})();'
)

foreach ($Signal in $RequiredSignals) {
    if (-not $Code.Contains($Signal)) {
        throw "Abbruch: Erwartetes Signal fehlt: $Signal"
    }
}

$BackupHtmlPath = Join-Path $BackupRoot $HtmlRelative
$BackupDirectory = Split-Path -Parent $BackupHtmlPath
New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
Copy-Item -LiteralPath $HtmlPath -Destination $BackupHtmlPath -Force

$JsDirectory = Split-Path -Parent $JsPath
New-Item -ItemType Directory -Path $JsDirectory -Force | Out-Null

$Utf8NoBom = [Text.UTF8Encoding]::new($false)
$NormalizedCode = $Code.Trim() + [Environment]::NewLine
[IO.File]::WriteAllText($JsPath, $NormalizedCode, $Utf8NoBom)

$IndentStart = $Html.LastIndexOf("`n", $Match.Index)
if ($IndentStart -lt 0) { $IndentStart = 0 } else { $IndentStart++ }
$IndentLength = 0
while (($IndentStart + $IndentLength) -lt $Html.Length -and $Html[$IndentStart + $IndentLength] -in @(' ', "`t")) {
    $IndentLength++
}
$Indent = $Html.Substring($IndentStart, $IndentLength)
$ExternalTag = $Indent + '<script src="./assets/js/data-inspector.js"></script>'

$UpdatedHtml = $Html.Remove($Match.Index, $Match.Length).Insert($Match.Index, $ExternalTag)
[IO.File]::WriteAllText($HtmlPath, $UpdatedHtml, $Utf8NoBom)

$FinalHtml = Get-Content -LiteralPath $HtmlPath -Raw
$FinalInlineCount = @([regex]::Matches($FinalHtml, $Pattern)).Count
$ExternalCount = @([regex]::Matches($FinalHtml, '(?is)<script\b[^>]*\bsrc\s*=\s*["'']\./assets/js/data-inspector\.js["''][^>]*></script>')).Count

if ($FinalInlineCount -ne 0 -or $ExternalCount -ne 1 -or -not (Test-Path -LiteralPath $JsPath -PathType Leaf)) {
    Copy-Item -LiteralPath $BackupHtmlPath -Destination $HtmlPath -Force
    Remove-Item -LiteralPath $JsPath -Force -ErrorAction SilentlyContinue
    throw "Validierung fehlgeschlagen. HTML wurde aus dem Backup wiederhergestellt."
}

$Node = Get-Command node -ErrorAction SilentlyContinue
if ($null -ne $Node) {
    & $Node.Source --check $JsPath
    if ($LASTEXITCODE -ne 0) {
        Copy-Item -LiteralPath $BackupHtmlPath -Destination $HtmlPath -Force
        Remove-Item -LiteralPath $JsPath -Force -ErrorAction SilentlyContinue
        throw "JavaScript-Syntaxprüfung fehlgeschlagen. Änderungen wurden zurückgesetzt."
    }
    $NodeStatus = "PASS"
}
else {
    $NodeStatus = "SKIPPED (node nicht installiert)"
}

$JsInfo = Get-Item -LiteralPath $JsPath

Write-Host ""
Write-Host "============================================================"
Write-Host " ROUTE CHECKER - SAFE SCRIPT EXTRACTION"
Write-Host "============================================================"
Write-Host "HTML                 : $HtmlRelative"
Write-Host "JavaScript           : $JsRelative"
Write-Host "JS bytes             : $($JsInfo.Length)"
Write-Host "Inline scripts after : $FinalInlineCount"
Write-Host "External tag count   : $ExternalCount"
Write-Host "Node syntax check    : $NodeStatus"
Write-Host "Backup               : $BackupRoot"
Write-Host "============================================================"
Write-Host "[PASS] Route Checker wurde sicher ausgelagert." -ForegroundColor Green
