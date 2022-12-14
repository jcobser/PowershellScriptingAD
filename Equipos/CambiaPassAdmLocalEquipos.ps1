Param ( 
    [Parameter(Mandatory = $true)] [String] $passwd,
    [Parameter(Mandatory = $false)] [ValidateSet('MM1','MM2','MM3','MM4','CISCO','ARIETE-2')] [String]$Aula
)

#Creación del filtro de equipos a los que se les va a cambiar la clave.
If ($Aula -eq "")
{
    #Si no se encuentra el parámetro -Aula se entiende que es a todos los equipos encendidos
    $filtro = "Name -like 'ZFNEEAE*' -or Name -like 'CISCO*'"
	$searchbase = "DC=EEAE,DC=LOCAL"
}
Else
{
	#Si se encuentra el parámetro -Aula se crea el filtro para el aula especificada
    Switch ($Aula)
    {
        MM1 { $filtro = "*"
			$searchbase = "OU=MM1-W10,OU=EQUIPOS-W10,DC=EEAE,DC=LOCAL"}
        MM2 { $filtro = "*" 
			$searchbase = "OU=MM2-W10,OU=EQUIPOS-W10,DC=EEAE,DC=LOCAL"}
        MM3 { $filtro = "*" 
			$searchbase = "OU=MM3-W10,OU=EQUIPOS-W10,DC=EEAE,DC=LOCAL"}
        MM4 { $filtro = "*" 
			$searchbase = "OU=MM4-W10,OU=EQUIPOS-W10,DC=EEAE,DC=LOCAL"}
    ARIETE-2 { $filtro = "*"
            $searchbase = "OU=ARIETE-2,OU=EQUIPOS,DC=EEAE,DC=LOCAL"}
        CISCO { $filtro = "*" 
			$searchbase = "OU=CISCO-EQUIPOS-W10,DC=EEAE,DC=LOCAL"}
    }

}

Import-Module ActiveDirectory

$equipos = Get-ADComputer -Filter $filtro -SearchBase $searchbase | Sort-Object Name
foreach ($equipo in $equipos) {
    $status = (get-wmiobject -Query "SELECT StatusCode FROM Win32_PingStatus WHERE Address='$($equipo.Name)'").StatusCode
    if ($status -eq '0')
    {
        $LocalAdmin = Get-WmiObject -Computer $($equipo.Name) -Class Win32_Account | Where-Object {$_.SID -like '*-500' }
        $Admin = $LocalAdmin.Name
        $user = [ADSI]"WinNT://$($equipo.Name)/$Admin, user"
        echo "Cambiando la contraseña a $($user.Name) en $($equipo.Name)"
        $user.PsBase.invoke("SetPassword", "$passwd")
        $user.psbase.InvokeSet("AccountDisabled", $false) 
        $user.SetInfo()
    }
    else
    {
        echo "El equipo $($equipo.Name) no está encendido o no responde al ping"
    }
  }  
