require('user/package')
require('user/options')
require('user/keymaps')

require('lazy').setup('plugins', {
  install = { colorscheme = { 'blank' } },
  change_detection = { notify = false },
})

-- local reset_group = vim.api.nvim_create_augroup('reset_group', {
--   clear = false,
-- })
--
-- vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'FocusGained' }, {
--   callback = function()
--     if vim.fn.isdirectory('.git') ~= 0 then
--       local branch = vim.fn.system("git branch --show-current | tr -d '\n'")
--       vim.b.branch_name = '[' .. branch .. ']'
--     end
--
--     local num_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
--     if num_errors > 0 then
--       vim.b.errors = ' ×' .. num_errors .. ' '
--       return
--     end
--
--     local num_warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
--     if num_warnings > 0 then
--       vim.b.errors = ' !' .. num_warnings .. ' '
--       return
--     end
--     vim.b.errors = ''
--   end,
--   group = reset_group,
-- })
--
-- vim.opt.statusline = ' %{get(b:, "branch_name", "")} %f %m %= %{get(b:, "errors", "")} %y %l:%c '
