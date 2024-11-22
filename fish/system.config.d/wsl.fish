function start_fcitx5
    if not pgrep -x "fcitx5" > /dev/null
        fcitx5 --disable=wayland -d --verbose '*'=0 &
    end
end

start_fcitx5
