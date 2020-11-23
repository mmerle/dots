#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get most recent 2FA code from iMessages
# @raycast.mode compact
# @raycast.author Caleb Stauffer
# @raycast.authorURL https://github.com/crstauf
# @raycast.description Port of Alfred workflow from @squatto to find and copy 2FA codes from iMessages.


### Requires Raycast to have Full Disk Access:
### https://spin.atomicobject.com/2020/05/22/search-imessage-sql/


data=$(php imessage-2fa.php)

if [[ "$data" == *";"* ]];
then
	IFS=';'; arrIN=($data); unset IFS; 
	echo ${arrIN[0]} | pbcopy
	echo "Copied \"${arrIN[0]}\" from ${arrIN[1]} at ${arrIN[2]}"
else
	echo $data
fi