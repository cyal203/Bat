
@echo off
chcp 65001 >nul
::--------15/08/2025-------------
	title MG ATUALIZADOR
::==========================
::EXECUTA COMO ADMINISTRADOR
::==========================
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	if "%Admin%"=="ops" goto :eof
	mode con: cols=50 lines=15
	setlocal enabledelayedexpansion
	Set Version=4
	set w=[97m
	set p=[95m
	set b=[96m
%B%
cls
echo.
echo         ╔══════════════════════════╗
echo         ║                          ║
echo         ║    %w%1 - 1.8.0.5 - ATUAL%b%   ║
echo         ║    %w%2 - 1.8.0.6 - BAIXA%b%   ║
echo         ║                          ║
echo         ╚══════════════════════════╝
	Set /p option= Escolha uma opcao:
	if %option%==1 goto 1805
	if %option%==2 goto 1806
	
:1805
@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
curl -g -k -L -# -o "%temp%\MG_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MG_ATUALIZADOR.bat" >nul 2>&1 && %temp%\MG_ATUALIZADOR.bat
Exit


:1806
@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
curl -g -k -L -# -o "%temp%\MG_ATUALIZADOR _BAIXA.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MG_ATUALIZADOR%20_BAIXA.bat" >nul 2>&1 && %temp%\MG_ATUALIZADOR _BAIXA.bat
Exit
