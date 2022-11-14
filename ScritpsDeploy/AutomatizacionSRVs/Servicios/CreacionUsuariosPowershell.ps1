<#

Les dejo este script para que no tengan problemas a la hora de 
copiar y pegar desde el pdf

Deben cambiar la cadena de caracteres <DOMINIO> 
por el nombre que le hayan puesto a su dominio

El símbolo ` está seguido de un [Enter] para poder romper la sentencia en varias líneas 
y hacer que quede más vistoso el script. Este símbolo es el acento que está al lado de la [P]

MARQUE LAS PARTES QUE LE INDICA EL MANUAL DEL LABORATORIO Y
 EJECÚTELAS CON [F8] Ejecutar la seleccion

#>


New-ADUser -DisplayName "Alumno Microsoft PowerShell" `
-GivenName "Alumno" `
-Surname "Microsoft PowerShell" `
-Name "Alumno Microsoft PowerShell" `
-SamAccountName "AMicroPower" `
-UserPrincipalName:"AMicroPower@<DOMINIO>.LOCAL" `
-ChangePasswordAtLogon $false `
-PasswordNeverExpires $true `
-AccountPassword (ConvertTo-SecureString -AsPlainText -String "UsrP@55w0rd" -Force) `
-Enabled $true


New-ADGroup -Name "_GAR-<DOMINIO>-POWERSHELL" -SamAccountName "_GAR-<DOMINIO>-POWERSHELL" -GroupCategory Security -GroupScope Global -DisplayName "_GAR-<DOMINIO>-POWERSHELL"
New-ADGroup -Name "_LAR-<DOMINIO>-POWERSHELL" -SamAccountName "_LAR-<DOMINIO>-POWERSHELL" -GroupCategory Security -GroupScope DomainLocal -DisplayName "_LAR-<DOMINIO>-POWERSHELL"

Add-ADGroupMember -Identity _LAR-<DOMINIO>-POWERSHELL -Members _GAR-<DOMINIO>-POWERSHELL
Add-ADGroupMember -Identity _GAR-<DOMINIO>-POWERSHELL -Members Amicropower


Import-Csv .\UsuariosDominio.csv | ForEach-Object {.\CreacionUsuario.ps1 -Nombre $_.Nombre -Apellido1 $_.Apellido1 -Apellido2 $_.Apellido2 -Logon $_.Login}