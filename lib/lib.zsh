# Exit with 0 if inside a TMUX pane
function .zeac-is-inside-tmux() {
    [[ "$TMUX" != "" ]]
}

# Find the TTY for the current shell, also accounting for TMUX.
function .zeac-current-tty() {
    if .zeac-is-inside-tmux; then
        tmux display-message -p '#{client_tty}'
    else
        echo $TTY
    fi
}

# Exit with 0 if given TMUX pane is the active one.
function .zeac-is-current-tmux-pane-active() {
    .zeac-is-inside-tmux || return 1

    local active_pane_id=$(tmux list-windows -F '#{window_active} #{pane_id}' | grep -i '^1' | awk '{ print $2 }')

    if [[ "$TMUX_PANE" == "$active_pane_id" ]]; then
        return 0
    fi

    return 1
}

function .zeac-handle-unsupported-terminal() {
    local suppressUnableCheckActiveWindow

    zstyle -b ':execute-after-command:user-setting:*' 'suppress-unable-check-active-window' 'suppressUnableCheckActiveWindow'

    if [[ "${suppressUnableCheckActiveWindow}" = no ]]; then
        printf -- 'ERROR: Unsupported terminal for checking for an active '
        printf -- 'window. To avoid this error, either set '
        printf -- '"check-active-window" to "no" or set '
        printf -- '"suppress-unable-check-active-window" to "yes".\n'
    fi

    return 3
}