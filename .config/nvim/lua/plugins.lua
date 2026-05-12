local map = vim.keymap.set
local add = vim.pack.add
local now_if_args, later, on_filetype = Config.now_if_args, Config.later, Config.on_filetype

-- language setup
Config.Languages = {
  treesitter = {
    'astro', 'bash', 'c',
    'cpp', 'css', 'fish',
    'glsl', 'graphql', 'groq',
    'html', 'javascript', 'json',
    'jsx', 'lua', 'markdown',
    'php', 'query', 'regex',
    'scss', 'svelte', 'tsx',
    'twig', 'typescript', 'yaml',
  },
  mason = {
    'lua_ls', 'ts_ls', 'html', 'cssls', 'emmet_ls', 'astro', 'svelte',
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    fish = { 'fish_indent' },
    javascript = { 'biome', 'prettierd', 'prettier' },
    javascriptreact = { 'biome', 'prettierd', 'prettier' },
    typescript = { 'biome', 'prettierd', 'prettier' },
    typescriptreact = { 'biome', 'prettierd', 'prettier' },
    json = { 'biome', 'prettierd', 'prettier' },
    jsonc = { 'biome', 'prettierd', 'prettier' },
    css = { 'biome', 'prettierd', 'prettier' },
    scss = { 'prettierd', 'prettier' },
    html = { 'prettierd', 'prettier' },
    markdown = { 'prettierd', 'prettier' },
    php = { 'prettierd', 'prettier' },
    twig = { 'prettierd', 'prettier' },
    astro = { 'prettierd', 'prettier' },
    svelte = { 'prettierd', 'prettier' },
  }
}

