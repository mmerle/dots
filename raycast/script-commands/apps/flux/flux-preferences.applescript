#!/usr/bin/osascript

# @raycast.schemaVersion 1
# @raycast.title Open Flux Preferences
# @raycast.mode silent

# @raycast.packageName Flux
# @raycast.icon images/flux.png

# @raycast.author mmerle
# @raycast.authorURL https://github.com/mmerle
# @raycast.description Open f.lux preferences.

ignoring application responses
  tell application "System Events" to tell process "Flux"
    click menu bar item 1 of menu bar 2
  end tell
end ignoring

delay 0.1
do shell script "killall System\\ Events"

tell application "System Events" to tell process "Flux"
  tell menu bar item 1 of menu bar 2
    click menu item "Preferences..." of menu 1
  end tell
end tell