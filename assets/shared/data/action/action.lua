local isBoth = false
local jingleStep = -100
local flick = false

--[[ 
-- TO ANYONE WHO WANTS TO USE THE ARROW WAVE MECHANIC, YOU LITERALLY CAN'T
-- I MODIFIED THE TWEENS FUNCTIONS IN SOURCE TO ADD A START DELAY
-- UNLESS YOU DO THAT YOURSELF ON YOUR OWN BUILD, COPYING THE CODE IN ANY WAYS WON'T WORK
--]]

function onCreate()
    makeLuaSprite("screen", "action/screen", 325, 400)
    setObjectOrder("screen", 2)
    scaleObject("screen", 1, 0.75)
    updateHitbox("screen")
    addLuaSprite("screen")
    setProperty("screen.y", -600) -- Precaching purposes

    makeLuaSprite("sky", "action/paradise", -750, -625)
    setScrollFactor("sky", 0.2, 0.2)
    scaleObject("sky", 4, 4)
    updateHitbox("sky")
    setProperty("sky.antialiasing", false)
    setProperty("sky.visible", false)
    addLuaSprite("sky")

    makeLuaSprite("skyfloor", "", -700, 1000)
    makeGraphic("skyfloor", 4000, 1500, "FFFFFF")
    setProperty("skyfloor.visible", false)
    addLuaSprite("skyfloor", false)

    makeLuaSprite("bg", "action/bg", -100, -100)
    setScrollFactor("bg", 0.8, 0.8)
    scaleObject("bg", 3.8, 3.8)
    updateHitbox("bg")
    setProperty("bg.antialiasing", false)
    addLuaSprite("bg")
    setProperty("bg.visible", false)

    makeLuaSprite("bg1", "action/bg1", -200, -100)
    scaleObject("bg1", 3.8, 3.8)
    updateHitbox("bg1")
    setProperty("bg1.antialiasing", false)
    addLuaSprite("bg1")
    setProperty("bg1.visible", false)

    makeLuaSprite("coolfilter", "coolfilter", 0.0, 0.0)
    setObjectCamera("coolfilter", "camHUD")
    scaleObject("coolfilter", 1.8, 1.8)
    screenCenter("coolfilter", 'xy')
    addLuaSprite("coolfilter", false)
    setProperty("coolfilter.visible", false)

    makeLuaSprite("bOverlay", "", 0, 0)
    makeGraphic("bOverlay", 1280, 720, "000000")
    setObjectCamera("bOverlay", "camOther")
    addLuaSprite("bOverlay")

    makeLuaText("subtitles", "", 1280, 0, 520)
    setTextFont("subtitles", "ourple.ttf")
    setTextSize("subtitles", 48)
    setObjectCamera("subtitles", "camOther")
    screenCenter("subtitles", 'x')
    setProperty("subtitles.visible", false)
    addLuaText("subtitles")

    if not lowQuality then -- This takes 500Mb of RAM, which is a no-no for some computers
        makeLuaSprite('vcrshit', 'vcrshit', 0, 0)
        setObjectCamera('vcrshit', 'camHUD')
        scaleObject("vcrshit", 1.075, 1.075)
        updateHitbox("vcrshit")
        screenCenter("vcrshit")
        setProperty('vcrshit.visible', false)
        addLuaSprite('vcrshit', false)

        makeLuaSprite('redboob','red', 167, 59)
        setObjectCamera('redboob', 'camHUD')
        scaleObject('redboob', 0.8, 0.8)
        setProperty('redboob.visible', false)
        addLuaSprite('redboob', false)

        makeAnimatedLuaSprite('monitor', 'monitor', 0, 0)
        addAnimationByPrefix('monitor', 'open', 'Open', 24, false)
        addAnimationByIndices('monitor', 'nothing', 'Close', '0', 24)
        addAnimationByPrefix('monitor', 'close', 'Close', 24, false)
        objectPlayAnimation('monitor', 'nothing', false)
        setObjectCamera('monitor', 'camHUD')
        screenCenter('monitor', 'xy')
        updateHitbox('monitor')
        addLuaSprite('monitor')
        setProperty('monitor.visible', false)
    end

    setProperty("skipCountdown", true)
end

function onCreatePost()
    setProperty("camHUD.visible", false)
    setProperty("cameraSpeed", 2)
end

function onSongStart()
    doTweenAlpha("bOverlay", "bOverlay", 0, (crochet / 1000) * 32, "sineInOut", 0.7)
    doTweenZoom("camGameInStart", "camGame", 1, (crochet / 1000) * 28, "sineInOut", 0.7)
end

