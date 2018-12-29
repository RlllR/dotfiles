if [ -f $HOME/.bashrc ]; then
	  . $HOME/.bashrc
fi

export PATH=/mingw64/bin:$PATH

# work
export PATH=/home/n-tada/work/jmeter/jmeter/bin:$PATH

PS1='\[\033]0;$MSYSTEM:${PWD//[^[:ascii:]]/?}\007\]' # set window title
PS1="$PS1"'\[\033[32m\]'       # change to green
PS1="$PS1"'\u@\h '             # user@host<space>
PS1="$PS1"'\[\033[33m\]'       # change to brownish yellow
PS1="$PS1"'\w'                 # current working directory


PS1="$PS1"'\[\033[0m\]' # change color
PS1="$PS1"'\n'          # new line
PS1="$PS1"'$\[\e[m\] '  # prompt: alias $

# for go lang
if [ -x "`which go`" ]; then
    export GOROOT=/mingw64/lib/go
    export GOPATH=/mingw64
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
fi

function peco_ls() {
    ls > /tmp/ls.txt
    script -qc "winpty peco /tmp/ls.txt" /tmp/typescript
    local target="$(col -bx < /tmp/typescript | tail -2 | head -1 | sed/OK$// | sed s/^0// )"
    echo "$target"
}

function _pecowrap_exec() {
    eval "$@" > /tmp/cmd.log
    script -e -qc "winpty peco /tmp/cmd.log" /tmp/script.log
}

function _pecowrap_result() {
    local result="$(col -bx < /tmp/script.log | tr -d '\n' | sed 's/.*0m\(.*\)OK.*$/\1/g' | sed 's/OK//g')"
}

function c() {
    _pecowrap_exec "find $1 -maxdepth 1 -type d | sort" || return
    cd $(_pecowrap_result)
}

function v() {
    _pecowrap_exec "find $1 -maxdepth 1 -type f | sort" || return
    vi $(_pecowrap_result)
}
