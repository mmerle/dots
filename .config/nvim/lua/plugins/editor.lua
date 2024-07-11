-- editor plugins
--
-- additions/enhancements/replacements to the user interface

return {
  -- nvim-telescope (https://github.com/nvim-telescope/telescope.nvim)
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'debugloop/telescope-undo.nvim',
      'dimaportenko/telescope-simulators.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    keys = {
      {
        '<leader>p',
        '<cmd>Telescope find_files<cr>',
        desc = 'Find files',
      },
      {
        '<leader>/',
        '<cmd>Telescope live_grep<cr>',
        desc = 'Find text',
      },
      {
        '<leader>fu',
        '<cmd>Telescope undo<cr>',
        desc = 'Find undo history',
      },
      {
        '<leader><Tab>',
        '<cmd>Telescope buffers<cr>',
        desc = 'Find buffers',
      },
      {
        '<leader>fb',
        '<cmd>Telescope current_buffer_fuzzy_find<cr>',
        desc = 'Find in current buffer',
      },
      {
        '<leader>fo',
        '<cmd>Telescope oldfiles<cr>',
        desc = 'Find recent files',
      },
      {
        '<leader>fr',
        '<cmd>Telescope resume<cr>',
        desc = 'Resume find',
      },
      {
        '<leader>fw',
        '<cmd>Telescope grep_string<cr>',
        desc = 'Find current word',
      },
      {
        '<leader>fd',
        '<cmd>Telescope diagnostics<cr>',
        desc = 'Find diagnostics',
      },
      {
        '<leader>fc',
        '<cmd>Telescope command_history<cr>',
        desc = 'Find command history',
      },
      {
        '<leader>fC',
        '<cmd>Telescope commands<cr>',
        desc = 'Find commands',
      },
      {
        '<leader>fh',
        '<cmd>Telescope help_tags<cr>',
        desc = 'Find help pages',
      },
      {
        '<leader>fH',
        '<cmd>Telescope highlights<cr>',
        desc = 'Find highlight groups',
      },
      {
        '<leader>fk',
        '<cmd>Telescope keymaps<cr>',
        desc = 'Find keymaps',
      },
      {
        '<leader>fM',
        '<cmd>Telescope man_pages<cr>',
        desc = 'Find man pages',
      },
      {
        '<leader>ff',
        '<cmd>Telescope builtin<cr>',
        desc = 'Find telescope builtins',
      },
    },
    opts = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      telescope.load_extension('undo')
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')

      return {
        defaults = {
          prompt_prefix = ' ',
          selection_caret = '  ',
          results_title = false,
          preview_title = false,
          column_indent = 0,
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
            horizontal = { preview_width = 0.6, height = 0.6 },
            preview_cutoff = 1,
          },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--hidden',
            '--with-filename',
            '--line-number',
            '--column',
            '--trim',
            '-g',
            '!.git',
            '--smart-case',
          },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<esc>'] = actions.close,
              ['<C-f>'] = actions.to_fuzzy_refine,
            },
          },
        },
        pickers = {
          find_files = {
            theme = 'dropdown',
            previewer = false,
            disable_devicons = true,
            hidden = true,
            find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
          },
          buffers = {
            theme = 'dropdown',
            previewer = false,
            disable_devicons = true,
            -- ignore_current_buffer = true,
            sort_lastused = true,
          },
          oldfiles = {
            theme = 'dropdown',
            previewer = false,
            disable_devicons = true,
          },
        },
        extensions = {
          fzf = {},
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
    end,
  },
  -- gitsigns.nvim (https://github.com/lewis6991/gitsigns.nvim)
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { ']h', '<cmd>Gitsigns next_hunk<cr>', desc = 'Next hunk' },
      { '[h', '<cmd>Gitsigns prev_hunk<cr>', desc = 'Previous hunk' },
      {
        '<leader>ghp',
        '<cmd>Gitsigns preview_hunk<cr>',
        desc = 'Git preview hunk',
      },
      {
        '<leader>ghr',
        '<cmd>Gitsigns reset_hunk<cr>',
        desc = 'Git reset hunk',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ghs',
        '<cmd>Gitsigns stage_hunk<cr>',
        desc = 'Git stage hunk',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ghS',
        '<cmd>Gitsigns stage_buffer<cr>',
        desc = 'Git stage buffer',
      },
      {
        '<leader>ghd',
        '<cmd>Gitsigns diffthis<cr>',
        desc = 'Git diff hunk',
      },
    },
    opts = {},
  },
  -- vim-illuminate (https://github.com/RRethy/vim-illuminate)
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      { ']]', desc = 'Next reference' },
      { '[[', desc = 'Prev reference' },
    },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp' },
      },
    },
    config = function(_, opts)
      require('illuminate').configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set(
          'n',
          key,
          function() require('illuminate')['goto_' .. dir .. '_reference'](false) end,
          { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer }
        )
      end

      map(']]', 'next')
      map('[[', 'prev')

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map(']]', 'next', buffer)
          map('[[', 'prev', buffer)
        end,
      })
    end,
  },
  -- indentmini.nvim (https://github.com/nvimdev/indentmini.nvim)
  {
    'nvimdev/indentmini.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      char = '│',
      exclude = {
        'help',
        'terminal',
        'toggleterm',
        'lazy',
        'mason',
        'markdown',
        'NvimTree',
      },
    },
  },
  -- nvim-tree (https://github.com/nvim-tree/nvim-tree.lua)
  {
    'nvim-tree/nvim-tree.lua',
    keys = {
      {
        '<leader>e',
        '<cmd>NvimTreeFindFileToggle<cr>',
        desc = 'Toggle file tree',
      },
    },
    opts = {
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set('n', 'd', api.fs.trash, { buffer = bufnr })
      end,
      actions = { open_file = { quit_on_open = true } },
      filters = {
        custom = { '^.git$', '.DS_Store', '^node_modules$' },
      },
      git = { ignore = false },
      renderer = {
        group_empty = true,
        root_folder_label = false,
        highlight_git = true,
        icons = {
          symlink_arrow = ' ≈ ',
          show = {
            file = false,
            folder = true,
            folder_arrow = false,
            git = false,
          },
          glyphs = {
            folder = {
              default = '→',
              open = '↓',
              empty = '─',
              empty_open = '─',
              symlink = '↔',
              symlink_open = '↓',
            },
          },
        },
        indent_markers = {
          enable = true,
          icons = {
            corner = '│',
            edge = '│',
            item = '│',
            bottom = '─',
            none = ' ',
          },
        },
      },
      trash = { cmd = 'trash' },
      -- view = { side = 'right' },
    },
  },
  -- oil.nvim (https://github.com/stevearc/oil.nvim)
  {
    'stevearc/oil.nvim',
    keys = {
      { '-', '<cmd>Oil --float<cr>', desc = 'Oil' },
    },
    opts = {
      keymaps = {
        ['<C-v>'] = 'actions.select_vsplit',
        ['<C-x>'] = 'actions.select_split',
        ['<Esc>'] = 'actions.close',
      },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      columns = {},
      float = {
        padding = 5,
        max_width = 184,
      },
    },
  },
  -- flash.nvim (https://github.com/folke/flash.nvim)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      jump = {
        autojump = true,
      },
      prompt = { enabled = false },
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
    },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function() require('flash').jump() end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'o', 'x' },
        function() require('flash').treesitter() end,
        desc = 'Flash Treesitter',
      },
    },
  },
  -- incline.nvim (https://github.com/b0o/incline.nvim)
  {
    'b0o/incline.nvim',
    event = 'BufReadPre',
    priority = 1200,
    config = function()
      require('incline').setup({
        window = { margin = { vertical = 0, horizontal = 0 } },
        hide = { cursorline = false },
        render = function(props)
          local filepath = vim.api.nvim_buf_get_name(props.buf)
          local filename = vim.fn.fnamemodify(filepath, ':t')
          if vim.bo[props.buf].modified then filename = '*' .. filename end
          -- local ext = vim.fn.fnamemodify(filepath, ':e')
          -- local relative = vim.fn.fnamemodify(filepath, ':~:.:h')
          local parent = vim.fn.fnamemodify(filepath, ':h:t')
          return string.format('%s/%s', parent, filename)
        end,
      })
    end,
  },
  -- mini.bufremove (https://github.com/echasnovski/mini.bufremove)
  {
    'echasnovski/mini.bufremove',
    version = false,
    keys = {
      {
        '<leader>w',
        function() require('mini.bufremove').delete(0, false) end,
        desc = 'Close current buffer',
      },
      {
        '<leader>W',
        function()
          local current_buf = vim.api.nvim_get_current_buf()
          local bufs = vim.api.nvim_list_bufs()

          for _, buf in ipairs(bufs) do
            if
                vim.api.nvim_buf_is_valid(buf)
                and vim.api.nvim_buf_get_option(buf, 'buflisted')
                and buf ~= current_buf
            then
              require('mini.bufremove').delete(buf, false)
            end
          end
        end,
        desc = 'Close all but current buffer',
      },
    },
    opts = {
      silent = true,
    },
  },
  -- nvim-highlight-colors (https://github.com/brenoprata10/nvim-highlight-colors)
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'BufReadPre',
    opts = {
      render = 'virtual',
      virtual_symbol = '●',
      enable_tailwind = true,
      enable_named_colors = false,
      enable_var_usage = false,
    },
  },
  -- which-key (https://github.com/folke/which-key.nvim)
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      defaults = {
        mode = { 'n', 'v' },
        [']'] = { name = '+next' },
        ['['] = { name = '+prev' },
        ['<leader>f'] = { name = '+find' },
      },
      window = {
        margin = { 0, 0, 0, 0 },
      },
      plugins = {
        spelling = { enabled = true },
      },
      show_help = false,
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)
      wk.register(opts.defaults)
    end,
  },
  -- diffview.nvim (https://github.com/sindrets/diffview.nvim)
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    keys = {
      { '<leader>dvo', '<cmd>DiffviewOpen<cr>',  desc = 'DiffView open' },
      { '<leader>dvc', '<cmd>DiffviewClose<cr>', desc = 'Diffview close' },
    },
    config = true,
    opts = {
      use_icons = false,
      file_panel = {
        listing_style = 'list',
        win_config = {
          width = 35,
        },
      },
    },
  },
  -- nvim-ufo (https://github.com/kevinhwang91/nvim-ufo)
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    event = 'BufReadPost',
    opts = {},
    init = function()
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set('n', 'zp', require('ufo').peekFoldedLinesUnderCursor, { desc = 'Peek fold' })
    end,
  },
  -- zen-mode.nvim (https://github.com/folke/zen-mode.nvim)
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    keys = { { '<leader>z', '<cmd>ZenMode<cr>', desc = 'Zen mode' } },
    opts = {
      window = {
        backdrop = 1,
        width = 0.85,
        height = 0.85,
        options = {
          number = false,
          relativenumber = false,
        },
      },
      plugins = {
        gitsigns = { enabled = true },
        kitty = { enabled = false, font = '+2' },
        tmux = { enabled = true },
        options = {
          enabled = true,
          showcmd = false,
          laststatus = 0,
        },
      },
      -- on_open = function()
      --   -- todo: disable indentmini.nvim (awaiting functionality)
      -- end,
      -- on_close = function()
      --   -- todo: enable indentmini.nvim (awaiting functionality)
      -- end,
    },
  },
  -- nvim-treesitter-context
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      enable = true,
      max_lines = 3,
      trim_scope = 'outer',
      min_window_height = 10,
      separator = '—',
    },
  },
}
