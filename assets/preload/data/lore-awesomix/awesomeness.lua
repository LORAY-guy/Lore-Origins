local flick = false
local camList = {'camGame', 'camHUD'}

function onCreate()
    makeAnimatedLuaSprite('monitor', 'stages/monitor', 0, 0)
    addAnimationByPrefix('monitor', 'open', 'Open', 24, false)
	addAnimationByIndices('monitor', 'nothing', 'Close', '0', 24)
	objectPlayAnimation('monitor', 'nothing', false)
	setObjectCamera('monitor', 'camHUD')
	screenCenter('monitor', 'xy')
    updateHitbox('monitor')
	setProperty('monitor.visible', false)
    addLuaSprite('monitor')

    makeLuaSprite('backstageblur','bckrom-blur', 0, 0)
    updateHitbox('backstageblur')
    setObjectCamera('backstageblur', 'camOther')
    screenCenter('backstageblur', 'xy')
    addLuaSprite('backstageblur',false)

    makeAnimatedLuaSprite('prange', 'characters/prange', 1280, 90)
    addAnimationByPrefix('prange', 'idle', 'idle', 30, false)
    objectPlayAnimation('prange', 'idle', false)
    scaleObject('prange', 3, 3)
    setProperty('prange.antialiasing', false)
    setProperty('prange.flipX', true)
    setProperty('prange.angle', 360)
	setObjectCamera('prange', 'camOther')
	addLuaSprite('prange', false)

    makeAnimatedLuaSprite('ourple', 'characters/guy', (screenWidth / 2) - 150, 100)
	addAnimationByPrefix('ourple', 'lol', 'idle', 24, false)
	objectPlayAnimation('ourple', 'lol', false)
    scaleObject('ourple', 3, 3)
	setProperty('ourple.antialiasing', false)
    setProperty('ourple.visible', false)
    setObjectCamera('ourple', 'camOther')
	addLuaSprite('ourple', false)

    makeLuaText('equal', '=', 80, 1280, 0)
    setObjectCamera('equal', 'camOther')
    setTextSize('equal', 96)
    screenCenter('equal', 'y')
    setObjectOrder('equal', getObjectOrder('motorist') - 1)
    addLuaText('equal', false)

    makeLuaSprite('william', 'william', 1280, 0)
    scaleObject('william', 2.6, 2.6)
    setProperty('william.antialiasing', false)
    setObjectCamera('william', 'camOther')
    screenCenter('william', 'y')
    addLuaSprite('william', false)

    makeLuaSprite('motorist', 'motoristproof', 0, -1500)
    scaleObject('motorist', 0.7, 0.7)
    setProperty('motorist.antialiasing', false)
    setObjectCamera('motorist', 'camOther')
    screenCenter('motorist', 'x')
    addLuaSprite('motorist', false)

    makeLuaSprite('finger', 'finger', -1000, -250)
    scaleObject('finger', 1.3, 1.3)
    --setProperty('finger.antialiasing', false)
    setObjectCamera('finger', 'camOther')
    setProperty('finger.angle', 50)
    addLuaSprite('finger', false)

    makeAnimatedLuaSprite('mapa', 'characters/matpat2', -375, 210)
	addAnimationByPrefix('mapa', 'lol', 'mat idle dance', 24, false)
	objectPlayAnimation('mapa', 'lol', false)
    scaleObject('mapa', 1.2, 1.2)
    setObjectCamera('mapa', 'camOther')
	addLuaSprite('mapa', false)

    makeLuaSprite('whitestuff', '', 0, 0)
    makeGraphic('whitestuff', 1280, 720, 'FFFFFF')
    setProperty('whitestuff.antialiasing', false)
    setProperty('whitestuff.alpha', 0)
    setObjectCamera('whitestuff', 'camOther')
    addLuaSprite('whitestuff', false)
    
    makeLuaSprite('vcrshit', 'vcrshit', 0, 0)
    setObjectCamera('vcrshit', 'camHUD')
    setProperty('vcrshit.visible', false)
    addLuaSprite('vcrshit', false)

    makeLuaSprite('redboob','stages/red', 167, 59)
	setObjectCamera('redboob', 'camHUD')
    scaleObject('redboob', 0.8, 0.8)
	setProperty('redboob.visible', false)
	addLuaSprite('redboob', false)

    setProperty('skipCountdown', true)
end

function onSongStart()
    doTweenX('prangeComeIn', 'prange', (screenWidth / 2) - 210, 1.5, 'cubeOut')
    doTweenAngle('prangeComeInAngle', 'prange', 0, 1.5, 'quadOut')
end

function onCreatePost()
    for i = 1, #camList do
        setProperty(camList[i]..'.visible', false) 
    end
end

