cd `dirname $0`

echo "export LC_ALL=en_US.utf8" >> ~/.bashrc
echo "export LANG=en_US.utf8" >> ~/.bashrc
echo "export LANGUAGE=en_US.utf8" >> ~/.bashrc
echo "export LC_CTYPE=\"en_US.utf8\"" >> ~/.bashrc
echo "export LC_NUMERIC=\"en_US.utf8\"" >> ~/.bashrc
echo "export LC_TIME=\"en_US.utf8\"" >> ~/.bashrc
echo "export LC_COLLATE=\"en_US.utf8\"" >> ~/.bashrc
echo "export LC_MONETARY=\"en_US.utf8\"" >> ~/.bashrc
echo "export LC_MESSAGES=\"en_US.utf8\"" >> ~/.bashrc

git clone https://github.com/chris-marsh/pureline.git ~/pureline
cp ./.pureline.conf ~/.pureline.conf

echo "if [ "\$TERM" != "linux" ]; then
    source ~/pureline/pureline ~/.pureline.conf
fi" >> ~/.bashrc

# Setting vim
cp -r ../vim/. ~/

conda init bash