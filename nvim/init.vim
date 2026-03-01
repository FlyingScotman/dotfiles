" ============================================================
"  PLUGIN MANAGER (vim-plug)
" ============================================================
call plug#begin()

Plug 'tpope/vim-surround'           " surround motions
Plug 'tpope/vim-commentary'         " commenting
Plug 'tpope/vim-repeat'             " makes . work with plugins
Plug 'wellle/targets.vim'           " extra text objects
Plug 'justinmk/vim-sneak'          " 2-char jump motion
Plug 'vim-scripts/ReplaceWithRegister' " replace with register

call plug#end()


" ============================================================
"  GENERAL SETTINGS
" ============================================================
set number                          " show absolute line number on current line
set relativenumber                  " show relative numbers on all other lines
set ignorecase                      " case-insensitive search...
set smartcase                       " ...unless you type a capital letter
set clipboard=unnamedplus           " yank/paste uses system clipboard automatically
set scrolloff=8                     " keep 8 lines visible above/below cursor
set incsearch                       " highlight matches as you type search

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

" ============================================================
"  KEY MAPPINGS
" ============================================================
let mapleader = " "                 " spacebar as leader key (common convention)

" jk to exit insert mode - much faster than reaching for Escape
inoremap jk <Esc>

" move through wrapped lines naturally with j/k
" nnoremap j gj
" nnoremap k gk
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'


" keep cursor centered when jumping through search results
nnoremap n nzz
nnoremap N Nzz

" Y should yank to end of line (consistent with D and C behavior)
nnoremap Y y$

" easier window navigation - Ctrl+hjkl to move between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" clear search highlight with Escape in normal mode
nnoremap <Esc> :noh<CR>

if exists('g:vscode')
    " VSCode extension
else
    " ordinary Neovim
endif
