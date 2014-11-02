EngHackMyo
==========
scriptId = 'com.thalmic.examples.myfirstscript'
 
locked = true
appTitle = ""
YOUTUBE = " - YouTube - Google Chrome"
 
function onForegroundWindowChange(app, title)
    myo.debug("onForegroundWindowChange: " .. app .. ", " .. title)
	appTitle = title
	--if string.sub(appTitle, -string.len(YOUTUBE))==YOUTUBE then
	--	myo.debug("Youtube!!")
	--	return true
	--end
    return false
end
 
function activeAppName()
	return appTitle
end

function onPoseEdge(pose, edge)
	myo.debug("onPoseEdge: " .. pose .. ": " .. edge)
	
	pose = conditionallySwapWave(pose)

	if (pose == "fist") and (edge == "on") then
		myo.keyboard("f", "press")
		myo.keyboard("return", "press")

	if (pose == "waveIn") and (edge == "on") then
		myo.keyboard("t", "press")
		myo.keyboard("return", "press")
		rollValue = math.floor(((myo.getRoll() / 3.18) * 10^3 + 0.5) / 10^3)
		--add parsing so you output this number 1 at a time
		--myo.keyboard(number, "press")
		--myo.keyboard("return", "press")
	if (pose == "waveOut") and (edge == "on") then
		myo.keyboard("b", "press")
		myo.keyboard("return", "press")

	if (edge == "on") then
		if (pose == "thumbToPinky") then
			toggleLock()
		elseif (not locked) then
			if (pose == "fist") then
				onFist()
			end
		end
	end
end
 
function toggleLock()
	locked = not locked
	myo.vibrate("short")
	if (not locked) then
		-- Vibrate twice on unlock
		myo.debug("Unlocked")
		myo.vibrate("short")
	else 
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
	myo.debug("Space")	
	--myo.vibrate("medium")
	myo.keyboard("space","press")
end
 
function onFingersSpread()
	myo.debug("Escape")
	--myo.vibrate("long")
	myo.keyboard("escape", "press")
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
