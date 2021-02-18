#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Translate with DeepL
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/deepl.png
# @raycast.argument1 { "type": "text", "placeholder": "query" }

open "https://www.deepl.com/en/translator#en/fr/${1// /%20}"
