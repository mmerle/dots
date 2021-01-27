#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title System Activity
# @raycast.mode inline
# @raycast.refreshTime 1m

# Optional parameters:
# @raycast.icon 📈
# @raycast.packageName Performance

cpu_mem=$(ps -A -o %cpu,%mem | awk '{ cpu += $1; mem += $2} END {print "CPU: "cpu"% RAM: "mem"%"}')

echo "${cpu_mem}"