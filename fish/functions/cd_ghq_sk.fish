function cd_ghq_sk
    if command -q sk
        set -f finder sk
    else
        set -f finder fzf
    end
    set -l list (ghq list)
    set -f repo (printf '%s\n' $list | $finder)
    if test -n "$repo"
        cd (ghq root)/$repo
    end
    commandline -f repaint
end
