return {
  -- luasnip (https://github.com/L3MON4D3/LuaSnip)
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    event = 'InsertEnter',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
      local ls = require('luasnip')
      ls.config.setup({
        enable_autosnippets = true,
        region_check_events = 'InsertEnter',
        delete_check_events = 'InsertLeave'
      })
    end,
  },
  -- completions (https://github.com/hrsh7th/nvim-cmp)
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'onsails/lspkind-nvim',
    },
    config = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')
      cmp.setup({
        snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
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
          ['<C-y>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer',  keyword_length = 4 },
          { name = 'path' },
          { name = 'calc' },
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = 'text',
            menu = {
              buffer = '[buf]',
              nvim_lsp = '[lsp]',
              path = '[path]',
              luasnip = '[snip]',
              calc = '[calc]',
            },
          }),
        },
        performance = {
          debounce = 0,
          throttle = 0,
        },
      })

      -- `/` cmdline setup.
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })
    end,
  },
  -- comment (https://github.com/numToStr/Comment.nvim)
  {
    'numToStr/Comment.nvim',
    event = 'BufEnter',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
  -- mini.surround (https://github.com/echasnovski/mini.surround)
  {
    'echasnovski/mini.surround',
    version = false,
    event = 'VeryLazy',
    opts = {
      mappings = {
        add = 'gsa',
        delete = 'gsd',
        find = 'gsf',
        find_left = 'gsF',
        highlight = 'gsh',
        replace = 'gsr',
        update_n_lines = 'gsn',
      },
    },
  },
  -- ultimate-autopair (https://github.com/altermo/ultimate-autopair.nvim)
  {
    'altermo/ultimate-autopair.nvim',
    event = { 'InsertEnter', 'CmdlineEnter' },
    opts = {},
  },
  -- multicursor.nvim (https://jake-stewart/multicursor.nvim)
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
  },
  -- vim-repeat (https://github.com/tpope/vim-repeat)
  {
    'tpope/vim-repeat',
    event = 'VeryLazy',
  },
  -- mini.ai (https://github.com/echasnovski/mini.ai)
  {
    'echasnovski/mini.ai',
    version = false,
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    opts = function()
      local spec_treesitter = require('mini.ai').gen_spec.treesitter
      return {
        n_lines = 200,
        silent = true,
        search_method = 'cover_or_next',
        mappings = {
          around_last = '',
          inside_last = '',
        },
        custom_textobjects = {
          a = spec_treesitter({ a = '@assignment.outer', i = '@assignment.inner' }),
          -- b = spec_treesitter({ a = '@block.outer', i = '@block.inner' }),
          c = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
          f = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
          l = spec_treesitter({ a = '@loop.outer', i = '@loop.inner' }),
          m = spec_treesitter({ a = '@comment.outer', i = '@comment.inner' }),
          r = spec_treesitter({ a = '@return.outer', i = '@return.inner' }),
          s = spec_treesitter({ a = '@block_string.outer', i = '@block_string.inner' }),
        },
      }
    end,
  },
}
