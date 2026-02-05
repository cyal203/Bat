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
:: =======================
:: ------27/01/2026-------
:: =======================
::
	chcp 1252 >nul
	setlocal enabledelayedexpansion
	for /f %%H in ('hostname') do set "HOSTNAME=%%H"
:: --- lista de hostnames que devem executar os comandos do "else" ---
	set "EXCLUDE=0"
	for %%A in (FENOX274 FENOX279 FENOX197 FENOX298 FENOX418DIGITAC FENOX559DIG) do (
    if /I "%%A"=="%HOSTNAME%" set "EXCLUDE=1"
)
	rem --- prioridade 1: hostname está na lista de exclusão ---
	if "%EXCLUDE%"=="1" (
    goto :DO_ELSE
)
::prioridade 2: hostname começa com FENOX → segue a rotina normal ---
	echo %HOSTNAME% | findstr /B /I "FENOX" >nul
	if %errorlevel% equ 0 (
    call :CONTINUE
    exit /b 0
)
	rem --- prioridade 3: qualquer outro hostname cai no ELSE ---
:DO_ELSE
	schtasks /Query /TN "Monitorar_HD" >nul 2>&1 && schtasks /Delete /TN "Monitorar_HD" /F >nul
	schtasks /Query /TN "MONITOR_INICIALIZAR" >nul 2>&1 && schtasks /Delete /TN "MONITOR_INICIALIZAR" /F >nul
	schtasks /Query /TN "IISRESET" >nul 2>&1 && schtasks /Delete /TN "IISRESET" /F >nul
	powershell -Command "Get-ChildItem -Path \"%TEMP%\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"
	exit /b 0
:CONTINUE
::============
::iisreset
::============
	iisreset /restart
	powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe'"
	powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Fenox V1.0\SisFnxUpdate.exe'"
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
	powershell -Command "'Node,Caption,FreeSpace,Size' | Out-File \"%TEMP_FILE%\" -Encoding UTF8; Get-WmiObject Win32_LogicalDisk -Filter \"FileSystem='NTFS'\" | ForEach-Object { '{0},{1},{2},{3}' -f $env:COMPUTERNAME, $_.Caption, $_.FreeSpace, $_.Size } | Add-Content \"%TEMP_FILE%\" -Encoding UTF8"
	
	::wmic logicaldisk where "FileSystem='NTFS'" get caption,freespace,size /format:csv > "%TEMP_FILE%"

:: Coletar informações da CPU
::	set "CPU="
::	for /f "skip=1 tokens=2 delims=," %%A in ('wmic cpu get name /format:csv') do (
::    set "CPU=%%A"
::)
::	set "CPU=!CPU: =!"
::	set "CPU=!CPU:\t=!"
::	set "CPU=!CPU:^"=!"
::	for /f "tokens=1 delims=@" %%B in ("!CPU!") do (
::    set "CPU=%%B"
::)

for /f "delims=" %%A in ('powershell -Command "(Get-WmiObject Win32_Processor).Name.Trim() -replace '@.*'"') do (
    set "CPU=%%A"
)


:: Data de instalação do Windows
	::for /f "skip=1 tokens=2 delims==" %%A in ('wmic os get installdate /format:list') do set "INSTALL_DATE=%%A"
	::set "INSTALL_DATE=!INSTALL_DATE:~6,2!/!INSTALL_DATE:~4,2!/!INSTALL_DATE:~0,4!"

::Usando ParseExact
for /f "delims=" %%A in ('powershell -Command "[DateTime]::ParseExact((Get-WmiObject Win32_OperatingSystem).InstallDate.Substring(0, 14), \"yyyyMMddHHmmss\", $null).ToString(\"dd/MM/yyyy\")"') do (
    set "INSTALL_DATE=%%A"
)

echo Data de instalacao: %INSTALL_DATE%

::Manipulação direta
for /f "delims=" %%A in ('powershell -Command "$id = (Get-WmiObject Win32_OperatingSystem).InstallDate; \"{2}/{1}/{0}\" -f $id.Substring(0,4), $id.Substring(4,2), $id.Substring(6,2)"') do (
    set "INSTALL_DATE_DIRETA=%%A"
)

:: RAM total
	::for /f "skip=1 tokens=2 delims=," %%A in ('wmic ComputerSystem get TotalPhysicalMemory /format:csv') do set "RAM=%%A"
	::set /a "RAM=!RAM:~0,-6!"


for /f "delims=" %%A in ('powershell -Command "[math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)"') do (
    set "RAM=%%A"
)

::CONTA MP4
	set "RAIZ=C:\captura\Repositorio"
	set "MP4=0"

	for /r "%RAIZ%" %%A in (*.mp4) do (
    set "ARQ=%%~nxA"
    set "DIRETORIO=%%~dpA"
    echo !DIRETORIO! | findstr /i "\\2024\\ \\2025\\ \\2026\\ \\2027\\" >nul
    if errorlevel 1 (
        echo !ARQ! | findstr /i "mptemp.mp4" >nul
        if errorlevel 1 (
            set /a MP4+=1
        )
    )
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
	sc stop SisOcrOffline >nul 2>&1
	sc stop SisAviCreator >nul 2>&1
	sc stop SisMonitorOffline >nul 2>&1
	sc stop MMFnx >nul 2>&1
	timeout /t 3 >nul
	taskkill /IM SisAviCreator.exe /F >nul 2>&1
	taskkill /IM SisMonitorOffline.exe /F >nul 2>&1
	taskkill /IM SSisOCR.Offline.Service.exe /F >nul 2>&1
	timeout /t 2 /nobreak >nul
	sc start SisOcrOffline >nul 2>&1
	sc start SisAviCreator >nul 2>&1
	sc start SisMonitorOffline >nul 2>&1
	sc start MMFnx >nul 2>&1
	iisreset /restart
	goto :eof

