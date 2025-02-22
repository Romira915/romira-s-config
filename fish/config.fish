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
if string match -q "*microsoft*" (uname -r)
    # WSL Only
    source ~/.config/romira-s-config/fish/system.config.d/wsl.fish
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

function bw-add-ssh
  set -l item_id "d8778a92-7c5f-481d-a046-fa59ecb65132"
  set -l tmp_key (mktemp -p /tmp bw-ssh-key.XXXXXX)

  bw get item $item_id | jq -r '.sshKey.privateKey' > $tmp_key
  chmod 600 $tmp_key
  ssh-add $tmp_key
  rm -f $tmp_key
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yuudai.tanaka/.tmp/google-cloud-sdk/path.fish.inc' ]; . '/Users/yuudai.tanaka/.tmp/google-cloud-sdk/path.fish.inc'; end
