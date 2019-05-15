" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END

" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/.cache/dein')

" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から取得
if &runtimepath !~# '/dein.vim'
	if !isdirectory(s:dein_repo_dir)
		execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
	endif
	execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" 設定開始
if dein#load_state(s:dein_dir)
	call dein#begin(s:dein_dir)

	" プラグインリストを収めたTOMLファイル
	" 予めTOMLファイルを用意
	let g:rc_dir = expand('~/dotfiles/.vim/rc')
	let s:toml   = g:rc_dir . '/dein.toml'
	let s:lazy_toml = g:rc_dir . '/lazy_dein.toml'

	" TOML読み込み、キャッシュ
	call dein#load_toml(s:toml,      {'lazy': 0})
	call dein#load_toml(s:lazy_toml, {'lazy': 1})

    if !has('nvim')
        call dein#add('roxma/nvim-yarp')
        call dein#add('roxma/vim-hug-neovim-rpc')
    endif

    " Colorscheme
    call dein#add('w0ng/vim-hybrid')
    call dein#add('tomasr/molokai')
    " call dein#add('raphamorim/lucario')
    call dein#add('jdkanani/vim-material-theme')
    call dein#add('jacoborus/tender.vim')

	" 設定終了
	call dein#end()
	call dein#save_state()
endif

"" 未インストールがあればインストール
if dein#check_install()
	call dein#install()
endif

"" プラグイン削除
call map(dein#check_clean(), "delete(v:val, 'rf')")
call dein#recache_runtimepath()

filetype plugin indent on
syntax enable

" vimログ出力
"set verbosefile=~/myVimLog
"set verbose=20

" インサートモードからノーマルモードの変更高速化
if !has('gui_running')
	set timeout timeoutlen=1000 ttimeoutlen=50
endif

" キーマッピング
let mapleader="\<Space>"

" php
augroup PHP_SyntaxCheck
  autocmd!
  autocmd FileType php set makeprg=php\ -l\ %
  autocmd BufWritePost *.php silent make | if len(getqflist()) != 1 | copen | else | cclose | endif | redraw!
augroup END

" システムのclipboardにコピー&ペースト
vmap <leader>y "+y
vmap <leader>d "+d
nmap <leader>p "+p
nmap <leader>P "+P
vmap <leader>p "+p
vmap <leader>P "+P

" 基本設定
source ~/dotfiles/.vimrc.basic
" ステータスライン
source ~/dotfiles/.vimrc.statusline
" インデント設定
source ~/dotfiles/.vimrc.indent
" 表示関連
source ~/dotfiles/.vimrc.apperance
" 補完関連
source ~/dotfiles/.vimrc.completion
" Tags関連
source ~/dotfiles/.vimrc.tags
" 検索関連
source ~/dotfiles/.vimrc.search
" 移動関連
source ~/dotfiles/.vimrc.moving
" ウィンドウ関連
source ~/dotfiles/.vimrc.window
" Color関連
" source ~/dotfiles/.vimrc.colors
" 編集関連
source ~/dotfiles/.vimrc.editing
" エンコーディング関連
" source ~/dotfiles/.vimrc.encoding
" その他
" source ~/dotfiles/.vimrc.misc
" プラグイン依存
source ~/dotfiles/.vimrc.plugins_setting
"
" Vimでgitのログをきれいに表示する - derisの日記
" http://deris.hatenablog.jp/entry/2013/05/10/003430
" source ~/dotfiles/.vimrc.gitlogviewer
