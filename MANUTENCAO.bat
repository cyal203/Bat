@echo off
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
if "%1"=="/hidden" goto :MANUTENCAO

:: Define variáveis
mode con: cols=50 lines=18
setlocal enabledelayedexpansion

:MANUTENCAO

call :IPV1
timeout /t 3 /nobreak >nul
call :iplisten
timeout /t 3 /nobreak >nul
call :StopServices
timeout /t 3 /nobreak >nul
call :StartServices
timeout /t 3 /nobreak >nul
::mshta "javascript:alert('REINICIADO SERVICOS\n\nDuvidas entre em contato com o Suporte.'); window.close();"
powershell -Command "Get-ChildItem -Path \"%TEMP%\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"
exit

:IPV1

:: Obtém o IPv4 do computador
	for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do for /f "tokens=1 delims= " %%j in ("%%i") do set IP=%%j
:: Remove espaços em branco
	set IP=%IP: =%
:: Caminho do arquivo de configuração
	set FILE="C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"
:: Substitui o endereço IP no arquivo usando PowerShell
	powershell -Command "(Get-Content '%FILE%') -replace 'http://.*:8080', 'http://%IP%:8080' | Set-Content '%FILE%'"
	goto :eof
	
:iplisten
	set "TEMP_IP=%TEMP%\IPLISTEN.txt"
	ipconfig | findstr "IPv4" > "%TEMP_IP%"
:: Lista os IPs no iplisten antes de remover
	for /f "tokens=*" %%i in ('netsh http show iplisten ^| findstr /R "[0-9]\."') do (
    set "IP=%%i"
    netsh http delete iplisten ip=!IP! >nul
)

:: Obtém o IP atual do computador
	for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr "IPv4"') do (
    set "CURRENT_IP=%%A"
    set "CURRENT_IP=!CURRENT_IP: =!"
)
:: Adiciona o IP atual e 127.0.0.1 ao iplisten
	echo Adicionado ip ao Iplisten:%w% !CURRENT_IP! %b%
	echo Adicionado ip ao Iplisten:%w%127.0.0.1 %b%
	netsh http add iplisten ip=!CURRENT_IP!  >nul
	netsh http add iplisten ip=127.0.0.1  >nul
	ipconfig /flushdns  >nul
	goto :eof

:StopServices
	sc stop SisOcrOffline >nul 2>&1
	sc stop SisAviCreator >nul 2>&1
	sc stop SisMonitorOffline >nul 2>&1
	sc stop MMFnx >nul 2>&1
	timeout /t 3 >nul
	taskkill /IM SisAviCreator.exe /F >nul 2>&1
	taskkill /IM SisMonitorOffline.exe /F >nul 2>&1
	taskkill /IM SSisOCR.Offline.Service.exe /F >nul 2>&1
	taskkill /IM FenoxSM.exe /F >nul 2>&1
	goto :eof
:StartServices
	sc start SisOcrOffline >nul 2>&1
	sc start SisAviCreator >nul 2>&1
	sc start SisMonitorOffline >nul 2>&1
	sc start MMFnx >nul 2>&1
	iisreset /restart
	goto :eof