@echo off
chcp 65001 >nul
title Versão 1.3
REM -----13/04/2025
call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof
mode con: cols=45 lines=12
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
cls
Set Version=4
set w=[97m
set p=[95m
set b=[96m
%B%
cls 
setlocal
set logFile="C:\captura\logs\ATUALIZACAO_SIS.txt"
set currentDate=%date%
echo Data: %currentDate% > %logFile%
:menu
::for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
echo         ╔══════════════════════════╗
echo         ║   Selecione uma opcao:   ║
echo         ║[%w%1%b%]  %w%VERIFICAR VERSAO%b%     ║
echo         ║[%w%2%b%]  %w%ATUALIZAR OCR%b%        ║
echo         ║[%w%3%b%]  %w%ATUALIZAR MONITOR%b%    ║
echo         ║[%w%4%b%]  %w%ATUALIZAR CREATOR%b%    ║
echo         ║[%w%5%b%]  %w%ATUALIZAR TODOS%b%      ║
echo         ║[%w%6%b%]  %w%MENU ANTERIOR%b%        ║
echo         ╚══════════════════════════╝
rem choice /c 1234 /m "Escolha uma opcao"
Set /p option= Escolha uma opcao:
rem set "option=%errorlevel%"

if %option%==1 goto verificar_versao
if %option%==2 goto atualizar_ocr
if %option%==3 goto atualizar_monitor
if %option%==4 goto atualizar_creator
if %option%==5 goto atualizar_todos
if %option%==6 goto menu_anterior
goto end
:menu_anterior
%temp%\CMD_1.2.cmd
:verificar_versao
cls
echo Data: %currentDate% > %logFile%
set "filePath=C:\\Program Files (x86)\\FNX\\SisOcr Offline\\SisOCR.Offline.Service.exe"
set "expectedVersion=7.4.0.0"
for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
chcp 65001 >nul 2>&1
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisOCR %fileVersion% OK.             ║
) else (
    echo ║Versao SisOCR %fileVersion%                 ║
   echo ║%w% Versao SisOCR Atual %expectedVersion% ^<== %b%     ║
)
echo ╚══════════════════════════════════════╝
echo OCR %fileVersion% >> %logFile%
REM ******************* VERSAO SisMonitorOffline ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisMonitorOffline\\SisMonitorOffline.exe"
set "expectedVersion=7.1.3.1"
for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisMonitor %fileVersion% OK.         ║
) else (
    echo ║Versao SisMonitor %fileVersion%             ║
   echo ║%w% Versao SisMonitor Atual %expectedVersion% ^<== %b% ║
)
echo ╚══════════════════════════════════════╝
echo Monitor %fileVersion% >> %logFile%

REM ******************* VERSAO AVICREATOR ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisAviCreator\\SisAviCreator.exe"
set "expectedVersion=12.1.4.0"

for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisAviCreator %fileVersion% OK.     ║
) else (
    echo ║Versao SisCreator %fileVersion%            ║
   echo ║%w% Versao SisCreator Atual %expectedVersion% ^<== %b%║
)
echo ╚══════════════════════════════════════╝
echo Creator %fileVersion% >> %logFile%
pause
cls
goto menu

:atualizar_ocr
cls
echo Data: %currentDate% > %logFile% >nul
echo Parando Servicos...>> %logFile% 2>&1 >nul
sc stop SisOcrOffline >nul
sc stop SisAviCreator >nul
sc stop SisMonitorOffline >nul
sc stop MMFnx >nul
taskkill /IM SisAviCreator.exe /F >nul
taskkill /IM SisMonitorOffline.exe /F >nul
taskkill /IM SSisOCR.Offline.Service.exe /F >nul
taskkill /IM FenoxSM.exe /F >nul
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\SisOcrOffline7400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/Ocr/SisOcrOffline7400.zip" >nul 2>&1
echo Extraindo Arquivos... >> %logFile% 2>&1 >nul
powershell -NoProfile Expand-Archive '%temp%\SisOcrOffline7400.zip' -DestinationPath 'C:\SisOcr Offline' >nul 2>&1 
robocopy "C:\SisOcr Offline" "C:\Program Files (x86)\FNX\SisOcr Offline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1 >nul
echo Iniciando Servicos...>> %logFile% 2>&1
sc start SisOcrOffline >nul
sc start SisAviCreator >nul
sc start SisMonitorOffline >nul
sc start MMFnx >nul
cls
set "filePath=C:\\Program Files (x86)\\FNX\\SisOcr Offline\\SisOCR.Offline.Service.exe"
set "expectedVersion=7.4.0.0"

for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
chcp 65001 >nul 2>&1
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisOCR %fileVersion% OK.             ║
) else (
    echo ║Versao SisOCR %fileVersion%                 ║
   echo ║%w% Versao SisOCR Atual %expectedVersion% ^<== %b%     ║
)
echo ╚══════════════════════════════════════╝
echo OCR %fileVersion% >> %logFile%
pause
cls
goto menu

