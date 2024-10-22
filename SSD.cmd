@echo off
echo Desativando Desfragmentação Automática...
schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable
echo Desfragmentação automática desativada para SSD!
pause

echo Habilitando TRIM no SSD...
fsutil behavior set DisableDeleteNotify 0
echo TRIM habilitado!
pause

echo Desativando a Indexação de Arquivos no SSD...
sc stop "wsearch"
sc config "wsearch" start= disabled
echo Indexação de arquivos desativada no SSD!
pause

echo Desativando Gerenciamento de energia
sc config "Power" start=disabled >nul

powercfg /change disk-timeout-ac 0 >nul
powercfg /change disk-timeout-dc 0 >nul