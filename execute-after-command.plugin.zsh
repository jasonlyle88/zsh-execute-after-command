# Standardized $0 handling
# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

declare zshExecuteAfterCommandPluginDirectory="${0:h}"

function () {
    # Standardize options
    # https://wiki.zshell.dev/community/zsh_plugin_standard#standard-recommended-options
    builtin emulate -L zsh ${=${options[xtrace]:#off}:+-o xtrace}
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    # Load ZSH modules
    zmodload zsh/datetime

    # User customizable settings
    zstyle ':execute-after-command:user-setting:*' 'error-log'                              '/dev/stderr'
    zstyle ':execute-after-command:user-setting:*' 'check-active-window'                    'no'
    zstyle ':execute-after-command:user-setting:*' 'suppress-unable-check-active-window'    'no'
    # zstyle ':execute-after-command:user-setting:*' 'function-list'

    # Internal settings
    zstyle ':execute-after-command:internal:setting:*'  'plugin-directory'  "${zshExecuteAfterCommandPluginDirectory}"
    # zstyle ':execute-after-command:internal:runtime:*'  'last-command-start-time'
    # zstyle ':execute-after-command:internal:runtime:*'  'last-command-as-typed'
    # zstyle ':execute-after-command:internal:runtime:*'  'last-command-as-executed-limited'
    # zstyle ':execute-after-command:internal:runtime:*'  'last-command-as-executed-full'
    # zstyle ':execute-after-command:internal:runtime:*'  'last-command-window-id'

    source "${zshExecuteAfterCommandPluginDirectory}/lib/main.zsh"

    function zsh-execute-after-command-add-functions() {
        local -a currentFunctions

        zstyle -a ':execute-after-command:user-setting:*' 'function-list' 'currentFunctions'

        if [[ "${#currentFunctions[@]}" -eq 0 ]]; then
            zstyle ':execute-after-command:user-setting:*' 'function-list' "$@"
        else
            zstyle ':execute-after-command:user-setting:*' 'function-list' "${currentFunctions[@]}" "$@"
        fi
    }

    # This function will be executed after a command has been entered, but before
    # a command is actually executed
    function zsh-execute-after-command-preexec-hook() {
        zstyle ':execute-after-command:internal:runtime:*'  'last-command-start-time'           "${EPOCHSECONDS}"
        zstyle ':execute-after-command:internal:runtime:*'  'last-command-as-typed'             "${1}"
        zstyle ':execute-after-command:internal:runtime:*'  'last-command-as-executed-limited'  "${2}"
        zstyle ':execute-after-command:internal:runtime:*'  'last-command-as-executed-full'     "${3}"
    }

    # This function will be executed after a command has completed execution
    function zsh-execute-after-command-precmd-hook() {
        # Information from system
        local lastCommandExitStatus="${?}"
        local lastCommandStopTime="${EPOCHSECONDS}"

        # Information from internal runtime
        local lastCommandStartTime
        local lastCommandAsTyped
        local lastCommandAsExecutedLimited
        local lastCommandAsExecutedFull

        # Information from user settings
        local errorLog
        local checkActiveWindow
        local -a functionList

        # Information from internal settings
        local pluginDirectory

        # Procedural
        local longestFunctionName
        local func
        local lastCommandExecutionSeconds
        local windowFocused

        zstyle -s ':execute-after-command:internal:runtime:*'   'last-command-start-time'           'lastCommandStartTime'
        zstyle -s ':execute-after-command:internal:runtime:*'   'last-command-as-typed'             'lastCommandAsTyped'
        zstyle -s ':execute-after-command:internal:runtime:*'   'last-command-as-executed-limited'  'lastCommandAsExecutedLimited'
        zstyle -s ':execute-after-command:internal:runtime:*'   'last-command-as-executed-full'     'lastCommandAsExecutedFull'

        zstyle -s ':execute-after-command:user-setting:*'       'error-log'                         'errorLog'
        zstyle -b ':execute-after-command:user-setting:*'       'check-active-window'               'checkActiveWindow'
        zstyle -a ':execute-after-command:user-setting:*'       'function-list'                     'functionList'

        zstyle -s ':execute-after-command:internal:setting:*'   'plugin-directory'                  'pluginDirectory'

        # If there are no functions to execute, then there is nothing to do
        if [[ "${#functionList[@]}" -eq 0 ]]; then
            return 0
        fi

        touch "${errorLog}"
        {
            # Calculate elapsed time
            (( lastCommandExecutionSeconds = lastCommandStopTime - lastCommandStartTime ))

            # Determine if the window was focused
            if [[ "${checkActiveWindow}" = 'yes' ]]; then
                .zeac-is-terminal-active
                windowFocused=$?
            else
                windowFocused=2
            fi

            for func in "${functionList[@]}"; do
                "${func}" \
                    ${lastCommandAsTyped} \
                    ${lastCommandAsExecutedLimited} \
                    ${lastCommandAsExecutedFull} \
                    ${lastCommandExitStatus} \
                    ${lastCommandExecutionSeconds} \
                    ${windowFocused}
            done
        } 2>&1 | sed 's|^|zsh-execute-after-command: |' >> "${errorLog}"

        zstyle -d ':execute-after-command:internal:runtime:*'   'last-command-start-time'
        zstyle -d ':execute-after-command:internal:runtime:*'   'last-command-as-typed'
        zstyle -d ':execute-after-command:internal:runtime:*'   'last-command-as-executed-limited'
        zstyle -d ':execute-after-command:internal:runtime:*'   'last-command-as-executed-full'
    }

    autoload -U add-zsh-hook
    add-zsh-hook preexec zsh-execute-after-command-preexec-hook
    add-zsh-hook precmd zsh-execute-after-command-precmd-hook
}

unset zshExecuteAfterCommandPluginDirectory
