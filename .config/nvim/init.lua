local function map(mode, lhs, rhs, opts)
	opts = opts or { noremap = true, silent = true }
	return vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

vim.g.mapleader = ' '

map('n', '<leader>r', ':source ~/.config/nvim/init.lua<cr>')
map('n', '<leader>e', ':NvimTreeToggle<cr>')
map('n', '<leader>p', [[:lua require('telescope.builtin').find_files()<cr>]])

map('n', '<leader>s', ':w<cr>')
map('n', '<leader>q', ':q<cr>')

map('n', 'gt', ':BufferNext<cr>')
map('n', 'gT', ':BufferPrevious<cr>')
map('n', '<leader>w', ':BufferClose<cr>')

map('n', '<leader>kc', ':PackerCompile<cr>')
map('n', '<leader>ks', ':PackerSync<cr>')

vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.scrolloff = 5
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.cindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.title = true
vim.opt.titlestring = '%t'
vim.opt.laststatus = 0
vim.opt.statusline = '%f %M %= %l:%c'
vim.opt.wildmode = 'longest:full,full'
vim.opt.smartcase = true
vim.opt.updatetime = 300
vim.opt.termguicolors = true

vim.cmd('colorscheme flora')

-- plugins

require('packer').startup(function(use)
  use('wbthomason/packer.nvim')
  use('tpope/vim-commentary')
  use({
    'nvim-telescope/telescope.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git/', '.next/' },
          layout_config = { horizontal = { preview_width = 0.6 }, }
        },
        pickers = {
          find_files = {
            hidden = true,
            theme = 'dropdown',
            previewer = false,
          },
        }
      })
    end,
  })
  use({
    'kyazdani42/nvim-tree.lua',
    config = function()
      vim.g.nvim_tree_git_hl = 1
      vim.g.nvim_tree_icons = {
        folder = {
          default = '▶',
          empty = '▶',
          symlink = '▶',
          open = '▼',
          empty_open = '▼',
          symlink_open = '▼',
        },
      }
      vim.g.nvim_tree_symlink_arrow = ' → '
      vim.g.nvim_tree_quit_on_open = 1
      vim.g.nvim_tree_show_icons = { folders = 1, files = 0 }
      require('nvim-tree').setup({
        auto_close = true,
        filters = {
          custom = { '.git', '.DS_Store' },
        },
        view = {
          hide_root_folder = true,
        },
      })
end,
  })
  use({
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup({
        '*';
        css = {
          hsl_fn = true;
          names = false;
        }
      })
    end,
  })
  use({
    'lewis6991/gitsigns.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  })
  use({
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup({
        show_end_of_line = true,
      })
    end,
  })
  use({
    'romgrk/barbar.nvim',
    config = function()
      vim.g.bufferline = {
        animation = false,
        icon_close_tab = 'x',
        icon_close_tab_modified = '•',
        icons = false,
      }
    end,
  })
end)
