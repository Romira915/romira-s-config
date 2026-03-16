function get_gh_repo
    if command -q sk
        set finder sk
    else
        set finder fzf
    end
    gh repo list -L 1000 $argv | $finder | awk '{print $1}' | read REPO && ghq get -p $REPO
    commandline -f repaint
end
