function onStepHit()
    if curStep == 128 then
        triggerEvent("Add Camera Zoom", "0.04", "0.02")
    end

    if curStep == 528 or curStep == 592 or curStep == 656 or curStep == 720 or curStep == 2384 or curStep == 2448 or curStep == 2512 or curStep == 2576 then
        coolEffectIdfk()
    end

    if curStep == 544 or curStep == 608 or curStep == 672 or curStep == 736 or curStep == 2400 or curStep == 2464 or curStep == 2528 or curStep == 2792 then
        cameraFlash("camGame", "FFFFFF", 1.2, true)
    end

    if curStep == 1264 then
        doTweenZoom("coolZoomIn", "camGame", 5, (crochet / 1000) * 8, "expoInOut")
    end
end

function coolEffectIdfk()
    triggerEvent("Add Camera Zoom", "0.06", "0.06")
    runTimer('coolEffectTimerIDFK', (stepCrochet / 1000) * 6, 2)
    if flashingLights then
        cameraFlash("camGame", "FFFFFF", 0.7)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'coolEffectTimerIDFK' then
        triggerEvent("Add Camera Zoom", "0.06", "0.06")
    end
end

function onTweenCompleted(tag)
    if tag == 'coolZoomIn' then
        setProperty("defaultCamZoom", 0.67)
        setProperty("camGame.zoom", 0.67)
    end
end