return {
  -- lspconfig
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      local function on_attach()
        local m = vim.keymap.set
        m('n', 'gh', vim.lsp.buf.hover, { desc = 'Documentation' })
        m('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
        m('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
        m('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto declaration' })
        m('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto definition' })
        m('n', 'gt', vim.lsp.buf.type_definition, { desc = 'Goto type definition' })
        m('n', 'gi', vim.lsp.buf.implementation, { desc = 'Goto implementation' })
        m('n', 'gr', vim.lsp.buf.references, { desc = 'Goto references' })
        m('n', 'gl', vim.diagnostic.open_float, { desc = 'Diagnostics' })
        m('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
        m('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
      end

      vim.lsp.config('*', {
        on_attach = on_attach,
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      })

      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'ts_ls', 'html', 'cssls', 'emmet_ls', 'astro', 'tailwindcss', 'svelte' },
      })
    end,
  },

  -- conform.nvim
  {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = function()
      return {
        notify_on_error = false,
        default_format_opts = {
          lsp_format = 'fallback',
        },
        formatters_by_ft = {
          fish = { 'fish_indent' },
          lua = { 'stylua' },
          -- biome (default)
          javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          javascriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          typescript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          json = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          jsonc = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          css = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          graphql = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
          -- prettier
          vue = { 'prettierd', 'prettier', stop_after_first = true },
          scss = { 'prettierd', 'prettier', stop_after_first = true },
          less = { 'prettierd', 'prettier', stop_after_first = true },
          html = { 'prettierd', 'prettier', stop_after_first = true },
          markdown = { 'prettierd', 'prettier', stop_after_first = true },
          yaml = { 'prettierd', 'prettier', stop_after_first = true },
          -- prettier (via extensions)
          astro = { 'prettierd', 'prettier', stop_after_first = true },
          svelte = { 'prettierd', 'prettier', stop_after_first = true },
          php = { 'prettierd', 'prettier', stop_after_first = true },
        },
        format_on_save = {
          lsp_format = 'fallback',
          async = false,
          timeout_ms = 500,
        },
        formatters = {
          biome = {
            command = 'biome',
            args = function()
              local global_config = vim.fn.expand('~/.config/biome/biome.json')
              local project_config = vim.fs.find('biome.json', {
                upward = true,
                type = 'file',
                path = vim.fn.expand('%:p:h'),
              })[1]

              if project_config then
                return { 'format', '--config-path', project_config, '--stdin-file-path', '$FILENAME' }
              else
                return { 'format', '--config-path', global_config, '--stdin-file-path', '$FILENAME' }
              end
            end,
            stdin = true,
          },
          prettier = {
            command = 'prettierd',
            args = function(ctx)
              local prettier_config_cache = {}
              local function get_prettier_config(ctx)
                if not ctx or not ctx.dirname then return nil end

                local global_config = vim.fn.expand('~/.config/.prettierrc')

                if vim.fn.filereadable(global_config) ~= 1 then return nil end

                local project_config = vim.fs.find(
                  function(name) return name:match('^%.?prettier.*') ~= nil end,
                  { upward = true, path = ctx.dirname, type = 'file' }
                )[1]

                return project_config or global_config
              end

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
