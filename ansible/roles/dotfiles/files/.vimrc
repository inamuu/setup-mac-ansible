if has('vim_starting')
   set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Filer
NeoBundle 'Shougo/vimfiler'

" Modify status line
NeoBundle 'itchyny/lightline.vim'

" git
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'kmnk/vim-unite-giti'

" indent
NeoBundle 'nathanaelkane/vim-indent-guides'

" vim-terraform
NeoBundle 'hashivim/vim-terraform.git'

" vim preview
NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'

" check syntax for puppet
NeoBundleLazy 'puppetlabs/puppet-syntax-vim', {
  \ 'autoload': {'filetypes': ['puppet']}}

" memo
NeoBundle 'glidenote/memolist.vim'

call neobundle#end()

filetype plugin indent on

NeoBundleCheck

syntax on
" 以下のコマンドは :colorscheme の前に設定します
" コメントを濃い緑にする
autocmd ColorScheme * highlight Comment ctermfg=31 guifg=#008800
" ...
colorscheme molokai

set t_Co=256
set laststatus=2
set number
set ruler
set noautoindent
set expandtab
set tabstop=2
set shiftwidth=2
"set fileencodings=iso-2022-jp,euc-jp,utf-8,sjis
set fileformats=unix,dos,mac
autocmd FileType * setlocal formatoptions-=r
autocmd FileType * setlocal formatoptions-=o
set nobackup
set noswapfile
set noundofile
set browsedir=~/Documents

"VimFiler
let g:vimfiler_as_default_explorer = 1

autocmd FileType vimfiler nmap <buffer> <CR> <Plug>(vimfiler_expand_or_edit)
"autocmd VimEnter * VimFiler -split -simple -winwidth=30 -no-quit
command Vf VimFiler -split -simple -winwidth=30 -no-quit

let g:vimfiler_safe_mode_by_default=0

let g:netrw_liststyle = 3
let g:netrw_altv = 1
let g:netrw_alto = 1
let g:netrw_winsize = 80

"Indent
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_start_level=2
let g:indent_guides_auto_colors=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#262626 ctermbg=gray
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#3c3c3c ctermbg=darkgray
let g:indent_guides_color_change_percent = 30
let g:indent_guides_guide_size = 0

"puppet syntax check
let g:puppet_align_hashes = 1

"ruby syntax check
autocmd BufNewFile,BufRead Gemfile set filetype=ruby
autocmd BufNewFile,BufRead Vagrantfile set filetype=ruby
autocmd BufNewFile,BufRead Berksfile set filetype=ruby

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"⭤":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
      \ },
      \ 'separator': { 'left': "\u2b80", 'right': "\u2b82" },
      \ 'subseparator': {  'left': "\u2b81", 'right': "\u2b83" }
      \ }

"bug fix
set nocompatible
set whichwrap=b,s,h,l,<,>,[,]
set backspace=indent,eol,start

"vim-terraform
let g:terraform_align=1
let g:terraform_fmt_on_save = 1

"Previm
au BufRead,BufNewFile *.md set filetype=markdown
nnoremap <silent> <C-p> :PrevimOpen<CR> " Ctrl-pでプレビュー

"memolist
map <Leader>mn  :MemoNew<CR>
map <Leader>ml  :MemoList<CR>
map <Leader>mg  :MemoGrep<CR>
let g:memolist_path = "~/memo"
