local map = vim.keymap.set

Config.new_autocmd('BufEnter', '*', function() vim.cmd('setlocal formatoptions-=o') end, 'Disable comment continuation')
Config.new_autocmd('TextYankPost', '*', function() vim.hl.hl_op({ higroup = 'IncSearch', timeout = 200 }) end)
Config.new_autocmd('VimResized', '*', function() vim.cmd('tabdo wincmd =') end, 'Balance windows')

Config.new_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, '*', function()
  if vim.opt.number:get() then vim.opt.relativenumber = true end
end)
Config.new_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, '*', function()
  if vim.opt.number:get() then vim.opt.relativenumber = false end
end)

Config.new_autocmd({ 'WinEnter', 'BufEnter', 'InsertLeave' }, '*', function() vim.opt_local.cursorline = true end)
Config.new_autocmd({ 'WinLeave', 'BufLeave', 'InsertEnter' }, '*', function() vim.opt_local.cursorline = false end)

Config.new_autocmd('BufWinEnter', '*', function(event)
  if vim.bo[event.buf].filetype ~= 'help' then return end
  vim.cmd.only()
  vim.bo[event.buf].buflisted = true
end, 'Open help pages in listed current-window buffers')

Config.on_filetype('qf', function(event)
  local opts = { buf = event.buf, silent = true }
  map('n', 'j', '<cmd>cn | wincmd p<CR>', opts)
  map('n', 'k', '<cmd>cN | wincmd p<CR>', opts)
end)

function Config.findfunc(file_pattern, _)
  if file_pattern:sub(1, 1) == '*' then file_pattern = file_pattern:gsub('.', '.*%0') .. '.*' end
  return vim.fn.systemlist({
    'fd',
    '--color=never',
    '--full-path',
    '--type',
    'file',
    '--hidden',
    '--exclude=.git',
    '--exclude=deps',
    file_pattern,
  })
end

vim.opt.findfunc = 'v:lua.Config.findfunc'
map('n', '<C-p>', ':find ', { desc = 'Project Files' })
