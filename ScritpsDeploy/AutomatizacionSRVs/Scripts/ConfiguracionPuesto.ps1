###################################################
####
#### Autor: Juan Marcos Cobelo Serantes
####
####
#### Configuración de los primeros pasos para un 
#### CDW01
####
#### Paso1
####
#### Copiar el Script a Documentos\Scripts\
####
###################################################

Param (
    [Parameter(Mandatory=$true)] [int]$Puesto
)


If ($Puesto -lt 0 -or $Puesto -gt 31){
    Write-host -ForegroundColor Cyan "Numero de puesto inválido (Entre 0 y 31)"
    break
}
else {
    If ($Puesto -eq 0) { $strPuesto = "PROFE" } else { $strPuesto = "DOM" + $Puesto.ToString().PadLeft(2,'0') }
    [string] $NetBiosCmp = "SRV" + $strPuesto + "CDW01"
    [string] $NetBiosDOM = $strPuesto
    [string] $DOM        = $NetBiosDOM + ".LOCAL"
    [string] $Ip         = "172.16."+$Puesto+".254"
    [string] $DefaultGw  = "172.16."+$Puesto+".1"
    [string] $DNS        = "172.16."+$Puesto+".254"

}


New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $Ip -DefaultGateway $DefaultGw -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DNS

#Navegar por regritro
Set-Location HKLM:.\System\CurrentControlSet\Services\TCPIP6\Parameters

#Deshabilitar IPv6
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\TCPIP6\Parameters -Name "DisabledComponents" -PropertyType "DWORD" -Value 0x000000ff
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\TCPIP6\Parameters -Name "DisableIPSourceRouting" -PropertyType "DWORD" -Value 0x00000002


Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Escritorio Remoto" 
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1

#Cambio de nombre del equipo
Rename-Computer $NetBiosCmp


#Particionado del Disco Duro
Resize-Partition -DiskNumber 0 -PartitionNumber 2 -Size (48.42GB)
New-Partition -DiskNumber 0 -UseMaximumSize -DriveLetter E –MbrType IFS
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel "AD"

#Instalación del Servicio ADDS
Add-WindowsFeature AD-Domain-Services -IncludeManagementTools

#Guardado del siguiente paso

New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name "CDW01-Paso2" `    -Value "PowerShell.exe -ExecutionPolicy Bypass -Noexit -File C:\users\Administrador\Documents\Scripts\PromocionCDW01.ps1 -Puesto $Puesto"    echo Reinicie el servidor.....