return {
  -- nvim-treesitter (https://github.com/nvim-treesitter/nvim-treesitter)
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = not_vscode,
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'windwp/nvim-ts-autotag',
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        ignore_install = { 'phpdoc' },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
            },
          },
        },
      })
    end,
  },
  -- nvim-treesitter-context
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPre',
    opts = {
      max_lines = 1,
      mode = 'cursor',
    },
  },

  -- flash.nvim (https://github.com/folke/flash.nvim)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      prompt = {
        enabled = false,
      },
      modes = {
        search = { enabled = false },
        char = { enabled = false },
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
  -- markdown preview
  {
    'toppair/peek.nvim',
    enables = not_vscode,
    event = { 'VeryLazy' },
    build = 'deno task --quiet build:fast',
    keys = {
      { '<leader>op', '<cmd>PeekOpen<cr>', desc = 'Preview markdown' },
    },
    config = function()
      require('peek').setup({
        app = 'browser',
      })
      vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
      vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end,
  },
  -- obsidian.nvim (https://github.com/epwalsh/obsidian.nvim)
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    event = {
      'BufReadPre ' .. vim.fn.expand('~') .. '/Documents/notes/**.md',
      'BufNewFile ' .. vim.fn.expand('~') .. '/Documents/notes/**.md',
    },
    opts = {
      dir = '~/Documents/notes',
      completion = { nvim_cmp = true },
      mappings = {
        ['gf'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },
      disable_frontmatter = true,
      open_app_foreground = true,
      daily_notes = {
        folder = '/daily',
        date_format = '%y-%m-%d',
      },
    },
  },
}
