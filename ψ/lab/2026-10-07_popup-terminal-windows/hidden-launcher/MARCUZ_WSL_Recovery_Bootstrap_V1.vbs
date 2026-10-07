Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "C:\WINDOWS\System32\wsl.exe -d Ubuntu-24.04 -u marcuz -- /bin/true", 0, True
