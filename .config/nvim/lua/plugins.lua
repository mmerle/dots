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
  --------------------------------------------------------------------------------------------------
  -- interface
  --------------------------------------------------------------------------------------------------

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
    config = function()
      require('nvim-surround').setup({
        keymaps = {
          insert = '<C-g>z',
          insert_line = 'gC-ggZ',
          normal = 'gz',
          normal_cur = 'gZ',
          normal_line = 'gzgz',
          normal_cur_line = 'gZgZ',
          visual = 'gz',
          visual_line = 'gZ',
          delete = 'gzd',
          change = 'gzc',
        },
      })
    end,
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
    event = 'BufReadPre',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },
  -- nvim-treesitter (https://github.com/nvim-treesitter/nvim-treesitter)
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = not_vscode,
    build = ':TSUpdate',
    event = 'BufReadPost',
    dependencies = {
      'windwp/nvim-ts-autotag',
      'kevinhwang91/nvim-ufo',
      'kevinhwang91/promise-async',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        ensure_installed = 'all',
        ignore_install = { 'phpdoc' },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
      })

      require('ufo').setup({
        provider_selector = function()
          return { 'treesitter', 'indent' }
        end,
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    enabled = not_vscode,
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
        desc = 'Options',
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
          file_ignore_patterns = { '.git/', 'node_modules' },
          layout_config = {
            prompt_position = 'top',
            horizontal = { preview_width = 0.6, height = 0.6 },
          },
          -- find_command = { 'fd', '-t', 'f', '-H', '-E', '.git', '--strip-cwd-prefix' },
          find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
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
          },
          buffers = {
            theme = 'dropdown',
            previewer = false,
            disable_devicons = true,
            ignore_current_buffer = true,
            sort_lastused = true,
          },
        },
      })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    enabled = not_vscode,
    dependencies = 'nvim-lua/plenary.nvim',
    event = 'BufReadPre',
    keys = {
      {
        '<leader>gsp',
        ':Gitsigns preview_hunk<cr>',
        desc = 'Git preview hunk',
      },
      {
        '<leader>gsr',
        ':Gitsigns reset_hunk<cr>',
        desc = 'Git reset hunk',
      },
    },
    config = function()
      require('gitsigns').setup()
      require('scrollbar.handlers.gitsigns').setup()
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = not_vscode,
    event = 'BufReadPre',
    config = function()
      require('indent_blankline').setup({
        show_current_context = true,
        show_end_of_line = true,
        filetype_exclude = { 'terminal', 'packer', 'help', 'markdown' },
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    enabled = not_vscode,
    lazy = false,
    keys = {
      {
        '<leader>e',
        '<cmd>NvimTreeFindFileToggle<cr>',
        desc = 'Toggle file tree',
      },
    },
    config = function()
      require('nvim-tree').setup({
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
      })
    end,
  },
  {
    'echasnovski/mini.tabline',
    enabled = not_vscode,
    version = false,
    event = 'VeryLazy',
    config = function()
      require('mini.tabline').setup({
        show_icons = false,
      })
    end,
  },
  {
    'norcalli/nvim-colorizer.lua',
    enabled = not_vscode,
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
    enabled = not_vscode,
    event = 'VeryLazy',
    config = function()
      require('which-key').setup({
        window = {
          margin = { 0, 0, 0, 0 },
        },
        plugins = {
          spelling = true,
        },
        show_help = false,
      })
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    enabled = not_vscode,
    version = '*',
    config = function()
      require('toggleterm').setup()
    end,
  },

  --------------------------------------------------------------------------------------------------
  -- lsp
  --------------------------------------------------------------------------------------------------

  {
    'neovim/nvim-lspconfig',
    enabled = not_vscode,
    event = 'BufReadPre',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-tool-installer').setup({})
      require('mason-lspconfig').setup({})

      local function on_attach(_, bufnr)
        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = opts.buffer or bufnr
          opts.silent = opts.silent or true
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
        map('n', '<leader>a', vim.lsp.buf.code_action, { desc = 'Code actions' })
        map('n', '<leader>r', vim.lsp.buf.rename, { desc = 'Rename symbol' })
        -- map("n", "K", vim.lsp.buf.hover, { desc = "Documenation" })
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
      capabilities.offsetEncoding = { 'utf-16' }

      -- Improve compatibility with nvim-cmp completions
      local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if has_cmp_nvim_lsp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Setup servers installed via `:MasonInstall`
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
      })
    end,
  },

  --------------------------------------------------------------------------------------------------
  -- completions
  --------------------------------------------------------------------------------------------------

  {
    'hrsh7th/nvim-cmp',
    enabled = not_vscode,
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'windwp/nvim-autopairs',
      'onsails/lspkind-nvim',
    },
    event = 'InsertEnter',
    config = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')

      cmp.setup({
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
          { name = 'luasnip' },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer', keyword_length = 2 },
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

  --------------------------------------------------------------------------------------------------
  -- formatters
  --------------------------------------------------------------------------------------------------

  {
    'jose-elias-alvarez/null-ls.nvim',
    enabled = not_vscode,
    event = 'BufReadPre',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'jay-babu/mason-null-ls.nvim',
    },
    config = function()
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

      require('null-ls').setup({
        sources = {
          require('null-ls').builtins.formatting.prettierd.with({
            extra_filetypes = { 'jsonc', 'astro', 'svelte' },
            env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand('~/.config/.prettierrc.json') },
          }),
          require('null-ls').builtins.formatting.stylua,
          require('null-ls').builtins.formatting.fish_indent,
          require('null-ls').builtins.completion.spell,
        },
        on_attach = format_on_save,
      })

      require('mason-null-ls').setup({
        automatic_setup = true,
        handlers = {
          function() end,
        },
      })
    end,
  },

  --------------------------------------------------------------------------------------------------
  -- other
  --------------------------------------------------------------------------------------------------

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      prompt = {
        enabled = false,
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
  {
    'folke/zen-mode.nvim',
    enabled = not_vscode,
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
        gitsigns = true,
        kitty = { enabled = false, font = '+2' },
      },
    },
  },
  {
    'petertriho/nvim-scrollbar',
    enabled = not_vscode,
    event = 'BufReadPre',
    config = function()
      require('scrollbar').setup({
        set_highlights = false,
        marks = {
          Cursor = {
            text = '',
          },
        },
        handlers = {
          cursor = false,
        },
      })
    end,
  },
}

require('lazy').setup(plugins, {
  defaults = { lazy = true },
  change_detection = { notify = false },
  ui = {
    icons = {
      cmd = '⚡︎ ',
      config = '⚡︎',
      event = '⚡︎',
      ft = '⚡︎ ',
      init = '! ',
      import = '! ',
      keys = '! ',
      lazy = '! ',
      loaded = '●',
      not_loaded = '○',
      plugin = '! ',
      runtime = '! ',
      source = '! ',
      start = '!',
      task = '✔ ',
      list = {
        '●',
        '➜',
        '★',
        '‒',
      },
    },
  },
})
