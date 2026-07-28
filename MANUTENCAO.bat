@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
chcp 65001 >nul
title Reinicia Camera

:: ===============================
::          17/04/2026
:: ===============================
:: ADIÇÃO DA CONFIGURAÇÃO POR MAC
:: ADIÇÃO DE VERIFICAÇÃO DE FRAME PRETO
:: BACKUP DO HOSTS E CRIAÇÃO DE UM ARQUIVO NOVO
::CORREÇÃO DO PREFIXO CA / C
:: ===============================
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

mode con cols=70 lines=15
Reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: ===============================
:: PALETA "TECH"
:: ===============================
::ciano brilhante (acento principal)
	set "cy=[38;5;51m"
:: azul neon (secundario)
	set "bl=[38;5;39m"
:: ciano escuro (bordas)
	set "bd=[38;5;30m"
:: cinza (texto discreto)
	set "gy=[38;5;244m"
::branco (destaque)
	set "w=[97m"
::verde (sucesso)
	set "g=[92m"
:: amarelo (aviso)
	set "y=[93m"
::vermelho (erro)
	set "r=[91m"
:: reset
	set "rs=[0m"
:: compatibilidade com nomes usados no restante do script
	set "b=%cy%"
	set "d=%bl%"
:: ===============================
:: VARIÁVEIS
:: ===============================
set TOTAL=8
set STEP=0

set "APP_PATH=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe"
set "CONFIG_FILE=C:\Program Files (x86)\Fenox V1.0\Fnx64bits.exe.config"

:: ===============================
:: LOG
:: ===============================
set "LOG_DIR=C:\captura\Scripts\logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
for /f "usebackq" %%D in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HHmmss'"`) do set "LOG_STAMP=%%D"
set "LOG_FILE=%LOG_DIR%\MANUTENCAO_%LOG_STAMP%.log"
call :Log "===== INICIO DA EXECUCAO ====="
call :LimpaLogsAntigos

:: ===============================
:: EXECUÇÃO
:: ===============================

call :Step "FECHANDO FENOX V1"
call :Log "Etapa 1/8: Fechando Fenox V1"
call :FechaV1

call :Step "ATUALIZANDO IP NO V1"
call :Log "Etapa 2/8: Atualizando IP no V1"
call :IPV1

call :Step "CONFIGURANDO IPLISTEN"
call :Log "Etapa 3/8: Configurando IPLISTEN"
call :IPLISTEN

call :Step "AJUSTANDO IP CAM"
call :Log "Etapa 4/8: Ajustando IP das cameras (hosts)"
call :AJUSTEIP

call :Step "PARANDO SERVICOS"
call :Log "Etapa 5/8: Parando servicos"
call :StopServices

call :Step "INICIANDO SERVICOS"
call :Log "Etapa 6/8: Iniciando servicos"
call :StartServices

call :Step "VERIFICANDO IMAGENS"
call :Log "Etapa 7/8: Verificando imagens escuras"
call :imagemescura

call :Step "ABRINDO FENOX V1"
call :Log "Etapa 8/8: Abrindo Fenox V1"
call :AbreV1

call :LIMPEZA

cls
echo.
if defined ERRO_DETECTADO (
    call :Log "===== PROCESSO CONCLUIDO COM AVISOS/ERROS - verifique o log ====="
    echo   %y%╔══════════════════════════════════════════════════════════════╗%rs%
    echo   %y%║%rs%               %w%⚠  PROCESSO CONCLUIDO COM AVISOS%rs%               %y%║%rs%
    echo   %y%╚══════════════════════════════════════════════════════════════╝%rs%
    echo.
    echo   %gy%Verifique o log:%rs% %w%%LOG_FILE%%rs%
) else (
    call :Log "===== PROCESSO CONCLUIDO COM SUCESSO ====="
    echo   %g%╔══════════════════════════════════════════════════════════════╗%rs%
    echo   %g%║%rs%              %w%✓  PROCESSO CONCLUIDO COM SUCESSO%rs%               %g%║%rs%
    echo   %g%╚══════════════════════════════════════════════════════════════╝%rs%
    echo.
    echo   %gy%Log salvo em:%rs% %w%%LOG_FILE%%rs%
)
echo.
timeout /t 3 >nul

