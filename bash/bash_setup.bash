cd `dirname $0`

git clone https://github.com/tadashi-aikawa/pureline-inspired.git ~/
cp pureline/configs/powerline_full_256col.conf ~/.pureline.conf

echo "if [ "$TERM" != "linux" ]; then
    source ~/pureline/pureline ~/.pureline.conf
fi" >> .bashrc