" Basic settings
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent

set number
set encoding=utf-8
set ttyfast
set showcmd
set hidden
set ruler
set cursorline

" Search features
set ignorecase
set smartcase
set gdefault

" Enable other features
syntax on
filetype plugin indent on

set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

" Enable display options
colorscheme sourcerer
set hlsearch

"Activate all highlighting and gui changes
highlight Normal ctermfg=grey ctermbg=black "This has to come after syntax on

nnoremap <Enter> o<ESC>
nnoremap <S-k> <PageUp><ESC>
nnoremap <S-j> <PageDown><ESC>
