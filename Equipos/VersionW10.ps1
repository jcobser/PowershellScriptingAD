Param ([Parameter(Mandatory = $true)] [String] $ComputerName)

$eqs = Get-ADComputer -filter {Name -like $ComputerName} | select Name
$res=@()
Write-Host -ForegroundColor Blue "Recuperando datos..."

foreach ($eq in $eqs) {
    $status = (get-wmiobject -Query "SELECT StatusCode FROM Win32_PingStatus WHERE Address='$($eq.Name)'").StatusCode
    if ($status -eq '0'){

        $_VERSION_SO = Invoke-Command -ComputerName $($eq.Name) {
            (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\' -Name ReleaseID).ReleaseID
        }
        $resultado = New-Object -TypeName PSObject -Property @{
        	Equipo = $eq.Name;
        	Version = $_VERSION_SO
		}
        $res += $resultado
    }
    else {
        echo "El equipo $($eq.Name) no está encendido o no responde al ping"
    }
}
$res | ft Equipo, Version

