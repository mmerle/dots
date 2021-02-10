#!/bin/bash
​
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Link Pool Page
# @raycast.mode silent
​
# Optional parameters:
# @raycast.packageName Notion
# @raycast.icon images/notion.png
​
# Customization instructions:
# 1. Copy link from Notion page (Share -> Copy link)
# 2. Replace `https://www.notion.so` with `notion://`
​
open "notion://mmerle/ad18a81d58854235a8a70e4151732ac0?v=c72849db2029410ab0682b8aef701cc3"

echo "Page Opened"