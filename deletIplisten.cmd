@echo off
setlocal enabledelayedexpansion

rem Mostra os IPs atuais no iplisten
echo Listando IPs atuais no iplisten:
netsh http show iplisten

rem Remove todos os IPs do iplisten
for /f "tokens=2 delims=:" %%I in ('netsh http show iplisten ^| findstr /R "IP"') do (
    set "ipToDelete=%%I"
    set "ipToDelete=!ipToDelete:~1!"  rem Remove espaço em branco inicial
    set "ipToDelete=!ipToDelete: =!"   rem Remove espaços em branco adicionais
    if not "!ipToDelete!"=="" (
        echo Removendo IP: !ipToDelete!
        netsh http delete iplisten ipaddress=!ipToDelete! 2>nul
        if errorlevel 1 (
            echo Erro ao remover IP: !ipToDelete!
        )
    )
)

echo Todos os IPs foram removidos do iplisten.
pause
endlocal

