vim.cmd.colorscheme('blank')

vim.opt.clipboard = 'unnamedplus' -- enable universal clipboard
vim.opt.updatetime = 250

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.laststatus = 3
vim.opt.statusline = ' %f %M %= [%{expand(&filetype)}] %l:%c '
vim.opt.shortmess:append('c')

vim.opt.mouse = 'a' -- enable mouse
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.undofile = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 3

vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.cindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wildmode = 'longest:full,full'
vim.opt.pumheight = 6
vim.opt.completeopt = 'menu,menuone,noinsert'

vim.opt.title = true
vim.opt.titlestring = '%t — nvim'

vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '·' }

vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- vim.opt.lazyredraw = true

-- Stop 'o' continuing comments
vim.api.nvim_create_autocmd('BufEnter', {
  command = 'setlocal formatoptions-=o',
})

-- Highlight copied text
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Use circles for diagnostics
local signs = { 'Error', 'Warn', 'Hint', 'Info' }
for _, type in pairs(signs) do
  local hl = string.format('DiagnosticSign%s', type)
  vim.fn.sign_define(hl, { text = '●', texthl = hl, numhl = hl })
end
