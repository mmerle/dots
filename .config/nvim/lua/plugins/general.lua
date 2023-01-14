return {
  {
    'numToStr/Comment.nvim',
    event = 'BufReadPre',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
      })

      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
  {
    'kylechui/nvim-surround',
    event = 'BufReadPre',
    config = function()
      require('nvim-surround').setup()
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'BufReadPre',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPost',
    dependencies = {
      'nvim-treesitter/playground',
      'windwp/nvim-ts-autotag',
      'kevinhwang91/nvim-ufo',
      'kevinhwang91/promise-async',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        ignore_install = { 'phpdoc' },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        playground = { enable = true },
      })

      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = 'Telescope',
    keys = {
      {
        '<leader>p',
        ':Telescope find_files<cr>',
        desc = 'Find files',
      },
      {
        '<leader>/',
        ':Telescope live_grep<cr>',
        desc = 'Find text',
      },
    },
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup({
        defaults = {
          selection_caret = '  ',
          column_indent = 0,
          sorting_strategy = 'ascending',
          layout_strategy = 'horizontal',
          file_ignore_patterns = { '.git', 'node_modules', '.next', '.DS_Store' },
          layout_config = {
            prompt_position = 'top',
            horizontal = { preview_width = 0.6, height = 0.6 },
          },
          find_command = { 'fd', '-t', 'f', '-H', '-E', '.git', '--strip-cwd-prefix' },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<esc>'] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true, theme = 'dropdown', previewer = false },
        },
      })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    event = 'BufReadPre',
    config = function()
      require('gitsigns').setup()
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufReadPre',
    config = function()
      require('indent_blankline').setup({
        show_end_of_line = true,
        filetype_exclude = { 'terminal', 'packer', 'help', 'markdown' },
      })
    end,
  },
  {
    'kyazdani42/nvim-tree.lua',
    keys = {
      {
        '<leader>e',
        '<cmd>NvimTreeFindFileToggle<cr>',
        desc = 'Toggle file tree',
      },
    },
    opts = {
      actions = {
        open_file = { quit_on_open = true },
      },
      filters = {
        custom = { '^.git$', '.DS_Store', '^node_modules$' },
      },
      git = { ignore = false },
      trash = { cmd = 'trash' },
      renderer = {
        highlight_git = true,
        icons = {
          symlink_arrow = ' → ',
          show = {
            file = false,
            folder = true,
            folder_arrow = false,
            git = false,
          },
          glyphs = {
            folder = {
              default = '●',
              empty = '◌',
              symlink = '●',
              open = '○',
              empty_open = '○',
              symlink_open = '○',
            },
          },
        },
      },
      view = {
        hide_root_folder = true,
        mappings = {
          list = {
            { key = 'd', action = 'trash' },
            { key = 'D', action = 'remove' },
          },
        },
      },
    },
  },
  {
    'romgrk/barbar.nvim',
    event = 'BufReadPre',
    config = function()
      require('bufferline').setup({
        animation = false,
        icon_close_tab = '×',
        icon_close_tab_modified = '*',
        icon_separator_active = '',
        icon_separator_inactive = '',
        icons = false,
      })
    end,
  },
  {
    'norcalli/nvim-colorizer.lua',
    event = 'BufReadPre',
    config = function()
      require('colorizer').setup({
        '*',
        css = {
          hsl_fn = true,
          names = false,
        },
      })
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'BufReadPre',
    config = function()
      require('which-key').setup({
        window = {
          margin = { 0, 0, 0, 0 },
        },
        plugins = {
          spelling = { enabled = true },
        },
      })
    end,
  },
}