-- nvim-treesitter (https://github.com/nvim-treesitter/nvim-treesitter)
-- nvim-treesitter-textobjects (https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')
  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local ensure_languages = Config.Languages.treesitter
  local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 end
  local to_install = vim.tbl_filter(isnt_installed, ensure_languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- ensure enabled
  local filetypes = vim.iter(ensure_languages):map(vim.treesitter.language.get_filetypes):flatten():totable()
  local ts_start = function(event) vim.treesitter.start(event.buf) end
  on_filetype(filetypes, ts_start, 'Ensure enabled tree-sitter')
end)

-- nvim-ts-autotag (https://github.com/windwp/nvim-ts-autotag)
now_if_args(function()
  add({ 'https://github.com/windwp/nvim-ts-autotag' })

  require('nvim-ts-autotag').setup({})
end)

-- nvim-treesitter-context (https://github.com/nvim-treesitter/nvim-treesitter-context)
later(function()
  add({ 'https://github.com/nvim-treesitter/nvim-treesitter-context' })

  require('treesitter-context').setup({
    enable = true,
    max_lines = 3,
    trim_scope = 'outer',
    min_window_height = 10,
    separator = '—',
  })
end)

-- LuaSnip (https://github.com/L3MON4D3/LuaSnip)
-- friendly-snippets (https://github.com/rafamadriz/friendly-snippets)
now_if_args(function()
  add({
    'https://github.com/L3MON4D3/LuaSnip',
    'https://github.com/rafamadriz/friendly-snippets',
  })

  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_lua').load({ paths = '~/.config/nvim/lua/snippets/' })
  require('luasnip').config.setup({
    enable_autosnippets = true,
    region_check_events = 'InsertEnter',
    delete_check_events = 'InsertLeave',
  })
end)

-- blink.cmp (https://github.com/saghen/blink.cmp)
now_if_args(function()
  add({ 'https://github.com/saghen/blink.lib' })
  add({ 'https://github.com/saghen/blink.cmp' })

  require('blink.cmp').setup({
    keymap = {
      preset = 'default',
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-y>'] = { 'select_and_accept', 'fallback' },
    },
    completion = {
      list = { selection = { preselect = true, auto_insert = false } },
      documentation = { auto_show = false },
      menu = { draw = { columns = { { 'label', 'label_description', gap = 1 }, { 'source_name' } } } },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        buffer = { min_keyword_length = 4 },
        cmdline = { enabled = function() return vim.fn.getcmdtype() == ':' end },
      },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'lua' },
    cmdline = {
      enabled = true,
      keymap = { preset = 'cmdline' },
    },
  })
end)

-- nvim-lspconfig (https://github.com/neovim/nvim-lspconfig)
now_if_args(function()
  add({ 'https://github.com/neovim/nvim-lspconfig' })

  vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities(nil, true) })
  Config.new_autocmd('LspAttach', '*', function(event)
    local function opts(desc) return { buffer = event.buf, desc = desc } end
    local function diagnostic_jump(count)
      return function() vim.diagnostic.jump({ count = count, float = true }) end
    end

    map('n', 'gh', vim.lsp.buf.hover, opts('Documentation'))
    map('n', '<leader>ca', vim.lsp.buf.code_action, opts('Code actions'))
    map('n', '<leader>cr', vim.lsp.buf.rename, opts('Rename symbol'))
    map('n', 'gD', vim.lsp.buf.declaration, opts('Goto declaration'))
    map('n', 'gd', vim.lsp.buf.definition, opts('Goto definition'))
    map('n', 'gt', vim.lsp.buf.type_definition, opts('Goto type definition'))
    map('n', 'gi', vim.lsp.buf.implementation, opts('Goto implementation'))
    map('n', 'gr', vim.lsp.buf.references, opts('Goto references'))
    map('n', 'gl', vim.diagnostic.open_float, opts('Diagnostics'))
    map('n', ']d', diagnostic_jump(1), opts('Next diagnostic'))
    map('n', '[d', diagnostic_jump(-1), opts('Previous diagnostic'))
  end)
end)

-- mason.nvim (https://github.com/mason-org/mason.nvim)
-- mason-lspconfig.nvim (https://github.com/mason-org/mason-lspconfig.nvim)
now_if_args(function()
  add({
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/mason-org/mason-lspconfig.nvim',
  })

  require('mason').setup()
  require('mason-lspconfig').setup({
    ensure_installed = Config.Languages.mason,
  })
end)

-- fzf-lua (https://github.com/ibhagwan/fzf-lua)
later(function()
  add({ 'https://github.com/ibhagwan/fzf-lua' })

  local fzf = require('fzf-lua')
  fzf.setup({
    keymap = {
      builtin = { ['<esc>'] = 'hide' },
      fzf = { ['ctrl-q'] = 'select-all+accept' },
    },
    fzf_opts = { ['--info'] = 'hidden', ['--gutter'] = ' ' },
    defaults = { file_icons = false, git_icons = false },
    winopts = {
      height = 0.6,
      width = 0.6,
      border = 'single',
      preview = { horizontal = 'right:70%', scrollbar = 'border', border = 'single' },
    },
    previewers = {
      builtin = { syntax_limit_b = 1024 * 1024, limit_b = 1024 * 1024, treesitter = { context = false } },
    },
    files = {
      formatter = 'path.filename_first',
      winopts = { height = 0.4, width = 0.4 },
      previewer = false,
      cwd_prompt = false,
      rg_opts = '--files --hidden -g !.git --color=never',
    },
    oldfiles = {
      formatter = 'path.filename_first',
      winopts = { height = 0.4, width = 0.4 },
      previewer = false,
      cwd_only = true,
      stat_file = true,
      include_current_session = true,
    },
    buffers = { winopts = { height = 0.4, width = 0.4 }, previewer = false, ignore_current_buffer = true },
    grep = {
      rg_opts =
      '--no-heading --hidden --with-filename --line-number --column --trim -g !.git -g !dist -g !build --smart-case --color=never',
    },
    spell_suggest = { winopts = { height = 0.33, width = 0.33, relative = 'cursor' } },
    hls = { normal = 'NormalFloat', preview_normal = 'NormalFloat', border = 'FloatBorder', preview_border = 'FloatBorder' },
    fzf_colors = {
      ['fg'] = { 'fg', 'Pmenu' },
      ['bg'] = { 'bg', 'Pmenu' },
      ['fg+'] = { 'fg', 'PmenuSel' },
      ['bg+'] = { 'bg', 'PmenuSel' },
      ['border'] = { 'fg', 'FloatBorder' },
      ['gutter'] = '-1',
    },
    file_icon_padding = '',
  })
  fzf.register_ui_select()
end)

map('n', '<leader>fr', '<cmd>FzfLua resume<cr>', { desc = 'Resume find' })
map('n', '<leader>p', '<cmd>FzfLua files<cr>', { desc = 'Find files' })
map('n', '<leader>/', '<cmd>FzfLua live_grep<cr>', { desc = 'Find text' })
map('n', '<leader>b', '<cmd>FzfLua buffers<cr>', { desc = 'Find buffers' })
map('n', '<leader>fo', '<cmd>FzfLua oldfiles<cr>', { desc = 'Find recent files' })
map('n', '<leader>fb', '<cmd>FzfLua lgrep_curbuf<cr>', { desc = 'Find in current buffer' })
map('n', '<leader>fd', '<cmd>FzfLua lsp_document_diagnostics<cr>', { desc = 'Find diagnostics' })
map('n', '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>', { desc = 'Find symbols' })
map('n', '<leader>fS', '<cmd>FzfLua spell_suggest<cr>', { desc = 'Find spelling suggestions' })
map('n', '<leader>fw', '<cmd>FzfLua grep_cword<cr>', { desc = 'Find current word' })
map('n', '<leader>fc', '<cmd>FzfLua command_history<cr>', { desc = 'Find command history' })
map('n', '<leader>fC', '<cmd>FzfLua commands<cr>', { desc = 'Find commands' })
map('n', '<leader>fh', '<cmd>FzfLua helptags<cr>', { desc = 'Find help' })
map('n', '<leader>fz', '<cmd>FzfLua zoxide<cr>', { desc = 'Find in zoxide' })
map('n', '<leader>fH', '<cmd>FzfLua highlights<cr>', { desc = 'Find highlights' })

-- gitsigns.nvim (https://github.com/lewis6991/gitsigns.nvim)
now_if_args(function()
  add({ 'https://github.com/lewis6991/gitsigns.nvim' })
  require('gitsigns').setup({
    current_line_blame = true,
    current_line_blame_opts = { delay = 0 },
    current_line_blame_formatter = ' <author>, <author_time:%R> ',
  })
end)
map('n', ']h', '<cmd>Gitsigns next_hunk<cr>', { desc = 'Next hunk' })
map('n', '[h', '<cmd>Gitsigns prev_hunk<cr>', { desc = 'Previous hunk' })
map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<cr>', { desc = 'Git preview hunk' })
map({ 'n', 'v' }, '<leader>hr', '<cmd>Gitsigns reset_hunk<cr>', { desc = 'Git reset hunk' })
map({ 'n', 'v' }, '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', { desc = 'Git stage hunk' })
map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<cr>', { desc = 'Git stage buffer' })
map('n', '<leader>hd', '<cmd>Gitsigns diffthis<cr>', { desc = 'Git diff hunk' })

-- vim-illuminate (https://github.com/RRethy/vim-illuminate)
now_if_args(function()
  add({ 'https://github.com/RRethy/vim-illuminate' })
  require('illuminate').configure({
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = { providers = { 'lsp' } },
    filetypes_denylist = { 'mason' },
  })
end)

local function map_reference(key, dir, buffer)
  map('n', key, function() require('illuminate')['goto_' .. dir .. '_reference'](false) end, {
    desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference',
    buffer = buffer,
  })
end

map_reference(']]', 'next')
map_reference('[[', 'prev')
on_filetype('*', function(event)
  map_reference(']]', 'next', event.buf)
  map_reference('[[', 'prev', event.buf)
end)

on_filetype({ 'help', 'man', 'mason', 'markdown', 'terminal', 'fzf' }, function()
  vim.b.miniindentscope_disable = true
end)

-- mini.indentscope (https://github.com/nvim-mini/mini.indentscope)
now_if_args(function()
  add({ 'https://github.com/nvim-mini/mini.indentscope' })
  require('mini.indentscope').setup({
    draw = { delay = 0, animation = require('mini.indentscope').gen_animation.none() },
    options = { try_as_border = true },
    symbol = '│',
  })
end)

-- mini.files (https://github.com/nvim-mini/mini.files)
later(function()
  add({ 'https://github.com/nvim-mini/mini.files' })
  require('mini.files').setup({
    mappings = { close = '<esc>', go_in_plus = '<cr>', synchronize = 's' },
    content = {
      filter = function(entry)
        return entry.name ~= '.DS_Store' and entry.name ~= '.git' and entry.name ~= 'node_modules'
      end,
      prefix = function() end,
    },
    options = { permanent_delete = false, use_as_default_explorer = false },
    windows = { preview = true, width_focus = 40, width_nofocus = 30, width_preview = 60 },
  })
end)

map('n', '-', function()
  local minifiles = require('mini.files')
  if not minifiles.close() then minifiles.open(vim.api.nvim_buf_get_name(0)) end
end, { desc = 'File explorer' })

local function map_split(buf_id, lhs, direction)
  map('n', lhs, function()
    local state = require('mini.files').get_explorer_state()
    local new_target = vim.api.nvim_win_call(state.target_window, function()
      vim.cmd(direction)
      return vim.api.nvim_get_current_win()
    end)
    require('mini.files').set_target_window(new_target)
    require('mini.files').go_in({ close_on_file = true })
  end, { buffer = buf_id, desc = 'Open in ' .. direction })
end

Config.new_autocmd('User', 'MiniFilesBufferCreate', function(args)
  map_split(args.data.buf_id, '<C-v>', 'belowright vertical split')
  map_split(args.data.buf_id, '<C-h>', 'belowright horizontal split')
end)

-- mini.bufremove (https://github.com/nvim-mini/mini.bufremove)
later(function()
  add({ 'https://github.com/nvim-mini/mini.bufremove' })
  require('mini.bufremove').setup({ silent = true })
end)
map('n', '<leader>w', function() require('mini.bufremove').delete(0, false) end, { desc = 'Close current buffer' })
map('n', '<leader>W', function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= current_buf then
      require('mini.bufremove').delete(buf, false)
    end
  end
end, { desc = 'Close all but current buffer' })

-- flash.nvim (https://github.com/folke/flash.nvim)
now_if_args(function()
  add({ 'https://github.com/folke/flash.nvim' })
  require('flash').setup({
    jump = { autojump = true },
    prompt = { enabled = false },
    modes = { search = { enabled = false }, char = { enabled = false } },
  })
end)
map({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash' })
map({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash Treesitter' })
map('n', '<leader>*', function() require('flash').jump({ pattern = vim.fn.expand('<cword>') }) end, {
  desc = 'Jump to word under cursor',
})

-- incline.nvim (https://github.com/b0o/incline.nvim)
now_if_args(function()
  add({ 'https://github.com/b0o/incline.nvim' })
  require('incline').setup({
    window = { margin = { vertical = 0, horizontal = 0 } },
    hide = { cursorline = false },
    render = function(props)
      local filepath = vim.api.nvim_buf_get_name(props.buf)
      local filename = vim.fn.fnamemodify(filepath, ':t')
      local parent = vim.fn.fnamemodify(filepath, ':h:t')
      if vim.bo[props.buf].modified then
        return { { string.format('* %s/%s', parent, filename), hlgroup = 'InclineModified' } }
      end
      return { string.format('%s/%s', parent, filename) }
    end,
  })
end)

-- nvim-highlight-colors (https://github.com/brenoprata10/nvim-highlight-colors)
now_if_args(function()
  add({ 'https://github.com/brenoprata10/nvim-highlight-colors' })
  require('nvim-highlight-colors').setup({
    render = 'virtual',
    virtual_symbol = '■',
    virtual_symbol_position = 'eol',
    virtual_symbol_prefix = '',
    virtual_symbol_suffix = '',
    enable_named_colors = false,
    enable_tailwind = false,
    enable_var_usage = false,
  })
end)

-- Comment.nvim (https://github.com/numToStr/Comment.nvim)
-- nvim-ts-context-commentstring (https://github.com/JoosepAlviste/nvim-ts-context-commentstring)
now_if_args(function()
  add({
    'https://github.com/numToStr/Comment.nvim',
    'https://github.com/JoosepAlviste/nvim-ts-context-commentstring',
  })
  require('Comment').setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  })
end)

-- mini.surround (https://github.com/nvim-mini/mini.surround)
now_if_args(function()
  add({ 'https://github.com/nvim-mini/mini.surround' })
  require('mini.surround').setup({
    mappings = {
      add = 'gsa',
      delete = 'gsd',
      find = 'gsf',
      find_left = 'gsF',
      highlight = 'gsh',
      replace = 'gsr',
      update_n_lines = 'gsn',
    },
  })
end)

-- ultimate-autopair.nvim (https://github.com/altermo/ultimate-autopair.nvim)
now_if_args(function()
  add({ 'https://github.com/altermo/ultimate-autopair.nvim' })
  require('ultimate-autopair').setup({})
end)

-- mini.ai (https://github.com/nvim-mini/mini.ai)
now_if_args(function()
  add({ 'https://github.com/nvim-mini/mini.ai' })
  local spec_treesitter = require('mini.ai').gen_spec.treesitter
  require('mini.ai').setup({
    n_lines = 200,
    silent = true,
    search_method = 'cover_or_next',
    mappings = { around_last = '', inside_last = '' },
    custom_textobjects = {
      a = spec_treesitter({ a = '@assignment.outer', i = '@assignment.inner' }),
      c = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
      f = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
      l = spec_treesitter({ a = '@loop.outer', i = '@loop.inner' }),
      m = spec_treesitter({ a = '@comment.outer', i = '@comment.inner' }),
      r = spec_treesitter({ a = '@return.outer', i = '@return.inner' }),
      s = spec_treesitter({ a = '@block_string.outer', i = '@block_string.inner' }),
    },
  })
end)

-- conform.nvim (https://github.com/stevearc/conform.nvim)
now_if_args(function()
  add({ 'https://github.com/stevearc/conform.nvim' })

  local global_biome_config = vim.fs.normalize('~/.config/biome/biome.json')
  local global_prettier_config = vim.fs.normalize('~/.config/.prettierrc')
  local biome_markers = { 'biome.json', 'biome.jsonc', '.biome.json', '.biome.jsonc' }
  local prettier_markers = {
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.js',
    'prettier.config.js',
  }

  local function file_exists(path)
    local stat = vim.uv.fs_stat(path)
    return stat and stat.type == 'file'
  end

  local function has_project_prettier_config(dirname)
    return vim.fs.root(dirname, function(name, path)
      if vim.list_contains(prettier_markers, name) then return true end
      if name ~= 'package.json' then return false end

      local ok, pkg = pcall(vim.json.decode, vim.secure.read(vim.fs.joinpath(path, name)) or '')
      return ok and type(pkg) == 'table' and pkg.prettier ~= nil
    end) ~= nil
  end

  local function autoformat_enabled(bufnr)
    if vim.b[bufnr].autoformat ~= nil then return vim.b[bufnr].autoformat end
    return vim.g.autoformat ~= false
  end

  local function set_autoformat(enabled, buffer)
    if buffer then
      vim.b.autoformat = enabled
    else
      vim.g.autoformat = enabled
      if enabled then vim.b.autoformat = nil end
    end

    vim.notify('Format on save ' .. (enabled and 'enabled' or 'disabled') .. (buffer and ' for this buffer' or ''))
  end

  require('conform').setup({
    notify_on_error = false,
    default_format_opts = { lsp_format = 'fallback', stop_after_first = true },
    formatters_by_ft = Config.Languages.formatters_by_ft,
    format_on_save = function(bufnr)
      if not autoformat_enabled(bufnr) then return end
      return { async = false, timeout_ms = 500 }
    end,
    formatters = {
      biome = {
        args = function(_, ctx)
          local args = { 'format', '--stdin-file-path', '$FILENAME' }
          if not vim.fs.root(ctx.dirname, biome_markers) and file_exists(global_biome_config) then
            vim.list_extend(args, { '--config-path', global_biome_config })
          end
          return args
        end,
        stdin = true,
      },
      prettierd = {
        env = function()
          if file_exists(global_prettier_config) then return { PRETTIERD_DEFAULT_CONFIG = global_prettier_config } end
        end,
      },
      prettier = {
        prepend_args = function(_, ctx)
          if not has_project_prettier_config(ctx.dirname) and file_exists(global_prettier_config) then
            return { '--config', global_prettier_config }
          end
          return {}
        end,
      },
    },
  })

  map('n', '<leader>x', function()
    require('conform').format({ async = true })
  end, { desc = 'Format buffer' })

  vim.api.nvim_create_user_command('FormatDisable', function(args)
    set_autoformat(false, args.bang)
  end, { desc = 'Disable format on save', bang = true, force = true })

  vim.api.nvim_create_user_command('FormatEnable', function(args)
    set_autoformat(true, args.bang)
  end, { desc = 'Enable format on save', bang = true, force = true })
end)

-- mini.clue (https://github.com/nvim-mini/mini.clue)
later(function()
  add({ 'https://github.com/nvim-mini/mini.clue' })
  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
      { mode = 'i', keys = '<C-x>' },
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' },
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },
    },
    clues = {
      Config.group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
      miniclue.gen_clues.square_brackets(),
    },
    window = { delay = 500, config = { width = 50 } },
  })
end)

-- diffview.nvim (https://github.com/sindrets/diffview.nvim)
later(function()
  add({ 'https://github.com/sindrets/diffview.nvim' })
  require('diffview').setup({
    use_icons = false,
    file_panel = { listing_style = 'list', win_config = { width = 35 } },
  })
end)
map('n', '<leader>dvo', '<cmd>DiffviewOpen<cr>', { desc = 'DiffView open' })
map('n', '<leader>dvc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview close' })

-- nvim-ufo (https://github.com/kevinhwang91/nvim-ufo)
later(function()
  add({
    'https://github.com/kevinhwang91/nvim-ufo',
    'https://github.com/kevinhwang91/promise-async',
  })

  map('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
  map('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
  map('n', 'zp', require('ufo').peekFoldedLinesUnderCursor, { desc = 'Peek fold' })
  require('ufo').setup({
    provider_selector = function()
      return { 'indent' }
    end,
    preview = { win_config = { border = 'single', winhighlight = 'Normal:Folded', winblend = 0 } },
  })
end)

-- zen-mode.nvim (https://github.com/folke/zen-mode.nvim)
later(function()
  add({ 'https://github.com/folke/zen-mode.nvim' })
  require('zen-mode').setup({
    window = { backdrop = 1, width = 0.8, height = 0.8, options = { number = false, relativenumber = false } },
    plugins = {
      gitsigns = { enabled = true },
      tmux = { enabled = true },
      options = { enabled = true, showcmd = false, laststatus = 0, winborder = 'none' },
    },
    on_open = function()
      vim.b.miniindentscope_disable = true
      require('incline').disable()
    end,
    on_close = function()
      vim.b.miniindentscope_disable = false
      require('incline').enable()
    end,
  })
end)
map('n', '<leader>z', '<cmd>ZenMode<cr>', { desc = 'Zen mode' })

-- harpoon (https://github.com/ThePrimeagen/harpoon)
later(function()
  add({
    { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
    'https://github.com/nvim-lua/plenary.nvim',
  })

  local harpoon = require('harpoon')
  harpoon:setup({ settings = { save_on_toggle = true } })
  map('n', 'ma', function() harpoon:list():add() end, { desc = 'Add current file to mark list' })
  map('n', '<leader>m', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Toggle quick mark list' })
  map('n', "'a", function() harpoon:list():select(1) end, { desc = 'Go to mark #1' })
  map('n', "'s", function() harpoon:list():select(2) end, { desc = 'Go to mark #2' })
  map('n', "'d", function() harpoon:list():select(3) end, { desc = 'Go to mark #3' })
  map('n', "'f", function() harpoon:list():select(4) end, { desc = 'Go to mark #4' })
end)

-- Navigator.nvim (https://github.com/numToStr/Navigator.nvim)
later(function()
  add({ 'https://github.com/numToStr/Navigator.nvim' })
  require('Navigator').setup({ disable_on_zoom = true })
end)
map('n', '<C-h>', '<cmd>NavigatorLeft<cr>')
map('n', '<C-j>', '<cmd>NavigatorDown<cr>')
map('n', '<C-k>', '<cmd>NavigatorUp<cr>')
map('n', '<C-l>', '<cmd>NavigatorRight<cr>')

-- harpoonline (https://github.com/abeldekat/harpoonline)
later(function()
  add({ 'https://github.com/abeldekat/harpoonline' })
  require('harpoonline').setup({
    on_update = function() vim.cmd.redrawstatus() end,
  })
end)

-- multicursor.nvim (https://github.com/jake-stewart/multicursor.nvim)
later(function()
  add({ { src = 'https://github.com/jake-stewart/multicursor.nvim', version = '1.0' } })
end)

-- vim-repeat (https://github.com/tpope/vim-repeat)
later(function()
  add({ 'https://github.com/tpope/vim-repeat' })
end)
