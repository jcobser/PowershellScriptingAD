Param ( [Parameter(Mandatory = $true)] [String] $equipo,
    [Parameter(Mandatory = $true)] [String] $passwd

 )
$LocalAdmin = Get-WmiObject -Computer $equipo -Class Win32_Account | Where-Object {$_.SID -like '*-500' }

$Admin = $LocalAdmin.Name
$user = [ADSI]"WinNT://$equipo/$Admin, user"

echo "Cambiando la contraseña a $($user.Name) en $equipo"
$user.PsBase.invoke("SetPassword", "$passwd")
$user.psbase.InvokeSet("AccountDisabled", $false) 
$user.SetInfo()