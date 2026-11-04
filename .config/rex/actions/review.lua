local panes = require("panes")

local branch = [[
for ref in "$(git symbolic-ref -q --short refs/remotes/origin/HEAD)" origin/main origin/master main master; do
  [ -n "$ref" ] && base=$(git merge-base HEAD "$ref" 2>/dev/null) && break
done
[ -n "$base" ] || { echo "No default branch (origin/HEAD, main, or master) to compare against."; exit 1; }
[ "$base" = "$(git rev-parse HEAD)" ] && exec tuicr -w
exec tuicr -r "$base..HEAD" -w
]]

for name, command in pairs({ uncommitted = { "tuicr", "-w" }, branch = { "sh", "-c", branch } }) do
  local title = "Review " .. name:gsub("^%l", string.upper)
  rex.action{ name = "review_" .. name, title = title .. " Split", run = function(ctx)
    return panes.split(ctx, { command = command })
  end }
  rex.action{ name = "review_" .. name .. "_float", title = title .. " Float", run = function(ctx)
    return panes.float(ctx, "review-" .. name, command)
  end }
end
