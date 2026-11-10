local M = {}
local terminal = "com.superlogical.terminal"
local directions = { h = "left", j = "down", k = "up", l = "right" }
-- NOTE: Private entry keys bypass Rex bindings and never request another handoff.
local entry = { left = "\27[1;8D", down = "\27[1;8B", up = "\27[1;8A", right = "\27[1;8C" }

local function is_nvim(process)
  return process and (process.name == "nvim" or process.name == "nvim.exe")
end

local function is_pi(process)
  if not process then return false end
  local argv0 = (process.argv0 or ""):match("([^/\\]+)$")
  return process.name == "pi" or process.name == "pi-coding-agent"
    or argv0 == "pi" or argv0 == "pi-coding-agent"
    or (process.script or ""):find("/pi-coding-agent/", 1, true) ~= nil
end

local function terminal_process(ctx, block_id)
  return rex.block.call(terminal, "process", {
    session_id = ctx.session_id,
    block_id = block_id,
  })
end

local function running(process, matches)
  if not process then return nil end
  if matches(process.foreground or process.child) then return true end
  for _, ancestor in ipairs(process.ancestors or {}) do
    if matches(ancestor) then return true end
  end
  return false
end

local function active_window(ctx)
  local view = assert(rex.session.view{ session_id = ctx.session_id })
  for _, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id then return window end
  end
end

function M.setup(opts)
  opts = opts or {}
  assert(opts.wrap == nil or type(opts.wrap) == "boolean", "navigator: wrap must be a boolean")
  local wrap = opts.wrap == true

  local function focus(ctx, direction)
    assert(entry[direction], "navigator: invalid direction")
    if not ctx.session_id or not ctx.block_id then return false end
    local source = active_window(ctx)
    -- NOTE: An async edge request must not move a different pane or end zoom.
    if not source or source.focused_block_id ~= ctx.block_id or source.zoomed_block_id then return false end

    assert(rex.session.focus_direction{ session_id = ctx.session_id, direction = direction, wrap = wrap })
    local destination = active_window(ctx)
    if not destination or destination.window_id ~= source.window_id then return false end
    local block_id = destination.focused_block_id
    if not block_id or (block_id == ctx.block_id and not wrap) then return false end
    if running(terminal_process(ctx, block_id), is_nvim) then
      local written, err = rex.block.call(terminal, "write", {
        session_id = ctx.session_id,
        block_id = block_id,
        data = entry[direction],
      })
      if not written then rex.log("warn", "navigator: entry failed: " .. tostring(err)) end
    end
    return true
  end

  rex.action{
    name = "navigator_focus",
    title = "Navigate to Rex Pane",
    category = "Navigator",
    args = { direction = "string" },
    run = function(ctx, args) return focus(ctx, args.direction) end,
  }

  for key, direction in pairs(directions) do
    local target = direction
    rex.bind("ctrl+" .. key, function(ctx)
      if not ctx.session_id or not ctx.block_id then return false end
      local process = terminal_process(ctx, ctx.block_id)
      if running(process, is_nvim) ~= false then return false end
      if (target == "up" or target == "down") and running(process, is_pi) then return false end
      focus(ctx, target)
      return true
    end)
  end
end

return M