function onStepHit()
    ------------- Camera Flashes -------------
    if curStep == 128 or curStep == 256 or curStep == 384 or curStep == 512 or curStep == 640 or curStep == 772 or curStep == 912 or curStep == 1040 or curStep == 1408 or curStep == 1664 or curStep == 1792 or curStep == 1824 or curStep == 1856 or curStep == 1920 or curStep == 2048 or curStep == 2176 or curStep == 2336 or curStep == 2464 or curStep == 2592 or curStep == 2720 or curStep == 2848 or curStep == 2976 then
        cameraFlash("camHUD", "FFFFFF", 0.9)
    end

    if flashingLights then -- Additional flashes. Nothing is worth the risk
        if curStep == 576 or curStep == 592 or curStep == 620 or curStep == 1504 or curStep == 1510 or curStep == 1516 or curStep == 1524 or curStep == 1532 or curStep == 2542 or curStep == 2546 or curStep == 2798 or curStep == 2802 then
            cameraFlash("camHUD", "FFFFFF", 0.6)
        end

        if curStep == 608 then
            cameraFlash("camHUD", "FFFFFF", 0.4)
        end
    end
    ------------------------------------------

    ------------- Camera Zooms (manual) -------------
    if curStep == 2542 or curStep == 2546 or curStep == 2550 or curStep == 2798 or curStep == 2802 or curStep == 2806 then
        setProperty("camGame.zoom", getProperty("camGame.zoom") + 0.09)
        setProperty("camHUD.zoom", getProperty("camHUD.zoom") + 0.06)
    end

    if curStep == 1504 or curStep == 1510 or curStep == 1516 or curStep == 1524 or curStep == 1532 then 
        coolCameraEffect(1, true)
    end
    -------------------------------------------------

    ------------------------------------------------------------------------------------------------------

    if curStep == 128 then
        setProperty("camHUD.visible", true)
    end

    if curStep == 384 or curStep == 768 then
        setProperty("camGame.zoom", 0.95)
        setProperty("defaultCamZoom", 0.95)
    end

    if curStep == 640 then
        removeLuaText("subtitles", true)
        setProperty("bOverlay.alpha", 0)
        setProperty("camGame.zoom", 0.7)
        setProperty("defaultCamZoom", 0.7)
    end

    if curStep == 772 or curStep == 912 or curStep == 1040 or curStep == 1824 or curStep == 1856 or curStep == 2048 then
        setProperty("defaultCamZoom", 0.7)
    end

    if curStep == 896 or curStep == 1024 or curStep == 1152 or curStep == 1812 or curStep == 1838 then
        setProperty("camGame.zoom", 1)
        setProperty("defaultCamZoom", 1)
    end

    if curStep == 1148 then
        setObjectCamera("bOverlay", 'camHUD')
        doTweenAlpha("bOverlayIn", "bOverlay", 1, crochet / 1000, "quadOut")
        doTweenZoom("camGameZoomQuickZoomIn", "camGame", 1, crochet / 1000, "expoIn")
    end

    if curStep == 1152 then
        doTweenAlpha("bOverlayOut", "bOverlay", 0, (crochet / 1000) * 62, "sineInOut")
        doTweenZoom("camGameZoomOut", "camGame", 0.675, (crochet / 1000) * 62, "sineInOut")
    end

    if curStep == 1280 or curStep == 2240 then
        doTweenY("greenScreenEntering", "screen", 200, (crochet / 1000) * 28, "linear")
    end

    if curStep == 1400 or curStep == 2032 then
        setProperty("defaultCamZoom", 1)
    end

    if curStep == 1408 or curStep == 2336 then
        setProperty("sky.visible", true)
        setProperty("skyfloor.visible", true)
        setProperty("defaultCamZoom", 0.55)
    end

    if curStep == 1648 then
        doTweenZoom("camGameQuickZoomIn", "camGame", 5, (crochet / 1000) * 4, "expoIn")
    end

    if curStep == 1664 or curStep == 2720 then
        setProperty("sky.visible", false) -- Might use them later on actually
        setProperty("skyfloor.visible", false)
        setProperty("bg.visible", true)
        setProperty("bg1.visible", true)
        setProperty("coolfilter.visible", true)
        cancelTween("camGameQuickZoomIn")
        setProperty("camGame.zoom", 0.65)
        setProperty("defaultCamZoom", 0.65)
        setProperty("cameraSpeed", 2.5)
    end

    if curStep == 1788 then
        doTweenAlpha("bOverlayIn", "bOverlay", 1, crochet / 1000, "quadOut")
    end

    if curStep == 1792 then
        cancelTween("bOverlayIn")
        setProperty("bOverlay.alpha", 0)
        setProperty("bg.visible", false)
        setProperty("bg1.visible", false)
        setProperty("coolfilter.visible", false)
        doTweenY("greenScreenLeaving", "screen", -600, (crochet / 1000) * 28, "linear")
        setProperty("cameraSpeed", 2)
        setProperty("camGame.zoom", 0.7)
        setProperty("defaultCamZoom", 0.7)
    end

    if curStep == 2048 then
        setProperty("cameraSpeed", 10000)
        setProperty("camGame.zoom", 0.7)
        setProperty("defaultCamZoom", 0.7)
        setProperty("camZooming", false)
        doTweenZoom("camGameZoomInPhone", "camGame", 1, (crochet / 1000) * 31, "linear")
    end

    if curStep == 2176 then
        cancelTween("camGameZoomInPhone")
        setProperty("cameraSpeed", 2)
        setProperty("camGame.zoom", 0.8)
    end

    if curStep == 2304 then
        setProperty("cameraSpeed", 10000)
        setProperty("camZooming", false)
        doTweenZoom("camGameZoomInPhone", "camGame", 0.9, (crochet / 1000) * 2, "sineOut")
    end

    if curStep == 2312 then
        cancelTween("camGameZoomInPhone")
        setProperty("camGame.zoom", 0.8)
        setProperty("defaultCamZoom", 0.8)
    end

    if curStep == 2320 then
        setProperty("camGame.zoom", 0.7)
        setProperty("defaultCamZoom", 0.7)
    end

    if curStep == 2336 then
        setProperty("camZooming", true)
        setProperty("cameraSpeed", 2)
    end

    if curStep == 2550 or curStep == 2806 then
        setProperty("bOverlay.alpha", 1)
        doTweenAlpha("bOverlayCoolEffect", "bOverlay", 0, (stepCrochet / 1000) * 10, "linear")
    end

    if curStep == 2170 then
        setProperty("defaultCamZoom", 0.65)
    end

    if curStep == 2848 then
        setProperty("bg.visible", false)
        setProperty("bg1.visible", false)
        setProperty("coolfilter.visible", false)
        doTweenY("greenScreenLeaving", "screen", -600, (crochet / 1000) * 28, "linear")
        setProperty("cameraSpeed", 2)
        setProperty("camGame.zoom", 0.9)
        setProperty("defaultCamZoom", 0.9)
    end

    if curStep == 3090 then
        setProperty("defaultCamZoom", 0.9)
    end

    if curStep == 3104 then
        setProperty("defaultCamZoom", 0.7)
    end

    if not lowQuality then
        if curStep == 1402 or curStep == 2330 then
            setProperty('monitor.visible', true)
            objectPlayAnimation('monitor', 'open', false)
        end

        if curStep == 1408 or curStep == 2336 then
            setProperty('vcrshit.visible', true)
            setProperty('monitor.visible', false)
            setProperty("curtains.visible", false)
        end

        if curStep == 1792 or curStep == 2848 then
            setProperty('monitor.visible', true)
            objectPlayAnimation('monitor', 'close', false)
            setProperty("curtains.visible", true)
            setProperty('vcrshit.visible', false)
            setProperty('redboob.visible', false)
        end

        if curStep == 1798 or curStep == 2854 then
            setProperty('monitor.visible', false)
        end

        if getProperty('vcrshit.visible') == true and curStep % 4 == 0 then
            setProperty('redboob.visible', flick)
            flick = not flick
        end
    end

    if curStep == 3136 then
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
    end

    ------------------------------------------------------------------------------------------------------

    --For the weird timer thing cuz using stepCrochets doesn't fucking works
    if curStep == (jingleStep + 7) then
        coolArrowWaveEffectPlayer(true)
    elseif curStep == (jingleStep + 14) then
        coolArrowWaveEffectOpponent(true)
    elseif curStep == (jingleStep + 17) then
        coolArrowWaveEffectPlayer(false)
    elseif curStep == (jingleStep + 23) then
        coolArrowWaveEffectOpponent(false)
        if isBoth then
            coolArrowWaveEffectPlayer(true)
            isBoth = false
        else
            isBoth = true
        end
    elseif curStep == (jingleStep + 32) and isBoth then
        noteJingle()
    end
