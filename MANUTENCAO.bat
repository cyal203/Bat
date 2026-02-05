@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
chcp 65001 >nul
title MANAGER V1

:: ===============================
::          03/02/2026
:: ===============================

:: ===============================
:: ELEVAÇÃO ADMIN
:: ===============================
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/k \"%~f0\"' -Verb RunAs"
    exit /b
)

mode con cols=41 lines=10
::ciano
	set b=[96m
::verde
	set g=[92m	
::vermelho
	set "r=[91m"
::vermelho
	set "r=[91m"
:: Azul
	set "d=[38;5;39m"
::branco
	set w=[97m
:: Amarelo claro	
	set "y=[93m" 
	
:: ===============================
:: VARIÁVEIS
:: ===============================
set TOTAL=6
set STEP=0

set APP_PATH=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe
set CONFIG_FILE=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config

:: ===============================
:: EXECUÇÃO
:: ===============================

call :Step "Fechando Fenox V1"
call :FechaV1

call :Step "Atualizando IP do Fenox V1"
call :IPV1

call :Step "Configurando IP Listen"
call :IPLISTEN

call :Step "Parando servicos"
call :StopServices

call :Step "Iniciando servicos"
call :StartServices


call :Step "Abrindo Fenox V1"
call :AbreV1


echo ========================================
echo     PROCESSO CONCLUIDO COM SUCESSO
echo ========================================

exit

:: =================================================
:: CONTROLE DE PROGRESSO
:: =================================================
:Step
set /a STEP+=1
call :Progress %STEP% %TOTAL% "%~1"
exit /b

:Progress
setlocal EnableDelayedExpansion
set CUR=%1
set MAX=%2
set TXT=%~3

set /a PCT=(CUR*100)/MAX
set /a FILL=(CUR*20)/MAX

set BAR=
for /L %%i in (1,1,!FILL!) do set BAR=!BAR!#
for /L %%i in (!FILL!,1,19) do set BAR=!BAR!-

cls
echo.
echo %b% ═══════════════════════════════════════
echo  ███          %d%  MANAGER V1  %b%         ███
echo  ═══════════════════════════════════════
echo.
echo       [ %w% !BAR! %b% ] %y% !PCT!%%
echo.
echo   %b% Etapa: %w% !TXT!
echo.
endlocal & timeout /t 1 >nul & exit /b

:: =================================================
:: FUNÇÕES
:: =================================================
:FechaV1
powershell -NoProfile -Command ^
 "Get-Process Fnx64bits -ErrorAction SilentlyContinue | Stop-Process -Force"
exit /b

:IPV1
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f %%B in ("%%A") do (
        set IP=%%B
        goto :gotIP
    )
)
:gotIP
set IP=%IP: =%

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "& { (Get-Content '%CONFIG_FILE%') -replace 'http://.*:8080','http://%IP%:8080' | Set-Content '%CONFIG_FILE%' }"
exit /b

:IPLISTEN
for /f "tokens=*" %%i in ('netsh http show iplisten ^| findstr /R "[0-9]\."') do (
    netsh http delete iplisten ip=%%i >nul
)

netsh http add iplisten ip=%IP% >nul
netsh http add iplisten ip=127.0.0.1 >nul
ipconfig /flushdns >nul
exit /b

:StopServices
for %%S in (SisOcrOffline SisAviCreator SisMonitorOffline MMFnx) do sc stop %%S >nul
timeout /t 2 >nul
taskkill /F /IM SisAviCreator.exe SisMonitorOffline.exe SSisOCR.Offline.Service.exe FenoxSM.exe >nul 2>&1
exit /b

:StartServices
for %%S in (SisOcrOffline SisAviCreator SisMonitorOffline MMFnx) do sc start %%S >nul
iisreset /restart >nul
exit /b

:AbreV1
start "" "%APP_PATH%"
exit /b
