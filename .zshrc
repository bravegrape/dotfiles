

## Add autocompletion for git

autoload -Uz compinit && compinit

# Load version control informatin
autoload -Uz vcs_info
precmd() { vcs_info }

# Define colours

CLR0=$(tput setaf 0)
CLR1=$(tput setaf 1)
CLR2=$(tput setaf 2)
CLR3=$(tput setaf 3)
CLR4=$(tput setaf 4)
CLR5=$(tput setaf 5)
CLR6=$(tput setaf 6)
CLR7=$(tput setaf 7)
CLR8=$(tput setaf 8)
CLR9=$(tput setaf 9)
RESET=$(tput sgr0)

# https://gist.github.com/mika/e30b4e99c338f5d80d7681407708609b

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' ! '
zstyle ':vcs_info:*' stagedstr '+ '

# enable hooks, requires Zsh >=4.3.11
if [[ $ZSH_VERSION == 4.3.<11->* || $ZSH_VERSION == 4.<4->* || $ZSH_VERSION == <5->* ]] ; then
  # hook for untracked files
  +vi-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == 'true'  ]] && \
       [[ -n $(git ls-files --others --exclude-standard) ]] ; then
       hook_com[staged]+='|☂'
    fi
  }

  # unpushed commits
  +vi-outgoing() {
    local gitdir="$(git rev-parse --git-dir 2>/dev/null)"
    [ -n "$gitdir" ] || return 0

    if [ -r "${gitdir}/refs/remotes/git-svn" ] ; then
      local count=$(git rev-list remotes/git-svn.. 2>/dev/null | wc -l)
    else
      local branch="$(cat ${gitdir}/HEAD 2>/dev/null)"
      branch=${branch##*/heads/}
      local count=$(git rev-list remotes/origin/${branch}.. 2>/dev/null | wc -l)
    fi

    if [[ "$count" -gt 0 ]] ; then
      hook_com[staged]+="|⬆"
    fi
  }

  # hook for stashed files
  +vi-stashed() {
    if git rev-parse --verify refs/stash &>/dev/null ; then
      hook_com[staged]+='|s'
    fi
  }

  zstyle ':vcs_info:git*+set-message:*' hooks stashed untracked outgoing
fi


## Build the vcs_info_msg_0_ variable

zstyle ':vcs_info:git:*' formats '%F{5}%r %F{8}on %F{1}%b %u%c'

## Set up the prompt (with git branch name)

setopt prompt_subst

PROMPT='
   ${vcs_info_msg_0_}
''${CLR8}'$'\U250F\U2501 ''${PWD}
'$'\U2503
'$'\U2517\U2501 ''${RESET}'
