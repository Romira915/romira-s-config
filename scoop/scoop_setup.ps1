# インストールディレクトリの設定 (user)
#$env:SCOOP='D:\Applications\Scoop'
#[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

# インストールディレクトリの設定 (global)
#$env:SCOOP_GLOBAL='D:\GlobalScoopApps'
#[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

Param([switch]$desktop)

# try {
#   # Scoopのインストール確認
#   get-command scoop -ErrorAction Stop
# } 
# catch [Exception] {
  # Scoopのインストール
Set-ExecutionPolicy RemoteSigned -scope CurrentUser 
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
# }

# install basic module
scoop install aria2
scoop install git
scoop install 7zip
scoop install sudo

# add bucket
scoop bucket add extras
scoop bucket add versions
scoop bucket add jp https://github.com/rkbk60/scoop-for-jp
scoop bucket add java
scoop bucket add nonportable

# Scoopのインストールディレクトリの取得
# $SCOOP_ROOT = if ($env:SCOOP) {$env:SCOOP} else {"$home\scoop"}
$SCOOP_ROOT = "${home}\scoop"

scoop install googlechrome
scoop install firefox
scoop install vscode
reg import $SCOOP_ROOT\apps\vscode\current\vscode-install-context.reg  # add context menu
scoop install slack
scoop install windows-terminal
scoop install openvpn
scoop install jetbrains-toolbox
scoop install nodejs-lts
scoop install rustup
scoop install vlc
scoop install deepl
scoop install miniconda3
scoop install hwinfo
scoop install pandoc
scoop install pandoc-crossref
scoop install teamviewer
scoop install sumatrapdf
scoop install wireshark
scoop install ricty-diminished
scoop install docker
scoop install msys2
scoop install openjdk
scoop install vivaldi
scoop install gh
scoop install authy
scoop install google-japanese-input-np

if ($desktop) {
  scoop install steam
  scoop install musicbee
  scoop install ubisoftconnect
  scoop install obs-studio
  scoop install audacity
  scoop install discord
  scoop install blender
}

# Reference https://qiita.com/rhene/items/d8a0c0c7d637904e14da#%E7%92%B0%E5%A2%83%E6%A7%8B%E7%AF%89%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88