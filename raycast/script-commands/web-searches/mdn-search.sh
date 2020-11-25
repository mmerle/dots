#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search in MDN
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/mdn.png
# @raycast.argument1 { "type": "text", "placeholder": "query" }

open "https://developer.mozilla.org/en-US/search?q=${1// /%20}"