end

function onBeatHit()
    if ((curBeat >= 32 and curBeat < 96) or (curBeat >= 544 and curBeat < 576) or (curBeat >= 712 and curBeat <= 772)) and curBeat % 2 == 0 then
        setProperty("camGame.zoom", getProperty("camGame.zoom") + 0.06)
        setProperty("camHUD.zoom", getProperty("camHUD.zoom") + 0.03)
    end

    if (curBeat >= 96 and curBeat < 128) and curBeat % 4 == 0 then
        setProperty("camGame.zoom", getProperty("camGame.zoom") + 0.06)
        setProperty("camHUD.zoom", getProperty("camHUD.zoom") + 0.03)
    end

    if (curBeat >= 128 and curBeat < 144) and curBeat % 2 == 0 then
        coolCameraEffect(1, true)
    end

    if ((curBeat >= 144 and curBeat < 156) or (curBeat >= 159 and curBeat < 192) or (curBeat >= 193 and curBeat < 224) or (curBeat >= 228 and curBeat < 256) or (curBeat >= 260 and curBeat < 287) or (curBeat >= 352 and curBeat < 376) or (curBeat >= 384 and curBeat < 416) or (curBeat >= 464 and curBeat < 508) or (curBeat >= 584 and curBeat < 636) or (curBeat >= 640 and curBeat < 700) or (curBeat >= 704 and curBeat < 712)) then
        coolCameraEffect(1, true)
    end

    if (curBeat >= 456 and curBeat < 459) then
        setProperty("camGame.zoom", getProperty("camGame.zoom") + 0.06)
        setProperty("camHUD.zoom", getProperty("camHUD.zoom") + 0.03)
    end 

    if curBeat == 176 or curBeat == 208 or curBeat == 240 or curBeat == 272 or curBeat == 600 or curBeat == 632 then
        noteJingle()
    end
