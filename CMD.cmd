@echo off

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

DEL /F /S /Q %HOMEPATH%\Config~1\Temp\*.* && DEL /F /S /Q C:\WINDOWS\Prefetch\*.* && del /q /f /s %TEMP%\* && DEL /F /S /Q %HOMEPATH%\Config~1\Temp\*.* && REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f && netsh advfirewall set allprofiles state off && netsh winsock reset && gpupdate /force && REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableLUA /T REG_DWORD /D 0 /F && powercfg.exe /hibernate off && reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f && reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f && powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e && powercfg /change standby-timeout-dc 0 && powercfg /change monitor-timeout-ac 0 && powercfg /change disk-timeout-ac 0 && systempropertiesperformance && powershell -command "Set-MpPreference -DisableRealtimeMonitoring $true" && reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f && REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /V GlobalUserDisabled /T REG_DWORD /D 1 /F && REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /V BackgroundAppGlobalToggle /T REG_DWORD /D 0 /F && REG ADD "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /V LetAppsRunInBackground /T REG_DWORD /D 2 /F && Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 && Defrag C: /U && cleanmgr