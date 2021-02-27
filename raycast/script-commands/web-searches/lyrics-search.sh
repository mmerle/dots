#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search for Lyrics
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/genius.png
# @raycast.argument1 { "type": "text", "placeholder": "query" }
  
open "https://genius.com/search?q=${1// /%20}"
