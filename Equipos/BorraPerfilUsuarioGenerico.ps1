Param ([Parameter(Mandatory = $true)] [String] $ComputerName) 
ipmo ActiveDirectory
$equipos = Get-ADComputer -SearchBase "OU=W10,OU=EQUIPOS,DC=EEAE,DC=LOCAL" -SearchScope Subtree -Filter {Name -like $ComputerName} | Select -Property Name

$sid = Get-ADuser usuario | select SID

Foreach ($equipo in $equipos) {
    	$strSid = $sid.SID
	$equ = $equipo.Name 
	write-host $equ
    	(Get-WmiObject Win32_UserProfile -ComputerName $equ -Filter "Special=False and Loaded=False and SID=""$strSid""").delete()
	write-host "Se ha eliminado el perfil $strSid de $equ"
    
}
