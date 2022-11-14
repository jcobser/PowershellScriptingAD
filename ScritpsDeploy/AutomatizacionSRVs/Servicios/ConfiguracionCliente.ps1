    [string] $NetBiosCmp = "ZFNCNTS0001"
    [string] $Ip         = "172.16.0.5"
    [string] $DefaultGw  = "172.16.0.1"
    [string] $DNS        = "172.16.0.254"

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $Ip -DefaultGateway $DefaultGw -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DNS

#Deshabilitar IPv6
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\TCPIP6\Parameters -Name "DisabledComponents" -PropertyType "DWORD" -Value 0x000000ff
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\TCPIP6\Parameters -Name "DisableIPSourceRouting" -PropertyType "DWORD" -Value 0x00000002

#Cambio de nombre del equipo
Rename-Computer $NetBiosCmp

Restart-computer