Param (
	[Parameter(Mandatory=$true)] [String] $Csv
)
#El fichero csv debe tener como campos ip, mac, equipo

If (Test-Path -Path $Csv)
{
	Import-Csv $Csv | foreach { netsh dhcp server 192.168.7.254 scope 192.168.0.0 add reservedip $($_.ip) $($_.mac) $($_.equipo) }
}
Else
{
	Write-Host -ForegroundColor Red "No se encuentra el fichero csv indicado"
}