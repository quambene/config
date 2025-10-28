# ~/.bashrc: executed by bash(1) for non-login shells.

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Source aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Source git completion
[ -f ~/.git-completion.bash ] && source ~/.git-completion.bash

# Source key bindings and completion for skim
[ -f ~/.skim/key-bindings.bash ] && source ~/.skim/key-bindings.bash
[ -f ~/.skim/completion.bash ] && source ~/.skim/completion.bash

# Source z and zi commands for skims
[ -f ~/.zoxide/zoxide.bash ] && source ~/.zoxide/zoxide.bash
