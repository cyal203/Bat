@echo off
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:: MONITOR_HD.bat - Auto-executa em modo oculto
:: Verifica se já está rodando oculto (parâmetro /hidden)
if "%1"=="/hidden" goto :MONITOR

:: Se não estiver oculto, prepara a execução oculta
(
  echo Set objShell = CreateObject("WScript.Shell"^)
  echo objShell.Run "cmd /c ""%~f0"" /hidden", 0, True
  echo WScript.Quit(0^)
) > "%temp%\runhidden.vbs"

:: Executa o VBS e fecha esta instância visível
start "" /B wscript "%temp%\runhidden.vbs"
exit

:MONITOR
:: ======================
:: ------27/05/2025------
:: ======================
	chcp 1252 >nul
	setlocal enabledelayedexpansion
	set "sis_ocr=7.4.0.0"
	set "sis_monitor=7.1.3.1"
	set "sis_creator=12.1.4.00"
	set "TEMP_IP=%TEMP%\IPLISTEN.txt"
::==============================================
:: Adicione aqui hosts que não atualizarão a OCR
::==============================================
	set "excludedHostsocr=FENOX33 FENOX34 FENOX31 FENOX117 FENOX40 FENOX128 FENOX023 FENOX54 FENOX85 FENOX27"
::==================================================
:: Adicione aqui hosts que não atualizarão o Monitor
::==================================================
	set "excludedHostsmonitor="
::==================================================
:: Adicione aqui hosts que não atualizarão o creator
::==================================================
	set "excludedHostscreator="
:: =====================================
:: Verificar versão do SisMonitorOffline
:: =====================================
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
::BAIXA A NOVA VERSÃO MONITOR
	echo Efetuando Download... >> %logFile% 2>&1
	curl -g -k -L -# -o "%temp%\SisMonitor7131.zip" "https://update.fenoxapp.com.br/Instaladores/Monitor/SisMonitor7131.zip" >nul 2>&1
	powershell -NoProfile Expand-Archive '%temp%\SisMonitor7131.zip' -DestinationPath 'C:\SisMonitorOffline' >nul 2>&1
::MODE OS ARQUIVOS
	echo Movendo arquivos baixados... >> %logFile% 2>&1
	robocopy "C:\SisMonitorOffline" "C:\Program Files (x86)\FNX\SisMonitorOffline" /E /MOVE /R:3 /W:5 >> %logFile% 2>&1
::INICIA OS PROCESSOS
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
:: CONTINUAÇÃO DO SCRIPT
:: ================================
:: ADICIONA A ROTINA DE RESET DOS SERVIÇOS
	schtasks /Create /TN "IISRESET" /TR "cmd.exe /c iisreset & sc stop SisOcrOffline & timeout /t 2 >nul & sc start SisOcrOffline & sc stop SisMonitorOffline & timeout /t 2 >nul & sc start SisMonitorOffline & sc stop SisAviCreator & timeout /t 2 >nul & sc start SisAviCreator" /SC DAILY /ST 07:00 /F /RL HIGHEST >nul
	::schtasks /Create /TN "IISRESET_INICIALIZACAO" /TR "cmd.exe /c iisreset & sc stop SisOcrOffline & timeout /t 2 >nul & sc start SisOcrOffline & sc stop SisMonitorOffline & timeout /t 2 >nul & sc start SisMonitorOffline & sc stop SisAviCreator & timeout /t 2 >nul & sc start SisAviCreator" /SC ONSTART /DELAY 0003:00 /F /RL HIGHEST >nul
	schtasks /Query /TN "IISRESET_INICIALIZACAO" >nul 2>&1 && schtasks /Delete /TN "IISRESET_INICIALIZACAO" /F >nul && echo Tarefa deletada. || echo Tarefa inexistente.	
	SCHTASKS /CREATE /TN "MONITOR_INICIALIZAR" /TR "cmd.exe /c curl -g -k -L -# -o \"%%temp%%\MONITOR_INICIALIZAR.bat\" \"https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MONITOR_INICIALIZAR.bat\" && \"%%temp%%\MONITOR_INICIALIZAR.bat\"" /SC ONSTART /DELAY 0000:30 /F /RL HIGHEST
	call :iplisten

