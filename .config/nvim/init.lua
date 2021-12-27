local function map(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  return vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

vim.g.mapleader = ' '

map('n', '<esc>', ':noh<cr>') -- clear match highlights on escape
map('n', '<leader>r', ':source ~/.config/nvim/init.lua<cr>')
map('n', '<leader>e', ':NvimTreeToggle<cr>')
map('n', '<leader>p', [[:lua require('telescope.builtin').find_files()<cr>]])
map('n', '<leader><cr>', ':ZenMode<cr>')
map('n', '<leader>s', ':w<cr>') -- quick save
map('n', '<leader>q', ':q<cr>') -- quick quit
map('n', 'gt', ':BufferNext<cr>')
map('n', 'gT', ':BufferPrevious<cr>')
map('v', '<', '<gv')
map('v', '>', '>gv')
map('n', '<leader>w', ':BufferClose<cr>')
map('n', '<leader>ki', ':PackerInstall<cr>')
map('n', '<leader>kc', ':PackerCompile<cr>')
map('n', '<leader>ks', ':PackerSync<cr>')

vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300
vim.opt.undofile = true
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
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.pumheight = 10
vim.opt.termguicolors = true

-- plugins
require('packer').startup(function(use)
  use('wbthomason/packer.nvim')
  use('tpope/vim-commentary')
  use('b0o/schemastore.nvim')
  use('tweekmonster/startuptime.vim')
  -- use('github/copilot.vim')
  use({
    'mmerle/flora-neovim',
    as = 'flora',
    config = function()
      vim.g.flora_disable_italics = false
      vim.cmd('colorscheme flora')
    end,
  })
  use({
    'nvim-telescope/telescope.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git/', '.next/', '.DS_Store' },
          layout_config = { horizontal = { preview_width = 0.6 } },
          find_command = { 'rg', '--hidden', '--follow' },
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
            hidden = true,
            theme = 'dropdown',
            previewer = false,
          },
        },
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
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {
      'nvim-treesitter/playground',
      'windwp/nvim-ts-autotag',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'maintained',
        ignore_install = { 'haskell' },
        indent = { enable = true },
        autotag = { enable = true },
        highlight = { enable = true },
        context_commentstring = { enable = true, enable_autocmd = false },
        playground = { enable = true },
      })
    end,
  })
  use({
    'neovim/nvim-lspconfig',
    requires = { 'folke/lua-dev.nvim' },
    config = function()
      local function on_attach(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false

        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        local function buf_map(mode, lhs, rhs, opts)
          opts = opts or { noremap = true, silent = true }
          vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        end

        buf_map('n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
        buf_map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
        buf_map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
        buf_map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
        buf_map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
        buf_map('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
        buf_map('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<cr>')
        buf_map('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>')
        buf_map('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<cr>')
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

      local lspconfig = require('lspconfig')
      lspconfig.sumneko_lua.setup(require('lua-dev').setup({
        lspconfig = {
          cmd = {
            vim.fn.getenv('HOME')
              .. '/.local/share/lua-language-server/bin/macOS/lua-language-server',
          },
          on_attach = on_attach,
          capabilities = capabilities,
        },
      }))

      local servers = { 'html', 'jsonls', 'cssls', 'tailwindcss', 'tsserver', 'svelte' }
      for _, server in ipairs(servers) do
        local opts = {}

        if server == 'jsonls' then
          opts = {
            filetypes = { 'json', 'jsonc' },
            settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
              },
            },
          }
        end

        lspconfig[server].setup(vim.tbl_deep_extend('force', {
          on_attach = on_attach,
          capabilities = capabilities,
        }, opts))
      end
    end,
  })
  use({
    'jose-elias-alvarez/null-ls.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      local null_ls = require('null-ls')
      local prettier_filetypes = null_ls.builtins.formatting.prettier.filetypes
      table.insert(prettier_filetypes, 'jsonc')
      table.insert(prettier_filetypes, 'svelte')

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.fish_indent,
          null_ls.builtins.formatting.prettierd.with({ filetypes = prettier_filetypes }),
          null_ls.builtins.formatting.shfmt.with({ filetypes = { 'bash', 'sh', 'zsh' } }),
          null_ls.builtins.formatting.stylua,
        },
        on_attach = function(client)
          if client.resolved_capabilities.document_formatting then
            vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]])
          end
        end,
      })
    end,
  })
  use({
    'hrsh7th/nvim-cmp',
    requires = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'windwp/nvim-autopairs',
      'onsails/lspkind-nvim',
    },
    config = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')

      cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())

      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<c-space>'] = cmp.mapping.complete(),
          ['<cr>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<c-e>'] = cmp.mapping.abort(),
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
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        sources = {
          { name = 'nvim_lsp', keyword_length = 2 },
          { name = 'path' },
          { name = 'buffer', keyword_length = 2 },
        },
        formatting = {
          format = lspkind.cmp_format({
            with_text = true,
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
  })
  use({
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  })
  use({
    'mattn/emmet-vim',
    config = function()
      vim.g.user_emmet_leader_key = ','
    end,
  })
  use({
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup({
        '*',
        css = {
          hsl_fn = true,
          names = false,
        },
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
        filetype_exclude = { 'terminal', 'packer', 'help', 'markdown' },
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
        icon_separator_active = '',
        icon_separator_inactive = '',
        icons = false,
      }
    end,
  })
  use({
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup()
    end,
  })
  use({
    'folke/zen-mode.nvim',
    config = function()
      require('zen-mode').setup({
        window = {
          backdrop = 1,
          height = 0.85,
          width = 0.8,
          options = {
            number = false,
          },
        },
      })
    end,
  })
end)
