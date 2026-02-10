bass source ~/.profile
function fish_user_key_bindings
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

zoxide init fish | source
mcfly init fish | source
starship init fish | source

function bw-add-ssh
  set -l item_id "d8778a92-7c5f-481d-a046-fa59ecb65132"
  set -l tmp_key (mktemp -p /tmp bw-ssh-key.XXXXXX)

  bw get item $item_id | jq -r '.sshKey.privateKey' > $tmp_key
  chmod 600 $tmp_key
  ssh-add $tmp_key
  rm -f $tmp_key
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.tmp/google-cloud-sdk/path.fish.inc" ]; . "$HOME/.tmp/google-cloud-sdk/path.fish.inc"; end

