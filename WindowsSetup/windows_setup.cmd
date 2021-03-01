cd /d %~dp0
powershell -ExecutionPolicy Unrestricted -File ..\scoop\scoop_setup.ps1
copy ..\WindowsTerminal\settings.json "%LOCALAPPDATA%\Microsoft\Windows Terminal"
powershell -ExecutionPolicy Unrestricted -File ..\wsl2setup\wsl2_setup.ps1

