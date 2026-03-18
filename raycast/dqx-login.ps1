# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DQX Login
# @raycast.mode silent
# @raycast.packageName Gaming

# Optional parameters:
# @raycast.icon :video_game:
# @raycast.description DQX にプレイヤー1・2を自動ログイン

Start-Process "AutoHotkey.exe" -ArgumentList "`"C:\Users\romira\.config\romira-s-config\autohotkey\dqx_login.ahk`" run"
