# ZSH Execute After Command

## Purpose

This is a ZSH plugin that is used to call functions after a command on the CLI finishes along with some context. When a function is called by this plugin, it recieves the following parameters:
1. Command as it was typed on the commmand line
2. Command as it is executed by ZSH (A condensed form, limited in size)
3. Command as it is executed by ZSH (full form)
4. The exit code of the command
5. The execution time (in seconds) of the command
6. If the window/tab/pane of the terminal or TMUX instance where the command was executed has focus when the command finishes
    - `0`: Had focus
    - `1`: Did not have focus
    - `2`: Not checking for focus
    - `3`: Unsupported terminal for checking focus

NOTE: The first three parameters are the same values that are provided by the ZSH [preexec hook](https://zsh.sourceforge.io/Doc/Release/Functions.html).

### How to use

This plugin runs after every command. If no callback functions are registered, then it just quickly exits, otherwise it will call those callback functions.

This plugin provides a function called `zsh-execute-after-command-add-functions`. This funcation can be called in order to register callback functions with the plugin.

<details>
<summary>This can best be explained with an example:</summary>

```shell
$> source "execute-after-command.plugin.zsh"

$> function jml1() {
    local param
    for param in "$@"; do
        printf -- 'JML1: "%s"\n' "${param}"
    done;
    printf -- '\n'
}

$> function jml2() {
    local param
    for param in "$@"; do
        printf -- 'JML2: "%s"\n' "${param}"
    done;
    printf -- '\n'
}

$> function jml3() {
    local param
    for param in "$@"; do
        printf -- 'JML3: "%s"\n' "${param}"
    done;
    printf -- '\n'
}

$> # Execute seperately to show fucntions can be added one at a time or multiple at once
zsh-execute-after-command-add-functions jml1
zsh-execute-after-command-add-functions jml2 jml3

$> echo 'Hello world!'
Hello world!
zsh-execute-after-command: JML1: "echo 'Hello world!'"
zsh-execute-after-command: JML1: "echo 'Hello world!'"
zsh-execute-after-command: JML1: "echo 'Hello world!'"
zsh-execute-after-command: JML1: "0"
zsh-execute-after-command: JML1: "0"
zsh-execute-after-command: JML1: "0"
zsh-execute-after-command:
zsh-execute-after-command: JML2: "echo 'Hello world!'"
zsh-execute-after-command: JML2: "echo 'Hello world!'"
zsh-execute-after-command: JML2: "echo 'Hello world!'"
zsh-execute-after-command: JML2: "0"
zsh-execute-after-command: JML2: "0"
zsh-execute-after-command: JML2: "0"
zsh-execute-after-command:
zsh-execute-after-command: JML3: "echo 'Hello world!'"
zsh-execute-after-command: JML3: "echo 'Hello world!'"
zsh-execute-after-command: JML3: "echo 'Hello world!'"
zsh-execute-after-command: JML3: "0"
zsh-execute-after-command: JML3: "0"
zsh-execute-after-command: JML3: "0"
zsh-execute-after-command:

$> # Execute a command and remove focus from terminal before the command finishes
echo 'Hello world!'; sleep 5
Hello world!
zsh-execute-after-command: JML1: "echo 'Hello world!'; sleep 5"
zsh-execute-after-command: JML1: "echo 'Hello world!'; sleep 5"
zsh-execute-after-command: JML1: "echo 'Hello world!'
zsh-execute-after-command: sleep 5"
zsh-execute-after-command: JML1: "0"
zsh-execute-after-command: JML1: "5"
zsh-execute-after-command: JML1: "1"
zsh-execute-after-command:
zsh-execute-after-command: JML2: "echo 'Hello world!'; sleep 5"
zsh-execute-after-command: JML2: "echo 'Hello world!'; sleep 5"
zsh-execute-after-command: JML2: "echo 'Hello world!'
zsh-execute-after-command: sleep 5"
zsh-execute-after-command: JML2: "0"
zsh-execute-after-command: JML2: "5"
zsh-execute-after-command: JML2: "1"
zsh-execute-after-command:
zsh-execute-after-command: JML3: "echo 'Hello world!'; sleep 5"
zsh-execute-after-command: JML3: "echo 'Hello world!'; sleep 5"
zsh-execute-after-command: JML3: "echo 'Hello world!'
zsh-execute-after-command: sleep 5"
zsh-execute-after-command: JML3: "0"
zsh-execute-after-command: JML3: "5"
zsh-execute-after-command: JML3: "1"
zsh-execute-after-command:
```
</details>

## Requirements

### MacOS

Apple Terminal or iTerm2 must be used in order for focus detection to work properly.

Note: This is because in order to determine focus the terminal needs to be scriptable via AppleScript.

### Linux

The tools `xdotool` and `wmctrl` must be installed in order for focus detection to work properly.

## Installation

To install this plugin, simply download this project and `source` the `execute-after-command.plugin.zsh` file.

This should also compatible with ZSH frameworks/package managers

## Configuration

This plugin uses ZSH's built in zstyle for storing settings. Below is a list of the settings and their initial values:

```shell
# Where to write any errors that occur during execution
# Defaults to stderr (output on the screen)
zstyle ':execute-after-command:user-setting:*' 'error-log'                              '/dev/stderr'

# Whether or not to check if the window is active when the command finishes
# Defaults to no
zstyle ':execute-after-command:user-setting:*' 'check-active-window'                    'no'

# Whether or not to suppress the error mesage about being unable to check if the window is active when the command finishes. This error will not occur if check-active-window is 'no'
# Defaults to no
zstyle ':execute-after-command:user-setting:*' 'suppress-unable-check-active-window'    'no'

# The list of function callbacks for this to call. Should be managed by 'zsh-execute-after-command-add-functions' function.
# Defaults to an empty list
zstyle ':execute-after-command:user-setting:*' 'function-list'
```

## Inspiration

I found [Federico Marzocchi's ZSH Notify](https://github.com/marzocchi/zsh-notify) ZSH plugin and was using it for a little bit. I wanted to do things a little different, and so this project was created. Thanks to Federico Marzocchi for his work on ZSH Notify!