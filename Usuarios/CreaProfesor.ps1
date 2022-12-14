Param ( 
    #Nombre del profesor
    [Parameter(Mandatory=$true)] [String]$Nombre, 
    #Apellidos del profesor
    [Parameter(Mandatory=$true)] [String]$Apellidos,
    #Departamento al que pertenence
    [Parameter(Mandatory=$true)] [ValidateSet('PRG','TI','SONAR')][String]$Depto,
    #Login que se le da para iniciar sesión - Poner el mismo que en DICODEF
    [Parameter(Mandatory=$true)] [String]$logon 
    )

#Importación del Módulo de Active Directory
Import-Module Activedirectory

#Variables necesarias para el script
$Nombre = (Get-Culture).TextInfo.ToTitleCase($Nombre.ToLower())
$Apellidos= (Get-Culture).TextInfo.ToTitleCase($Apellidos.ToLower())
$Logon = $Logon.ToLower()

$srvarch = 'srveeaecdw03'
$dir = "\\$srvarch\profesores\$logon"
$domain = Get-ADDomain
$domain = $domain.DNSRoot
switch ($depto)
{
	PRG { 
		$ou = "OU=PROFE-PRG,OU=USUARIOS,DC=EEAE,DC=LOCAL"
		$desc = "PROFESOR DEPARTAMENTO PRG"
		}
	TI	{ 
		$ou = "OU=PROFE-TI,OU=USUARIOS,DC=EEAE,DC=LOCAL" 
		$desc = "PROFESOR DEPARTAMENTO TI"
		}
    SONAR {
        $ou = "OU=PROFE-BUST,OU=USUARIOS,DC=EEAE,DC=LOCAL" 
		$desc = "PROFESOR DEPARTAMENTO SONAR"
		
        }
}

#Comprobación de que el usuario no exista
$usr = Get-ADUser -Filter {
    SamAccountName -eq $logon -or Name -eq "$Nombre $Apellidos"
}
If ($usr -ne $null) { 
    Write-Host -ForegroundColor Red "Existe un usuario $Nombre $Apellidos o logon $logon"
}
Else
{
    #Creación del nuevo usuario en caso de que no exista
    Write-Host -ForegroundColor green "Creando a $Nombre $Apellidos"
    New-ADUser -Name "$Nombre $Apellidos" -DisplayName "$Nombre $Apellidos" `
    -GivenName $Nombre -Surname $Apellidos -SamAccountName $logon `
    -UserPrincipalName $logon@$domain `
    -Description $desc `
    -Path $ou `
    -AccountPassword (Convertto-SecureString -AsPlainText Minisdef01 -Force) `
    -ChangePasswordAtLogon $true `
    -HomeDirectory $dir -HomeDrive P `
    -Enabled $true

    #Creación de la carpeta personal
    mkdir $dir

    #Permisos especiales para la carpeta personal
    $acl = Get-Acl $dir
    $acl.SetAccessRuleProtection($True, $True)

    $grupo = New-Object System.Security.Principal.NTAccount("$logon")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))

    Set-Acl $dir $acl

    #Agregación del usuario al grupo de los PROFESORES según corresponda
    switch ($depto)
    {
	PRG { 
		Add-ADGroupMember "_GAR-EEAE-PROFESORES-PRG-SRVEEAECDW01" -Members $logon
		}
	TI	{ 
		Add-ADGroupMember "_GAR-EEAE-PROFESORES-TI-SRVEEAECDW01" -Members $logon
		}
    SONAR {
        Add-ADGroupMember "_GAR-EEAE-PROFESORES-SONAR-SRVEEAECDW01" -Members $logon
        }
    }
    # Agregación necesaria para proceder a Veyon Master
    Add-ADGroupMember "_LAR-EEAE-VEYON-MASTERS" -Members $logon
}