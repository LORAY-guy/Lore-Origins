function onStepHit()

    if curStep == 1537 then
        doTweenAlpha('byehud', 'camHUD', 0, 0.6, 'easeInOut')
    end

    if curStep == 1672 or curStep == 1688 or curStep == 1704 or curStep == 1720 or curStep == 1736 or curStep == 1752 or curStep == 1768 then
        setProperty('defaultCamZoom', getProperty('defaultCamZoom') + 0.05)
        doTweenZoom('camzooooooooom', 'camGame', getProperty('defaultCamZoom') + 0.05, 0.0001, 'linear')
    end

    if curStep == 1776 then
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('camzooooooooom', 'camGame', 0.9, 0.8, 'easeInOut')
    end

    if curStep == 1782 then
        doTweenAlpha('hellohud', 'camHUD', 1, 0.6, 'easeInOut')
    end

end

function onUpdate()
    if curStep >= 1664 and curStep <= 1776 then
        setProperty('cameraSpeed', 100)
        setProperty('camZooming', false)
    else
        setProperty('cameraSpeed', 1)
        setProperty('camZooming', true)
    end
end