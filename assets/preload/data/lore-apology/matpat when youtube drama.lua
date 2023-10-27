local otherStuff = {}
local mult = 1.2
local flipped = false
local funni = true

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
    math.randomseed(os.time())
end

function onSongStart()
    removeLuaSprite('blackness', true)
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

    if curStep >= 1824 and curStep < 1856 then
        setProperty('camZooming', false)
        setProperty('camFollow.x', 691.5)
        setProperty('camFollow.y', 383)
    end
end

function onStepHit()
    if curStep == 64 then
        cameraFlash('camGame', 'FFFFFF', 0.9)
        for i = 1, #otherStuff do
            removeLuaSprite(otherStuff[i], true)
        end
    end

    if curStep == 182 or curStep == 310 or curStep == 1206 or curStep == 1334 or curStep == 2486 or curStep == 2614 then
        setProperty('defaultCamZoom', 1.3)
        setProperty('cameraSpeed', 1000)
    end

    if curStep == 192 or curStep == 1216 or curStep == 2496 then
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.9, 0.01, 'linear')
    end

    if curStep == 320 or curStep == 1344 then
        setProperty('defaultCamZoom', 0.8)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.8, 0.01, 'linear')
    end

    if curStep == 576 or curStep == 1600 then
        setProperty('defaultCamZoom', 0.9)    
        setProperty('cameraSpeed', 1)
    end

    if curStep == 1616 then
        setProperty('cameraSpeed', 1000)
    end

    if curStep == 1728 then
        setProperty('cameraSpeed', 1)
        setProperty('defaultCamZoom', 0.9) 
    end

    if curStep == 1824 then
        doTweenZoom('camGameEpicZoomInOnPhone', 'camGame', 1.3, (stepCrochet / 1000) * 16, 'expoIn')
    end

    if curStep == 1856 then
        setProperty('defaultCamZoom', 0.8)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.8, 0.01, 'linear')
        setProperty('cameraSpeed', 1000)
        setProperty('camZooming', true)
    end

    if curStep == 2624 then
        cameraFlash('camGame', 'FFFFFF', 0.9)
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camGameGoBackQuick', 'camGame', 0.9, 0.01, 'linear')
    end

    if curStep == 2632 then
        doTweenZoom('finalZoomIn', 'camGame', 1.4, (stepCrochet / 1000) * 8, 'expoIn')
    end
end

function onBeatHit()
    if (curBeat >= 16 and curBeat < 76 and curBeat % 2 == 0) or (curBeat >= 272 and curBeat < 333 and curBeat % 2 == 0) or (curBeat >= 592 and curBeat < 656 and curBeat % 2 == 0) then
        triggerEvent('Add Camera Zoom', '0.02', '0.02')
    end

    if (curBeat >= 80 and curBeat < 144) or (curBeat >= 336 and curBeat < 400) or (curBeat >= 464 and curBeat < 592) then
        triggerEvent('Add Camera Zoom', '0.04', '0.02')
    end

    if (curBeat >= 144 and curBeat < 272) then
        triggerEvent('Add Camera Zoom', '0.02', '0.02')
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'Play Animation' and value1 == 'ringstart' and curStep < 1728 then
        setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.075)
        doTweenZoom('camGameGoInQuick', 'camGame', getProperty('defaultCamZoom'), 0.01, 'linear')
    end

    if eventName == 'Play Animation' and value1 == 'singDOWN' then
        setProperty('defaultCamZoom', 0.9)
    end
end

function onTweenCompleted(tag)
    if tag == 'camGameEpicZoomInOnPhone' then
        setProperty('defaultCamZoom', 1)
        doTweenZoom('camGameGoBackQuick', 'camGame', getProperty('defaultCamZoom'), 0.01, 'linear')
    end

    if tag == 'finalZoomIn' then
        setProperty('camGame.visible', false)
        setProperty('camHUD.visible', false)
    end
end