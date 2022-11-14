Param (
    [Parameter(Mandatory=$false)][String]$Ip ,
	[Parameter(Mandatory=$false)][String]$Filtro
)

If ($Ip -eq "" -and $Filtro -eq "") {
    Write-Host "Debe especificar una dirección IP o un filtro de direcciones"
    Exit
}

If ($Ip -ne "" -and $Filtro -ne "") {
    Write-Host "No es posible especificar las opciones Equipo y filtro a la vez"
    Exit
}

If ($Ip -ne "") {
    $Ips = netsh dhcp server \\srveeaecdw03 scope 192.168.0.0 show clients | findstr \<$Ip\>
}
If ($Filtro -ne "") {
$Ips = netsh dhcp server \\srveeaecdw03 scope 192.168.0.0 show clients | findstr $filtro
}

Function llama(){
    param (
        [String] $mac,
        [String] $ip = "192.168.7.255",
        [Int] $port = 9
    )
    $broadcast = [Net.IPAddress]::Parse($ip)
    $mac = (($mac.Replace(":","")).Replace("-","")).Replace(".","")
    $target = 0,2,4,6,8,10 | % {[Convert]::ToByte($mac.substring($_,2),16)}
    $packet = (,[byte]255*6)+($target*16)
    $UDPClient = New-Object System.Net.Sockets.UdpClient
    $UDPClient.Connect($broadcast, $port)
    [void]$UDPClient.Send($packet,102)
}


foreach ($computer in $Ips) {
    write-host "equipo encontrado $computer.substr"
    $datos = $computer -split("  -")
    $mac = $($datos[2].trim())
    write-host $mac
    llama -mac $mac
}