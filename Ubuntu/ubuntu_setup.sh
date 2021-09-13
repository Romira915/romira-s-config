#!/bin/bash
cd `dirname $0`

# The usual.
sudo apt update
sudo apt upgrade -y

# Install basic module
sudo apt install -y build-essential procps curl file git lldb

# Setting zsh
sudo apt install -y zsh
zsh ../zsh/preztoinit.sh

# Install cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install Homebrew
./homebrew_setup.sh

# Setting git config.
git config --global user.name "Romira915" # Change your user name.
git config --global user.email 40430090+Romira915@users.noreply.github.com # Change your user email.
git config --global alias.tree "log --graph --all --format=\"%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s\""
git config --global alias.ignore '!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi'
git config --global init.defaultBranch main
git config --global github.user "Romira915"

# Install fish
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install -y fish
chsh -s $(which fish)

# Setting fisher
fish ../fish/fish_setup.fish

# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
rm -f Miniconda3-latest-Linux-x86_64.sh
~/miniconda3/bin/conda init fish
~/miniconda3/bin/conda init zsh
echo "auto_activate_base: false" >> ~/.condarc

# Setting vim
cp -r ../vim/. ~/
echo "export EDITOR=vim" >> ~/.profile

# Install Tex Live
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xvf install-tl-unx.tar.gz
sudo ./install-tl*/install-tl
sudo /usr/local/texlive/????/bin/*/tlmgr path add

# Install font
sudo apt install -y ttf-mscorefonts-installer

# Install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash