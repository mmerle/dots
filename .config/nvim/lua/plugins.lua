-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

local not_vscode = not vim.g.vscode

local plugins = {
  -- flora
  {
    dir = '~/Developer/projects/p/flora/flora.nvim',
    name = 'flora',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme flora]])
    end,
  },
  -- comment (https://github.com/numToStr/Comment.nvim)
  {
    'numToStr/Comment.nvim',
    enabled = not_vscode,
    event = 'VeryLazy',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
  -- nvim-surround (https://github.com/kylechui/nvim-surround)
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {
      keymaps = {
        insert = '<C-g>z',
        insert_line = '<C-g>gZ',
        normal = 'gz',
        normal_cur = 'gZ',
        normal_line = 'gzgz',
        normal_cur_line = 'gZgZ',
        visual = 'gz',
        visual_line = 'gZ',
        delete = 'gzd',
        change = 'gzc',
      },
    },
  },
  -- vim-repeat (https://github.com/tpope/vim-repeat)
  {
    'tpope/vim-repeat',
    event = 'VeryLazy',
  },
  -- nvim-autopairs (https://github.com/windwp/nvim-autopairs)
  {
    'windwp/nvim-autopairs',
    enabled = not_vscode,
    event = 'InsertEnter',
    opts = {},
  },
  -- nvim-treesitter (https://github.com/nvim-treesitter/nvim-treesitter)
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = not_vscode,
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'windwp/nvim-ts-autotag',
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        ignore_install = { 'phpdoc' },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
            },
          },
        },
      })
    end,
  },
  -- nvim-telescope (https://github.com/nvim-telescope/telescope.nvim)
  {
    'nvim-telescope/telescope.nvim',
    enabled = not_vscode,
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'debugloop/telescope-undo.nvim',
      'dimaportenko/telescope-simulators.nvim',
    },
    keys = {
      {
        '<leader>p',
        ':Telescope find_files<cr>',
        desc = 'Find files',
      },
      {
        '<leader>b',
        ':Telescope buffers<cr>',
        desc = 'Find Buffers',
      },
      {
        '<leader>/',
        ':Telescope live_grep<cr>',
        desc = 'Find text',
      },
      {
        '<leader>fr',
        ':Telescope oldfiles<cr>',
        desc = 'Find recent files',
      },
      {
        '<leader>fb',
        ':Telescope current_buffer_fuzzy_find<cr>',
        desc = 'Buffer',
      },
      {
        '<leader>fc',
        ':Telescope command_history<cr>',
        desc = 'Command History',
      },
      {
        '<leader>fC',
        ':Telescope commands<cr>',
        desc = 'Commands',
      },
      {
        '<leader>fd',
        ':Telescope diagnostics<cr>',
        desc = 'Diagnostics',
      },
      {
        '<leader>fh',
        ':Telescope help_tags<cr>',
        desc = 'Help Pages',
      },
      {
        '<leader>fH',
        ':Telescope highlights<cr>',
        desc = 'Highlight Groups',
      },
      {
        '<leader>fk',
        ':Telescope keymaps<cr>',
        desc = 'Key Maps',
      },
      {
        '<leader>fM',
        ':Telescope man_pages<cr>',
        desc = 'Man Pages',
      },
      {
        '<leader>fo',
        ':Telescope vim_options<cr>',
        desc = 'Options',
      },
      {
        '<leader>ft',
        ':Telescope builtin<cr>',
        desc = 'Builtin',
      },
      {
        '<leader>U',
        ':Telescope undo<cr>',
        desc = 'Undo history',
      },
    },
    opts = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local layout_strategies = require('telescope.pickers.layout_strategies')
      telescope.load_extension('undo')

      -- custom layout
      layout_strategies.horizontal_merged = function(picker, max_columns, max_lines, layout_config)
        local layout = layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)

        layout.prompt.title = ''
        layout.prompt.borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' }

        layout.results.title = ''
        layout.results.borderchars = { '─', '│', '─', '│', '├', '┤', '┘', '└' }
        layout.results.line = layout.results.line - 1
        layout.results.height = layout.results.height + 1

        if layout.preview then
          layout.preview.title = ''
          layout.preview.borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' }
        end

        return layout
      end

      return {
        defaults = {
          prompt_prefix = ' ',
          selection_caret = '  ',
          results_title = false,
          preview_title = false,
          column_indent = 0,
          sorting_strategy = 'ascending',
          layout_strategy = 'horizontal_merged',
          layout_config = {
            prompt_position = 'top',
            horizontal = { preview_width = 0.6, height = 0.6 },
            -- dropdown = {
            --   height = function(_, _, max_lines)
            --     return math.min(max_lines, 15)
            --   end,
            --   width = function(_, max_columns, _)
            --     return math.min(max_columns, 80)
            --   end,
            -- },
            -- preview_cutoff = 1,
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
            ignore_current_buffer = true,
            sort_lastused = true,
          },
          oldfiles = {
            theme = 'dropdown',
            previewer = false,
            disable_devicons = true,
          },
        },
      }
    end,
  },
  -- gitsigns.nvim (https://github.com/lewis6991/gitsigns.nvim)
  {
    'lewis6991/gitsigns.nvim',
    enabled = not_vscode,
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { ']h', ':Gitsigns next_hunk<cr>', desc = 'Next hunk' },
      { '[h', ':Gitsigns prev_hunk<cr>', desc = 'Previous hunk' },
      {
        '<leader>ghp',
        ':Gitsigns preview_hunk<cr>',
        desc = 'Git preview hunk',
      },
      {
        '<leader>ghr',
        ':Gitsigns reset_hunk<cr>',
        desc = 'Git reset hunk',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ghs',
        ':Gitsigns stage_hunk<cr>',
        desc = 'Git stage hunk',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ghS',
        ':Gitsigns stage_buffer<cr>',
        desc = 'Git stage buffer',
      },
      {
        '<leader>ghd',
        ':Gitsigns diffthis<cr>',
        desc = 'Git diff hunk',
      },
    },
    opts = {},
  },
  -- vim-illuminate (https://github.com/RRethy/vim-illuminate)
  {
    'RRethy/vim-illuminate',
    enabled = not_vscode,
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
        vim.keymap.set('n', key, function()
          require('illuminate')['goto_' .. dir .. '_reference'](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer })
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
  -- indent-blankline (https://github.com/lukas-reineke/indent-blankline.nvim)
  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = not_vscode,
    event = { 'BufReadPre', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = { char = '│' },
      scope = { enabled = false }, -- disable in favour of mini-indentscope
      exclude = {
        filetypes = {
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
  },
  -- mini-indentscope (https://github.com/echasnovski/mini.indentscope)
  {
    'echasnovski/mini.indentscope',
    enabled = not_vscode,
    event = { 'BufReadPre', 'BufNewFile' },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'help',
          'terminal',
          'toggleterm',
          'lazy',
          'mason',
          'markdown',
          'NvimTree',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
    opts = function()
      local indent = require('mini.indentscope')
      return {
        symbol = '│',
        options = { try_as_border = true },
        draw = {
          animation = indent.gen_animation.none(),
          delay = 0,
        },
      }
    end,
  },
  -- nvim-tree (https://github.com/nvim-tree/nvim-tree.lua)
  {
    'nvim-tree/nvim-tree.lua',
    enabled = not_vscode,
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
        root_folder_label = false,
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
      trash = { cmd = 'trash' },
      view = { side = 'right' },
    },
  },
  -- oil.nvim (https://github.com/stevearc/oil.nvim)
  {
    'stevearc/oil.nvim',
    keys = {
      { '<leader>of', ":lua require('oil').open_float()<CR>", desc = 'Oil' },
    },
    opts = {
      keymaps = {
        ['<C-v>'] = 'actions.select_vsplit',
        ['<C-s>'] = 'actions.select_split',
        ['<Esc>'] = 'actions.close',
      },
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 5,
      },
    },
  },
  -- barbar.nvim (https://github.com/romgrk/barbar.nvim)
  {
    'romgrk/barbar.nvim',
    enabled = not_vscode,
    event = 'VeryLazy',
    keys = {
      {
        '<leader>w',
        ':BufferDelete<cr>',
        desc = 'Close current buffer',
      },
      {
        '<leader>W',
        ':BufferCloseAllButCurrent<cr>',
        desc = 'Close all but current buffer',
      },
    },
    opts = {
      animation = false,
      auto_hide = 1,
      icons = {
        filetype = { enabled = false },
        button = '×',
        modified = { button = '*' },
        separator = { left = '', right = '' },
        separator_at_end = false,
        maximum_length = 10,
        inactive = {
          separator = { left = '', right = '' },
        },
      },
      sidebar_filetypes = { NvimTree = true },
    },
  },
  -- nvim-colorizer (https://github.com/NvChad/nvim-colorizer.lua)
  {
    'NvChad/nvim-colorizer.lua',
    enabled = not_vscode,
    event = 'BufReadPre',
    opts = {
      filetypes = {
        '*',
        css = {
          hsl_fn = true,
          rgb_fn = true,
        },
      },
      user_default_options = { mode = 'background', names = false, tailwind = true },
    },
  },
  -- which-key (https://github.com/folke/which-key.nvim)
  {
    'folke/which-key.nvim',
    enabled = not_vscode,
    event = 'VeryLazy',
    opts = {
      window = {
        margin = { 0, 0, 0, 0 },
      },
      plugins = {
        spelling = { enabled = true },
      },
      show_help = false,
    },
  },
  -- toggleterm (https://github.com/akinsho/toggleterm.nvim)
  {
    'akinsho/toggleterm.nvim',
    enabled = not_vscode,
    event = 'VeryLazy',
    keys = {
      {
        '<leader>lg',
        function()
          local Terminal = require('toggleterm.terminal').Terminal
          local lazygit = Terminal:new({
            cmd = 'lazygit',
            hidden = true,
            direction = 'float',
            float_opts = {
              border = 'none',
            },
            on_open = function(_)
              vim.cmd('startinsert!')
            end,
            on_close = function(_) end,
            count = 99,
          })
          lazygit:toggle()
        end,
        desc = 'LazyGit',
      },
    },
  },
  -- lsp
  {
    'neovim/nvim-lspconfig',
    name = 'lsp',
    enabled = not_vscode,
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'astro',
          'cssls',
          'emmet_ls',
          'html',
          'svelte',
          'tailwindcss',
          'tsserver',
        },
        automatic_installation = true,
      })

      local function on_attach(_, bufnr)
        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = opts.buffer or bufnr
          opts.silent = opts.silent or true
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- map("n", "K", vim.lsp.buf.hover, { desc = "Documenation" })
        map('n', '<leader>a', vim.lsp.buf.code_action, { desc = 'Code actions' })
        map('n', '<leader>r', vim.lsp.buf.rename, { desc = 'Rename symbol' })
        map('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto declaration' })
        map('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto definition' })
        map('n', 'gt', vim.lsp.buf.type_definition, { desc = 'Goto type definition' })
        map('n', 'gi', vim.lsp.buf.implementation, { desc = 'Goto implementation' })
        map('n', 'gr', vim.lsp.buf.references, { desc = 'Goto references' })
        map('n', 'gl', vim.diagnostic.open_float, { desc = 'Diagnostics' })
        map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
        map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if has_cmp_nvim_lsp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      require('mason-lspconfig').setup_handlers({
        function(server_name)
          require('lspconfig')[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
        ['lua_ls'] = function()
          require('lspconfig').lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = { diagnostics = { globals = { 'vim' } } },
            },
          })
        end,
        ['emmet_ls'] = function()
          require('lspconfig').emmet_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = { 'html', 'javascript', 'javascriptreact', 'svelte' },
            init_options = {
              javascript = {
                options = {
                  jsx = { enabled = true },
                  ['markup.attributes'] = { class = 'className' },
                },
              },
            },
          })
        end,
      })
    end,
  },
  -- luasnip
  {
    'L3MON4D3/LuaSnip',
    lazy = false,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
  -- completions
  {
    'hrsh7th/nvim-cmp',
    enabled = not_vscode,
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'onsails/lspkind-nvim',
    },
    config = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')
      cmp.setup({
        -- window = {
        --   documentation = cmp.config.window.bordered(),
        --   completion = cmp.config.window.bordered(),
        -- },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<c-space>'] = cmp.mapping.complete({ select = true }),
          ['<cr>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<C-j>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end,
          ['<C-k>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer',  keyword_length = 2 },
          { name = 'path' },
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = 'text',
            menu = {
              buffer = '[buf]',
              nvim_lsp = '[LSP]',
              path = '[path]',
              luasnip = '[snip]',
            },
          }),
        },
      })
    end,
  },
  -- none-ls
  {
    'nvimtools/none-ls.nvim',
    enabled = not_vscode,
    event = 'BufReadPre',
    config = function()
      local null_ls = require('null-ls')
      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

      local function format_on_save(client, bufnr)
        if client.supports_method('textDocument/formatting') then
          vim.api.nvim_clear_autocmds({
            group = augroup,
            buffer = bufnr,
          })
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettierd.with({
            extra_filetypes = { 'jsonc', 'astro', 'svelte' },
            env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand('~/.config/.prettierrc.json') },
          }),
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.fish_indent,
          null_ls.builtins.completion.spell,
        },
        on_attach = format_on_save,
      })
    end,
  },
  -- flash.nvim (https://github.com/folke/flash.nvim)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      prompt = {
        enabled = false,
      },
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
    },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'o', 'x' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Flash Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },
  -- zen-mode.nvim (https://github.com/folke/zen-mode.nvim)
  {
    'folke/zen-mode.nvim',
    enabled = not_vscode,
    cmd = 'ZenMode',
    keys = { { '<leader>z', ':ZenMode<cr>', desc = 'Zen mode' } },
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
      },
      on_open = function()
        vim.cmd('IBLDisable')
        vim.b.miniindentscope_disable = true
      end,
      on_close = function()
        vim.cmd('IBLEnable')
        vim.b.miniindentscope_disable = false
      end,
    },
  },
  -- markdown preview
  {
    'toppair/peek.nvim',
    enables = not_vscode,
    event = { 'VeryLazy' },
    build = 'deno task --quiet build:fast',
    keys = {
      { '<leader>op', ':PeekOpen<cr>', desc = 'Peek' },
    },
    config = function()
      require('peek').setup({
        app = 'browser',
      })
      vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
      vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end,
  },
  -- diffview.nvim (https://github.com/sindrets/diffview.nvim)
  {
    'sindrets/diffview.nvim',
    enabled = not_vscode,
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    keys = {
      { '<leader>dvo', ':DiffviewOpen<cr>',  desc = 'DiffView open' },
      { '<leader>dvc', ':DiffviewClose<cr>', desc = 'Diffview close' },
    },
    config = true,
    opts = {
      file_panel = {
        listing_style = 'list',
        win_config = {
          position = 'right',
          width = 35,
        },
      },
    },
  },
  -- obsidian.nvim (https://github.com/epwalsh/obsidian.nvim)
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    event = {
      'BufReadPre ' .. vim.fn.expand('~') .. '/Documents/notes/**.md',
      'BufNewFile ' .. vim.fn.expand('~') .. '/Documents/notes/**.md',
    },
    opts = {
      dir = '~/Documents/notes',
      completion = { nvim_cmp = true },
      mappings = {
        ['gf'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },
      disable_frontmatter = true,
      open_app_foreground = true,
    },
  },
  -- navigator.nvim (https://github.com/numToStr/Navigator.nvim)
  {
    'numToStr/Navigator.nvim',
    enabled = not_vscode,
    lazy = false,
    keys = {
      {
        '<C-h>',
        '<cmd>NavigatorLeft<cr>',
        mode = { 'n', 't' },
      },
      {
        '<C-l>',
        '<cmd>NavigatorRight<cr>',
        mode = { 'n', 't' },
      },
      {
        '<C-k>',
        '<cmd>NavigatorUp<cr>',
        mode = { 'n', 't' },
      },
      {
        '<C-j>',
        '<cmd>NavigatorDown<cr>',
        mode = { 'n', 't' },
      },
      {
        '<C-\\>',
        '<cmd>NavigatorPrevious<cr>',
        mode = { 'n', 't' },
      },
    },
    opts = {},
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
}

require('lazy').setup(plugins, {
  defaults = { lazy = true },
})
