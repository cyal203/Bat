@echo off
chcp 65001 >nul
title Versão 1.2
REM ----- DATA - 07/02/2025 -----------
call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof
mode con: cols=45 lines=12
setlocal
set "params=%*"
set w=[97m
set b=[96m
%B%
cls
REM ******************** ABRE O MENU INICIAL ********************
echo ╔══════════════════════════╗
echo ║   SELECIONE UMA OPCAO:   ║
echo ║    [%w%1%b%]  %w%DIGITACAO%b%        ║
echo ║    [%w%2%b%]  %w%SERVIDOR%b%         ║
echo ╚══════════════════════════╝

Set /p option= %w%Escolha uma Opcao:%b%

if %option%==1 goto digitacao
if %option%==2 goto servidor

echo.
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE. . . .%b%    ███
echo   ═════════════════════════════════════
:servidor
setlocal enabledelayedexpansion
:: Define o caminho do arquivo temporário
set "TEMP_IP=%TEMP%\IPLISTEN.txt"

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
timeout /t 3 /nobreak >nul
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
:digitacao
REM ******************* FINALIZANDO SERVIÇOS QUE NÃO RESPONDEM********
taskkill /f /fi "status eq not responding" >nul
CLS
echo.
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (1/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESABILITA DEFENDER ****************
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f >nul
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f >nul
powershell -command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul
sc stop WinDefend>nul
sc config WinDefend start= disabled >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (2/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESABILITA FIREWALL ****************
netsh advfirewall set allprofiles state off >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (3/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* REDEFINIR PROBLEMAS DE TCP/IP ****************
netsh winsock reset >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (4/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* ATUALIZA DIRETIVA DE GRUPO ****************
gpupdate /force >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (5/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESBLOQUEIA INSTALAÇÃO DE SOFTWARE ****************
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableLUA /T REG_DWORD /D 0 /F >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (6/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESABILITA HIBERNAÇÃO ****************
powercfg.exe /hibernate off >nul
timeout /t 1 /nobreak >nul
REM ******************* DESABILITA APLICATIVOS EM SEGUNDO PLANO ****************
REG add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /V GlobalUserDisabled /T REG_DWORD /D 1 /F >nul
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /V BackgroundAppGlobalToggle /T REG_DWORD /D 0 /F >nul
REG ADD "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /V LetAppsRunInBackground /T REG_DWORD /D 2 /F >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (7/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESABILITA XBOX GameDVR ****************
REG add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (8/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* TORNA O ESQUEMA DE ENERGIA ATIVO FAZENDO ALTERAÇÕES SIGNIFICANTES ****************
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul
powercfg /change standby-timeout-dc 0 >nul
powercfg /change monitor-timeout-ac 0 >nul
powercfg /change disk-timeout-ac 0 >nul
powercfg /change disk-timeout-dc 0 >nul
timeout /t 2 /nobreak >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (9/18)%b%    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESATIVA IPV6 ****************
REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (10/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ********** DESATIVA INDEXAÇÃO *************
sc stop "WSearch" >nul
sc config "WSearch" start=disabled >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (11/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESATIVA TELEMETRIA **********************
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
reg add "HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f >nul
reg add "HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules" /v PeriodInNanoSeconds /t REG_QWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
sc stop DiagTrack >nul
sc delete DiagTrack >nul
sc stop dmwappushservice >nul
sc delete dmwappushservice >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (12/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESATIVA SERVIÇOS********
sc config Fax start= disabled >nul
sc config "Remote Desktop Services" start= disabled >nul
sc config "Diagnostic Policy Service" start= disabled >nul
sc config "Distributed Link Tracking Client" start= disabled >nul
sc config "Offline Files" start= disabled >nul
sc config "Windows Error Reporting Service" start= disabled >nul
sc config "Windows Search" start= disabled >nul
sc config "SysMain" start= disabled >nul
sc delete SysMain >nul
sc config "SIMNextLocalRecording" start= disabled >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (13/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* DESATIVA CORTANA ************
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul
taskkill /f /im SearchUI.exe >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (14/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* LIMPA TEM DO INTERNET EXPLORER ****************
Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (15/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************** LIXEIRA ********************
del c:\$recycle.bin\* /s /q >nul
PowerShell.exe -NoProfile -Command Clear-RecycleBin -Confirm:$false >$null >nul
del $null >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (16/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM cria arquivo vazio.txt dentro da pasta \Windows\Temp
type nul > c:\Windows\Temp\vazio.txt >nul
REM apaga todas as pastas vazias dentro da pasta \Windows\Temp (mas não apaga a própria pasta)
robocopy c:\Windows\Temp c:\Windows\Temp /s /move /NFL /NDL /NJH /NJS /nc /ns /np >nul
REM Apaga arquivo vazio.txt dentro da pasta \Windows\Temp
del c:\Windows\Temp\vazio.txt >nul
REM ******************** ARQUIVOS DE LOG DO WINDOWS ********************
del C:\Windows\Logs\cbs\*.log >nul
del C:\Windows\setupact.log >nul
attrib -s c:\windows\logs\measuredboot\*.* >nul
del c:\windows\logs\measuredboot\*.log >nul
attrib -h -s C:\Windows\ServiceProfiles\NetworkService\ >nul
attrib -h -s C:\Windows\ServiceProfiles\LocalService\ >nul
del C:\Windows\ServiceProfiles\LocalService\AppData\Local\Temp\MpCmdRun.log >nul
del C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp\MpCmdRun.log >nul >nul
attrib +h +s C:\Windows\ServiceProfiles\NetworkService\ >nul
attrib +h +s C:\Windows\ServiceProfiles\LocalService\ >nul
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\*.log /s /q >nul
del C:\Windows\Logs\MeasuredBoot\*.log  >nul
del C:\Windows\Logs\MoSetup\*.log >nul
del C:\Windows\Panther\*.log /s /q >nul
del C:\Windows\Performance\WinSAT\winsat.log /s /q >nul
del C:\Windows\inf\*.log /s /q >nul
del C:\Windows\logs\*.log /s /q >nul
del C:\Windows\SoftwareDistribution\*.log /s /q >nul
del C:\Windows\Microsoft.NET\*.log /s /q >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (17/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************** ARQUIVOS DE LOG DO ONEDRIVE ********************
taskkill /F /IM "OneDrive.exe"
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\setup\logs\*.log /s /q >nul
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\*.odl /s /q >nul
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\*.aodl /s /q >nul
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\Microsoft\OneDrive\*.otc /s /q >nul
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\OneDrive\*.qmlc /s /q >nul

REM ******************** ARQUIVOS DE DUMP DE PROGRAMAS (NÃO DO WINDOWS) ********************
for /d %%F in (C:\Users\*) do del %%F\AppData\Local\CrashDumps\*.dmp /s /q >nul

REM ******************** TeamViewer ********************
for /l %%i in (1,1,12) do (for /d %%F in (C:\Users\*) do del %%F\AppData\Local\TeamViewer\EdgeBrowserControl\Persistent\data_*.  /s /q) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_0 /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_1 /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_2 /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_3 /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_4 /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /S /M *_5 /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /M "f_*." /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /M "data.*" /C "cmd /c del @path")) >nul
for /d %%u in (C:\Users\*) do (if exist "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" (forfiles /P "%%u\AppData\Local\TeamViewer\EdgeBrowserControl" /M "index.*" /C "cmd /c del @path")) >nul


REM ******************* DESATIVA EFEITOS VISUAIS ****************
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 90120000010000000000000000 /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f >nul
cls
echo   ═════════════════════════════════════
echo   ███  %w%OTIMIZANDO AGUARDE (18/18)%b%   ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
cls
echo   ═══════════════════════════════════
echo   ███  %w%OTIMZACAO CONCLUIDA. . .%b%   ███
echo   ═══════════════════════════════════
echo.
timeout /t 3 /nobreak >nul
REM ******************** ABRE A LIMPEZA DE DISCO ********************
:menu1
echo.
Set /p op= DESEJA EXECUTAR LIMPEZA DE DISCO (%w%S/N%b%):
if %op% equ s goto s
if %op% equ n goto n
if %op% equ S goto s
if %op% equ N goto n

:s
REM ******************** WINDOWS TEMP ********************
cleanmgr C:
::del c:\Windows\Temp\* /s /q >nul
::del /F /S /Q C:\WINDOWS\Temp\*.* >nul
::del /F /S /Q C:\WINDOWS\Prefetch\*.* >nul
::del /s /f /q %temp%\ >nul

:n
goto menu

REM ******************** EXECUTA A DEFRAGMENTAÇÃO DE DISCO ********************

@echo off
:menu

Set /p op= DESEJA EXECUTAR A DEFRAG DE DISCO (%w%S/N%b%):
if %op% equ s goto s
if %op% equ n goto n
if %op% equ S goto s
if %op% equ N goto n

:s
Defrag C: /U
exit

:n
exit
