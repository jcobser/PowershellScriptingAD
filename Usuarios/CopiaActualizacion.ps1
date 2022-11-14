[cmdletbinding()]

Param ( 
    [Parameter(Mandatory = $false)] [String] $filtro
)

$_ACT="kb4089848" # Modificar para escoger la actulizacion

If ($filtro -eq "")
{

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
       copy "\\srveeaecdw03\app$\ACTW10\1709\64-bits\$_ACT" \\$($Computer.Name)\c$\ACTW10\ -Force -Verbose -recurse
    }
}