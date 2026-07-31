function __load_wsl_ssh_agent_env --argument-names agent_env
    test -f "$agent_env"; or return 1

    while read -l line
        set -l assignment (string split -m 1 ';' -- "$line")[1]
        switch "$assignment"
            case 'SSH_AUTH_SOCK=*'
                set -gx SSH_AUTH_SOCK (string replace 'SSH_AUTH_SOCK=' '' -- "$assignment")
            case 'SSH_AGENT_PID=*'
                set -gx SSH_AGENT_PID (string replace 'SSH_AGENT_PID=' '' -- "$assignment")
        end
    end <"$agent_env"
end

function __ensure_wsl_ssh_agent
    if set -q SSH_AUTH_SOCK; and test -S "$SSH_AUTH_SOCK"
        return
    end

    set -l agent_env "$HOME/.ssh/agent.env"
    __load_wsl_ssh_agent_env "$agent_env"

    if not set -q SSH_AUTH_SOCK; or not test -S "$SSH_AUTH_SOCK"
        command mkdir -p "$HOME/.ssh"; or return 1
        ssh-agent -s >"$agent_env" 2>/dev/null; or return 1
        chmod 600 "$agent_env"; or return 1
        __load_wsl_ssh_agent_env "$agent_env"
    end
end

__ensure_wsl_ssh_agent
functions -e __ensure_wsl_ssh_agent __load_wsl_ssh_agent_env

function start_fcitx5
    if not pgrep -x "fcitx5" > /dev/null
        fcitx5 --disable=wayland -d --verbose '*'=0 &
    end
end

start_fcitx5
