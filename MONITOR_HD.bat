@echo off
:: ======================
:: ------17/04/2025------
:: ======================
setlocal enabledelayedexpansion
set "sis_ocr=7.4.0.0"
set "sis_monitor=7.1.3.1"
set "sis_creator=12.1.4.00"
:: Adicione aqui hosts que não atualizarão a OCR ex.: FENOX33 FENOX34 FENOX33 FENOX34
set "excludedHostsocr=FENOX33 FENOX34 FENOX31 FENOX117 FENOX40 FENOX128 FENOX023 FENOX54 FENOX85 FENOX27"
:: Adicione aqui hosts que não atualizarão o Monitor ex.: FENOX33 FENOX34 FENOX33 FENOX34
set "excludedHostsmonitor="
:: Adicione aqui hosts que não atualizarão o creator ex.: FENOX33 FENOX34 FENOX33 FENOX34
set "excludedHostscreator="

:: ================================
:: Verificar versão do SisMonitorOffline
:: ================================
:: LISTA DE SERVIDORES COM OUTRA VERSÃO DO MONITOR, NÃO RECEBERÃO ATUALIZAÇÃO
for %%h in (%excludedHostscreator%) do (
    if /I "%%h"=="%COMPUTERNAME%" goto SkipMonitor
)

set "exemonitor=C:\Program Files (x86)\FNX\SisMonitorOffline\SisMonitorOffline.exe"

set "logFile=%temp%\log_sismonitor_update.txt"

:: Obtém a versão do executável
for /f "tokens=*" %%A in ('powershell -command "(Get-Item '%exemonitor%').VersionInfo.ProductVersion"') do set "versaoAtualmonitor=%%A"

echo Versao atual do SisMonitorOffline: %versaoAtualmonitor%

:: Compara a versão
if not "%versaoAtualmonitor%"=="%sis_monitor%" (
    echo Versao desatualizada. Iniciando atualizacao...

    :: Parar serviços
    sc stop SisOcrOffline >nul
    sc stop SisAviCreator >nul
    sc stop SisMonitorOffline >nul
    sc stop MMFnx >nul

    :: Encerrar processos
    taskkill /IM SisAviCreator.exe /F >nul
    taskkill /IM SisMonitorOffline.exe /F >nul
    taskkill /IM SSisOCR.Offline.Service.exe /F >nul
    taskkill /IM FenoxSM.exe /F >nul

    echo Efetuando Download... >> %logFile% 2>&1
    curl -g -k -L -# -o "%temp%\SisMonitor7131.zip" "https://update.fenoxapp.com.br/Instaladores/Monitor/SisMonitor7131.zip" >nul 2>&1

    powershell -NoProfile Expand-Archive '%temp%\SisMonitor7131.zip' -DestinationPath 'C:\SisMonitorOffline' >nul 2>&1

    echo Movendo arquivos baixados... >> %logFile% 2>&1
    robocopy "C:\SisMonitorOffline" "C:\Program Files (x86)\FNX\SisMonitorOffline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1

    echo Iniciando Servicos... >> %logFile% 2>&1
    sc start SisOcrOffline >nul
    sc start SisAviCreator >nul
    sc start SisMonitorOffline >nul
    sc start MMFnx >nul
)
:SkipMonitor

:: ================================
:: Verificar versão do SisAviCreator
:: ================================

:: LISTA DE SERVIDORES COM OUTRA VERSÃO DO CREATOR, NÃO RECEBERÃO ATUALIZAÇÃO
for %%h in (%excludedHostscreator%) do (
    if /I "%%h"=="%COMPUTERNAME%" goto SkipCreator
)

set "execreator=C:\Program Files (x86)\FNX\SisAviCreator\SisAviCreator.exe"
set "logFile=%temp%\log_siscreator_update.txt"

:: Obtém a versão do executável
for /f "tokens=*" %%A in ('powershell -command "(Get-Item '%execreator%').VersionInfo.ProductVersion"') do set "versaoAtualcreator=%%A"
echo Versao atual do SisAviCreator: %versaoAtualcreator%

:: Compara a versão
if not "%versaoAtualcreator%"=="%sis_creator%" (
    echo Versao desatualizada. Iniciando atualizacao...
    :: Parar serviços
    sc stop SisOcrOffline >nul
    sc stop SisAviCreator >nul
    sc stop SisMonitorOffline >nul
    sc stop MMFnx >nul

    :: Encerrar processos
    taskkill /IM SisAviCreator.exe /F >nul
    taskkill /IM SisMonitorOffline.exe /F >nul
    taskkill /IM SSisOCR.Offline.Service.exe /F >nul
    taskkill /IM FenoxSM.exe /F >nul

    echo Efetuando Download... >> %logFile% 2>&1
    curl -g -k -L -# -o "%temp%\sisavicreator121400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/AviCreator/sisavicreator121400.zip" >nul 2>&1

    powershell -NoProfile Expand-Archive '%temp%\sisavicreator121400.zip' -DestinationPath 'C:\SisAviCreator' >nul 2>&1

    echo Movendo arquivos baixados... >> %logFile% 2>&1
    robocopy "C:\SisAviCreator" "C:\Program Files (x86)\FNX\SisAviCreator" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1

    echo Iniciando Servicos... >> %logFile% 2>&1
    sc start SisOcrOffline >nul
    sc start SisAviCreator >nul
    sc start SisMonitorOffline >nul
    sc start MMFnx >nul
)
:SkipCreator

