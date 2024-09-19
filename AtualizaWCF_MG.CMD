@echo off
chcp 65001 >nul
title Versao 1.7.0.13
call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof
mode con: cols=50 lines=10
COLOR 1f
setlocal
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
cls
REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao V1 e WCF...
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version && wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
pause
cls
REM ******************* PARA INETMGR ****************
echo Parando Inetmgr...
iisreset /stop
sc stop SisMonitorOffline
sc stop SisOcrOffline
sc stop SisAviCreator
cls
REM ******************* RENOMEANDO WCF e V1 ****************
ren C:\WCFLOCAL WCFLOCAL.17012
ren C:\Program Files (x86)\Fenox V1.0.17012
REM ******************* BAIXA A NOVA VERSAO ****************
echo Efetuando Download da nova versao 1.7.0.13...
curl -g -k -L -# -o "%temp%\UpdateWCFServidorLocal17013.zip" "http://update.fenoxapp.com.br/ModoOff/Install/WcfLocal/1.7.0.13/UpdateWCFServidorLocal17013.zip" >nul 2>&1
curl -g -k -L -# -o "%temp%\Fnx64.zip" "http://update.fenoxapp.com.br/ModoOff/Install/SistemaLaudos/1.7.0.13/Fnx64.zip" >nul 2>&1
cls
REM ******************* EXTRAI NOVO SISOCR ****************
echo Extraindo Arquivos...
powershell -NoProfile Expand-Archive '%temp%\UpdateWCFServidorLocal17013.zip' -DestinationPath 'C:\WCFLOCAL' >nul 2>&1 
powershell -NoProfile Expand-Archive '%temp%\Fnx64.zip' -DestinationPath 'C:\Users\%username%\Documents\Fenox V1' >nul 2>&1  
robocopy "C:\Users\%username%\Documents\Fenox V1" "C:\Program Files (x86)\Fenox V1" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1
cls
REM Obtém o IPv4 do computador
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do for /f "tokens=1 delims= " %%j in ("%%i") do set IP=%%j
REM Remove espaços em branco
set IP=%IP: =%
REM Caminho do arquivo de configuração
set FILE="C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"
REM Substitui o endereço IP no arquivo usando PowerShell
powershell -Command "(Get-Content '%FILE%') -replace 'http://.*:8080', 'http://%IP%:8080' | Set-Content '%FILE%'"
REM ******************* INICIA SISOCR ****************
echo Iniciando Servico
iisreset /start
sc start SisMonitorOffline
sc start SisOcrOffline
sc start SisAviCreator
cls
echo Finalizado
REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao...
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version && wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
echo FINALIZADO...
pause
exit

