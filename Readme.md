# PowershellScriptingAD
Scrips de powershell para la administración de un directorio activo con DNS, DHCP, SERVIDOR DE FICHEROS. Este directorio activo se emplea para enseñanza con lo que habrá usuarios profesores y usuarios alumnos.
**Los diferentes scripts se dividen en varias carpetas:**
### accesosServicios: 
Links para parar servicios del sistema operativo cuando no sean necesarios.
### Asignaturas:
Scripts para crear carpetas de asignaturas de forma que los alumnos sólo puedan ver contenido, y los profesores modificarlo.
### Equipos:
Scripts para generar informes de equipos, borrar perfiles y otros...
### Instalaciones
Script completo para las instalaciones desatendidas en los equipos de dominio. Se basa en la carga en local del instalable en .msi o .exe con instalación desatendida, seguido de la invocación remota de la instalación. El software que se puede instalar se encuentra en una carpeta compartida en el servidor de ficheros y se controla mediante un fichero .xml
### Usuarios
Scripts se manejo de usuarios de dominio. Entre otros la creación de usuarios alumnos y profesores, el reseteo de usuarios, informes de usuarios conectados a equipos, etc...
