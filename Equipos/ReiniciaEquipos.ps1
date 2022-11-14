
Param ( 
    [Parameter(Mandatory = $false)] [String] $filtro
)
If ($filtro -eq "")
{
    #Si no se encuentra el par�metro -Aula se entiende que es a todos los equipos encendidos
    $filtro = "*"

}

Import-Module ActiveDirectory

$computers =Get-ADComputer -Filter {Name -like $filtro} | sort-object
foreach($Computer in $Computers) 
{
	$status = (get-wmiobject -Query "SELECT StatusCode FROM Win32_PingStatus WHERE Address='$($Computer.Name)'").StatusCode
    if ($status -eq '0')
    {
		Write-host "shutdown -r -m \\$($Computer.Name) -t 0"
		shutdown -r -m \\$($Computer.Name) -t 0
	}
	else
	{
		echo "El equipo $($Computer.Name) no est� encendido o no responde al ping"
	}
}