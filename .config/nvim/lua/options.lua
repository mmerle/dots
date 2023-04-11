local indent = 2
local scrolloff = 3

vim.opt.clipboard = 'unnamedplus' -- enable universal clipboard
vim.opt.cursorline = true         -- highlight current line
vim.opt.updatetime = 250          -- faster update time
vim.opt.shiftwidth = indent
vim.opt.tabstop = indent
vim.opt.scrolloff = scrolloff
vim.opt.sidescrolloff = scrolloff
vim.opt.termguicolors = true  -- support for true colour
vim.opt.number = true         -- show line numbers
vim.opt.relativenumber = true -- line numbers relative to cursor
vim.opt.signcolumn = 'yes'    -- always show signcolumn
vim.opt.mouse = 'a'           -- enable mouse
vim.opt.undofile = true       -- unable undo
vim.opt.shortmess:append('c') -- shorter messages
vim.opt.splitbelow = true     -- split new window below of current
vim.opt.splitright = true     -- split new window right of current
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.cindent = true
vim.opt.laststatus = 3
vim.opt.ignorecase = true
vim.opt.smartcase = true               -- only case sensitive when alternate case is used
vim.opt.wildmode = 'longest:full,full' -- commandline completion settings
vim.opt.pumheight = 6                  -- commandline completion height
vim.opt.completeopt = 'menu,menuone,noinsert'
-- vim.opt.title = true
-- vim.opt.titlestring = '%t — nvim'
vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '·' }
-- vim.opt.cmdheight = 0

-- settings for ufo compatibility
vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

if not vim.g.vscode then
  -- apply local colorscheme
  vim.cmd.colorscheme('flora')

  -- stop 'o' continuing comments
  vim.api.nvim_create_autocmd('BufEnter', {
    command = 'setlocal formatoptions-=o',
  })

  -- highlight copied text
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      vim.highlight.on_yank()
    end,
  })

  -- use circles for diagnostics
  local signs = { 'Error', 'Warn', 'Hint', 'Info' }
  for _, type in pairs(signs) do
    local hl = string.format('DiagnosticSign%s', type)
    vim.fn.sign_define(hl, { text = '●', texthl = hl, numhl = hl })
  end

  -- open nvim-tree on startup
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      require('nvim-tree.api').tree.open()
    end,
  })

  -- custom statusline
  local reset_group = vim.api.nvim_create_augroup('reset_group', {
    clear = false,
  })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'FocusGained' }, {
    callback = function()
      if vim.fn.isdirectory('.git') ~= 0 then
        local branch = vim.fn.system("git branch --show-current | tr -d '\n'")
        vim.b.branch_name = '[' .. branch .. ']'
      end

      local num_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      if num_errors > 0 then
        vim.b.errors = ' ×' .. num_errors .. ' '
        return
      end

      local num_warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      if num_warnings > 0 then
        vim.b.errors = ' !' .. num_warnings .. ' '
        return
      end
      vim.b.errors = ''
    end,
    group = reset_group,
  })

  vim.opt.statusline = ' %{get(b:, "branch_name", "")} %f %m %= %{get(b:, "errors", "")} %y %l:%c '
end
