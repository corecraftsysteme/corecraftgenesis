[CmdletBinding()]
param(
    [string[]]$StartTxIds = @(
        "0afdce7db2c99e72633cba22a564609f2af37f74d21fde3275eec0050b35ecc9",
        "fd0746e3c0a5f6854e4af6c3cf8b314e8b6440e69cfed3e6defe3a13df63cb70"
    ),

    [int64]$TargetSatoshi = 12500000,

    [int]$MaxDepth = 5,

    [int]$MaxTransactions = 250,

    [int]$DelayMilliseconds = 300
)

$ErrorActionPreference = "Stop"

$Api = "https://mempool.space/api"

$Queue = [System.Collections.Generic.Queue[object]]::new()
$Visited = [System.Collections.Generic.HashSet[string]]::new()
$Matches = [System.Collections.Generic.List[object]]::new()

foreach ($TxId in $StartTxIds) {
    $Queue.Enqueue(
        [PSCustomObject]@{
            TxId  = $TxId
            Depth = 0
            ParentTxId = $null
            ParentVout = $null
        }
    )
}

$Processed = 0

function Invoke-MempoolApi {
    param(
        [Parameter(Mandatory)]
        [string]$Uri
    )

    while ($true) {
        try {
            return Invoke-RestMethod `
                -Uri $Uri `
                -Method Get `
                -TimeoutSec 30
        }
        catch {
            $StatusCode = $null

            if ($_.Exception.Response) {
                $StatusCode = [int]$_.Exception.Response.StatusCode
            }

            if ($StatusCode -eq 429) {
                Write-Host "[RATE LIMIT] Warte 5 Sekunden..." `
                    -ForegroundColor Yellow

                Start-Sleep -Seconds 5
                continue
            }

            throw
        }
    }
}

Write-Host ""
Write-Host "============================================================"
Write-Host " CoreCraft Genesis - Bitcoin Output Chain Scanner"
Write-Host "============================================================"
Write-Host "Target          : $TargetSatoshi sat"
Write-Host "Target BTC      : $($TargetSatoshi / 100000000)"
Write-Host "Max Depth       : $MaxDepth"
Write-Host "Max Transactions: $MaxTransactions"
Write-Host ""

while (
    $Queue.Count -gt 0 -and
    $Processed -lt $MaxTransactions
) {
    $Current = $Queue.Dequeue()

    if ($Current.Depth -gt $MaxDepth) {
        continue
    }

    if (-not $Visited.Add($Current.TxId)) {
        continue
    }

    $Processed++

    Write-Host (
        "[SCAN] Depth {0} | {1}" -f
        $Current.Depth,
        $Current.TxId
    ) -ForegroundColor Cyan

    try {
        $Tx = Invoke-MempoolApi `
            -Uri "$Api/tx/$($Current.TxId)"

        Start-Sleep -Milliseconds $DelayMilliseconds

        $Outspends = Invoke-MempoolApi `
            -Uri "$Api/tx/$($Current.TxId)/outspends"

        Start-Sleep -Milliseconds $DelayMilliseconds
    }
    catch {
        Write-Host (
            "[ERROR] {0}: {1}" -f
            $Current.TxId,
            $_.Exception.Message
        ) -ForegroundColor Red

        continue
    }

    for ($Vout = 0; $Vout -lt $Tx.vout.Count; $Vout++) {

        $Output = $Tx.vout[$Vout]
        $Value = [int64]$Output.value

        $Address = $Output.scriptpubkey_address
        $Type = $Output.scriptpubkey_type

        if ($Value -eq $TargetSatoshi) {

            $Match = [PSCustomObject]@{
                TxId       = $Current.TxId
                Vout       = $Vout
                Satoshi    = $Value
                BTC        = [decimal]$Value / 100000000
                Address    = $Address
                Type       = $Type
                Depth      = $Current.Depth
                ParentTxId = $Current.ParentTxId
                ParentVout = $Current.ParentVout
                Spent      = $Outspends[$Vout].spent
                SpendingTx = $Outspends[$Vout].txid
            }

            $Matches.Add($Match)

            Write-Host ""
            Write-Host "[MATCH] 0,125 BTC gefunden" `
                -ForegroundColor Green

            $Match | Format-List
        }

        if (
            $Current.Depth -lt $MaxDepth -and
            $Outspends[$Vout].spent -eq $true -and
            -not [string]::IsNullOrWhiteSpace(
                [string]$Outspends[$Vout].txid
            )
        ) {
            $Queue.Enqueue(
                [PSCustomObject]@{
                    TxId       = $Outspends[$Vout].txid
                    Depth      = $Current.Depth + 1
                    ParentTxId = $Current.TxId
                    ParentVout = $Vout
                }
            )
        }
    }
}

Write-Host ""
Write-Host "============================================================"
Write-Host " SCAN SUMMARY"
Write-Host "============================================================"
Write-Host "Transactions scanned : $Processed"
Write-Host "Queued remaining      : $($Queue.Count)"
Write-Host "Matches               : $($Matches.Count)"
Write-Host ""

if ($Matches.Count -gt 0) {
    $Matches |
        Select-Object `
            Depth,
            TxId,
            Vout,
            BTC,
            Satoshi,
            Address,
            Spent,
            SpendingTx |
        Format-Table -AutoSize

    $ReportPath = Join-Path $PWD "bitcoin-chain-matches.json"

    $Matches |
        ConvertTo-Json -Depth 10 |
        Set-Content -LiteralPath $ReportPath -Encoding UTF8

    Write-Host "[PASS] Trefferbericht: $ReportPath" `
        -ForegroundColor Green
}
else {
    Write-Host (
        "[NO MATCH] Kein Output mit exakt {0} sat gefunden." -f
        $TargetSatoshi
    ) -ForegroundColor Yellow
}

if ($Processed -ge $MaxTransactions) {
    Write-Host (
        "[STOP] Sicherheitsgrenze von {0} Transaktionen erreicht." -f
        $MaxTransactions
    ) -ForegroundColor Yellow
}