:atualizar_monitor
cls
echo Data: %currentDate% > %logFile% >nul
echo Parando Servicos...>> %logFile% 2>&1 >nul
sc stop SisOcrOffline >nul
sc stop SisAviCreator >nul
sc stop SisMonitorOffline >nul
sc stop MMFnx >nul
taskkill /IM SisAviCreator.exe /F >nul
taskkill /IM SisMonitorOffline.exe /F >nul
taskkill /IM SSisOCR.Offline.Service.exe /F >nul
taskkill /IM FenoxSM.exe /F >nul
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\SisMonitor7131.zip" "https://update.fenoxapp.com.br/Instaladores/Monitor/SisMonitor7131.zip" >nul 2>&1
powershell -NoProfile Expand-Archive '%temp%\SisMonitor7131.zip' -DestinationPath 'C:\SisMonitorOffline' >nul 2>&1
echo Movendo arquivos baixados... >> %logFile% 2>&1 >nul
robocopy "C:\SisMonitorOffline" "C:\Program Files (x86)\FNX\SisMonitorOffline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1 >nul
echo Iniciando Servicos...>> %logFile% 2>&1
sc start SisOcrOffline >nul
sc start SisAviCreator >nul
sc start SisMonitorOffline >nul
sc start MMFnx >nul
cls
set "filePath=C:\\Program Files (x86)\\FNX\\SisMonitorOffline\\SisMonitorOffline.exe" >nul
set "expectedVersion=7.1.3.1"
for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
cls
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisMonitor %fileVersion% OK.         ║
) else (
    echo ║Versao SisMonitor %fileVersion%             ║
   echo ║%w% Versao SisMonitor Atual %expectedVersion% ^<== %b% ║
)
echo ╚══════════════════════════════════════╝
echo Monitor %fileVersion% >> %logFile%
pause
cls
goto menu

:atualizar_creator
cls
echo Data: %currentDate% > %logFile% >nul
echo Parando Servicos...>> %logFile% 2>&1 >nul
sc stop SisOcrOffline >nul
sc stop SisAviCreator >nul
sc stop SisMonitorOffline >nul
sc stop MMFnx >nul
taskkill /IM SisAviCreator.exe /F >nul
taskkill /IM SisMonitorOffline.exe /F >nul
taskkill /IM SSisOCR.Offline.Service.exe /F >nul
taskkill /IM FenoxSM.exe /F >nul
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\sisavicreator121400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/AviCreator/sisavicreator121400.zip" >nul 2>&1
powershell -NoProfile Expand-Archive '%temp%\sisavicreator121400.zip' -DestinationPath 'C:\SisAviCreator' >nul 2>&1
echo Movendo arquivos baixados... >> %logFile% 2>&1 >nul
robocopy "C:\SisAviCreator" "C:\Program Files (x86)\FNX\SisAviCreator" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1 >nul
cls
echo Iniciando Servicos...
sc start SisOcrOffline >nul
sc start SisAviCreator >nul
sc start SisMonitorOffline1 >nul
sc start MMFnx >nul
cls
set "filePath=C:\\Program Files (x86)\\FNX\\SisAviCreator\\SisAviCreator.exe" >nul
set "expectedVersion=12.1.4.0"

for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisAviCreator %fileVersion% OK.     ║
) else (
    echo ║Versao SisCreator %fileVersion%            ║
   echo ║%w% Versao SisCreator Atual %expectedVersion% ^<== %b%║
)
echo ╚══════════════════════════════════════╝
echo Creator %fileVersion% >> %logFile%
pause
cls
goto menu

:atualizar_todos

REM *******************VERCAO SISOCR ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisOcr Offline\\SisOCR.Offline.Service.exe"
set "expectedVersion=7.4.0.0"

for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
chcp 65001 >nul 2>&1
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisOCR %fileVersion% OK.             ║
) else (
    echo ║Versao SisOCR %fileVersion%                 ║
   echo ║%w% Versao SisOCR Atual %expectedVersion% ^<== %b%     ║
)
echo ╚══════════════════════════════════════╝
echo OCR %fileVersion% >> %logFile% >nul

REM ******************* VERSAO SisMonitorOffline ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisMonitorOffline\\SisMonitorOffline.exe"
set "expectedVersion=7.1.3.1"
for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisMonitor %fileVersion% OK.         ║
) else (
    echo ║Versao SisMonitor %fileVersion%             ║
   echo ║%w% Versao SisMonitor Atual %expectedVersion% ^<== %b% ║
)
echo ╚══════════════════════════════════════╝
echo Monitor %fileVersion% >> %logFile% >nul

REM ******************* VERSAO AVICREATOR ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisAviCreator\\SisAviCreator.exe" >nul
set "expectedVersion=12.1.4.0"

