###################################################
####
#### Autor: Juan Marcos Cobelo Serantes
####
####
#### Configuración de los primeros pasos para un 
#### CDW01
####
#### Paso2
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
    [string] $NetBiosCmp = "SRV" + $strPuesto + "CDW02"
    [string] $NetBiosDOM = $strPuesto
    [string] $DOM        = $NetBiosDOM + ".LOCAL"
    [string] $Ip         = "172.16."+$Puesto+".253"
    [string] $DefaultGw  = "172.16."+$Puesto+".1"
    [string] $DNS        = "172.16."+$Puesto+".254"

}

 Write-host -ForegroundColor Cyan "Cuando reinicie el sistema ejecute C:\users\Administrador\Documents\Scripts\PostInstForest.ps1"

#Promocion a Controlador de dominio

Install-ADDSDomainController `
-CreateDnsDelegation:$false `
-DomainName $DOM `
-InstallDns:$true `
-DatabasePath "E:\AD\NTDS" `
-LogPath "E:\AD\NTDS" `
-SysvolPath "E:\AD\SYSVOL" `
-NoRebootOnCompletion:$true `
-Credential (Get-Credential) `
-Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "SafeMod3." -Force)