exit

:: =================================================
:: LOG
:: =================================================
:Log
setlocal EnableDelayedExpansion
set "MSG=%~1"
for /f "usebackq" %%T in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) do set "TS=%%T"
>> "%LOG_FILE%" echo [!TS!] !MSG!
endlocal
exit /b

:LimpaLogsAntigos
setlocal EnableDelayedExpansion
set "MANTER=10"
set "CONT=0"
for /f "delims=" %%F in ('dir /b /a-d /o-d "%LOG_DIR%\MANUTENCAO_*.log" 2^>nul') do (
    set /a CONT+=1
    if !CONT! GTR %MANTER% (
        del /q "%LOG_DIR%\%%F" 2>nul
    )
)
endlocal
exit /b

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
set /a FILL=(CUR*58)/MAX
set /a REST=58-FILL

set "BARFILL="
set "BAREMPTY="
for /L %%i in (1,1,!FILL!) do set "BARFILL=!BARFILL!█"
for /L %%i in (1,1,!REST!) do set "BAREMPTY=!BAREMPTY!░"

cls
echo.
echo   %bd%╔══════════════════════════════════════════════════════════════╗%rs%
echo   %bd%║%rs%          %cy%FENOX SYSTEMS%rs%  %gy%•%rs%  %w%MANUTENCAO AUTOMATIZADA%rs%           %bd%║%rs%
echo   %bd%╚══════════════════════════════════════════════════════════════╝%rs%
echo.
echo   %gy%ETAPA%rs% %w%[!CUR!/!MAX!]%rs%    %cy%!TXT!%rs%
echo.
echo   %cy%!BARFILL!%gy%!BAREMPTY!%rs%   %w%!PCT!%%%rs%
echo.
echo   %gy%──────────────────────────────────────────────────────────────%rs%
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
set "IP="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do set "IP=%%A"
set "IP=%IP: =%"

if not defined IP (
    call :Log "[ERRO] Nao foi possivel detectar um IPv4 valido. Etapa IPV1 abortada."
    set "ERRO_DETECTADO=1"
    exit /b
)

call :Log "IP detectado: %IP%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "& { (Get-Content '%CONFIG_FILE%') -replace 'http://.*:8080','http://%IP%:8080' | Set-Content '%CONFIG_FILE%' }"
if errorlevel 1 (
    call :Log "[ERRO] Falha ao atualizar IP em %CONFIG_FILE%"
    set "ERRO_DETECTADO=1"
) else (
    call :Log "Config atualizado com sucesso."
)
exit /b

:IPLISTEN
if not defined IP (
    call :Log "[ERRO] Variavel IP nao definida. Etapa IPLISTEN abortada."
    set "ERRO_DETECTADO=1"
    exit /b
)

for /f "tokens=*" %%i in ('netsh http show iplisten ^| findstr /R "[0-9]\."') do (
    netsh http delete iplisten ip=%%i >nul
)

netsh http add iplisten ip=%IP% >nul
if errorlevel 1 (
    call :Log "[ERRO] Falha ao adicionar %IP% ao iplisten."
    set "ERRO_DETECTADO=1"
) else (
    call :Log "IP %IP% adicionado ao iplisten."
)
netsh http add iplisten ip=127.0.0.1 >nul
ipconfig /flushdns >nul
exit /b

:StopServices
for %%S in (SisOcrOffline SisAviCreator SisMonitorOffline MMFnx) do (
    sc stop %%S >nul 2>&1
    if errorlevel 1 (
        call :Log "[AVISO] Nao foi possivel parar o servico %%S (pode ja estar parado)."
    ) else (
        call :Log "Servico %%S parado."
    )
)
timeout /t 2 >nul
taskkill /F /IM SisAviCreator.exe /IM SisMonitorOffline.exe /IM SisOCR.Offline.Service.exe /IM FenoxSM.exe >nul 2>&1
exit /b

