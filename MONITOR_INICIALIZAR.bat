@echo off
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
if "%1"=="/hidden" goto :MONITOR
(
  echo Set objShell = CreateObject("WScript.Shell"^)
  echo objShell.Run "cmd /c ""%~f0"" /hidden", 0, True
  echo WScript.Quit(0^)
) > "%temp%\runhidden.vbs"
	start "" /B wscript "%temp%\runhidden.vbs"
	exit /b

:MONITOR
:: =======================
:: ------14/04/2026-------
:: =======================

	setlocal enabledelayedexpansion
	for /f %%H in ('hostname') do set "HOSTNAME=%%H"
::LISTA DE HOSTNAMES QUE DEVEM EXECUTAR OS COMANDOS DO "ELSE"
	set "EXCLUDE=0"
	for %%A in (FENOX274 FENOX279 FENOX197 FENOX298 FENOX418DIGITAC FENOX559DIG) do (
    if /I "%%A"=="%HOSTNAME%" set "EXCLUDE=1"
)
::PRIORIDADE 1: HOSTNAME ESTÁ NA LISTA DE EXCLUSÃO
	if "%EXCLUDE%"=="1" (
    goto :DO_ELSE
)
::PRIORIDADE 2: HOSTNAME COMEÇA COM FENOX → SEGUE A ROTINA NORMAL
	echo %HOSTNAME% | findstr /B /I "FENOX" >nul
	if %errorlevel% equ 0 (
    call :CONTINUE
    exit /b 0
)
::PRIORIDADE 3: QUALQUER OUTRO HOSTNAME CAI NO ELSE
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
	set "COMPUTADOR=%COMPUTERNAME%"
:: URL DO WEB APP DO GOOGLE APPS SCRIPT
	set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbzIrQlZDQowLdEjQO1-zt3LLLiSpT2nkOkAl9qMkdywGS1YKV7a_TgZchOPyHAoXDvk/exec"
:: ARQUIVO TEMPORÁRIO PARA ARMAZENAR OS DADOS
	set "TEMP_FILE=%TEMP%\disk_info.txt"
	set "RESPONSE_FILE=%TEMP%\response.txt"
	set "JSON_FILE=%TEMP%\json_payload.txt"
	set "ANYDESK_CONFIG=%appdata%\AnyDesk\system.conf"
:: EXTRAIR O ID DO ANYDESK
	set "ANYDESK_ID="
	if exist "%ANYDESK_CONFIG%" (
    for /f "tokens=2 delims==" %%I in ('findstr /i "ad.anynet.id" "%ANYDESK_CONFIG%"') do (
        set "ANYDESK_ID=%%I"
    )
)
	if defined ANYDESK_ID (
    set "ANYDESK_ID=!ANYDESK_ID: =!"
    set "ANYDESK_ID=!ANYDESK_ID:    =!"
    set "ANYDESK_ID=!ANYDESK_ID:^"=!"
) else (
    set "ANYDESK_ID=N/A"
)
:: COLETAR INFORMAÇÕES DE ESPAÇO EM DISCO
	powershell -Command "'Node,Caption,FreeSpace,Size' | Out-File \"%TEMP_FILE%\" -Encoding UTF8; Get-WmiObject Win32_LogicalDisk -Filter \"FileSystem='NTFS'\" | ForEach-Object { '{0},{1},{2},{3}' -f $env:COMPUTERNAME, $_.Caption, $_.FreeSpace, $_.Size } | Add-Content \"%TEMP_FILE%\" -Encoding UTF8"
::COLETAR INFORMAÇÕES DA CPU
	set "CPU="
	for /f "delims=" %%A in ('powershell -Command "(Get-WmiObject Win32_Processor).Name.Trim() -replace '@.*'"') do (
    set "CPU=%%A"
)
:: DATA DE INSTALAÇÃO DO WINDOWS
	set "INSTALL_DATE="
	for /f "delims=" %%A in ('powershell -Command "[DateTime]::ParseExact((Get-WmiObject Win32_OperatingSystem).InstallDate.Substring(0, 14), \"yyyyMMddHHmmss\", $null).ToString(\"dd/MM/yyyy\")"') do (
    set "INSTALL_DATE=%%A"
)

:: RAM TOTAL
	set "RAM="
	for /f "delims=" %%A in ('powershell -Command "[math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)"') do (
    set "RAM=%%A"
)

::CONTA MP4
	set "RAIZ=C:\captura\Repositorio"
	set "MP4=0"
	if exist "%RAIZ%" (
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
)

::OBTER VERSÕES DOS ARQUIVOS
	call :VERSAOARQUIVO "C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe" v1
	call :VERSAOARQUIVO "C:\WCFLOCAL\bin\PrototipoMQ.Interface.WCF.dll" wcf
	call :VERSAOARQUIVO "C:\Program Files (x86)\FNX\SisAviCreator\SisAviCreator.exe" creator
	call :VERSAOARQUIVO "C:\Program Files (x86)\FNX\SisMonitorOffline\SisMonitorOffline.exe" monitor
	call :VERSAOARQUIVO "C:\Program Files (x86)\FNX\SisOcr Offline\SisOCR.Offline.Service.exe" ocr

:: PROCESSAR O ARQUIVO E ENVIAR OS DADOS AO GOOGLE SHEETS
	if exist "%TEMP_FILE%" (
    for /f "skip=1 tokens=2-4 delims=," %%A in ('type "%TEMP_FILE%"') do (
        set "DRIVE=%%A"
        set "FREE=%%B"
        set "SIZE=%%C"
        set "DRIVE=!DRIVE: =!"
        set "FREE=!FREE: =!"
        set "SIZE=!SIZE: =!"
        
        if defined SIZE (
            set /a "TOTAL=!SIZE:~0,-9!" 2>nul
        ) else (
            set "TOTAL=0"
        )
        
        if defined FREE (
            set /a "LIVRE=!FREE:~0,-9!" 2>nul
        ) else (
            set "LIVRE=0"
        )
        
        if !TOTAL! gtr 0 (
            set /a "PERCENTUAL=(LIVRE*100)/TOTAL" 2>nul
        ) else (
            set "PERCENTUAL=0"
        )

::MONTAR JSON
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
        if exist "%RESPONSE_FILE%" (
            type "%RESPONSE_FILE%"
        ) else (
            echo Nenhuma resposta recebida
        )
        echo =============================
    )
) else (
    echo Arquivo temporario nao encontrado: %TEMP_FILE%
)
	call :LIMPEZA
exit /b

::========================================
::         FUNÇOES ADICIONAIS
::========================================

:VERSAOARQUIVO
    setlocal EnableDelayedExpansion

    set "version="
    set "filepath=%~1"
    set "outvar=%~2"

::TRATAMENTO DE CAMINHO
    set "escapedpath=%filepath:\=\\%"

::CHAMA O POWERSHELL PARA OBTER SOMENTE NÚMEROS E PONTOS
    for /f "usebackq tokens=*" %%v in (
        `powershell -NoProfile -Command ^
            "(Get-Item '%escapedpath%').VersionInfo.FileVersion -replace '[^0-9\.]', ''"`
    ) do (
        set "version=%%v"
    )

::GARANTE TRIMMING (SEM ESPAÇOS)
    for /f "delims=" %%a in ("!version!") do set "version=%%a"

    endlocal & set "%outvar%=%version%"

    exit /b

:LIMPEZA
	powershell -Command "Get-ChildItem -Path \"%TEMP%\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"
	exit /b
