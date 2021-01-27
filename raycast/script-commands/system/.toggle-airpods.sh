#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle AirPods
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Audio
# @raycast.icon images/airpods.png

tell application "System Events" to tell process "SystemUIServer"
    set bt to (first menu bar item whose description is "bluetooth") of menu bar 1
    click bt
    tell (first menu item whose title is "merle airpods") of menu of bt
        click
        tell menu 1
            if exists menu item "Connect" then
                click menu item "Connect"
            else if exists menu item "Disconnect" then
                click menu item "Disconnect"
            else 
                click bt
            end if
        end tell
    end tell
end tell