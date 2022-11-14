Param ([Parameter (Mandatory = $false, 
        ValueFromPipeline = $true)][string[]] $ComputerName = $env:COMPUTERNAME,
       [Parameter (Mandatory = $false)] [Switch] $ActivaLicencia
       )

class Equipo {
    $Nombre
    $Ipv4
    hidden $Red
    $MAC
    $Licencia
    
    hidden [IPAddress] GetSubnet() {
        $Ip = (Get-WmiObject -class "Win32_NetworkAdapterConfiguration" | Where-Object {$_.IPEnabled -match "True"}).IPAddress
        Write-Output $Ip
        $mask = (Get-WmiObject -class "Win32_NetworkAdapterConfiguration" | Where-Object {$_.IPEnabled -match "True"}).IPSubnet
        Write-Output $mask
        filter Convert-IP2Decimal
        {
            ([IPAddress][String]([IPAddress]$_)).Address
        }
        filter Convert-Decimal2IP
        {
            ([System.Net.IPAddress]$_).IPAddressToString 
        }

        [UInt32]$uIP = $Ip[0] | Convert-IP2Decimal
        [UInt32]$uMask = $mask[0] | Convert-IP2Decimal
        [UInt32]$subnet = $uIP -band $uMask
        return  $subnet
    }

    hidden [String] GetIpv4() {
        $fqdn = $this.Nombre + '.' + (Get-ADDomain).DNSRoot
        return (Get-DhcpServerv4Lease -ComputerName srveeaecdw03  -ScopeId $this.GetSubnet() | Where-Object Hostname -eq $fqdn | Sort-Object LeaseExpiryTime -Descending | Select-Object -First 1).IPAddress.IpAddressToString
    }

    hidden [String] GetMac() {
        $fqdn = $this.Nombre + '.' + (Get-ADDomain).DNSRoot
        return (Get-DhcpServerv4Lease -ComputerName srveeaecdw03  -ScopeId $this.GetSubnet() | Where-Object Hostname -eq $fqdn | Sort-Object LeaseExpiryTime -Descending | Select-Object -First 1).ClientId
    }

    hidden [String] GetLicense(){
        $res = (Get-WmiObject -ComputerName $this.Nombre -query 'SELECT OA3xOriginalProductKey FROM SoftwareLicensingService' -ErrorAction SilentlyContinue).OA3xOriginalProductKey
        if ($null -eq $res -or $res -eq '') {$res = '----'}
        return $res
    }

    Equipo($Nombre){
        $this.Nombre = $Nombre.toUpper()
        $this.Red = ($this.GetSubnet()).IpAddressToString
        $this.MAC = $this.GetMac()
        $this.Ipv4 = $this.GetIpv4()
        $this.Licencia = $this.GetLicense()
    }


}



$equipos = @()

function ActivaLicencia ($equipo) {
    if ($equipo.Licencia -ne '----') {
        Invoke-Command -ComputerName $equipo.Nombre {
            ### Comandos de poweshell para activar la licencia
            cscript.exe slmgr.vbs /ikp $equipo.Licencia
            cscript.exe slmgr.vbs /ato
        }
    }
}

if ($ComputerName.Length -eq 1) {
    Get-ADComputer -Filter "name -like '$ComputerName'" | Select-Object Name | ForEach-Object {
        $equipo =[Equipo]::new($_.Name)
        $equipos += $equipo
    }
}
else {
    foreach ($c in $ComputerName) {
        $equipo =[Equipo]::new($_.Name)
        $equipos += $equipo
    }
}
$equipos
