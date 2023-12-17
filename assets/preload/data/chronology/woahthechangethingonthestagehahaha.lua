function onStepHit()
    if curStep == 506 then
        setProperty('defaultCamZoom', 0.9)
        setProperty('cameraSpeed', 1000)
    end

    if curStep == 512 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('defaultCamZoom', 0.7)
        setProperty('cameraSpeed', 1.5)
    end

    if curStep == 704 or curStep == 720 then
        cameraFlash('camGame', 'FFFFFF', (crochet / 1000) * 3)
        setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.1)
    end

    if curStep == 736 or curStep == 744 or curStep == 752 then
        cameraFlash('camGame', 'FFFFFF', (stepCrochet / 1000) * 7)
        setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.05)
    end

    if curStep == 768 then
        setProperty('defaultCamZoom', 0.7)
    end

    if curStep == 800 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 1060 then
        setProperty('defaultCamZoom', 0.9)
    end

    if curStep == 1068 then
        setProperty('defaultCamZoom', 0.7)
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 1312 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 1552 then
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camZoomInQuick', 'camGame', 0.9, 0.01, 'linear')
    end

    if curStep == 1568 then
        setProperty('defaultCamZoom', 0.7)
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 1824 then
        setProperty('cameraSpeed', 1000)
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camZoomInQuick', 'camGame', 0.9, 0.01, 'linear')
    end

    if curStep == 1840 then
        setProperty('cameraSpeed', 1.5)
        setProperty('defaultCamZoom', 0.7)
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 2064 then
        setProperty('defaultCamZoom', 0.9)
    end

    if curStep == 2080 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('cameraSpeed', 1000)
        setProperty('defaultCamZoom', 0.8)
    end

    if curStep == 2340 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 2592 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('cameraSpeed', 1.5)
        setProperty('defaultCamZoom', 0.7)
    end

    if curStep == 2848 then
        setProperty('cameraSpeed', 1000)
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camZoomInQuick', 'camGame', 0.9, 0.01, 'linear')
    end

    if curStep == 2856 then
        setProperty('cameraSpeed', 1.5)
        setProperty('defaultCamZoom', 0.7)
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 3104 then
        setProperty('cameraSpeed', 1000)
        doTweenZoom('camZoomInQuick', 'camGame', 0.8, 0.01, 'linear')
        setProperty('defaultCamZoom', 0.8)
        setProperty('camHUD.alpha', 0)
    end

    if curStep == 3120 then
        setProperty('cameraSpeed', 1.5)
        doTweenAlpha('comeBackHUD', 'camHUD', 1, 1, 'quadInOut')
        setProperty('defaultCamZoom', 0.7)
    end

    if curStep == 3392 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
    end

    if curStep == 3520 then
        doTweenZoom('camZoomInQuick', 'camGame', 0.9, 0.01, 'linear')
        setProperty('defaultCamZoom', 0.9)
        setProperty('cameraSpeed', 1000)
    end

    if curStep == 3524 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('defaultCamZoom', 0.7)
        setProperty('cameraSpeed', 1.5)
    end

    if curStep == 3640 then
        cameraSetTarget('boyfriend')
        setProperty('cameraSpeed', 1000)
        doTweenZoom('camZoomInQuick', 'camGame', 0.9, 0.01, 'linear')
        setProperty('defaultCamZoom', 0.9)
    end

    if curStep == 3648 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('cameraSpeed', 1.5)
        setProperty('defaultCamZoom', 0.7)
    end

    if curStep == 3776 then
        setProperty('cameraSpeed', 1000)
        doTweenZoom('camZoomInQuick', 'camGame', 0.9, 0.01, 'linear')
        setProperty('defaultCamZoom', 0.9)
    end

    if curStep == 3792 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('cameraSpeed', 1.5)
        setProperty('defaultCamZoom', 0.7)
    end

    if curStep == 3904 then
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('cameraSpeed', 1000)
    end

    if curStep == 4032 then
        setProperty('cameraSpeed', 1.5)
    end

    if curStep == 4160 then
        setProperty('cameraSpeed', 1000)
        doTweenZoom('camZoomInQuick', 'camGame', 0.9, 0.01, 'linear')
        setProperty('defaultCamZoom', 0.9)
    end

    if curStep == 4168 then
        setProperty('cameraSpeed', 1.5)
        cameraFlash('camGame', 'FFFFFF', 1.2)
        setProperty('defaultCamZoom', 0.7)
    end

    if curStep == 4288 then
        setProperty('defaultCamZoom', 0.8)
    end
end

function onEvent(eventName, value1, value2)
	if eventName == 'Play Animation' and value1 == 'singDOWN' then
		setProperty('camGame.visible', false)
		setProperty('camHUD.visible', false)
	end

    if eventName == 'Play Animation' and value1 == 'singUP' then
        setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.05)
	end

    if eventName == 'Play Animation' and value1 == 'welcome' then
		setProperty('gf.visible', true)
	end
end