#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search in Facebook Marketplace
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/facebook.png
# @raycast.argument1 { "type": "text", "placeholder": "query" }

open "https://www.facebook.com/marketplace/montreal/search/?query=${1// /%20}"
