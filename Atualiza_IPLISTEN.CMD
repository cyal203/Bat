@echo off
setlocal enabledelayedexpansion

REM Obter o IP atual da máquina
for /f "tokens=2 delims=[]" %%i in ('ping -4 -n 1 %computername% ^| find "Pinging"') do set ipAtual=%%i

REM Remover todos os IPs da lista iplisten
for /f "tokens=2 delims=:" %%i in ('netsh http show iplisten ^| findstr /R /C:"IP.*"') do (
    set ip=%%i
    set ip=!ip:~1!
    netsh http delete iplisten ipaddress=!ip!
)

REM Adicionar o IP atual à lista iplisten
netsh http add iplisten ipaddress=%ipAtual%

echo Todos os IPs foram removidos da lista iplisten e o IP atual (%ipAtual%) foi adicionado.
pause