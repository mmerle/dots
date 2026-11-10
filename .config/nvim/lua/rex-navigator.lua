local M = {}
local directions = {
  h = { name = 'Left', opposite = 'l', direction = 'left' },
  j = { name = 'Down', opposite = 'k', direction = 'down' },
  k = { name = 'Up', opposite = 'j', direction = 'up' },
  l = { name = 'Right', opposite = 'h', direction = 'right' },
}
local pending = false

local function notify(message)
  vim.notify('navigator: ' .. message, vim.log.levels.WARN)
end

function M.navigate(key)
  local target = assert(directions[key], 'navigator: expected h, j, k, or l')
  if vim.fn.getcmdwintype() ~= '' then return end
  local before = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(key)
  if vim.api.nvim_get_current_win() ~= before or pending then return end
  local session, block = vim.env.REX_SESSION, vim.env.REX_BLOCK
  if not session or session == '' or not block or block == '' then return end
  local binary = vim.env.REX_BIN_DIR and (vim.env.REX_BIN_DIR .. '/rex') or 'rex'
  pending = true
  local ok, err = pcall(vim.system, {
    binary, '--autostart=false', '--timeout', '1s',
    'do', '-s', session, '-b', block,
    'navigator_focus', 'direction=' .. target.direction,
  }, { text = true, timeout = 1250 }, vim.schedule_wrap(function(result)
    pending = false
    if result.code ~= 0 then
      local detail = vim.trim(result.stderr or '')
      notify(detail ~= '' and detail or 'Rex exited with status ' .. result.code)
    end
  end))
  if not ok then
    pending = false
    notify(tostring(err))
  end
end

local function floating()
  return vim.api.nvim_win_get_config(0).relative ~= ''
end

local function enter(opposite)
  if floating() or vim.bo.filetype == 'fzf' or vim.fn.getcmdwintype() ~= '' then return end
  if vim.api.nvim_get_mode().mode == 't' then vim.cmd.stopinsert() end
  for _ = 1, #vim.api.nvim_tabpage_list_wins(0) do
    local before = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(opposite)
    if vim.api.nvim_get_current_win() == before then break end
  end
end

function M.setup()
  for key, target in pairs(directions) do
    local letter, opposite = key, target.opposite
    local signal = '<C-M-S-' .. target.name .. '>'
    vim.keymap.set('n', '<C-' .. key .. '>', function() M.navigate(letter) end,
      { desc = 'Navigator: ' .. target.direction })
    vim.keymap.set({ 'n', 'x', 'i', 't' }, signal, function() enter(opposite) end,
      { desc = 'Navigator: enter moving ' .. target.direction })
    vim.keymap.set('t', '<C-' .. key .. '>', function()
      if floating() or vim.bo.filetype == 'fzf' then return '<C-' .. letter .. '>' end
      return '<C-\\><C-n><Cmd>lua require("rex-navigator").navigate("' .. letter .. '")<CR>'
    end, { expr = true, desc = 'Navigator: ' .. target.direction })
  end
end

return M
