# vim:ft=zplug

ZPLUG_SUDO_PASSWORD=
#ZPLUG_PROTOCOL=ssh
ZPLUG_PROTOCOL=https

zplug "zplug/zplug", hook-build:'zplug --self-manage'

zplug "~/.zsh", from:local, use:"<->_*.zsh"

zplug "b4b4r07/enhancd", use:init.sh
if zplug check "b4b4r07/enhancd"; then
    export ENHANCD_FILTER="fzf --height 50% --reverse --ansi"
    export ENHANCD_DOT_SHOW_FULLPATH=1
fi

#zplug "mafredri/zsh-async", from:github, use:"aync.zsh"
#zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

zplug "b4b4r07/zsh-vimode-visual", use:"*.zsh", defer:3
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
zplug "Tarrasch/zsh-functional"
zplug "willghatch/zsh-hooks"
zplug "unixorn/warhol.plugin.zsh"
zplug "mollifier/zload"

#zplug "GeneralD/zsh-aliases-colorls"
#zplug "GeneralD/zsh-completion-gibo"
#zplug "GeneralD/zsh-without-etcdir"

# from oh-my-zsh
#zplug "plugins/colored-man-pages", from:oh-my-zsh
#zplug "plugins/colorize", from:oh-my-zsh, if:"which pygmentize 1>/dev/null"
#zplug "plugins/command-not-found", from:oh-my-zsh
#zplug "plugins/composer", from:oh-my-zsh, if:"which composer 1>/dev/null"
#zplug "plugins/docker", from:oh-my-zsh, if:"which docker 1>/dev/null"
#zplug "plugins/emacs", from:oh-my-zsh, if:"which emacs 1>/dev/null"
#zplug "plugins/extract", from:oh-my-zsh, hook-load:"alias -s {tar,gz,tgz,bz2,tbz2,xz,txz,zma,tlz,lzma,Z,zip,war,jar,rar,7z,deb}=extract"
#zplug "plugins/gem", from:oh-my-zsh, if:"which gem 1>/dev/null"
#zplug "plugins/git", from:oh-my-zsh, if:"which git 1>/dev/null"
#zplug "plugins/github", from:oh-my-zsh, if:"which hub 1>/dev/null"
#zplug "plugins/gitignore", from:oh-my-zsh, if:"which git 1>/dev/null"
#zplug "plugins/gnu-utils", from:oh-my-zsh
#zplug "plugins/go", from:oh-my-zsh, if:"which got 1>/dev/null"
#zplug "plugins/gpg-agent", from:oh-my-zsh, if:"which gpg-agent 1>/dev/null"
#zplug "plugins/heroku", from:oh-my-zsh, if:"which heroku 1>/dev/null"
#zplug "plugins/httpie", from:oh-my-zsh, if:"which http 1>/dev/null"
#zplug "plugins/man", from:oh-my-zsh
#zplug "plugins/pip", from:oh-my-zsh, if:"which pip 1>/dev/null"
#zplug "plugins/pod", from:oh-my-zsh, if:"which pod 1>/dev/null"
#zplug "plugins/wp-cli", from:oh-my-zsh
#zplug "plugins/z", from:oh-my-zsh

# from zaw
zplug "zsh-users/zaw"
zplug "GeneralD/zaw-src-nerd-icon", on:"zsh-users/zaw", defer:2
zplug "GeneralD/zaw-src-directory", on:"zsh-users/zaw", defer:2
zplug "GeneralD/zaw-src-bitbucket", on:"zsh-users/zaw", defer:2
zplug "GeneralD/zaw-src-github", on:"zsh-users/zaw", defer:2
zplug "GeneralD/zaw-src-package-managers", on:"zsh-users/zaw", defer:2
zplug "GeneralD/zaw-src-unity-launcher", on:"zsh-users/zaw", on:"Tarrasch/zsh-functional", on:"sttz/install-unity", defer:2
zplug "sttz/install-unity", \
    as:command, \
    use:'(*).py', \
    rename-to:'$1', \
    if:"[[ $OSTYPE == *darwin* ]], \
    hook-build:"pyenv versions -base 2/dev/null | gsort --version-sort --reverse | egrep '2.[0-9]+.[0-9]+' | head -n 1 > $ZPLUG_REPOS/sttz/install-unity/.python-version"

zplug "glidenote/hub-zsh-completion"
zplug "Valodim/zsh-curl-completion"

zplug "b4b4r07/epoch-cat", \
    as:command, \
    hook-build:'go get -d && go build'

zplug "stedolan/jq", \
    as:command, \
    from:gh-r, \
    rename-to, jq

zplug "junegunn/fzf-bin", \
    as:command, \
    rename-to:"fzf", \
    frozen:1

zplug "monochromegane/the_platinum_searcher", \
    as:command, \
    from:gh-r, \
    rename-to:"pt", \
    frozen:1

zplug "peco/peco", \
    as:command, \
    from:gh-r, \
    frozen:1

zplug "motemen/ghq", \
    as:command, \
    from:gh-r, \
    rename-to:ghq

zplug "fujiwara/nssh", \
    as:command, \
    from:gh-r, \
    rename-to:"nssh", \
    frozen:1

zplug "philovivero/distribution", \
    as:command, \
    use:distribution, \
    if:'(( $+commands[perl] ))'

zplug "jhawthorn/fzy", \
    as:command, \
    hook-build:"make && sudo make install"
