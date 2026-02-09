function cd_ghq_sk
    ghq list | sk | read REPO && cd (ghq root)/$REPO
    commandline -f repaint
end
