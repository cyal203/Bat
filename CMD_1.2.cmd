@echo off
chcp 65001 >nul
title Versão 1.7.2
::==========================
::------03-09-2025----------
::==========================
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	if "%Admin%"=="ops" goto :eof
	mode con: cols=50 lines=20
	setlocal enabledelayedexpansion
	set "params=%*"
::branco
	set w=[97m
::ciano
	set b=[96m
::green
	set g=[92m
:: =============================================
:: CREDENCIAIS SQL
:: =============================================
	set "B64_USER=c2E="
	set "B64_PASS=RjNOMFhmbng="
	for /f "delims=" %%A in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_USER%')).Trim()"') do (
    set "SQL_USER=%%A"
)
	for /f "delims=" %%B in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_PASS%')).Trim()"') do (
    set "SQL_PASS=%%B"
)
:: =============================================
:: COMANDO DE BACKUP SQL
:: =============================================
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
:: Obtém data e hora
    for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "datetime=%%G"
    set "backup_timestamp=%datetime:~6,2%_%datetime:~4,2%_%datetime:~0,4%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"
:: Define o nome do arquivo de backup
    set "BACKUP_FILE=%BACKUP_DIR%\%SQL_DB%_%backup_timestamp%.bak"
:: Define Diretorio IPLISTEN
    set "TEMP_IP=%TEMP%\IPLISTEN.txt"
    set passos=34
    setlocal
	%B%
    cls
    for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")
    Reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
    (for /f %%a in ('echo prompt $E^| cmd') do set "esc=%%a" )
::Ativar modo de cursor invisível
    echo !esc![?25l

:INICIO
	echo.
	echo   ███████╗███████╗███╗   ██╗   █████╗ ██╗   ██╗
	echo   ██╔════╝██╔════╝████╗  ██║ ██╔═══██║ ██║ ██╔╝
	echo   ███████╗█████╗  ██╔██╗ ██║ ██║   ██║   ██╔╝
	echo   ██╔════╝██╔══╝  ██║╚██╗██║ ██║   ██║ ██╔═██╗
	echo   ██║     ███████╗██║ ╚████║ ╚██████╔╝██║   ██╗
	echo   ╚═╝     ╚══════╝╚═╝  ╚═══╝  ╚═════╝ ╚═╝   ╚═╝
	echo.
	echo              SELECIONE UMA OPCAO:
	echo.   
	echo      [%w%1%b%]%w% OTIMIZACAO%b%     [%w%2%b%]%w% ADD IPLISTEN%b%     
	echo.                 
	echo      [%w%3%b%]%w% ATT SERVICOS%b%   [%w%4%b%]%w% PROGRAMAS UTEIS%b%
	echo.
	echo      [%w%5%b%]%w% HD 100%b%
	echo.
	echo.
	Set /p option= %w%     Escolha uma Opcao:%b%

	if %option%==1 goto otimizacao
	if %option%==2 goto iplisten
	if %option%==3 goto atualiza_servicos
	if %option%==4 goto programas_uteis
	if %option%==5 goto hd100
	if %option%==10 goto atualizadorv1
	if %option%==x goto atualizadormanual
	echo.
	cls
	echo   ═════════════════════════════════════
	echo   ███  %w%OTIMIZANDO AGUARDE. . . .%b%    ███
	echo   ═════════════════════════════════════
:otimizacao
::=======================================================
:: ADICIONA O MONITORAMENTO NO SERVIDOR COM O HOST FENOX
::=======================================================
	for /f %%H in ('hostname') do set "HOSTNAME=%%H"
	echo %HOSTNAME% | findstr /B /I "FENOX" >nul
	if %errorlevel% equ 0 (
	SCHTASKS /CREATE /TN "Monitorar_HD" /TR "cmd.exe /c curl -g -k -L -# -o \"%%temp%%\MONITOR_HD.bat\" \"https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MONITOR_HD.bat\" >nul 2>&1 && %%temp%%\MONITOR_HD.bat" /SC DAILY /ST 05:15 /F /RL HIGHEST >nul
	SCHTASKS /CREATE /TN "MONITOR_INICIALIZAR" /TR "cmd.exe /c curl -g -k -L -# -o \"%%temp%%\MONITOR_INICIALIZAR.bat\" \"https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MONITOR_INICIALIZAR.bat\" && \"%%temp%%\MONITOR_INICIALIZAR.bat\"" /SC ONSTART /DELAY 0000:30 /F /RL HIGHEST
:: =============================================
:: COMANDO DE BACKUP SQL
:: =============================================
	IF NOT EXIST "%BACKUP_DIR%" (
    MKDIR "%BACKUP_DIR%" >nul
)
	echo Executando backup de %SQL_DB%...
	sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "BACKUP DATABASE [%SQL_DB%] TO DISK='%BACKUP_FILE%' WITH FORMAT;"
	if %errorlevel% equ 0 (
    echo Backup concluído com sucesso: %BACKUP_FILE%
) else (
    echo Falha no backup. Código de erro: %errorlevel%
    echo Verifique:
    echo 1. Serviço SQL Server está rodando
    echo 2. Credenciais estão corretas
    echo 3. Espaço suficiente em disco
)
	cls
:: Captura a saída do ipconfig e salva no arquivo temporário
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
	netsh http add iplisten ip=!CURRENT_IP!  >nul
	netsh http add iplisten ip=127.0.0.1  >nul
	ipconfig /flushdns  >nul
) else (
    echo Prosseguindo com o script.
)
	timeout /t 2 /nobreak >nul
::====================================================
:: PROSSEGUE COM O SCRIPT EM PC NÃO SERVIDOR
::====================================================
	call :ram
:continue
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	cls
	timeout /t 2 /nobreak >nul
	call :SAFE_EXECUTE 01 %passos% "taskkill /f /fi "status eq not responding""
	call :SHOW_PROGRESS 02 %passos%
	icacls "C:\Captura\StatusUpload" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&1
	icacls "C:\Captura\StatusServicos" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&1
	icacls "C:\Captura\SiteVerVideo" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&1
	icacls "C:\Captura\preview" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&10
	icacls "C:\Captura\ocr" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&1
	icacls "C:\Captura\Msg" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&1
	icacls "C:\Captura\Config" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&1
	icacls "C:\WCFLOCAL" /q /c /t /grant Todos:(OI)(CI)F >nul 2>&1
	icacls "C:\Program Files (x86)\FNX" /q /c /t /grant Todos:(OI)(CI)F >nul 2>&1
	icacls "C:\fnx" /q /c /t /grant Todos:(OI)(CI)F >nul 2>&1
	icacls "C:\Program Files (x86)\Fenox V1.0" /grant Todos:(OI)(CI)F /T /C /Q >nul 2>&1
	powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe'"
	powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Fenox V1.0\SisFnxUpdate.exe'"
::(continuação com SAFE_EXECUTE)
	call :SAFE_EXECUTE 03 %passos% "REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f"
	call :SAFE_EXECUTE 04 %passos% "netsh advfirewall set allprofiles state off"
	call :SAFE_EXECUTE 05 %passos% "netsh winsock reset"
	call :SAFE_EXECUTE 06 %passos% "gpupdate /force"
	call :SAFE_EXECUTE 07 %passos% "REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableLUA /T REG_DWORD /D 0 /F"
	call :SAFE_EXECUTE 08 %passos% "powercfg.exe /hibernate off"
	call :SAFE_EXECUTE 09 %passos% "REG add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f"
	call :SAFE_EXECUTE 10 %passos% "REG add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f"
	call :SAFE_EXECUTE 11 %passos% "powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e"
	call :SAFE_EXECUTE 12 %passos% "REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f"
	call :SAFE_EXECUTE 13 %passos% "sc stop "WSearch" & sc config "WSearch" start=disabled"
	call :SAFE_EXECUTE 14 %passos% "reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f"
	call :SAFE_EXECUTE 15 %passos% "sc config Fax start= disabled & sc config "Remote Desktop Services" start= disabled"
	call :SAFE_EXECUTE 16 %passos% "reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f"
	call :SAFE_EXECUTE 17 %passos% "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 8"
	call :SAFE_EXECUTE 18 %passos% "del C:\Windows\Logs\cbs\*.log"
	call :SAFE_EXECUTE 19 %passos% "for /d %%u in (C:\Users\*) do if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /M "data.*" /C "cmd /c del @path""
	call :SAFE_EXECUTE 20 %passos% "reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f"
	call :SAFE_EXECUTE 21 %passos% "REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /V BackgroundAppGlobalToggle /T REG_DWORD /D 0 /F"
	call :SAFE_EXECUTE 22 %passos% "powercfg /change standby-timeout-dc 0"
	call :SAFE_EXECUTE 23 %passos% "powercfg /change disk-timeout-ac 0"
	call :SAFE_EXECUTE 24 %passos% "sc stop "DiagTrack" & sc config "DiagTrack" start=disabled"
	call :SAFE_EXECUTE 25 %passos% "sc stop "dmwappushservice" & sc config "dmwappushservice" start=disabled"
	call :SAFE_EXECUTE 26 %passos% "sc stop "SysMain" & sc config "SysMain" start=disabled"
	call :SAFE_EXECUTE 27 %passos% "PowerShell.exe -NoProfile -Command Clear-RecycleBin -Confirm:$false"
	call :SAFE_EXECUTE 28 %passos% "del c:\$recycle.bin\* /s /q"
	call :SAFE_EXECUTE 29 %passos% "reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 90120000010000000000000000 /f"
	call :SAFE_EXECUTE 30 %passos% "reg add "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f"
	call :SAFE_EXECUTE 31 %passos% "reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f"
	call :SAFE_EXECUTE 32 %passos% "reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Fnx64bits.exe" /f"
	call :SAFE_EXECUTE 33 %passos% "reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Fnx64bits.exe" /v PerfOptions /f"
	call :SAFE_EXECUTE 34 %passos% "reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Fnx64bits.exe" /v CpuPriorityClass /t REG_DWORD /d 3 /f"

	call :CONCLUIDO
	schtasks /run /tn "Monitorar_HD"
	start cleanmgr.exe /d C: /VERYLOWDISK
	powershell -Command "Get-ChildItem -Path \"C:\Windows\Temp\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"
	del /s /f /q %SystemRoot%\Prefetch\*
	del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db"
	del /s /f /q C:\Windows\Temp\*
	powershell -Command "Get-ChildItem -Path \"%TEMP%\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"
	cls
	exit

:SAFE_EXECUTE
:: Executa comandos com tratamento de erros
	call :SHOW_PROGRESS %1 %2
	(%3) >nul 2>&1
	goto :EOF

:SHOW_PROGRESS
:: Mostra apenas a contagem de progresso
	cls
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%OTIMIZANDO (%1/%2)%b%      ███
	echo       ══════════════════════════════════
	timeout /t 1 >nul
	goto :EOF

:CONCLUIDO
	cls
	echo.
	echo   ═══════════════════════════════════
	echo   ███  %w%OTIMZACAO CONCLUIDA. . .%b%   ███
	echo   ═══════════════════════════════════
	timeout /t 1 >nul
	goto :EOF

:hd100
	cls
	echo   ═══════════════════════════════════
	echo   ███  %w%VERIFICANDO ARQUIVOS. . .%b%  ███
	echo   ═══════════════════════════════════
	sfc /scannow
	dism /online /cleanup-image /restorehealth
	Defrag C: /U
	exit

:atualizadorv1
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\ATUALIZADOR_ESTADOS.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/ATUALIZADOR_ESTADOS.bat" >nul 2>&1 && %temp%\ATUALIZADOR_ESTADOS.bat
	Exit

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
	cls
	netsh http add iplisten ip=!CURRENT_IP!  >nul
	netsh http add iplisten ip=127.0.0.1  >nul
	ipconfig /flushdns  >nul
	echo.
	echo.
	echo            ╔══════════════════════════╗
	echo            ║       Adicionado         ║
	echo            ║     ip ao Iplisten       ║
	echo            ║     %w% !CURRENT_IP! %b%     ║
	echo            ║       %w%127.0.0.1 %b%         ║
	echo            ╚══════════════════════════╝
	echo.
	echo              Pressione para voltar
	pause >nul
	cls
	goto inicio

:atualiza_servicos
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\ATUALIZA_SERVICOS.cmd" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/ATUALIZA_SERVICOS.cmd" >nul 2>&1 && %temp%\ATUALIZA_SERVICOS.cmd
	cls
	goto inicio

:programas_uteis
	cls
	echo.
	echo.
	echo            ╔══════════════════╗
	echo            ║ %g%PROGRAMAS UTEIS%b%  ║
	echo            ╚══════════════════╝
	echo.
	echo     [%w%1%b%]%w% IPUTILITY%b%     [%w%2%b%]%w% SEARCH_TOOLS%b%   
	echo.                 
	echo     [%w%3%b%]%w% TEAM_VIEWER%b%   [%w%4%b%]%w% VLC_2.2.6%b%
	echo.
	echo     [%w%5%b%]%w% FIDDLER%b%       [%w%6%b%]%w% LEITOR BIOMETRICO%b%
	echo.
	echo     [%w%7%b%]%w% CERTIFICADOS%b%  [%w%8%b%]%w% ADVANCED IP SCANN%b%
	echo.
	echo     [%w%9%b%]%w% NSI%b%
	echo.
	echo.
	Set /p option0= %w%    Escolha uma opcao:%b%

	if %option0%==1 goto IPUTILITY
	if %option0%==2 goto SEARCH_TOOLS
	if %option0%==3 goto TEAM_VIEWER
	if %option0%==4 goto VLC
	if %option0%==5 goto FIDDLER
	if %option0%==6 goto LEITOR_BIOMETRICO
	if %option0%==7 goto CERTIFICADOS
	if %option0%==8 goto ADVANCED
	if %option0%==9 goto NSI

:IPUTILITY
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (1/4)%b%      ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\IPUtilityNext.zip" "https://www.dropbox.com/scl/fi/wpq5qpy7yksxtwi1hv32b/General_IPUtilityNext.zip?rlkey=thm7blxtas6vjfxpmhye5nc53&st=f9eubz3o&dl=1" >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (2/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	powershell -NoProfile Expand-Archive '%temp%\IPUtilityNext.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (3/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	%temp%\Fenox\General_IPUtilityNext.exe /S
	start "" "C:\Program Files (x86)\IP Utility\IP Utility.exe"
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (4/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	cls
	goto inicio

:SEARCH_TOOLS
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (1/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\SearchTools.zip" "https://www.dropbox.com/scl/fi/gbrnllnz889mel362t8oj/SearchTools.zip?rlkey=v7ef76jrgdjmkkijolifd3yxa&st=fhrmi59a&dl=1" >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (2/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	powershell -NoProfile Expand-Archive '%temp%\SearchTools.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (3/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	%temp%\Fenox\SearchTools.exe /S
	start "" "C:\Program Files\NVClient_V5\SearchTools V2.exe"
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (4/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	cls
	goto inicio

:FIDDLER
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%DOWNLOAD (1/4)%b%          ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\FiddlerSetup.zip" "https://www.dropbox.com/scl/fi/hmt32gfgkaks8jm68fqkn/FiddlerSetup.zip?rlkey=l79nvjgugp02vxs07npbpr2hs&st=0zajwgzc&dl=1" >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%EXTRAINDO (2/4)%b%         ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	powershell -NoProfile Expand-Archive '%temp%\FiddlerSetup.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INICIANDO (3/4)%b%         ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	echo.
	echo Ajustar para Keep: 100 sessions
	%temp%\Fenox\"FiddlerSetup.exe"
	start "" "C:\Users\Fenox\AppData\Local\Programs\Fiddler\Fiddler.exe"

	cls
	goto inicio

:TEAM_VIEWER
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%DOWNLOAD (1/4)%b%          ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\TeamViewer_Setup_x64.zip" "https://www.dropbox.com/scl/fi/niirt87a7gdcsndeczcia/TeamViewer_Setup_x64.zip?rlkey=89doikznjy5fglkvcxwygvwbz&st=ub1gfw84&dl=1" >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%EXTRAINDO (2/4)%b%         ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	powershell -NoProfile Expand-Archive '%temp%\TeamViewer_Setup_x64.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INICIANDO (3/4)%b%         ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	%temp%\Fenox\"TeamViewer_Setup_x64.exe"
	cls
	goto inicio


:VLC
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (1/4)%b%      ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\VLC-2.2.6.exe.zip" "https://www.dropbox.com/scl/fi/tle009xzh9uuf9xnn5xof/VLC-2.2.6.exe.zip?rlkey=1wjimcl0jdz9ii9knfcvl2lxp&st=adqtqro6&dl=1" >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (2/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	powershell -NoProfile Expand-Archive '%temp%\VLC-2.2.6.exe.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (3/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	%temp%\Fenox\"VLC 2.2.6.exe" /S
	start "" "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (4/4)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	cls
	goto inicio
:NSI
	sc config winmgmt start= disabled
	net stop winmgmt /y
	%systemdrive%
	cd %windir%\system32\wbem
	for /f %%s in ('dir /b *.dll') do regsvr32 /s %%s
	wmiprvse /regserver
	winmgmt /regserver
	sc config winmgmt start= Auto
	net start winmgmt
	dir /b *.mof *.mfl | findstr /v /i uninstall > moflist.txt & for /F %%s in (moflist.txt) do mofcomp %%s 
	cls
	goto inicio

:LEITOR_BIOMETRICO
	cls
	echo.
	echo.
	echo       ════════════════════════════════
	echo       ███    %w%EFETUANDO DOWNLOAD %b%   ███
	echo       ════════════════════════════════
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\LEITOR_BIOMETRICO.zip" "https://www.dropbox.com/scl/fi/vkwaoojm2gpef0wbuky1s/LEITOR_BIOMETRICO.zip?rlkey=98n5937z1641k0wpx39ajwdif&st=5bt8looi&dl=1" >nul 2>&1
	powershell -NoProfile Expand-Archive '%temp%\LEITOR_BIOMETRICO.zip' -DestinationPath '%temp%\LEITOR_BIOMETRICO' >nul 2>&1
	cls
	echo.
	echo.
	echo       ════════════════════════════════
	echo       ███    %w%COPIANDO DLL %b%         ███
	echo       ════════════════════════════════
	timeout /t 3 /nobreak >nul
:: Copia as DLLs de System32
	xcopy /Y /V "%temp%\LEITOR_BIOMETRICO\System32\*.dll" "C:\Windows\System32\"
	if %errorlevel% neq 0 echo Falha ao copiar DLLs para System32.

:: Copia as DLLs de SysWOW64
	if exist "C:\Windows\SysWOW64" (
		xcopy /Y /V "%temp%\LEITOR_BIOMETRICO\SysWOW64\*.dll" "C:\Windows\SysWOW64\"
		if %errorlevel% neq 0 echo Falha ao copiar DLLs para SysWOW64.
	)

	cls
	echo.
	echo.
	echo       ══════════════════════════════
	echo       ███       %w%INSTALANDO %b%      ███
	echo       ══════════════════════════════
:: Instala o programa
	%temp%\LEITOR_BIOMETRICO\UBio_Hamster_DX_Driver_Setup.exe

:: Verifica se a instalação foi bem-sucedida
	if %errorlevel% neq 0 (
		echo Erro ao instalar o programa.
		exit /b %errorlevel%
	)
	cls
	cls
	echo %w%Processo concluido! %b%
	echo.
	echo Verifique se o %w%isolamento de Nucleo%b% foi desativado
	goto :inicio

:CERTIFICADOS

	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%DOWNLOAD (1/3)%b%          ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\CERTIFICADOS.zip" "https://www.dropbox.com/scl/fi/rd1uuwaz43zb5kfpmeozo/CERTIFICADOS.zip?rlkey=db4p3wv7q0mzqs20rzc6whtr5&st=4m2nu4tf&dl=1" >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INICIANDO (2/3)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	powershell -NoProfile Expand-Archive '%temp%\CERTIFICADOS.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (3/3)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	%temp%\Fenox\"SafeSignIC30124-x64-win-tu-admin.exe" /s /v/qb
	timeout /t 5 /nobreak >nul
	%temp%\Fenox\"GDsetupStarsignCUTx64.exe" /s
	timeout /t 5 /nobreak >nul
	%temp%\Fenox\"ePass2003-Setup_v1.1.16.330_32_64_Windows.exe" /s /v/qb
	timeout /t 5 /nobreak >nul
	%temp%\Fenox\"certisign10.6-x64-10.6 (1).exe" /s /v/qb
	timeout /t 5 /nobreak >nul
	cls
	goto inicio

:ADVANCED
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%DOWNLOAD (1/3)%b%          ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\Advanced_IP.zip" "https://www.dropbox.com/scl/fi/fchgwfft5d8rv97tqoizf/Advanced_IP.zip?rlkey=3myzaqs8zd8ltyyqc3i7orrg9&st=qindv0t3&dl=1" >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INICIANDO (2/3)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	powershell -NoProfile Expand-Archive '%temp%\Advanced_IP.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1
	cls
	echo.
	echo.
	echo       ══════════════════════════════════
	echo       ███    %w%INSTALANDO (3/3)%b%        ███
	echo       ══════════════════════════════════
	timeout /t 1 /nobreak >nul
	%temp%\Fenox\"Advanced_IP.exe" /s /v/qb
	timeout /t 5 /nobreak >nul

	cls
	goto inicio

:ram
	cls
	echo otimizando ram

	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\EmptyStandbyList.exe" "https://www.dropbox.com/scl/fi/fomse4kgxofbdjj3tzvxl/EmptyStandbyList.exe?rlkey=h09tiejj4bnu2pm4f5nkrpmk2&st=vxcg44q8&dl=1" >nul 2>&1 && %temp%\EmptyStandbyList.exe

	set "emptyStandbyList=%temp%\EmptyStandbyList.exe"

	if not exist "%emptyStandbyList%" (
    echo [ERRO] O arquivo EmptyStandbyList.exe nao foi encontrado.
    echo Certifique-se de que ele esta na mesma pasta deste script.
    pause
    exit /b
)

	echo Limpando o cache de memoria RAM...
	"%emptyStandbyList%" workingsets
	"%emptyStandbyList%" modifiedpagelist
	"%emptyStandbyList%" standbylist
	goto continue

:atualizadormanual
	cls
	echo.
	echo.
	echo            ╔══════════════════════════╗
	echo            ║       %g%Menu Secreto%b%       ║
	echo            ║  Atualizar V1 Por estado ║
	echo            ╚══════════════════════════╝
	echo.
	echo      		[%w%1%b%]%w% SP%b%     [%w%2%b%]%w% MG%b%     
	echo.                 
	echo      		[%w%3%b%]%w% ES%b%     [%w%4%b%]%w% GO%b%
	echo.
	echo      		[%w%5%b%]%w% MS%b% 	   [%w%6%b%]%w% DF%b%
	echo.
	echo      		[%w%7%b%]%w% BA%b% 	   [%w%8%b%]%w% PB%b%
	echo.
	echo      		[%w%9%b%]%w% PA%b%
	echo.
	Set /p option0= %w%Digite a sigla do estado:%b%

	if %option0%==1 goto sp
	if %option0%==2 goto mg
	if %option0%==3 goto es
	if %option0%==4 goto go
	if %option0%==5 goto ms
	if %option0%==6 goto df
	if %option0%==7 goto ba
	if %option0%==8 goto pb
	if %option0%==9 goto pa

:sp
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\SP_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/SP_ATUALIZADOR.bat" >nul 2>&1 && %temp%\SP_ATUALIZADOR.bat
	Exit
	goto :fim

:mg
@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
curl -g -k -L -# -o "%temp%\MG_ATUALIZADOR_GERAL.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MG_ATUALIZADOR_GERAL.bat" >nul 2>&1 && %temp%\MG_ATUALIZADOR_GERAL.bat
Exit
goto :fim

:es
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\ES_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/ES_ATUALIZADOR.bat" >nul 2>&1 && %temp%\ES_ATUALIZADOR.bat
	Exit
	goto :fim

:ba
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\BA_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/BA_ATUALIZADOR.bat" >nul 2>&1 && %temp%\BA_ATUALIZADOR.bat
	Exit
	goto :fim

:df
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\DF_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/DF_ATUALIZADOR.bat" >nul 2>&1 && %temp%\DF_ATUALIZADOR.bat
	Exit
	goto :fim

:go
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\GO_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/GO_ATUALIZADOR.bat" >nul 2>&1 && %temp%\GO_ATUALIZADOR.bat
	Exit
	goto :fim

:ms
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\MS_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MS_ATUALIZADOR.bat" >nul 2>&1 && %temp%\MS_ATUALIZADOR.bat
	Exit
	goto :fim

:pb
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\PB_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/PB_ATUALIZADOR.bat" >nul 2>&1 && %temp%\PB_ATUALIZADOR.bat
	Exit
	goto :fim

:pa
	@echo off
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	curl -g -k -L -# -o "%temp%\PA_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/PA_ATUALIZADOR.bat" >nul 2>&1 && %temp%\PA_ATUALIZADOR.bat
	Exit
	goto :fim






