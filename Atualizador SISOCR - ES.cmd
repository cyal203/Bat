@echo off
COLOR 1f
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
cls
REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao...
wmic datafile where name="C:\\Program Files (x86)\\FNX\\SisOcr Offline\\SisOCR.Offline.Service.exe" get Version
pause
cls
REM ******************* PARA SISOCR ****************
echo Parando Servico...
sc stop SisOcrOffline
cls
REM ******************* BAIXA A NOVA VERSAO SISOCR ****************
echo Efetuando Download versao 7.3.5.0...
curl -g -k -L -# -o "%temp%\SisOcrOffline7350.zip" "https://update.fenoxapp.com.br/ModoOff/Install/Ocr/SisOcrOffline7350.zip" >nul 2>&1
cls
REM ******************* EXTRAI NOVO SISOCR ****************
echo Extraindo Arquivos...
powershell -NoProfile Expand-Archive '%temp%\SisOcrOffline7350.zip' -DestinationPath 'C:\SisOcr Offline' >nul 2>&1 
cls
REM ******************* MOVENDO SISOCR ****************
echo Movendo arquivos baixados...
REM /E: Copia todos os subdiretórios, incluindo os vazios.
REM /MOVE: Move os arquivos e diretórios, excluindo-os da origem após a cópia.
REM /R:3: Tenta reexecutar a cópia 3 vezes em caso de falha.
REM /W:5: Espera 5 segundos entre as tentativas.
robocopy "C:\SisOcr Offline" "C:\Program Files (x86)\FNX\SisOcr Offline" /E /MOVE /R:3 /W:5
cls
REM ******************* INICIA SISOCR ****************
echo Iniciando Serviço
sc start SisOcrOffline
cls
echo Finalizado
REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao...
wmic datafile where name="C:\\Program Files (x86)\\FNX\\SisOcr Offline\\SisOCR.Offline.Service.exe" get Version
pause

REM ******************* AJUSTANDO RESOLUÇÃO DE UPLOAD ****************
echo AJUSTANDO RESOLUÇÃO DE UPLOAD
setlocal enabledelayedexpansion

set "file=C:\captura\imgUp.ini"
set "tempfile=%file%.tmp"

if not exist "%file%" (
    echo O arquivo %file% não foi encontrado.
    exit /b 1
)

rem Cria um arquivo temporário e copia as linhas que não contêm X ou Y
(for /f "usebackq tokens=*" %%A in ("%file%") do (
    set "line=%%A"
    if not "!line:~0,2!"=="X=" if not "!line:~0,2!"=="Y=" (
        echo !line!
    )
)) > "%tempfile%"

rem Adiciona as novas linhas X=1024 e Y=768
echo X=1024>>"%tempfile%"
echo Y=768>>"%tempfile%"

rem Substitui o arquivo original pelo arquivo temporário
move /y "%tempfile%" "%file%"

echo Verificação e alteração concluídas.
exit /b 0
echo FINALIZADO...
pause
exit

