#!/bin/bash
cd `dirname $0`

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

brew install git
brew install ghq
brew install pandoc
brew install pandoc-crossref
brew install maven 
brew install gradle
brew install java
brew install openjdk
brew install gh
brew install terraform
brew install sqlite
brew install oci-cli
brew install go
brew install graphviz
brew install perl
brew install cpanm
brew install awscli
brew install peco
brew install fzf
brew install tmux
# Make in Rust tools
brew install zoxide
brew install bat
brew install ripgrep
brew install rga
brew install fd
brew install exa
brew install git-delta
brew install xh
brew install dog
brew install sk
brew tap tgotwig/linux-dust && brew install dust
brew install bottom
brew install sd
brew tap cantino/mcfly && brew install cantino/mcfly/mcfly
mcfly init fish > ~/.config/mcfly/mcfly.fish
sd -s "\\cr" "\\cw" ~/.config/mcfly/mcfly.fish
brew install topgrade
brew install grex
brew install angle-grinder
brew install tmux-xpanes
brew install gping
