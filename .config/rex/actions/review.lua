local panes = require("panes")

rex.action{
  name = "tuicr",
  title = "Open Code Review Split",
  run = function(ctx)
    return panes.split(ctx, { command = { "tuicr" } })
  end,
}

rex.action{
  name = "floating_review",
  title = "Open Floating Code Review",
  run = function(ctx)
    return panes.float(ctx, "code-review", { "tuicr" })
  end,
}
