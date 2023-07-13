source ~/.bash_profile
export LC_ALL=en_US.utf8
export LANG=en_US.utf8
export LANGUAGE=en_US.utf8
export LC_CTYPE="en_US.utf8"
export LC_NUMERIC="en_US.utf8"
export LC_TIME="en_US.utf8"
export LC_COLLATE="en_US.utf8"
export LC_MONETARY="en_US.utf8"
export LC_MESSAGES="en_US.utf8"
if [ $TERM != linux ]; then
    source ~/pureline/pureline ~/.pureline.conf
fi

if [ $TERM != linux ]; then
    export PATH=$PATH:~/scoop/apps/gcc/current/bin
fi
