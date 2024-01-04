return {
  -- lspconfig
  {
    'neovim/nvim-lspconfig',
    name = 'lsp',
    enabled = not_vscode,
    event = 'BufEnter',
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
          'lua_ls',
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

        -- map("n", "K", vim.lsp.buf.hover, { desc = "Documentation" })
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
        ['tailwindcss'] = function()
          require('lspconfig').tailwindcss.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            hovers = true,
            suggestions = true,
            root_dir = function(fname)
              local root_pattern =
                require('lspconfig').util.root_pattern('tailwind.config.cjs', 'tailwind.config.js', 'postcss.config.js')
              return root_pattern(fname)
            end,
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
}
