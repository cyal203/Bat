@echo off

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

DEL /F /S /Q C:\WINDOWS\Temp\*.* && DEL /F /S /Q C:\WINDOWS\Prefetch\*.* && RD /S /Q C:\WINDOWS\Prefetch\ && MD C:\WINDOWS\Prefetch && del /s /f /q c:\windows\temp\*.* && rd /s /q c:\windows\temp && md c:\windows\temp && del /s /f /q C:\WINDOWS\Prefetch && del /s /f /q %temp%\*