function onStepHit()
    if getProperty('vcrshit.visible') == true and curStep % 4 == 0 then
		setProperty('redboob.visible', flick)
		flick = not flick
	end

    if curStep == 26 then
        setProperty('camOther.zoom', 1.05)
        cameraFlash('other', 'FFFFFF', 0.75)
        removeLuaSprite('prange', true)
        setProperty('ourple.visible', true)
        doTweenZoom('camOtherBoom', 'camOther', 1, 0.75, 'cubeOut')
    end

    if curStep == 39 then
        doTweenX('mapaComeIn', 'mapa', 50, 0.5, 'cubeOut')
    end

    if curStep == 46 then
        doTweenX('ourpleJustMove', 'ourple', getProperty('ourple.x') - 200, 0.5, 'cubeOut')
        doTweenX('equalComeIn', 'equal', (screenWidth / 2) - 15, 0.4, 'cubeOut')
        doTweenX('williamcomeIn', 'william', getProperty('ourple.x') + 200, 0.5, 'cubeOut')
    end

    if curStep == 58 then
        ourples = {'ourple', 'william', 'equal'}
        for i = 1, #ourples do
            doTweenY(ourples[i]..'byebye', ourples[i], 750, 0.6, 'cubeIn')
        end
    end

    if curStep == 61 then
        doTweenY('midnightIn', 'motorist', 0, 0.7, 'sineOut')
    end

    if curStep == 71 then
        doTweenAlpha('flashincoming', 'whitestuff', 1, (stepCrochet / 1000) * 29, 'expoIn')
    end

    if curStep == 73 then
        doTweenX('motoristX', 'motorist', getProperty('motorist.x') - 310, 0.5, 'sineOut')
        doTweenY('motoristY', 'motorist', getProperty('motorist.y') - 80, 0.5, 'sineOut')
        doTweenX('motoristXZoom', 'motorist.scale', 1, 0.5, 'sineOut')
        doTweenY('motoristYZoom', 'motorist.scale', 1, 0.5, 'sineOut')
    end

    if curStep == 77 then
        doTweenX('fingerX', 'finger', 530, 0.25, 'sineOut')
        doTweenY('fingerY', 'finger', 235, 0.25, 'sineOut')
    end

    if curStep == 87 then
        ourples = {'finger', 'motorist'}
        for i = 1, #ourples do
            doTweenY('byebye'..i, ourples[i], 1000, 0.6, 'cubeIn')
        end
        doTweenX('mapaCenterX', 'mapa', (screenWidth / 2) - 200, 0.5, 'sineInOut')
        doTweenY('mapaCenterY', 'mapa', getProperty('mapa.y') - 30, 0.5, 'sineInOut')
        doTweenX('mapaXZoom', 'mapa.scale', 1.4, 0.5, 'sineInOut')
        doTweenY('mapaYZoom', 'mapa.scale', 1.4, 0.5, 'sineInOut')
    end

    if curStep == 100 then
        for i = 1, #camList do
            setProperty(camList[i]..'.visible', true) 
        end
        ourples = {'mapa', 'backstageblur'}
        for i = 1, #ourples do
            removeLuaSprite(ourples[i], true) 
        end
    end

    if curStep == 100 or curStep == 1924 or curStep == 2180 then
        cameraFlash('camGame', 'FFFFFF', 1)
    end

    if curStep == 544 or curStep == 1824 then
        setProperty('defaultCamZoom', 1.1)
        doTweenZoom('camin', 'camGame', 1.1, 0.2, 'quadOut')
    elseif curStep == 548 or curStep == 1828 then
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camout', 'camGame', 0.9, 0.2, 'quadOut')
    end

    if curStep == 1824 then
        cameraShake('game', 0.02, 0.25)
    end

    if curStep == 2046 then
        setProperty('monitor.visible', true)
		objectPlayAnimation('monitor', 'open', false)
        runTimer('byemonitor', 0.4)
    end

    if curStep == 2948 then
        setProperty('camGame.visible', false)
        setProperty('camHUD.visible', false)
        cameraFlash('camOther', 'FFFFFF', 1)
    end
end

function onUpdate(elapsed)
    --debugPrint(getProperty('camFollow.x'), getProperty('camFollow.y'))

    if gfSection then
        setProperty('camFollow.x', 712)
    end

    if curStep >= 2816 and curStep < 2832 then
        setProperty('camFollow.x', 712)
        setProperty('camFollow.y', 383)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'byemonitor' then
        setProperty('defaultCamZoom', 1.2)
        doTweenZoom('camshit', 'camGame', 1.2, 0.01, 'linear')
        doTweenX('dadcenter', 'dad', getProperty('dad.x') + 75, 0.01, 'linear')
        --doTweenX('bfcenter', 'boyfriend', getProperty('boyfriend.x') - 50, 0.01, 'linear')
		setProperty('monitor.visible', false)
        setProperty('vcrshit.visible', true)
	end
end

function onTweenCompleted(tag)
    if tag == 'byebye1' then
        for i = 1, #ourples do
            if ourples[i] == 'equal' then
                removeLuaText(ourples[i], true)
            else
                removeLuaSprite(ourples[i], true)
            end
        end
    end

    if tag == 'flashincoming' then
        removeLuaSprite('whitestuff', true)
    end
end