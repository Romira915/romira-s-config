#!/bin/bash
cd `dirname $0`

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [ "$(uname)" == 'Darwin' ]; then
    # Mac Only
    eval $(/opt/homebrew/bin/brew shellenv)
    brew install wget
    brew install p7zip
    brew install htop

    # Install font
    brew tap homebrew/cask-fonts
    brew install font-hackgen
    brew install font-hackgen-nerd
    brew install font-plemol-jp
    brew install font-plemol-jp-nf
    brew install font-plemol-jp-nfj
    brew install font-plemol-jp-hs
    brew install --cask font-myrica
    brew install --cask font-myricam
    brew install --cask font-noto-sans-jp
    brew install --cask font-noto-serif-jp
    brew tap sanemat/font
    brew install ricty --with-powerline
    cp -f /opt/homebrew/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
    fc-cache -vf
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    # Linux Only
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

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
if [ "$(uname)" == 'Darwin' ]; then
    brew install dust
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    brew tap tgotwig/linux-dust && brew install dust
fi
brew install bottom
brew install sd
brew tap cantino/mcfly && brew install cantino/mcfly/mcfly
mkdir -p ~/.config/mcfly
mcfly init fish > ~/.config/mcfly/mcfly.fish
sd -s "\\cr" "\\ck" ~/.config/mcfly/mcfly.fish
brew install topgrade
brew install grex
brew install angle-grinder
brew install tmux-xpanes
brew install gping
# End: Make in Rust tools
brew install git-lfs
brew install starship
brew install ghostscript
brew install gnuplot
brew install php
brew install composer
brew install tfmigrate
brew install ansible
brew install ansible-lint 
brew install ansible-language-server

