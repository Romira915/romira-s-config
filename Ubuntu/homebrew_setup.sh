#!/bin/bash
cd `dirname $0`

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.profile
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

brew install git
brew install ghq
brew install pandoc
brew install maven 
brew install gradle
brew install java
brew install openjdk
brew install gh
brew install terraform
brew install node
brew install sqlite