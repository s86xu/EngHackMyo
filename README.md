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