end

local mult = 1
function coolCameraEffect(power, zoom)
    cancelTween("camGameEffect")
    cancelTween("camHUDEffect")
    if zoom then
        setProperty("camGame.zoom", getProperty("camGame.zoom") + power / 10)
        setProperty("camHUD.zoom", getProperty("camHUD.zoom") + (power / 10) / 2)
    end
    setProperty("camGame.angle", power * mult)
    setProperty("camHUD.angle", power * -mult)
    doTweenAngle("camGameEffect", "camGame", 0, (stepCrochet / 1000) * 6, "sineOut")
    doTweenAngle("camHUDEffect", "camHUD", 0, (stepCrochet / 1000) * 6, "sineOut")
    mult = -mult
end

function noteJingle()
    coolArrowWaveEffectOpponent(false)
    jingleStep = curStep
end

function coolArrowWaveEffectOpponent(inv)
    local num = 0
    if not inv then
        for i = 0, 3 do
            noteTweenY("coolArrowWaveOpponent"..i, i, _G['defaultOpponentStrumY'..i] - 25, 0.075, "sineOut", (0.035 * i))
        end
    else
        for i = 3, 0, -1 do
            noteTweenY("coolArrowWaveOpponent"..i, i, _G['defaultOpponentStrumY'..i] - 25, 0.075, "sineOut", (0.035 * num))
            num = num + 1
        end
    end
end

function coolArrowWaveEffectPlayer(inv)
    local num = 0
    if not inv then
        for i = 4, 7 do
            noteTweenY("coolArrowWavePlayer"..i, i, _G['defaultPlayerStrumY'..(i - 4)] - 25, 0.075, "sineOut", (0.035 * i))
        end
    else
        for i = 7, 4, -1 do
            noteTweenY("coolArrowWavePlayer"..i, i, _G['defaultPlayerStrumY'..(i - 4)] - 25, 0.075, "sineOut", (0.035 * num))
            num = num + 1
        end
    end
end

function onTweenCompleted(tag)
    if tag == 'camGameInStart' then
        setProperty("camZooming", true)
        setProperty("defaultCamZoom", 0.8)
    end

    if stringStartsWith(tag, "coolArrowWaveOpponent") then
        local num = tonumber(string.sub(tag, -1))
        noteTweenY("coolArrowWave"..num..'end', num, _G['defaultOpponentStrumY'..num], 0.075, "sineOut")
    end

    if stringStartsWith(tag, "coolArrowWavePlayer") then
        local num = tonumber(string.sub(tag, -1))
        noteTweenY("coolArrowWave"..num..'end', num, _G['defaultPlayerStrumY'..(num - 4)], 0.075, "sineOut")
    end
end

function onEvent(e, v1, v2)
    if e == 'Set Text' then
        if v1 == nil then
            setProperty("subtitles.visible", false)
            setProperty("bOverlay.alpha", 0)
        else
            setProperty("subtitles.visible", true)
            setTextString("subtitles", v1)
            screenCenter("subtitles", 'x')

            if v2 == "1" then
                setProperty("bOverlay.alpha", 1)
                screenCenter("subtitles", 'y')
                setTextSize("subtitles", 82)
            end
        end
    end

    if e == 'Add Camera Zoom' then
        coolCameraEffect(1, false)
    end
end

function onSectionHit()
	if (curSection >= 128 and curSection <= 142) and curSection % 2 == 0 then
		cameraShake("camHUD", 0.002, (crochet / 1000) * 4)
	end

    if curSection == 144 then
        cameraShake("camHUD", 0.003, (crochet / 1000) * 2)
    end
end