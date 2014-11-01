scriptId = 'com.thalmic.examples.myfirstscript'
 
locked = false
appTitle = ""
targetApp = "Paint"
myo.controlMouse(true)
 
function onForegroundWindowChange(app, title)
    myo.debug("onForegroundWindowChange: " .. app .. ", " .. title)
	appTitle = title
	if string.sub(appTitle, -string.len(targetApp))==targetApp then
		myo.debug("Active App")
		locked = false
	else
		locked = true
	end
	
    return true
end
 
function activeAppName()
	return appTitle
end

function onPoseEdge(pose, edge)
	myo.debug("onPoseEdge: " .. pose .. ": " .. edge)
	
	pose = conditionallySwapWave(pose)
	
	if (edge == "on") then
		if (pose == "thumbToPinky") then
			--toggleLock()
		elseif (not locked) then
			if (pose == "fist") then
				onFist()
			elseif (pose == "fingersSpread") then
				onFingersSpread()
			end
		end
	end

	if (not locked and edge == "off") then
		if (pose == "fist") then
			onFistOff()
		end
	end
end
 
function toggleLock()
	--locked = not locked
	myo.vibrate("short")
	if (not locked) then
		-- Vibrate twice on unlock
		myo.debug("Unlocked")
		myo.controlMouse(true)
		myo.vibrate("short")
	else 
		myo.controlMouse(false)
		myo.debug("Locked")
	end
end
 
function onWaveOut()
	myo.debug("Next")
	--myo.vibrate("short")
	myo.keyboard("tab", "press")
end
 
function onWaveIn()
	myo.debug("Previous")
	--myo.vibrate("short")
	--myo.vibrate("short")
	myo.keyboard("tab","press","shift")
end
 
function onFist()
	myo.debug("Click")	
	myo.vibrate("short")
	myo.mouse("left", "down")
end

function onFistOff()
	myo.debug("Release")
	myo.mouse("left", "up")
end
 
function onFingersSpread()
	myo.debug("Centered")
	--myo.vibrate("long")
	myo.centerMousePosition()
end
 
function conditionallySwapWave(pose)
	if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end