Param ( [Parameter(Mandatory=$false)] [String]$usuario,
		[Parameter(Mandatory=$false)] [ValidateSet('ASAR','C1','C2', `
        'CAES1-CSS','CAES2-CSS','CAES3-CSS','CIBERDEF','MTPM','PRG','TCI','TI', 'NCAGS','IMSUBO','IMC1','ECSTS')]  `
        [String]$curso  )
        # $Adusuarios = $null
        
        If ((!$usuario) -and (!$curso)) {
            Write-Host "Se necesita la opción curso o la opción usuario" -ForegroundColor Yellow
            break;
        }
        If (($usuario) -and ($curso)) {
            Write-Host "La opción usuario no es compatible con la opción curso" -ForegroundColor Yellow
            break;
        }
        If ($curso) {
            Ipmo ActiveDirectory
            $ADusuarios = Get-ADuser -Properties HomeDirectory -SearchBase "ou=CURSO-$curso,ou=USUARIOS,dc=eeae,dc=local" -Filter *
            $confirm = $false
        
        }
        If ($usuario) {
             
            Ipmo ActiveDirectory
            $ADusuarios = Get-Aduser -Property HomeDirectory -Filter "SamAccountName -like '$usuario' -or DisplayName -like '*$usuario*'"
            $confirm = $true
        }
        foreach ($ADusuario in $ADusuarios) {
            # Remove-Item $ADusuario.HomeDirectory
            $user = Get-ADUser $ADusuario -Properties HomeDirectory
            If ($user.HomeDirectory) {

                Remove-Item -Recurse $user.HomeDirectory -Confirm:$confirm -Force
            }
            Remove-ADUser $ADusuario -Confirm:$confirm
            
        }
        