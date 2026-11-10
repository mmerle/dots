-- Run: nvim --headless -u NONE -i NONE -l .config/rex/extensions/navigator/smoke.lua
local root = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))
local ctx = { session_id = 'session:test', block_id = 'block:shell' }
local window = { window_id = 'window:test', focused_block_id = ctx.block_id }
local actions, bindings, writes = {}, {}, {}
local processes = {
  ['block:shell'] = { foreground = { name = 'fish' } },
  ['block:editor'] = { foreground = { name = 'nvim' } },
}
local moves = 0
_G.rex = {
  action = function(action) actions[action.name] = action.run end,
  bind = function(key, callback) bindings[key] = callback end,
  block = { call = function(_, method, args)
    if method == 'process' then return processes[args.block_id] end
    assert(method == 'write')
    writes[#writes + 1] = args.data
    return {}
  end },
  session = {
    view = function() return { active_window_id = window.window_id, windows = { window } } end,
    focus_direction = function(args)
      assert(args.wrap == false)
      moves = moves + 1
      window.focused_block_id = 'block:editor'
      return {}
    end,
  },
}
dofile(root .. '/init.lua').setup()
assert(bindings['ctrl+l'](ctx) == true)
assert(moves == 1 and writes[1] == '\27[1;8C')
actions.navigator_focus(ctx, { direction = 'right' })
assert(moves == 1, 'stale requests must not move the destination')
window.focused_block_id, window.zoomed_block_id = ctx.block_id, ctx.block_id
actions.navigator_focus(ctx, { direction = 'right' })
assert(moves == 1, 'navigation must preserve zoom')
window.zoomed_block_id = nil
processes[ctx.block_id] = { foreground = { name = 'sh' }, ancestors = { { name = 'nvim' } } }
assert(bindings['ctrl+l'](ctx) == false, 'Neovim ancestors must retain their keys')
processes[ctx.block_id] = nil
assert(bindings['ctrl+l'](ctx) == false, 'unknown processes must retain their keys')

for _, process in ipairs({
  { foreground = { name = 'pi' } },
  { foreground = { name = 'pi-coding-agent' } },
  { foreground = { name = 'node', argv0 = 'pi' } },
  { foreground = { name = 'node', script = '/npm/@earendil-works/pi-coding-agent/dist/cli.js' } },
  { foreground = { name = 'child' }, ancestors = { { name = 'node', argv0 = 'pi' } } },
}) do
  processes[ctx.block_id] = process
  assert(bindings['ctrl+j'](ctx) == false and bindings['ctrl+k'](ctx) == false, 'Pi must retain Ctrl-j/k')
end
assert(moves == 1)
processes['block:editor'] = { foreground = { name = 'node', argv0 = 'pi' } }
for _, key in ipairs({ 'ctrl+h', 'ctrl+l' }) do
  window.focused_block_id = ctx.block_id
  assert(bindings[key](ctx) == true, 'Pi must retain horizontal Rex navigation')
end
assert(#writes == 1, 'Neovim entry signals must never be sent to Pi')
window.focused_block_id = ctx.block_id
processes[ctx.block_id] = { foreground = { name = 'node', argv0 = 'node' } }
assert(bindings['ctrl+j'](ctx) == true, 'unrelated Node programs must not be mistaken for Pi')

vim.env.REX_SESSION, vim.env.REX_BLOCK = ctx.session_id, ctx.block_id
vim.opt.runtimepath:prepend('.config/nvim')
local navigator = require('rex-navigator')
assert(not package.loaded['Navigator.mux.vi'], 'Rex must not depend on Navigator.nvim')
assert(vim.fn.maparg('<C-M-S-Right>', 'n') == '', 'requiring the module must not install mappings')
navigator.setup()
local saved_system, saved_notify = vim.system, vim.notify
local notices, launches, complete = 0, 0, nil
vim.notify = function() notices = notices + 1 end
vim.system = function() error('missing Rex executable') end
navigator.navigate('l')
assert(notices == 1)
vim.system = function(argv, _, callback)
  assert(argv[2] == '--autostart=false' and argv[10] == 'navigator_focus')
  launches, complete = launches + 1, callback
end
navigator.navigate('l')
navigator.navigate('h')
assert(launches == 1, 'failed launches must recover; pending requests must not overlap')
complete({ code = 0 })
vim.wait(10, function() return false end)
navigator.navigate('h')
assert(launches == 2)
complete({ code = 0 })
vim.wait(10, function() return false end)

vim.cmd.vsplit()
vim.cmd.wincmd('l')
local right = vim.api.nvim_get_current_win()
navigator.navigate('h')
assert(vim.api.nvim_get_current_win() ~= right and launches == 2, 'internal moves must not call Rex')
navigator.navigate('l')
assert(vim.api.nvim_get_current_win() == right and launches == 2)
vim.api.nvim_feedkeys(vim.keycode('<C-M-S-Right>'), 'xt', false)
assert(vim.api.nvim_get_current_win() ~= right, 'rightward entry must select the left edge')
vim.bo.filetype = 'fzf'
assert(vim.fn.maparg('<C-j>', 't', false, true).callback() == '<C-j>', 'fzf must retain Ctrl-j')
vim.system, vim.notify = saved_system, saved_notify
print('navigator: smoke checks passed')
vim.cmd('qa!')
