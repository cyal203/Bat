Set WshShell = CreateObject("WScript.Shell")
tempFolder = WshShell.ExpandEnvironmentStrings("%TEMP%")
WshShell.Run chr(34) & tempFolder & "\Info.bat" & chr(34), 0, False
