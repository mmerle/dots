return {
  -- flora
  {
    dir = '~/Developer/projects/p/flora/flora.nvim',
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
      'windwp/nvim-ts-autotag',
      'kevinhwang91/promise-async',
      -- 'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        ignore_install = { 'phpdoc' },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        -- textobjects = {
        --   select = {
        --     enable = true,
        --     lookahead = true,
        --     keymaps = {
        --       ['af'] = '@function.outer',
        --       ['if'] = '@function.inner',
        --     },
        --   },
        -- },
      })
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
    keys = {
      { '<leader>on', '<cmd>ObsidianNew<cr>', desc = 'New Note' },
      { '<leader>op', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Quick Switch' },
      { '<leader>o/', '<cmd>ObsidianSearch<cr>', desc = 'Search Notes' },
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
      {
        '<C-h>',
        '<cmd>NavigatorLeft<cr>',
        mode = { 'n', 't' },
      },
      {
        '<C-l>',
        '<cmd>NavigatorRight<cr>',
        mode = { 'n', 't' },
      },
      {
        '<C-k>',
        '<cmd>NavigatorUp<cr>',
        mode = { 'n', 't' },
      },
      {
        '<C-j>',
        '<cmd>NavigatorDown<cr>',
        mode = { 'n', 't' },
      },
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
  -- gen.nvim (https://github.com/David-Kunz/gen.nvim)
  {
    'David-Kunz/gen.nvim',
    cmd = 'Gen',
    opts = {
      model = 'codestral',
      display_mode = 'split',
      show_model = true,
      no_auto_close = true,
    },
    config = function(_, opts)
      require('gen').setup(opts)
      require('gen').prompts['Fix_Code'] = {
        prompt = 'Fix the following code. Only ouput the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```',
        replace = true,
        extract = '```$filetype\n(.-)```',
      }
    end,
  },
}
