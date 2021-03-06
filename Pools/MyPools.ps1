param(
    [Parameter(Mandatory = $true)]
    [String]$Querymode = $null,
    [Parameter(Mandatory = $false)]
    [PSCustomObject]$Info
)

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$ActiveOnManualMode = $true
$ActiveOnAutomaticMode = $false
$WalletMode = "None"
$RewardType = "PPLS"
$Result = @()

if ($Querymode -eq "Info") {
    $Result = [PSCustomObject]@{
        Disclaimer            = "Must set wallet for each coin on web, set login on config.ini file"
        ActiveOnManualMode    = $ActiveOnManualMode
        ActiveOnAutomaticMode = $ActiveOnAutomaticMode
        ApiData               = $true
        WalletMode            = $WalletMode
        RewardType            = $RewardType
    }
}

if ($Querymode -eq "Core") {
    $Pools = @(
        [PSCustomObject]@{ Coin = "Dallar"       ; Symbol = "DAL"  ; Algo = "Throestl"    ; Server = "pool.dallar.org"              ; Port = 3032 ; Fee = 0.01  ; User = $Wallets.DAL }
        [PSCustomObject]@{ Coin = "Pascal"       ; Symbol = "PASC" ; Algo = "RandomHash2" ; Server = "mine.pool.pascalpool.org"     ; Port = 3338 ; Fee = 0.005 ; User = $Wallets.PASC + "$(if ($null -eq ($Wallets.PASC -split '\.')[1]) {'.0'}).#WorkerName#/#Email#" }
        # [PSCustomObject]@{ Coin = "Grin"         ; Symbol = "GRIN" ; Algo = "Cuckaroo29"  ; Server = "eu-west-stratum.grinmint.com" ; Port = 3416 ; Fee = 0.01  ; User = '#Email#/#WorkerName#' }
        # [PSCustomObject]@{ Coin = "Verium"       ; Symbol = "VRM"  ; Algo = "Verium"      ; Server = "eu.vrm.mining-pool.ovh"       ; Port = 3032 ; Fee = 0.009 ; User = "#UserName.#WorkerName#" }
        # [PSCustomObject]@{ Coin = "Verus"        ; Symbol = "VRSC" ; Algo = "Verushash"   ; Server = "eu.luckpool.net"              ; Port = 3956 ; Fee = 0.009 ; User = $Wallets.VRSC + ".#WorkerName#" }
    )

    $Result = $Pools | ForEach-Object {
        [PSCustomObject]@{
            Algorithm             = $_.Algo
            Info                  = $_.Coin
            Protocol              = "stratum+tcp"
            Host                  = $_.Server
            Port                  = $_.Port
            User                  = $_.User
            Pass                  = if ([string]::IsNullOrEmpty($_.Pass)) { "x" } else { $_.Pass }
            Location              = "EU"
            SSL                   = $false
            Symbol                = $_.symbol
            ActiveOnManualMode    = $ActiveOnManualMode
            ActiveOnAutomaticMode = $ActiveOnAutomaticMode
            PoolName              = $Name
            WalletMode            = $WalletMode
            Fee                   = $_.Fee
            RewardType            = $RewardType
        }
    }
    Remove-Variable Pools
}

$Result
Remove-Variable result
