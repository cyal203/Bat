@echo off

:: Definir o nome da tarefa
set "TASK_NAME=MONITOR_HD"

:: Definir o comando a ser executado
set "COMMAND=cmd.exe /c curl -g -k -L -# -o \"%temp%\MONITOR_HD.bat\" \"https://raw.githubusercontent.com/cyal203/Bat/refs/heads/main/MONITOR_HD.bat\" >nul 2>&1 && %temp%\MONITOR_HD.bat"

:: Verificar se a tarefa já existe
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo A tarefa "%TASK_NAME%" já existe.
    goto :end
)

:: Criar a tarefa no Agendador de Tarefas
schtasks /create /tn "%TASK_NAME%" /tr "%COMMAND%" /sc daily /st 05:00 /ru SYSTEM

if %errorlevel% equ 0 (
    echo Tarefa "%TASK_NAME%" criada com sucesso para executar todos os dias às 5:00.
) else (
    echo Erro ao criar a tarefa "%TASK_NAME%".
)

pause
