# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export LANG="en_US.UTF-8"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -r "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

command -v setopt >/dev/null 2>&1 && setopt +o nomatch
for f in $HOME/.config/romira-s-config/shell/profile.d/*; do
    [ -f "$f" ] && source "$f"
    # ファイルがなかった場合何もしないとなぜか詰まるのでなんかする
    echo "Sourced $f" >/dev/null
done
command -v setopt >/dev/null 2>&1 && setopt -o nomatch
if [ "$(uname)" = 'Darwin' ]; then
    # Mac Only
    . ~/.config/romira-s-config/shell/system.profile.d/darwin
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ]; then
    # Linux Only
    . ~/.config/romira-s-config/shell/system.profile.d/linux
fi
if [[ "$(uname -r)" = *microsoft* ]]; then
    # WSL Only
    . ~/.config/romira-s-config/shell/system.profile.d/wsl
fi

export EDITOR=vim
export VOLTA_HOME="$HOME/.volta"
if [ -d "$VOLTA_HOME/bin" ]; then
    export PATH="$VOLTA_HOME/bin:$PATH"
fi

alias ls="eza"
alias la="eza -la"

export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

if [ -d "$HOME/.local/share/binaryen/bin" ]; then
    PATH="$HOME/.local/share/binaryen/bin:$PATH"
fi
