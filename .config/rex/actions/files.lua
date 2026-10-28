local panes = require("panes")

rex.action{
  name = "yazi",
  title = "Open Files Split",
  run = function(ctx)
    return panes.split(ctx, { initial_input = "y\n" })
  end,
}
