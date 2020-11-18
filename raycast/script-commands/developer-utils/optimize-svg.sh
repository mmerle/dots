#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Optimize SVG
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🧼

pbpaste | svgo -i - --disable removeViewBox,convertColors --enable removeDimensions,reusePaths -o - | pbcopy
echo "SVG Optimized"
