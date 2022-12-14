#Parámetros necesarios
Param ( [Parameter(Mandatory=$true)] [String]$Logon,
		[Parameter(Mandatory=$true)] [ValidateSet('ASAR','C1','C2', `
        'CAES1','CAES2','CAES3','CIBERDEF','MTPM','PRG','TCI','TI','IMSUBO','IMC1')]  `
        [String]$Curso )

#Comprobación de que el usuario existe
$usr = Get-ADUser -Filter {
    SamAccountName -eq $Logon
}
If ($usr -eq $null) { 
    Write-Host -ForegroundColor Red "No existe el usuario con el logon $logon"
}
else
{
    #Eliminación de los grupos del usuario
    Write-Host -ForegroundColor Blue "Eliminación de los grupos del usuario $Logon"
    $grupos=(GET-ADUSER -Identity $Logon -Properties MemberOf | Select-Object MemberOf).MemberOf 
    Foreach ($grupo in $grupos)
    {
        Write-Host "Eliminando el grupo $grupo"
        Remove-ADGroupMember $grupo -Member $Logon -Confirm:$false
    }
    #Movimiento del usuario
    Get-aduser $Logon | Move-ADObject -TargetPath "OU=CURSO-$Curso,OU=USUARIOS,DC=EEAE,DC=LOCAL"
   
        #Agregación del grupo para el acceso a las unidades del servidor de ficheros.
        Get-ADGroup _GAR-EEAE-ALUMNOS-SRVEEAECDW01 | Add-ADGroupMember -Members $Logon
    
        #Agregación de las asignaturas del curso.
        #Se supone que todos los grupos globales de alumnos 
        #que están en la OU del curso.
    Get-ADGroup -Filter "Name -like '_GAR-EEAE-*$Curso*-ALUMNOS'" | Add-ADGroupMember -Members $Logon
		Write-Host -ForegroundColor Yellow "Se ha agregado a los grupos del curso $Curso"    
    
    #Movimiento de la carpeta personal.
    Write-Host -ForegroundColor Blue "Movimiento de la carpeta personal de $Logon"
    $srvarch = 'srveeaecdw03'
    $dir = "\\$srvarch\usuarios\$Curso"
    Move-Item -Path (Get-ADUser -Identity $Logon -Properties HomeDirectory | `
        Select-Object HomeDirectory).HomeDirectory `
        -Destination "$dir"

    #Modificación del perfil del alumno.
    Write-Host -ForegroundColor Blue "Modificación del perfil del usuario $Logon"
    Get-ADUser -Identity $Logon -Properties HomeDirectory | Set-Aduser -HomeDirectory "$dir\$Logon"
    Get-ADUser -Identity $Logon -Properties Description | Set-Aduser -Description  "$Curso - Alumno"
    Write-Host -ForegroundColor Yellow "Tarea completa para el usuario $Logon"
}