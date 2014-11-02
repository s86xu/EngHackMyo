scriptId = 'com.enghack.scribbler'

unlocked = false
appTitle = ""
target = "src_Scribbler"

rollCal = 0
pitchCal = 0
 
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
	
	if (edge == "on") then
		if (pose == "thumbToPinky") then
			onFlex()
		end
	end
end
 
function onFlex()
	time = myo.getTimeMilliseconds()
	myo.debug("flex")
	if time - timeSinceFlex < 600 and time - timeSinceFlex > 200 then
		toggleLock()
		timeSinceFlex = time-1000
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
		calibrate()
		myo.vibrate("short")
	else 
		myo.debug("Locked")
		write("0 0")
	end
end

function calibrate()
	myo.debug("Calibrate")
	rollCal = myo.getRoll();
	pitchCal = myo.getPitch();
end
 
function onPeriodic()
	time = myo.getTimeMilliseconds()

	if time - timeSinceWrite > 300 then
		timeSinceWrite = time
		pitch = (myo.getPitch() - pitchCal)*1.3
		if (pitch > 0) then
			pitch = pitch*1.2
		end

		roll = (myo.getRoll() - rollCal)*1.3
		if (roll > 0) then
			roll = roll*1.5
		end
			
		
		if (unlocked) then
			message = tostring(round(roll, 3)).." "..tostring(round(pitch, 3))
			write(message)
		end 
	end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function write(message)
			myo.debug("Write: "..message)
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