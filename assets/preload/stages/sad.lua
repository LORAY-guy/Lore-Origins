local chars = {'dad', 'boyfriend', 'gf'}
local allowCountdown = false

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
end

function onStartCountdown()
	if not allowCountdown then
		runTimer('startSong', 2.6)
		doTweenZoom("epicCamZoom", "camGame", 0.9, 3.5, "sineOut")
		doTweenAlpha("introBackStuff", "blackIntro", 0, 2.5, "quadInOut")
		return Function_Stop;
	end
	return Function_Continue;
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