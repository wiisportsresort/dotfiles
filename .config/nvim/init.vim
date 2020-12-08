let mapleader = " "

call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-sensible'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
" Plug 'mboughaba/i3config.vim'
Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'ap/vim-css-color'
Plug 'dag/vim-fish'
call plug#end()

" gamer
nnoremap c "_c
set nocompatible
syntax on
filetype plugin on
set encoding=utf-8
set number relativenumber
set wildmode=longest,list,full
set splitright splitbelow

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" nerdtre
map <leader>n :NERDTreeToggle<CR>
if has('nvim')
  let NERDTreeBookmarksFile = stdpath('data') . '/NERDTreeBookmarks'
else
  let NERDTreeBookmarksFile = '~/.vim' . '/NERDTreeBookmarks'
endif

" use sudo when needed
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
" cmap w!! w !sudo tee % >/dev/null

" powerline
let g:airline_powerline_fonts = 0

" tabulation
set expandtab
set tabstop=4
set shiftwidth=2
