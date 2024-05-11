bass source ~/.profile
set -g theme_color_scheme brgrey
set -g theme_display_date no
function fish_user_key_bindings
#  bind \cg peco_select_ghq_repository
  bind \cg cd_ghq_sk
  bind \cb\cr zoxide_zi
  bind \cb\cg get_gh_repo
end

for f in ~/.config/romira-s-config/fish/config.d/*.fish
    source $f
end

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
zoxide init fish | source

function zoxide_zi
  zi
  commandline -f repaint
end

function cd_ghq_sk
  ghq list | sk | read REPO && cd (ghq root)/$REPO
  commandline -f repaint
end

function get_gh_repo
  gh repo list -L 1000 $argv | sk | awk '{print $1}' | read REPO && ghq get -p $REPO
  commandline -f repaint
end

source ~/.config/mcfly/mcfly.fish

function jira_ticket
    set ticket (git branch --show-current | sed 's/feature\///g')
    echo $ticket
end

function jira_url
    echo https://prtimes.atlassian.net/browse/(jira_ticket)
end

function open_jira
    open (jira_url)
end

function ghprc
    set ticket_name (jira_ticket)
    set ticket_url (jira_url)
    gh pr create -a @me -t "$ticket_name:" -b "## JIRA
$ticket_url
" -w
end
