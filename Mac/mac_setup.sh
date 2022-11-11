#!/bin/bash
cd `dirname $0`

# Symbolic links config files
ln -fs $HOME/.config/romira-s-config/git/.gitconfig ~/.gitconfig
ln -fs $HOME/.config/romira-s-config/shell/.profile ~/.profile
ln -fs $HOME/.config/romira-s-config/vim/.vimrc ~/.vimrc
ln -fs $HOME/.config/romira-s-config/vim/.vim ~/.vim

# Setting zsh
zsh ../zsh/preztoinit.sh
ln -fs $HOME/.config/romira-s-config/zsh/.zpreztorc ~/.zpreztorc
ln -fs $HOME/.config/romira-s-config/zsh/.zshrc ~/.zshrc
ln -fs $HOME/.config/romira-s-config/zsh/.git-prompt.sh ~/.git-prompt.sh

# Install fish
brew install fish
sudo sh -c "echo $(which fish) >> /etc/shells"
chsh -s $(which fish)

# Setting fisher
fish ../fish/fish_setup.fish
ln -fs $HOME/.config/romira-s-config/fish/config.fish ~/.config/fish/config.fish

# Install cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install Homebrew
bash ./homebrew/homebrew_setup.sh
ln -fs $HOME/.config/romira-s-config/tmux/.tmux.conf ~/.tmux.conf
bash ./homebrew/homebrew_cask.sh

# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
bash Miniconda3-latest-MacOSX-arm64.sh
rm -f Miniconda3-latest-MacOSX-arm64.sh
ln -fs $HOME/.config/romira-s-config/miniconda3/.condarc ~/.condarc
~/miniconda3/bin/conda init fish
~/miniconda3/bin/conda init zsh

# Install Volta
curl https://get.volta.sh | bash
~/.volta/bin/volta install node@16

# Install tmux-thumbs
git clone https://github.com/fcsonline/tmux-thumbs ~/.tmux/plugins/tmux-thumbs
cd ~/.tmux/plugins/tmux-thumbs
cargo build --release
cd `dirname $0`