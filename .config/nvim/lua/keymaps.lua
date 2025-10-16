vim.g.mapleader = ' '

local opts = { silent = true }
local map = vim.keymap.set

_G.conf.group_clues = {
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>h', desc = '+Hunk' },
}

-- move through wrapped lines
map({ 'n', 'v' }, 'j', 'gj')
map({ 'n', 'v' }, 'k', 'gk')

map('v', '<', '<gv', opts) -- unindent (keep selection)
map('v', '>', '>gv', opts) -- indent (keep selection)

-- quick actions
map('n', '<leader>s', '<cmd>w<cr>', { desc = 'Write file' }, opts)         -- quick save
map('n', '<leader>S', '<cmd>wall<cr>', { desc = 'Write all files' }, opts) -- quick save all buffers
map('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit instance' }, opts)      -- quick quit

-- search
map('n', '<esc>', '<cmd>noh<cr>', opts)                     -- clear search highlights
map('n', '*', '*N', opts)                                   -- search word under cursor (keep position)
map('v', '*', [[y/\V<c-r>=escape(@",'/\')<cr><cr>N]], opts) -- search selection (keep position)
-- map('n', 'S', ':%s/<c-r><c-w>//g<left><left>', { silent = false }) -- replace selection

-- block movement
map('n', 'J', ':m .+1<cr>==', opts)
map('n', 'K', ':m .-2<cr>==', opts)
map('v', 'J', ":m '>+1<cr>gv=gv", opts)
map('v', 'K', ":m '<-2<cr>gv=gv", opts)

-- center vertical movement
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<c-d>', '<c-d>zz')
map('n', '<c-u>', '<c-u>zz')

-- split rotations
map('n', '<leader>H', '<c-w>t <c-w>H <c-w>=', { desc = 'Rotate splits (Horitonzal)' })
map('n', '<leader>V', '<c-w>t <c-w>K <c-w>=', { desc = 'Rotate splits (Vertical)' })

-- split resize
map('n', '<up>', ':horizontal resize -5<cr>')
map('n', '<down>', ':horizontal resize +5<cr>')
map('n', '<left>', ':vertical resize -5<cr>')
map('n', '<right>', ':vertical resize +5<cr>')

-- goto
map('n', 'go', '<c-o>', { desc = 'Goto previous position' }, opts) -- goto previous position
map('n', 'gm', '%', { desc = 'Goto matching pair' }, opts)         -- goto matching character: '()', '{}', '[]'

-- inspect syntax highlighting
map('n', '<leader>i', '<cmd>Inspect<cr>', { desc = 'Inspect syntax highlighting' }, opts)

-- visually select text that was last edited/pasted (Vimcast#26)
map('n', 'gV', '`[v`]', { desc = 'Visually select last edited' }, opts)

-- like macOS opt-delete
map('i', '<a-bs>', '<c-w>', { desc = 'Delete word' })

-- duplicate a line and comment out the first line
map('n', 'yc', 'yygccp', { remap = true })

-- yank entire file content
map('n', '<leader>y', '<cmd>%y<cr>', { desc = 'Yank entire file' })

-- conceal level toggle
map('n', '<leader>uc', function()
  local prev = vim.o.conceallevel
  local next_value = prev + 1
  vim.o.conceallevel = next_value == 4 and 0 or next_value
  local descriptions = {
    [0] = '0 (No conceal)',
    [1] = '1 (Replace with one char)',
    [2] = '2 (Replace with one char, or hide)',
    [3] = '3 (Completely hide)',
  }
  vim.notify('Conceal level: ' .. descriptions[vim.o.conceallevel])
end, { desc = 'Adjust conceal level' })

-- comment
-- map('n', '<leader>gg', 'gcc', { desc = 'Comment current line' })
map(
  'n',
  '<C-_>',
  function() require('Comment.api').toggle.linewise.current() end,
  { noremap = true, silent = true }
)
-- map('v', 'gv', '<C-/>', { desc = 'Comment selected line' }, opts)
