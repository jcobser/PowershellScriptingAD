
Param ( 
    [Parameter(Mandatory = $false)] [String] $filtro
)
If ($filtro -eq "")
{
    #Si no se encuentra el parámetro -Aula se entiende que es a todos los equipos encendidos
    $filtro = "*"

}

Import-Module ActiveDirectory

$computers =Get-ADComputer -Filter {Name -like $filtro} | sort-object
foreach($Computer in $Computers) 
{
	$status = (get-wmiobject -Query "SELECT StatusCode FROM Win32_PingStatus WHERE Address='$($Computer.Name)'").StatusCode
    if ($status -eq '0')
    {
		$serial = Get-WmiObject -ComputerName $Computer.Name -Class win32_OperatingSystem | Select-Object -ExpandProperty TotalVisibleMemorySize
		write-host "$($Computer.Name)    $($serial)"
	#	ft $($Computer.Name) $serial -Autosize
	}
	else
	{
		echo "El equipo $($Computer.Name) no está encendido o no responde al ping"
	}
}