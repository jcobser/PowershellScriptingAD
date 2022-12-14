Param ( [Parameter(Mandatory=$true)] [String]$Nombre, 
        [Parameter(Mandatory=$true)] [String]$Apellidos, 
        [Parameter(Mandatory=$true)] [String]$Logon,
		[Parameter(Mandatory=$true)] [ValidateSet('ASAR','C1','C2', `
        'CAES1-CSS','CAES2-CSS','CAES3-CSS','CIBERDEF','MTPM','PRG','TCI','TI','IMSUBO','IMC1','ECSTS','TDA', 'CNTDIG')]  `
        [String]$Curso, `
        [Parameter(Mandatory=$false)] [String]$fecha_fin )


#Importación del Módulo de Active Directory
Import-Module Activedirectory

#Variables necesarias para el script
$Logon = $Logon.ToLower().Trim()
$srvarch = 'srveeaecdw03'
$dir = "\\$srvarch\usuarios\$Curso\$Logon"
$domain = Get-ADDomain
$domain = $domain.DNSRoot

$Nombre = (Get-Culture).TextInfo.ToTitleCase($Nombre.ToLower().trim())
$Apellidos= (Get-Culture).TextInfo.ToTitleCase($Apellidos.ToLower().trim())
$Logon = $Logon.ToLower().trim()

#Comprobación de que el usuario no exista
$usr = Get-ADUser -Filter {
    SamAccountName -eq $Logon -or Name -eq "$Nombre $Apellidos"
}
If ($usr -ne $null) { 
    Write-Host -ForegroundColor Red "Existe un usuario $Nombre $Apellidos o Logon $Logon"
}
Else
{
    #Creación del nuevo usuario en caso de que no exista
    Write-Host -ForegroundColor Yellow "Creando a $Nombre $Apellidos"
    New-ADUser -Name "$Nombre $Apellidos" -DisplayName "$Nombre $Apellidos" -GivenName $Nombre -Surname $Apellidos -SamAccountName $Logon -UserPrincipalName $Logon@$domain -Path "OU=CURSO-$Curso,OU=USUARIOS,DC=EEAE,DC=LOCAL" -Description "$Curso - Alumno" -AccountPassword (Convertto-SecureString -AsPlainText "Minisdef01" -Force) -ChangePasswordAtLogon $true -HomeDirectory $dir -HomeDrive P -Enabled $true # -AccountExpirationDate $fecha_fin `
    
 
    #Creación de la carpeta personal
    mkdir $dir

    #Permisos especiales para la carpeta personal
    $acl = Get-Acl $dir
    $acl.SetAccessRuleProtection($True, $True)

    $grupo = New-Object System.Security.Principal.NTAccount("$Logon")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))

    Set-Acl $dir $acl

    #Agregación del usuario al grupo de los alumnos
    Add-ADGRoupMember -Identity _GAR-EEAE-ALUMNOS-SRVEEAECDW01 -Members (get-ADUser $Logon)
	
	#Agregación del usuario a las asignaturas de su curso si esta definido
	If ($Curso -ne $null) {
	Get-ADGroup -Filter "Name -like '_GAR-EEAE*-$Curso-*ALUMNOS'"  | Add-ADGroupMember -Members $Logon
		Write-Host -ForegroundColor Yellow "Se ha agregado a los grupos del curso $Curso"
	}
}



