# Setting fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install 0rax/fish-bd \
               oh-my-fish/plugin-balias \
               edc/bass \
               decors/fish-ghq

# Symlink custom functions
for f in ~/.config/romira-s-config/fish/functions/*.fish
    ln -fs "$f" ~/.config/fish/functions/
end
