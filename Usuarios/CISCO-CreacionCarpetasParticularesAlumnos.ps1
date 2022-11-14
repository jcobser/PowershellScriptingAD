$usuarios = Get-Aduser -filter "SamAccountName -like 'CISCO0*'" 

Foreach ($u in $usuarios){
    $dir =  "G:\AULA_CISCO\PRIVATE_ALUMNOS\" + $u.SamAccountName

    mkdir $dir

    $acl = Get-Acl $dir
    $acl.SetAccessRuleProtection($True, $False)

    $grupo = New-Object System.Security.Principal.NTAccount($u.SamAccountName)
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
    $grupo = New-Object System.Security.Principal.NTAccount("_LAR-EEAE-CISCO-PROFESORES")
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($grupo,"ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")))
    Set-Acl $dir $acl

    $Private_home = "\\srvciscoaiw01\AlumnosCISCO\" + $u.SamAccountName
    Set-ADuser $u -HomeDirectory $Private_home


}
