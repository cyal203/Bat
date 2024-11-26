echo off
chcp 65001 >nul
title INST BACKUP SQL
call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof
mode con: cols=50 lines=9
setlocal
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
echo   ═════════════════════════════════════════
echo   ███  BAIXANDO ARQUIVOS . . . . . (1/5)███
echo   ═════════════════════════════════════════
timeout /t 2 /nobreak >nul
REM ******************* BAIXA A NOVA VERSAO ****************
echo Efetuando Download do sisbackupsql...
curl -g -k -L -# -o "%temp%\SisBackupSQL.zip" "https://www.dropbox.com/scl/fo/lh53c8qbz9jnorxud5nlw/AJ7RzQdpl1hBF8xr0bVYPLw?rlkey=f4pkss6e1coao7bervwk7pthf&dl=1" >nul 2>&1
cls
REM ******************* EXTRAI NOVO SISOCR ****************
cls
echo   ═════════════════════════════════════════
echo   ███  EXTRAINDO ARQUIVOS . . . . .(2/5)███
echo   ═════════════════════════════════════════
timeout /t 2 /nobreak >nul
powershell -NoProfile Expand-Archive '%temp%\SisBackupSQL.zip' -DestinationPath '%temp%\SisBackupSQL' >nul 2>&1 
REM ******************* INSTALANDO ****************
cls
echo   ═════════════════════════════════════════
echo   ███  MOVENDO ARQUIVOS . . . . . .(3/5)███
echo   ═════════════════════════════════════════ 
timeout /t 2 /nobreak >nul
robocopy "%temp%\SisBackupSQL" "C:\Program Files (x86)\FNX\SisBackupSQL" /E /MOVE /R:3 /W:5
REM ******************* INICIA SISOCR ****************
cls
echo   ═════════════════════════════════════════
echo   ███  INSTALANDO SERVICO DE BACKUP(4/5)███
echo   ═════════════════════════════════════════
timeout /t 2 /nobreak >nul
cd C:\Program Files (x86)\FNX\SisBackupSQL
nssm install SisBackupSQL "C:\Program Files (x86)\FNX\SisBackupSQL\SisBackupSQL.exe"
timeout /t 2 /nobreak >nul
sc config SisBackupSQL start=auto >nul
timeout /t 2 /nobreak >nul
sc start SisBackupSQL >nul

cls
echo   ═════════════════════════════════════════
echo   ███  INSTALACAO CONCLUIDA . (5/5) . . ███
echo   ═════════════════════════════════════════ 
timeout /t 2 /nobreak >nul
pause