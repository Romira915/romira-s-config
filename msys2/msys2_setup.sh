cd `dirname $0`

# Setting msys2
pacman -S --noconfirm zsh fish
sed -i -e 's/LOGINSHELL=[ba]*[z]*sh/LOGINSHELL=fish/' /msys2_shell.cmd
echo -e 'export PATH=$(cygpath -p -u $ORIGINAL_PATH):$PATH' >> /etc/profile

# Setting fish
fish ../fish/fish_setup.fish

# Setting vim
cp -r ../vim/. ~/
