set nobackup
set noswapfile

syntax on
" ビジュアルを水色にする
autocmd ColorScheme * highlight Visual ctermfg=99 guifg=99
colorscheme molokai
set guifont=RictyForPowerline-Regular:h16


set t_Co=256
set number
set ruler
"set autoindent
set expandtab
set tabstop=2
set fileencodings=iso-2022-jp,euc-jp,utf-8,sjis
set fileformats=unix,dos,mac
set noautoindent
set browsedir=~/Document/

set lines=60
set columns=150

NeoBundle 'nathanaelkane/vim-indent-guides'

