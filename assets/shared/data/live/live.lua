local boom = false

function onCreate()
    makeLuaSprite("blackIntro", '', 0, 0)
    makeGraphic("blackIntro", 1280, 720, '000000')
    setObjectCamera("blackIntro", 'camHUD')
    setObjectOrder("blackIntro", 0)
    screenCenter("blackIntro", 'xy')
    addLuaSprite("blackIntro", false)

    makeAnimatedLuaSprite("dronecall", 'characters/drone_intro', 20, 100)
    addAnimationByIndicesLoop("dronecall", "idle", "calling drone", '0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17', 24)
    setProperty("dronecall.visible", false)
    addLuaSprite("dronecall", false)

    makeLuaSprite("drone", 'drone', -900, 130)
    setProperty("drone.angle", 50)
    addLuaSprite("drone", false)

    makeAnimatedLuaSprite("explosion", 'explosion', 450, 475)
    scaleObject("explosion", 2.5, 2.5)
    addAnimationByPrefix("explosion", "boom", "explosion idle", 24, false)
    setProperty("explosion.visible", false)
    addLuaSprite("explosion", false)

    precacheSound("explosion")
end

function onCreatePost()
    camSpeed = getProperty("cameraSpeed")
    camZoom = getProperty("defaultCamZoom")
    setProperty("gf.visible", false)
end

function onSongStart()
    removeLuaSprite("blackIntro", true)
    cameraFlash("camHUD", "ffffff", 0.9)
    setProperty("cameraSpeed", 100)
    setProperty("defaultCamZoom", 1)
    doTweenZoom("camGameZoomInIntro", "camGame", 1, 0.01, "linear")
    camLock('dad')
end

function onStepHit()
    if curStep == 132 or curStep == 1924 or curStep == 3460 then
        camLock('boyfriend')
    end

    if curStep == 246 or curStep == 2038 or curStep == 3520 then
        camLock('dad')
    end

    if curStep == 256 or curStep == 2048 then
        camLock()
        cameraFlash("camHUD", "ffffff", 0.9)
        setProperty("defaultCamZoom", 0.75)
        doTweenZoom("camGameZoomOutCool", "camGame", 0.75, 0.01, "linear")
        setProperty("cameraSpeed", camSpeed)
    end

    if curStep == 368 or curStep == 2160 then
        setProperty("defaultCamZoom", 0.9)
    end

    if curStep == 384 or curStep == 2176 then
        setProperty("defaultCamZoom", 0.75)
        doTweenZoom("camGameZoomOutCool", "camGame", 0.75, 0.01, "linear")
    end

    if curStep == 768 then
        setProperty("defaultCamZoom", 0.9)
        setProperty("cameraSpeed", 100)
    end

    if curStep == 1024 then
        setProperty("cameraSpeed", camSpeed)
        setProperty("defaultCamZoom", camZoom)
    end

    if curStep == 1152 or curStep == 1154 or curStep == 1216 or curStep == 1218 then
        triggerEvent("Add Camera Zoom", 0.06, 0.04)
    end

    if curStep == 1272 then
        setProperty("defaultCamZoom", 1)
        doTweenZoom("camGameZoomInIntro", "camGame", 1, 0.01, "linear") 
    end

    if curStep == 1280 then
        cameraFlash("camHUD", "ffffff", 0.9)
        setProperty("defaultCamZoom", camZoom)
    end

    if curStep == 1792 or curStep == 3328 then
        cameraFlash("camHUD", "ffffff", 0.9)
        setProperty("cameraSpeed", 100)
        setProperty("defaultCamZoom", 1)
        doTweenZoom("camGameZoomInIntro", "camGame", 1, 0.01, "linear") 
        camLock('dad')
    end

    if curStep == 2560 then
        setProperty("cameraSpeed", camSpeed)
    end

    if curStep == 2560 then
        doTweenZoom("coolZoomInPhone", "camGame", 1, (crochet / 1000) * 32, "easeIn")
    end

    if curStep == 2576 then
        droneIntro()
    end

    if curStep == 2688 then
        cameraFlash("camHUD", "ffffff", 0.9)
    end

    if curStep == 2790 then
        setProperty("gf.visible", true)
        triggerEvent("Play Animation", "welcome", "gf")
    end

    if curStep == 2792 then   
        doTweenY("droneCrash", "drone", 720, 0.2, "bounceOut")
        doTweenAngle("droneCrashAngle", "drone", 180, 0.2, "cubeIn")
    end 

    if curStep == 2800 or curStep == 2928 or curStep == 3072 then
        setProperty("cameraSpeed", 100)
        setProperty("defaultCamZoom", 1)
        doTweenZoom("camGameZoomInIntro", "camGame", 1, 0.01, "linear") 
    end

    if curStep == 2816 or curStep == 2944 or curStep == 3088 then
        cameraFlash("camHUD", "ffffff", 0.9)
        setProperty("cameraSpeed", camSpeed)
        setProperty("defaultCamZoom", 0.75)
    end

    if curStep == 3200 then
        setProperty("cameraSpeed", 100)
    end

    if curStep == 3264 or curStep == 3280 or curStep == 3296 then
        setProperty("defaultCamZoom", getProperty("defaultCamZoom") + 0.1)
        doTweenZoom("camGameZoomOutCool", "camGame", getProperty("defaultCamZoom") + 0.1, 0.01, "linear")
    end

    if curStep == 3296 or curStep == 3312 then
        camLock('dad')
    elseif curStep == 3304 or curStep == 3320 then
        camLock('boyfriend')
    end

    if curStep == 3584 then
        setProperty("defaultCamZoom", 0.75)
        doTweenZoom("camGameZoomOutCool", "camGame", 0.75, 0.01, "linear")
    end

    if curStep == 3600 then
        setProperty("defaultCamZoom", 1)
        doTweenZoom("camGameZoomInIntro", "camGame", 1, 0.01, "linear") 
    end

    if curStep == 3612 then
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
    end

    if (curSection == 86 or curSection == 94 or curSection == 100 or curSection == 108 or curSection == 175 or curSection == 183) then
        triggerEvent("Add Camera Zoom", 0.01, 0.01)
    end
