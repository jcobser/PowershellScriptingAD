Param (
    [Parameter(Mandatory=$true)][String]$usuario
)
Import-Module ActiveDirectory
dsquery user -samid $($usuario) | dsmod user -pwd Minisdef01 -mustchpwd yes
write-host "cambiada la contraseña a $usuario"
