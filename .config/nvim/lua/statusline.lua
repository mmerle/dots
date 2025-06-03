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

vim.opt.statusline = M.statusline()
