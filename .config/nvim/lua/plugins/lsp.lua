return {
  -- lspconfig
  {
    'neovim/nvim-lspconfig',
    name = 'lsp',
    event = { 'BufReadPost', 'BufNewFile' },
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
        map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
        map('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
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
      if has_cmp_nvim_lsp then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end

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
            filetypes = { 'html', 'javascript', 'javascriptreact', 'svelte', 'astro', 'xhtml' },
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
  -- conform.nvim
  {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = function()
      local prettier_config_cache = {}

      local function get_prettier_config(ctx)
        if not ctx or not ctx.dirname then return nil end

        local global_config = vim.fn.expand('~/.config/.prettierrc.json')

        if vim.fn.filereadable(global_config) ~= 1 then return nil end

        local project_config = vim.fs.find(
          function(name) return name:match('^%.?prettier.*') ~= nil end,
          { upward = true, path = ctx.dirname, type = 'file' }
        )[1]

        return project_config or global_config
      end

      return {
        notify_on_error = false,
        formatters_by_ft = {
          fish = { 'fish_indent' },
          lua = { 'stylua' },

          -- prettier (default)
          javascript = { 'prettierd', 'prettier' },
          javascriptreact = { 'prettierd', 'prettier' },
          typescript = { 'prettierd', 'prettier' },
          typescriptreact = { 'prettierd', 'prettier' },
          vue = { 'prettierd', 'prettier' },
          css = { 'prettierd', 'prettier' },
          scss = { 'prettierd', 'prettier' },
          less = { 'prettierd', 'prettier' },
          html = { 'prettierd', 'prettier' },
          json = { 'prettierd', 'prettier' },
          jsonc = { 'prettierd', 'prettier' },
          graphql = { 'prettierd', 'prettier' },
          markdown = { 'prettierd', 'prettier' },
          yaml = { 'prettierd', 'prettier' },

          -- prettier (via extensions)
          astro = { 'prettierd', 'prettier' },
          svelte = { 'prettierd', 'prettier' },
        },
        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        },
        formatters = {
          prettier = {
            command = 'prettierd',
            args = function(ctx)
              local filepath = vim.api.nvim_buf_get_name(0)
              local dirname = vim.fn.fnamemodify(filepath, ':h')
              ctx.dirname = dirname

              local config = get_prettier_config(ctx)
              if not config then return { '--stdin-filepath', filepath } end
              return {
                '--config',
                config,
                '--stdin-filepath',
                filepath,
              }
            end,
            cwd = function(ctx)
              return vim.fn.fnamemodify(vim.fs.find({ 'package.json', '.git' }, {
                upward = true,
                stop = vim.loop.os_homedir(),
                path = ctx.dirname,
              })[1] or ctx.dirname, ':h')
            end,
          },
        },
      }
    end,
  },
}
