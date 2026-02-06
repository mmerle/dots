---@diagnostic disable: lowercase-global

-- change config location:
-- defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

-- ensure cli is available
if not hs.ipc.cliStatus() then
	hs.ipc.cliInstall()
end

hs.alert.defaultStyle.strokeWidth = 0
hs.alert.defaultStyle.strokeColor = { alpha = 0 }
hs.alert.defaultStyle.radius = 8
hs.alert.defaultStyle.textFont = "MD IO"
hs.alert.defaultStyle.textSize = 13

hs.window.setShadows(false)

-- auto-reload the config file
hs.pathwatcher
	.new(os.getenv("HOME") .. "/.config/hammerspoon/", function(files)
		for _, file in ipairs(files) do
			if file:match("%.lua$") then
				hs.reload()
				break
			end
		end
	end)
	:start()

hs.notify.new({ title = "Hammerspoon", informativeText = "Config reloaded" }):send()

-- switch audio devices
function switchAudioDevice(targetName)
	targetName = targetName or "MacBook Pro Speakers"
	local audioDevices = hs.audiodevice.allOutputDevices()

	for _, device in ipairs(audioDevices) do
		if device:name():lower():match(targetName:lower()) then
			local success = device:setDefaultOutputDevice()
			if success then
				if hs.audiodevice.defaultOutputDevice():name():lower():match(targetName:lower()) then
					return string.format("Audio switched to %s", device:name())
				else
					return "Switch command succeeded, but verification failed"
				end
			else
				return string.format("Failed to switch to %s", device:name())
			end
		end
	end

	return string.format("Device '%s' not found", targetName)
end
