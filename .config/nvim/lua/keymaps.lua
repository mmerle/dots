local opts = { silent = true }
local Util = require('util')

vim.g.mapleader = ' '

-- move through wrapped lines
vim.keymap.set({ 'n', 'v' }, 'j', 'gj', opts)
vim.keymap.set({ 'n', 'v' }, 'k', 'gk', opts)

vim.keymap.set('v', '<', '<gv', opts)            -- unindent (keep selection)
vim.keymap.set('v', '>', '>gv', opts)            -- indent (keep selection)
vim.keymap.set('n', 'H', '^', opts)              -- jump to first character of line
vim.keymap.set('n', 'L', 'g_', opts)             -- jump to last character of line
vim.keymap.set('n', '<leader>s', ':w<cr>', opts) -- quick save
vim.keymap.set('n', '<leader>q', ':q<cr>', opts) -- quick quit

-- search
vim.keymap.set('n', '<esc>', ':noh<cr>', opts)                                -- clear search highlights
vim.keymap.set('n', '*', '*N', opts)                                          -- search word under cursor (keep position)
vim.keymap.set('v', '*', [[y/\V<c-r>=escape(@",'/\')<cr><cr>N]], opts)        -- search selection (keep position)
vim.keymap.set('n', 'S', ':%s/<c-r><c-w>//g<left><left>', { silent = false }) -- replace selection

-- block movement
vim.keymap.set('n', 'J', ':m .+1<cr>==', opts)
vim.keymap.set('n', 'K', ':m .-2<cr>==', opts)
vim.keymap.set('v', 'J', ":m '>+1<cr>gv=gv", opts)
vim.keymap.set('v', 'K', ":m '<-2<cr>gv=gv", opts)

-- center vertical movement
vim.keymap.set('n', '<c-d>', '<c-d>zz', opts)
vim.keymap.set('n', '<c-u>', '<c-u>zz', opts)

-- window
vim.keymap.set('n', '<c-h>', '<c-w><c-h>', opts) -- jump to split left
vim.keymap.set('n', '<c-j>', '<c-w><c-j>', opts) -- jump to split below
vim.keymap.set('n', '<c-k>', '<c-w><c-k>', opts) -- jump to split above
vim.keymap.set('n', '<c-l>', '<c-w><c-l>', opts) -- jump to split right
-- vim.keymap.set('n', '<c-r>', '<c-w><c-r>', opts) -- swap split positions

-- goto
vim.keymap.set('n', 'go', '<c-o>', { desc = 'Goto previous position' }, opts)    -- goto previous position
vim.keymap.set('n', 'gm', '%', { desc = 'Goto matching pair' }, opts)            -- goto matching character: '()', '{}', '[]'
vim.keymap.set('n', 'gp', ':bprev<cr>', { desc = 'Goto previous buffer' }, opts) -- goto previous buffer
vim.keymap.set('n', 'gn', ':bnext<cr>', { desc = 'Goto next buffer' }, opts)     -- goto next buffer

vim.keymap.set('n', '<leader>w', ':bdelete<cr>', opts)                           -- close current buffer
-- vim.keymap.set('n', '<leader>W', ':BufferCloseAllButCurrent<cr>', opts) -- close all but current buffer

vim.keymap.set('n', '<leader>lg', function()
  Util.lazygit_toggle()
end, { desc = 'Lazygit' })
