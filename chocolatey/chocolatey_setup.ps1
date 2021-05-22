$desktop=True

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install git
choco install 7zip
choco install sudo
choco install googlechrome
choco install firefox
choco install vscode
choco install slack
choco install microsoft-windows-terminal
choco install openvpn
choco install jetbrainstoolbox
choco install nodejs-lts
choco install rustup.install
choco install vlc
choco install deepl
choco install miniconda3
choco install hwinfo
choco install pandoc
choco install pandoc-crossref
choco install sumatrapdf
choco install wireshark
choco install docker
choco install msys2
choco install openjdk
choco install gh
choco install authy-desktop
choco install googlejapaneseinput
choco install maven
choco install vim
choco install gradle
choco install eartrumpet
choco install vivaldi
choco install microsoft-teams
choco install office-tool
choco install unity-hub
choco install line
choco install teamviewer

if ($desktop) {
    choco install steam
    choco install musicbee
    choco install ubisoft-connect
    choco install uplay
    choco install obs
    choco install audacity
    choco install blender
    choco install crystaldiskinfo
    choco install crystaldiskmark
    choco install gimp
    choco install mp3tag
    choco install makemkv
    choco install discord
}