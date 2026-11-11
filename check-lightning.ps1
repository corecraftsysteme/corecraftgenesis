$commands = @(
    "lncli",
    "lnd",
    "lightning-cli",
    "lightningd",
    "eclair-cli",
    "eclair-node",
    "ndlc",
    "ldk-node",
    "electrum",
    "phoenix-cli"
)

Write-Host "`n=== 1. Lightning-Programme im PATH ===" -ForegroundColor Cyan

$foundCommands = foreach ($command in $commands) {
    $result = Get-Command $command -ErrorAction SilentlyContinue

    if ($null -ne $result) {
        [PSCustomObject]@{
            Command = $command
            Type    = $result.CommandType
            Path    = $result.Source
        }
    }
}

if ($foundCommands) {
    $foundCommands | Format-Table -AutoSize
} else {
    Write-Host "Keine bekannte Lightning-CLI im PATH gefunden." -ForegroundColor Yellow
}

Write-Host "`n=== 2. Laufende Lightning-Prozesse ===" -ForegroundColor Cyan

$processPattern = '^(lnd|lightningd|eclair-node|electrum|phoenix|ldk-node|ndlc)$'

$foundProcesses = Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessName -match $processPattern } |
    Select-Object ProcessName, Id, Path

if ($foundProcesses) {
    $foundProcesses | Format-Table -AutoSize
} else {
    Write-Host "Keine bekannte Lightning-Implementierung läuft lokal." -ForegroundColor Yellow
}

Write-Host "`n=== 3. Installierte Programme ===" -ForegroundColor Cyan

$uninstallPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$foundApps = Get-ItemProperty $uninstallPaths -ErrorAction SilentlyContinue |
    Where-Object {
        $_.DisplayName -match 'Lightning|LND|Core Lightning|Eclair|Electrum|Phoenix|LDK|NDLC'
    } |
    Select-Object DisplayName, DisplayVersion, InstallLocation

if ($foundApps) {
    $foundApps | Format-Table -AutoSize
} else {
    Write-Host "Keine passende Windows-Installation gefunden." -ForegroundColor Yellow
}

Write-Host "`n=== 4. Docker ===" -ForegroundColor Cyan

if (Get-Command docker -ErrorAction SilentlyContinue) {
    $dockerResults = docker ps -a --format "{{.Names}}|{{.Image}}|{{.Status}}" 2>$null |
        Select-String -Pattern 'lightning|lnd|clightning|core-lightning|eclair|ldk|ndlc'

    if ($dockerResults) {
        $dockerResults
    } else {
        Write-Host "Keine Lightning-Container gefunden." -ForegroundColor Yellow
    }
} else {
    Write-Host "Docker ist nicht im PATH verfügbar." -ForegroundColor DarkGray
}

Write-Host "`n=== 5. WSL ===" -ForegroundColor Cyan

if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    $distributions = wsl.exe --list --quiet 2>$null |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }

    if ($distributions) {
        foreach ($distribution in $distributions) {
            Write-Host "`nWSL-Distribution: $distribution" -ForegroundColor White

            wsl.exe -d $distribution -- sh -lc '
                for cmd in lncli lnd lightning-cli lightningd eclair-cli electrum; do
                    if command -v "$cmd" >/dev/null 2>&1; then
                        printf "%s -> " "$cmd"
                        command -v "$cmd"
                    fi
                done
            '
        }
    } else {
        Write-Host "Keine WSL-Distribution installiert." -ForegroundColor Yellow
    }
} else {
    Write-Host "WSL ist nicht verfügbar." -ForegroundColor DarkGray
}

Write-Host "`n=== Prüfung abgeschlossen ===" -ForegroundColor Green
