$SRVFICHEROS   = hostname
$users = Get-ADUser -Filter * -SearchBase (Get-ADDomain).UsersContainer
foreach ($u in $users){
    $login = $u.SamAccountName
    $carpeta =  "\\$SRVFICHEROS\USUARIOS\$login"
    
    # Creación y asignación de permisos de la carpeta
    mkdir $carpeta
    $acl = Get-Acl $carpeta
    $acl.SetAccessRuleProtection($True, $False)
    $grupo = New-Object System.Security.Principal.NTAccount("$login")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
    Set-Acl $carpeta $acl

    #Configuración del perfil del usuario
    Set-ADUser $login -HomeDirectory $carpeta -HomeDrive "P:\"
}