@echo off
COLOR 1f
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
cls
REM ******************* BAIXA A NOVA VERSAO SISOCR ****************
echo Efetuando Download Driver Biometria...
curl -g -k -L -# -o "%temp%\EasyInstallation_v3.12.zip" "https://github.com/cyal203/PROGRAMAS/raw/main/EasyInstallation_v3.12.zip" >nul 2>&1
cls
REM ******************* EXTRAI NOVO SISOCR ****************
echo Extraindo Arquivos...
powershell -NoProfile Expand-Archive '%temp%\EasyInstallation_v3.12.zip' -DestinationPath 'c:\EasyInstallation_v3.12' >nul 2>&1 
cls

REM ******************* MOVENDO SISOCR ****************
echo Movendo Dlls...
REM /E: Copia todos os subdiretórios, incluindo os vazios.
REM /MOVE: Move os arquivos e diretórios, excluindo-os da origem após a cópia.
REM /R:3: Tenta reexecutar a cópia 3 vezes em caso de falha.
REM /W:5: Espera 5 segundos entre as tentativas.
copy "c:\EasyInstallation_v3.12\System32\" "C:\Windows\System32"
copy "c:\EasyInstallation_v3.12\SysWOW64\" "C:\Windows\SysWOW64"
pause
cls
REM ******************* INICIA SISOCR ****************
c:\EasyInstallation_v3.12\Setup.exe /silent
cls
echo FINALIZADO...
pause
exit


