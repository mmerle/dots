rex.mode("layout", { exclusive = true })
rex.bind("cmd+shift+l", "client.mode.enter", { name = "layout" })
rex.bind("layout/=", "pane.balance")

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("layout/" .. key, "pane.resize", { direction = direction })
  rex.bind("layout/shift+" .. key, "pane.move", { direction = direction })
end
