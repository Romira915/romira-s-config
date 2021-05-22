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

git clone https://github.com/chris-marsh/pureline.git ~/pureline
cp ./.pureline.conf ~/.pureline.conf

echo "if [ "\$TERM" != "linux" ]; then
    source ~/pureline/pureline ~/.pureline.conf
fi" >> ~/.bashrc

# Setting vim
cp -r ../vim/. ~/