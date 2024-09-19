@echo off
chcp 65001 >nul
title Versao 1.7.0.13
call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof
mode con: cols=60 lines=10
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
ren "C:\WCFLOCAL" "WCFLOCAL.17012"
ren "C:\Program Files (x86)\Fenox V1.0" "Fenox V1.0.1012"
echo Pasta renomeada com sucesso.
REM ******************* BAIXA A NOVA VERSAO ****************
echo Efetuando Download da nova versao 1.7.0.13...
curl -g -k -L -# -o "%temp%\1.7.0.13.zip" "https://www.dropbox.com/scl/fi/av89whtp4g6vwihlb1lzr/1.7.0.13.zip?rlkey=o8d83pkbqi06b79ub42yyrkmr&st=qrauww2y&dl=1" >nul 2>&1
cls
REM ******************* EXTRAI NOVO SISOCR ****************
echo Extraindo Arquivos...
powershell -NoProfile Expand-Archive '%temp%\1.7.0.13.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1 
REM ******************* INSTALANDO ****************
echo Instalando...
%temp%\Fenox\Fnx_1.7.0.13_x64.exe /silent
%temp%\Fenox\WCFLocalFenox_1.7.0.13_x86 /silent
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

