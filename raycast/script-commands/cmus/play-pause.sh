#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Toggle Play/Pause
# @raycast.mode silent
#
# @raycast.icon ⏯
# @raycast.packageName cmus
#
# @raycast.description Toggles the play/pause state if cmus is running
# @raycast.author mmerle
# @raycast.authorURL https://github.com/mmerle

cmus-remote --pause
