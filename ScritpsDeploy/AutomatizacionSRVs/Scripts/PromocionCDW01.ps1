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
    [string] $NetBiosCmp = "SRV" + $strPuesto + "CDW01"
    [string] $NetBiosDOM = $strPuesto
    [string] $DOM        = $NetBiosDOM + ".LOCAL"
    [string] $Ip         = "172.16."+$Puesto+".254"
    [string] $DefaultGw  = "172.16."+$Puesto+".1"
    [string] $DNS        = "172.16."+$Puesto+".254"

}

 Write-host -ForegroundColor Cyan "Cuando reinicie el sistema ejecute C:\users\Administrador\Documents\Scripts\PostInstForest.ps1"

New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion' -Name RunOnce

New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name "CDW01-PostInstall" `    -Value "PowerShell.exe -ExecutionPolicy Bypass -Noexit -File C:\users\Administrador\Documents\Scripts\PostInstForest.ps1 -Puesto $Puesto"

#Promocion de Bosque
Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "E:\AD\NTDS" `
-DomainMode "Win2008R2" `
-DomainName $DOM `
-DomainNetbiosName $NetBiosDOM `
-ForestMode "Win2008R2" `
-InstallDns:$true `
-LogPath "E:\AD\NTDS" `
-NoRebootOnCompletion:$true `
-SysvolPath "E:\AD\SYSVOL" `
-Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "SafeMod3." -Force)

Write-Host -ForegroundColor Cyan  "Se reinicia el equipo....."Start-Sleep 10Restart-Computer