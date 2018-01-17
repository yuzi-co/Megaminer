﻿param(
    [Parameter(Mandatory = $true)]
    [String]$Querymode = $null,
    [Parameter(Mandatory = $false)]
    [pscustomobject]$Info
)

#. .\..\Include.ps1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$ActiveOnManualMode = $true
$ActiveOnAutomaticMode = $true
$ActiveOnAutomatic24hMode = $false
$AbbName = 'NH'
$WalletMode = "WALLET"
$Result = @()


if ($Querymode -eq "info") {
    $Result = [PSCustomObject]@{
        Disclaimer            = "No registration, Autoexchange to BTC always"
        ActiveOnManualMode    = $ActiveOnManualMode
        ActiveOnAutomaticMode = $ActiveOnAutomaticMode
        ApiData               = $True
        AbbName               = $AbbName
        WalletMode            = $WalletMode
    }
}


if ($Querymode -eq "speed") {
    $Info.user = ($Info.user -split '\.')[0]

    try {
        $http = "https://api.nicehash.com/api?method=stats.provider.workers&addr=" + $Info.user
        $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json
    } catch {}

    $Result = @()

    if ($Request.Result.Workers -ne $null -and $Request.Result.Workers -ne "") {
        $A = $Request.Result.Workers
        $Request.Result.Workers |ForEach-Object {
            $Result += [PSCustomObject]@{
                PoolName   = $name
                WorkerName = $_[0]
                Rejected   = $_[4]
                Hashrate   = [double]$_[1].a * 1000000
            }
        }
        remove-variable Request
    }
}


if ($Querymode -eq "wallet") {
    $Info.user = ($Info.user -split '\.')[0]
    try {
        $http = "https://api.nicehash.com/api?method=stats.provider&addr=" + $Info.user
        $Request = Invoke-WebRequest $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json |Select-Object -ExpandProperty result  |Select-Object -ExpandProperty stats
    } catch {}

    if ($Request -ne $null -and $Request -ne "") {
        $Result = [PSCustomObject]@{
            Pool     = $name
            currency = "BTC"
            balance  = ($Request | Measure-Object -Sum balance).sum
        }
    }
    Remove-variable Request
}


if (($Querymode -eq "core" ) -or ($Querymode -eq "Menu")) {

    $retries = 1
    do {
        try {
            $http = "https://api.nicehash.com/api?method=simplemultialgo.info"
            $Request = Invoke-WebRequest $http -UseBasicParsing -TimeoutSec 5 | ConvertFrom-Json |Select-Object -expand result |Select-Object -expand simplemultialgo
        } catch {start-sleep 2}
        $retries++
        if ($Request -eq $null -or $Request -eq "") {start-sleep 3}
    } while ($Request -eq $null -and $retries -le 3)

    if ($retries -gt 3) {
        Write-Host $Name 'API NOT RESPONDING...ABORTING'
        Exit
    }

    $Locations = @()
    $Locations += [PSCustomObject]@{NhLocation = 'USA'; MMlocation = 'US'}
    $Locations += [PSCustomObject]@{NhLocation = 'EU'; MMlocation = 'Europe'}

    $Request | Where-Object {$_.paying -gt 0 } | ForEach-Object {

        $Algo = get_algo_unified_name ($_.name)

        $Divisor = 1000000000

        foreach ($location in $Locations) {

            $enableSSL = ($Algo -in @('Cryptonight', 'Equihash'))

            $Result += [PSCustomObject]@{
                Algorithm             = $Algo
                Info                  = $coin
                Price                 = [double]($_.paying / $Divisor)
                Price24h              = $null
                Protocol              = "stratum+tcp"
                ProtocolSSL           = if ($enableSSL) {"stratum+tls"} else {$null}
                Host                  = $_.name + "." + $location.NhLocation + ".nicehash.com"
                Port                  = $_.port
                PortSSL               = if ($enableSSL) {$_.port + 30000} else {$null}
                User                  = $(if ($CoinsWallets.get_item('BTC_NICE') -ne $null) {$CoinsWallets.get_item('BTC_NICE')} else {$CoinsWallets.get_item('BTC')}) + '.' + "#Workername#"
                Pass                  = "x"
                Location              = $location.MMLocation
                SSL                   = $enableSSL
                Symbol                = $null
                AbbName               = $AbbName
                ActiveOnManualMode    = $ActiveOnManualMode
                ActiveOnAutomaticMode = $ActiveOnAutomaticMode
                PoolName              = $Name
                WalletMode            = $WalletMode
                WalletSymbol          = "BTC"
                Fee                   = $(if ($CoinsWallets.get_item('BTC_NICE') -ne $null) {0.02} else {0.05})
                EthStMode             = 3
            }
        }
    }
    Remove-variable Request
}


$Result |ConvertTo-Json | Set-Content $info.SharedFile
Remove-variable Result
