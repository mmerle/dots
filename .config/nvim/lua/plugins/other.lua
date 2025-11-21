return {
  -- flora
  {
    dir = '~/Developer/projects/flora/nvim',
    name = 'flora',
    lazy = false,
    priority = 1000,
    config = function() vim.cmd([[colorscheme flora]]) end,
  },
  -- nvim-treesitter (https://github.com/nvim-treesitter/nvim-treesitter)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'kevinhwang91/promise-async',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        ignore_install = { 'ipkg' },
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = false,
            scope_incremental = false,
            node_incremental = '.',
            node_decremental = ',',
          },
        },
        indent = { enable = true },
      })
    end,
  },
  -- nvim-ts-autotag (https://github.com/windwp/nvim-ts-autotag)
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
  -- obsidian.nvim (https://github.com/obsidian-nvim/obsidian.nvim)
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*',
    event = {
      'BufReadPre ' .. vim.fn.expand('~') .. '/Documents/notes/**.md',
      'BufNewFile ' .. vim.fn.expand('~') .. '/Documents/notes/**.md',
    },
    keys = {
      { '<leader>on', '<cmd>ObsidianNew<cr>',         desc = 'New Note' },
      { '<leader>op', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Quick Switch' },
      { '<leader>o/', '<cmd>ObsidianSearch<cr>',      desc = 'Search Notes' },
    },
    opts = {
      dir = '~/Documents/notes',
      completion = { nvim_cmp = true },
      mappings = {
        ['gf'] = {
          action = function() return require('obsidian').util.gf_passthrough() end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },
      disable_frontmatter = true,
      open_app_foreground = true,
      attachments = {
        img_folder = 'attachments/images',
      },
      daily_notes = {
        folder = '/daily',
        date_format = '%y-%m-%d',
      },
      ui = {
        checkboxes = {
          [' '] = { char = '▢', hl_group = 'ObsidianTodo' },
          ['x'] = { char = '✓', hl_group = 'ObsidianDone' },
        },
        bullets = { char = '-', hl_group = 'ObsidianBullet' },
        external_link_icon = { char = '↗', hl_group = 'ObsidianExtLinkIcon' },
      },
    },
  },
  -- navigator.nvim (https://github.com/numToStr/Navigator.nvim)
  {
    'numToStr/Navigator.nvim',
    keys = {
      { '<C-h>', '<cmd>NavigatorLeft<cr>',  mode = { 'n' } },
      { '<C-j>', '<cmd>NavigatorDown<cr>',  mode = { 'n' } },
      { '<C-k>', '<cmd>NavigatorUp<cr>',    mode = { 'n' } },
      { '<C-l>', '<cmd>NavigatorRight<cr>', mode = { 'n' } },
    },
    opts = {
      disable_on_zoom = true,
    },
  },
  -- cloak.nvim (https://github.com/laytan/cloak.nvim)
  {
    'laytan/cloak.nvim',
    cmd = { 'CloakEnable', 'CloakToggle' },
    opts = {
      enabled = true,
      cloak_character = '*',
    },
  },
  -- harpoonline (https://github.com/abeldekat/harpoonline)
  {
    'abeldekat/harpoonline',
    event = { 'BufReadPost', 'BufNewFile' },
    version = '*',
    config = function()
      local Harpoonline = require('harpoonline')
      Harpoonline.setup({
        on_update = function() vim.cmd.redrawstatus() end
      })
    end,
  }
}
