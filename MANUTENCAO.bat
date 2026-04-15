@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
chcp 65001 >nul
title Reinicia Camera

:: ===============================
::          09/04/2026
:: ===============================
:: ADIÇÃO DA CONFIGURAÇÃO POR MAC
:: ADIÇÃO DE VERIFICAÇÃO DE FRAME PRETO
:: BACKUP DO HOSTS E CRIAÇÃO DE UM ARQUIVO NOVO
:: ===============================
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

mode con cols=41 lines=10
::ciano
	set "b=[96m"
::verde
	set "g=[92m"
::vermelho
	set "r=[91m"
::vermelho
	set "r=[91m"
:: Azul
	set "d=[38;5;39m"
::branco
	set w=[97m
:: Amarelo claro
	set "y=[93m"
:: ===============================
:: VARIÁVEIS
:: ===============================
set TOTAL=8
set STEP=0

set "APP_PATH=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe"
set "CONFIG_FILE=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"

:: ===============================
:: EXECUÇÃO
:: ===============================

call :Step "FECHANDO FENOX V1"
call :FechaV1

call :Step "ATUALIZANDO IP NO V1"
call :IPV1

call :Step "CONFIGURANDO IPLISTEN"
call :IPLISTEN

call :Step "AJUSTANDO IP CAM"
call :AJUSTEIP

call :Step "PARANDO SERVICOS"
call :StopServices

call :Step "INICIANDO SERVICOS"
call :StartServices

call :Step "VERIFICANDO IMAGENS"
call :imagemescura

call :Step "ABRINDO FENOX V1"
call :AbreV1

call :LIMPEZA

echo ========================================
echo     PROCESSO CONCLUIDO COM SUCESSO
echo ========================================

exit

:: =================================================
:: CONTROLE DE PROGRESSO
:: =================================================
:Step
set /a STEP+=1
call :Progress %STEP% %TOTAL% "%~1"
exit /b

:Progress
setlocal EnableDelayedExpansion
chcp 65001 >nul
set CUR=%1
set MAX=%2
set TXT=%~3

set /a PCT=(CUR*100)/MAX
set /a FILL=(CUR*20)/MAX

set BAR=
for /L %%i in (1,1,!FILL!) do set BAR=!BAR!#
for /L %%i in (!FILL!,1,19) do set BAR=!BAR!-

cls
echo.
echo %b% ═══════════════════════════════════════
echo  ███          %d%  MANAGER  %b%            ███
echo  ═══════════════════════════════════════
echo.
echo       [ %w% !BAR! %b% ] %y% !PCT!%%
echo.
echo   %b% Etapa: %w% !TXT!
echo.
endlocal & timeout /t 1 >nul & exit /b

:: =================================================
:: FUNÇÕES
:: =================================================
:FechaV1
powershell -NoProfile -Command ^
 "Get-Process Fnx64bits -ErrorAction SilentlyContinue | Stop-Process -Force"
exit /b

:IPV1
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f %%B in ("%%A") do (
        set IP=%%B
        goto :gotIP
    )
)
:gotIP
set IP=%IP: =%
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "& { (Get-Content '%CONFIG_FILE%') -replace 'http://.*:8080','http://%IP%:8080' | Set-Content '%CONFIG_FILE%' }"
exit /b

:IPLISTEN
for /f "tokens=*" %%i in ('netsh http show iplisten ^| findstr /R "[0-9]\."') do (
    netsh http delete iplisten ip=%%i >nul
)

netsh http add iplisten ip=%IP% >nul
netsh http add iplisten ip=127.0.0.1 >nul
ipconfig /flushdns >nul
exit /b

:StopServices
for %%S in (SisOcrOffline SisAviCreator SisMonitorOffline MMFnx) do sc stop %%S >nul
timeout /t 2 >nul
taskkill /F /IM SisAviCreator.exe SisMonitorOffline.exe SSisOCR.Offline.Service.exe FenoxSM.exe >nul 2>&1
exit /b

:StartServices
for %%S in (SisOcrOffline SisAviCreator SisMonitorOffline MMFnx) do sc start %%S >nul
iisreset /restart >nul
exit /b

:AbreV1
start "" "%APP_PATH%"
exit /b

