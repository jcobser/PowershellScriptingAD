Param ([Parameter (Mandatory = $true)][String]$ComputerName,
        [Parameter (Mandatory = $true)][String]$License
      ) 

Invoke-Command -ComputerName $ComputerName -ArgumentList "$License" {
    cscript.exe c:\windows\system32\slmgr.vbs /ipk $License
    cscript.exe c:\windows\system32\slmgr.vbs /ato
}