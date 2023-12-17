local startStar = 365
local lore = {
    {name = 'lored', step = 0, skip = false},
    {name = 'lore-ryan', step = 0, skip = false},
    {name = 'lore-awesomix', step = 100, skip = true},
    {name = 'lore-apology', step = 64, skip = true},
    {name = 'fever', step = 0, skip = false},
    {name = 'lore-style', step = 0, skip = false},
    {name = 'live', step = 0, skip = false},
    {name = 'horse-lore', step = 0, skip = false},
    {name = 'chronology', step = 256, skip = false},
    {name = 'lore-tropical', step = 0, skip = false},
    {name = 'lore-sad', step = 0, skip = false},
}

function onCreate()
    precacheSound('boop')
    makeLuaSprite("pizzaIconP1", 'newOurpleHUD/pizza', 839, downscroll and 20 or 540)
    setObjectCamera("pizzaIconP1", 'camHUD')
    setObjectOrder("pizzaIconP1", getObjectOrder("healthBarBG") - 1)
    setProperty("pizzaIconP1.antialiasing", false)
    addLuaSprite("pizzaIconP1", false)

    makeLuaSprite("pizzaIconP2", 'newOurpleHUD/pizza', 236, downscroll and 20 or 540)
    setObjectCamera("pizzaIconP2", 'camHUD')
    setObjectOrder("pizzaIconP2", getObjectOrder("healthBarBG") - 1)
    setProperty("pizzaIconP2.antialiasing", false)
    addLuaSprite("pizzaIconP2", false)

    makeLuaSprite('loraySign', 'loraySign', -400, 175)
    setObjectCamera('loraySign', 'camOther')
    setProperty('loraySign.antialiasing', false)
    addLuaSprite('loraySign', false)
    
    makeLuaText('loray', 'Coded by\nLORAY', 300, 0, 185)
    setObjectCamera('loray', 'camOther')
    setTextAlignment('loray', 'left')
    setTextFont('loray', 'ourple.ttf')
    setTextSize('loray', 36)
    addLuaText('loray', false)
end

stepCredits = nil
creditsSkip = false
function onCreatePost()
    for _, data in ipairs(lore) do
        if data.name == songName then
            stepCredits = data.step
            creditsSkip = data.skip
        end
    end
    setProperty("timeTxt.visible", false)
    loadGraphic('timeBarBG', 'newOurpleHUD/lore')
    setProperty("timeBarBG.antialiasing", false)
    setProperty("healthBarBG.antialiasing", false)
    scaleObject("timeBar", 1.02, 1.375)
    scaleObject("healthBarBG", 1.1, 1.0)
    scaleObject("healthBar", 1.1, 1.0)
    setObjectOrder("timeBarBG", getObjectOrder("timeBar") + 1)
    setObjectOrder("healthBarBG", getObjectOrder("healthBar") + 1)
    setObjectOrder("iconP1", getObjectOrder("healthBarBG") + 1)
    doTweenColor("timeBarBG", "timeBarBG", "FFFFFF", 0.01, "linear")
    setProperty('healthBar.y', downscroll and 87 or 610)
    setProperty("showComboNum", false)
    for i = 1, 5 do
        makeAnimatedLuaSprite('star'..i, 'star', startStar, downscroll and -30 or 600)
        addAnimationByPrefix('star'..i, 'flash', 'star', 35, false)
        addAnimationByIndices('star'..i, 'static', 'star', '35', 35, false)
        setObjectCamera('star'..i, 'camHUD')
        setProperty('star'..i..'.antialiasing', false)
        setObjectOrder('star'..i, getObjectOrder('healthBarBG') + 1)
        addLuaSprite('star'..i, false)
        startStar = startStar + 87
    end
end

function onUpdatePost(elapsed)
    setProperty("iconP1.x", 839)
    setProperty("iconP2.x", 237)
    setProperty("iconP2.y", downscroll and 15 or 533)
    setProperty("iconP1.y", downscroll and 10 or 530)
    setProperty("timeBarBG.y", downscroll and 640 or -15)
    setProperty("timeBarBG.x", 426)
    setProperty("timeBar.y", downscroll and 685 or 30)
    setProperty("timeBar.x", 435)
    setProperty("healthBarBG.x", 310)
    setProperty("healthBar.x", 313)

    for _, data in ipairs(lore) do
        if data.name == songName then
            if getPropertyFromClass('flixel.FlxG', 'mouse.visible') == true then
                if mouseOverLapsSprite('loray', 'other') then
                    setTextColor('loray', '3fe780')
                    if mouseClicked() then
                        os.execute('start "" "https://youtube.com/@LORAY_"')
                    end
                else
                    setTextColor('loray', 'FFFFFF')
                end
            else
                setTextColor('loray', 'FFFFFF')
            end
        end
    end

    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SEVEN') or getPropertyFromClass('flixel.FlxG', 'keys.justPressed.EIGHT') or getPropertyFromClass('flixel.FlxG', 'keys.justPressed.NUMPADMULTIPLY')then
        playSound('boop', 1, 'boop')
    end
end

function onUpdate(elapsed)
    setProperty('loray.x', getProperty('loraySign.x') + 10)
end

function onTweenCompleted(tag)
    if tag == 'songsignbye' then
        removeLuaSprite('loraySign', true)
        removeLuaText('loray', true)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'byebye' then
        setPropertyFromClass('flixel.FlxG', 'mouse.visible', false)
        doTweenX('loraysignbye', 'loraySign', -400, crochet / 200, 'quadInOut')
    end
end

function onSongStart()
    if stepCredits == 0 then
        showCredits()
    end
    doTweenColor('timebar', 'timeBar', '3fe780', 0.01, 'linear')
end

function onStepHit()
    if curStep == stepCredits then
        showCredits()
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then
        if misses == 0 then
            for i = 1, 5 do
                playAnim("star"..i, "flash", false, false, 0)
            end
        else
            for i = 1, 5 do
                playAnim("star"..i, "static", false, false, 0)
            end
        end
    end
end

function onRecalculateRating()
    if misses > 0 then
        for i = 1, 5 do
            doTweenColor('starChange'..i, 'star'..i, 'FFFFFF', 0.01, 'linear')
        end
        if (getProperty('ratingPercent') * 100) >= 90 then
            for i = 1, 5 do
                doTweenColor('starChange'..i, 'star'..i, 'FFFF00', 0.01, 'linear')
            end
        elseif (getProperty('ratingPercent') * 100) >= 85 then
            for i = 1, 4 do
                doTweenColor('starChange'..i, 'star'..i, 'FFFF00', 0.01, 'linear')
            end
        elseif (getProperty('ratingPercent') * 100) >= 80 then
            for i = 1, 3 do
                doTweenColor('starChange'..i, 'star'..i, 'FFFF00', 0.01, 'linear')
            end
        elseif (getProperty('ratingPercent') * 100) >= 75 then
            for i = 1, 2 do
                doTweenColor('starChange'..i, 'star'..i, 'FFFF00', 0.01, 'linear')
            end
        elseif (getProperty('ratingPercent') * 100) >= 70 then
            doTweenColor('starChange1', 'star1', 'FFFF00', 0.01, 'linear')
        end
    end
end

function showCredits()
    if creditsSkip == true then
        setProperty('loraySign.x', 50)
    else
        doTweenX('loraysign', 'loraySign', 50, crochet / 500, 'quadInOut')
    end
    setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
    runTimer('byebye', 4)
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