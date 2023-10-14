function .zeac-is-terminal-active() {
    # run an AppleScript, selected from ./resources by basename given as the
    # first argument, with all other arguments as positional arguments to the
    # script's `on run` handler.
    function .zeac-run-applescript() {
        local scriptName="${1}"
        local pluginDirectory

        shift

        zstyle -s ':execute-after-command:internal:setting:*' 'plugin-directory' 'pluginDirectory'

        "${pluginDirectory:?}/lib/apple/resources/${scriptName:?}.applescript" "$@" 2>/dev/null
    }

    # exit with code 0 if the terminal window/tab is active, code 1 if inactive.
    function .zeac-is-terminal-window-active() {
        local terminal

        if [[ "${TERM_PROGRAM}" == 'iTerm.app' ]] || [[ -n "${ITERM_SESSION_ID}" ]]; then
            terminal="iterm2"
        elif [[ "${TERM_PROGRAM}" == 'Apple_Terminal' ]] || [[ -n "${TERM_SESSION_ID}" ]]; then
            terminal="apple-terminal"
        else
            .zeac-handle-unsupported-terminal
            return $?
        fi

        .zeac-run-applescript "is-${terminal}-active" "$(.zeac-current-tty)"
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
