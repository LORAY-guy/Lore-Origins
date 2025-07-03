function onCreate()
    setProperty('skipCountdown', true)
end

function onCreatePost()
    setProperty("camHUD.alpha", 0)

    setProperty("isCameraOnForcedPos", true)
    setProperty("cameraSpeed", 1000)
    setProperty("camFollow.y", getProperty("camFollow.y") - 3750)
    setProperty('defaultCamZoom', 0.3)
    setProperty("camGame.zoom", 0.3)
    doTweenZoom("camGameZoomOut", "camGame", 0.175, (stepCrochet / 1000) * 96, "quadInOut")

    setProperty("gfGroup.flipX", true)
    setProperty("gfGroup.alpha", 0)
    setProperty("dadGroup.visible", false)
    setProperty("gfGroup.x", getProperty("gfGroup.x") + 1200)
    setProperty("iconP2.visible", false)
end

function onSongStart()
    setProperty("cameraSpeed", 1)
    cameraFlash("camGame", "FFFFFF", 2)
end

function onStepHit()
    if curStep == 112 then
        setProperty("isCameraOnForcedPos", false)
        setProperty('defaultCamZoom', 0.2)
        doTweenAlpha("camHUDAlpha", "camHUD", 1, (stepCrochet / 1000) * 16, "linear")
    end

    if curStep == 128 then
        setProperty("camZooming", true)
    end

    if curStep == 256 then
        setProperty('defaultCamZoom', 0.25)
        doTweenAlpha("luaIllusionAppear", "gfGroup", 0.2, (stepCrochet / 1000) * 16, "fadeIn")
        triggerEvent("Camera Follow Pos", getProperty("camFollow.x") + 250, getProperty("camFollow.y"))
    end

    if curStep == 384 then
        triggerEvent("Camera Follow Pos", "", "")
        setProperty('defaultCamZoom', 0.4)
    end

    if curStep == 448 then
        triggerEvent("Camera Follow Pos", getProperty("camFollow.x") + 250, getProperty("camFollow.y"))
        setProperty('defaultCamZoom', 0.5)
    end

    if curStep == 480 then
        setProperty('defaultCamZoom', 0.7)
    end

    if curStep == 496 then
        triggerEvent("Camera Follow Pos", "", "")
        setProperty("cameraSpeed", 2)
        setProperty("dadGroup.visible", true)
        setProperty("iconP2.visible", true)
        setProperty("luaRTX.visible", true)
        doTweenAlpha("luaIllusionDisappear", "gfGroup", 0, (stepCrochet / 1000) * 8, "fadeOut")
    end

    if curStep == 512 then
        setProperty("cameraSpeed", 1)
        setProperty("gfGroup.visible", false)
        setProperty("defaultCamZoom", 0.4)
    end

    if curStep == 784 then
        doTweenZoom("luaFocusZoomIn", "camGame", 0.7, (stepCrochet / 1000) * 96, "sineInOut")
    end

    if curStep == 880 then
        setProperty("defaultCamZoom", 0.5)
    end

    if curStep == 1136 then
        setProperty("defaultCamZoom", 0.6)
    end

    if curStep == 1152 then
        cameraFlash("camGame", "FFFFFF", 2, true)
        setProperty("defaultCamZoom", 0.4)
        setProperty("cameraSpeed", 1000)
        setProperty("camGame.zoom", 0.4)
        doTweenZoom("LORAYFocusZoomIn", "camGame", 0.25, (stepCrochet / 1000) * 96, "sineInOut")
    end

    if curStep == 1248 then
        setProperty("defaultCamZoom", 0.225)
        setProperty("cameraSpeed", 2)
    end

    if curStep == 1306 or curStep == 1310 or curStep == 1338 or curStep == 1342 or curStep == 1370 or curStep == 1374 then
        triggerEvent("Add Camera Zoom", "0.02", "0.02")
    end

    if curStep == 1396 or curStep == 1400 or curStep == 1404 or curStep == 1405 or curStep == 1406 or curStep == 1407 then
        triggerEvent("Add Camera Zoom", "0.02", "0.02")
    end

    if curStep == 1568 then
        setProperty("defaultCamZoom", 0.225)
    end

    if curStep == 1576 then
        setProperty("defaultCamZoom", 0.25)
    end

    if curStep == 1584 then
        setProperty("defaultCamZoom", 0.2)
    end

    if curStep == 1632 then
        setProperty("defaultCamZoom", 0.25)
    end

    if curStep == 1664 then
        setProperty("defaultCamZoom", 0.2)
        triggerEvent("Camera Follow Pos", getProperty("camFollow.x") + 235, getProperty("camFollow.y"))
        doTweenZoom("BothFocusZoomIn", "camGame", 0.25, (stepCrochet / 1000) * 96, "sineInOut")
    end

    if curStep == 1760 then
        setProperty("defaultCamZoom", 0.25)
    end

    if curStep == 1792 then
        setProperty("defaultCamZoom", 0.2)
    end

    if curStep == 1808 then
        setProperty("cameraSpeed", 2)
        triggerEvent("Camera Follow Pos", "", "")
    end

    if curStep == 1816 then
        setProperty("defaultCamZoom", 0.25)
    end

    if curStep == 1824 then
        setProperty("cameraSpeed", 1)
        setProperty("defaultCamZoom", 0.4)
    end
    
    if curStep == 2080 then
        setProperty("defaultCamZoom", 0.2)
    end

    if curStep == 2336 then
        setProperty("defaultCamZoom", 0.175)
        triggerEvent("Camera Follow Pos", getProperty("camFollow.x") + 235, getProperty("camFollow.y"))
        setProperty("isCameraOnForcedPos", true)
        doTweenAlpha("camHUDAlphaOut", "camHUD", 0, (stepCrochet / 1000) * 16, "linear")
    end

    if curStep == 2344 then
        doTweenY("up", "camFollow", getProperty("camFollow.y") - 3750, (stepCrochet / 1000) * 16, "sineInOut")
    end

    if curStep == 2368 then
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
        cameraFlash("camOther", "FFFFFF", 3, true)
    end
end

function onBeatHit()
    if (curBeat >= 128 and curBeat < 192) then
        triggerEvent("Add Camera Zoom", "0.02", "0.02")
    end

    if (curBeat >= 224 and curBeat < 284) and (curBeat % 2 == 0) then
        triggerEvent("Add Camera Zoom", "0.02", "0.02")
    end

    if (curBeat >= 320 and curBeat < 348) then
        triggerEvent("Add Camera Zoom", "0.02", "0.02")
    end

    if (curBeat >= 352 and curBeat < 448) and (curBeat % 2 ~= 0) then
        triggerEvent("Add Camera Zoom", "0.02", "0.02")
    end

    if (curBeat >= 456 and curBeat < 584) then
        triggerEvent("Add Camera Zoom", "0.02", "0.02")
    end
end