@echo off
::==========================================================================================================================
::      DATA
::    06-04-2026
::==========================================================================================================================
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
if "%Admin%"=="ops" goto :eof
mode con: cols=60 lines=12
setlocal enabledelayedexpansion

:: --- CONFIGURAÇÕES ---
set "SQL_SERVER=localhost"
set "SQL_DB=SisviWcfLocal"
set "BACKUP_DIR=C:\captura\BackupDB"
set "B64_USER=c2E="
set "B64_PASS=RjNOMFhmbng="

:: --- DECODIFICAÇÃO ---
for /f "delims=" %%A in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_USER%')).Trim()"') do set "SQL_USER=%%A"
for /f "delims=" %%B in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_PASS%')).Trim()"') do set "SQL_PASS=%%B"

:: --- BACKUP ---
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
icacls "%BACKUP_DIR%" /grant "NT SERVICE\MSSQLSERVER":(OI)(CI)F >nul 2>&1
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "datetime=%%G"
set "backup_timestamp=%datetime:~6,2%_%datetime:~4,2%_%datetime:~0,4%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"
set "BACKUP_FILE=%BACKUP_DIR%\%SQL_DB%_%backup_timestamp%.bak"

echo Realizando backup de seguranca...
sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -Q "BACKUP DATABASE [%SQL_DB%] TO DISK='%BACKUP_FILE%' WITH FORMAT;" >nul

if %errorlevel% neq 0 (
    echo [ERRO] Falha no backup. A operacao foi abortada por seguranca.
    pause
    exit /b
)
echo [OK] Backup concluido: %BACKUP_FILE%
echo.

:: --- BUSCA DE OS ---
cls
echo ===============================================================================================
echo    Escolha o tipo de busca:
echo ===============================================================================================
echo      [1] - PLACA
echo      [2] - CHASSI
echo.
set /p TIPO_BUSCA=Digite: 
cls
if "%TIPO_BUSCA%"=="1" (
    set /p VALOR_BUSCA=Digite a placa: 
    set "CAMPO=Placa"
) else if "%TIPO_BUSCA%"=="2" (
    set /p VALOR_BUSCA=Digite o chassi: 
    set "CAMPO=Chassi"
) else (
    echo Opcao invalida!
    pause
    exit /b
)

:: Busca o ID da OS mais recente
for /f "usebackq" %%i in (`sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -h -1 -Q "SET NOCOUNT ON; SELECT TOP 1 IdentificadorOrdemServico FROM OrdemServico WHERE %CAMPO%='%VALOR_BUSCA%' ORDER BY DataCadastro DESC"`) do set "ID_OS=%%i"

if "%ID_OS%"=="" (
    echo Nenhuma Ordem de Servico encontrada para %CAMPO% %VALOR_BUSCA%.
    pause
    exit /b
)

echo.
echo OS Localizada: %ID_OS%
echo Processando verificacoes...
echo ---------------------------------------------------

:: --- LÓGICA DE EXCLUSÃO ---

:: ORDEM 0
for /f "usebackq" %%f in (`sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -h -1 -Q "SET NOCOUNT ON; SELECT IdentificadorFoto FROM OrdemServicoFotos WHERE IdentificadorOrdemServico='%ID_OS%' AND FotoOriginal=0 EXCEPT SELECT IdentificadorFotoReduzida FROM OrdemServicoFotoREXOR WHERE IdentificadorOrdemServico='%ID_OS%'"`) do (
    if not "%%f"=="" (
        echo [ORDEM 0] Deletando Foto Reduzida orfa: %%f
        sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -Q "DELETE FROM OrdemServicoFotos WHERE IdentificadorFoto='%%f' AND IdentificadorOrdemServico='%ID_OS%'"
    )
)

:: ORDEM 1
for /f "usebackq" %%f in (`sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -h -1 -Q "SET NOCOUNT ON; SELECT IdentificadorFotoOriginal FROM OrdemServicoFotoREXOR WHERE IdentificadorOrdemServico='%ID_OS%' EXCEPT SELECT IdentificadorFoto FROM OrdemServicoFotos WHERE IdentificadorOrdemServico='%ID_OS%' AND FotoOriginal=1"`) do (
    if not "%%f"=="" (
        echo [ORDEM 1] Deletando Registro REXOR sem Original: %%f
        sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -Q "DELETE FROM OrdemServicoFotoREXOR WHERE IdentificadorFotoOriginal='%%f' AND IdentificadorOrdemServico='%ID_OS%'"
    )
)

:: ORDEM 2
for /f "usebackq" %%f in (`sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -h -1 -Q "SET NOCOUNT ON; SELECT IdentificadorFoto FROM OrdemServicoFotos WHERE IdentificadorOrdemServico='%ID_OS%' AND FotoOriginal=1 EXCEPT SELECT IdentificadorFotoOriginal FROM OrdemServicoFotoREXOR WHERE IdentificadorOrdemServico='%ID_OS%'"`) do (
    if not "%%f"=="" (
        echo [ORDEM 2] Deletando Foto Original sem vinculo REXOR: %%f
        sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -Q "DELETE FROM OrdemServicoFotos WHERE IdentificadorFoto='%%f' AND IdentificadorOrdemServico='%ID_OS%'"
    )
)

:: --- VERIFICAR RELACIONAMENTO FINAL ---
set "FALTA_RELACAO=N"
for /f "usebackq" %%r in (`sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -d %SQL_DB% -h -1 -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM OrdemServicoFotos WHERE IdentificadorOrdemServico='%ID_OS%' AND IdentificadorFoto NOT IN (SELECT IdentificadorFotoOriginal FROM OrdemServicoFotoREXOR WHERE IdentificadorOrdemServico='%ID_OS%') AND IdentificadorFoto NOT IN (SELECT IdentificadorFotoReduzida FROM OrdemServicoFotoREXOR WHERE IdentificadorOrdemServico='%ID_OS%')"`) do (
    if %%r GTR 0 set "FALTA_RELACAO=S"
)

if "%FALTA_RELACAO%"=="S" (
    powershell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Falta de Relacionamento.' + [Environment]::NewLine + 'Acionar o suporte N2.', 'Alerta N2', 'OK', 'Error')"
) else (
    powershell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('[SUCESSO] %CAMPO%: %VALOR_BUSCA%' + [Environment]::NewLine + 'Atualize o V1.', 'Sucesso', 'OK', 'Information')"
)

pause
