local otherStuff = {}
local mult = 1.2
local flipped = false
local funni = true
local defaultY = 0

function onCreate()
    makeLuaSprite('ourple_bg', 'couch', 0, 0)
    setObjectCamera('ourple_bg', 'camOther')
    screenCenter('ourple_bg', 'xy')
    otherStuff[#otherStuff + 1] = 'ourple_bg'
    addLuaSprite('ourple_bg', true)

    makeLuaSprite('matpat', 'daepicmatpat', 0, 0)
    setObjectCamera('matpat', 'camOther')
    scaleObject('matpat', 1.3, 1.3)
    otherStuff[#otherStuff + 1] = 'matpat'
    addLuaSprite('matpat', true)

    makeLuaSprite('blackness', '', 0, 0)
    setObjectCamera('blackness', 'camOther')
    makeGraphic('blackness', 1280, 720, '000000')
    addLuaSprite('blackness', true)

    setProperty('introSoundsSuffix', '-nothing')

    addLuaScript('pogScripts/OurpleHUD')
end

function onCreatePost()
    defaultY = getProperty('boyfriend.y')
end

function onSongStart()
    setPropertyFromClass('flixel.FlxG', 'sound.music.volume', 0.9)
    setProperty("blackness.alpha", 0)
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if curStep < 64 then
        scaleObject('matpat', getProperty('matpat.scale.x') * mult, getProperty('matpat.scale.y') * mult)
        scaleObject('ourple_bg', getProperty('ourple_bg.scale.x') * mult - 0.075, getProperty('ourple_bg.scale.y') * mult - 0.075)
        setProperty('matpat.x', 460)
        setProperty('matpat.y', 150)

        if noteType == 'Alt Animation' then
            funni = false
            mult = mult * 1.05
            if not flipped then
                flipped = true
                setProperty('matpat.flipX', true)
            end
        elseif noteType == '' and mult > 1.1 then
            funni = true
            mult = 1.1
            if flipped then
                flipped = false
                setProperty('matpat.flipX', false)
            end
        end
    end
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'GF Sing' and gfSection and mustHitSection then
		setProperty('boyfriend.y', defaultY)
		setProperty('boyfriend.flipX', true)
        playAnim("boyfriend", getProperty('singAnimations')[math.abs(noteData)+1], true, false, 0)
        setProperty('boyfriend.holdTimer', 0)
    end
end

function onUpdate(elapsed)
    if curStep < 64 and funni then
        doTweenX('matpatResizeX', 'matpat.scale', 1.3, 0.25, 'cubeOut')
        doTweenY('matpatResizeY', 'matpat.scale', 1.3, 0.25, 'cubeOut')
        doTweenX('ourple_bgResizeX', 'ourple_bg.scale', 1, 0.25, 'cubeOut')
        doTweenY('ourple_bgResizeY', 'ourple_bg.scale', 1, 0.25, 'cubeOut')
    end
end

function onUpdatePost(elapsed)
    if curStep < 64 then
        screenCenter('matpat', 'x')
        screenCenter('ourple_bg', 'x')
        updateHitbox('matpat')
        updateHitbox('ourple_bg')
    end
end

function onStepHit()
    if curStep == 64 then
        cameraFlash('camGame', 'FFFFFF', 0.9)
        for i = 1, #otherStuff do
            removeLuaSprite(otherStuff[i], true)
        end
    end

    if curStep == 182 or curStep == 310 or curStep == 1338 or curStep == 1462 or curStep == 1590 or curStep == 2742 or curStep == 2616 or curStep == 2870 then
        setProperty('defaultCamZoom', 1.3)
        setProperty('cameraSpeed', 1000)
    end

    if curStep == 192 or curStep == 1344 or curStep == 1472 or curStep == 1600 or curStep == 2624 or curStep == 2752 then
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.9, 0.01, 'linear')
    end

    if curStep == 312 then
        strumBye()
        doTweenAlpha("goingDownHUD", "camHUD", 0, (stepCrochet / 1000) * 8, "cubeOut")
        doTweenAlpha("goingDown", "blackness", 1, (stepCrochet / 1000) * 8, "cubeOut")
    end

    if curStep == 320 or curStep == 576 then
        setProperty('defaultCamZoom', 0.8)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.8, 0.01, 'linear')
    end

    if curStep == 448 then
        cameraFlash("camGame", "FFFFFF", 0.9)
        setProperty("camHUD.alpha", 1)
        strumHello()
    end

    if curStep == 560 then
        setProperty('defaultCamZoom', 1.3)
    end

    if curStep == 832 or curStep == 1856 then
        setProperty('defaultCamZoom', 0.9)    
        setProperty('cameraSpeed', 1)
    end

    if curStep == 1120 or curStep == 1184 or curStep == 1248 then
        epicBooms(false)
    end

    if curStep == 1312 then
        epicBooms(true)
    end

    if curStep == 1344 or curStep == 1856 or curStep == 1920 or curStep == 1984 or curStep == 2624 then
        cameraFlash("camGame", "FFFFFF", 0.9)
    end

    if curStep == 1856 then
        setProperty("camHUD.alpha", 0)
        strumBye()
    end

    if curStep == 1984 then
        setProperty('defaultCamZoom', 0.9) 
        setProperty("camHUD.alpha", 1)
        strumHello()
    end

    if curStep == 1824 then
        doTweenZoom('camGameEpicZoomInOnOurple', 'camGame', 1.3, (stepCrochet / 1000) * 16, 'expoIn')
    end

    if curStep == 2080 then
        setProperty('defaultCamZoom', 0.8)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.8, 0.01, 'linear')
        setProperty('cameraSpeed', 1000)
    end

    if curStep == 2880 then
        cameraFlash('camGame', 'FFFFFF', 0.9)
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.9, 0.01, 'linear')
    end

    if curStep == 2888 then
        doTweenZoom('finalZoomIn', 'camGame', 1.4, (stepCrochet / 1000) * 8, 'expoIn')
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'Play Animation' and value1 == 'ringstart' and curStep < 1728 then
        setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.075)
        doTweenZoom('camGameGoInQuick', 'camGame', getProperty('defaultCamZoom'), 0.01, 'linear')
    end
