-- when using fish, set shell to bash
if vim.env.SHELL:match('fish$') then vim.opt.shell = '/opt/homebrew/bin/bash' end

-- Use proper syntax highlighting in code blocks
local fences = {
    'console=sh',
    'javascript',
    'js=javascript',
    'json',
    'lua',
    'python',
    'sh',
    'shell=sh',
    'ts=typescript',
    'typescript',
}
vim.g.markdown_fenced_languages = fences
vim.g.markdown_recommended_style = 0

-- stop 'o' continuing comments
vim.api.nvim_create_autocmd('BufEnter', {
    command = 'setlocal formatoptions-=o',
})

-- highlight copied text
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 }) end,
})

-- diagnostic symbols
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '●',
            [vim.diagnostic.severity.WARN] = '●',
            [vim.diagnostic.severity.INFO] = '●',
            [vim.diagnostic.severity.HINT] = '●',
        },
    },
    virtual_text = {
        prefix = '*',
    },
})

-- balance splits on window resize
vim.api.nvim_create_autocmd('VimResized', {
    desc = 'Balance windows',
    command = 'tabdo wincmd =',
})

-- open nvim-tree on startup, only if in directory
vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        local args = vim.fn.argv()
        local directory = vim.fn.isdirectory(args[1]) == 1

        if directory then require('nvim-tree.api').tree.open() end
    end,
})

-- custom statusline
M = {}

function M.watch_fn(fn) return '%<%{luaeval("' .. fn .. '")}' end

function M.get_branch()
    if vim.fn.isdirectory('.git') ~= 0 then
        local branch = vim.fn.system("git branch --show-current | tr -d '\n'")
        return '(' .. branch .. ')'
    end
    return ''
end

function M.diagnostic_error_status()
    local num_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })

    if num_errors > 0 then return '● ' .. num_errors end
    return ''
end

function M.diagnostic_warn_status()
    local num_warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

    if num_warnings > 0 then return '● ' .. num_warnings end
    return ''
end

function M.statusline()
    local lsp_error_count = '%#DiagnosticError#' .. M.watch_fn('M.diagnostic_error_status()') .. '%*'
    local lsp_warning_count = '%#DiagnosticWarn#' .. M.watch_fn('M.diagnostic_warn_status()') .. '%*'
    local current_branch = M.watch_fn('M.get_branch()')

    local sections = {
        current_branch,
        '%f %M',
        '%=',
        lsp_error_count,
        lsp_warning_count,
        '%P %l:%c',
    }

    return ' ' .. table.concat(sections, ' ') .. ' '
end

-- vim.diagnostic.config({ virtual_text = false })
vim.opt.statusline = M.statusline()

-- switch between relative and absolute line numbers based on mode
local number_toggle = vim.api.nvim_create_augroup('number_toggle', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
    callback = function()
        if vim.opt.number:get() == true then vim.opt.relativenumber = true end
    end,
    group = number_toggle,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
    callback = function()
        if vim.opt.number:get() == true then vim.opt.relativenumber = false end
    end,
    group = number_toggle,
})

-- open `:help` pages in vsplit
vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('help_window_right', {}),
    pattern = { '*.txt' },
    callback = function()
        if vim.o.filetype == 'help' then
            vim.api.nvim_cmd({ cmd = 'wincmd', args = { 'L' } }, {})
            vim.keymap.set('n', 'q', ':q<cr>', { buffer = 0 })
        end
    end,
})

-- vim.api.nvim_create_autocmd('FileType', {
--     group = vim.api.nvim_create_augroup('Prose', {}),
--     pattern = { 'gitcommit', 'markdown' },
--     callback = function()
--         vim.opt_local.spell = true
--         vim.opt_local.wrap = true
--         vim.opt_local.linebreak = true
--         vim.opt_local.conceallevel = 2
--     end,
-- })

-- additional filetypes
vim.filetype.add({
    extension = {
        mdx = 'markdown',
        js = 'javascriptreact',
        conf = 'conf',
    },
    pattern = {
        ['.*%.env.*'] = 'sh',
        ['ignore$'] = 'conf',
    },
})
