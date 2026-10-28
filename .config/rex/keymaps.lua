for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  local target = direction
  rex.bind("ctrl+" .. key, function(ctx)
    local process = assert(rex.block.call("com.superlogical.terminal", "process", {
      block_id = ctx.block_id,
    }))
    local name = process.foreground and process.foreground.name
    if name == "nvim" or name == "vim" or name == "vi" then return false end

    assert(rex.session.focus_direction{ direction = target, wrap = false })
    return true
  end)
end

rex.mode("layout", { exclusive = true })
rex.bind("cmd+shift+l", "client.mode.enter", { name = "layout" })
rex.bind("layout/=", "pane.balance")

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("layout/" .. key, "pane.resize", { direction = direction })
  rex.bind("layout/shift+" .. key, "pane.move", { direction = direction })
end