:: ================================
:: Verificar versão do SisOcr
:: ================================

:: LISTA DE SERVIDORES COM OUTRA VERSÃO DA OCR, NÃO RECEBERÃO ATUALIZAÇÃO
for %%h in (%excludedHostsocr%) do (
    if /I "%%h"=="%COMPUTERNAME%" goto SkipOCR
)

set "exeocr=C:\Program Files (x86)\FNX\SisOcr Offline\SisOCR.Offline.Service.exe"
set "logFile=%temp%\log_sisocr_update.txt"

:: Obtém a versão do executável
for /f "tokens=*" %%A in ('powershell -command "(Get-Item '%exeocr%').VersionInfo.ProductVersion"') do set "versaoAtualocr=%%A"
echo Versao atual do SisOcr: %versaoAtualocr%

:: Compara a versão
if not "%versaoAtualocr%"=="%sis_ocr%" (
    echo Versao desatualizada. Iniciando atualizacao...
    :: Parar serviços
    sc stop SisOcrOffline >nul
    sc stop SisAviCreator >nul
    sc stop SisMonitorOffline >nul
    sc stop MMFnx >nul

    :: Encerrar processos
    taskkill /IM SisAviCreator.exe /F >nul
    taskkill /IM SisMonitorOffline.exe /F >nul
    taskkill /IM SSisOCR.Offline.Service.exe /F >nul
    taskkill /IM FenoxSM.exe /F >nul

    echo Efetuando Download... >> %logFile% 2>&1
	curl -g -k -L -# -o "%temp%\SisOcrOffline7400.zip" "https://update.fenoxapp.com.br/ModoOff/Install/Ocr/SisOcrOffline7400.zip" >nul 2>&1

    powershell -NoProfile Expand-Archive '%temp%\SisOcrOffline7400.zip' -DestinationPath 'C:\SisOcr Offline' >nul 2>&1

    echo Movendo arquivos baixados... >> %logFile% 2>&1
    robocopy "C:\SisOcr Offline" "C:\Program Files (x86)\FNX\SisOcr Offline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1 >nul

    echo Iniciando Servicos... >> %logFile% 2>&1
    sc start SisOcrOffline >nul
    sc start SisAviCreator >nul
    sc start SisMonitorOffline >nul
    sc start MMFnx >nul
)
:SkipOCR

:: ================================
:: CONTINUAÇÃO DO SCRIPT ORIGINAL
:: ================================

SET SERVER_NAME=localhost
SET USER_NAME=sa
SET PASSWORD=F3N0Xfnx
SET DATABASE_NAME=SisviWcfLocal
SET BACKUP_DIR=C:\captura\BackupDB
SET BACKUP_PATH=%BACKUP_DIR%\SisviWcfLocal_backup.bak

:: Defina o nome do computador
set "COMPUTADOR=%COMPUTERNAME%"

:: URL do Web App do Google Apps Script
set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbw3OVNmpxJ9RXKF7YwkqrfcNoAL2-crg_R6WSmClJeMw-Vrw4gegc-lYB-l-xi3ZJpu/exec"

:: Arquivo temporário para armazenar os dados
set "TEMP_FILE=%TEMP%\disk_info.txt"
set "RESPONSE_FILE=%TEMP%\response.txt"
set "JSON_FILE=%TEMP%\json_payload.txt"

:: Caminho para o arquivo de configuração do AnyDesk
set "ANYDESK_CONFIG=%appdata%\AnyDesk\system.conf"

:: Extrair o ID do AnyDesk
set "ANYDESK_ID="
for /f "tokens=2 delims==" %%I in ('findstr /i "ad.anynet.id" "%ANYDESK_CONFIG%"') do (
    set "ANYDESK_ID=%%I"
)
set "ANYDESK_ID=!ANYDESK_ID: =!"
set "ANYDESK_ID=!ANYDESK_ID:\t=!"
set "ANYDESK_ID=!ANYDESK_ID:^"=!"

:: Coletar informações de espaço em disco
wmic logicaldisk get caption,freespace,size /format:csv > "%TEMP_FILE%"

:: Coletar informações da CPU
set "CPU="
for /f "skip=1 tokens=2 delims=," %%A in ('wmic cpu get name /format:csv') do (
    set "CPU=%%A"
)
set "CPU=!CPU: =!"
set "CPU=!CPU:\t=!"
set "CPU=!CPU:^"=!"
for /f "tokens=1 delims=@" %%B in ("!CPU!") do (
    set "CPU=%%B"
)

