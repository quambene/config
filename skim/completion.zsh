# copied and modifed from https://github.com/skim-rs/skim/blob/master/shell/completion.zsh
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ completion.zsh
#
# - $SKIM_TMUX               (default: 0)
# - $SKIM_TMUX_OPTS          (default: '-d 40%')
# - $SKIM_COMPLETION_TRIGGER (default: '**')
# - $SKIM_COMPLETION_OPTS    (default: empty)
# copied and modified from https://github.com/junegunn/fzf/blob/master/shell/completion.zsh

# Both branches of the following `if` do the same thing -- define
# __skim_completion_options such that `eval $__skim_completion_options` sets
# all options to the same values they currently have. We'll do just that at
# the bottom of the file after changing options to what we prefer.
#
# IMPORTANT: Until we get to the `emulate` line, all words that *can* be quoted
# *must* be quoted in order to prevent alias expansion. In addition, code must
# be written in a way works with any set of zsh options. This is very tricky, so
# careful when you change it.
#
# Start by loading the builtin zsh/parameter module. It provides `options`
# associative array that stores current shell options.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  # This is the fast branch and it gets taken on virtually all Zsh installations.
  #
  # ${(kv)options[@]} expands to array of keys (option names) and values ("on"
  # or "off"). The subsequent expansion# with (j: :) flag joins all elements
  # together separated by spaces. __skim_completion_options ends up with a value
  # like this: "options=(shwordsplit off aliases on ...)".
  __skim_completion_options="options=(${(j: :)${(kv)options[@]}})"
else
  # This branch is much slower because it forks to get the names of all
  # zsh options. It's possible to eliminate this fork but it's not worth the
  # trouble because this branch gets taken only on very ancient or broken
  # zsh installations.
  () {
    # That `()` above defines an anonymous function. This is essentially a scope
    # for local parameters. We use it to avoid polluting global scope.
    'local' '__skim_opt'
    __skim_completion_options="setopt"
    # `set -o` prints one line for every zsh option. Each line contains option
    # name, some spaces, and then either "on" or "off". We just want option names.
    # Expansion with (@f) flag splits a string into lines. The outer expansion
    # removes spaces and everything that follow them on every line. __skim_opt
    # ends up iterating over option names: shwordsplit, aliases, etc.
    for __skim_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__skim_opt" ]]; then
        # Option $__skim_opt is currently on, so remember to set it back on.
        __skim_completion_options+=" -o $__skim_opt"
      else
        # Option $__skim_opt is currently off, so remember to set it back off.
        __skim_completion_options+=" +o $__skim_opt"
      fi
    done
    # The value of __skim_completion_options here looks like this:
    # "setopt +o shwordsplit -o aliases ..."
  }
fi

# Enable the default zsh options (those marked with <Z> in `man zshoptions`)
# but without `aliases`. Aliases in functions are expanded when functions are
# defined, so if we disable aliases here, we'll be sure to have no pesky
# aliases in any of our functions. This way we won't need prefix every
# command with `command` or to quote every word to defend against global
# aliases. Note that `aliases` is not the only option that's important to
# control. There are several others that could wreck havoc if they are set
# to values we don't expect. With the following `emulate` command we
# sidestep this issue entirely.
'emulate' 'zsh' '-o' 'no_aliases'

