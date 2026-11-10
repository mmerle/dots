local map = vim.keymap.set
local opts = { silent = true }

Config.group_clues = {
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>h', desc = '+Hunk' },
  { mode = 'n', keys = '<Leader>y', desc = '+Yank' },
}

map({ 'n', 'v' }, 'j', 'gj')
map({ 'n', 'v' }, 'k', 'gk')
map('v', '<', '<gv', opts)
map('v', '>', '>gv', opts)
map('n', '<leader>s', '<cmd>w<cr>', { desc = 'Write file' })
map('n', '<leader>S', '<cmd>wall<cr>', { desc = 'Write all files' })
map('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit instance' })
map('n', '<esc>', '<cmd>noh<cr>', opts)
map('n', '*', '*N', opts)
map('v', '*', [[y/\V<c-r>=escape(@",'/\')<cr><cr>N]], opts)
map('n', 'J', ':m .+1<cr>==', opts)
map('n', 'K', ':m .-2<cr>==', opts)
map('v', 'J', ":m '>+1<cr>gv=gv", opts)
map('v', 'K', ":m '<-2<cr>gv=gv", opts)
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<c-d>', '<c-d>zz')
map('n', '<c-u>', '<c-u>zz')
map('n', '<leader>H', '<c-w>H <c-w>=', { desc = 'Rotate splits (Horizontal)' })
map('n', '<leader>V', '<c-w>K <c-w>=', { desc = 'Rotate splits (Vertical)' })
for _, key in ipairs({ 'h', 'j', 'k', 'l' }) do
  map('n', '<C-' .. key .. '>', '<C-w>' .. key, { desc = 'Navigate window' })
end
map('n', '<up>', ':horizontal resize -5<cr>')
map('n', '<down>', ':horizontal resize +5<cr>')
map('n', '<left>', ':vertical resize -5<cr>')
map('n', '<right>', ':vertical resize +5<cr>')
map('n', 'go', '<c-o>', { desc = 'Goto previous position' })
map('n', 'gm', '%', { desc = 'Goto matching pair' })
map('n', '<leader>i', '<cmd>Inspect<cr>', { desc = 'Inspect syntax highlighting' })
map('n', 'gV', '`[v`]', { desc = 'Visually select last edited' })
map('i', '<a-bs>', '<c-w>', { desc = 'Delete word' })
map('n', 'yc', 'yygccp', { remap = true })
map('n', '<leader>ya', '<cmd>%y<cr>', { desc = 'Yank entire file' })

local function yank_path_with_line(modifier)
  if vim.api.nvim_buf_get_name(0) == '' or vim.bo.buftype ~= '' then
    vim.notify('Buffer has no file path', vim.log.levels.WARN)
    return
  end

  local path = vim.fn.expand('%:' .. modifier) .. '#L' .. vim.fn.line('.')
  vim.fn.setreg('+', path, 'v')
  vim.notify('Yanked: ' .. path, vim.log.levels.INFO)
end

map('n', '<leader>yf', function()
  yank_path_with_line('.')
end, { desc = 'Yank relative path with line number' })
map('n', '<leader>yp', function()
  yank_path_with_line('p')
end, { desc = 'Yank absolute path with line number' })
map('n', '<C-_>', function()
  require('Comment.api').toggle.linewise.current()
end, opts)

-- conceal level toggle
map('n', '<leader>uc', function()
  local next_value = vim.o.conceallevel + 1
  vim.o.conceallevel = next_value == 4 and 0 or next_value
  local descriptions = {
    [0] = '0 (No conceal)',
    [1] = '1 (Replace with one char)',
    [2] = '2 (Replace with one char, or hide)',
    [3] = '3 (Completely hide)',
  }
  vim.notify('Conceal level: ' .. descriptions[vim.o.conceallevel])
end, { desc = 'Adjust conceal level' })
