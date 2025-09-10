@echo off
setlocal enabledelayedexpansion

	set "SQL_SERVER=localhost"
	set "SQL_DB=SisviWcfLocal"
	set "BACKUP_DIR=C:\captura\BackupDB"
	for /f "tokens=1-3 delims=/ " %%a in ("%date%") do (
    set "day=%%a"
    set "month=%%b"
    set "year=%%c"
)
:: Formatar com dois dígitos
	if "!day:~1!"=="" set "day=0!day!"
	if "!month:~1!"=="" set "month=0!month!"
	set "BACKUP_FILE=!BACKUP_DIR!\SisviWcfLocal_backup_!day!_!month!_!year!.bak"

:: Configurações do SQL Server
set "SQL_SERVER=localhost"
set "SQL_DB=SisviWcfLocal"
set "B64_USER=c2E="
set "B64_PASS=RjNOMFhmbng="
set "BACKUP_DIR=C:\captura\BackupDB"

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
set "backup_timestamp=%datetime:~6,2%_%datetime:~4,2%_%datetime:~0,4%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"
::set "backup_timestamp=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"

:: Define o nome do arquivo de backup
set "BACKUP_FILE=%BACKUP_DIR%\%SQL_DB%_%backup_timestamp%.bak"

:: Executa o backup
echo Realizando backup de %SQL_DB% para %BACKUP_FILE%...
sqlcmd -S %SQL_SERVER% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "BACKUP DATABASE [%SQL_DB%] TO DISK='%BACKUP_FILE%' WITH FORMAT;"

if %errorlevel% equ 0 (
	cls
	echo.
	echo ====================================================
    echo Backup concluido com sucesso!
	echo ====================================================
	echo.
) else (
    echo Falha no backup. Verifique as credenciais e permissões.
)

:: Entrada de dados
set /p PLACA=Digite a placa: 
set /p CPF_ANTIGO=Digite o CPF do vistoriador atual: 
set /p CPF_NOVO=Digite o CPF do novo vistoriador: 
cls
echo ====================================================
echo Buscando ID do vistoriador novo...
echo ====================================================

:: Consulta o ID do vistoriador pelo CPF novo
for /f "skip=2 tokens=1,2,3 delims=," %%a in ('
    sqlcmd -S %SQL_SERVER% -d %SQL_DB% -U "%SQL_USER%" -P "%SQL_PASS%" -W -s "," -Q "SET NOCOUNT ON; SELECT IdUsuario, Nome, CPF FROM Login WHERE CPF='%CPF_NOVO%'"
') do (
    set ID_NOVO=%%a
    set NOME_NOVO=%%b
    set CPF_NOVO_CONF=%%c
)

if "%ID_NOVO%"=="" (
    echo ERRO: CPF %CPF_NOVO% nao encontrado na tabela Login.
    pause
    exit /b
)

echo Novo vistoriador: %NOME_NOVO% (ID=%ID_NOVO%, CPF=%CPF_NOVO_CONF%)

echo ====================================================
echo Buscando OSs pela placa %PLACA%...
echo ====================================================
echo.
sqlcmd -S %SQL_SERVER% -d %SQL_DB% -U "%SQL_USER%" -P "%SQL_PASS%" -W -s "," -Q "SET NOCOUNT ON; SELECT IdentificadorOrdemServico, DataHora, IdVistoriador, CpfVistoriador FROM OrdemServico WHERE Placa='%PLACA%' ORDER BY DataCadastro DESC"
echo.
set /p OS_ID=Digite o Identificador da OS que deseja atualizar: 

echo ====================================================
echo Atualizando OS %OS_ID%...
echo ====================================================

sqlcmd -S %SQL_SERVER% -d %SQL_DB% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "UPDATE OrdemServico SET IdVistoriador='%ID_NOVO%', CpfVistoriador='%CPF_NOVO%' WHERE IdentificadorOrdemServico='%OS_ID%'"

echo ====================================================
echo OS %OS_ID% atualizada com sucesso!
echo ====================================================
timeout /t 2 >nul
cls
echo ====================================================
echo Para concluir Feche o Sistema V1 
echo ====================================================

pause
