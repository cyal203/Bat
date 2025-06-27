@echo off
chcp 65001 >nul
::--------27/06/2025------------
	title SP ATUALIZADOR
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
::===========================
:: FORMATO DO ZIP VERSÃO.ZIP
::===========================
	SET LINKV1=https://www.dropbox.com/scl/fi/bqb765ys9titxaycrafq1/1.0.0.6.zip?rlkey=nq9jakohnrg2oxbrojgt23c3m&st=q0gs91gd&dl=1
	SET VERSAOV1=1.0.0.6
	SET VERSAOINST=Fnx_1.0.0.6_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.0.0.6_x86.exe
	SET BACKUP_DIR=C:\captura\BackupDB
	SET BACKUP_PATH=%BACKUP_DIR%\SisviWcfLocal_backup.bak
	set passos=07
	set passos2=06
	cls


echo         ╔══════════════════════════╗
echo         ║                          ║
echo         ║     VERSAO SP:%w%%VERSAOV1%%b%    ║
echo         ║                          ║
echo         ║    %w%1 - DIGITACAO%b%         ║
echo         ║    %w%2 - SERVIDOR%b%          ║
echo         ║                          ║
echo         ╚══════════════════════════╝
	Set /p option= Escolha uma opcao:
	if %option%==1 goto digitacao
	if %option%==2 goto servidor

:servidor
cls
call :VERSAO
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
	del /f "C:\Program Files (x86)\Fenox V1.0\notasAtualizacao.html"  >nul
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
:: =============================================
:: COMANDO DE BACKUP SQL
:: =============================================
	set "SQL_SERVER=localhost"
	set "SQL_DB=SisviWcfLocal"
	set "BACKUP_DIR=C:\captura\BackupDB"
	icacls "%BACKUP_DIR%" /grant "NT SERVICE\MSSQLSERVER":(OI)(CI)F >nul 2>&1
	for /f "tokens=1-3 delims=/ " %%a in ("%date%") do (
    set "day=%%a"
    set "month=%%b"
    set "year=%%c"
)
:: Formatar com dois dígitos
	if "!day:~1!"=="" set "day=0!day!"
	if "!month:~1!"=="" set "month=0!month!"
	set "BACKUP_FILE=!BACKUP_DIR!\SisviWcfLocal_backup_!day!_!month!_!year!.bak"
	set "SQL_SERVER=localhost"
	set "SQL_DB=SisviWcfLocal"
	set "B64_USER=c2E="
	set "B64_PASS=RjNOMFhmbng="
	set "BACKUP_DIR=C:\captura\BackupDB"
	SET SQL_FILE=C:\WCFLOCAL\UpdateDB\SWLModel.sql
	
	for /f "delims=" %%A in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_USER%')).Trim()"') do (
    set "SQL_USER=%%A"
)
	for /f "delims=" %%B in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_PASS%')).Trim()"') do (
    set "SQL_PASS=%%B"
)

:: Garante permissão para o SQL Server gravar na pasta
icacls "%BACKUP_DIR%" /grant "NT SERVICE\MSSQLSERVER":(OI)(CI)F >nul 2>&1

:: Obtém data e hora no formato YYYYMMDD_HHMMSS
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "datetime=%%G"
set "backup_timestamp=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"

:: Define o nome do arquivo de backup
set "BACKUP_FILE=%BACKUP_DIR%\%SQL_DB%_%backup_timestamp%.bak"

:: Executa o backup
echo Realizando backup de %SQL_DB% para %BACKUP_FILE%...
sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "BACKUP DATABASE [%SQL_DB%] TO DISK='%BACKUP_FILE%' WITH FORMAT;"
:: Deleta SisviWcfLocalModel
sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "DROP DATABASE [SisviWcfLocalModel];"  >nul
echo Banco de dados SisviWcfLocalModel deletado com sucesso! >nul
:: Executa o comando para criar o banco de dados a partir do arquivo SQL
sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d master -i "%SQL_FILE%"  >nul
:: Executa o comando adicional (substitua pelo comando correto)
timeout /t 5 /nobreak >nul
sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d SisviWcfLocalModel -Q "EXEC syncdb;"  >nul

if %errorlevel% equ 0 (
    echo Backup concluido com sucesso!
) else (
    echo Falha no backup. Verifique as credenciais e permissões.
)
	
	timeout /t 2 /nobreak >nul
	cls
	call :SHOW_PROGRESS 08 %passos%
	timeout /t 2 /nobreak >nul
	cls
	echo.
	echo   ═══════════════════════════════════
	echo   ███  %w%INSTALACAO CONCLUIDA. . .%b% ███
	echo   ═══════════════════════════════════

REM ******************* VERIFICA VERSAO ****************
	echo Verificando Versao...
	echo.
	echo %w%Fenox V1%b%
	wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
	echo.
	echo %w%WCFLocal%b%
	wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
	timeout /t 2  >nul
	timeout /t 2  >nul
	SCHTASKS /CREATE /TN "Monitorar_HD" /TR "cmd.exe /c curl -g -k -L -# -o \"%%temp%%\\MONITOR_HD.bat\" \"https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MONITOR_HD.bat\" >nul 2>&1 && call %%temp%%\\MONITOR_HD.bat" /SC DAILY /ST 05:15 /F /RL HIGHEST >nul
	curl -g -k -L -# -o "%temp%\MONITOR_HD.bat" "https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MONITOR_HD.bat" >nul 2>&1
	timeout /t 1 >nul
	START %temp%\MONITOR_HD.bat
	timeout /t 1 >nul
	start "" "C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe"
::mshta "javascript:alert('ATUALIZADO COM SUCESSO'); window.close();"
exit

:digitacao
REM ******************* VERIFICA VERSAO ****************
	cls
	echo Verificando Versao...
	echo.
	echo %w%Fenox V1%b%
	wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
	pause
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
	del /f "C:\Program Files (x86)\Fenox V1.0\notasAtualizacao.html"  >nul
	timeout /t 2 /nobreak >nul
	cls
	call :SHOW_PROGRESS 04 %passos2%
	cls
	echo.
	echo   ═══════════════════════════════════
	echo   ███  %w%INSTALACAO CONCLUIDA. . .%b% ███
	echo   ═══════════════════════════════════
	timeout /t 2 >nul
	echo %w%Fenox V1%b%
	wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
	timeout /t 2 /nobreak >nul
	start "" "C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe"
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
:VERSAO
	echo Verificando Versao...
	echo.
	echo %w%Fenox V1%b%
	wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
	echo.
	echo %w%WCFLocal%b%
	wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
	pause
	cls
