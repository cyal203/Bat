@echo off
COLOR 1f
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
cls
REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao V1 e WCF...
wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version && wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
pause
cls
REM ******************* PARA SISOCR ****************
echo Parando Inetmgr...
iisreset /stop
cls
REM ******************* BAIXA A NOVA VERSAO ****************
echo Efetuando Download da nova versao 1.7.0.12...
curl -g -k -L -# -o "%temp%\WCFLocalFenox_1.7.0.12_x86.exe" "https://update.fenoxapp.com.br/Executaveis/ServicoLocal/WCFLocalFenox_1.7.0.12_x86.exe" >nul 2>&1
cls


REM ******************* RENOMEANDO WCF ****************
ren C:\WCFLOCAL WCFLOCAL.old2
REM ******************* EXECUTANDO INSTALADOR ****************
%temp%\WCFLocalFenox_1.7.0.12_x86.exe 


cls
REM ******************* INICIA SISOCR ****************
echo Iniciando Serviço
iisreset /start
cls
echo Finalizado
REM ******************* VERIFICA VERSAO ****************
echo Verificando a versao...
wmic datafile where name="C:\\Program Files (x86)\\FNX\\SisOcr Offline\\SisOCR.Offline.Service.exe" get Version
pause

REM ******************* AJUSTANDO RESOLUÇÃO DE UPLOAD ****************


:menu1

Set /p op= DESEJA ALTERAR A RESOLUCAO DE UP PARA 1024X768 (S/N):
if %op% equ s goto s
if %op% equ n goto n
if %op% equ S goto s
if %op% equ N goto n

:n
exit


:s
echo AJUSTANDO RESOLUCAO DE UPLOAD
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

echo Verificacao e alteracao concluidas.
exit /b 0
echo FINALIZADO...
pause
exit

