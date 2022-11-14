[cmdletbinding()]

Param ( 
    [Parameter(Mandatory = $false)] [String] $filtro,
    [Parameter(Mandatory = $true)] [String] $KB,
    [Parameter(Mandatory = $true)] [String] $VersionW10
)

$_ACT=  $KB 
$_SRV_PATH ="\\srveeaecdw03\app$\ACTW10\$Version\64-bits"

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
       Write-Host $Computer.Name
       xcopy "$_SRV_PATH\$_ACT\*" "\\$($Computer.Name)\c$\ACTW10\$_ACT\" /c /s /e /r /h /d /y /x
       Write-Host "--------------------------"
    }
    else {
        echo "El equipo $($Computer.Name) no está encendido o no responde al ping"
    }
}