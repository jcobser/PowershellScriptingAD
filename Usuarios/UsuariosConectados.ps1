[cmdletbinding()]

Param ( 
    [Parameter(Mandatory = $false)] [String] $filtro
)
If ($filtro -eq "")
{
    #Si no se encuentra el parámetro -Aula se entiende que es a todos los equipos encendidos
    $filtro = "*"

}
Import-Module ActiveDirectory
$_DOM=(Get-ADDomain).NetBiosName
$Usuarios = @() 
Write-Host -ForegroundColor Blue "Recuperando datos..."
$computers =Get-ADComputer -Filter {Name -like $filtro} -SearchBase $((Get-ADDomain).ComputersContainer) | sort-object
foreach($Computer in $Computers) {
	$status = (get-wmiobject -Query "SELECT StatusCode FROM Win32_PingStatus WHERE Address='$($Computer.Name)'").StatusCode
    if ($status -eq '0'){
	$usr = (Get-WmiObject -ComputerName $Computer.Name -Class win32_ComputerSystem).UserName # | select username -ExpandProperty username
	If ($usr) {
	        $usuario = New-Object -TypeName PSObject -Property @{
        		Equipo = $Computer.Name;
        		Logon = "$usr";
			Nombre = (Get-Aduser $usr.Replace("$_DOM\","")).Name
        	}
	}
	else {
		$usuario = New-Object -TypeName PSObject -Property @{
        		Equipo = $Computer.Name;
        		Logon = "Usuario No Conectado";
			Nombre = "No-User"
        	}
	}
        $Usuarios += $usuario
   }
   else	{
		echo "El equipo $($Computer.Name) no está encendido o no responde al ping"
   }
   
}
$Usuarios | ft Equipo,Logon,Nombre -AutoSize