:StartServices
for %%S in (SisOcrOffline SisAviCreator SisMonitorOffline MMFnx) do (
    sc start %%S >nul 2>&1
    if errorlevel 1 (
        call :Log "[ERRO] Falha ao iniciar o servico %%S."
        set "ERRO_DETECTADO=1"
    ) else (
        call :Log "Servico %%S iniciado."
    )
)
iisreset /restart >nul 2>&1
if errorlevel 1 (
    call :Log "[ERRO] Falha ao reiniciar o IIS."
    set "ERRO_DETECTADO=1"
) else (
    call :Log "IIS reiniciado."
)
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

:: --- DETECÇÃO DINÂMICA DO PREFIXO (c ou ca) ---
set "PREFIXO=c"
:: Certifique-se que o caminho abaixo aponta para o arquivo que você me mandou
set "INI_IP_FILE=C:\captura\sensor.ini"

if exist "%INI_IP_FILE%" (
    :: Procura na linha do IpCanal01 se existe @ca
    findstr /i "IpCanal01" "%INI_IP_FILE%" | findstr /i "@ca" >nul
    if !errorlevel! equ 0 (
        set "PREFIXO=ca"
    ) else (
        set "PREFIXO=c"
    )
)

echo.
echo   %gy%Prefixo detectado no INI:%rs% %cy%!PREFIXO!%rs%
:: ----------------------------------------------

:: Verifica se a seção [CANALXMAC] existe
findstr /i /c:"[CANALXMAC]" "%INI_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Seção [CANALXMAC] não encontrada.
    goto :FIM_SCRIP
)

:: --- LOGICA DE BACKUP E RESET ---
copy /y "%HOSTS_FILE%" "%HOSTS_BACKUP%" >nul
if errorlevel 1 (
    call :Log "[ERRO] Falha ao criar backup de hosts em %HOSTS_BACKUP%. Etapa AJUSTEIP abortada por seguranca."
    set "ERRO_DETECTADO=1"
    exit /b
)
call :Log "Backup de hosts criado em %HOSTS_BACKUP%."
attrib -r "%HOSTS_FILE%" 2>nul
type nul > "%TEMP_HOSTS%"

set "inSection=0"
set "HAS_CHANGES=0"
set "ENTRY_COUNT=0"

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
                
                :: Pega os dois últimos dígitos do Canal (ex: Canal01 -> 01)
                set "NUM=!CANAL_STR:~-2!"
                :: Remove o zero à esquerda se existir (01 -> 1)
                if "!NUM:~0,1!"=="0" set "NUM=!NUM:~1!"
                
                :: Monta o HOSTNAME com o prefixo detectado (c1 ou ca1)
                set "HOSTNAME=!PREFIXO!!NUM!"
                
                set "IP_FOUND="
                for /f "tokens=1" %%I in ('arp -a ^| findstr /i /c:"!MAC_SEARCH!"') do (
                    set "IP_FOUND=%%I"
                )

                if defined IP_FOUND (
                    echo !IP_FOUND! !HOSTNAME!>> "%TEMP_HOSTS%"
                    set "HAS_CHANGES=1"
                    set /a ENTRY_COUNT+=1
                )
            )
        )
    )
)

:: Se foram encontrados IPs, substitui o arquivo hosts original
if !HAS_CHANGES! equ 1 (
    findstr /v /r "^$" "%TEMP_HOSTS%" > "%TEMP%\hosts_clean.txt"
    chcp 1252 >nul
    copy /y "%TEMP%\hosts_clean.txt" "%HOSTS_FILE%" >nul
    if errorlevel 1 (
        call :Log "[ERRO] Falha ao gravar novo hosts. Restaurando backup."
        copy /y "%HOSTS_BACKUP%" "%HOSTS_FILE%" >nul
        set "ERRO_DETECTADO=1"
    ) else (
        call :Log "Arquivo hosts atualizado com !ENTRY_COUNT! entrada(s)."
    )
    del "%TEMP%\hosts_clean.txt" 2>nul
    chcp 65001 >nul
)

del "%TEMP_HOSTS%" 2>nul

:: Reinicia cache DNS
net stop dnscache >nul 2>&1
ipconfig /flushdns >nul 2>&1
net start dnscache >nul 2>&1

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
	exit /b
