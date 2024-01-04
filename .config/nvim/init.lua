require('options') -- lua/options.lua
require('keymaps') -- lua/keymaps.lua

-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

local not_vscode = not vim.g.vscode

require('lazy').setup('plugins', {
  defaults = { lazy = true },
  change_detection = { notify = false },
})
