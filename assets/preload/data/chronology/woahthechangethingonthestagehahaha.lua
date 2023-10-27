local stuff = {
    {songTitle = 'chronology', opponentColor = '3fe780', playerColor = 'a357ab', gfColor = 'd4363c', composers = {"Smily, KOSE"}}
}

function onCreate()
    for _, data in ipairs(stuff) do
        if data.songTitle == songName then
            curComposer = table.concat(data.composers, ", ")

            makeLuaSprite('songSign', 'songSign', -400, 175)
            setObjectCamera('songSign', 'camOther')
            setProperty('songSign.antialiasing', false)
            addLuaSprite('songSign', false)

            makeLuaSprite('shaggersSign', 'shaggersSign', -400, 300)
            setObjectCamera('shaggersSign', 'camOther')
            setProperty('shaggersSign.antialiasing', false)
            addLuaSprite('shaggersSign', false)

            makeLuaText('comp', songName..'\n'..curComposer, 300, 0, 0)
            setObjectCamera('comp', 'camOther')
            setTextAlignment('comp', 'left')
            setTextFont('comp', 'ourple.ttf')
            setTextSize('comp', 36)
            addLuaText('comp', false)

            makeLuaText('shag', 'Coded by\nShaggers', 300, 0, 0)
            setObjectCamera('shag', 'camOther')
            setTextAlignment('shag', 'left')
            setTextFont('shag', 'ourple.ttf')
            setTextSize('shag', 36)
            addLuaText('shag', false)
        end
    end
    precacheSound('boop')
end

function onSongStart()
    for _, data in ipairs(stuff) do
        if data.songTitle == songName then
            doTweenColor('timebar', 'timeBar', data.opponentColor, 0.01, 'linear')
            doTweenColor('scoreTxt', 'scoreTxt', data.opponentColor, 0.01, 'linear')
        end
    end
end

function onUpdate(elapsed)
    setProperty('comp.x', getProperty('songSign.x') + 10)
    setProperty('shag.x', getProperty('shaggersSign.x') + 10)
    setProperty('comp.y', getProperty('songSign.y') + 10)
    setProperty('shag.y', getProperty('shaggersSign.y') + 10)
end

function onUpdatePost(elapsed)
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SEVEN') or getPropertyFromClass('flixel.FlxG', 'keys.justPressed.EIGHT') or getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADMULTIPLY')then
        playSound('boop', 1, 'boop')
    end

    for _, data in ipairs(stuff) do
        if data.songTitle == songName then
            if getPropertyFromClass('flixel.FlxG', 'mouse.visible') == true then
                if mouseOverLapsSprite('shag', 'other') then
                    setTextColor('shag', data.opponentColor)
                    if mouseClicked() then
                        os.execute('start "" "https://youtube.com/@Shaggers"')
                    end
                elseif mouseOverLapsSprite('comp', 'other') then
                    setTextColor('comp', data.opponentColor)
                    if mouseClicked() then
                        os.execute('start "" "https://www.youtube.com/@boi_smily"')
                        os.execute('start "" "https://www.youtube.com/@protonatedOH"')
                    end
                else
                    setTextColor('comp', 'FFFFFF')
                    setTextColor('shag', 'FFFFFF')
                end
            else
                setTextColor('comp', 'FFFFFF')
                setTextColor('shag', 'FFFFFF')
            end
        end
    end
end

function onTweenCompleted(tag)
    if tag == 'songsignbye' then
        removeLuaSprite('songSign', true)
        removeLuaSprite('shaggersSign', true)
        removeLuaText('comp', true)
        removeLuaText('shag', true)
    end
end

function onTimerCompleted(tag)
    if tag == 'byebye' then
        doTweenX('songsignbye', 'songSign', -400, crochet / 200, 'quadInOut')
        doTweenX('shagsignbye', 'shaggersSign', -400, crochet / 200, 'quadInOut')
        setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)
    end
end

function onStepHit()
    if curStep == 256 then
        setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
        doTweenX('songsign', 'songSign', 50, crochet / 500, 'quadInOut')
        doTweenX('shagsign', 'shaggersSign', 50, crochet / 500, 'quadInOut')
        runTimer('byebye', 4)
    end
    
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

function onSectionHit()
    for _, data in ipairs(stuff) do
        if data.songTitle == songName then
            if not mustHitSection then
                doTweenColor('timeBar', 'timeBar', data.opponentColor, 0.4, 'sineOut')
                doTweenColor('scoreTxt', 'scoreTxt', data.opponentColor, 0.4, 'sineOut')
            else
                doTweenColor('timeBar', 'timeBar', data.playerColor, 0.4, 'sineOut')
                doTweenColor('scoreTxt', 'scoreTxt', data.playerColor, 0.4, 'sineOut')
            end

            if gfSection and data.gfColor ~= nil then
                doTweenColor('timeBar', 'timeBar', data.gfColor, 0.4, 'sineOut')
                doTweenColor('scoreTxt', 'scoreTxt', data.gfColor, 0.4, 'sineOut')
            end
        end
    end
end

function onDestroy()
    setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)
end

function posOverlaps(
    x1, y1, w1, h1, --r1,
    x2, y2, w2, h2 --r2
)
    return (
        x1 + w1 >= x2 and x1 < x2 + w2 and
        y1 + h1 >= y2 and y1 < y2 + h2
    )
end

function mouseOverLapsSprite(spr, cam)
    local mouseX, mouseY = getMouseX(cam or "other"), getMouseY(cam or "other")
    
    local x, y, w, h = getProperty(spr .. ".x"), getProperty(spr .. ".y"), getProperty(spr .. ".width"), getProperty(spr .. ".height")
    
    return posOverlaps(
        mouseX, mouseY, 1, 1,
        x, y, w, h
    )
end