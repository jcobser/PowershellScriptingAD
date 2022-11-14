 #############################################################################
# Fecha: 29/04/2022
#
# Autor: Juan Marcos Cobelo Serantes
#
#
# Instalación del software de Veyon en los equipos del dominio
#
# ADVERTENCIA: LA MODIFICACIÓN DE ESTE SCRIPT PUEDE CAUSAR FALLOS EN EL 
# SISTEMA.
#############################################################################

Param([Parameter (Mandatory =  $false)] [String[]] $ComputerName = ($env:COMPUTERNAME) ,
    [Parameter(Mandatory = $false)] [switch] $Desinstala,
    [Parameter(Mandatory = $false)] [switch] $Install,
	[Parameter(Mandatory = $false)] [switch] $TodasOU
)

$RutaServidor = "\\srveeaecdw03\App$\Veyon"
$RutaEquipoRemoto = "C:\Program Files\software_eeae\Install"
#$instalable = "veyon-4.5.1.0-win64-setup.exe"
$instalable = "veyon-4.7.3.0-win64-setup.exe"
if ($TodasOU){
	$config = "config-cliente_TodasOU.json"
}else {
	$config = "config-cliente_SoloOU.json"
}
$destino = "\\" + $ComputerName + "\" + $RutaEquipoRemoto.Replace(":", "$")
#Funcion para testear la conexión con el equipo remoto
function TC ($equipo){
    If (Test-Connection $equipo -Count 1 -ErrorAction SilentlyContinue) {return $true}
    else {return $false}
}

#Funcion para copiar el software a local
function copiasoftware($equipo){
    $fuentes = @("$RutaServidor\$instalable","$RutaServidor\$config")
    $destino = "\\" + $equipo + "\" + $RutaEquipoRemoto.Replace(":", "$")
    foreach ($fuente in $fuentes){
        try {
            If (-not (Test-Path $destino)) {
                New-Item -Path $destino -ItemType directory -Force | Out-Null
            }
            write-Host "FUENTE: $fuente"
            write-Host "DESTINO: $destino"
 
            Copy-Item "$fuente" "$destino" -Force -Recurse -Verbose

        } catch {
            Write-Host "No se pudo copiar el software a $ComputerName"
            return $false
        }
    }
}

#Funcion para instalar el software
function instala($equipo){
    $comando = "$RutaEquipoRemoto\$instalable"
    Write-host $equipo
    if ($equipo.EndsWith('00')) {  #Puesto del profesor acaba en 00
        $argumentos = @("/S", "/ApplyConfig=$RutaEquipoRemoto\$config")
        $confcliente = $true
    }
    else { #Puestos de alumnos
        
        $argumentos =@("/S","/NoMaster", "/ApplyConfig=$RutaEquipoRemoto\$config")
        $confcliente = $true
        Write-Host $argumentos
    }

    try {
        Invoke-command -ComputerName $equipo -ArgumentList $comando, $argumentos { 
            $ejec = $args[0]
            $opc = ""
            Foreach ($op in $args[1]) {
                $opc += "$op "
            }

            Start-Process -FilePath $ejec -ArgumentList $opc -Wait
            
        }
        $resInst = $true
        
    } catch {
        write-host "No se pudo instalar el software en el equipo $equipo"
    }
    Remove-Item $Destino\$config
}

###PROCESO
## Instalación del software en los equipos.
If ($Install) {
    Foreach ($C in $ComputerName){ 

        if (TC $C){

                copiasoftware $C
                instala $C
        }

    }
}
