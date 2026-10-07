Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "wsl.exe -- bash -lc ""cd '/mnt/d/01 Main Work/Boots/Agentic AI/mission-control-hermes-watcher' && bash royal-master-oracle/tools/khun-runtime/start-hermes-github-watcher.sh >> '/mnt/c/Users/User/AppData/Local/Forge/logs/hermes-github-watcher.log' 2>&1""", 0, True
