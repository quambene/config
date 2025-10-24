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
    local query="$1"
    local branch
    branch=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
                | grep -v '^HEAD$' \
                | sk --exact --query="$query") || return

    if [[ $branch == origin/* ]]; then
        # Extract the remote branch
        local remote_branch=${branch#origin/}
        git checkout -t "origin/$remote_branch"
    else
        git checkout "$branch"
    fi
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
