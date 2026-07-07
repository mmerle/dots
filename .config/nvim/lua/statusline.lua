local M = {}
local api = vim.api

local PAD = ' '
local SEP = '%='
local SBAR = { '▔', '🮂', '🬂', '🮃', '▀', '▄', '▃', '🬭', '▂', '▁' }

local ORDER = {
  'pad',
  'branch',
  'path',
  'harpoon',
  'sep',
  'error',
  'warning',
  'fileinfo',
  'pad',
  'scrollbar',
  'pad',
}

-- utils
local function hl_str(hl, str) return '%#' .. hl .. '#' .. str .. '%*' end

local function concat(parts)
  local out, i = {}, 1
  for _, k in ipairs(ORDER) do
    local v = parts[k]
    if v and v ~= '' then
      out[i] = v
      i = i + 1
    end
  end
  return table.concat(out, ' ')
end

-- branch
local function get_branch()
  local branch = vim.b.gitsigns_head
  if branch and branch ~= '' then return '[' .. branch .. ']' end
  return ''
end

-- error
local function diagnostic_error_status()
  local num_errors = vim.diagnostic.count(0)[vim.diagnostic.severity.ERROR] or 0
  if num_errors > 0 then return '● ' .. num_errors end
  return ''
end

-- warning
local function diagnostic_warn_status()
  local num_warnings = vim.diagnostic.count(0)[vim.diagnostic.severity.WARN] or 0
  if num_warnings > 0 then return '● ' .. num_warnings end
  return ''
end

-- harpoon
local function harpoon_status()
  local ok, Harpoonline = pcall(require, 'harpoonline')
  if not ok then return '' end

  return Harpoonline.format()
end

-- scrollbar
-- thank to (https://github.com/mcauley-penney/nvim/blob/main/lua/ui/statusline.lua)
local function scrollbar()
  local cur = api.nvim_win_get_cursor(0)[1]
  local total = api.nvim_buf_line_count(0)
  local idx = math.floor((cur - 1) / total * #SBAR) + 1
  return hl_str('Cursor', SBAR[idx]:rep(2))
end

function M.render()
  local sections = {
    pad = PAD,
    branch = get_branch(),
    path = '%f %M',
    harpoon = harpoon_status(),
    sep = SEP,
    error = hl_str('DiagnosticError', diagnostic_error_status()),
    warning = hl_str('DiagnosticWarn', diagnostic_warn_status()),
    scrollbar = scrollbar(),
    -- fileinfo = '%P %l:%c (%L)',
    fileinfo = '%l:%c (%L)',
  }

  return concat(sections)
end

vim.o.statusline = "%!v:lua.require('statusline').render()"

return M
