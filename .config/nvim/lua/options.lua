local profile = require('profile').get()

vim.g.mapleader = ' '

for _, plugin in ipairs({ 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' }) do
  vim.g['loaded_' .. plugin] = 1
end

if vim.env.SHELL:match('fish$') then vim.opt.shell = '/opt/homebrew/bin/bash' end
if vim.g.vscode then vim.opt.cmdheight = 999 end

vim.opt.mouse = 'a'
vim.opt.diffopt = 'internal,filler,closeoff,linematch:60'

vim.opt.expandtab = true
vim.opt.shiftwidth = profile.indent
vim.opt.shiftround = true
vim.opt.tabstop = profile.indent
vim.opt.softtabstop = profile.indent
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.spell = false
vim.opt.spelloptions = 'camel'            -- treat camelCase word parts as separate words
vim.opt.iskeyword = '@,48-57,_,192-255,-' -- treat dash as `word` textobject part

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.statuscolumn = '%=%{&nu?(&rnu && v:relnum?v:relnum:v:lnum):""}%=%s'
vim.opt.colorcolumn = '+1'
vim.opt.showmode = false
vim.opt.linebreak = true
vim.opt.showbreak = '↪'
vim.opt.winborder = 'single'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = 'screen'
vim.opt.pumheight = 6
vim.opt.completeopt = 'menu,menuone,noselect' -- completion behavior
vim.opt.smoothscroll = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4
vim.opt.cursorline = true
vim.opt.cursorlineopt = { 'both' }
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '·' }
vim.opt.fillchars = {
  eob = ' ',
  fold = ' ',
  foldopen = '',
  foldclose = '',
}

vim.opt.foldcolumn = '0'
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = 'manual'
vim.opt.foldexpr = '0'
vim.opt.foldtext = ''

vim.opt.confirm = true
vim.opt.updatetime = 250
vim.opt.shortmess:append({ W = true, a = true, c = true, C = true, F = true, s = true, o = true, O = true })
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.shada = "'100,<50,s10,:1000,/100,@100,h"

vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end

vim.diagnostic.config({
  -- show signs on top of any other sign, but only for warning and errors
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
  virtual_text = false,
  update_in_insert = false, -- don't update diagnostics while typing
})

vim.g.markdown_fenced_languages = {
  'console=sh',
  'javascript',
  'js=javascript',
  'json',
  'lua',
  'python',
  'sh',
  'shell=sh',
  'ts=typescript',
  'typescript',
}
vim.g.markdown_recommended_style = 0

vim.filetype.add({
  extension = {
    mdx = 'markdown',
    mdoc = 'markdown',
    conf = 'conf',
  },
  pattern = {
    ['.*%.env.*'] = 'sh',
    ['ignore$'] = 'conf',
  },
})
