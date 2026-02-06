vim.o.list = false
vim.o.colorcolumn = ''
vim.o.concealcursor = 'nc'

-- https://www.reddit.com/r/neovim/comments/10383z1/open_help_in_buffer_instead_of_split/
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function(event)
    if vim.bo[event.buf].filetype == 'help' then
      vim.cmd.only()
      vim.bo[event.buf].buflisted = true
    end
  end,
  desc = 'Open help pages in a listed buffer in the current window.'
})

-- open `:help` pages in vsplit
-- vim.api.nvim_create_autocmd('BufWinEnter', {
--   group = vim.api.nvim_create_augroup('help_window_right', {}),
--   pattern = { '*.txt' },
--   callback = function()
--     if vim.o.filetype == 'help' then
--       vim.api.nvim_cmd({ cmd = 'wincmd', args = { 'L' } }, {})
--       vim.keymap.set('n', 'q', ':q<cr>', { buffer = 0 })
--     end
--   end,
-- })
