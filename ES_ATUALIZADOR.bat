@echo off
chcp 65001 >nul
::--------06/05/2025------------
title ES ATUALIZADOR
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
SET SERVER_NAME=localhost
SET USER_NAME=sa
SET PASSWORD=F3N0Xfnx
SET DATABASE_NAME=SisviWcfLocal
SET SQL_FILE=C:\WCFLOCAL\UpdateDB\SWLModel.sql
::===========================
:: FORMATO DO ZIP VERSÃO.ZIP
::===========================
SET LINKV1=https://www.dropbox.com/scl/fi/bp2oopnwk0hh539z7akq2/1.3.0.18.zip?rlkey=k5bw5j2mgpc9r0o8btjxvlj0q&st=j6nur2hq&dl=1
SET VERSAOV1=1.3.0.18
SET VERSAOINST=Fnx_1.3.0.18_x64.exe
SET VERSAOINSTWCF=WCFLocalFenox_1.3.0.18_x86.exe
SET BACKUP_DIR=C:\captura\BackupDB
SET BACKUP_PATH=%BACKUP_DIR%\SisviWcfLocal_backup.bak
set passos=07
set passos2=06
cls


echo         ╔══════════════════════════╗
echo         ║                          ║
echo         ║     VERSAO:%w%%VERSAOV1%%b%      ║
echo         ║    %w%Correcao Movel 06/05%b%  ║
echo         ║                          ║
echo         ║    %w%1 - DIGITACAO%b%         ║
echo         ║    %w%2 - SERVIDOR%b%          ║
echo         ║                          ║
echo         ╚══════════════════════════╝
rem choice /c 1234 /m "Escolha uma opcao"
Set /p option= Escolha uma opcao:
rem set "option=%errorlevel%"

if %option%==1 goto digitacao
if %option%==2 goto servidor

:servidor
REM ******************* VERIFICA VERSAO ****************
echo Verificando Versao...
echo.
echo %w%Fenox V1%b%
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
echo.
echo %w%WCFLocal%b%
wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
pause
cls
REM ******************* PARA INETMGR ****************
echo.
cls
call :SHOW_PROGRESS 01 %passos%
iisreset /stop  >nul
sc stop SisMonitorOffline  >nul
sc stop SisOcrOffline  >nul
sc stop SisAviCreator  >nul
timeout /t 2 /nobreak >nul
cls
REM ******************* RENOMEANDO WCF e V1 ****************
ren "C:\WCFLOCAL" "WCFLOCAL.OLD1"
ren "C:\Program Files (x86)\Fenox V1.0" "Fenox V1.0.OLD1"
timeout /t 2 /nobreak >nul
call :SHOW_PROGRESS 02 %passos%
REM ******************* BAIXA A NOVA VERSAO ****************
echo Efetuando Download da nova versao %VERSAOV1%...
curl -g -k -L -# -o "%temp%\%VERSAOV1%.zip" "%LINKV1%" >nul 2>&1
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 03 %passos%
powershell -NoProfile Expand-Archive '%temp%\%VERSAOV1%.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1 
timeout /t 2 /nobreak >nul
REM ******************* INSTALANDO ****************
cls
call :SHOW_PROGRESS 04 %passos%
%temp%\Fenox\%VERSAOINST% /silent
%temp%\Fenox\%VERSAOINSTWCF% /silent
timeout /t 2 /nobreak >nul
cls
REM Obtém o IPv4 do computador
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do for /f "tokens=1 delims= " %%j in ("%%i") do set IP=%%j  >nul
REM Remove espaços em branco
set IP=%IP: =%
REM Caminho do arquivo de configuração
set FILE="C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"  >nul
REM Substitui o endereço IP no arquivo usando PowerShell
powershell -Command "(Get-Content '%FILE%') -replace 'http://.*:8080', 'http://%IP%:8080' | Set-Content '%FILE%'"  >nul
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 05 %passos%
REM ******************* DELETA PASTAS ****************
rmdir /s /q "C:\Program Files (x86)\Fenox V1.0.OLD1"  >nul
rmdir /s /q "C:\WCFLOCAL.OLD1"  >nul
del /f "C:\Program Files (x86)\Fenox V1.0\un.config"  >nul
del /f "C:\Program Files (x86)\Fenox V1.0\notasAtualizacao.html"  >nul
ren "C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe" "Fnx64bits.exe.OLD1"
move "%temp%\Fenox\Fnx64bits.exe" "C:\Program Files (x86)\Fenox V1.0\"
REM ******************* INICIA SISOCR ****************
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 06 %passos%
timeout /t 2 /nobreak >nul
iisreset /start  >nul
sc start SisMonitorOffline  >nul
sc start SisOcrOffline  >nul
sc start SisAviCreator  >nul
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 07 %passos%
REM ******************* BACKUP E SINCRONOZAÇÃO DO DB ****************
:: Backup do banco
IF NOT EXIST "%BACKUP_DIR%" (
    MKDIR "%BACKUP_DIR%" >nul
)
IF EXIST "%BACKUP_PATH%" (
    DEL /Q "%BACKUP_PATH%" >nul
)
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -Q "BACKUP DATABASE [%DATABASE_NAME%] TO DISK = '%BACKUP_PATH%' WITH FORMAT;"
echo Backup do banco de dados %DATABASE_NAME% concluido com sucesso! >nul
REM Deleta SisviWcfLocalModel
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -Q "DROP DATABASE [SisviWcfLocalModel];"  >nul
echo Banco de dados SisviWcfLocalModel deletado com sucesso! >nul
REM Executa o comando para criar o banco de dados a partir do arquivo SQL
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -d master -i "%SQL_FILE%"  >nul
REM Executa o comando adicional (substitua pelo comando correto)
timeout /t 5 /nobreak >nul
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -d SisviWcfLocalModel -Q "EXEC syncdb;"  >nul
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 08 %passos%
timeout /t 2 /nobreak >nul
cls
call :CONCLUIDO
REM ******************* VERIFICA VERSAO ****************
echo Verificando Versao...
echo.
echo %w%Fenox V1%b%
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
echo.
echo %w%WCFLocal%b%
wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
pause
exit

