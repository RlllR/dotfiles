#  _______| |__  _ __ ___
# |_  / __| '_ \| '__/ __|
#  / /\__ \ | | | | | (__
# /___|___/_| |_|_|  \___|
#

umask 022
bindkey -d # bindkey reset
bindkey -e # bindkey emacs-mode

# autloads
autoload -Uz compinit                && compinit
autoload -Uz promptinit              && promptinit && prompt clint
autoload -Uz colors                  && colors
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
autoload -Uz modify-current-argument
autoload -Uz smart-insert-last-word
autoload -Uz history-search-end
autoload -Uz terminfo
autoload -Uz vcs_info
autoload -Uz cdr
autoload -Uz zcalc
autoload -Uz zmv
autoload -Uz run-help                && unalias run-help && alias zhelp=run-help
autoload -Uz run-help-git
autoload -Uz run-help-svn

# zplugins
if [[ -f ~/.zplug/init.zsh ]]; then
    export ZPLUG_LOADFILE=$HOME/.zsh/zplug.zsh
    source ~/.zplug/init.zsh

    if ! zplug check --verbose; then
        printf "Install? [Y/n]: "
        if read -q; then
            echo ; zplug install
        fi
    fi
    zplug load --verbose
fi

if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi

# aliases
zshrc_alias() {
    alias -g F='| fzf'
    alias g='git'
    alias gl='git log --graph --oneline --decorate --all'
    alias gs='git status -sb'
    alias gb='git branch -vv'
    alias rm='rm -i'
    alias mv='mv -i -v'
    alias zmv='noglob zmv -W'
    alias grep='grep --color=auto'
    alias diff='diff --color=auto'
    alias ll='ls -lAF --color=always'
    alias ..='cd ..'
    alias ...='cd ../../'
    alias hist='history'

    # {{{ docker aliases
    # Get latest container ID
    # alias dl="docker ps -l -q"
    # Get container process
    # alias dps="docker ps"
    # Get images
    # alias di="docker images"
    # Get ccontainer IP
    # alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
    # Run deamonized container, e.g., $dkd base /bin/echo hello
    # alias dkd="docker run -d -P"
    # Run interactive container, e.g., $dki base /bin/bash
    # alias dki="docker run -i -t -P"
    # Execute interactive container e.g., $dex base /bin/bash
    # alias dex="docker exec -i -t"
    # Stop and Remove all containers
    # alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

    # {{{ shell mangement aliases
    alias path='echo -e ${PATH//:/\\n}'
    alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
    # }}}

    # alias ghci='stack ghci'
    # alias ghc='stack ghc --'
    # alias runghc='stack runghc --'
}

# less
export LESS='-R'
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'

# man
export MANPAGER='less -R'

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000

# functions
has () {
    type "${1:?too frew arguments}" &>/dev/null
}

