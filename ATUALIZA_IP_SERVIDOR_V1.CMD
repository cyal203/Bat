@echo off
setlocal

REM Obtém o IPv4 do computador
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do for /f "tokens=1 delims= " %%j in ("%%i") do set IP=%%j
pause
REM Remove espaços em branco
set IP=%IP: =%
pause
REM Caminho do arquivo de configuração
set FILE="C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"
pause
REM Substitui o endereço IP no arquivo usando PowerShell
powershell -Command "(Get-Content '%FILE%') -replace 'http://.*:8080', 'http://%IP%:8080' | Set-Content '%FILE%'"
pause
endlocal