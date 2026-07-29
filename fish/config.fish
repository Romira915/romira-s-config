# Ensure MSYS2 base paths are available (needed when spawned by tmux)
if test -d /usr/bin; and not contains /usr/bin $PATH
    set -gx PATH /usr/local/bin /usr/bin /bin $PATH
end

function __load_cached_posix_profile
    set -l cache_home "$HOME/.cache"
    if set -q XDG_CACHE_HOME
        set cache_home "$XDG_CACHE_HOME"
    end
    set -l cache_dir "$cache_home/fish"
    # Do not share a cache across inherited PATH variants because .profile derives its PATH from them.
    set -l path_checksum (string join \x1e $PATH | command cksum)
    set -l cache_key (string split ' ' -- "$path_checksum")[1]
    set -l cache_file "$cache_dir/posix-profile-$cache_key.fish"

    set -l profile_dirs \
        "$HOME/.config/romira-s-config/shell/profile.d" \
        "$HOME/.config/romira-s-config/shell/system.profile.d"
    set -l profile_sources \
        "$HOME/.profile" \
        "$HOME/.cargo/env" \
        "$HOME/.config/fish/functions/bass.fish" \
        "$HOME/.config/fish/functions/__bass.py" \
        $profile_dirs

    for profile_dir in $profile_dirs
        if test -d "$profile_dir"
            for profile_file in "$profile_dir"/*
                test -f "$profile_file"; and set -a profile_sources "$profile_file"
            end
        end
    end
    for profile_command in brew mise
        set -l command_path (command -v "$profile_command")
        test -n "$command_path"; and set -a profile_sources "$command_path"
    end

    set -l refresh_cache false
    if not test -s "$cache_file"
        set refresh_cache true
    else
        for profile_source in $profile_sources
            if test -e "$profile_source"; and test "$profile_source" -nt "$cache_file"
                set refresh_cache true
                break
            end
        end
    end

    if "$refresh_cache"
        command mkdir -p "$cache_dir"; or begin
            bass source ~/.profile
            return
        end

        set -l cache_tmp (command mktemp "$cache_file.XXXXXX")
        if test -z "$cache_tmp"
            bass source ~/.profile
            return
        end

        # Keep .profile as the single source of truth; cache only bass's generated fish code.
        if bass -d source ~/.profile >"$cache_tmp"
            command mv "$cache_tmp" "$cache_file"
        else
            set -l bass_status $status
            command rm "$cache_tmp"
            return $bass_status
        end
    else
        source "$cache_file"
    end
end

__load_cached_posix_profile
functions -e __load_cached_posix_profile

# Syntax highlighting colors
set -g fish_color_command blue

for f in ~/.config/romira-s-config/fish/config.d/*.fish
    source $f
end
if string match -q "*microsoft*" (uname -r)
    # WSL Only
    source ~/.config/romira-s-config/fish/system.config.d/wsl.fish
end

command -q zoxide; and zoxide init fish | source
command -q mcfly; and mcfly init fish | source
command -q starship; and starship init fish | source

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.tmp/google-cloud-sdk/path.fish.inc" ]
    . "$HOME/.tmp/google-cloud-sdk/path.fish.inc"
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
