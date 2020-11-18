#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Play/Pause
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon ⏯
# @raycast.packageName cmus

cmus-remote --pause
