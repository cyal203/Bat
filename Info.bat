@echo off
setlocal enabledelayedexpansion

:: Define o arquivo de saída
set "OUTPUT_FILE=info_sistema.txt"

:: 1. Nome do Computador e Usuário Logado
set "computador=%COMPUTERNAME%"
set "usuario=%USERNAME%"

:: 2. Chave do Windows (Via PowerShell - Tenta buscar da BIOS e depois do Registro)
set "chave=NÃO encontrada"
for /f "usebackq delims=" %%i in (`powershell -command "(Get-CimInstance -Query 'select * from SoftwareLicensingService').OA3xOriginalProductKey" 2^>nul`) do (
    if not "%%i"==" " if not "%%i"=="" set "chave=%%i"
)

if "%chave%"=="NÃO encontrada" (
    for /f "usebackq delims=" %%i in (`powershell -command "(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform').BackupProductKeyDefault" 2^>nul`) do (
        if not "%%i"==" " if not "%%i"=="" set "chave=%%i"
    )
)

:: 3. Status, Versão e Última Atualização do Windows Defender
set "defender=NÃO"
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
set "windows_ativado=NÃO"
for /f "tokens=2 delims==" %%i in ('wmic path SoftwareLicensingProduct where "ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f' and LicenseStatus=1" get Description /value 2^>nul') do (
    if not "%%i"=="" set "windows_ativado=SIM"
)

:: 5. Versao do Windows
set "windows_versao=Desconhecida"
for /f "tokens=2 delims==" %%i in ('wmic os get Caption /value 2^>nul') do (
    set "windows_versao=%%i"
)
set "windows_versao=%windows_versao:Microsoft Windows =%"

:: Gerar o arquivo TXT formatado
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

echo Arquivo %OUTPUT_FILE% gerado com sucesso!

exit /b