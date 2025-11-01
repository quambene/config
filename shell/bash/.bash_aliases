#!/bin/bash

alias ..='cd ..'
alias ...='cd ../..'
alias datetime='date +"%Y-%m-%d %H:%M:%S %Z"'
alias current_millis='date +%s%N | cut -b1-13'

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

find_file() {
    find . -iname "*$1*"
}

find_process_id() {
    pgrep -aif "$1"
}

find_history() {
    history | grep "$1"
}

find_package() {
    dpkg -s "$1"
}

find_snap() {
    snap list "$1"
}

# linux
alias show-hardware='sudo lshw'
alias show-cpu='lscpu'
alias show-cpu-2='cat /proc/cpuinfo'
alias show-ram='free -h'
alias disk-usage='du -h --max-depth=1'
alias disk-usage-top-10='du -ah | sort -hr | head -n 10'
alias list-mountpoints='df -h -x squashfs'
alias list-usb='lsusb'
alias list-usb-verbose='usb-devices'
alias list-devices='sudo fdisk -l'
alias list-packages='apt list --installed'
alias list-snaps='snap list'
alias show-firmware-updates='fwupdmgr get-updates'
alias update-firmware='fwupdmgr update'

# git
alias merge-dev='git merge --no-ff --no-commit dev'
alias merge-master='git merge --no-ff --no-commit master'
alias merge-main='git merge --no-ff --no-commit main'
alias git-diff-stat='git diff --stat master..dev'
alias diff-dev='git difftool dev'
alias diff-master='git difftool master'
alias diff-main='git difftool main'
alias gitlog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"

git-loc() {
	git ls-files | grep "\.$1" | xargs wc -l
}

git-branch-delete() {
	git branch | grep "$1" | xargs git branch -d
}

# rust
alias f-nightly='cargo +nightly fmt'
alias fmt='cargo fmt'
alias fmt-all='cargo fmt --all'
alias check='cargo check'
alias check-all='cargo check --all-targets'
alias check-all-features='cargo check --all-targets --all-features'
alias clippy='cargo clippy'
alias clippy-nightly='cargo +nightly clippy'
alias clippy-all='cargo clippy --all-targets'
alias clippy-all-features='cargo clippy --all-targets --all-features'
alias cargo-docs='cargo doc --no-deps --document-private-items'
alias cargo-docs-open='cargo doc --open --no-deps --document-private-items'
