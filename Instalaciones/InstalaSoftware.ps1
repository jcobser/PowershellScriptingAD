[cmdletbinding()]

Param([Parameter (Mandatory = $false)][switch] $ListAvailables,
    [Parameter (Mandatory = $false)][string] $Software,
    [Parameter (Mandatory = $false)][switch] $SoloCopia,
    [Parameter (Mandatory = $false)][switch] $NoCheckFiles,
    [Parameter (Mandatory = $false, 
        ValueFromPipeline = $true)][string[]] $ComputerName = $env:COMPUTERNAME
)

#Definicion de variables globales
$Dir = Split-Path -Parent $PSCommandPath;

[Xml]$ficheroXml = Get-Content "$Dir\software.xml"

$ObjEnv = New-Object -TypeName psobject -Property @{
    RutaServidor = "\\" + $ficheroXml.Configuracion.env.srv + "\" + $ficheroXml.Configuracion.env.shared + "\"
    RutaLocal    = $ficheroXml.Configuracion.env.PathLocal

}
## Nos aseguramos que $ComputerName siempre apunta a alg�n lugar.
If ($ComputerName -eq $null) {
    $ComputerName = $env:COMPUTERNAME
}

### FUNCIONES
function ListAvailables () {
    $aplis = $ficheroXml.Configuracion.Aplis.Software
    $aplis | Format-Table -Property Nombre,Descripcion
}

function  CopiaSoftware ($ObjSoftware, $Equipo) {
    $fuente = $ObjEnv.RutaServidor + $ObjSoftware.carpeta + "\."
    $destino = $ObjEnv.RutaLocal + "\" + $ObjSoftware.carpeta + "\"
    If ($Equipo) {
        [string]$destino = "\\" + $Equipo + "\" + $destino.Replace(":", "$")
    } 
    write-Host "FUENTE: $fuente"
    write-Host "DESTINO: $destino"
 
    xcopy $fuente $destino /c /s /e /r /h /d /y /x

}

function InstalaSoftware ($ObjSoftware, $Equipo) {
    $ObjSoftware.carpeta = $ObjEnv.RutaLocal + "\" + $ObjSoftware.carpeta + "\"
    Write-Host "Carpeta donde se ejecuta: "  $ObjSoftware.carpeta
    #Localizacion de ejecutables
    $Ejecutables = $ficheroXml | Select-Xml -Xpath "/Configuracion/Aplis/*[@Nombre='$($ObjSoftware.Nombre)']/Ejecutable" | Select-Object -ExpandProperty "node" #---Buscar como localiza los ejecutables --#
    $Ejecutables | Format-Table
    Foreach ($Ejecutable in $Ejecutables){
        #$Ejecutable.comando = $ObjSoftware.carpeta + "\" + $Ejecutable.comando
        Write-Host "Ejectuable                "  $Ejecutable.comando
        Write-Host "Argumentos                "  $Ejecutable.argumento
    }
    If ($Equipo -eq $env:COMPUTERNAME){
        Write-host "Instalando en Equipo Local"
	Invoke-command -ArgumentList $ObjSoftware.carpeta,$Ejecutables  {
            $Ejecutables = $args[1]
            foreach ($Ejecutable in $Ejecutables) {
                If ($Ejecutable.IsInLocalPath -eq "1") {
                    $Ejecutable.comando = $args[0] + "\" + $Ejecutable.comando
                }
                Start-Process $Ejecutable.comando -ArgumentList $Ejecutable.argumento -PassThru -Wait
            }
        } 
    }
    else {
	write-host "instalando en $Equipo"
        Invoke-command -ComputerName $Equipo -ArgumentList $ObjSoftware.carpeta,$Ejecutables  {
            $Ejecutables = $args[1]
            foreach ($Ejecutable in $Ejecutables) {
                If ($Ejecutable.IsInLocalPath -eq "1") {
                    $Ejecutable.comando = $args[0] + "\" + $Ejecutable.comando
		    Write-Host $Ejecutable.comando
                }
                Start-Process $Ejecutable.comando -ArgumentList $Ejecutable.argumento -PassThru -Wait
            }
        }  # -AsJob # -AsJob cuando se emplee sobre un equipo remoto.
    }

}



	
##PROCESOS
	
If ($ListAvailables) {
    ListAvailables
    break;
}

If ($Software) {
    $ObjApli = $ficheroXml.Configuracion.Aplis.Software | Where-Object {$_.Nombre -eq $Software}
    $ObjApli | Format-Table
    If ($ObjApli -eq $null) {
        Write-Host -BackgroundColor Red "El Parametro Software s�lo acepta valores de la siguiente lista"
        ListAvailables
        break
    }
    $FullPathApli = $ObjEnv.RutaLocal + "\" + $ObjApli.carpeta + "\"
    Write-Host "FULLPATHAPLI $FullPathApli"
    Write-Host "Equipos: " $ComputerName
    ForEach ($Computer in $ComputerName) {
        If (Test-Connection $Computer -Count 1 -ErrorAction SilentlyContinue) {
            If ($SoloCopia) {
                CopiaSoftware $ObjApli $Computer
            }
	    elseIf ($NoCheckFiles) {
		InstalaSoftware $ObjApli $Computer
	    }
            else {
                CopiaSoftware $ObjApli $Computer
                InstalaSoftware $ObjApli $Computer
            }
        }
    }
}

<#
.SYNOPSIS
    Script para la instalaci�n de software de forma remota en clientes de dominio bas�ndose 
    en la copia del software y ejecuci�n del instalador en local

.DESCRIPTION
    Instala el software en m�quinas remotas copiando el software en el disco duro local y luego
    ejecutando el proceso de instalaci�n.
    Junto con este scritp debe estar el lfichero software.xml que guarda los par�metros de instalaci�n
    del software.
.PARAMETER ListAvailables
    Lista el software disponible para la instalaci�n.
.PARAMETER Software
    Selecci�n del software a instalar
.PARAMETER SoloCopia
    En combinaci�n con Software, s�lo copia el software al disco duro local. No realiza la instalaci�n.
.PARAMETER ComputerName
    Selecci�n del cliente donde se instalar� el software. Si no se emplea se entiende que se est� lanzando el script
    para la instalaci�n del software en la máquina local.
.EXAMPLE
    PS C:\> Instalasoftware.ps1 -ListAvailables
    Muestra el software que se puede instalar bas�ndose en el fichero software.xml
.EXAMPLE    
    PS c:\> Instalasoftware.ps1 -software VISIO2013
    Instala el software VISIO2013 en el equipo local
.EXAMPLE
    PS C:\> Instalasoftware.ps1 -software VISIO2013 -ComputerName ZFNEEAE0100,ZFNEEAE0101
    Instala el software VISIO2013 en los equipos ZFNEEAE0100,ZFNEEAE0101
.EXAMPLE
    PS C:\> Instalasoftware.ps1 -software VISIO2013 -ComputerName ZFNEEAE0100 -SoloCopia
    Copia los archivos de instalaci�n del VISIO2013 al equipos ZFNEEAE0100 sin ejecutar la instalaci�n del software

.NOTES
    Autor: Juan Marcos Cobelo Serantes
    Fecha: 02/10/2017
#>