"plugins
call plug#begin('~/.config/nvim/plugged')
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ctrlpvim/ctrlp.vim'
call plug#end()

"import lua config
:lua require('init')

set encoding=UTF-8 nobackup nowritebackup nocursorline splitbelow splitright
set wildmode=longest:full,full
set nu smarttab cindent tabstop=2 shiftwidth=2 expandtab

"keybindings
let mapleader=" "
nnoremap <leader>s :source ~/.config/nvim/init.vim<CR>
nnoremap <leader><ENTER> :Goyo<CR>

"color settings
:colorscheme flora
let g:limelight_conceal_ctermfg = 240
let g:limelight_conceal_guifg = '#777777'

"Goyo settings
function! s:goyo_enter()
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
endfunction

function! s:goyo_leave()
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