:AJUSTEIP
set "INI_FILE=C:\captura\sensor.ini"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "HOSTS_BACKUP=%SystemRoot%\System32\drivers\etc\hosts.bak"
set "TEMP_HOSTS=%TEMP%\hosts_new.txt"

if not exist "%INI_FILE%" exit /b

:: Verifica se a seção [CANALXMAC] existe
findstr /i /c:"[CANALXMAC]" "%INI_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Seção [CANALXMAC] não encontrada.
    goto :FIM_SCRIP
)

:: --- LOGICA DE BACKUP E RESET ---
:: Cria backup (sobrescreve se já existir)
copy /y "%HOSTS_FILE%" "%HOSTS_BACKUP%" >nul
:: Remove atributo de somente leitura para poder alterar
attrib -r "%HOSTS_FILE%" 2>nul
:: Cria um arquivo temporário vazio (isso garante que o novo hosts só terá o que o script achar)
type nul > "%TEMP_HOSTS%"

set "PREFIXO=ca"
:: Tenta detectar se o padrão é 'c' ou 'ca' com base no INI ou padrão anterior
:: (Mantido da sua lógica original)
set "inSection=0"
set "HAS_CHANGES=0"

for /f "usebackq tokens=1,2 delims==" %%A in ("%INI_FILE%") do (
    set "line=%%A"
    if /i "!line!"=="[CANALXMAC]" (
        set "inSection=1"
    ) else (
        echo !line! | findstr /r "^\[" >nul
        if !errorlevel! == 0 set "inSection=0"
        
        if !inSection! == 1 (
            set "CANAL_STR=%%A"
            set "MAC_INI=%%B"
            if defined MAC_INI (
                set "MAC_SEARCH=!MAC_INI::=-!"
                set "NUM=!CANAL_STR:~-2!"
                if "!NUM:~0,1!"=="0" set "NUM=!NUM:~1!"
                set "HOSTNAME=!PREFIXO!!NUM!"
                
                set "IP_FOUND="
                for /f "tokens=1" %%I in ('arp -a ^| findstr /i /c:"!MAC_SEARCH!"') do (
                    set "IP_FOUND=%%I"
                )

                if defined IP_FOUND (
                    echo !IP_FOUND! !HOSTNAME!>> "%TEMP_HOSTS%"
                    set "HAS_CHANGES=1"
                )
            )
        )
    )
)

:: Se foram encontrados IPs, substitui o arquivo hosts original pelo novo
if !HAS_CHANGES! equ 1 (
    :: Remove linhas vazias extras e salva por cima do original
    findstr /v /r "^$" "%TEMP_HOSTS%" > "%TEMP%\hosts_clean.txt"
    chcp 1252 >nul
    copy /y "%TEMP%\hosts_clean.txt" "%HOSTS_FILE%" >nul
    del "%TEMP%\hosts_clean.txt" 2>nul
)

del "%TEMP_HOSTS%" 2>nul

:: Reinicia cache DNS
net stop dnscache >nul 2>&1
ipconfig /flushdns >nul 2>&1
net start dnscache >nul 2>&1

:FIM_SCRIP
exit /b

:FIM_SCRIP
exit /b

:imagemescura
set "folder=C:\captura\preview"
set "threshold=8300"
set "lista_erros="

if not exist "%folder%" exit /b

pushd "%folder%"
for %%F in (*.png) do (
    set "filename=%%~nF"
    set "filesize=%%~zF"

    echo !filename! | findstr /i "temp" >nul
    if errorlevel 1 (
        if !filesize! LEQ %threshold% (
            set "lista_erros=!lista_erros! CAMERA: !filename!,"
        )
    )
)
popd

if not "!lista_erros!"=="" (
    set "lista_erros=!lista_erros:~0,-1!"
    
    :: Utilizamos a concatenacao do PowerShell para inserir as quebras de linha reais
    powershell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework; $msg = 'CAMERAS SEM IMAGEM: !lista_erros!.' + [Environment]::NewLine + [Environment]::NewLine + 'Favor entrar em contato com o suporte.'; [System.Windows.MessageBox]::Show($msg, '', 'OK', 'Error')"
)
exit /b

:LIMPEZA
	powershell -Command "Get-ChildItem -Path \"%TEMP%\" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue"
