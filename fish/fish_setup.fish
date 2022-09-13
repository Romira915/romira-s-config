# Setting fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install oh-my-fish/theme-bobthefish \
               jethrokuan/z \
               0rax/fish-bd \
               oh-my-fish/plugin-balias \
               edc/bass\
               oh-my-fish/plugin-peco \
               jethrokuan/fzf\
               decors/fish-ghq \
               yoshiori/fish-peco_select_ghq_repository \
               tsu-nera/fish-peco_recentd
echo "bass source ~/.profile" >> ~/.config/fish/config.fish
echo "set -g theme_color_scheme brgrey" >> ~/.config/fish/config.fish
echo "set -g theme_display_date no" >> ~/.config/fish/config.fish
echo "function fish_user_key_bindings
  bind \c] peco_select_ghq_repository
  bind \cv\cr peco_recentd
end" >> ~/.config/fish/config.fish
echo "zoxide init fish | source" >> ~/.config/fish/config.fish