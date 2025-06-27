@echo off
chcp 65001 >nul
::--------27/06/2025------------
	title ATUALIZADOR_ESTADO
::==========================
::EXECUTA COMO ADMINISTRADOR
::==========================
	set "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	if "%Admin%"=="ops" goto :eof
	mode con: cols=50 lines=15
	setlocal enabledelayedexpansion
set "params=%*"
set w=[97m
set b=[96m
set g=[92m

:: Verifica se curl está disponível
	curl --version >nul 2>&1 || (
    echo Erro: curl nao encontrado. Tente executar em um Windows 10+ ou adicione curl ao PATH.
    pause
    exit /b
)

:: Obtem localizacao via IP
	curl -s ipinfo.io > "%temp%\ipinfo.txt"

:: Extrai o estado (region)
	for /f "tokens=1,* delims=:" %%A in ('findstr /i "region" "%temp%\ipinfo.txt"') do (
    set "REGIAO=%%B"
)

:: Limpa espaços, aspas, vírgulas e acentos
	set "REGIAO=%REGIAO:"=%"
	set "REGIAO=%REGIAO:,=%"
	set "REGIAO=%REGIAO: =%"
	call :removeAcentos "%REGIAO%" REGIAO
:: Corrigir nome especial do Distrito Federal
	if /i "%REGIAO%"=="FederalDistrict" set "REGIAO=DistritoFederal"

echo Estado detectado:%g% %REGIAO% %b%
::echo Codigo do estado: %ESTADO_NUM%
echo.
:: ESTADOS

if /i "%REGIAO%"=="Bahia" set ESTADO_NUM=1 & goto :bahia
if /i "%REGIAO%"=="DistritoFederal" set ESTADO_NUM=2 & goto :distritofederal
if /i "%REGIAO%"=="EspiritoSanto" set ESTADO_NUM=3 & goto :espiritosanto
if /i "%REGIAO%"=="Goias" set ESTADO_NUM=4 & goto :goias
if /i "%REGIAO%"=="Maranhao" set ESTADO_NUM=5 & goto :maranhao
if /i "%REGIAO%"=="MatoGrosso" set ESTADO_NUM=6 & goto :matogrosso
if /i "%REGIAO%"=="MatoGrossodoSul" set ESTADO_NUM=7 & goto :matogrossodosul
if /i "%REGIAO%"=="MinasGerais" set ESTADO_NUM=8 & goto :minasgerais
if /i "%REGIAO%"=="Para" set ESTADO_NUM=9 & goto :para
if /i "%REGIAO%"=="SaoPaulo" set ESTADO_NUM=10 & goto :saopaulo


echo Estado nao reconhecido ou nao mapeado.
goto :fim

:: Funções por estado
:saopaulo
echo Em processo de criação, Aguarde........
pause
Exit
goto :fim

:minasgerais
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
curl -g -k -L -# -o "%temp%\MG_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MG_ATUALIZADOR.bat" >nul 2>&1 && %temp%\MG_ATUALIZADOR.bat
Exit
goto :fim

:espiritosanto
@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
curl -g -k -L -# -o "%temp%\ES_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/ES_ATUALIZADOR.bat" >nul 2>&1 && %temp%\ES_ATUALIZADOR.bat
Exit
goto :fim

:bahia
echo BA em processo de criação, Aguarde........
pause
goto :fim

:distritofederal
echo DF em processo de criação, Aguarde........
pause
goto :fim

:goias
echo GO em processo de criação, Aguarde........
pause
goto :fim

:maranhao
echo MA em processo de criação, Aguarde........
pause
goto :fim

:matogrosso
echo Em processo de criação, Aguarde........
pause
goto :fim

:matogrossodosul
echo MS em processo de criação, Aguarde........
pause
goto :fim

:para
echo PA em processo de criação, Aguarde........
pause
goto :fim

:fim
endlocal
pause
exit /b

:: Função para remover acentos (básica, por substituição)
:removeAcentos
setlocal EnableDelayedExpansion
set "str=%~1"
:: substituições comuns de acentos
set "str=!str:á=a!"
set "str=!str:à=a!"
set "str=!str:ã=a!"
set "str=!str:â=a!"
set "str=!str:é=e!"
set "str=!str:ê=e!"
set "str=!str:í=i!"
set "str=!str:ó=o!"
set "str=!str:ô=o!"
set "str=!str:õ=o!"
set "str=!str:ú=u!"
set "str=!str:ç=c!"


:: remove espaços finais
set "str=!str: =!"
endlocal & set "%~2=%str%"
exit /b
