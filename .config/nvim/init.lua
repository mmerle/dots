-- main config table to pass data between scripts
_G.Config = {}

require('options')

vim.pack.add({ 'https://github.com/nvim-mini/mini.misc' })

-- loading helpers
local misc = require('mini.misc')
Config.now = function(f) misc.safely('now', f) end
Config.later = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later

-- define custom autocommand group
local group = vim.api.nvim_create_augroup('config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = group, pattern = pattern, callback = callback, desc = desc }
  return vim.api.nvim_create_autocmd(event, opts)
end

-- define custom filetype helper
Config.on_filetype = function(filetype, callback, desc)
  return Config.new_autocmd('FileType', filetype, callback, desc)
end

-- define custom `vim.pack.add()` hook helper
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  if vim.fn.has('nvim-0.12') == 0 then return end
  local f = function(event)
    local name, kind = event.data.spec.name, event.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not event.data.active then vim.cmd.packadd(plugin_name) end
    callback()
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end

vim.cmd.colorscheme('flora')

require('keymaps')
require('autocmds')
require('statusline')
require('plugins')
