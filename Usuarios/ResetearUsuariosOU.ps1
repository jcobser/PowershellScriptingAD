#Modifica los usuarios de una Unidad Organizativa para el reseteo de los usuarios
Param ( 
	[Parameter(Mandatory=$true)] [String]$OU 
)
Get-ADUser -Filter * -SearchBase "OU=$OU,DC=EEAE,DC=LOCAL" | Foreach-Object { dsquery user -samid $_.SamAccountName | dsmod user -pwd Minisdef01 -Mustchpwd yes}