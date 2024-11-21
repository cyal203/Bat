@echo off
SET SERVER_NAME=localhost
SET USER_NAME=sa
SET PASSWORD=F3N0Xfnx
SET DATABASE_NAME=SisviWcfLocal
SET BACKUP_PATH=C:\captura\SisviWcfLocal_backup.bak

REM Exclui o arquivo de backup se já existir
IF EXIST "%BACKUP_PATH%" (
    DEL /Q "%BACKUP_PATH%"
)

REM Executa o comando de backup
sqlcmd -S %SERVER_NAME% -U %USER_NAME% -P %PASSWORD% -Q "BACKUP DATABASE [%DATABASE_NAME%] TO DISK = '%BACKUP_PATH%' WITH FORMAT;"
echo.
echo Backup Salvo na pasta C:\captura\SisviWcfLocal_backup.bak !
pause

