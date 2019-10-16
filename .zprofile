echo '-------------------------------'
echo 'zshprofile'
echo '-------------------------------'

export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

# Go
export GO_VERSION=1.12.5
export GOROOT=$HOME/.anyenv/envs/goevn/versions/$GO_VERSION
export GOPATH=$HOME/go/$GO_VERSION
export PATH=$HOME/.anyenv/envs/goevn/shims/bin:$PATH
export PATH=$GOROOT/bin:$PATH
export PATH=$GOPATH/bin:$PATH

# export EDITOR=`which vim`
# eval "$(direnv hook bash)"

export PATH=$HOME/.local/bin:$PATH

# direnv
export PATH="$HOME/.local/bin:$PATH"
eval "$(direnv hook zsh)"

# fasd
# eval "$(fasd --init auto)"

PATH="/home/n-tada/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/n-tada/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/n-tada/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/n-tada/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/n-tada/perl5"; export PERL_MM_OPT;

# rust
export PATH="$HOME/.cargo/bin:$PATH"
