@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

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

:: Mapeia estado para número
set "ESTADO_NUM=0"

if /i "%REGIAO%"=="SaoPaulo" set ESTADO_NUM=1
if /i "%REGIAO%"=="MinasGerais" set ESTADO_NUM=2
if /i "%REGIAO%"=="EspiritoSanto" set ESTADO_NUM=3
:: adicione mais conforme desejar

echo Estado detectado: %REGIAO%
echo Codigo do estado: %ESTADO_NUM%
pause
:: Vai para a função
if "%ESTADO_NUM%"=="1" goto :saopaulo
if "%ESTADO_NUM%"=="2" goto :minasgerais
if "%ESTADO_NUM%"=="3" goto :espiritosanto

echo Estado nao reconhecido ou nao mapeado.
goto :fim

:: Funções por estado
:saopaulo
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
curl -g -k -L -# -o "%temp%\MG_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MG_ATUALIZADOR.bat" >nul 2>&1 && %temp%\MG_ATUALIZADOR.bat
Exit
goto :fim

:minasgerais
echo Executando funcao para Minas Gerais...
goto :fim

:espiritosanto
@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
curl -g -k -L -# -o "%temp%\ES_ATUALIZADOR.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/ES_ATUALIZADOR.bat" >nul 2>&1 && %temp%\ES_ATUALIZADOR.bat
Exit
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
