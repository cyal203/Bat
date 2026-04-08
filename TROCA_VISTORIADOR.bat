@echo off
:: VERSÃO COM INPUT MANUAL PARA ID VISTORIADOR BAHIA
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
if "%Admin%"=="ops" goto :eof
mode con: cols=54 lines=12
chcp 65001 >nul
::branco
	set w=[97m
::ciano
	set b=[96m
::verde
	set g=[92m
::vermelho
	set "r=[91m"
:: Amarelo claro	
	set "y=[93m"  
:: Azul claro      
	set "a=[94m"   
:: Reset
	set "reset=[0m"
:: Azul
	set "d=[38;5;39m" 
setlocal enabledelayedexpansion
:: Configurações do SQL Server
set "SQL_SERVER=localhost"
set "SQL_DB=SisviWcfLocal"
set "B64_USER=c2E="
set "B64_PASS=RjNOMFhmbng="

:: Decodificação de credenciais
for /f "delims=" %%A in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_USER%')).Trim()"') do set "SQL_USER=%%A"
for /f "delims=" %%B in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_PASS%')).Trim()"') do set "SQL_PASS=%%B"

:: --- SELEÇÃO DE ESTADO ---
cls
	echo. %b%
    echo ╔════════════════════════════════════════════════════╗
	echo ║                %w%Selecione o Estado:%b%                 ║
	echo ║                                                    ║
	echo ║               [%w%1%b%] - %d%Demais Estados%b%                 ║
	echo ║               [%w%2%b%] - %y%Bahia%b%                          ║
	echo ║                                                    ║
	echo ╚════════════════════════════════════════════════════╝
	echo.
set /p ESTADO=%w%Digite a Opção%b%: 

:: --- SELEÇÃO DE BUSCA ---
cls
	echo. %b%
    echo ╔════════════════════════════════════════════════════╗
	echo ║                %w%Escolha o tipo de busca:%b%            ║
	echo ║                                                    ║
	echo ║                [%w%1%b%] - %y%PLACA%b%                         ║
	echo ║                [%w%2%b%] - %r%CHASSI%b%                        ║
	echo ║                                                    ║
	echo ╚════════════════════════════════════════════════════╝
	echo.
set /p TIPO_BUSCA=%w%Digite:%b% 
cls
if "%TIPO_BUSCA%"=="1" (
	echo.
    set /p VALOR_BUSCA=%w%Digite a placa:%b% 
    set "CAMPO_BUSCA=Placa"
) else if "%TIPO_BUSCA%"=="2" (
	echo.
    set /p VALOR_BUSCA=%w%Digite o chassi:%b% 
    set "CAMPO_BUSCA=Chassi"
) else (
    echo Opcao invalida! & pause & exit /b
)

set /p CPF_NOVO=%w%CPF do Novo Vistoriador:%b% 

:: --- CONSULTA: Busca ID do Login via CPF ---
for /f "skip=2 tokens=1,2 delims=," %%a in ('sqlcmd -S %SQL_SERVER% -d %SQL_DB% -U "%SQL_USER%" -P "%SQL_PASS%" -W -s "," -Q "SET NOCOUNT ON; SELECT IdUsuario, Nome FROM Login WHERE CPF='%CPF_NOVO%'"') do (
    set ID_NOVO=%%a
    set NOME_NOVO=%%b
)

if "%ID_NOVO%"=="" (
    echo ERRO: CPF %CPF_NOVO% nao encontrado na tabela Login.
    pause & exit /b
)

:: --- INPUT MANUAL PARA BAHIA ---
set "ID_BAHIA_MANUAL="
if "%ESTADO%"=="2" (
    echo.
    echo ════════════════════════════════════════════════════
    echo ███     %r%ATENCAO:%b% %w%ESTADO DA BAHIA SELECIONADO%b%     ███
    echo ════════════════════════════════════════════════════
    echo.
	set /p ID_BAHIA_MANUAL=%w%Numero de Matricula Detran BA Vistoriador:%b%
    echo.
)

:: --- LISTAGEM DE OS PARA ESCOLHA ---
cls
echo Vistoriador encontrado: %NOME_NOVO% (ID: %ID_NOVO%)
echo.
echo Buscando OS por %CAMPO_BUSCA% %VALOR_BUSCA%...
sqlcmd -S %SQL_SERVER% -d %SQL_DB% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "SELECT IdentificadorOrdemServico, DataHora, Placa, Chassi FROM OrdemServico WHERE %CAMPO_BUSCA%='%VALOR_BUSCA%' ORDER BY DataCadastro DESC" -W -s ","

echo.

set /p OS_ID=%w%Número da OS:%b% 

:: --- EXECUÇÃO DO UPDATE CONFORME O ESTADO ---
echo.
if "%ESTADO%"=="2" (
    echo Executando Update Bahia...
    sqlcmd -S %SQL_SERVER% -d %SQL_DB% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "UPDATE OrdemServico SET cpfvistoriador = '%CPF_NOVO%', idvistoriador = '%ID_NOVO%', IdUsuarioIntegracao = '%ID_NOVO%', idvistoriadorbahia = '%ID_BAHIA_MANUAL%' where IdentificadorOrdemServico = '%OS_ID%'"
	
) else (
    echo Executando Update Padrao...
    sqlcmd -S %SQL_SERVER% -d %SQL_DB% -U "%SQL_USER%" -P "%SQL_PASS%" -Q "UPDATE OrdemServico SET idvistoriador = '%ID_NOVO%', cpfvistoriador = '%CPF_NOVO%', IdUsuarioIntegracao = '%ID_NOVO%' WHERE IdentificadorOrdemServico = '%OS_ID%'"
)

echo.
echo ════════════════════════════════════════════════════
echo ███     %w%OS %VALOR_BUSCA% atualizada com sucesso %b%       ███
echo ════════════════════════════════════════════════════
timeout /t 2 >nul
taskkill /IM Fnx64bits.exe /F >nul 2>&1
start "" "C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe"
exit /b
