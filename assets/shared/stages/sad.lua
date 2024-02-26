local chars = {'dad', 'boyfriend', 'gf'}
local sadStuff = {'timerBar', 'countdown'}

local allowCountdown = false
local firstOpening = false

local remainingTheories = ""

local botplaySine = 0

function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'playguy')
	
	makeLuaSprite('wall', 'lore/wall', -320, 0)
	scaleObject("wall", 1.3, 1.3)
	addLuaSprite('wall', false)
	
	makeLuaSprite('floor', 'lore/floor', -350, 950)
	scaleObject("floor", 1.3, 1.3)
	addLuaSprite('floor', false)

	makeLuaSprite("darkStuff", '', 0, 0)
	makeGraphic("darkStuff", 2500, 2500, '000000')
	setProperty("darkStuff.alpha", 0.9)
	addLuaSprite("darkStuff", false)

	makeLuaSprite("spotlightMatpat", 'spotlight', 640, 240)
	setBlendMode("spotlightMatpat", 'add')
	setProperty("spotlightMatpat.alpha", 0.45)
	setObjectOrder("spotlightMatpat", getObjectOrder("gfGroup") + 1)
	setProperty("spotlightMatpat.visible", false)
	addLuaSprite("spotlightMatpat", false)

	makeLuaSprite("spotlightOurpleGuy", 'spotlight', 1370, 240)
	setBlendMode("spotlightOurpleGuy", 'add')
	setProperty("spotlightOurpleGuy.alpha", 0.45)
	setObjectOrder("spotlightOurpleGuy", getObjectOrder("gfGroup") + 1)
	setProperty("spotlightOurpleGuy.visible", false)
	addLuaSprite("spotlightOurpleGuy", false)

	makeLuaSprite("spotlightPhoneGuy", 'spotlight', 1005, 160)
	setBlendMode("spotlightPhoneGuy", 'add')
	setProperty("spotlightPhoneGuy.alpha", 0.45)
	setProperty("spotlightPhoneGuy.visible", false)
	addLuaSprite("spotlightPhoneGuy", false)

	makeLuaSprite("curtains", "lore/curtain", -75, 135)
	scaleObject("curtains", 1.2, 1.2)
	setScrollFactor("curtains", 1.2, 1.2)
	doTweenColor("curtains", "curtains", "444444", 0.01, "linear")
	addLuaSprite("curtains", true)

	makeLuaSprite("blackIntro", '', 0, 0)
	makeGraphic("blackIntro", 1280, 720, '000000')
	screenCenter("blackIntro", 'xy')
	setObjectCamera("blackIntro", 'camOther')
	addLuaSprite("blackIntro", false)

	makeLuaText('tutorialTxt', 'Press \'TAB\' to open the countdown', 300, 10, (getPropertyFromClass("ClientPrefs", "downscroll") == true and 110 or 640))
	setTextColor('tutorialTxt', '00FF00')
	setTextSize('tutorialTxt', 26)
	addLuaText('tutorialTxt', true)

	setProperty("skipCountdown", true)
end

function onCreatePost()
	setObjectOrder("gfGroup", getObjectOrder("darkStuff") - 1)
	setProperty("gfGroup.visible", false)
	setProperty("camHUD.visible", false)
	setProperty("defaultCamZoom", 0.9)
	setProperty("cameraSpeed", 100)

	for i = 1, #chars do
		doTweenColor(chars[i], chars[i], "444444", 0.01, "linear")
	end

	local currentYear, currentMonth, currentDay = os.date("*t").year, os.date("*t").month, os.date("*t").day
	local daysRemaining = os.time({year = 2024, month = 3, day = 9}) - os.time({year = currentYear, month = currentMonth, day = currentDay})
	local weeksRemaining = math.floor(daysRemaining / (7 * 24 * 60 * 60))

	if daysRemaining < 0 then
		remainingTheories = "FAREWELL, MATPAT!"
	else
		remainingTheories = "- "..weeksRemaining.." THEORIES REMAIN -"
	end

	makeLuaSprite("timerBar", "", 0, 420)
	makeGraphic("timerBar", 1280, 120, "FFFFFF")
	screenCenter("timerBar", 'x')
	setObjectCamera("timerBar", "camHUD")
	setProperty("timerBar.alpha", 0)
	addLuaSprite("timerBar", true)

	makeLuaText("countdown", remainingTheories, 1280, 0, 437)
	setTextSize("countdown", 68)
	setTextColor("countdown", "000000")
	setTextBorder("countdown", 1, "000000")
	setTextFont("countdown", "matpat-timer.otf")
	setProperty("countdown.alpha", 0)
	setObjectCamera("countdown", "camHUD")
	screenCenter("countdown", 'x')
	addLuaText("countdown")
end

function onStartCountdown()
	if not allowCountdown then
		runTimer('startSong', 2.6)
		doTweenZoom("epicCamZoom", "camGame", 0.9, 3.5, "sineOut")
		doTweenAlpha("introBackStuff", "blackIntro", 0, 2.5, "quadInOut")
		return Function_Stop
	end
	return Function_Continue
end

