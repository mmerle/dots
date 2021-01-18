#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Check contrast
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎨
# @raycast.argument1 { "type": "text", "placeholder": "background color", "percentEncoded": true }
# @raycast.argument2 { "type": "text", "placeholder": "foreground color", "percentEncoded": true }

open "https://colourcontrast.cc/$1/$2"