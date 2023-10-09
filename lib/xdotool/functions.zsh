function .zeac-is-terminal-active() {
    # exit with code 0 if the terminal window/tab is active, code 1 if inactive.
    function .zeac-is-terminal-window-active {
        local activeWindowId
        local lastCommandWindowId

        activeWindowId="$(xdotool getwindowfocus)"
        zstyle -s ':execute-after-command:internal:runtime:*' 'last-command-window-id' 'lastCommandWindowId'

        if [[ "${activeWindowId}" == "${lastCommandWindowId}" ]]; then
            return 0
        fi

        return 1
    }

    if .zeac-is-terminal-window-active; then
        if .zeac-is-inside-tmux; then
            .zeac-is-current-tmux-pane-active
            return $?
        fi
    else
        return $?
    fi
}

function zsh-execute-after-command-store-window-id() {
    zstyle ':execute-after-command:internal:runtime:*' 'last-command-window-id' "$(xdotool getwindowfocus)"
}

autoload -U add-zsh-hook
add-zsh-hook preexec zsh-execute-after-command-store-window-id