end

function onTweenCompleted(tag)
    if tag == 'camGameEpicZoomInOnOurple' then
        setProperty('defaultCamZoom', 1)
        doTweenZoom('camGameGoBackQuick', 'camGame', 1, 0.01, 'linear')
    end

    if tag == 'finalZoomIn' then
        setProperty('camGame.visible', false)
        setProperty('camHUD.visible', false)
    end

    if tag =='goingDown' then
        doTweenAlpha("goingBack", "blackness", 0, (crochet / 1000) * 64, "cubeIn")
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'boomBitch' then
        triggerEvent("Add Camera Zoom", "0.4", "0.2")
    end

    if tag == 'boomBitch2' then
        triggerEvent("Add Camera Zoom", "0.4", "0.2")
        runTimer("boomBitch3", (stepCrochet / 1000) * 4)
    end

    if tag == 'boomBitch3' then
        triggerEvent("Add Camera Zoom", "0.4", "0.2")
        runTimer("justFlash", (stepCrochet / 1000) * 4)
    end

    if tag == 'justFlash' then
        cameraFlash("camGame", "FFFFFF", 0.9)
    end
end

function epicBooms(isEnd)
    triggerEvent("Add Camera Zoom", "0.4", "0.2")
    runTimer("boomBitch", (stepCrochet / 1000) * 6, 3)
    if not isEnd then
        runTimer("boomBitch2", (stepCrochet / 1000) * 24)
    end
end

function strumBye()
    for i = 0, 7 do
        if i < 4 then
            noteTweenAngle('strumAngle'..i, i, -360, (stepCrochet / 1000) * 8, "quadIn")
            noteTweenX('strum'..i, i, _G['defaultOpponentStrumX'..i] - 750, (stepCrochet / 1000) * 8, "quadIn")
        else
            noteTweenAngle('strumAngle'..i, i, 360, (stepCrochet / 1000) * 8, "quadIn")
            noteTweenX('strum'..i, i, _G['defaultPlayerStrumX'..(i - 4)] + 750, (stepCrochet / 1000) * 8, "quadIn")
        end
    end
end

function strumHello()
    for i = 0, 7 do
        if i < 4 then
            noteTweenAngle('strumAngle'..i, i, 0, (stepCrochet / 1000) * 8, "quadOut")
            noteTweenX('strum'..i, i, _G['defaultOpponentStrumX'..i], (stepCrochet / 1000) * 8, "quadOut")
        else
            noteTweenAngle('strumAngle'..i, i, 0, (stepCrochet / 1000) * 8, "quadOut")
            noteTweenX('strum'..i, i, _G['defaultPlayerStrumX'..(i - 4)], (stepCrochet / 1000) * 8, "quadOut")
        end
    end
end