:digitacao
REM ******************* VERIFICA VERSAO ****************
echo Verificando Versao...
echo.
echo %w%Fenox V1%b%
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version || goto :INSTALAR >nul
REM Se a versão for reconhecida, o script continua normalmente

REM ******************* RENOMEANDO V1 ****************
pause
CLS
echo.
ren "C:\Program Files (x86)\Fenox V1.0" "Fenox V1.0.OLD1"
cls
timeout /t 2 /nobreak >nul

:INSTALAR
REM ******************* BAIXA A NOVA VERSAO ****************
cls
call :SHOW_PROGRESS 01 %passos2%
echo Efetuando Download da versao %VERSAOV1%...
curl -g -k -L -# -o "%temp%\%VERSAOV1%.zip" "%LINKV1%" >nul 2>&1
cls

REM ******************* EXTRAI NOVO V1 ****************
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 02 %passos2%
powershell -NoProfile Expand-Archive '%temp%\%VERSAOV1%.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1 

REM ******************* INSTALANDO ****************
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 03 %passos2%
%temp%\Fenox\%VERSAOINST% /silent
timeout /t 2 /nobreak >nul
REM ******************* DELETA PASTAS ****************
rmdir /s /q "C:\Program Files (x86)\Fenox V1.0.OLD1"  >nul
del /f "C:\Program Files (x86)\Fenox V1.0\un.config"  >nul
del /f "C:\Program Files (x86)\Fenox V1.0\notasAtualizacao.html"  >nul
ren "C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe" "Fnx64bits.exe.OLD1"
move "%temp%\Fenox\Fnx64bits.exe" "C:\Program Files (x86)\Fenox V1.0\"
timeout /t 2 /nobreak >nul
cls
call :SHOW_PROGRESS 04 %passos2%
cls
call :CONCLUIDO
echo %w%Fenox V1%b%
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version || goto :INSTALAR >nul
pause
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
echo       ███    %w%INSTALANDO (%1/%2)%b%      ███
echo       ══════════════════════════════════
timeout /t 1 >nul
goto :EOF

:CONCLUIDO
cls
echo.
echo   ═══════════════════════════════════
echo   ███  %w%INSTALACAO CONCLUIDA. . .%b% ███
echo   ═══════════════════════════════════
timeout /t 1 >nul
goto :EOF
