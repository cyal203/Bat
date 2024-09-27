@echo off
setlocal

rem Remove todos os IPs do iplisten
for /f "tokens=2 delims=:" %%I in ('netsh http show iplisten ^| findstr /R "IP"') do (
    set "ipToDelete=%%I"
    set "ipToDelete=!ipToDelete:~1!"
    netsh http del iplisten ipaddress=!ipToDelete!
)

rem Obtém o IP atual
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr /R "IPv4"') do set "currentIp=%%I"

rem Remove espaços em branco
set "currentIp=%currentIp:~1%"

rem Adiciona o IP atual ao iplisten
netsh http add iplisten ipaddress=%currentIp%
netsh http add iplisten 127.0.0.1
ipconfig /flushdns

echo Todos os IPs foram removidos e o IP atual (%currentIp%) foi adicionado.
pause
endlocal