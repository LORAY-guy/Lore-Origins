function onCreate()
	makeLuaSprite('blackIntro', '', 0, 0)
	setScrollFactor('blackIntro', 0, 0)
	makeGraphic('blackIntro', 2000, 2000, '000000')
	screenCenter('blackIntro', 'xy')
	setProperty('blackIntro.alpha', 0.6)
	setObjectOrder('blackIntro', 50)
	addLuaSprite('blackIntro', true)

    makeLuaSprite('redAlarm', '', 0, 0)
    setObjectCamera('redAlarm', 'camHUD')
	makeGraphic('redAlarm', 1280, 720, 'FF0000')
	screenCenter('redAlarm', 'xy')
	setProperty('redAlarm.alpha', 0)
	addLuaSprite('redAlarm', false)
end

function onCreatePost()
    setProperty('light.visible', false)
end

function onSongStart()
    cameraFlash("camGame", "FFFFFF", 0.9)
    removeLuaSprite("blackIntro", true)
    setProperty('light.visible', true)
end

function onUpdate(elapsed)
    if (curStep >= 125 and curStep < 128) or (curStep >= 520 and curStep < 528) then
        setProperty("cameraSpeed", 100)
        cameraSetTarget("boyfriend")
    end

    if (curStep >= 584 and curStep < 592) or (curStep >= 2376 and curStep < 2384) then
        setProperty("cameraSpeed", 100)
        cameraSetTarget("dad")
    end

    if (curStep >= 2312 and curStep < 2320) then
        setProperty("cameraSpeed", 100)
        cameraSetTarget("gf")
    end
end

function onStepHit()
    if curStep == 110 or curStep == 240 or curStep == 880 or curStep == 1392 or curStep == 1648 or curStep == 2032 or curStep == 2416 or curStep == 2672 then
        setProperty('camZooming', false)
    elseif curStep == 128 or curStep == 256 or curStep == 896 or curStep == 1408 or curStep == 1664 or curStep == 2048 or curStep == 2432 or curStep == 2688 then
        setProperty('camZooming', true)
    end

    if curStep == 110 or curStep == 880 then
        setProperty('defaultCamZoom', 1.0)
        doTweenZoom('camInEpic', 'camGame', 1.0, 0.01, 'linear')
    elseif curStep == 128 or curStep == 896 then
        setProperty('defaultCamZoom', 0.8)
        setProperty('cameraSpeed', 1)
    end

    if curStep == 240 or curStep == 624 or curStep == 1138 or curStep == 1392 or curStep == 1648 or curStep == 2032 or curStep == 2416 or curStep == 2672 then
        setProperty('defaultCamZoom', 1.0)
    elseif curStep == 256 or curStep == 640 or curStep == 1152 or curStep == 1408 or curStep == 1664 or curStep == 2048 or curStep == 2432 or curStep == 2688 then
        setProperty('defaultCamZoom', 0.8)
        setProperty('cameraSpeed', 1)
    end

    if curStep == 128 or curStep == 640 or curStep == 896 or curStep == 1152 or curStep == 1280 or curStep == 1664 or curStep == 2432 or curStep == 2688 or curStep == 2944 then
        cameraFlash("camGame", "FFFFFF", 0.9)
    end

    if curStep == 1280 or curStep == 1920 then
        doTweenZoom("camInCool", "camGame", 1.05, (stepCrochet / 1000) * 112, "cubeInOut")
    end

    if curStep == 2964 then
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
    end
end

function onBeatHit()
    if (curBeat >= 64 and curBeat <= 160) or (curBeat >= 356 and curBeat <= 412) or (curBeat >= 512 and curBeat <= 604) then
        triggerEvent('Add Camera Zoom', '0.06', '0.04')
    end

    if (curBeat >= 224 and curBeat <= 288) then
        triggerEvent('Add Camera Zoom', '0.04', '0.02')
    end

    if (curBeat >= 224 and curBeat <= 288) or (curBeat >= 608 and curBeat < 668) and (curBeat % 4 == 0) then
        triggerEvent('Add Camera Zoom', '0.04', '0.04')
    end
end

function onSectionHit()
    if curSection >= 104 and curSection <= 128 then
        if flashingLights then
            setProperty('redAlarm.alpha', 0.5)
            doTweenAlpha('redGoAway', 'redAlarm', 0, crochet / 1000, 'linear')
        end
    end
end