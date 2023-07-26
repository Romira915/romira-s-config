# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export LANG="en_US.UTF-8"

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
. "$HOME/.cargo/env"
if [ "$(uname)" == 'Darwin' ]; then
    # Mac Only
    eval $(/opt/homebrew/bin/brew shellenv)
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    # Linux Only
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
    export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
    alias pwdw='wslpath -w $(pwd)'
    alias pwdw2c="pwdw | clip"
fi
export EDITOR=vim
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
alias ls="exa"
alias la="exa -la"

if [[ "$(uname -r)" == *microsoft* ]]; then
    # WSL Only
    export BROWSER="msedge"
    /usr/bin/keychain -q --nogui
    source $HOME/.keychain/$(hostname)-sh
fi

export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