:: =============================================
:: CONFIGURAÇÕES DO BANCO DE DADOS
:: =============================================
	set "SQL_SERVER=localhost"
	set "SQL_DB=SisviWcfLocal"
	set "BACKUP_DIR=C:\captura\BackupDB"
	icacls "%BACKUP_DIR%" /grant "NT SERVICE\MSSQLSERVER":(OI)(CI)F >nul 2>&1
	for /f "tokens=1-3 delims=/ " %%a in ("%date%") do (
    set "day=%%a"
    set "month=%%b"
    set "year=%%c"
)
:: Formatar com dois dígitos
	if "!day:~1!"=="" set "day=0!day!"
	if "!month:~1!"=="" set "month=0!month!"
	set "BACKUP_FILE=!BACKUP_DIR!\SisviWcfLocal_backup_!day!_!month!_!year!.bak"
	set "COMPUTADOR=%COMPUTERNAME%"
:: URL do Web App do Google Apps Script
	set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbw3OVNmpxJ9RXKF7YwkqrfcNoAL2-crg_R6WSmClJeMw-Vrw4gegc-lYB-l-xi3ZJpu/exec"
:: Arquivo temporário para armazenar os dados
	set "TEMP_FILE=%TEMP%\disk_info.txt"
	set "RESPONSE_FILE=%TEMP%\response.txt"
	set "JSON_FILE=%TEMP%\json_payload.txt"
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
	wmic logicaldisk where "FileSystem='NTFS'" get caption,freespace,size /format:csv > "%TEMP_FILE%"
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

:: =============================================
:: COMANDO DE BACKUP SQL
:: =============================================

:: Configurações do SQL Server
set "SQL_SERVER=localhost"
set "SQL_DB=SisviWcfLocal"
set "B64_USER=c2E="
set "B64_PASS=RjNOMFhmbng="
set "BACKUP_DIR=C:\captura\BackupDB"

	for /f "delims=" %%A in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_USER%')).Trim()"') do (
    set "SQL_USER=%%A"
)
	for /f "delims=" %%B in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_PASS%')).Trim()"') do (
    set "SQL_PASS=%%B"
)

:: Garante permissão para o SQL Server gravar na pasta
icacls "%BACKUP_DIR%" /grant "NT SERVICE\MSSQLSERVER":(OI)(CI)F >nul 2>&1

:: Obtém data e hora no formato YYYYMMDD_HHMMSS
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "datetime=%%G"
set "backup_timestamp=%datetime:~6,2%_%datetime:~4,2%_%datetime:~0,4%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"

:: Define o nome do arquivo de backup
set "BACKUP_FILE=%BACKUP_DIR%\%SQL_DB%_%backup_timestamp%.bak"

:: Executa o backup
echo Realizando backup de %SQL_DB% para %BACKUP_FILE%...
sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "BACKUP DATABASE [%SQL_DB%] TO DISK='%BACKUP_FILE%' WITH FORMAT;"

if %errorlevel% equ 0 (
    echo Backup concluido com sucesso!
) else (
    echo Falha no backup. Verifique as credenciais e permissões.
)
	call :IPV1
	call :LIMPEZAA
::==========================
::         FUNÇOES
::==========================
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

:LIMPEZAA
::APAGA ARQUVOS IOSC E MANTEM APENAS DE 90 DIAS ANTERIORES
	for /f %%i in ('powershell -command "(Get-Date).AddDays(-90).ToString('yyyy-MM-dd')"') do set "ioscdata=%%i"
	powershell.exe -Command "$limite=Get-Date '%ioscdata%'; $pasta='C:\captura\iosc'; Get-ChildItem -Path $pasta -Force | Where-Object {($_.Attributes -match 'Hidden') -and ($_.LastWriteTime -lt $limite)} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
	for /f %%i in ('powershell -command "(Get-Date).AddDays(-5).ToString('yyyy-MM-dd')"') do set "C:\captura\BackupDB=%%i"
	
	set "pasta=C:\captura\BackupDB"
	set "dias=5"

:: Verifica se a pasta existe
	if not exist "%pasta%" (
    echo A pasta "%pasta%" não existe.
    pause
    exit /b
)

	powershell.exe -Command ^
    "$dias = %dias%;" ^
    "$pasta = '%pasta%';" ^
    "$limite = (Get-Date).AddDays(-$dias);" ^
    "Get-ChildItem -Path $pasta -File -Force |" ^
    "Where-Object { $_.LastWriteTime -lt $limite } |" ^
    "Remove-Item -Force -ErrorAction SilentlyContinue;"
	
	powershell -Command "Get-ChildItem -Path \"%TEMP%\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"
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
