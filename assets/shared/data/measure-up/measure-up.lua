function onStepHit()
    if curStep == 128 or curStep == 256 or curStep == 384 or curStep == 512 or curStep == 640 or curStep == 768 or curStep == 896 or curStep == 1024 or curStep == 1152 or curStep == 1280 or curStep == 1408 or curStep == 1536 or curStep == 1664 or curStep == 1792 or curStep == 1920 or curStep == 2176 or curStep == 2304 or curStep == 2432 or curStep == 2560 then
        cameraFlash("camGame", "FFFFFF", 1.2, nil)
    end

    if curStep == 240 or curStep == 760 or curStep == 1016 or curStep == 1264 or curStep == 2416 or curStep == 2672 then
        setProperty("cameraSpeed", 1000)
        doTweenZoom("camGame", "camGame", 1, 0.01, "linear")
        setProperty("defaultCamZoom", 1)
    end

    if curStep == 256 or curStep == 768 or curStep == 1280 then
        setProperty("cameraSpeed", 1.75)
        setProperty("defaultCamZoom", 0.75)
    end

    if curStep == 512 or curStep == 1536 or curStep == 2176 then
        setProperty("defaultCamZoom", 0.85)
        setProperty("cameraSpeed", 1000)
    end

    if curStep == 1024 then
        setProperty("cameraSpeed", 1.75)
        setProperty("defaultCamZoom", 0.85)
    end

    if curStep == 1536 then
        doTweenZoom("camGame", "camGame", 1.1, (crochet / 1000) * 32, "sineInOut")
    end

    if curStep == 1660 then
        camLock('dad')
    end

    if curStep == 1668 then
        camLock()
        setProperty("cameraSpeed", 1.75)
        doTweenZoom("camGame", "camGame", 0.85, 0.01, "linear")
        setProperty("defaultCamZoom", 0.85)
    end

    if curStep == 1904 then
        setProperty("defaultCamZoom", 0.8)
        doTweenZoom("camGame", "camGame", 0.8, 0.01, "linear")
        setProperty("cameraSpeed", 1000)
    end

    if curStep == 1920 then
        setProperty("defaultCamZoom", 0.75)
        setProperty("cameraSpeed", 1.75)
    end

    if curStep == 2432 then
        doTweenZoom("camGame", "camGame", 0.85, 0.01, "linear")
        setProperty("defaultCamZoom", 0.85)
        setProperty("cameraSpeed", 1000)
    end

    if curStep == 2688 then
        doTweenZoom("camGame", "camGame", 0.75, 0.01, "linear")
        setProperty("defaultCamZoom", 0.75)
        cameraFlash("camOther", "FFFFFF", 1.2, nil)
    end

    if curStep == 2696 then
        setProperty("camHUD.visible", false, nil)
        setProperty("camGame.visible", false, nil)
    end
end

function onSongStart()
    cameraFlash("camGame", "FFFFFF", 0.9, nil)
end

function onSectionHit()
	if (curSection >= 96 and curSection <= 118) and curSection % 2 == 0 then
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