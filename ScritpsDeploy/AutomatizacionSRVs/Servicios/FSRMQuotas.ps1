###################################################
####
#### Autor: Juan Marcos Cobelo Serantes
####
####
#### Configuración de Cuotas según
#### normativa de 
####
#### 
####
#### Copiar el Script a Documentos\Scripts\
####
#### Se deben  incluir las herramientas de administración 
#### del servicio de archivos y recursos compartidos
####
###################################################

    [string] $NetBiosDOM   = (Get-ADDomain).NetBiosName

## TEMPLATES

New-FsrmQuotaTemplate -Name "LIMITE 2GB MAXIMO" -Description "Limite máximo de 2GB para las carpetas de grupo" -Size 2GB
New-FsrmQuotaTemplate -Name "LIMITE 4GB MAXIMO" -Description "Limite máximo de 4GB para la carpeta COMUN" -Size 4GB
New-FsrmQuotaTemplate -Name "LIMITE 250MB MAXIMO" -Description "Limite máximo de 250MB para la carpetas de usuarios" -Size 250MB

New-FsrmAutoQuota -Path "G:\$NetBiosDOM\COMUSER\GRUPOS" -Template "LIMITE 2GB MAXIMO" 
Set-FsrmAutoQuota -Path "G:\$NetBiosDOM\COMUSER\GRUPOS" -Template "LIMITE 2GB MAXIMO" -UpdateDerived
New-FsrmAutoQuota -Path "G:\$NetBiosDOM\USUARIOS" -Template "LIMITE 250MB MAXIMO" 
Set-FsrmAutoQuota -Path "G:\$NetBiosDOM\USUARIOS" -Template "LIMITE 250MB MAXIMO" -UpdateDerived

New-FsrmQuota -Path "G:\$NetBiosDom\COMUSER\GRUPOS" -Template "LIMITE 4GB MAXIMO"

