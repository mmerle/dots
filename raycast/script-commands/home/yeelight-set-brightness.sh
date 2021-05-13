#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set Light Bar Brightness
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Home
# @raycast.icon images/yeelight.png

# @raycast.argument1 { "type": "text", "placeholder": "100" }

yeecli brightness $1
