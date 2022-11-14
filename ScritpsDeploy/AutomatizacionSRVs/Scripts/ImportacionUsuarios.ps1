###################################################
####
#### Autor: Juan Marcos Cobelo Serantes
####
####
#### Configuración de los primeros pasos para un 
#### CDW01
####
#### Importacion de usuarios desde .csv
####
#### Copiar el Script a Documentos\Scripts\
####
###################################################

[string] $DirCommand = Split-Path -Parent $PSCommandPath

## Funcion para crear un usuario
Function CreaUsuario {
Param ([Parameter(Mandatory=$true)] [string]$Nombre,
    [Parameter(Mandatory=$true)] [string]$Apellido1,
    [Parameter(Mandatory=$true)] [string]$Apellido2,
    [Parameter(Mandatory=$true)] [string]$Login)
    $Dominio=(Get-ADDomain).DNSRoot
    New-ADUser -DisplayName "$Nombre $Apellido1 $Apellido2" `
    -GivenName "$Nombre" `
    -Surname "$Apellidos" `
    -Name "$Nombre $Apellido1 $Apellido2" `
    -SamAccountName "$Login" `
    -UserPrincipalName:"$Login@$Dominio" `
    -ChangePasswordAtLogon $false `
    -PasswordNeverExpires $true `
    -AccountPassword (ConvertTo-SecureString `
        -AsPlainText -String "Minisdef01" -Force) `
    -Enabled $true
}



Import-Csv ($DirCommand + "\usuarios\UsuariosDominio.csv") | `    ForEach-Object { Creausuario -Nombre $_.Nombre -Apellido1 $_.Apellido1 -Apellido2 $_.Apellido2 -Login $_.Login }


New-ADUser -DisplayName "Alumno Microsoft PowerShell" `
-GivenName "Alumno" `
-Surname "Microsoft PowerShell" `
-Name "Alumno Microsoft PowerShell" `
-SamAccountName "AMicroPower" `
-UserPrincipalName:"AMicroPower@PROFE.LOCAL" `
-ChangePasswordAtLogon $false `
-PasswordNeverExpires $true `
-AccountPassword (ConvertTo-SecureString `
    -AsPlainText -String "Minisdef01" -Force) `
-Enabled $true

