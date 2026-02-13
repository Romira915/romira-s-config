bass source ~/.profile

# Syntax highlighting colors
set -g fish_color_command blue

for f in ~/.config/romira-s-config/fish/config.d/*.fish
    source $f
end
if string match -q "*microsoft*" (uname -r)
    # WSL Only
    source ~/.config/romira-s-config/fish/system.config.d/wsl.fish
end

zoxide init fish | source
mcfly init fish | source
starship init fish | source

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.tmp/google-cloud-sdk/path.fish.inc" ]; . "$HOME/.tmp/google-cloud-sdk/path.fish.inc"; end
