function bw-add-ssh
  set -l item_id "d8778a92-7c5f-481d-a046-fa59ecb65132"
  set -l tmp_key (mktemp -p /tmp bw-ssh-key.XXXXXX)

  bw get item $item_id | jq -er '.sshKey.privateKey | select(type == "string" and length > 0)' > $tmp_key
  set -l fetch_status $pipestatus
  if test $fetch_status[1] -ne 0 -o $fetch_status[2] -ne 0
    rm -f $tmp_key
    echo "Bitwarden から SSH 秘密鍵を取得できませんでした" >&2
    return 1
  end

  chmod 600 $tmp_key
  ssh-add $tmp_key
  set -l add_status $status
  rm -f $tmp_key
  return $add_status
end
