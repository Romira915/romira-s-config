cd /d %~dp0

powershell -ExecutionPolicy Unrestricted -File ..\chocolatey\chocolatey_setup.ps1
powershell -ExecutionPolicy Unrestricted -File ..\scoop\scoop_setup.ps1 

@REM Setting git config.
@REM Change your user name.
@REM git config --global user.name "Romira915"
@REM Change your user email.
@REM git config --global user.email 40430090+Romira915@users.noreply.github.com
@REM git config --global alias.tree "log --graph --all --format=\"%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s\""
@REM git config --global alias.ignore '!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi'
@REM git config --global init.defaultBranch main

@REM xcopy ..\WindowsTerminal\settings.json "%LOCALAPPDATA%\Microsoft\Windows Terminal\"
xcopy ..\WindowsTerminal\settings.json "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
powershell -ExecutionPolicy Unrestricted -File .\fonts_setup.ps1
powershell -ExecutionPolicy Unrestricted -File ..\wsl2\wsl2_setup.ps1
