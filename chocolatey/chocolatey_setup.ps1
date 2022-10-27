Param(
    [String]$is_desktop = "False"
    )

$is_desktop_bool = [System.Convert]::ToBoolean($is_desktop)

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y googlechrome
choco install -y firefox
choco install -y slack
# choco install -y microsoft-windows-terminal
choco install -y openvpn
choco install -y jetbrainstoolbox
choco install -y vlc
choco install -y deepl
choco install -y hwinfo
choco install -y sumatrapdf
choco install -y wireshark
choco install -y docker-desktop
choco install -y authy-desktop
choco install -y googlejapaneseinput
choco install -y eartrumpet
choco install -y vivaldi
choco install -y microsoft-teams
choco install -y office-tool
choco install -y unity-hub
choco install -y line
choco install -y teamviewer
choco install -y google-drive-file-stream
choco install -y virtualbox
choco install -y parsec
choco install -y zoom
choco install -y wakemeonlan
choco install -y notion
choco install -y dropbox
choco install -y nextcloud-client
choco install -y procmon
choco install -y wireguard
choco install -y font-hackgen-nerd
choco install -y adobe-creative-cloud
choco install -y jmeter
choco install -y postman
choco install -y du
choco install -y devtoys
choco install -y crystaldiskinfo
choco install -y crystaldiskmark
choco install -y powertoys
choco install -y figma

if ($is_desktop_bool) {
    choco install -y steam
    choco install -y musicbee
    choco install -y ubisoft-connect
    choco install -y uplay
    choco install -y obs
    choco install -y audacity
    choco install -y blender
    choco install -y gimp
    choco install -y mp3tag
    choco install -y makemkv
    choco install -y discord
    choco install -y voicemeeter-banana
    choco install -y borderlessgaming
    choco install -y xmedia-recode
    choco install -y vb-cable
    choco install -y lghub
    choco install -y epicgameslauncher
}
