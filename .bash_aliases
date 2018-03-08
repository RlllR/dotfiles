# Interactive operation...
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort
alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour

# Some shortcuts for different directory listings
alias ll='ls -lAF --color=tty'                # classify files in colour
alias ls='ls -hF --color=tty'                 # classify files in colour
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias l='ls -CF'                              #

# move
alias ..='cd ..'
alias ...='cd ../..'

# reload
alias relogin='exec $SHELL -l'
alias re=relogin

# git
alias g='git'
alias -g B='`git branch -a | peco --prompt "GIT BRANCH>" | head -n 1 |sed -e "sed/^\*/s*//g"`'
alias -g H='`curl -sL https://api.github.com/users/USER_NAME/repos | jq -r ".[].full_name" | peco --prompt "GITHUB REPOS>" | head -n 1`'
alias -g LR='`git branch -a | peco --query "remotes/ " --prompt "GIT REMOTE BRANCH>" | head -n 1 | sed "s/^\*\s*//" | sed "s/remotes\/[^\/]*\/(\S*\)/\1 \0/"`'

