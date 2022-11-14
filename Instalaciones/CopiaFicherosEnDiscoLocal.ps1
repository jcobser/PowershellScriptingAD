$eqs = @()
(get-adcomputer -filter "Name -like 'zfneeae04*'") | Foreach-object {
    If (Test-Connection -Count 1 -ComputerName $_.Name -ErrorAction SilentlyContinue){
        $eqs += $_.Name
    }
}
    
$eqs

foreach($eq in $eqs){
    $DIR = "\\$eq\c$\Program Files\Software_eeae\ADM-REDES\maquinas_ova\"
    New-Item $DIR -ItemType DIRECTORY -ErrorAction SilentlyContinue | OUT-NULL
    #Copy-Item 'E:\Maquinas Virtuales\Templates-VirtualBox\FreeNAS2020\FreeNAS.ova' $DIR -Force -Container -Verbose
    Copy-Item 'E:\Maquinas Virtuales\Templates-VirtualBox\OpenBSDRouter\OpenBSD-OSPF-IIS-SSH.ova'     $DIR -Force -Container -Verbose
    Copy-Item 'E:\Maquinas Virtuales\Templates-VirtualBox\W10-20H2\W10-20H2.ova'     $DIR -Force -Container -Verbose
    Copy-Item 'E:\Maquinas Virtuales\Templates-VirtualBox\W2k16Core\W2k16Core.ova'   $DIR -Force -Container -Verbose
    Copy-Item 'E:\Maquinas Virtuales\Templates-VirtualBox\W2K16STD\W2K16SRV-STD.ova' $DIR -Force -Container -Verbose
}