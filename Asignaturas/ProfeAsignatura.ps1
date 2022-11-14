Param (
    [Parameter(Mandatory=$true)][String]$filtro ,
	[Parameter(Mandatory=$true)][String]$profe
)
Import-Module ActiveDirectory
Get-ADGroup -Filter "Name -like '_GAR*$filtro*-PROFESOR'" | Add-ADGroupMember -Members $profe

