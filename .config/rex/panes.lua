local panes = {}

function panes.directory(ctx)
  local process = assert(rex.block.call("com.superlogical.terminal", "process", {
    block_id = ctx.block_id,
  }))
  return assert(process.foreground and process.foreground.cwd,
    "The focused terminal has no foreground working directory")
end

function panes.split(ctx, options)
  options.cwd = panes.directory(ctx)
  return assert(rex.session.new_split{
    anchor_id = ctx.block_id,
    direction = "horizontal",
    side = "after",
    focus = true,
    layout = rex.layout.block{
      flavor = "com.superlogical.terminal.shell",
      options = options,
    },
  })
end

function panes.float(ctx, label, command)
  local source = assert(rex.session.describe_block{ block_id = ctx.block_id })
  local window_id = source.block.window_id
  local view = assert(rex.session.view{})
  for _, window in ipairs(view.windows) do
    if window.window_id == window_id then
      for _, layer in ipairs(window.layers) do
        if layer.kind == "floating" then
          for _, block in ipairs(layer.blocks) do
            if block.label == label then
              assert(rex.session.raise_layer{ layer_id = layer.layer_id })
              assert(rex.session.focus_block{ block_id = block.block_id })
              return { block_id = block.block_id, layer_id = layer.layer_id }
            end
          end
        end
      end
    end
  end

  local layer = assert(rex.session.new_layer{
    window_id = window_id,
    bounds = { 0.1, 0.1, 0.8, 0.8 },
    focus = true,
    layout = rex.layout.block{
      flavor = "com.superlogical.terminal.shell",
      label = label,
      options = { command = command, cwd = panes.directory(ctx) },
    },
  })
  return { block_id = layer.block_ids[1], layer_id = layer.layer_id }
end

return panes
