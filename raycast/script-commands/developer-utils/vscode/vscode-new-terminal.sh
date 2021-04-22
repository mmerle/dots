#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open VS Code Terminal
# @raycast.mode silent
# @raycast.packageName VS Code

# Optional parameters:
# @raycast.icon images/vscode.png

open -a "Visual Studio Code"
echo "{ \"command\": \"workbench.action.terminal.new\" }" | websocat ws://localhost:3710
