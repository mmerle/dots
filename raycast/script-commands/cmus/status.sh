#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Current Track
# @raycast.mode inline
# @raycast.refreshTime 5s

# Optional parameters:
# @raycast.icon ℹ️
# @raycast.packageName cmus

# Modified script from https://github.com/Anachron/i3blocks/blob/master/blocks/cmus

info_cmus=$(cmus-remote -Q)
info_status=$(echo "${info_cmus}" | sed -n -e 's/^.*status//p' | head -n 1)

track_title=$(echo "${info_cmus}" | sed -n -e 's/^.*title//p' | head -n 1)
track_artist=$(echo "${info_cmus}" | sed -n -e 's/^.*artist//p' | head -n 1)
track_album=$(echo "${info_cmus}" | sed -n -e 's/^.*album//p' | head -n 1)

out_text="Cmus is not running"

if [[ "${info_status}" == *"playing"* ]]; then
  out_text="${track_title} —${track_artist}"
elif [[ "${info_status}" == *"paused"* ]]; then
  out_text="[PAUSED] ${track_title} —${track_artist}"
else
  out_text="No Track Playing"
fi


echo "${out_text}"
