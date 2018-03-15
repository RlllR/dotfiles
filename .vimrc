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

	" 設定終了
	call dein#end()
	call dein#save_state()
endif

" 未インストールがあればインストール
if dein#check_install()
	call dein#install()
endif



set mouse=
set scrolloff=3

" tab
set expandtab       " タブの代わりに空白
set tabstop=4       " タブ幅
set shiftwidth=4    " 自動インデントでずれる幅
set softtabstop=2   " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く
set autoindent      " 改行時に前の行のインデントを継続
set smartindent     " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する

" search
set ignorecase    " 大文字小文字無視
set smartcase     " 小文字入力のときのみ大文字小文字を無視
set incsearch     " インクリメンタルサーチ
set hlsearch      " 検索結果をはハイライト

" autocmd
autocmd BufWritePre * :%s/\s\+$//ge " 行末の余分なスペースを取り除く
" autocmd ColorScheme
autocmd ColorScheme * highlight Normal ctermbg=none
autocmd ColorScheme * highlight LineNr ctermbg=none
autocmd ColorScheme * highlight NonText ctermbg=none
autocmd ColorScheme * highlight Folded ctermbg=none
autocmd ColorScheme * highlight EndOfBuffer ctermbg=none

" visual
syntax on
colorscheme lucario
set cursorline      " 現在の行をハイライト
hi clear CursoLine  " 行番号のみハイライト
set colorcolumn=80
set number          " 行番号
set showmatch       " カーソル：括弧にカーソルを合わせたとき、対応した括弧を表示する
set matchtime=1     " カーソル：カーソルが飛ぶ時間を0.1秒で
set whichwrap=b,s,h,l,<,>,[,]
set ttyfast         " ターミナル：ターミナル接続を高速にする
set t_Co=256        " ターミナル：ターミナルで256色表示
set nowrap          " テキスト折り返しなし
set laststatus=2    " 下部ステータスラインを常に表示

" SpellCheck
set spell
set spelllang=en,cjk " 日本語を除外

" other
set backspace=indent,eol,start
set pumheight=10 " 変換候補で一度に表示される数
set encoding=utf-8 " 文字コード
set fileencoding=utf-8
set vb t_vb= " ビープ消音

" インサートモードからノーマルモードの変更高速化
if !has('gui_running')
	set timeout timeoutlen=1000 ttimeoutlen=50
endif


" キーマッピング
let mapleader="<\Space>"

nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

nnoremap <C-n> gt
nnoremap <C-p> gT

inoremap jj <Esc>

nnoremap Y y$

nnoremap ; :

nnoremap <silent> <ESC><ESC> :nohlsearch<CR> " ESCキー連打でハイライトを消す


" php
augroup PHP_SyntaxCheck
  autocmd!
  autocmd FileType php set makeprg=php\ -l\ %
  autocmd BufWritePost *.php silent make | if len(getqflist()) != 1 | copne | else | cclose | endif | redraw!
augroup END
