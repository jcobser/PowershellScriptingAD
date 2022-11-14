###################################################
####
#### Autor: Juan Marcos Cobelo Serantes
####
####
#### Configuración de los primeros pasos para un 
#### CDW01
####
#### Paso3
####
#### Copiar el Script a Documentos\Scripts\
####
###################################################

Param (
    [Parameter(Mandatory=$true)] [int]$Puesto
)

Start-Sleep 30

If ($Puesto -lt 0 -or $Puesto -gt 31){
    Write-host -ForegroundColor Cyan "Numero de puesto inválido (Entre 0 y 31)"
    break
}
else {
    If ($Puesto -eq 0) { $strPuesto = "PROFE" } else { $strPuesto = "DOM" + $Puesto.ToString().PadLeft(2,'0') }
    [string] $DirCommand   = Split-Path -Parent $PSCommandPath
    [string] $NetBiosCmp   = "SRV" + $strPuesto + "CDW01"
    [string] $NetBiosDOM   = $strPuesto
    [string] $SufijoDOM    =  "LOCAL"
    [string] $DOM          = $NetBiosDOM + "." + $SufijoDOM
    [string] $Ip           = "172.16."+$Puesto+".254"
    [string] $DefaultGw    = "172.16."+$Puesto+".1"
    [string] $DNS          = "172.16."+$Puesto+".254"
    [string] $SiteName     = "SAR-" + $NetBiosDOM + "-SITE"
    [string] $SubnetName   = "172.16." + $Puesto + ".0/24"
    [string] $SubnetObject = "CN=SubNets,CN=Sites,CN=Configuration,DC=" + $NetBiosDOM + ",DC=" + $SufijoDOM
    [string] $SiteObject   = "CN=" + $SiteName + ",CN=Sites,CN=Configuration,DC=" + $NetBiosDOM + ",DC=" + $SufijoDOM
    [string] $DNSForwarder = "192.168.7.254"
    [string] $ReverseZone  = [string]$Puesto + ".16.172.in-addr.arpa"
    [string] $DHCPStartRange  = "172.16."+$Puesto+".1"
    [string] $DHCPEndRange    = "172.16."+$Puesto+".254"
    [string] $DHCPSubnet      = "255.255.255.0"

}

Get-AdObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -Filter {Objectclass -eq 'site'} | Rename-ADObject -NewName $SiteName

New-ADObject -Name $SubnetName -Type Subnet -Path $SubnetObject -OtherAttributes @{SiteObject=$SiteObject}

New-ADOrganizationalUnit ESTACIONES
New-ADOrganizationalUnit USUARIOS

[string] $OuEstaciones = "OU=ESTACIONES," + (Get-ADDomain).DistinguishedName
REDIRCMP $OuEstaciones
[string] $OuUsuarios = "OU=USUARIOS," + (Get-ADDomain).DistinguishedName
REDIRUSR $OuUsuarios

#Configuracion DNS 

Add-DnsServerPrimaryZone -NetworkId $SubnetName -ReplicationScope Domain -DynamicUpdate Secure 
Set-DnsServerZoneAging -Name $DOM -Aging $true -RefreshInterval 08.00:00:00 -NoRefreshInterval 08.00:00:00
Set-DnsServerZoneAging -Name $ReverseZone -Aging $true -RefreshInterval 08.00:00:00 -NoRefreshInterval 08.00:00:00
Add-DnsServerForwarder $DNSForwarder
Set-DnsServerForwarder -UseRootHint $False

#Servicio de DHCP
Install-WindowsFeature DHCP -IncludeManagementTools

Add-DhcpServerInDC

Add-DhcpServerv4Scope -Name RedLan `    -StartRange $DHCPStartRange -EndRange $DHCPEndRange `    -SubnetMask $DHCPSubnet -State Active `    -LeaseDuration 8.00:00:00

Add-DhcpServerv4ExclusionRange -ScopeId $SubnetName.Substring(0,$SubnetName.Length -3) `    -StartRange ($SubnetName.Substring(0,$SubnetName.LastIndexOf('.')+1) + "1").ToString() `    -EndRange ($SubnetName.Substring(0,$SubnetName.LastIndexOf('.')+1) + "10").ToString()

Add-DhcpServerv4ExclusionRange -ScopeId $SubnetName.Substring(0,$SubnetName.Length -3) `    -StartRange ($SubnetName.Substring(0,$SubnetName.LastIndexOf('.')+1) + "245").ToString() `    -EndRange ($SubnetName.Substring(0,$SubnetName.LastIndexOf('.')+1) + "254").ToString()

Set-DhcpServerv4OptionValue -ScopeId $SubnetName.Substring(0,$SubnetName.Length -3)  -DnsServer $Ip -DnsDomain $DOM -Router $DefaultGw


#Importacion de usuarios de dominio

& "$DirCommand\ImportacionUsuarios.ps1"

