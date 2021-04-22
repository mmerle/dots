#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Code Terminal
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 👨‍💻

echo "{ \"command\": \"workbench.action.terminal.new\" }" | websocat ws://localhost:3710
