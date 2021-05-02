cd `dirname $0`

git clone https://github.com/chris-marsh/pureline.git ~/pureline
cp ./.pureline.conf ~/.pureline.conf

echo "if [ "\$TERM" != "linux" ]; then
    source ~/pureline/pureline ~/.pureline.conf
fi" >> ~/.bashrc