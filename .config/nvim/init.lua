-- vim.deprecate = function() end ---@diagnostic disable-line: duplicate-set-field
require('options')
require('keymaps')
require('autocmds')

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
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  defaults = { lazy = true },
  change_detection = { notify = false },
})

require('snippets')