end

function onBeatHit()
    if (curBeat >= 1 and curBeat < 64) or (curBeat >= 448 and curBeat < 512) or (curBeat >= 832 and curBeat < 896) and (curBeat % 2 == 0) then
        triggerEvent("Add Camera Zoom", 0.02, 0.02)
    end

    if (curBeat >= 64 and curBeat < 192) or (curBeat >= 512 and curBeat < 640) then
        triggerEvent("Add Camera Zoom", 0.04, 0.04)
    end

    if (curBeat >= 192 and curBeat < 320) or (curBeat >= 704 and curBeat < 732) or (curBeat >= 736 and curBeat < 768) then
        triggerEvent("Add Camera Zoom", 0.04, 0.02)
    end

    if (curBeat >= 320 and curBeat < 448) and (curBeat % 2 == 0) then
        triggerEvent("Add Camera Zoom", 0.02, 0.02)
    end

    if (curBeat >= 640 and curBeat < 672) and (curBeat % 2 == 0) then
        triggerEvent("Add Camera Zoom", 0.02, 0.04)
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

function droneIntro()
    setProperty("dronecall.visible", true)
    objectPlayAnimation("dronecall", "idle", false)
    runTimer('droneWait', (crochet / 1000) * 44)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'droneWait' then
        doTweenX("droneComininHot", "drone", 460, 2.5, "cubeOut")
        doTweenAngle("droneComingBackUp", "drone", 0, 2.5, "cubeOut")
        runTimer('disappearThingy', 2)
    end

    if tag == 'disappearThingy' then
        removeLuaSprite("dronecall", true)
    end

    if tag == 'explosionDisappear' then
        removeLuaSprite("explosion", true)
    end
end

function onTweenCompleted(tag)
    if tag == 'droneCrash' then
        setProperty("explosion.visible", true)
        objectPlayAnimation("explosion", "boom", false)
        playSound("explosion", 0.7)
        boom = true
        removeLuaSprite("drone", true)
        runTimer("explosionDisappear", 0.4)
    end
end