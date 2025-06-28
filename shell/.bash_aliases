#!/bin/bash

alias ..='cd ..'
alias ...='cd ../..'

# fuzzy search on all directories in home directory sorted by nesting (deepest
# directories last)
fdf() {
    local query="$1"

    fd --type d --max-depth 4 . "$HOME" 2>/dev/null \
        | awk '{ print gsub("/", "/"), $0 }' \
        | sed 's|^\./||' \
        | sort -n \
        | cut -d' ' -f2- \
        | sk --tiebreak=index --exact --query="$query" --select-1 --exit-0
}

# change directory with fuzzy finder
cdf() {
    # allow multiple arguments
    local query="$*"
    local dir

    dir=$(fdf "$query")

    if [ -n "$dir" ]; then
        cd "$dir" || exit
    fi
}

# fuzzy search all local and remote branches
git-checkout() {
    git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
        | grep -v '^HEAD' \
        | sk \
        | xargs -r git checkout
}

# open project in helix with fuzzy finder
hxf() {
    # allow multiple arguments
    local query="$*"
    local dir

    dir=$(fdf "$query")

    if [ -n "$dir" ]; then
        hx "$dir" || exit
    fi
}

# open project in vs code with fuzzy finder
codef() {
    # allow multiple arguments
    local query="$*"
    local dir

    dir=$(fdf "$query")

    if [ -n "$dir" ]; then
        code "$dir" || exit
    fi
}