for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i" >nul
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisAviCreator %fileVersion% OK.     ║
) else (
    echo ║Versao SisCreator %fileVersion%            ║
   echo ║%w% Versao SisCreator Atual %expectedVersion% ^<== %b%║
)
echo ╚══════════════════════════════════════╝
echo Creator %fileVersion% >> %logFile% >nul
pause
echo Atualizando...
REM ******************* PARAR SERVIÇOS ****************
echo Parando Servicos...
sc stop SisOcrOffline >> %logFile% 2>&1 >nul
sc stop SisAviCreator >> %logFile% 2>&1 >nul
sc stop SisMonitorOffline >> %logFile% 2>&1 >nul
sc stop MMFnx >> %logFile% 2>&1 >nul
taskkill /IM SisAviCreator.exe /F >> %logFile% 2>&1 >nul
taskkill /IM SisMonitorOffline.exe /F >> %logFile% 2>&1 >nul
taskkill /IM SSisOCR.Offline.Service.exe /F >> %logFile% 2>&1 >nul
taskkill /IM FenoxSM.exe /F >nul
cls
echo Atualizando....
REM ******************* BAIXA NOVAs VERSOES ****************
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\SisOcrOffline7400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/Ocr/SisOcrOffline7400.zip" >nul 2>&1
curl -g -k -L -# -o "%temp%\sisavicreator121400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/AviCreator/sisavicreator121400.zip" >nul 2>&1
curl -g -k -L -# -o "%temp%\SisMonitor7131.zip" "https://update.fenoxapp.com.br/Instaladores/Monitor/SisMonitor7131.zip" >nul 2>&1
cls
echo Atualizando.....
REM ******************* EXTRAI ARQUIVOS ****************
echo Extraindo Arquivos... >> %logFile% 2>&1
powershell -NoProfile Expand-Archive '%temp%\SisOcrOffline7400.zip' -DestinationPath 'C:\SisOcr Offline' >nul 2>&1 
powershell -NoProfile Expand-Archive '%temp%\sisavicreator121400.zip' -DestinationPath 'C:\SisAviCreator' >nul 2>&1 
powershell -NoProfile Expand-Archive '%temp%\SisMonitor7131.zip' -DestinationPath 'C:\SisMonitorOffline' >nul 2>&1 
cls
echo Atualizando......
REM ******************* MOVENDO ARQUIVOS ****************
echo Movendo arquivos baixados... >> %logFile% 2>&1 >nul
robocopy "C:\SisOcr Offline" "C:\Program Files (x86)\FNX\SisOcr Offline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1 >nul
robocopy "C:\SisAviCreator" "C:\Program Files (x86)\FNX\SisAviCreator" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1 >nul
robocopy "C:\SisMonitorOffline" "C:\Program Files (x86)\FNX\SisMonitorOffline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1 >nul
REM ******************* INICIA SERVIÇOS ****************
echo Iniciando Servicos...
sc start SisOcrOffline >> %logFile% 2>&1 >nul
sc start SisAviCreator >> %logFile% 2>&1 >nul
sc start SisMonitorOffline >> %logFile% 2>&1 >nul
sc start MMFnx >> %logFile% 2>&1 >nul
cls
REM *******************VERCAO SISOCR ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisOcr Offline\\SisOCR.Offline.Service.exe" >nul
set "expectedVersion=7.4.0.0"

for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
chcp 65001 >nul 2>&1
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisOCR %fileVersion% OK.             ║
) else (
    echo ║Versao SisOCR %fileVersion%                 ║
   echo ║%w% Versao SisOCR Atual %expectedVersion% ^<== %b%     ║
)
echo ╚══════════════════════════════════════╝

REM ******************* VERSAO SisMonitorOffline ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisMonitorOffline\\SisMonitorOffline.exe"
set "expectedVersion=7.1.3.1"
for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisMonitor %fileVersion% OK.         ║
) else (
    echo ║Versao SisMonitor %fileVersion%             ║
   echo ║%w% Versao SisMonitor Atual %expectedVersion% ^<== %b% ║
)
echo ╚══════════════════════════════════════╝

REM ******************* VERSAO AVICREATOR ********************
set "filePath=C:\\Program Files (x86)\\FNX\\SisAviCreator\\SisAviCreator.exe"
set "expectedVersion=12.1.4.0"

for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
echo ╔══════════════════════════════════════╗
if "%fileVersion%"=="%expectedVersion%" (
    echo ║Versao SisAviCreator %fileVersion% OK.     ║
) else (
    echo ║Versao SisCreator %fileVersion%            ║
   echo ║%w% Versao SisCreator Atual %expectedVersion% ^<== %b%║
)
echo ╚══════════════════════════════════════╝
echo      %p% ATUALIZACAO CONCLUIDA...%b% 
echo atualizacao concluida >> %logFile% 2>&1
echo Data: %currentDate% > %logFile%
pause
endlocal
cls
goto menu