reload () {
    local f
    f=(~/.zsh/Completion/*(.))
    unfunction $f:t 2>/dev/null
    autoload -U $f:t
}

is_osx () {
    os_detect
    if [[ $PLATFORM == "osx" ]]; then
        return 0
    else
        return 1
    fi
}

is_linux() {
    os_detect
    if [[ $PLATFORM == "linux" ]];then
        return 0
    else
        return 1
    fi
}

is_bsd() {
    os_detect
    if [[ $PLATFORM == "bsd" ]]; then
        return 0
    else
        return 1
    fi
}

get_os() {
    local os
    for os in osx linux bsd; do
        if is_$os; then
            echo $os
        fi
    done
}

# docker でubuntu-jwm 起動
jwm () {
    docker info &> /dev/null \
        || { echo 'Is the docker daemon running?'; return; }
    local -r display=1
    [[ -e "/tmp/.X11-unix/X${display}" ]] \
        || Xephyr -wr -resizeable ":${display}" &> /dev/null &
        docker run  \
            -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
            -it --rm ubuntu-jwm &> /dev/null
    pkill Xephyr
}

# Xephyr で Xmonad 起動(デバッグ用)
xmdtest () {
    local -r display=1
    Xephyr :1 -ac -br -noreset & DISPLAY=:1.0 xmonad
}


# right prompt
setopt prompt_subst
setopt transient_rprompt
# r_prompt() {
#     RPROMPT=$RPROMPT
#     if [ ! -e ".git" ]; then
#         RPROMPT="[%{$fg[blue]%}%~%{$reset_color%}]"
#         return
#     fi
#     local branch_name st branch_status
#     branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
#     st=`git status 2> /dev/null`
#     if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
#         # commit済み
#         branch_status="%F{green}"
#     elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
#         # git管理されていないファイルがある
#         branch_status="%F{red}?"
#     elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
#         # git add されていないファイルがある
#         branch_status="%F{red}+"
#     elif [[ -n `echo "$st" | grep "^Changes to be commited"` ]]; then
#         # git commit されていないファイルがある
#         branch_status="%F{yellow}!"
#     elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
#         # コンフリクト
#         branch_status="%F{red}!"
#         branch_name="no branch"
#     else
#         branch_status="%F{blue}"
#     fi
#     RPROMPT="${branch_status}($branch_name)%{$reset_color%}[%{$fg[blue]%}%~%{$reset_color%}]"
# }
#
# add-zsh-hook precmd r_prompt

# SPROMPT
SPROMPT="%{$fg[red]%}Did you mean?: %R -> %r [nyae]? %{${reset_color}%}"

zshrc_setopt() {
    setopt auto_cd
    setopt auto_param_keys
    setopt auto_param_slash
    setopt auto_pushd
    setopt pushd_minus
    setopt pushd_ignore_dups
    setopt pushd_to_home
    setopt correct
    setopt correct_all
    setopt no_clobber
    setopt brace_ccl
    setopt print_eight_bit
    setopt sh_word_split
    setopt multios
    setopt auto_remove_slash
    setopt equals
    setopt no_flow_control
    setopt path_dirs
    setopt print_exit_value
    setopt rm_star_wait
    setopt rc_quotes
    setopt notify
    setopt long_list_jobs
    setopt auto_resume
    setopt no_case_glob
    setopt extended_glob
    setopt mark_dirs
    setopt no_prompt_cr
    setopt mail_warning

    # history
    setopt hist_ignore_dups
    setopt hist_ignore_all_dups
    setopt hist_verify
    setopt extended_history
    setopt share_history
    setopt hist_reduce_blanks
    setopt hist_save_no_dups
    setopt hist_no_store
    setopt hist_find_no_dups
    setopt inc_append_history
    setopt append_history
    setopt hist_no_functions
    setopt bang_hist
    setopt hist_ignore_space

    # beep
    setopt no_beep
    setopt no_list_beep
    setopt no_hist_beep
}

zshrc_keybind() {
#    # Vim-like keybind as default
#    bindkey -v
#    # Vim-like escaping jj keybind
#    bindkey -M viins 'jj' vi-cmd-mode

    # Add vim-like keybind to viins mode

    fzf-history-selection() {
        BUFFER=`history -n 1 | tac | awk '!a[$0]++' | fzf`
        CURSOR=$#BUFFER
        zle reset-prompt
    }
    zle -N fzf-history-selection

    fzf-gitbranch-selection() {
        local branches branch
        branches=$(git branch -vv --all | grep -v HEAD) &&
        branch=$(echo "$branches" |
            fzf-tmux -d $((2 + $(wc -l <<< "$branches") )) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    }
    zle -N fzf-gitbranch-selection

    # Ctrl+r history on fzf
    bindkey '^r' fzf-history-selection
    bindkey '^g' fzf-gitbranch-selection
    #bindkey '^f'

}

zshrc_comp() {
    setopt auto_param_slash
    setopt list_types
    setopt auto_menu
    setopt auto_param_keys
    setopt interactive_comments
    setopt magic_equal_subst
    setopt complete_in_word
    setopt always_last_prompt
    setopt globdots

    # Important
    zstyle ':completion:*:default' menu select=2
    # Completion groping
    zstyle ':completion:*:options' description 'yes'
    zstyle ':completion:*:descriptions' format "%F{yellow}Completing %B%d%b%f"
    zstyle ':completion:*' group-name ''
    # Completion misc
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
    zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
    zstyle ':completion:*' use-cache true
    zstyle ':completion:*:*:-subscript-:*'  tag-order indexes parameters
}

## zsh startup
zshrc_startup() {
    echo -e "\n$fg_bold[cyan]This is ZSH $fg_bold[red]${ZSH_VERSION}$fg_bold[cyan] - DISPLAY on $fg_bold[red]$DISPLAY$reset_color\n"
}

# {{{ docker functions
# Stop all cotainters
# dstop() { docker stop $(docker ps -a -q); }
# Remove all containers
# drm() { docker rm $(docker ps -a -q); }
# Remove all images
# dri() { docker rmi $(docker images -q); }
# Dockerfile build, e.g., $dbu
# dbu() { docker build -t=$1 .; }
# Show all alias related docker
# dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }
# Bash into running container
# dbash() { docker exec -it $(docker ps -aqf "name=$1") bash; }

## Main prompt
if zshrc_startup; then
    zshrc_keybind
    zshrc_comp
    zshrc_setopt
    zshrc_alias
    neofetch
fi

PROMPT="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m  %{$fg_no_bold[yellow]%}%1~ %{$reset_color%}> "

## MISC
export EDITOR=vim

# neovim
export XDG_CONFIG_HOME=$HOME/dotfiles

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

# direnv
export PATH="$HOME/.local/bin:$PATH"
eval "$(direnv hook zsh)"
