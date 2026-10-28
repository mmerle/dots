local directions = { h = 'left', j = 'down', k = 'up', l = 'right' }
local Rex = require('Navigator.mux.vi'):new()
local pending = false

-- Check zoom at the editor edge, without blocking Neovim for status queries.
local focus = [[
  local view = assert(rex.session.view{})
  for _, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id and window.focused_block_id == rex.block_id then
      if not window.zoomed_block_id then
        assert(rex.session.focus_direction{ direction = rex.args.direction, wrap = false })
      end
      return
    end
  end
]]

function Rex:navigate(direction)
  local target = directions[direction]
  if not target or pending then return self end

  pending = true
  vim.system({
    'rex', 'do', '-s', vim.env.REX_SESSION, '-b', vim.env.REX_BLOCK,
    '-e', focus, 'direction=' .. target,
  }, { text = true, timeout = 2000 }, vim.schedule_wrap(function(result)
    pending = false
    if result.code ~= 0 then
      vim.notify('Rex navigation failed: ' .. vim.trim(result.stderr or ''), vim.log.levels.ERROR)
    end
  end))
  return self
end

return Rex