# This brace is the start of try-always block. The `always` part is like
# `finally` in lesser languages. We use it to *always* restore user options.
{

# Bail out if not interactive shell.
[[ -o interactive ]] || return 0

# To use custom commands instead of find, override _skim_compgen_{path,dir}
if ! declare -f _skim_compgen_path > /dev/null; then
  _skim_compgen_path() {
    echo "$1"
    command find -L "$1" \
      -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
      -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

if ! declare -f _skim_compgen_dir > /dev/null; then
  _skim_compgen_dir() {
    command find -L "$1" \
      -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -type d \
      -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

###########################################################

__skim_comprun() {
  if [[ "$(type _skim_comprun 2>&1)" =~ function ]]; then
    _skim_comprun "$@"
  elif [ -n "$TMUX_PANE" ] && { [ "${SKIM_TMUX:-0}" != 0 ] || [ -n "$SKIM_TMUX_OPTS" ]; }; then
    shift
    if [ -n "$SKIM_TMUX_OPTS" ]; then
      sk-tmux ${(Q)${(Z+n+)SKIM_TMUX_OPTS}} -- "$@"
    else
      sk-tmux -d ${SKIM_TMUX_HEIGHT:-40%} -- "$@"
    fi
  else
    shift
    sk "$@"
  fi
}

# Extract the name of the command. e.g. foo=1 bar baz**<tab>
__skim_extract_command() {
  local token tokens
  tokens=(${(z)1})
  for token in $tokens; do
    token=${(Q)token}
    if [[ "$token" =~ [[:alnum:]] && ! "$token" =~ "=" ]]; then
      echo "$token"
      return
    fi
  done
  echo "${tokens[1]}"
}

__skim_generic_path_completion() {
  local base lbuf cmd compgen skim_opts suffix tail dir leftover matches
  base=$1
  lbuf=$2
  cmd=$(__skim_extract_command "$lbuf")
  compgen=$3
  skim_opts=$4
  suffix=$5
  tail=$6

  setopt localoptions nonomatch
  eval "base=$base"
  [[ $base = *"/"* ]] && dir="$base"
  while [ 1 ]; do
    if [[ -z "$dir" || -d ${dir} ]]; then
      leftover=${base/#"$dir"}
      leftover=${leftover/#\/}
      [ -z "$dir" ] && dir='.'
      [ "$dir" != "/" ] && dir="${dir/%\//}"
      matches=$(eval "$compgen $(printf %q "$dir")" | SKIM_DEFAULT_OPTIONS="--height ${SKIM_TMUX_HEIGHT:-40%} --reverse $SKIM_DEFAULT_OPTIONS $SKIM_COMPLETION_OPTS" __skim_comprun "$cmd" ${(Q)${(Z+n+)skim_opts}} -q "$leftover" | while read item; do
        echo -n "${(q)item}$suffix "
      done)
      matches=${matches% }
      if [ -n "$matches" ]; then
        LBUFFER="$lbuf$matches$tail"
      fi
      zle reset-prompt
      break
    fi
    dir=$(dirname "$dir")
    dir=${dir%/}/
  done
}

_skim_path_completion() {
  __skim_generic_path_completion "$1" "$2" _skim_compgen_path \
    "-m" "" " "
}

_skim_dir_completion() {
  __skim_generic_path_completion "$1" "$2" _skim_compgen_dir \
    "" "/" ""
}

_skim_feed_fifo() (
  command rm -f "$1"
  mkfifo "$1"
  cat <&0 > "$1" &
)

_skim_complete() {
  setopt localoptions ksh_arrays
  # Split arguments around --
  local args rest str_arg i sep
  args=("$@")
  sep=
  for i in {0..${#args[@]}}; do
    if [[ "${args[$i]}" = -- ]]; then
      sep=$i
      break
    fi
  done
  if [[ -n "$sep" ]]; then
    str_arg=
    rest=("${args[@]:$((sep + 1)):${#args[@]}}")
    args=("${args[@]:0:$sep}")
  else
    str_arg=$1
    args=()
    shift
    rest=("$@")
  fi

  local fifo lbuf cmd matches post
  fifo="${TMPDIR:-/tmp}/skim-complete-fifo-$$"
  lbuf=${rest[0]}
  cmd=$(__skim_extract_command "$lbuf")
  post="${funcstack[1]}_post"
  type $post > /dev/null 2>&1 || post=cat

  _skim_feed_fifo "$fifo"
  matches=$(SKIM_DEFAULT_OPTIONS="--height ${SKIM_TMUX_HEIGHT:-40%} --reverse $SKIM_DEFAULT_OPTIONS $SKIM_COMPLETION_OPTS $str_arg" __skim_comprun "$cmd" "${args[@]}" -q "${(Q)prefix}" < "$fifo" | $post | tr '\n' ' ')
  if [ -n "$matches" ]; then
    LBUFFER="$lbuf$matches"
  fi
  zle reset-prompt
  command rm -f "$fifo"
}

_skim_complete_telnet() {
  _skim_complete --no-multi -- "$@" < <(
    command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0' |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

_skim_complete_ssh() {
  _skim_complete --no-multi -- "$@" < <(
    setopt localoptions nonomatch
    command cat <(command tail -n +1 ~/.ssh/config ~/.ssh/config.d/* /etc/ssh/ssh_config 2> /dev/null | command grep -i '^\s*host\(name\)\? ' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}' | command grep -v '[*?]') \
        <(command grep -oE '^[[a-z0-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }') \
        <(command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0') |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

_skim_complete_export() {
  _skim_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_skim_complete_unset() {
  _skim_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_skim_complete_unalias() {
  _skim_complete --no-multi -- "$@" < <(
    alias | sed 's/=.*//'
  )
}

_skim_complete_kill() {
  _skim_complete -m --preview 'echo {}' --preview-window down:3:wrap --min-height 15 -- "$@" < <(
    command ps -ef | sed 1d
  )
}

_skim_complete_kill_post() {
  awk '{print $2}'
}

skim-completion() {
  local tokens cmd prefix trigger tail matches lbuf d_cmds
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  # http://zsh.sourceforge.net/FAQ/zshfaq03.html
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  tokens=(${(z)LBUFFER})
  if [ ${#tokens} -lt 1 ]; then
    zle ${skim_default_completion:-expand-or-complete}
    return
  fi

  cmd=$(__skim_extract_command "$LBUFFER")

  # Explicitly allow for empty trigger.
  trigger=${SKIM_COMPLETION_TRIGGER-'**'}
  [ -z "$trigger" -a ${LBUFFER[-1]} = ' ' ] && tokens+=("")

  # When the trigger starts with ';', it becomes a separate token
  if [[ ${LBUFFER} = *"${tokens[-2]}${tokens[-1]}" ]]; then
    tokens[-2]="${tokens[-2]}${tokens[-1]}"
    tokens=(${tokens[0,-2]})
  fi

  lbuf=$LBUFFER
  tail=${LBUFFER:$(( ${#LBUFFER} - ${#trigger} ))}
  # Kill completion (do not require trigger sequence)
  if [ "$cmd" = kill -a ${LBUFFER[-1]} = ' ' ]; then
    tail=$trigger
    tokens+=$trigger
    lbuf="$lbuf$trigger"
  fi

  # Trigger sequence given
  if [ ${#tokens} -gt 1 -a "$tail" = "$trigger" ]; then
    d_cmds=(${=SKIM_COMPLETION_DIR_COMMANDS:-cd pushd rmdir})

    [ -z "$trigger"      ] && prefix=${tokens[-1]} || prefix=${tokens[-1]:0:-${#trigger}}
    [ -n "${tokens[-1]}" ] && lbuf=${lbuf:0:-${#tokens[-1]}}

    if eval "type _skim_complete_${cmd} > /dev/null"; then
      prefix="$prefix" eval _skim_complete_${cmd} ${(q)lbuf}
    elif [ ${d_cmds[(i)$cmd]} -le ${#d_cmds} ]; then
      _skim_dir_completion "$prefix" "$lbuf"
    else
      _skim_path_completion "$prefix" "$lbuf"
    fi
  # Fall back to default completion
  else
    zle ${skim_default_completion:-expand-or-complete}
  fi
}

[ -z "$skim_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || skim_default_completion=$binding[(s: :w)2]
  unset binding
}

zle     -N   skim-completion
bindkey '^I' skim-completion

} always {
  # Restore the original options.
  eval $__skim_completion_options
  'unset' '__skim_completion_options'
}
