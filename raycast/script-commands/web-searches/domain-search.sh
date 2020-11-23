#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search in Vercel Domains
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/vercel.png
# @raycast.argument1 { "type": "text", "placeholder": "query" }

open "https://vercel.com/domains?q=${1// /%20}&limit=24"