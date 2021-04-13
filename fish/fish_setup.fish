# Setting fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install oh-my-fish/theme-bobthefish jethrokuan/z 0rax/fish-bd oh-my-fish/plugin-balias edc/bass
echo "bass source ~/.profile" >> ~/.config/fish/config.fish
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