function onCreate()
    makeLuaSprite("coolfilter", "coolfilter", 0.0, 0.0)
    setObjectCamera("coolfilter", "camHUD")
    scaleObject("coolfilter", 1.8, 1.8)
    screenCenter("coolfilter", 'xy')
    addLuaSprite("coolfilter", false)

    makeAnimatedLuaSprite("rain", "rain", 200, 300)
    addAnimationByPrefix("rain", "rain", "rain", 40, true)
    playAnim("rain", "rain", false, false, 0)
    scaleObject("rain", 4.25, 4.25)
    setProperty("rain.antialiasing", false)
	setBlendMode('rain', 'add')
	setProperty('rain.alpha', 0.1)
	setScrollFactor('rain', 1.3, 1.3)
    addLuaSprite("rain", true)
end

function onCreatePost()
    setProperty('camZooming', true)
    setProperty("defaultCamZoom", 0.7)
    setProperty('cameraSpeed', 1.5)
end

function onSongStart()
    cameraFlash("camGame", "FFFFFF", 0.9)
    setProperty("defaultCamZoom", 1)
end

function onStepHit()
    if curStep == 128 or curStep == 256 or curStep == 396 or curStep == 512 or curStep == 1024 or curStep == 1280 or curStep == 1536 or curStep == 1792 or curStep == 1920 or curStep == 2048 or curStep == 2560 then
        cameraFlash("camGame", "FFFFFF", 0.9)
    end

    if curStep == 256 then
        setProperty("defaultCamZoom", 0.7)
    end

    if curStep == 384 or curStep == 512 then
        setProperty("defaultCamZoom", 0.9)
    end

    if curStep == 396 then
        setProperty("defaultCamZoom", 0.7)
    end

    if curStep == 768 or curStep == 1792 then
        setProperty("defaultCamZoom", 0.8)
    end

    if curStep == 1008 then
        setProperty("defaultCamZoom", 1)
        setProperty("cameraSpeed", 2.5)
    end

    if curStep == 1272 then
        setProperty("defaultCamZoom", 1.1)
    end

    if curStep == 1280 then
        setProperty("defaultCamZoom", 1)
    end

    if curStep == 1536 then 
        setProperty("cameraSpeed", 1.5)
    end

    if curStep == 1792 or curStep == 1920 then
        setProperty("cameraSpeed", 1000)
        doTweenZoom("camGame", "camGame", 1.1, (crochet / 1000) * 26, "sineIn")
    end

    if curStep == 1919 then
        setProperty("camZooming", true)
    end

    if curStep == 2048 then
        setProperty("cameraSpeed", 2.5)
    end

    if curStep == 2560 then
        setProperty("defaultCamZoom", 1)
        setProperty("cameraSpeed", 1.5)
    end

    if curStep == 2848 then
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
        cameraFlash("camOther", "FFFFFF", 1.4)
    end
end

function onUpdate(elapsed)
    if (curSection >= 112 and curSection < 119) then
        setProperty("camZooming", false)
    elseif curSection <= 120 then
        setProperty("camZooming", true)
    end
end

function onSectionHit()
	if (curSection >= 112 and curSection <= 126) and curSection % 2 == 0 then
		cameraShake("camHUD", 0.002, (crochet / 1000) * 4)
	end
end

function onEvent(eventName, value1, value2)
    if eventName == 'coolzoom' then
        if value1 == '1' then
            setProperty("defaultCamZoom", value1)
            doTweenZoom("camGame", "camGame", value1, 0.01, 'linear')
        else
            setProperty("defaultCamZoom", tonumber('0.'..value1))
            doTweenZoom("camGame", "camGame", tonumber('0.'..value1), 0.01, 'linear')
        end
    end
end