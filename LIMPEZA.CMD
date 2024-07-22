@echo off

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

del /q /f /s %TEMP%\* && del /q /f /s temp\*
DEL /F /S /Q %HOMEPATH%\Config~1\Temp\*.* 
DEL /F /S /Q C:\WINDOWS\Temp\*.* 
DEL /F /S /Q C:\WINDOWS\Prefetch\*.* 
DEL "%WINDIR%\Tempor~1\*.*" /F /S /Q 
RD /S /Q "%HOMEPATH%\Config~1\Temp" 
MD "%HOMEPATH%\Config~1\Temp" 
RD /S /Q C:\WINDOWS\Temp\ 
MD C:\WINDOWS\Temp 
RD /S /Q C:\WINDOWS\Prefetch\ 
MD C:\WINDOWS\Prefetch
del /s /f /q c:\windows\temp\*.*
rd /s /q c:\windows\temp
md c:\windows\temp
del /s /f /q C:\WINDOWS\Prefetch
del /s /f /q %temp%\*.*
rd /s /q %temp%
md %temp%
deltree /y c:\windows\tempor~1
deltree /y c:\windows\temp
deltree /y c:\windows\tmp
deltree /y c:\windows\ff*.tmp
deltree /y c:\windows\history
deltree /y c:\windows\cookies
deltree /y c:\windows\recent
deltree /y c:\windows\spool\printers
del c:\WIN386.SWP
cls
exit
