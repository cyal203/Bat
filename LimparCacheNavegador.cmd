@echo off
echo Limpando cache do Google Chrome...
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"

echo Limpando cache do Mozilla Firefox...
rd /s /q "%APPDATA%\Mozilla\Firefox\Profiles\*.default\cache2"

echo Limpando cache do Microsoft Edge...
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"

echo Cache limpo com sucesso!
pause