:: Data de instalação do Windows
for /f "skip=1 tokens=2 delims==" %%A in ('wmic os get installdate /format:list') do set "INSTALL_DATE=%%A"
set "INSTALL_DATE=!INSTALL_DATE:~6,2!/!INSTALL_DATE:~4,2!/!INSTALL_DATE:~0,4!"

:: RAM total
for /f "skip=1 tokens=2 delims=," %%A in ('wmic ComputerSystem get TotalPhysicalMemory /format:csv') do set "RAM=%%A"
set /a "RAM=!RAM:~0,-6!"

:: === Obter versões dos arquivos ===
call :getFileVersion "C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe" v1
call :getFileVersion "C:\WCFLOCAL\bin\PrototipoMQ.Interface.WCF.dll" wcf
call :getFileVersion "C:\Program Files (x86)\FNX\SisAviCreator\SisAviCreator.exe" creator
call :getFileVersion "C:\Program Files (x86)\FNX\SisMonitorOffline\SisMonitorOffline.exe" monitor
call :getFileVersion "C:\Program Files (x86)\FNX\SisOcr Offline\SisOCR.Offline.Service.exe" ocr

:: Processar o arquivo e enviar os dados ao Google Sheets
for /f "skip=1 tokens=2-4 delims=," %%A in ('type "%TEMP_FILE%"') do (
    set "DRIVE=%%A"
    set "FREE=%%B"
    set "SIZE=%%C"
    set "DRIVE=!DRIVE: =!"
    set "FREE=!FREE: =!"
    set "SIZE=!SIZE: =!"
    set /a "TOTAL=!SIZE:~0,-9!"
    set /a "LIVRE=!FREE:~0,-9!"
    if !TOTAL! gtr 0 (
        set /a "PERCENTUAL=(LIVRE*100)/TOTAL"
    ) else (
        set "PERCENTUAL=0"
    )

    :: Montar JSON
    echo { > "%JSON_FILE%"
    echo   "computador": "!COMPUTADOR!", >> "%JSON_FILE%"
    echo   "unidade": "!DRIVE!", >> "%JSON_FILE%"
    echo   "espaco_total": !TOTAL!, >> "%JSON_FILE%"
    echo   "espaco_livre": !LIVRE!, >> "%JSON_FILE%"
    echo   "porcentagem_livre": !PERCENTUAL!, >> "%JSON_FILE%"
    echo   "cpu": "!CPU!", >> "%JSON_FILE%"
    echo   "instwin": "!INSTALL_DATE!", >> "%JSON_FILE%"
    echo   "ram": !RAM!, >> "%JSON_FILE%"
    echo   "anydesk": "!ANYDESK_ID!", >> "%JSON_FILE%"
    echo   "v1": "!v1!", >> "%JSON_FILE%"
    echo   "wcf": "!wcf!", >> "%JSON_FILE%"
    echo   "creator": "!creator!", >> "%JSON_FILE%"
    echo   "monitor": "!monitor!", >> "%JSON_FILE%"
    echo   "ocr": "!ocr!" >> "%JSON_FILE%"
    echo } >> "%JSON_FILE%"

    echo Enviando:
    type "%JSON_FILE%"
    curl --ssl-no-revoke -X POST -H "Content-Type: application/json" -d "@%JSON_FILE%" "%URL_WEB_APP%" > "%RESPONSE_FILE%" 2>nul
    echo === RESPOSTA DO SERVIDOR ===
    type "%RESPONSE_FILE%"
    echo =============================
)

:: Backup do banco
IF NOT EXIST "%BACKUP_DIR%" (
    MKDIR "%BACKUP_DIR%" >nul
)
IF EXIST "%BACKUP_PATH%" (
    DEL /Q "%BACKUP_PATH%" >nul
)
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -Q "BACKUP DATABASE [%DATABASE_NAME%] TO DISK = '%BACKUP_PATH%' WITH FORMAT;"

:: Função para obter versão de arquivos
:getFileVersion
set "version="
set "filepath=%~1"
set "outvar=%~2"
set "escapedpath=%filepath:\=\\%"
for /f "skip=1 delims=" %%v in ('wmic datafile where "name='%escapedpath%'" get Version ^| findstr /r /v "^$"') do (
    set "version=%%v"
)
set "version=!version: =!"
set "version=!version:\t=!"
set "version=!version:^"=!"
set "version=!version:`=!"
set "version=!version:~0,30!"
for /f "delims=" %%a in ("!version!") do set "version=%%a"
set "%outvar%=!version!"
exit /b

:: Limpar arquivos temporários
del "%TEMP_FILE%"
del "%RESPONSE_FILE%"
del "%JSON_FILE%"