function onSongStart()
	cameraFlash("camGame", "FFFFFF", 0.9, nil)
	setProperty("camHUD.visible", true)
	doTweenColor("dadBrub", "dad", 'FFFFFF', 0.01, "linear")
	setProperty("spotlightMatpat.visible", true)
	setProperty("cameraSpeed", 1)
	camLock('dad')
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startSong' then
		allowCountdown = true
		startCountdown()
	end
end

function onTweenCompleted(tag)
	if tag == 'introBackStuff' then
		removeLuaSprite("introBackStuff", true)
	end

	if tag == 'countdownAlpha' then
		blocked = false
	end
end

function onStepHit()
	if curStep == 66 then
		doTweenColor("boyfriendBrub", "boyfriend", 'FFFFFF', 0.01, "linear")
		setProperty("spotlightOurpleGuy.visible", true)
		camLock('boyfriend')
	end

	if curStep == 92 then
		camLock()
	end

	if curStep == 236 or curStep == 1516 or curStep == 2800 then
		setProperty("defaultCamZoom", 1.2)
	end

	if curStep == 256 or curStep == 1536 then
		cameraFlash("camGame", "FFFFFF", 1.2)
		setProperty("defaultCamZoom", 0.7)
	end

	if curStep == 368 or curStep == 1648 then
		setProperty("defaultCamZoom", 0.9)
	end

	if curStep == 384 or curStep == 1664 then
		setProperty("defaultCamZoom", 0.7)
	end

	if curStep == 512 then
		setProperty("defaultCamZoom", 0.9)
	end

	if curStep == 768 then
		setProperty("defaultCamZoom", 0.8)
	end

	if curStep == 1024 then
		setProperty("defaultCamZoom", 1.0)
	end

	if curStep == 1280 or curStep == 2560 then
		setProperty("cameraSpeed", 1000)
		setProperty("defaultCamZoom", 0.9)
		cameraFlash("camGame", "FFFFFF", 1.2)
	end

	if curStep == 1344 or curStep == 1984 or curStep == 2624 then
		setProperty("cameraSpeed", 1)
	end

	if curStep == 1792 then
		cameraFlash("camGame", "FFFFFF", 1.2)
		setProperty("cameraSpeed", 1000)
		setProperty("defaultCamZoom", 0.9)
		doTweenZoom('zoomInPhone', 'camGame', 1.3, (crochet / 1000) * 32, 'quadInOut')
	end

	if curStep == 1920 then
		setProperty("cameraSpeed", 1000)
		setProperty("defaultCamZoom", 1.0)
		cameraFlash("camGame", "FFFFFF", 1.2)
	end

	if curStep == 2032 then
		runHaxeCode([[
			game.camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			game.camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			game.camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
		]])
	end

	if curStep == 2036 then
		setProperty("spotlightPhoneGuy.visible", true)
		setObjectOrder("gfGroup", getObjectOrder("spotlightPhoneGuy") + 1)
		doTweenColor("gfBrub", "gf", 'FFFFFF', 0.01, "linear")
		setProperty("gfGroup.visible", true)
	end

	if curStep == 2688 then
		cameraFlash("camGame", "FFFFFF", 1.2)
	end

	if curStep == 2816 then
		setProperty("defaultCamZoom", 0.7)
		doTweenZoom("camGamePreFinale", "camGame", 0.7, 0.01, "linear")
	end

	if curStep == 2820 then
		doTweenAlpha("camGameFinaleAlpha", "camGame", 0, 2.5, "quadInOut")
		doTweenZoom("camGameFinale", "camGame", 1.4, 2.5, "quadInOut")
	end
end

function onSectionHit()
	if (curSection >= 112 and curSection <= 126) and curSection % 2 == 0 then
		cameraShake("camHUD", 0.002, (crochet / 1000) * 4)
	end
end

function camLock(e)
    if e ~= nil then
        cameraSetTarget(e)
        xPos = getProperty("camFollow.x")
        yPos = getProperty("camFollow.y")
        triggerEvent("Camera Follow Pos", xPos, yPos)
    else
        triggerEvent("Camera Follow Pos", '', '')
    end
end

function onUpdate(elapsed)
	if luaTextExists('tutorialTxt') == true then
		botplaySine = botplaySine + 180 * elapsed
		setProperty('tutorialTxt.alpha', 1 - math.sin((math.pi * botplaySine) / 180)) --actually took that from the Psych source code lol
	elseif botplaySine ~= nil then
		botplaySine = nil
	end

	if firstOpening == true and getProperty('tutorialTxt.alpha') < 0.01 then
		removeLuaText('tutorialTxt', true)
		firstOpening = nil
	end
end

function onUpdatePost(elapsed)
	if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.TAB') and not blocked then
		blocked = true
	
		for i = 1, #sadStuff do
			local sprite = sadStuff[i]
			local alpha = getProperty(sprite..'.alpha')
			local targetAlpha = (alpha == 0) and 1 or 0
			local tweenName = sprite..'Alpha'
	
			doTweenAlpha(tweenName, sprite, targetAlpha, 0.5, 'sineInOut')
		end
	
		if not firstOpening then
			firstOpening = true
		end
	end
end