@echo off
setlocal enabledelayedexpansion
:: ------02/04/2025------
:: Defina o nome do computador
set "COMPUTADOR=%COMPUTERNAME%"

:: URL do Web App do Google Apps Script
set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbwt-mzIQppTdzdxTcqq_z_MvvTDw6GTzj7p0qkxnEWmpdBXOgBEck6WB0VWoxmsEbE/exec"

:: Arquivo temporário para armazenar os dados
set "TEMP_FILE=%TEMP%\disk_info.txt"
set "RESPONSE_FILE=%TEMP%\response.txt"
set "JSON_FILE=%TEMP%\json_payload.txt"

:: Caminho para o arquivo de configuração do AnyDesk
set "ANYDESK_CONFIG=%appdata%\AnyDesk\system.conf"

:: Extrair o ID do AnyDesk
set "ANYDESK_ID="
for /f "tokens=2 delims==" %%I in ('findstr /i "ad.anynet.id" "%ANYDESK_CONFIG%"') do (
    set "ANYDESK_ID=%%I"
)

:: Remover espaços extras e caracteres inválidos do ANYDESK_ID
set "ANYDESK_ID=!ANYDESK_ID: =!"
set "ANYDESK_ID=!ANYDESK_ID:\t=!"  :: Remove tabulações
set "ANYDESK_ID=!ANYDESK_ID:^"=!"  :: Remove aspas

:: Coletar informações de espaço em disco
wmic logicaldisk get caption,freespace,size /format:csv > "%TEMP_FILE%"

:: Coletar informações da CPU
set "CPU="
for /f "skip=1 tokens=2 delims=," %%A in ('wmic cpu get name /format:csv') do (
    set "CPU=%%A"
)

:: Remover espaços extras
set "CPU=!CPU: =!"
set "CPU=!CPU:\t=!"
set "CPU=!CPU:^"=!"

:: Remover tudo após o caractere "@" (se existir)
for /f "tokens=1 delims=@" %%B in ("!CPU!") do (
    set "CPU=%%B"
)

:: Coletar informação sobre a data de instalação do Windows
for /f "skip=1 tokens=2 delims==" %%A in ('wmic os get installdate /format:list') do set "INSTALL_DATE=%%A"
set "INSTALL_DATE=!INSTALL_DATE:~6,2!/!INSTALL_DATE:~4,2!/!INSTALL_DATE:~0,4!"

:: Coletar informação da memória RAM total
for /f "skip=1 tokens=2 delims=," %%A in ('wmic ComputerSystem get TotalPhysicalMemory /format:csv') do set "RAM=%%A"
set /a "RAM=!RAM:~0,-6!"  :: Converter de bytes para MB

:: Exibir conteúdo coletado
type "%TEMP_FILE%"

:: Processar o arquivo e enviar os dados ao Google Sheets
for /f "skip=1 tokens=2-4 delims=," %%A in ('type "%TEMP_FILE%"') do (
    set "DRIVE=%%A"
    set "FREE=%%B"
    set "SIZE=%%C"

    :: Remover espaços em branco extras
    set "DRIVE=!DRIVE: =!"
    set "FREE=!FREE: =!"
    set "SIZE=!SIZE: =!"

    :: Converter valores para GB
    set /a "TOTAL=!SIZE:~0,-9!"
    set /a "LIVRE=!FREE:~0,-9!"

    :: Calcular porcentagem de espaço livre
    if !TOTAL! gtr 0 (
        set /a "PERCENTUAL=(LIVRE*100)/TOTAL"
    ) else (
        set "PERCENTUAL=0"
    )

    :: Criar JSON corretamente formatado
    echo { > "%JSON_FILE%"
    echo   "computador": "!COMPUTADOR!", >> "%JSON_FILE%"
    echo   "unidade": "!DRIVE!", >> "%JSON_FILE%"
    echo   "espaco_total": !TOTAL!, >> "%JSON_FILE%"
    echo   "espaco_livre": !LIVRE!, >> "%JSON_FILE%"
    echo   "porcentagem_livre": !PERCENTUAL!, >> "%JSON_FILE%"
    echo   "cpu": "!CPU!", >> "%JSON_FILE%"
    echo   "instwin": "!INSTALL_DATE!", >> "%JSON_FILE%"
    echo   "ram": !RAM!, >> "%JSON_FILE%"
    echo   "anydesk": "!ANYDESK_ID!" >> "%JSON_FILE%"
    echo } >> "%JSON_FILE%"

    :: Exibir JSON formatado
    echo Enviando:
    type "%JSON_FILE%"

    :: Enviar dados para o Google Sheets via CURL
    curl --ssl-no-revoke -X POST -H "Content-Type: application/json" -d "@%JSON_FILE%" "%URL_WEB_APP%" > "%RESPONSE_FILE%" 2>nul

    :: Exibir resposta do servidor
    echo === RESPOSTA DO SERVIDOR ===
    type "%RESPONSE_FILE%"
    echo =============================
)

:: Limpar arquivos temporários
del "%TEMP_FILE%"
del "%RESPONSE_FILE%"
del "%JSON_FILE%"
