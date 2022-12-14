#Parámetros necesarios
Param ( [Parameter(Mandatory=$true)] [ValidateSet('ASAR','C1','C2', `
        'CAES1-CSS','CAES2-CSS','CAES3-CSS','CIBERDEF','MTPM','PRG','TCI','TI', 'ZZ-TEMPORAL','IMSUBO','IMC1')]  `
        [String]$CursoOrigen,
        [Parameter(Mandatory=$true)] [ValidateSet('ASAR','C1','C2', `
        'CAES1-CSS','CAES2-CSS','CAES3-CSS','CIBERDEF','MTPM','PRG','TCI','TI', 'ZZ-TEMPORAL','IMSUBO','IMC1')]  `
        [String]$CursoDestino)

Ipmo ActiveDirectory

#Comprobación de que el curso de destino no tiene Usuarios.
$usrs = Get-ADUser -Filter * -SearchBase "ou=CURSO-$CursoDestino,ou=usuarios,dc=eeae,dc=local"
If ($usrs) {
    Write-Host -ForegroundColor Red "Existen usuarios pertenencientes al curso de destino $CursoDestino. BÓRRELOS o MÍGRELOS"
    Exit
}
#Comprobación de que existen usuarios en el Curso de Origen
$usrs = Get-ADUser -Filter * -SearchBase "ou=CURSO-$CursoOrigen,ou=usuarios,dc=eeae,dc=local"
If ($usrs -eq $null) { 
    Write-Host -ForegroundColor Red "No existen usuarios en el curso de origen $CursoOrigen"
    Exit
}
else
{
    Foreach ($usr in $usrs) {
        #Eliminación de los grupos del usuario
        $Logon = $usr.SamAccountName
        Write-Host "Eliminación de los grupos del usuario $Logon"
        $grupos=(GET-ADUSER -Identity $Logon -Properties MemberOf | Select-Object MemberOf).MemberOf 
        Foreach ($grupo in $grupos)
            {
            Write-Host "Eliminando a $Logon del grupo $grupo"
            Remove-ADGroupMember $grupo -Member $Logon -Confirm:$false
        }
        #Movimiento del usuario
        Get-aduser $Logon | Move-ADObject -TargetPath "OU=CURSO-$CursoDestino,OU=USUARIOS,DC=EEAE,DC=LOCAL"

        #Agregación del grupo para el acceso a las unidades del servidor de ficheros.
        Get-ADGroup _GAR-EEAE-ALUMNOS-SRVEEAECDW01 | Add-ADGroupMember -Members $Logon
        
        #Agregación de las asignaturas del curso.
        #Se supone que todos los grupos globales de alumnos 
        #que están en la OU del curso.
        Get-ADGroup -Filter "Name -like '_GAR-EEAE-*$CursoDestino*-ALUMNOS'" | Add-ADGroupMember -Members $Logon
		Write-Host -ForegroundColor Yellow "Se ha agregado a los grupos del curso $CursoDestino"    
    
        #Movimiento de la carpeta personal.
        Write-Host "Movimiento de la carpeta personal de $Logon"
        $srvarch = 'srveeaecdw03'
        $dir = "\\$srvarch\usuarios\$CursoDestino"
        Move-Item -Path (Get-ADUser -Identity $Logon -Properties HomeDirectory | `
            Select-Object HomeDirectory).HomeDirectory `
            -Destination "$dir"

        #Modificación del perfil del alumno.
        Write-Host "Modificación del perfil del usuario $Logon"
        Get-ADUser -Identity $Logon -Properties HomeDirectory | Set-Aduser -HomeDirectory "$dir\$Logon"
        Get-ADUser -Identity $Logon -Properties Description | Set-Aduser -Description  "$Curso - Alumno"
        Write-Host -ForegroundColor Yellow "Tarea completa para el usuario $Logon"
    }
}