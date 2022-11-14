Param ([Parameter(Mandatory = $true)] [String] $ComputerName) 
Ipmo ActiveDirectory

$Equipos= Get-ADComputer -SearchBase "OU=EQUIPOS-W10,DC=EEAE,DC=LOCAL" -SearchScope Subtree -Filter {Name -like $ComputerName} | Select -Property Name

Foreach ($equ in $Equipos) {
    $comp = $equ.Name
    write-host $comp
    $conn=[ADSI]”WinNT://$comp” 
    $user = $conn.Create(“user”,”Ciber2016”) 
    $user.SetPassword(“Minisdef01”)
    $user.SetInfo()
    

    $group = [ADSI]"WinNT://$Comp/Usuarios,group" 
    $group.add("WinNT://$Comp/Ciber2016,group")

}