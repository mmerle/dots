-- setup formatters
return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = 'BufReadPre',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'jayp0521/mason-null-ls.nvim',
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

      require('mason-null-ls').setup({ automatic_setup = true })
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
      require('mason-null-ls').setup_handlers()
    end,
  },
}
