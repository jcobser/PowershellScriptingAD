Param (
    [Parameter(Mandatory=$true)] [String]$carpeta,
	[Parameter(Mandatory=$true)] [String]$curso
)
Import-Module ActiveDirectory

$carpeta = "$curso-$carpeta"

mkdir \\srveeaecdw03\COMUSER\GRUPOS\EEAE-$carpeta

$grupoGA = "_GAR-EEAE-$carpeta-ALUMNOS"
$grupoLA = "_LAR-EEAE-$carpeta-ALUMNOS"
$grupoGP = "_GAR-EEAE-$carpeta-PROFESOR"
$grupoLP = "_LAR-EEAE-$carpeta-PROFESOR"
$ou= "OU=CURSO-$curso,OU=USUARIOS,DC=EEAE,DC=LOCAL"
New-ADGroup -Name $grupoGA -SamAccountName $grupoGA -GroupCategory Security -GroupScope Global -Path $ou -PassThru
New-ADGroup -Name $grupoGP -SamAccountName $grupoGP -GroupCategory Security -GroupScope Global -Path $ou -PassThru
New-ADGroup -Name $grupoLA -SamAccountName $grupoLA -GroupCategory Security -GroupScope DomainLocal -Path $ou -PassThru
New-ADGroup -Name $grupoLP -SamAccountName $grupoLP -GroupCategory Security -GroupScope DomainLocal -Path $ou -PassThru

Add-ADGroupMember -Identity $grupoLA -Members $grupoGA -PassThru
Add-ADGroupMember -Identity $grupoLP -Members $grupoGP -PassThru

#Creación de ACL --> System y administradores del dominio (CT); _L...-R (L); _L...-RW(M)
    $dirout = "\\srveeaecdw03\comuser\grupos\EEAE-$carpeta"
	$acl = Get-Acl $dirout
    $acl.SetAccessRuleProtection($True, $False)
    $grupo = New-Object System.Security.Principal.NTAccount("SYSTEM")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $grupo = New-Object System.Security.Principal.NTAccount("Admins. del dominio")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $grupo = New-Object System.Security.Principal.NTAccount("$grupoLA")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $grupo = New-Object System.Security.Principal.NTAccount("$grupoLP")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")))
    Set-Acl $dirout $acl

#Agregación de alumnos a la asignatura en caso de que existan en la OU del curso

Get-ADUser -Filter * -SearchBase "$ou" | Foreach-object {Add-ADGroupMember "$grupoGA" -Member $_.SamAccountName }