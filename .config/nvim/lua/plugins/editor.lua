return {
  -- fzf-lua (https://github.com/ibhagwan/fzf-lua)
  {
    'ibhagwan/fzf-lua',
    keys = {
      { '<leader>fr', '<cmd>FzfLua resume<cr>',                   desc = 'Resume find' },
      { '<leader>p',  '<cmd>FzfLua files<cr>',                    desc = 'Find files' },
      { '<leader>/',  '<cmd>FzfLua live_grep<cr>',                desc = 'Find text' },
      { '<leader>b',  '<cmd>FzfLua buffers<cr>',                  desc = 'Find buffers', },
      { '<leader>fo', '<cmd>FzfLua oldfiles<cr>',                 desc = 'Find recent files', },
      { '<leader>fb', '<cmd>FzfLua lgrep_curbuf<cr>',             desc = 'Find in current buffer', },
      { '<leader>fd', '<cmd>FzfLua lsp_document_diagnostics<cr>', desc = 'Find diagnostics' },
      { '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>',     desc = 'Find symbols', },
      { '<leader>fS', '<cmd>FzfLua spell_suggest<cr>',            desc = 'Find spelling suggestions', },
      { '<leader>fw', '<cmd>FzfLua grep_cword<cr>',               desc = 'Find current word', },
      { '<leader>fc', '<cmd>FzfLua command_history<cr>',          desc = 'Find command history', },
      { '<leader>fC', '<cmd>FzfLua commands<cr>',                 desc = 'Find commands', },
      { '<leader>fh', '<cmd>FzfLua helptags<cr>',                 desc = 'Find help', },
      { '<leader>fz', '<cmd>FzfLua zoxide<cr>',                   desc = 'Find in zoxide', },
      { '<leader>fH', '<cmd>FzfLua highlights<cr>',               desc = 'Find highlights', },
    },
    opts = {
    },
    config = function()
      local fzf = require('fzf-lua')
      fzf.setup({
        keymap = {
          builtin = {
            ['<esc>'] = 'hide',
          },
          fzf = {
            ['ctrl-q'] = 'select-all+accept',
          },
        },
        fzf_opts = {
          ['--info'] = 'hidden',
        },
        defaults = {
          file_icons = false,
          git_icons = false,
        },
        winopts = {
          height = 0.6,
          width = 0.6,
          border = 'single',
          preview = {
            horizontal = 'right:70%',
            scrollbar = 'border',
            border = 'single',
          },
        },
        previewers = {
          builtin = {
            syntax_limit_b = 1024 * 1024,
            limit_b        = 1024 * 1024,
            treesitter     = {
              context = false,
            },
          },
        },
        files = {
          formatter = 'path.filename_first',
          winopts = {
            height = 0.4,
            width = 0.4,
          },
          previewer = false,
          cwd_prompt = false,
          rg_opts = '--files --hidden -g !.git --color=never',
        },
        oldfiles = {
          formatter = 'path.filename_first',
          winopts = {
            height = 0.4,
            width = 0.4,
          },
          previewer = false,
          cwd_only = true,
          stat_file = true,
          include_current_session = true,
        },
        buffers = {
          winopts = {
            height = 0.4,
            width = 0.4,
          },
          previewer = false,
          ignore_current_buffer = true,
        },
        grep = {
          rg_opts =
          '--no-heading --hidden --with-filename --line-number --column --trim -g !.git --smart-case --color=never'
        },
        spell_suggest = {
          winopts = {
            height = 0.33,
            width = 0.33,
            relative = 'cursor',
          },
        },
        hls = {
          normal = 'NormalFloat',
          preview_normal = 'NormalFloat',
          border = 'FloatBorder',
          preview_border = 'FloatBorder',
        },
        fzf_colors = {
          ['gutter'] = '-1'
        },
        file_icon_padding = '',
      })
      fzf.register_ui_select()
    end,
  },
  -- gitsigns.nvim (https://github.com/lewis6991/gitsigns.nvim)
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { ']h',         '<cmd>Gitsigns next_hunk<cr>',    desc = 'Next hunk' },
      { '[h',         '<cmd>Gitsigns prev_hunk<cr>',    desc = 'Previous hunk' },
      { '<leader>hp', '<cmd>Gitsigns preview_hunk<cr>', desc = 'Git preview hunk' },
      { '<leader>hr', '<cmd>Gitsigns reset_hunk<cr>',   desc = 'Git reset hunk',  mode = { 'n', 'v' }, },
      { '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>',   desc = 'Git stage hunk',  mode = { 'n', 'v' }, },
      { '<leader>hS', '<cmd>Gitsigns stage_buffer<cr>', desc = 'Git stage buffer' },
      { '<leader>hd', '<cmd>Gitsigns diffthis<cr>',     desc = 'Git diff hunk' },
    },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 0,
      },
      current_line_blame_formatter = ' <author>, <author_time:%R> ',
    },
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
      filetypes_denylist = {
        'lazy',
        'mason',
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
  -- mini.indentscope (https://github.com/echasnovski/mini.indentscope)
  {
    'echasnovski/mini.indentscope',
    version = false,
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('mini.indentscope').setup({
        draw = { delay = 0, animation = require('mini.indentscope').gen_animation.none() },
        options = { try_as_border = true },
        symbol = '│',
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'help',
          'lazy',
          'man',
          'mason',
          'markdown',
          'NvimTree',
          'terminal',
        },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },
  -- mini.files (https://github.com/echasnovski/mini.files)
  {
    'echasnovski/mini.files',
    version = false,
    lazy = false,
    keys = {
      {
        '-',
        function()
          local minifiles = require('mini.files')
          if not minifiles.close() then
            minifiles.open(vim.api.nvim_buf_get_name(0))
            -- minifiles.reveal_cwd()
          end
        end,
        desc = 'File explorer',
      },
    },
    opts = {
      mappings = {
        close = '<esc>',
        go_in_plus = '<cr>',
        synchronize = 's',
      },
      content = {
        filter = function(entry)
          return entry.name ~= '.DS_Store' and entry.name ~= '.git' and entry.name ~= 'node_modules'
        end,
        prefix = function() end,
      },
      options = {
        permanent_delete = false,
        use_as_default_explorer = false,
      },
      windows = {
        preview = true,
        width_focus = 40,
        width_nofocus = 30,
        width_preview = 60,
      },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      -- open in splits
      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          local state = require('mini.files').get_explorer_state()
          local new_target = vim.api.nvim_win_call(state.target_window, function()
            vim.cmd(direction)
            return vim.api.nvim_get_current_win()
          end)
          require('mini.files').set_target_window(new_target)
          require('mini.files').go_in({ close_on_file = true })
        end
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = 'Open in ' .. direction })
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id
          map_split(buf_id, '<C-v>', 'belowright vertical split')
          map_split(buf_id, '<C-h>', 'belowright horizontal split')
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
  -- flash.nvim (https://github.com/folke/flash.nvim)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function() require('flash').jump() end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function() require('flash').treesitter() end,
        desc = 'Flash Treesitter',
      },
      {
        '<leader>*',
        mode = { 'n' },
        function()
          require('flash').jump({
            pattern = vim.fn.expand('<cword>'),
          })
        end,
        desc = 'Jump to word under cursor',
      },
    },
    opts = {
      jump = {
        autojump = true,
      },
      prompt = { enabled = false },
      modes = {
        -- using /
        search = { enabled = false },
        -- using f F t T
        char = { enabled = false },
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
          local parent = vim.fn.fnamemodify(filepath, ':h:t')

          if vim.bo[props.buf].modified then
            return { { string.format('* %s/%s', parent, filename), hlgroup = 'InclineModified' } }
          else
            return { string.format('%s/%s', parent, filename) }
          end
        end,
      })
    end,
  },
  -- nvim-highlight-colors (https://github.com/brenoprata10/nvim-highlight-colors)
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'BufReadPre',
    opts = {
      render = 'virtual',
      virtual_symbol = '■',
      virtual_symbol_position = 'eol',
      virtual_symbol_prefix = '',
      virtual_symbol_suffix = '',
      enable_named_colors = false,
      enable_tailwind = false,
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
        { '[',          group = 'prev' },
        { ']',          group = 'next' },
        { '<leader>c',  group = 'code' },
        { '<leader>f',  group = 'find' },
        { '<leader>gh', group = 'git' },
      },
      win = {
        padding = { 1, 0 },
      },
      icons = {
        breadcrumb = '»',
        separator = '→',
        group = '+',
        ellipsis = '…',
        mappings = false,
      },
      plugins = {
        spelling = { enabled = true },
      },
      show_help = false,
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)
      wk.add(opts.defaults)
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
    config = function()
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set('n', 'zp', require('ufo').peekFoldedLinesUnderCursor, { desc = 'Peek fold' })

      require('ufo').setup({
        preview = {
          win_config = {
            border = 'single',
            winhighlight = 'Normal:Folded',
            winblend = 0
          },
        },
      })
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
        width = 0.8,
        height = 0.8,
        options = {
          number = false,
          relativenumber = false,
        },
      },
      plugins = {
        gitsigns = { enabled = true },
        tmux = { enabled = true },
        options = {
          enabled = true,
          showcmd = false,
          laststatus = 0,
          winborder = 'none',
        },
      },
      on_open = function()
        vim.b.miniindentscope_disable = true
        require('incline').disable()
      end,
      on_close = function()
        vim.b.miniindentscope_disable = false
        require('incline').enable()
      end,
    },
  },
  -- nvim-treesitter-context (https://github.com/nvim-treesitter/nvim-treesitter-context)
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
  --- harpoon (https://github.com/ThePrimeagen/harpoon)
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufEnter' },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({ settings = { save_on_toggle = true } })
      vim.keymap.set('n', 'ma', function() harpoon:list():add() end)
      vim.keymap.set('n', '<leader>m', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      vim.keymap.set('n', "'a", function() harpoon:list():select(1) end)
      vim.keymap.set('n', "'s", function() harpoon:list():select(2) end)
      vim.keymap.set('n', "'d", function() harpoon:list():select(3) end)
      vim.keymap.set('n', "'f", function() harpoon:list():select(4) end)
    end,
  },
}
