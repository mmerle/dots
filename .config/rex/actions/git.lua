local panes = require("panes")

rex.action{
  name = "git",
  title = "Open Lazygit",
  run = function(ctx)
    return panes.float(ctx, "lazygit", { "lazygit" })
  end,
}

rex.bind("cmd+g", "git")
