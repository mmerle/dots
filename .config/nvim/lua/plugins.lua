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

-- plugin configs
local plugins = {
  -- interface
  {
    'numToStr/Comment.nvim',
    enabled = not_vscode,
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
  {
    'windwp/nvim-autopairs',
    enabled = not_vscode,
    event = 'BufReadPre',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },
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
        '<leader>d',
        ':Telescope diagnostics<cr>',
        desc = 'Diagnostics',
      },
      {
        '<leader>b',
        ':Telescope buffers<cr>',
        desc = 'Find buffers',
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
          find_files = {
            theme = 'dropdown',
            previewer = false,
            disable_devicons = true,
            hidden = true,
          },
          buffers = { theme = 'dropdown', previewer = false, disable_devicons = true },
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
          spelling = { enabled = true },
        },
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

  -- lsp
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

  -- completions
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
          { name = 'buffer',  keyword_length = 2 },
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

  -- formatters
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
          function()
          end,
        },
      })
    end,
  },

  -- other
  {
    'ggandor/leap.nvim',
    event = 'VeryLazy',
    config = function()
      require('leap').add_default_mappings(true)
    end,
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
}

require('lazy').setup(plugins, { change_detection = { notify = false } })
