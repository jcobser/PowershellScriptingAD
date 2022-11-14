Param (
    [Parameter(Mandatory=$true)][String]$filtro ,
	[Parameter(Mandatory=$true)][String]$Alumno
)
Import-Module ActiveDirectory
Get-ADGroup -Filter "Name -like '_GAR*$filtro*-ALUMNOS'" | Add-ADGroupMember -Members $Alumno