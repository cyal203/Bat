@echo off
chcp 65001 >nul
title Versão 1.0
REM ----- DATA - 26/03/2025 -----------
call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof
mode con: cols=53 lines=12
setlocal
set "params=%*"
set w=[97m
set b=[96m
%B%
cls

echo Efetuando Download...
curl -g -k -L -# -o "%temp%\LEITOR_BIOMETRICO.zip" "https://www.dropbox.com/scl/fi/vkwaoojm2gpef0wbuky1s/LEITOR_BIOMETRICO.zip?rlkey=98n5937z1641k0wpx39ajwdif&st=5bt8looi&dl=1" >nul 2>&1
powershell -NoProfile Expand-Archive '%temp%\LEITOR_BIOMETRICO.zip' -DestinationPath '%temp%\LEITOR_BIOMETRICO' >nul 2>&1
echo Copiando DLLs...
:: Copia as DLLs de System32
xcopy /Y /V "%temp%\LEITOR_BIOMETRICO\System32\*.dll" "C:\Windows\System32\"
if %errorlevel% neq 0 echo Falha ao copiar DLLs para System32.

:: Copia as DLLs de SysWOW64
if exist "C:\Windows\SysWOW64" (
    xcopy /Y /V "%temp%\LEITOR_BIOMETRICO\SysWOW64\*.dll" "C:\Windows\SysWOW64\"
    if %errorlevel% neq 0 echo Falha ao copiar DLLs para SysWOW64.
)

cls
echo Instalando...
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
timeout /t 5 /nobreak >nul
exit /b