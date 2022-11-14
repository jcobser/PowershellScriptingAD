Param (
    [Parameter(Mandatory=$true)] [String]$carpeta
)
    [string] $DirCommand   = Split-Path -Parent $PSCommandPath
    [string] $SRVFICHEROS   = hostname
    [string] $DOM          = (Get-ADDomain).DNSROot
    [string] $NetBiosDOM   = (Get-ADDomain).NetBiosName
    [string] $dirout       = "\\$SRVFICHEROS\COMUSER\GRUPOS\$carpeta"
    [string] $carpeta      = "$NetBiosDOM-$carpeta"
    [string] $ou           = (Get-addomain).UsersContainer

Import-Module ActiveDirectory

mkdir $dirout

$grupoGA = "_GAR-$carpeta-R"
$grupoLA = "_LAR-$carpeta-R"
$grupoGP = "_GAR-$carpeta-RW"
$grupoLP = "_LAR-$carpeta-RW"
New-ADGroup -Name $grupoGA -SamAccountName $grupoGA -GroupCategory Security -GroupScope Global -Path $ou -PassThru
New-ADGroup -Name $grupoGP -SamAccountName $grupoGP -GroupCategory Security -GroupScope Global -Path $ou -PassThru
New-ADGroup -Name $grupoLA -SamAccountName $grupoLA -GroupCategory Security -GroupScope DomainLocal -Path $ou -PassThru
New-ADGroup -Name $grupoLP -SamAccountName $grupoLP -GroupCategory Security -GroupScope DomainLocal -Path $ou -PassThru

Add-ADGroupMember -Identity $grupoLA -Members $grupoGA -PassThru
Add-ADGroupMember -Identity $grupoLP -Members $grupoGP -PassThru

#Creación de ACL --> System y administradores del dominio (CT); _L...-R (L); _L...-RW(M)
	$acl = Get-Acl $dirout
    $acl.SetAccessRuleProtection($True, $False)
    $grupo = New-Object System.Security.Principal.NTAccount("SYSTEM")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $grupo = New-Object System.Security.Principal.NTAccount("Admins. del dominio")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $grupo = New-Object System.Security.Principal.NTAccount("$grupoLA")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $grupo = New-Object System.Security.Principal.NTAccount("$grupoLP")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"Write", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"DeleteSubdirectoriesAndFiles", "ContainerInherit, ObjectInherit", "None", "Allow")))
    Set-Acl $dirout $acl