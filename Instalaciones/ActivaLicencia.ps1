Param ([Parameter (Mandatory = $true)][String]$ComputerName,
        [Parameter (Mandatory = $true)][String]$License
      ) 

Invoke-Command -ComputerName zfneeae0200 -ArgumentList "$License" {
    cscript.exe c:\windows\system32\slmgr.vbs /ipk $args[0]
    cscript.exe c:\windows\system32\slmgr.vbs /ato
}