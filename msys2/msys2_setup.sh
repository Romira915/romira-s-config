# Update pacman
pacman -Syuu --noconfirm
pacman -Sy --noconfirm

# Setting msys2
pacman -S --noconfirm zsh fish
sed -i -e '/db_home/c db_home: windows' /etc/nsswitch.conf
sed -i -e 's/LOGINSHELL=[ba]*[z]*sh/LOGINSHELL=fish/' /msys2_shell.cmd
echo -e 'export PATH=$(cygpath -p -u $ORIGINAL_PATH):$PATH' >> /etc/profile

# Setting fish
fish -c "curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish jethrokuan/z 0rax/fish-bd oh-my-fish/plugin-balias edc/bass"
echo "set -g theme_color_scheme brgrey" >> ~/.config/fish/config.fish
echo "set -g theme_display_date no" >> ~/.config/fish/config.fish
echo "function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
end" >> ~/.config/fish/config.fish
ghq get https://github.com/cm-wada-yusuke/angular-websocket-chat.git
ghq get https://github.com/cm-wada-yusuke/chatserver-play-websocket-akka-stream.git
echo "function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
  bind \c] peco_select_ghq_repository
end" >> ~/.config/fish/config.fish