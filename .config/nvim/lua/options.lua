local indent = 2
local scrolloff = 3

vim.opt.autoindent = true         -- good auto indent
vim.opt.breakindent = true
vim.opt.clipboard = 'unnamedplus' -- enable universal clipboard
vim.opt.cursorline = true         -- highlight current line
vim.opt.expandtab = true          -- expand tabs into spaces
vim.opt.hidden = true             -- handle multiple buffers better
vim.opt.ignorecase = true
vim.opt.laststatus = 3            -- global statusline
vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '·' }
vim.opt.mouse = 'a'               -- enable mouse
vim.opt.number = true             -- show line numbers
vim.opt.pumheight = 6             -- commandline completion height
vim.opt.relativenumber = true     -- line numbers relative to cursor
vim.opt.scrolloff = scrolloff     -- always show at least x lines above/below cursor
vim.opt.sidescrolloff = scrolloff -- always show at least x lines left/right cursor
vim.opt.shiftround = true         -- round indent
vim.opt.shiftwidth = indent       -- size of indent
vim.opt.showmode = false          -- Hide redundant mode
vim.opt.shortmess:append('WcC')   -- shorter messages
vim.opt.signcolumn = 'yes'        -- always show signcolumn
vim.opt.smartcase = true          -- only case sensitive when alternate case is used
vim.opt.smartindent = true
vim.opt.smoothscroll = true
vim.opt.splitbelow = true              -- split new window below current
vim.opt.splitright = true              -- split new window right of current
vim.opt.statuscolumn = '%=%{&nu?(&rnu && v:relnum?v:relnum:v:lnum):""}%=%s'
vim.opt.swapfile = false               -- disable swapfiles
vim.opt.tabstop = indent               -- size of tab
vim.opt.termguicolors = true           -- support for true colour
vim.opt.timeoutlen = 300
vim.opt.undofile = true                -- unable undo
vim.opt.updatetime = 250               -- faster update time
vim.opt.visualbell = true              -- disable beeping
vim.opt.wildmode = 'longest:full,full' -- commandline completion settings
vim.opt.completeopt = 'menu,menuone,noselect'

-- disable netrw for better nvim-tree support
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- disable barbar auto setup
vim.g.barbar_auto_setup = false

-- ufo support
vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.fillchars = { eob = ' ' }
