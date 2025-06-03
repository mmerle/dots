-- when using fish, set shell to bash
if vim.env.SHELL:match('fish$') then vim.opt.shell = '/opt/homebrew/bin/bash' end

-- Use proper syntax highlighting in code blocks
local fences = {
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
vim.g.markdown_fenced_languages = fences
vim.g.markdown_recommended_style = 0

-- stop 'o' continuing comments
vim.api.nvim_create_autocmd('BufEnter', {
  command = 'setlocal formatoptions-=o',
})

-- highlight copied text
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 }) end,
})

-- diagnostic symbols
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN] = '●',
      [vim.diagnostic.severity.INFO] = '●',
      [vim.diagnostic.severity.HINT] = '●',
    },
  },
  virtual_text = {
    prefix = '*',
  },
})

-- balance splits on window resize
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Balance windows',
  command = 'tabdo wincmd =',
})

-- switch between relative and absolute line numbers based on mode
local number_toggle = vim.api.nvim_create_augroup('number_toggle', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  callback = function()
    if vim.opt.number:get() == true then vim.opt.relativenumber = true end
  end,
  group = number_toggle,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  callback = function()
    if vim.opt.number:get() == true then vim.opt.relativenumber = false end
  end,
  group = number_toggle,
})


-- cursorline only in active window
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'InsertLeave' }, {
  callback = function() vim.opt_local.cursorline = true end,
})
vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave', 'InsertEnter' }, {
  callback = function() vim.opt_local.cursorline = false end,
})

-- additional filetypes
vim.filetype.add({
  extension = {
    mdx = 'markdown',
    mdoc = 'markdown',
    js = 'javascriptreact',
    conf = 'conf',
  },
  pattern = {
    ['.*%.env.*'] = 'sh',
    ['ignore$'] = 'conf',
  },
})

-- quickfix quickview
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set('n', 'j', '<cmd>cn | wincmd p<CR>', opts)
    vim.keymap.set('n', 'k', '<cmd>cN | wincmd p<CR>', opts)
  end,
})
