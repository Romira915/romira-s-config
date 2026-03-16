function cd_ghq_sk
    if command -q sk
        set finder sk
    else
        set finder fzf
    end
    ghq list | $finder | read REPO && cd (ghq root)/$REPO
    commandline -f repaint
end
