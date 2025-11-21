-- vim.opt.cmdheight = 0

-- temp: surpress vscode-neovim output messages
if vim.g.vscode then
  vim.opt.cmdheight = 999
end

vim.opt.mouse            = 'a' -- enable mouse
vim.opt.diffopt          = 'internal,filler,closeoff,linematch:60'

-- indentation
vim.opt.expandtab        = true -- expand tabs into spaces
vim.opt.shiftwidth       = 2    -- size of indent
vim.opt.shiftround       = true -- round indent
vim.opt.tabstop          = 2    -- size of tab
vim.opt.softtabstop      = 2
vim.opt.breakindent      = true

-- search
vim.opt.ignorecase       = true
vim.opt.smartcase        = true -- only case sensitive when alternate case is used

-- disable netrw
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- spelling
vim.o.spell              = false
vim.o.spelloptions       = 'camel' -- camelCase word parts as separate words
-- vim.o.spelllang = 'en,fr'

-- editing
vim.o.iskeyword          = '@,48-57,_,192-255,-' -- enables dash as part of `word` textobject

-- ui
vim.opt.number           = true  -- show line numbers
vim.opt.relativenumber   = true  -- line numbers relative to cursor
vim.opt.signcolumn       = 'yes' -- always show signcolumn
vim.opt.statuscolumn     = '%=%{&nu?(&rnu && v:relnum?v:relnum:v:lnum):""}%=%s'
vim.opt.showmode         = false -- hide redundant mode

vim.opt.linebreak        = true
vim.opt.showbreak        = '↪'

vim.opt.winborder        = 'single'

vim.opt.splitbelow       = true -- split new window below current
vim.opt.splitright       = true -- split new window right of current
vim.opt.splitkeep        = 'screen'

vim.opt.pumheight        = 6 -- commandline completion height
vim.opt.completeopt      = 'menu,menuone,noselect'

vim.opt.smoothscroll     = true
vim.opt.scrolloff        = 4    -- always show at least x lines above/below cursor
vim.opt.sidescrolloff    = 4    -- always show at least x lines left/right cursor

vim.opt.cursorline       = true -- highlight current line
vim.opt.cursorlineopt    = { 'both' }
vim.opt.laststatus       = 3    -- global statusline

-- chars
vim.opt.list             = true
vim.opt.listchars        = { tab = '  ', trail = '·' }
vim.opt.fillchars        = {
  eob = ' ',  -- suppress ~
  fold = ' ', -- hide trailing folding characters
  foldopen = '',
  foldclose = '',
}

-- folds
vim.opt.foldcolumn       = '0'
vim.opt.foldenable       = true
vim.opt.foldlevel        = 99
vim.opt.foldlevelstart   = 99
vim.opt.foldmethod       = 'expr'
vim.opt.foldexpr         = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext         = ''

-- ux
vim.opt.confirm          = true
vim.opt.updatetime       = 250 -- faster update time

-- messages
vim.opt.shortmess:append {
  W = true, -- do not print "written" when editing
  a = true, -- use abbreviations in messages ([RO] intead of [readonly])
  c = true, -- do not show ins-completion-menu messages (match 1 of 2)
  C = true,
  F = true, -- do not print file name when opening a file
  s = true, -- do not show "Search hit BOTTOM" message
  o = true,
  O = true,
}

-- clipboard
vim.opt.clipboard = 'unnamedplus' -- enable universal clipboard

-- undo and history
vim.opt.undofile = true -- enable undo
vim.opt.swapfile = false

-- startup
vim.opt.shada = "'100,<50,s10,:1000,/100,@100,h" -- limit ShaDa file
vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end

-- diagnostics
vim.diagnostic.config({
  signs = {
    priority = 9999,
    severity = { min = 'WARN', max = 'ERROR' },
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN] = '●',
      [vim.diagnostic.severity.INFO] = '●',
      [vim.diagnostic.severity.HINT] = '●',
    },
  },
  -- virtual_text = {
  --   prefix = '*',
  -- },
  virtual_text = false,
  update_in_insert = false, -- don't update diagnostics when typing
})
