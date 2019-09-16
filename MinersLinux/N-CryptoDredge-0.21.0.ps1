
$M = @{
    Path       = "CryptoDredge_0.21.0/CryptoDredge"
    Type       = "NVIDIA"
    Arguments  = @(
        "-o #Protocol#://#Server#:#Port#"
        "-u #Login#"
        "-p #Password#"
        "-d #Devices#"
        "--retries 4"
        "--retry-pause 10"
        "--timeout 60"
        "--no-watchdog"
        "-b 127.0.0.1:#APIPort#"
        "#AlgorithmParameters#"
        "#CustomParameters#"
    )
    API        = "Ccminer"
    Fee        = 0.01
    Algorithms = [PSCustomObject]@{
        Allium      = "-a allium"
        Argon2d250  = "-a argon2d250"
        Argon2d256  = "-a chukwa-wrkz"
        Argon2d500  = "-a argon2d-dyn"
        Argon2d512  = "-a chukwa"
        Argon2d4096 = "-a argon2d4096"
        Argon2dNim  = "-a argon2d-nim"
        # BCD        = "-a bcd"
        # Bitcore    = "-a bitcore"
        CnConceal   = "-a cnconceal"
        CnGpu       = "-a cngpu"
        CnHalf      = "-a cnfast2"
        CnHaven     = "-a cnhaven"
        CnHeavy     = "-a cnheavy"
        CnLiteV7    = "-a aeon"
        CnSaber     = "-a cnsaber"
        CnTurtle    = "-a cnturtle"
        # Cuckoo29   = @{
        #     Params = "-a aeternity"
        #     Mem    = 5.3
        # }
        # Cuckaroo29 = @{
        #     Params = "-a cuckaroo29"
        #     NoCpu  = true
        #     Mem    = 5.3
        # }
        Hmq1725     = "-a hmq1725"
        # Lyra2v3    = "-a lyra2rev3"
        Lyra2vc0ban = "-a lyra2vc0banhash"
        # Lyra2z     = "-a lyra2z"
        Lyra2zz     = "-a lyra2zz"
        MTP         = @{
            Params = "-a mtp"
            Mem    = 4.5
            Fee    = 0.02
        }
        NeoScrypt   = "-a neoscrypt"
        Phi2        = "-a phi2"
        Pipe        = "-a pipe"
        Skunk       = "-a skunk"
        Tribus      = "-a tribus"
        # X16r       = "-a x16r"
        # X16rt      = "-a x16rt"
        # X16s       = "-a x16s"
        # X17        = "-a x17"
        X21s        = "-a x21s"
        # X22i       = "-a x22i"
    }
}

if ($SystemInfo.CudaVersion -ge [version]"10.1") {
    $M.Uri = "https://github.com/technobyl/CryptoDredge/releases/download/v0.21.0/CryptoDredge_0.21.0_cuda_10.1_linux.tar.gz"
    $M.SHA256 = "B24B31829F4CE23862E1971F4D66F353FCA8D60A6728564CDC973418B9DB58D9"
    $M.CUDA = 10.1
} elseif ($SystemInfo.CudaVersion -ge [version]"10.0") {
    $M.Uri = "https://github.com/technobyl/CryptoDredge/releases/download/v0.21.0/CryptoDredge_0.21.0_cuda_10.0_linux.tar.gz"
    $M.SHA256 = "69ADCE2DF836934CF67E05D9A611C2DEA5F236F7313126169F9C8215211D85E1"
    $M.CUDA = 10
} elseif ($SystemInfo.CudaVersion -ge [version]"9.2") {
    $M.Uri = "https://github.com/technobyl/CryptoDredge/releases/download/v0.21.0/CryptoDredge_0.21.0_cuda_9.2_linux.tar.gz"
    $M.SHA256 = "9BD1F63CF589A7BBDF17720CB4B747DE693827D3661592761CBD27C4243DF05C"
    $M.CUDA = 9.2
} else {
    return
}

return [PSCustomObject]$M