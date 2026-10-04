# ==============================================
#       INVENTARIO DE HARDWARE
# ==============================================

$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$ram = Get-CimInstance Win32_ComputerSystem

$archivo = "inventario_hardware.txt"

$inventario = @"

==============================================
        INVENTARIO DE HARDWARE
==============================================

== Equipo: $($env:COMPUTERNAME)
== Fecha: $(Get-Date)

== Sistema Operativo
SO: $($os.Caption)
Version: $($os.Version)

== CPU
Modelo: $($cpu.Name)
Nucleos: $($cpu.NumberOfCores)
Hilos: $($cpu.NumberOfLogicalProcessors)
Frecuencia: $($cpu.MaxClockSpeed) MHz

== Cache
L2: $($cpu.L2CacheSize) KB
L3: $($cpu.L3CacheSize) KB

== Memoria RAM
"@

$ramGB = [math]::Round(
    $ram.TotalPhysicalMemory / 1GB,
    2
)

$inventario += @"

RAM total: $ramGB GB

== Discos

"@

$discos = Get-PhysicalDisk |
    Select-Object FriendlyName, MediaType,
    @{Name="Tamano(GB)";Expression={
        [math]::Round($_.Size / 1GB, 2)
    }} |
    Format-Table -AutoSize |
    Out-String

$inventario += $discos

$inventario += @"

== Interfaces de red e IP

"@

$red = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*"
    } |
    Select-Object InterfaceAlias, IPAddress |
    Format-Table -AutoSize |
    Out-String

$inventario += $red

$inventario += @"

==============================================
        FIN DEL INVENTARIO
==============================================
"@

$inventario | Out-File -FilePath $archivo -Encoding UTF8

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host " INVENTARIO GENERADO CORRECTAMENTE" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Archivo creado: $archivo" -ForegroundColor Cyan
Write-Host "Ubicacion: $(Get-Location)\$archivo" -ForegroundColor Cyan
Write-Host ""