function get_gh_repo
    gh repo list -L 1000 $argv | sk | awk '{print $1}' | read REPO && ghq get -p $REPO
    commandline -f repaint
end
