@echo off
COLOR 1f
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
REM ******************* RENOMEANDO WCF ****************
ren C:\WCFLOCAL WCFLOCAL.17012
REM ******************* BAIXA A NOVA VERSAO ****************
echo Efetuando Download da nova versao 1.7.0.13...
curl -g -k -L -# -o "%temp%\UpdateWCFServidorLocal17013.zip" "http://update.fenoxapp.com.br/ModoOff/Install/WcfLocal/1.7.0.13/UpdateWCFServidorLocal17013.zip" >nul 2>&1
cls
REM ******************* EXTRAI NOVO SISOCR ****************
echo Extraindo Arquivos...
powershell -NoProfile Expand-Archive '%temp%\UpdateWCFServidorLocal17013.zip' -DestinationPath 'C:\WCFLOCAL' >nul 2>&1 

cls
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

