@echo off
chcp 65001 >nul
::--------15/04/2026-------------
	title ATUALIZADOR GERAL
::==========================
::EXECUTA COMO ADMINISTRADOR
::==========================
	SET "params=%*"
	cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo SET UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
	if "%Admin%"=="ops" goto :eof
	mode con: cols=50 lines=17
	SETlocal enabledelayedexpansion
	SET Version=4
::branco	
	SET w=[97m
::SET p=[95m
::ciano
	SET b=[96m
::verde
	SET g=[92m
::vermelho
	SET "r=[91m"
:: Amarelo claro	
	SET "y=[93m"  
:: Azul claro      
	SET "a=[94m"   
:: ReSET
	SET "reSET=[0m"
:: Azul
	SET "d=[38;5;39m"
	
	
%B%

	cls
	echo.
	echo.
	echo              ╔══════════════════════════╗
	echo              ║       %g%    MENU%b%           ║
	echo              ║                          ║	
	echo              ║  %r%Atualizar V1 Por estado%b% ║
	echo              ╚══════════════════════════╝
	echo.
	echo              [%w%1%b%]%w% SP%b%     [%w%2%b%]%w% MG%b%     
	echo.             
	echo              [%w%3%b%]%w% ES%b%     [%w%4%b%]%w% GO%b%
	echo.             
	echo              [%w%5%b%]%w% MS%b%     [%w%6%b%]%w% DF%b%
	echo.             
	echo              [%w%7%b%]%w% BA%b%     [%w%8%b%]%w% PB%b%
	echo.             
	echo              [%w%9%b%]%w% PA%b%
	echo.
	SET /p option0=%w%_Digite:%b%
	if %option0%==0 goto exit
	if %option0%==1 goto SP
	if %option0%==2 goto MG
	if %option0%==3 goto ES
	if %option0%==4 goto GO
	if %option0%==5 goto MS
	if %option0%==6 goto DF
	if %option0%==7 goto BA
	if %option0%==8 goto PB
	if %option0%==9 goto PA

::===========================
:: SETUP ESTADOS
::===========================
:SP
	cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%y%FENOX_APP%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto SP_FENOXAPP
	if %option0%==2 goto SP_ONE_DRIVE
	
:SP_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQB9QeN_WpZiRYKQ__vS89G-AXMPbY4HNJPJlcKOTzBYylY?e=Wj0Ck3&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQAorZn1PcrFQ6mOIhjdYnn8AT9NSSY7UEn8QC6CVixmL3c?e=mzS7UF&download=1"
	SET UF=SP
	SET VERSAO= 1.0.0.7
	SET VERSAOINST=Fnx_1.0.0.7_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.0.0.7_x86.exe
goto :CONTINUE

:SP_FENOXAPP
	SET "LINKV1=http://update.fenoxapp.com.br/Executaveis/EmissaoLaudos/Fnx_1.0.0.7_x64.exe"
	SET "LINKWCF=http://update.fenoxapp.com.br/Executaveis/ServicoLocal/WCFLocalFenox_1.0.0.7_x86.exe"
	SET UF=SP
	SET VERSAO= 1.0.0.7
	SET VERSAOINST=Fnx_1.0.0.7_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.0.0.7_x86.exe
goto :CONTINUE

:MG
	cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%y%FENOX_APP%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto MG_FENOXAPP
	if %option0%==2 goto MG_ONE_DRIVE

:MG_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQCesllIVYaVRZAIxkWejRsiAeQn_prH0oFx7V3rLZXbHQU?e=q61uI4&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQD46PFuiZ8WRYdhNiE4nFfpAXSG4dbxn7-M0at-svu34zA?e=10UazZ&download=1"
	SET UF=MG
	SET VERSAO= 1.8.0.7
	SET VERSAOINST=Fnx_1.8.0.7_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.8.0.7_x86.exe
goto :CONTINUE

:MG_FENOXAPP
	SET "LINKV1=https://downloads.fenoxapp.com.br/Fnx_1.8.0.7_x64.exe"
	SET "LINKWCF=https://update.fenoxapp.com.br/Executaveis/ServicoLocal/WCFLocalFenox_1.8.0.7_x86.exe"
	SET UF=MG
	SET VERSAO= 1.8.0.7
	SET VERSAOINST=Fnx_1.8.0.7_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.8.0.7_x86.exe
goto :CONTINUE

:ES
	cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%y%ONE_DRIVE%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto ES_FENOXAPP
	if %option0%==2 goto ES_ONE_DRIVE

:ES_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDr4FCQkw_HSb45yvST7ideAYIzezHd_VYiEEDiEB3ub58?e=0oHi6Y&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQC8qIC0NkGsRYAWj2RWt_aKAYIK6LitXXWnIn-QH5DQkyM?e=wkbHI2&download=1"
	SET UF=ES
	SET VERSAO=1.3.0.20
	SET VERSAOINST=Fnx_1.3.0.20_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.3.0.20_x86.exe
goto :CONTINUE

:ES_FENOXAPP
SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDr4FCQkw_HSb45yvST7ideAYIzezHd_VYiEEDiEB3ub58?e=0oHi6Y&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQC8qIC0NkGsRYAWj2RWt_aKAYIK6LitXXWnIn-QH5DQkyM?e=wkbHI2&download=1"
	SET UF=ES
	SET VERSAO=1.3.0.20
	SET VERSAOINST=Fnx_1.3.0.20_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.3.0.20_x86.exe
goto :CONTINUE

:GO
	cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%y%FENOX_APP%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto GO_FENOXAPP
	if %option0%==2 goto GO_ONE_DRIVE
:GO_ONE_DRIVE	
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQCc3_IDhtfwQJrxoR4unmVHAXYLOeWe804cBitM-Et-Nvc?e=2MJNVJ&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQB0E3t2bFOXSYTIyn7x8iolAXdaLIOsC2nyQlyvjR0DMJI?e=6kTcCv&download=1"
	SET UF=GO
	SET VERSAO=1.7.0.11
	SET VERSAOINST=Fnx_1.7.0.11_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.7.0.10_x86.exe
goto :CONTINUE

:GO_FENOXAPP
	SET "LINKV1=http://update.fenoxapp.com.br/Executaveis/EmissaoLaudos/Fnx_1.7.0.11_x64.exe"
	SET "LINKWCF=http://update.fenoxapp.com.br/Executaveis/ServicoLocal/WCFLocalFenox_1.7.0.10_x86.exe"
	SET UF=GO
	SET VERSAO=1.7.0.11
	SET VERSAOINST=Fnx_1.7.0.11_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.7.0.10_x86.exe
goto :CONTINUE

:MS
cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%y%FENOX_APP%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto MS_FENOXAPP
	if %option0%==2 goto MS_ONE_DRIVE
:MS_FENOXAPP	
	SET "LINKV1=https://downloads.fenoxapp.com.br/Fnx_1.2.0.6_x64.exe"
	SET "LINKWCF=https://downloads.fenoxapp.com.br/WCFLocalFenox_1.2.0.6_x86.exe"
	SET UF=MS
	SET VERSAO= 1.2.0.6
	SET VERSAOINST=Fnx_1.2.0.6_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.2.0.6_x86.exe
goto :CONTINUE
:MS_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQA8fpkoY0CDTaKnCVXgFV9vAZJc-skVhFVkJ-EZXlq3ce0?e=XINbhM&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQBV-tJiY6gGQbWrjkZyhxFoAWQyalIn6M8ftZ_g4Zb58m4?e=73SjX4&download=1"
	SET UF=MS
	SET VERSAO= 1.2.0.6
	SET VERSAOINST=Fnx_1.2.0.6_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.2.0.6_x86.exe
goto :CONTINUE

:DF
cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%d%FENOX_APP%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto DF_FENOXAPP
	if %option0%==2 goto DF_ONE_DRIVE
:DF_FENOXAPP	
	SET "LINKV1=https://update.fenoxapp.com.br/Executaveis/EmissaoLaudos/Fnx_1.4.0.9_x64.exe"
	SET "LINKWCF=https://update.fenoxapp.com.br/Executaveis/ServicoLocal/WCFLocalFenox_1.4.0.9_x86.exe"
	SET UF=DF
	SET VERSAO= 1.4.0.9
	SET VERSAOINST=Fnx_1.4.0.9_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.4.0.9_x86.exe
goto :CONTINUE
:DF_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQABHiQz31GHQprmT0LThT67AdybLxQ0-z_3zMfG_Ku4veY?e=POE34W&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDK4jkFTrNERrGQuf5QqFDiAUPnQZSp6ZjQ92uq6ZuX8Lo?e=qc78cH&download=1"
	SET UF=DF
	SET VERSAO= 1.4.0.9
	SET VERSAOINST=Fnx_1.4.0.9_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.4.0.9_x86.exe
goto :CONTINUE

:BA
	cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%d%ONE_DRIVE%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto BA_FENOXAPP
	if %option0%==2 goto BA_ONE_DRIVE
:BA_FENOXAPP	
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQBjE4hHPnnCQq2x3ZR1bGAkAe9XZznkaH7Sxi6qDOg-9pQ?e=1dWP5g&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDVyshPWrWMQYoeYS-Sg0NwAcE7BUuiHKHONZkk8k8RRQ4?e=HqbYkn&download=1"
	SET UF=BA
	SET VERSAO=1.5.0.10
	SET VERSAOINST=Fnx_1.5.0.10_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.5.0.10_x86.exe
goto :CONTINUE
:BA_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQBjE4hHPnnCQq2x3ZR1bGAkAe9XZznkaH7Sxi6qDOg-9pQ?e=1dWP5g&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDVyshPWrWMQYoeYS-Sg0NwAcE7BUuiHKHONZkk8k8RRQ4?e=HqbYkn&download=1"
	SET UF=BA
	SET VERSAO=1.5.0.10
	SET VERSAOINST=Fnx_1.5.0.10_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.5.0.10_x86.exe
goto :CONTINUE

:PB
	cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%d%ONE_DRIVE%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto PB_FENOXAPP
	if %option0%==2 goto PB_ONE_DRIVE
:PB_FENOXAPP	
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQCZQCTmfJX7TYSyMlLjDmP6AXiwbd4qxe9YieKDhY9kiEA?e=BFKMrU&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDZinRyPuqgRpxw7mmK1RmXAVxjq02NjH0H68XhXOJ_i2A?e=8UkkKn&download=1"
	SET UF=PB
	SET VERSAO= 1.6.0.1
	SET VERSAOINST=Fnx_1.6.0.1_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.6.0.1_x86.exe
goto :CONTINUE
:PB_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQCZQCTmfJX7TYSyMlLjDmP6AXiwbd4qxe9YieKDhY9kiEA?e=BFKMrU&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDZinRyPuqgRpxw7mmK1RmXAVxjq02NjH0H68XhXOJ_i2A?e=8UkkKn&download=1"
	SET UF=PB
	SET VERSAO= 1.6.0.1
	SET VERSAOINST=Fnx_1.6.0.1_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.6.0.1_x86.exe
goto :CONTINUE

:PA
	cls
	echo        ╔════════════════════════╗
	echo        ║       %g%SERVIDOR%b%         ║
	echo        ╚════════════════════════╝
	echo.
	echo          [%w%1%b%]%d%ONE_DRIVE%b%
	echo          [%w%2%b%]%d%ONE_DRIVE%b%
	echo.
	SET /p option0= %w%_SELECIONE:%b%

	if %option0%==1 goto PA_FENOXAPP
	if %option0%==2 goto PA_ONE_DRIVE
:PA_FENOXAPP
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQCLk2jhLKDyS4yk2sih3dHJAfxD0MNPZt2HNab6uuT_vOk?e=jOGsGt&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDtUeifV4XZS64HkIHPaEZSAUWIQ8N36gcJttHPHfEh_Bo?e=Ba4iBD&download=1"
	SET "LINKCONFIG=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQA2SuyG80SzQoae-cXwAAQcAbwMLCQujr_QPcbQdpS9514?e=uNIZ2C&download=1"
	SET UF=PA
	SET VERSAO= 1.1.0.2
	SET VERSAOINST=Fnx_1.1.0.2_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.1.0.2_x86.exe
goto :CONTINUE
:PA_ONE_DRIVE
	SET "LINKV1=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQCLk2jhLKDyS4yk2sih3dHJAfxD0MNPZt2HNab6uuT_vOk?e=jOGsGt&download=1"
	SET "LINKWCF=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQDtUeifV4XZS64HkIHPaEZSAUWIQ8N36gcJttHPHfEh_Bo?e=Ba4iBD&download=1"
	SET "LINKCONFIG=https://fenoxteccombr-my.sharepoint.com/:u:/g/personal/alan_silva_fenoxtec_com_br/IQA2SuyG80SzQoae-cXwAAQcAbwMLCQujr_QPcbQdpS9514?e=uNIZ2C&download=1"
	SET UF=PA
	SET VERSAO= 1.1.0.2
	SET VERSAOINST=Fnx_1.1.0.2_x64.exe
	SET VERSAOINSTWCF=WCFLocalFenox_1.1.0.2_x86.exe
goto :CONTINUE

::===========================
:: SETUP GERAL
::===========================	
:CONTINUE
	SET BACKUP_DIR=C:\captura\BackupDB
	SET BACKUP_PATH=%BACKUP_DIR%\SisviWcfLocal_backup.bak
::SET "DIR_CONFIG=C:\Program Files (x86)\Fenox V1.0"
	SET passos=08
	SET passos2=04
	SET "ARQ=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"
	SET "TEMPO=00:45:00"
	SET "EXE=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe"
	cls


echo         ╔══════════════════════════╗
echo         ║                          ║
echo         ║  VERSÂO %y%%UF%%b% : %w%%VERSAO%%b%    ║
echo         ║                          ║
echo         ║                          ║
echo         ║    [%w%1%b%] - %g%DIGITACÃO%b%       ║
echo         ║    [%w%2%b%] - %r%SERVIDOR%b%        ║
echo         ║                          ║
echo         ╚══════════════════════════╝
	SET /p option= Escolha uma Opcão:
	if %option%==1 goto digitacao
	if %option%==2 goto SERVIDOR

:SERVIDOR
cls
call :VERSAO_GERAL
REM ******************* PARA INETMGR ****************
	echo.
	cls
	call :SHOW_PROGRESS 01 %passos%
	iisreSET /stop  >nul
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
	echo.
	echo Efetuando Download da nova versao %VERSAO%...
::curl -g -k -L -# -f -o "%temp%\%VERSAOINST%" "%LINKV1%"
	powershell -Command "Start-BitsTransfer -Source '%LINKV1%' -Destination '%temp%\%VERSAOINST%'"
	echo Download WCF....
::curl -g -k -L -# -f -o "%temp%\%VERSAOINSTWCF%" "%LINKWCF%"
	powershell -Command "Start-BitsTransfer -Source '%LINKWCF%' -Destination '%temp%\%VERSAOINSTWCF%'"

	cls
	call :SHOW_PROGRESS 03 %passos%

	timeout /t 2 /nobreak >nul
REM ******************* INSTALANDO ****************
	cls
	call :SHOW_PROGRESS 04 %passos%
	%temp%\%VERSAOINST% /silent
	%temp%\%VERSAOINSTWCF% /silent
	timeout /t 2 /nobreak >nul
	cls
REM Obtém o IPv4 do computador
	for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do for /f "tokens=1 delims= " %%j in ("%%i") do SET IP=%%j  >nul
REM Remove espaços em branco
	SET IP=%IP: =%
REM Caminho do arquivo de configuração
	SET FILE="C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"  >nul
REM Substitui o endereço IP no arquivo usando PowerShell
	powershell -Command "(Get-Content '%FILE%') -replace 'http://.*:8080', 'http://%IP%:8080' | SET-Content '%FILE%'"  >nul
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
	iisreSET /start  >nul
	sc start SisMonitorOffline  >nul
	sc start SisOcrOffline  >nul
	sc start SisAviCreator  >nul
	timeout /t 2 /nobreak >nul
	cls
	call :SHOW_PROGRESS 07 %passos%
:: =============================================
:: COMANDO DE BACKUP SQL
:: =============================================
::Verifica se a pasta existe
SET "pasta=C:\captura\BackupDB"
if not exist "%pasta%" (
    echo Pasta nao encontrada. Criando...
    mkdir "%pasta%"
) else (
    echo A pasta ja existe. >nul
)
	SET "SQL_SERVER=localhost"
	SET "SQL_DB=SisviWcfLocal"
	SET "BACKUP_DIR=C:\captura\BackupDB"
	icacls "%BACKUP_DIR%" /grant "NT SERVICE\MSSQLSERVER":(OI)(CI)F >nul 2>&1
	for /f "tokens=1-3 delims=/ " %%a in ("%date%") do (
    SET "day=%%a"
    SET "month=%%b"
    SET "year=%%c"
)
:: Formatar com dois dígitos
	if "!day:~1!"=="" SET "day=0!day!"
	if "!month:~1!"=="" SET "month=0!month!"
	SET "BACKUP_FILE=!BACKUP_DIR!\SisviWcfLocal_backup_!day!_!month!_!year!.bak"
	SET "SQL_SERVER=localhost"
	SET "SQL_DB=SisviWcfLocal"
	SET "B64_USER=c2E="
	SET "B64_PASS=RjNOMFhmbng="
	SET "BACKUP_DIR=C:\captura\BackupDB"
	SET SQL_FILE=C:\WCFLOCAL\UpdateDB\SWLModel.sql
	
	for /f "delims=" %%A in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_USER%')).Trim()"') do (
    SET "SQL_USER=%%A"
)
	for /f "delims=" %%B in ('powershell -noprofile -command "[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('%B64_PASS%')).Trim()"') do (
    SET "SQL_PASS=%%B"
)

:: Garante permissão para o SQL Server gravar na pasta
icacls "%BACKUP_DIR%" /grant "NT SERVICE\MSSQLSERVER":(OI)(CI)F >nul 2>&1

:: Obtém data e hora no formato YYYYMMDD_HHMMSS
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do SET "datetime=%%G"
::SET "backup_timestamp=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"
SET "backup_timestamp=%datetime:~6,2%%datetime:~4,2%%datetime:~0,4%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"

:: Define o nome do arquivo de backup
SET "BACKUP_FILE=%BACKUP_DIR%\%SQL_DB%_%backup_timestamp%.bak"
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
::CONFIG PA
	call :CONFIG_PA	
	timeout /t 2 /nobreak >nul
	cls
	call :SHOW_PROGRESS 08 %passos%
	timeout /t 2 /nobreak >nul
	cls
	echo.
	echo   ═══════════════════════════════════
	echo   ███  %w%INSTALACAO CONCLUIDA. . .%b%  ███
	echo   ═══════════════════════════════════

::******************* VERIFICA VERSAO ****************
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
	timeout /t 1 >nul
::AJUSTA TIMEOUT
net session >nul 2>&1
if %errorlevel% NEQ 0 (
  echo Solicitando permissao de administrador...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

if not exist "%ARQ%" (
  echo Arquivo nao encontrado: "%ARQ%"
  pause
  exit /b 1
)

REM Backup simples
copy /y "%ARQ%" "%ARQ%.bak" >nul
echo Backup criado em: "%ARQ%.bak"

REM --- Metodo 1 (preferencial): editar como XML e alterar TODAS as ocorrencias ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p = '%ARQ%'; $TEMPO = '%TEMPO%';" ^
  "[xml]$x = Get-Content -Raw $p;" ^
  "$atts = $x.SelectNodes('//@*');" ^
  "foreach($a in $atts){ $n = $a.Name.ToLowerInvariant(); if($n -eq 'receivetimeout' -or $n -eq 'sendtimeout'){ $a.Value = $TEMPO } }" ^
  ";$x.Save($p)"
start "" "%EXE%"
timeout /t 2 /nobreak >nul
call :LIMPEZA
exit

:DIGITACAO
REM ******************* VERIFICA VERSAO ****************
call :VERSAO_GERAL	
REM ******************* BAIXA A NOVA VERSAO ****************
	cls
	call :SHOW_PROGRESS 01 %passos2%
	echo Efetuando Download da versao %VERSAO%...
::curl -g -k -L -# -f -o "%temp%\%VERSAOINST%" "%LINKV1%"
	powershell -Command "Start-BitsTransfer -Source '%LINKV1%' -Destination '%temp%\%VERSAOINST%'"
	cls
	
REM ******************* EXTRAI TEMPO V1 ****************
	timeout /t 2 /nobreak >nul
	cls
	call :SHOW_PROGRESS 02 %passos2%

REM ******************* INSTALANDO ****************
	timeout /t 2 /nobreak >nul
	cls
	call :SHOW_PROGRESS 03 %passos2%
	%temp%\%VERSAOINST% /silent
	timeout /t 2 /nobreak >nul
REM ******************* DELETA PASTAS ****************
	rmdir /s /q "C:\Program Files (x86)\Fenox V1.0.OLD1"  >nul
	del /f "C:\Program Files (x86)\Fenox V1.0\notasAtualizacao.html"  >nul
	timeout /t 2 /nobreak >nul
::CONFIG PA
	call :CONFIG_PA	
	cls
	call :SHOW_PROGRESS 04 %passos2%
	cls
	echo.
	echo   ═══════════════════════════════════
	echo   ███  %w%INSTALACAO CONCLUIDA. . .%b%  ███
	echo   ═══════════════════════════════════
	timeout /t 2 >nul
	echo %w%Fenox V1%b%
	wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
	timeout /t 2 /nobreak >nul
::AJUSTA TIMEOUT
net session >nul 2>&1
if %errorlevel% NEQ 0 (
  echo Solicitando permissao de administrador...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

if not exist "%ARQ%" (
  echo Arquivo nao encontrado: "%ARQ%"
  pause
  exit /b 1
)

REM Backup simples
copy /y "%ARQ%" "%ARQ%.bak" >nul
echo Backup criado em: "%ARQ%.bak"

REM --- Metodo 1 (preferencial): editar como XML e alterar TODAS as ocorrencias ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p = '%ARQ%'; $TEMPO = '%TEMPO%';" ^
  "[xml]$x = Get-Content -Raw $p;" ^
  "$atts = $x.SelectNodes('//@*');" ^
  "foreach($a in $atts){ $n = $a.Name.ToLowerInvariant(); if($n -eq 'receivetimeout' -or $n -eq 'sendtimeout'){ $a.Value = $TEMPO } }" ^
  ";$x.Save($p)"
start "" "%EXE%"
timeout /t 2 /nobreak >nul
call :LIMPEZA
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
:VERSAO_GERAL
	echo Verificando Versao...
	echo.
	echo %w%Fenox V1%b%
	wmic datafile where name="C:\\Program Files (x86)\\Fenox V1.0\\Fnx64bits.exe" get Version
	echo.
	echo %w%WCFLocal%b%
	wmic datafile where name="C:\\WCFLOCAL\\bin\\PrototipoMQ.Interface.WCF.dll" get Version
	echo Iniciando Instalação.....
	timeout /t 3 /nobreak >nul
	cls

:LIMPEZA
	powershell -Command "Get-ChildItem -Path \"%TEMP%\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"

:CONFIG_PA
REM --- VERIFICACAO PA ---
	if "%UF%"=="PA" (
	echo Baixando Configuracao especifica para PA...
	powershell -Command "Start-BitsTransfer -Source '%LINKCONFIG%' -Destination '%temp%\config.ini'"
	robocopy "%temp%" "C:\Program Files (x86)\Fenox V1.0" config.ini /MOV /NFL /NDL /NJH /NJS /NP
	)	
	timeout /t 2 /nobreak >nul 	
