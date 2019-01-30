export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

# Go
export GO_VERSION=1.11.1
export GOROOT=$HOME/.anyenv/envs/goevn/versions/$GO_VERSION
export GOPATH=$HOME/dev/go
export PATH=$HOME/.anyenv/envs/goevn/shims/bin:$PATH
export PATH=$GOROOT/bin:$PATH
export PATH=$GOPATH/bin:$PATH

export EDITOR=`which vim`
eval "$(direnv hook bash)"

export PATH=$HOME/.local/bin:$PATH

# direnv
export PATH="$HOME/.local/bin:$PATH"
eval "$(direnv hook zsh)"

# fasd
# eval "$(fasd --init auto)"
