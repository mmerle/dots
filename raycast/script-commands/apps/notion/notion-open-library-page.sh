#!/bin/bash
​
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Knowledge Library Page
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
open "notion://mmerle/5110cf9b5300444f98cc5f5ada6e38aa?v=0d19117c5a084073b4501526db11977d"

echo "Page Opened"