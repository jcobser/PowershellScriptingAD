Param ([Parameter(Mandatory = $true)] [String] $ComputerName) 

$removeProfileCmd = Get-WmiObject Win32_UserProfile -ComputerName $ComputerName -Filter 'Special=False and Loaded=False'
if (!$removeProfileCmd) {
    Write-Host "No existen perfiles en $ComputerName que se puedan borrar" -ForegroundColor Red -BackgroundColor White
} else {
	Foreach ($prof in $removeProfileCmd) {
        try {
            $UserName = $prof.LocalPath            

            
            $SID = $prof.SID            
            If((Get-ADUser -Properties SID -Filter {SID -eq $SID} -ErrorAction SilentlyContinue) -eq $null){
                $prof.delete()
                Write-Host "$UserName Borrado Correctamente en $ComputerName con SID $SID"
            }            
        } catch {            
            Write-Host "No se ha podido borrar el perfil: $UserName en $ComputerName" -ForegroundColor Red -BackgroundColor White 
        }
     }
}

