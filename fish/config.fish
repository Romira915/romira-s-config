# Profile cache: avoid slow bass+python on every startup
set -l _pcache ~/.cache/fish/profile_cache.fish
set -l _cache_valid true

if not test -f $_pcache
    set _cache_valid false
else
    for _f in ~/.profile ~/.cargo/env \
              ~/.config/romira-s-config/shell/profile.d/* \
              ~/.config/romira-s-config/shell/system.profile.d/*
        if test -f $_f; and test $_f -nt $_pcache
            set _cache_valid false
            break
        end
    end
end

if not $_cache_valid
    # Snapshot exported vars before bass
    set -l _snap
    for _k in (set --names -gx)
        set -a _snap "$_k="(string escape -- $$_k | string join \x1f)
    end
    # Snapshot function bodies before bass (to detect overrides like ls→eza)
    set -l _fnames_before (functions --names)
    set -l _fbodies_before
    for _f in $_fnames_before
        set -a _fbodies_before (functions $_f | string collect | string escape)
    end

    bass source ~/.profile

    # Build cache from diff
    mkdir -p (dirname $_pcache)
    echo "# Profile cache - "(date -Iseconds) >$_pcache

    for _k in (set --names -gx)
        set -l _cur "$_k="(string escape -- $$_k | string join \x1f)
        if not contains -- $_cur $_snap
            echo "set -gx $_k" (string escape -- $$_k) >>$_pcache
        end
    end

    # Capture new or changed functions (aliases from bass)
    for _f in (functions --names)
        set -l _body (functions $_f | string collect | string escape)
        set -l _idx (contains -i -- $_f $_fnames_before)
        if test -n "$_idx"
            # Existing function - save only if body changed
            test "$_body" != "$_fbodies_before[$_idx]"; and functions $_f >>$_pcache
        else
            # New function
            functions $_f >>$_pcache
        end
    end
else
    source $_pcache
end

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
if [ -f "$HOME/.tmp/google-cloud-sdk/path.fish.inc" ]; . "$HOME/.tmp/google-cloud-sdk/path.fish.inc"; end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
