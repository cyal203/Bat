@echo off
setlocal enabledelayedexpansion

:: Defina o nome do computador
set "COMPUTADOR=%COMPUTERNAME%"

:: URL do Web App do Google Apps Script
set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbwHelq7EaYwQXVCew_CC4kkOr3H_6J33RaL1uThVbThzMV20QdRpFPifHzJaC6Mw5RF/exec"

:: Arquivo temporário para armazenar os dados
set "TEMP_FILE=%TEMP%\disk_info.txt"
set "RESPONSE_FILE=%TEMP%\response.txt"
set "JSON_FILE=%TEMP%\json_payload.txt"

:: Coletar informações de espaço em disco
wmic logicaldisk get caption,freespace,size /format:csv > "%TEMP_FILE%"

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
    echo   "computador": "%COMPUTADOR%", >> "%JSON_FILE%"
    echo   "unidade": "!DRIVE!", >> "%JSON_FILE%"
    echo   "espaco_total": !TOTAL!, >> "%JSON_FILE%"
    echo   "espaco_livre": !LIVRE!, >> "%JSON_FILE%"
    echo   "porcentagem_livre": !PERCENTUAL! >> "%JSON_FILE%"
    echo } >> "%JSON_FILE%"

    :: Exibir JSON formatado
    echo Enviando:
    type "%JSON_FILE%"

    :: Enviar dados para o Google Sheets via CURL e salvar resposta
    curl --ssl-no-revoke -X POST -H "Content-Type: application/json" -d "@%JSON_FILE%" "%URL_WEB_APP%" > "%RESPONSE_FILE%"  >nul

    :: Exibir resposta do servidor
    echo === RESPOSTA DO SERVIDOR ===
    type "%RESPONSE_FILE%"
    echo =============================
)


:: Limpar arquivos temporários
del "%TEMP_FILE%"
del "%RESPONSE_FILE%"
del "%JSON_FILE%"