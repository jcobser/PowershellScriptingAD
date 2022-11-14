$usuarios = Get-ADGroupMember _gar-eeae-cisco-profesores

Foreach ($u in $usuarios){
    $dir =  "G:\AULA_CISCO\PRIVATE_PROFESORES\" + $u.SamAccountName

    mkdir $dir

    $acl = Get-Acl $dir
    $acl.SetAccessRuleProtection($True, $False)

    $grupo = New-Object System.Security.Principal.NTAccount($u.SamAccountName)
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
    Set-Acl $dir $acl

#    $Private_home = "\\srvciscoaiw01\ProfesoresCISCO\" + $u.SamAccountName
#    Set-ADuser $u -HomeDirectory $Private_home


}
