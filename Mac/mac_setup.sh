#!/bin/bash
cd `dirname $0`

# Symbolic links config files
ln -fs $HOME/.config/romira-s-config/git/.gitconfig ~/.gitconfig
ln -fs $HOME/.config/romira-s-config/shell/.profile ~/.profile
ln -fs $HOME/.config/romira-s-config/vim/.vimrc ~/.vimrc
ln -fs $HOME/.config/romira-s-config/vim/.vim ~/.vim
ln -fs $HOME/.config/romira-s-config/latex/.latexmkrc ~/.latexmkrc

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
ln -fs $HOME/.config/romira-s-config/starship/starship.toml ~/.config/starship.toml

# Install cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

ln -fs $HOME/.config/romira-s-config/tmux/.tmux.conf ~/.tmux.conf

# Install Homebrew Cask
bash ./homebrew/homebrew_cask.sh

# Install Volta
curl https://get.volta.sh | bash
~/.volta/bin/volta install node@16

# Install tmux-thumbs
git clone https://github.com/fcsonline/tmux-thumbs ~/.tmux/plugins/tmux-thumbs
cd ~/.tmux/plugins/tmux-thumbs
cargo build --release
cd `dirname $0`