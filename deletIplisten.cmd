@echo off
setlocal enabledelayedexpansion

rem Remove todos os IPs do iplisten
for /f "tokens=2 delims=:" %%I in ('netsh http show iplisten ^| findstr /R "IP"') do (
    set "ipToDelete=%%I"
    set "ipToDelete=!ipToDelete:~1!"
    if not "!ipToDelete!"=="" (
        echo Removendo IP: !ipToDelete!
        netsh http delete iplisten ipaddress=!ipToDelete!
    )
)

echo Todos os IPs foram removidos do iplisten.
endlocal