function bw-add-ssh
  set -l item_id "d8778a92-7c5f-481d-a046-fa59ecb65132"
  set -l tmp_key (mktemp -p /tmp bw-ssh-key.XXXXXX)

  bw get item $item_id | jq -r '.sshKey.privateKey' > $tmp_key
  chmod 600 $tmp_key
  ssh-add $tmp_key
  rm -f $tmp_key
end
