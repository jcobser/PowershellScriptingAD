<#
* **********************************
* Borra Perfiles del Curso
*
* Autor: Juan Marcos Cobelo Serantes
* Fecha: 04/06/2019
*
* **********************************

#>

Param (
    [Parameter (Mandatory = $true)][string] $Aula,
    [Parameter (Mandatory = $true)][string] $Curso
)

$_DOMINIO = (Get-ADDomain).DNSRoot
$_DOMINIO_DN = (Get-ADDomain).DistinguishedName
$_DOMINIO_Name = (Get-ADDomain).Name

$Curso = "CURSO-" + $Curso
#$Aula = "OSS-MM2"

$ArrPerfilesCurso = Get-aduser -Filter * -SearchBase "OU=$Curso,OU=USUARIOS,$_DOMINIO_DN" -Properties sid | SELECT SID 
$Computers = Get-ADComputer -filter * -SearchBase "OU=$Aula,OU=W10,OU=EQUIPOS,$_DOMINIO_DN" 

Foreach ($Computer in $Computers){
    ECHO $Computer.Name
    $ArrPerfilesEnComputer = Get-WmiObject Win32_UserProfile -ComputerName $Computer.Name -Filter 'Special=False and Loaded=False' 
   # echo $ArrPerfilesEnComputer.SID
    Foreach ($Perfil in $ArrPerfilesEnComputer){
        if ($ArrPerfilesCurso.SID -match $Perfil.SID) {
            echo "Encontrado perfil $($Perfil.SID) en $($Computer.Name)"
            try {
                $Perfil.delete()
                }
            catch
                {
                Write-Error "No se ha podido borrar el perfil $($Perfil.SID) en $($Computer.Name)"
                }
        }
    }
}
 