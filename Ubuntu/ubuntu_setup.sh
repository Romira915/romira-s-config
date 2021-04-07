#!/bin/bash
cd `dirname $0`

# The usual.
sudo apt update
sudo apt upgrade -y

# Setting zsh
sudo apt install -y zsh
zsh ../zsh/preztoinit.sh

# Install cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
bass source $HOME/.cargo/env

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> /home/romira/.profile
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# Setting git config.
brew install git
git config --global user.name "Romira915" # Change your user name.
git config --global user.email 40430090+Romira915@users.noreply.github.com # Change your user email.
git config --global alias.tree "log --graph --all --format=\"%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s\""
git config --global init.defaultBranch main

# Install fish
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install -y fish
chsh -s $(which fish)

# Setting fisher
fish -c "curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher"
sudo apt install -y fonts-powerline
fish -c "fisher install oh-my-fish/theme-bobthefish jethrokuan/z 0rax/fish-bd oh-my-fish/plugin-balias edc/bass"
echo "set -g theme_color_scheme brgrey" >> ~/.config/fish/config.fish
echo "set -g theme_display_date no" >> ~/.config/fish/config.fish
echo "function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
end" >> ~/.config/fish/config.fish
brew install ghq
ghq get https://github.com/cm-wada-yusuke/angular-websocket-chat.git
ghq get https://github.com/cm-wada-yusuke/chatserver-play-websocket-akka-stream.git
echo "function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
  bind \c] peco_select_ghq_repository
end" >> ~/.config/fish/config.fish


# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
rm -f Miniconda3-latest-Linux-x86_64.sh
~/miniconda3/bin/conda init fish
~/miniconda3/bin/conda init zsh
conda config --set auto_activate_base false

# Setting vim
cp -r ../vim/. ~/

# Install other 
sudo apt install -y build-essential