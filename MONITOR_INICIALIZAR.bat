@echo off
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
:: MONITOR_INICIALIZAR.bat - Auto-executa em modo oculto
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
:: ------22/08/2025-------
:: ======================
	chcp 1252 >nul
	setlocal enabledelayedexpansion
	
for /f %%H in ('hostname') do set "HOSTNAME=%%H"
echo %HOSTNAME% | findstr /B /I "FENOX" >nul
if %errorlevel% equ 0 (

call :CONTINUE
) else (
    schtasks /Query /TN "Monitorar_HD" >nul 2>&1 && schtasks /Delete /TN "Monitorar_HD" /F >nul
	schtasks /Query /TN "MONITOR_INICIALIZAR" >nul 2>&1 && schtasks /Delete /TN "MONITOR_INICIALIZAR" /F >nul
	schtasks /Query /TN "IISRESET" >nul 2>&1 && schtasks /Delete /TN "IISRESET" /F >nul
)
	
:CONTINUE
	set "COMPUTADOR=%COMPUTERNAME%"
	set "TEMP_IP=%TEMP%\IPLISTEN.txt"
:: URL do Web App do Google Apps Script
::set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbw3OVNmpxJ9RXKF7YwkqrfcNoAL2-crg_R6WSmClJeMw-Vrw4gegc-lYB-l-xi3ZJpu/exec"
set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbzIrQlZDQowLdEjQO1-zt3LLLiSpT2nkOkAl9qMkdywGS1YKV7a_TgZchOPyHAoXDvk/exec"
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

:: Contar arquivos .mp4
	set "PASTA=C:\captura\Repositorio\PANORAMICA01"
	set "MP4=0"
	for %%A in ("%PASTA%\*.mp4") do (
		set /a MP4+=1
	)	
	
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
    echo   "ocr": "!ocr!", >> "%JSON_FILE%"
	echo   "mp4": "!MP4!" >> "%JSON_FILE%"
    echo } >> "%JSON_FILE%"

    echo Enviando:
    type "%JSON_FILE%"
    curl --ssl-no-revoke -X POST -H "Content-Type: application/json" -d "@%JSON_FILE%" "%URL_WEB_APP%" > "%RESPONSE_FILE%" 2>nul
    echo === RESPOSTA DO SERVIDOR ===
    type "%RESPONSE_FILE%"
    echo =============================
)
	call :iplisten
	call :IPV1
	call :IIS
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
	for /f %%i in ('powershell -command "(Get-Date).AddDays(-90).ToString('yyyy-MM-dd')"') do set "ioscdata=%%i"
	powershell.exe -Command "$limite=Get-Date '%ioscdata%'; $pasta='C:\captura\iosc'; Get-ChildItem -Path $pasta -Force | Where-Object {($_.Attributes -match 'Hidden') -and ($_.LastWriteTime -lt $limite)} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
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
:IIS
	IISRESET
	sc stop SisOcrOffline >nul
	sc stop SisAviCreator >nul
	sc stop SisMonitorOffline >nul
	sc stop MMFnx >nul
	timeout /t 2 /nobreak >nul
	sc start SisOcrOffline >nul
	sc start SisAviCreator >nul
	sc start SisMonitorOffline >nul
	sc start MMFnx >nul
	goto :eof
