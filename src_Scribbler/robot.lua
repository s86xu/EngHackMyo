scriptId = 'com.enghack.scribbler'

unlocked = false
appTitle = ""
target = "src_Scribbler"
myo.debug(myo.getArm())

rollCal = 0
pitchCal = 0

MINROLL = -1.5
MAXROLL = 1.5

MAXPITCH = math.pi/2
 
timeSinceFlex = 0
timeSinceWrite = 0

function onForegroundWindowChange(app, title)
    myo.debug("onForegroundWindowChange: " .. app .. ", " .. title)
	appTitle = title
	if string.match(appTitle, target) then
		myo.debug("Active App")
		return true
	else
		return false
	end
end

function activeAppName()
	return appTitle
end

function onPoseEdge(pose, edge)
	myo.debug("onPoseEdge: " .. pose .. ": " .. edge)
	
	pose = conditionallySwapWave(pose)
	
	if (edge == "on") then
		if (pose == "thumbToPinky") then
			onFlex()
		elseif (unlocked) then
			if (pose == "fist") then
				onFist()
			elseif pose == "rest" then
				onRest()
			elseif (pose == "fingersSpread") then
				onFingersSpread()
			end
		end
	end
end
 
function onFlex()
	time = myo.getTimeMilliseconds()
	myo.debug("flex")
	if time - timeSinceFlex < 1000 then
		toggleLock()
	else
		timeSinceFlex = time
	end
end

function toggleLock()
	unlocked = not unlocked
	myo.vibrate("short")
	if (unlocked) then
		-- Vibrate twice on unlock
		myo.debug("Unlocked")
		calibrateGyro()
		myo.vibrate("short")
	else 
		myo.debug("Locked")
		write("0 0")
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
	--calibrateGyro()
	--[[myo.debug("Click")	
	--myo.vibrate("short")
	message = "hello world"
	for i = 1, #message do
		if message:sub(i,i) == " " then
			myo.keyboard("space", "press")
		else
			myo.keyboard(message:sub(i,i), "press")
		end
	end

	myo.keyboard("return", "press")]]
end

function calibrateGyro()
	myo.debug("Calibrate")
	rollCal = myo.getRoll();
	pitchCal = myo.getPitch();
end

function onRest()
	myo.keyboard("w", "up")
end
 
function onFingersSpread()
	--myo.debug("Centered")
	--myo.vibrate("long")
	--myo.centerMousePosition()
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

function onPeriodic()
	time = myo.getTimeMilliseconds()

	if time - timeSinceWrite > 300 then
		timeSinceWrite = time
		pitch = (myo.getPitch() - pitchCal)*1.3

		roll = (myo.getRoll() - rollCal)*1.3
		if (roll > 0) then
			roll = roll*1.5
		end
			
		
		if (unlocked) then
			message = tostring(round(roll, 3)).." "..tostring(round(pitch, 3))
			write(message)
		end 
	end
	--myo.debug("Roll: "..roll.." Pitch: "..pitch)
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function write(message)
			myo.debug(message)
			for i = 1, #message do
				c = message:sub(i,i)
				if c == " " then
					myo.keyboard("space", "press")
				elseif c=="-" then
					myo.keyboard("minus", "press")
				elseif c=="." then
					myo.keyboard("period", "press")
				else
					myo.keyboard(c, "press")
				end
			end

			myo.keyboard("return", "press")
end