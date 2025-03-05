@echo off
::----05.03.2025
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
for /f "tokens=2 delims==" %%i in ('wmic datafile where name^="%filePath%" get Version /value') do set "fileVersion=%%i"
chcp 65001 >nul 2>&1
echo ╔══════════════════════════╗
echo ║   Selecione uma opcao:   ║
echo ║%w%1 - Verificar versao%b%      ║
echo ║%w%2 - Atualizar Ocr%b%         ║
echo ║%w%3 - Atualizar Monitor%b%     ║
echo ║%w%4 - Atualizar Creator%b%     ║
echo ║%w%5 - Atualizar Todos%b%       ║
echo ╚══════════════════════════╝
rem choice /c 1234 /m "Escolha uma opcao"
Set /p option= Escolha uma opcao:
rem set "option=%errorlevel%"

if %option%==1 goto verificar_versao
if %option%==2 goto atualizar_ocr
if %option%==3 goto atualizar_monitor
if %option%==4 goto atualizar_creator
if %option%==5 goto atualizar_todos
goto end

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
echo Data: %currentDate% > %logFile%
echo Parando Servicos...>> %logFile% 2>&1
sc stop SisOcrOffline
sc stop SisAviCreator
sc stop SisMonitorOffline
sc stop MMFnx
taskkill /IM SisAviCreator.exe /F
taskkill /IM SisMonitorOffline.exe /F
taskkill /IM SSisOCR.Offline.Service.exe /F
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\SisOcrOffline7400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/Ocr/SisOcrOffline7400.zip" >nul 2>&1
echo Extraindo Arquivos... >> %logFile% 2>&1
powershell -NoProfile Expand-Archive '%temp%\SisOcrOffline7400.zip' -DestinationPath 'C:\SisOcr Offline' >nul 2>&1 
robocopy "C:\SisOcr Offline" "C:\Program Files (x86)\FNX\SisOcr Offline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1
echo Iniciando Servicos...>> %logFile% 2>&1
sc start SisOcrOffline
sc start SisAviCreator
sc start SisMonitorOffline
sc start MMFnx
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
echo Data: %currentDate% > %logFile%
echo Parando Servicos...>> %logFile% 2>&1
sc stop SisOcrOffline
sc stop SisAviCreator
sc stop SisMonitorOffline
sc stop MMFnx
taskkill /IM SisAviCreator.exe /F
taskkill /IM SisMonitorOffline.exe /F
taskkill /IM SSisOCR.Offline.Service.exe /F
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\SisMonitor7131.zip" "https://update.fenoxapp.com.br/Instaladores/Monitor/SisMonitor7131.zip" >nul 2>&1
powershell -NoProfile Expand-Archive '%temp%\SisMonitor7131.zip' -DestinationPath 'C:\SisMonitorOffline' >nul 2>&1
echo Movendo arquivos baixados... >> %logFile% 2>&1
robocopy "C:\SisMonitorOffline" "C:\Program Files (x86)\FNX\SisMonitorOffline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1
echo Iniciando Servicos...>> %logFile% 2>&1
sc start SisOcrOffline
sc start SisAviCreator
sc start SisMonitorOffline
sc start MMFnx
cls
set "filePath=C:\\Program Files (x86)\\FNX\\SisMonitorOffline\\SisMonitorOffline.exe"
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
echo Data: %currentDate% > %logFile%
echo Parando Servicos...>> %logFile% 2>&1
sc stop SisOcrOffline
sc stop SisAviCreator
sc stop SisMonitorOffline
sc stop MMFnx
taskkill /IM SisAviCreator.exe /F
taskkill /IM SisMonitorOffline.exe /F
taskkill /IM SSisOCR.Offline.Service.exe /F
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\sisavicreator121400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/AviCreator/sisavicreator121400.zip" >nul 2>&1
powershell -NoProfile Expand-Archive '%temp%\sisavicreator121400.zip' -DestinationPath 'C:\SisAviCreator' >nul 2>&1
echo Movendo arquivos baixados... >> %logFile% 2>&1
robocopy "C:\SisAviCreator" "C:\Program Files (x86)\FNX\SisAviCreator" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1
cls
echo Iniciando Servicos...
sc start SisOcrOffline
sc start SisAviCreator
sc start SisMonitorOffline1
sc start MMFnx
cls
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

REM ******************* PARAR SERVIÇOS ****************
echo Parando Servicos...
sc stop SisOcrOffline >> %logFile% 2>&1
sc stop SisAviCreator >> %logFile% 2>&1
sc stop SisMonitorOffline >> %logFile% 2>&1
sc stop MMFnx >> %logFile% 2>&1
taskkill /IM SisAviCreator.exe /F >> %logFile% 2>&1
taskkill /IM SisMonitorOffline.exe /F >> %logFile% 2>&1
taskkill /IM SSisOCR.Offline.Service.exe /F >> %logFile% 2>&1

cls

REM ******************* BAIXA NOVAs VERSOES ****************
echo Efetuando Download... >> %logFile% 2>&1
curl -g -k -L -# -o "%temp%\SisOcrOffline7400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/Ocr/SisOcrOffline7400.zip" >nul 2>&1
cls
curl -g -k -L -# -o "%temp%\sisavicreator121400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/AviCreator/sisavicreator121400.zip" >nul 2>&1

curl -g -k -L -# -o "%temp%\SisMonitor7131.zip" "https://update.fenoxapp.com.br/Instaladores/Monitor/SisMonitor7131.zip" >nul 2>&1
cls

REM ******************* EXTRAI ARQUIVOS ****************
echo Extraindo Arquivos... >> %logFile% 2>&1
powershell -NoProfile Expand-Archive '%temp%\SisOcrOffline7400.zip' -DestinationPath 'C:\SisOcr Offline' >nul 2>&1 
powershell -NoProfile Expand-Archive '%temp%\sisavicreator121400.zip' -DestinationPath 'C:\SisAviCreator' >nul 2>&1 
powershell -NoProfile Expand-Archive '%temp%\SisMonitor7131.zip' -DestinationPath 'C:\SisMonitorOffline' >nul 2>&1 
cls

REM ******************* MOVENDO ARQUIVOS ****************
echo Movendo arquivos baixados... >> %logFile% 2>&1
REM /E: Copia todos os subdiretórios, incluindo os vazios.
REM /MOVE: Move os arquivos e diretórios, excluindo-os da origem após a cópia.
REM /R:3: Tenta reexecutar a cópia 3 vezes em caso de falha.
REM /W:5: Espera 5 segundos entre as tentativas.
robocopy "C:\SisOcr Offline" "C:\Program Files (x86)\FNX\SisOcr Offline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1
robocopy "C:\SisAviCreator" "C:\Program Files (x86)\FNX\SisAviCreator" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1
robocopy "C:\SisMonitorOffline" "C:\Program Files (x86)\FNX\SisMonitorOffline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1

cls
REM ******************* INICIA SERVIÇOS ****************
echo Iniciando Servicos...
sc start SisOcrOffline >> %logFile% 2>&1
sc start SisAviCreator >> %logFile% 2>&1
sc start SisMonitorOffline >> %logFile% 2>&1
sc start MMFnx >> %logFile% 2>&1
cls
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
:end
