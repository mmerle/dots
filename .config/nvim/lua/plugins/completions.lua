-- setup completions
return {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'windwp/nvim-autopairs',
      'onsails/lspkind-nvim',
    },
    event = 'BufReadPre',
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
}
