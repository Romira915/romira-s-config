cd /d %~dp0

@REM Install package manager
powershell -ExecutionPolicy Unrestricted -File ..\chocolatey\chocolatey_setup.ps1
powershell -ExecutionPolicy Unrestricted -File ..\scoop\scoop_setup.ps1
start https://github.com/microsoft/winget-cli/releases

@REM Setting git config.
@REM Change your user name.
%USERPROFILE%\scoop\shims\git.exe config --global user.name "Romira915"
@REM Change your user email.
%USERPROFILE%\scoop\shims\git.exe config --global user.email 40430090+Romira915@users.noreply.github.com
%USERPROFILE%\scoop\shims\git.exe config --global alias.tree "log --graph --all --format=\"%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s\""
%USERPROFILE%\scoop\shims\git.exe config --global alias.ignore '!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi'
%USERPROFILE%\scoop\shims\git.exe config --global init.defaultBranch main
%USERPROFILE%\scoop\shims\git.exe config --global github.user "Romira915"

@REM xcopy ..\WindowsTerminal\settings.json "%LOCALAPPDATA%\Microsoft\Windows Terminal\"
xcopy ..\WindowsTerminal\settings.json "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
powershell -ExecutionPolicy Unrestricted -File .\fonts_setup.ps1
@REM powershell -ExecutionPolicy Unrestricted -File ..\wsl2\wsl2_setup.ps1

powershell -ExecutionPolicy Unrestricted -File ..\wsl2\wsl2_for_windows11.ps1
