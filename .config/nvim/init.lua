local opts = { silent = true }

vim.g.mapleader = ' '
vim.keymap.set('n', '<space>', '<nop>', opts)

--- KEYMAPS
vim.keymap.set({ 'n', 'v' }, 'j', 'gj', opts) -- move through wrapped lines
vim.keymap.set({ 'n', 'v' }, 'k', 'gk', opts) -- move through wrapped lines
vim.keymap.set('v', '<', '<gv', opts) -- unindent (keep selection)
vim.keymap.set('v', '>', '>gv', opts) -- indent (keep selection)
vim.keymap.set('n', 'H', '^', opts) -- jump to first character of line
vim.keymap.set('n', 'L', 'g_', opts) -- jump to last character of line
vim.keymap.set('n', '<leader>s', ':w<cr>', opts) -- quick save
vim.keymap.set('n', '<leader>q', ':q<cr>', opts) -- quick quit

vim.keymap.set('n', '<esc>', ':noh<cr>', opts) -- clear search highlights
vim.keymap.set('n', '*', '*N', opts) -- search word under cursor (keep position)
vim.keymap.set('v', '*', [[y/\V<c-r>=escape(@",'/\')<cr><cr>N]], opts) -- search selection (keep position)

vim.keymap.set('n', '<leader>p', ':Telescope find_files<cr>', opts) -- searh files
vim.keymap.set('n', '<leader>f', ':Telescope live_grep<cr>', opts) -- searh text
vim.keymap.set('n', '<leader>e', ':NvimTreeFindFileToggle<cr>', opts) -- toggle file explorer
vim.keymap.set('n', '<leader><cr>', ':ZenMode<cr>', opts) -- toggle zenmode

-- window
vim.keymap.set('n', '<c-h>', '<c-w><c-h>', opts) -- jump to split left
vim.keymap.set('n', '<c-j>', '<c-w><c-j>', opts) -- jump to split below
vim.keymap.set('n', '<c-k>', '<c-w><c-k>', opts) -- jump to split above
vim.keymap.set('n', '<c-l>', '<c-w><c-l>', opts) -- jump to split right
vim.keymap.set('n', '<c-r>', '<c-w><c-r>', opts) -- swap split positions

-- goto
vim.keymap.set('n', 'g.', '`.', opts) -- goto last modification
vim.keymap.set('n', 'gp', ':bprev<cr>', opts) -- goto previous buffer
vim.keymap.set('n', 'gn', ':bnext<cr>', opts) -- goto next buffer
vim.keymap.set('n', 'gm', '%', opts) -- goto matching character: '()', '{}', '[]'

vim.keymap.set('n', '<leader>kc', ':PackerCompile<cr>', opts)
vim.keymap.set('n', '<leader>ks', ':PackerSync<cr>', opts)

vim.keymap.set('n', '<leader>w', ':BufferClose<cr>', opts) -- close current buffer
vim.keymap.set('n', '<leader>bo', ':BufferCloseAllButCurrent<cr>', opts) -- close all but current buffer

--- OPTIONS
vim.opt.clipboard = 'unnamedplus' -- enable universal clipboard
vim.opt.updatetime = 300

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.laststatus = 3
vim.opt.statusline = ' %f %M %= [%{expand(&filetype)}] %l:%c '
vim.opt.shortmess:append('c')

vim.opt.mouse = 'a' -- enable mouse
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.undofile = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 5

vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.cindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wildmode = 'longest:full,full'
vim.opt.pumheight = 5
vim.opt.completeopt = 'menu,menuone,noinsert'

vim.opt.title = true
vim.opt.titlestring = '%t — nvim'

vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '·' }

-- Stop 'o' continuing comments
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  command = 'setlocal formatoptions-=o',
})

--- PLUGINS
require('packer').startup(function(use)
  use('wbthomason/packer.nvim')
  use('tpope/vim-surround')
  use('tpope/vim-repeat')
  use('b0o/schemastore.nvim')
  use('fladson/vim-kitty')
  -- use('github/copilot.vim')
  use({
    'mmerle/flora-neovim',
    as = 'flora',
    config = function()
      vim.g.flora = false
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
          selection_caret = '  ',
          column_indent = 0,
          sorting_strategy = 'ascending',
          layout_strategy = 'horizontal',
          file_ignore_patterns = { '^.git$', 'node_modules', '.next', '.DS_Store' },
          layout_config = {
            prompt_position = 'top',
            horizontal = { preview_width = 0.6, height = 0.6 },
          },
          find_command = { 'fd', '--type', 'f', '-H', '-E', '.git', '--strip-cwd-prefix' },
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
  })
  use({
    'kyazdani42/nvim-tree.lua',
    config = function()
      require('nvim-tree').setup({
        actions = { open_file = { quit_on_open = true } },
        filters = {
          custom = { '^.git$', '.DS_Store', '^node_modules$' },
        },
        git = { ignore = false },
        view = {
          hide_root_folder = true,
          side = 'right',
        },
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
      })
    end,
  })
  use({
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = { 'nvim-treesitter/playground', 'windwp/nvim-ts-autotag' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        ignore_install = { 'phpdoc' },
        indent = { enable = true },
        autotag = { enable = true },
        highlight = { enable = true },
        playground = { enable = true },
      })
    end,
  })
  use({
    'neovim/nvim-lspconfig',
    requires = 'folke/lua-dev.nvim',
    config = function()
      local function on_attach(_, bufnr)
        local b_opts = { buffer = bufnr, silent = true }
        -- vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, b_opts)
        vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, b_opts)
        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, b_opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, b_opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, b_opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, b_opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, b_opts)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Improve compatibility with nvim-cmp completions
      local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if has_cmp_nvim_lsp then
        capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
      end

      local lspconfig = require('lspconfig')
      lspconfig.sumneko_lua.setup(require('lua-dev').setup({
        lspconfig = {
          on_attach = on_attach,
          capabilities = capabilities,
        },
      }))

      -- Language servers to setup. Servers must be available in your path.
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      local servers = { 'cssls', 'html', 'jsonls', 'svelte', 'tailwindcss', 'tsserver' }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          on_attach = on_attach,
          capabilities = capabilities,
        })
      end
    end,
  })
  use({
    'jose-elias-alvarez/null-ls.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.fish_indent,
          null_ls.builtins.formatting.prettierd.with({
            extra_filetypes = { 'svelte', 'jsonc' },
            env = {
              PRETTIERD_DEFAULT_CONFIG = vim.fn.expand('~/.prettierrc.json'),
            },
          }),
          null_ls.builtins.formatting.stylua,
        },
        on_attach = function(client, bufnr)
          if client.supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(lsp_client)
                    return lsp_client.name == 'null-ls'
                  end,
                })
              end,
            })
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
    'numToStr/Comment.nvim',
    config = function()
      require('comment').setup()
    end,
  })
  use({
    'mattn/emmet-vim',
    config = function()
      vim.g.user_emmet_mode = 'n'
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
      require('bufferline').setup({
        animation = false,
        icon_close_tab = 'x',
        icon_close_tab_modified = '•',
        icon_separator_active = '',
        icon_separator_inactive = '',
        icons = false,
      })
    end,
  })
  use({
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup({
        window = {
          margin = { 0, 0, 0, 0 },
        },
      })
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
