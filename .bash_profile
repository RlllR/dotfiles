if [ -f $HOME/.bashrc ]; then
	. $HOME/.bashrc
fi

export PATH=/mingw64/bin:$PATH

PS1='\[\033]0;$MSYSTEM:${PWD//[^[:ascii:]]/?}\007\]' # set window title
PS1="$PS1"'\[\033[32m\]'       # change to green
PS1="$PS1"'\u@\h '             # user@host<space>
PS1="$PS1"'\[\033[33m\]'       # change to brownish yellow
PS1="$PS1"'\w'                 # current working directory


PS1="$PS1"'\[\033[0m\]' # change color
PS1="$PS1"'\n'          # new line
PS1="$PS1"'λ '         # prompt: alias λ

