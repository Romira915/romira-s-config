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

# Symlink custom functions
for f in ~/.config/romira-s-config/fish/functions/*.fish
    ln -fs "$f" ~/.config/fish/functions/
end
