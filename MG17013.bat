@echo off
chcp 65001 >nul
title Versao MG 1.7.0.13
call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof
mode con: cols=60 lines=10
setlocal
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
SET SERVER_NAME=localhost
SET USER_NAME=sa
SET PASSWORD=F3N0Xfnx
SET DATABASE_NAME=SisviWcfLocal
SET BACKUP_PATH=C:\captura\SisviWcfLocal_backup.bak
SET SQL_FILE=C:\WCFLOCAL\UpdateDB\SWLModel.sql
cls
REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao V1 e WCF...
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version && wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
pause
cls
REM ******************* PARA INETMGR ****************
echo.
cls
echo   ═════════════════════════════════════
echo   ███  PARANDO INETMGR . . . . .    ███
echo   ═════════════════════════════════════

iisreset /stop  >nul
sc stop SisMonitorOffline  >nul
sc stop SisOcrOffline  >nul
sc stop SisAviCreator  >nul
cls
REM ******************* RENOMEANDO WCF e V1 ****************
ren "C:\WCFLOCAL" "WCFLOCAL.17012"
ren "C:\Program Files (x86)\Fenox V1.0" "Fenox V1.0.1012"
CLS
echo.
cls
echo   ═════════════════════════════════════
echo   ███  PASTA RENOMEADA (1/6)       ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
REM ******************* BAIXA A NOVA VERSAO ****************
echo Efetuando Download da nova versao 1.7.0.13...
curl -g -k -L -# -o "%temp%\1.7.0.13.zip" "https://www.dropbox.com/scl/fi/av89whtp4g6vwihlb1lzr/1.7.0.13.zip?rlkey=o8d83pkbqi06b79ub42yyrkmr&st=qrauww2y&dl=1" >nul 2>&1
cls
REM ******************* EXTRAI NOVO SISOCR ****************
cls
echo   ═════════════════════════════════════
echo   ███  EXTRAINDO ARQUIVOS (2/6)    ███
echo   ═════════════════════════════════════
timeout /t 2 /nobreak >nul
powershell -NoProfile Expand-Archive '%temp%\1.7.0.13.zip' -DestinationPath '%temp%\Fenox' >nul 2>&1 
REM ******************* INSTALANDO ****************
cls
echo   ═════════════════════════════════════
echo   ███  INSTALANDO . . . . (3/6)    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
%temp%\Fenox\Fnx_1.7.0.13_x64.exe /silent
%temp%\Fenox\WCFLocalFenox_1.7.0.13_x86 /silent
cls
REM Obtém o IPv4 do computador
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do for /f "tokens=1 delims= " %%j in ("%%i") do set IP=%%j  >nul
REM Remove espaços em branco
set IP=%IP: =%
REM Caminho do arquivo de configuração
set FILE="C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"  >nul
REM Substitui o endereço IP no arquivo usando PowerShell
powershell -Command "(Get-Content '%FILE%') -replace 'http://.*:8080', 'http://%IP%:8080' | Set-Content '%FILE%'"  >nul

REM ******************* DELETA PASTAS ****************

rmdir /s /q "C:\Program Files (x86)\Fenox V1.0.1012"  >nul
rmdir /s /q "C:\WCFLOCAL.17012"  >nul

REM ******************* INICIA SISOCR ****************
cls
echo   ═════════════════════════════════════
echo   ███  INICIANDO SERVICOS (4/6)    ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
iisreset /start  >nul
sc start SisMonitorOffline  >nul
sc start SisOcrOffline  >nul
sc start SisAviCreator  >nul
timeout /t 2 /nobreak >nul
cls
REM ******************* BACKUP E SINCRONOZAÇÃO DO DB ****************
cls
echo   ═════════════════════════════════════
echo   ███  BACKUP BANCO DE DADOS (5/6) ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
IF EXIST "%BACKUP_PATH%" (
    DEL /Q "%BACKUP_PATH%"
)

REM Executa o comando de backup
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -Q "BACKUP DATABASE [%DATABASE_NAME%] TO DISK = '%BACKUP_PATH%' WITH FORMAT;"  >nul
echo Backup do banco de dados %DATABASE_NAME% concluido com sucesso! >nul
REM Deleta SisviWcfLocalModel
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -Q "DROP DATABASE [SisviWcfLocalModel];"  >nul
echo Banco de dados SisviWcfLocalModel deletado com sucesso! >nul
REM Executa o comando para criar o banco de dados a partir do arquivo SQL
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -d master -i "%SQL_FILE%"  >nul
REM Executa o comando adicional (substitua pelo comando correto)
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -d SisviWcfLocalModel -Q "EXEC syncdb;"  >nul

REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao...
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version && wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version

cls
echo   ═════════════════════════════════════
echo   ███  FINALIZADO . . . .    (5/6) ███
echo   ═════════════════════════════════════ 
timeout /t 2 /nobreak >nul
pause
exit

