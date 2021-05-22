cd `dirname $0`

echo "export LC_ALL=ja_JP.utf8" >> ~/.bashrc
echo "export LANG=ja_JP.utf8" >> ~/.bashrc
echo "export LANGUAGE=ja_JP.utf8" >> ~/.bashrc
echo "export LC_CTYPE=\"ja_JP.utf8\"" >> ~/.bashrc
echo "export LC_NUMERIC=\"ja_JP.utf8\"" >> ~/.bashrc
echo "export LC_TIME=\"ja_JP.utf8\"" >> ~/.bashrc
echo "export LC_COLLATE=\"ja_JP.utf8\"" >> ~/.bashrc
echo "export LC_MONETARY=\"ja_JP.utf8\"" >> ~/.bashrc
echo "export LC_MESSAGES=\"ja_JP.utf8\"" >> ~/.bashrc

git config --global user.name "Romira915"
git config --global user.email 40430090+Romira915@users.noreply.github.com
git config --global alias.tree "log --graph --all --format=\"%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s\""
git config --global alias.ignore '!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi'
git config --global init.defaultBranch main

git clone https://github.com/chris-marsh/pureline.git ~/pureline
cp ./.pureline.conf ~/.pureline.conf

echo "if [ "\$TERM" != "linux" ]; then
    source ~/pureline/pureline ~/.pureline.conf
fi" >> ~/.bashrc