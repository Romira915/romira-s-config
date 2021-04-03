cd /d %~dp0

powershell -ExecutionPolicy Unrestricted -File ..\scoop\scoop_setup.ps1 

@REM Setting mingw64
mingw64 -c "pacman -Syuu --noconfirm"
mingw64 -c "pacman -S --noconfirm zsh fish"
mingw64 -c "sed -i -e '/db_home/d' /etc/nsswitch.conf"
mingw64 -c "echo db_home: windows >> /etc/nsswitch.conf"

@REM Setting git config.
@REM Change your user name.
git config --global user.name "Romira915"
@REM Change your user email.
git config --global user.email 40430090+Romira915@users.noreply.github.com
git config --global alias.tree "log --graph --all --format=\"%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s\""
git config --global init.defaultBranch main

xcopy ..\WindowsTerminal\settings.json "%LOCALAPPDATA%\Microsoft\Windows Terminal\"
powershell -ExecutionPolicy Unrestricted -File ..\wsl2\wsl2_setup.ps1