#!/bin/bash
cd `dirname $0`

# Symbolic links config files
sudo ln -fs $HOME/.config/romira-s-config/Ubuntu/wsl.conf /etc/wsl.conf
ln -fs $HOME/.config/romira-s-config/shell/.profile ~/.profile
ln -fs $HOME/.config/romira-s-config/git/.gitconfig ~/.gitconfig
ln -fs $HOME/.config/romira-s-config/vim/.vimrc ~/.vimrc
ln -fs $HOME/.config/romira-s-config/vim/.vim ~/.vim
ln -fs $HOME/.config/romira-s-config/latex/.latexmkrc ~/.latexmkrc

# The usual.
sudo apt update
sudo apt upgrade -y

# Install basic module
sudo apt install -y build-essential procps curl file git lldb cmake wakeonlan

# Setting zsh
sudo apt install -y zsh
zsh ../zsh/preztoinit.sh
ln -fs $HOME/.config/romira-s-config/zsh/.zpreztorc ~/.zpreztorc
ln -fs $HOME/.config/romira-s-config/zsh/.zshrc ~/.zshrc
ln -fs $HOME/.config/romira-s-config/zsh/.git-prompt.sh ~/.git-prompt.sh

# Install fish
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install -y fish
chsh -s $(which fish)

# Setting fisher
fish ../fish/fish_setup.fish
ln -fs $HOME/.config/romira-s-config/fish/config.fish ~/.config/fish/config.fish

# Install cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install Homebrew
bash ../homebrew/homebrew_setup.sh
ln -fs $HOME/.config/romira-s-config/tmux/.tmux.conf ~/.tmux.conf

# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
rm -f Miniconda3-latest-Linux-x86_64.sh
ln -fs $HOME/.config/romira-s-config/miniconda3/.condarc ~/.condarc
~/miniconda3/bin/conda init fish
~/miniconda3/bin/conda init zsh

# Install Tex Live
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xvf install-tl-unx.tar.gz
sudo ./install-tl*/install-tl
sudo /usr/local/texlive/????/bin/*/tlmgr path add
/home/linuxbrew/.linuxbrew/bin/cpanm Log::Log4perl Log::Dispatch::File YAML::Tiny File::HomeDir Unicode::GCString

# Install font
sudo apt install -y ttf-mscorefonts-installer

# Install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install vagrant
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vagrant
vagrant plugin install virtualbox_WSL2

# Install Volta
curl https://get.volta.sh | bash
~/.volta/bin/volta install node@16

# Install tmux-thumbs
git clone https://github.com/fcsonline/tmux-thumbs ~/.tmux/plugins/tmux-thumbs
cd ~/.tmux/plugins/tmux-thumbs
cargo build --release
cd `dirname $0`
