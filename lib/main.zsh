function() {
    local pluginDirectory

    zstyle -s ':execute-after-command:internal:setting:*' 'plugin-directory' 'pluginDirectory'

    source "${pluginDirectory:?}/lib/lib.zsh"

    if
        [[ "$TERM_PROGRAM" == 'iTerm.app' ]] \
        || [[ "$TERM_PROGRAM" == 'Apple_Terminal' ]] \
        || [[ -n "$ITERM_SESSION_ID" ]] \
        || [[ -n "$TERM_SESSION_ID" ]]
    then
        source "${pluginDirectory}/lib/apple/functions.zsh"
    elif
        [[ "$DISPLAY" != '' ]] \
        && command -v xdotool 1> /dev/null 2>&1 \
        && command -v wmctrl 1> /dev/null 2>&1
    then
        source "${pluginDirectory}/lib/xdotool/functions.zsh"
    else
        source "${pluginDirectory}/lib/unsupported/functions.zsh"
    fi
}