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
# TODO: macOS Ansible 化時に廃止。Ansible develop_ubuntu.yml Play 4 と同等の処理
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
fish -c 'fisher install 0rax/fish-bd edc/bass'
for f in $HOME/.config/romira-s-config/fish/functions/*.fish; do ln -fs "$f" ~/.config/fish/functions/; done
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