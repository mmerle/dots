#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search in Are.na
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/arena.png
# @raycast.argument1 { "type": "text", "placeholder": "query" }

open "https://www.are.na/search/${1// /%20}"