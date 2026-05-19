# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export LANG="en_US.UTF-8"

if [ -r "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

command -v setopt >/dev/null 2>&1 && setopt +o nomatch
for f in "$HOME/.config/romira-s-config/shell/profile.d/"*; do
    [ -f "$f" ] && . "$f"
done
command -v setopt >/dev/null 2>&1 && setopt -o nomatch
_uname_s="$(uname -s)"
_uname_r="$(uname -r)"
case "$_uname_s" in
    Darwin) . ~/.config/romira-s-config/shell/system.profile.d/darwin ;;
    Linux)  . ~/.config/romira-s-config/shell/system.profile.d/linux ;;
esac
case "$_uname_r" in
    *microsoft*) . ~/.config/romira-s-config/shell/system.profile.d/wsl ;;
esac
unset _uname_s _uname_r

export EDITOR=vim
export MCFLY_FUZZY=2
export GOPATH="$HOME/go"

# === PATH (prepend) ===
export PNPM_HOME="$HOME/.local/share/pnpm"
for _dir in \
    "$PNPM_HOME" \
    "$HOME/bin" \
    "$HOME/.local/share/mise/shims" \
    "$HOME/.local/bin" \
    "$HOME/.local/share/binaryen/bin" \
    "$GOPATH/bin"
do
    [ -d "$_dir" ] && PATH="$_dir:$PATH"
done
unset _dir

# === PATH (append) ===
[ -d "$HOME/.lmstudio/bin" ] && PATH="$PATH:$HOME/.lmstudio/bin"

alias ls="eza"
alias la="eza -la"

if command -v mise >/dev/null 2>&1; then
    if [ -n "$BASH_VERSION" ]; then
        eval "$(mise activate bash)"
    elif [ -n "$ZSH_VERSION" ]; then
        eval "$(mise activate zsh)"
    fi
fi

true
