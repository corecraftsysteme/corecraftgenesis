<#
    EngineCore Genesis Portal Auto-Refresh Daemon
    Überwacht alle Genesis-Schichten und regeneriert portal.html bei Änderungen
    Version: 2026-09-20
#>

Write-Host "[EngineCore][DAEMON] Starte Portal-Auto-Refresh-Daemon..." -ForegroundColor Cyan

$Base = "C:\corecraftgenesis.ch"
$PortalBuilder = Join-Path $Base "build-portal.ps1"

# Hash-Cache für Änderungsdetektion
$State = @{}

function Get-FolderState {
    param($Path)

    $Files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
    $Hash = ""

    foreach ($File in $Files) {
        try {
            $Hash += (Get-FileHash $File.FullName -Algorithm SHA256).Hash
        } catch {
            $Hash += "ERR"
        }
    }

    return (Get-FileHash -InputStream ([IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($Hash))) -Algorithm SHA256).Hash
}

function Check-GenesisState {
    $Folders = Get-ChildItem -Path $Base -Directory

    foreach ($Folder in $Folders) {
        $Path = $Folder.FullName
        $CurrentHash = Get-FolderState -Path $Path

        if ($State[$Path] -ne $CurrentHash) {
            Write-Host "[EngineCore][DAEMON] Änderung erkannt in: $($Folder.Name)" -ForegroundColor Yellow
            $State[$Path] =