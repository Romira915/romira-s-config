@echo off
setlocal
set "MSYS2_BASH=%USERPROFILE%\scoop\apps\msys2\current\usr\bin\bash.exe"
if not exist "%MSYS2_BASH%" exit /b 0
"%MSYS2_BASH%" -lc "if [ -f ~/.codex/herdr-agent-state.sh ]; then sh ~/.codex/herdr-agent-state.sh session; fi"
exit /b 0
