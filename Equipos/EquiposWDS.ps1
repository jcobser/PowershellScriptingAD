Param (
	[Parameter(Mandatory=$true)] [String] $Csv
)
#El fichero csv debe tener como campos ip, mac, equipo, aula

If (Test-Path -Path $Csv)
{
	Import-Csv $Csv | foreach { wdsutil /Add-Device /Device:$($_.equipo) /ID:$($_.mac) /OU:"$($_.aula),OU=EQUIPOS-w10,DC=EEAE,DC=LOCAL"}
}
Else
{
	Write-Host -ForegroundColor Red "No se encuentra el fichero csv indicado"
}