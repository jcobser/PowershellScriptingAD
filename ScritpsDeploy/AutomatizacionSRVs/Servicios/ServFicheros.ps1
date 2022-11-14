###################################################
####
#### Autor: Juan Marcos Cobelo Serantes
####
####
#### Configuración de un servidor de ficheros según
#### normativa de 
####
#### 
####
#### Copiar el Script a Documentos\Scripts\
####
###################################################
    [string] $DirCommand   = Split-Path -Parent $PSCommandPath
    [string] $NetBiosCmp   = hostname
    [string] $DOM          = (Get-ADDomain).DNSROot
    [string] $NetBiosDOM   = (Get-ADDomain).NetBiosName
    [string[]]$ComuserDirs =@('APLICACIONES','COMUN','GRUPOS')

# Creación de las rutas donde se guardarán las carpetas compartidas
#Particionado del segundo disco duro

$Disk = Get-Disk | Where {$_.OperationalStatus -eq 'Offline'} | Select Name

#Set-Disk -Number 1 -IsOffline $false
#Initialize-Disk -Number 1 -PartitionStyle MBR
#New-Partition -DiskNumber 1 -DriveLetter G  -UseMaximumSize
#Format-Volume -DriveLetter G -FileSystem NTFS -Force

 
#Creación de las rutas donde se guardarán los datos
$ComuserDirs | foreach-Object {New-Item -ItemType Directory -Path G:\$NetBiosDom\COMUSER\$_ -Force}
New-Item -ItemType Directory -Path G:\$NetBiosDom\USUARIOS -Force

# Creación de las carpetas compartidas y los permisos SMB correspondientes
New-SmbShare -Name "USUARIOS" -Path G:\$NetBiosDOM\USUARIOS -FullAccess "$NetBiosDOM\ADmins. del Dominio" -ChangeAccess "$NetBiosDOM\Usuarios del dominio" -FolderEnumerationMode AccessBased -CachingMode None
New-SmbShare -Name "COMUSER" -Path G:\$NetBiosDOM\COMUSER -FullAccess "$NetBiosDOM\ADmins. del Dominio" -ChangeAccess "$NetBiosDOM\Usuarios del dominio" -FolderEnumerationMode AccessBased -CachingMode None

# Creación de los permisos NTFS para cada carpeta

## Permisos NFTS para carpeta USUARIOS {Admins. del dominio CT
#                                       Usuarios del dominio --- Ninguno ---
$dir = "G:\$NetBiosDom\USUARIOS"

$acl = Get-Acl $dir
$acl.SetAccessRuleProtection($true, $false)
$grupo = New-Object System.Security.Principal.NTAccount("Admins. del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl","ContainerInherit, ObjectInherit", "None", "Allow")))

Set-Acl $dir $acl

## Permisos NFTS para carpeta COMUSER {Admins. del dominio  CT
#                                       Usuarios del dominio R

$dir = "G:\$NetBiosDom\COMUSER"

$acl = Get-Acl $dir
$acl.SetAccessRuleProtection($true, $false)
$grupo = New-Object System.Security.Principal.NTAccount("Admins. del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$grupo = New-Object System.Security.Principal.NTAccount("Usuarios del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")))

Set-Acl $dir $acl

## Permisos NFTS para carpeta COMUSER\APLICACIONES {Admins. del dominio  CT
#                                                   Usuarios del dominio R

$dir = "G:\$NetBiosDom\COMUSER\APLICACIONES"

$acl = Get-Acl $dir
$acl.SetAccessRuleProtection($true, $false)
$grupo = New-Object System.Security.Principal.NTAccount("Admins. del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$grupo = New-Object System.Security.Principal.NTAccount("Usuarios del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")))

Set-Acl $dir $acl

## Permisos NFTS para carpeta COMUSER\COMUN {Admins. del dominio  CT
#                                            Usuarios del dominio RW

$dir = "G:\$NetBiosDom\COMUSER\COMUN"

$acl = Get-Acl $dir
$acl.SetAccessRuleProtection($true, $false)
$grupo = New-Object System.Security.Principal.NTAccount("Admins. del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$grupo = New-Object System.Security.Principal.NTAccount("Usuarios del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")))

Set-Acl $dir $acl

## Permisos NFTS para carpeta COMUSER\GRUPOS {Admins. del dominio  CT
#                                             Usuarios del dominio R

$dir = "G:\$NetBiosDom\COMUSER\GRUPOS"

$acl = Get-Acl $dir
$acl.SetAccessRuleProtection($true, $false)
$grupo = New-Object System.Security.Principal.NTAccount("Admins. del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$grupo = New-Object System.Security.Principal.NTAccount("Usuarios del dominio")
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")))

Set-Acl $dir $acl