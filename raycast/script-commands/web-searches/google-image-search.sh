#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search in Google Images
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/google.png
# @raycast.argument1 { "type": "text", "placeholder": "query" }

open "https://www.google.com/search?tbm=isch&q=${1// /%20}"
