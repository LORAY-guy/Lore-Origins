local closeUp = false

function onCreate()
	makeLuaSprite('coolstuff', '', 0, 0)
	setScrollFactor('coolstuff', 0, 0)
	makeGraphic('coolstuff', 2000, 2000, '000000')
	screenCenter('coolstuff', 'xy')
	setProperty('coolstuff.alpha', 0.6)
	setObjectOrder('coolstuff', 2)
    setProperty('coolstuff.visible', false)
	addLuaSprite('coolstuff', true)
end

function onStepHit()
    if curStep == 192 or curStep == 256 or curStep == 320 or curStep == 388 or curStep == 448 or curStep == 512 or curStep == 768 or curStep == 904 or curStep == 1024 or curStep == 1118 or curStep == 1280 or curStep == 1472 or curStep == 1536 or curStep == 1668 or curStep == 1728 or curStep == 2048 or curStep == 2176 then
        cameraFlash('camGame', 'FFFFFF', 0.9)
    end

    if curStep >= 304 and curStep < 320 or curStep >= 368 and curStep < 388 or curStep >= 432 and curStep < 448 or curStep >= 496 and curStep < 512 or curStep >= 992 and curStep < 1015 or curStep >= 1110 and curStep < 1118 or curStep >= 1584 and curStep < 1600 or curStep >= 1648 and curStep < 1664 or curStep >= 2288 and curStep < 2304 then
        setProperty('camZooming', false)
    end

    if curStep == 176 or curStep == 1248 or curStep == 1456 or curStep == 1520 or curStep == 2016 or curStep == 2160 or curStep == 2032 or curStep == 2800 then
        setProperty('camZooming', false)
    elseif curStep == 192 or curStep == 320 or curStep == 388 or curStep == 448 or curStep == 512 or curStep == 1280 or curStep == 1472 or curStep == 1532 or curStep == 1732 or curStep == 2048 or curStep == 2176 or curStep == 2808 then
        setProperty('camZooming', true)
    end

    if curStep == 240 or curStep == 384 or curStep == 496 or curStep == 896 or curStep == 1016 or curStep == 1096 or curStep == 1520 or curStep == 1648 or curStep == 1776 or curStep == 1920 or curStep == 2800 or curStep == 2492 or curStep == 2512 then
        setProperty('defaultCamZoom', 1.2)
        doTweenZoom('camInEpic', 'camGame', 1.2, 0.01, 'linear')
    elseif curStep == 256 or curStep == 388 or curStep == 512 or curStep == 904 or curStep == 1024 or curStep == 1118 or curStep == 1536 or curStep == 1668 or curStep == 1792 or curStep == 2016 or curStep == 2816 or curStep == 2496 or curStep == 2528 then
        setProperty('defaultCamZoom', 0.75)
        setProperty('cameraSpeed', 1)
    end

    if curStep >= 256 and curStep < 512 or curStep >= 1110 and curStep < 1118 or curStep >= 1536 and curStep < 1776 or curStep >= 2016 and curStep < 2048 or curStep >= 2622 and curStep < 2657 or curStep >= 2752 then
        setProperty('cameraSpeed', 100)
    end

    if curStep == 1118 then
        setProperty('cameraSpeed', 1)
    end

    if curStep == 760 then
        setProperty('defaultCamZoom', 1.2)
    elseif curStep == 768 then
        setProperty('defaultCamZoom', 0.75)
        setProperty('cameraSpeed', 100)
    end

    if curStep == 768 or curStep == 2432 then
        setProperty('coolstuff.visible', true)
        setProperty('defaultCamZoom', 0.75)
        setProperty('cameraSpeed', 1)
    end

    if curStep == 786 then
        doTweenZoom('epicCamIn', 'camGame', 1.1, 6, 'cubeInOut')
    end

    if curStep == 1808 then
        doTweenZoom('epicZoomInPhone', 'camGame', 1.1, (stepCrochet / 1000) * (16 * 7), 'cubeInOut')
    end

    if curStep == 2416 or curStep == 2544 then
        doTweenZoom('gonnaTransition', 'camGame', 2, (stepCrochet / 1000) * 16, 'expoIn')
    end

    if curStep == 1118 then
        cameraSetTarget('boyfriend')
    end

    if curStep == 1280 or curStep == 2560 then
        setProperty('coolstuff.visible', false)
    end

    if curStep == 2846 then
        setProperty('blackstuff.alpha', 1)
        setObjectCamera('blackstuff', 'camOther')
    end
end

function onStartCountdown()
    doTweenZoom('camInStart', 'camGame', 0.9, 4, 'cubeInOut')
    setProperty('camZooming', false)
    setProperty('defaultCamZoom', 0.9)
end

function onTweenCompleted(tag)
    if tag == 'camInStart' then
        setProperty('camZooming', true)
    end

    if tag == 'gonnaTransition' then
        doTweenZoom('doneTransition', 'camGame', 0.75, (stepCrochet / 1000) * 16, 'expoOut')
    end
end

function onUpdate(elapsed)
    if getProperty('defaultCamZoom') >= 1.1 then
        closeUp = true
    else
        closeUp = false
    end

    if closeUp == true then
        setProperty('cameraSpeed', 100)
        if not mustHitSection then
            setProperty('camFollow.x', 520)
            setProperty('camFollow.y', 260)
        else
            setProperty('camFollow.x', 900)
            setProperty('camFollow.y', 332)
        end
    end

    if curStep >= 1096 and curStep < 1110 then
        cameraSetTarget('boyfriend')
    elseif curStep >= 1110 and curStep < 1118 then
        cameraSetTarget('dad')
    end

    if curStep >= 2492 and curStep < 2496 or curStep >= 2512 and curStep < 2528 or curStep >= 2796 then
        setProperty('camFollow.x', 691.5)
        setProperty('camFollow.y', 353)
    end
end

function onBeatHit()
    if curBeat >= 64 and curBeat < 76 or curBeat >= 80 and curBeat < 92 or curBeat >= 97 and curBeat < 108 or curBeat >= 112 and curBeat < 124 or curBeat >= 226 and curBeat < 248 or curBeat >= 352 and curBeat < 380 or curBeat >= 384 and curBeat < 396 or curBeat >= 400 and curBeat < 412 or curBeat >= 417 and curBeat < 428 or curBeat >= 432 and curBeat < 444 or curBeat >= 544 and curBeat < 572 or curBeat >= 576 and curBeat < 604 or curBeat >= 672 and curBeat < 700 then
        triggerEvent('Add Camera Zoom', '0.04', '0.02')
    end

    if curBeat >= 128 and curBeat < 190 or curBeat >= 320 and curBeat < 352 or curBeat >= 640 and curBeat < 672 and curBeat % 2 == 0 then
        triggerEvent('Add Camera Zoom', '0.04', '0.02')
    end

    if curBeat >= 256 and curBeat < 273 or curBeat >= 280 and curBeat < 312 or curBeat >= 512 and curBeat < 540 or curBeat >= 608 and curBeat < 632 or curBeat >= 624 and curBeat < 628 or curBeat >= 632 and curBeat < 635 then
        triggerEvent('Add Camera Zoom', '0.06', '0.04')
    end
end