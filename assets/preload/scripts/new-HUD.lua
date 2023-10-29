local startStar = 365
local lore = {
    {name = 'lored', step = 0, skip = false},
    {name = 'lore-ryan', step = 0, skip = false},
    {name = 'lore-awesomix', step = 100, skip = true},
    {name = 'lore-apology', step = 64, skip = true},
    {name = 'fever', step = 0, skip = false},
    {name = 'lore-style', step = 0, skip = false},
    {name = 'live', step = 0, skip = false},
}

function onCreate()
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

    makeLuaSprite('shaggersSign', 'shaggersSign', -400, 175)
    setObjectCamera('shaggersSign', 'camOther')
    setProperty('shaggersSign.antialiasing', false)
    addLuaSprite('shaggersSign', false)
    
    makeLuaText('shag', 'Coded by\nShaggers', 300, 0, 185)
    setObjectCamera('shag', 'camOther')
    setTextAlignment('shag', 'left')
    setTextFont('shag', 'ourple.ttf')
    setTextSize('shag', 36)
    addLuaText('shag', false)

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
    setTextSize("scoreTxt", 42)
    setProperty("scoreTxt.y", downscroll and 570 or 57)
    setTextFont('scoreTxt', 'DIGILF__.TTF')
    setProperty('healthBar.y', downscroll and 87 or 610)
    setProperty("showComboNum", false)
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
    setTextString('scoreTxt', 'Score:\n'..score..'')
end

function onUpdate(elapsed)
    setProperty('shag.x', getProperty('shaggersSign.x') + 10)
end

function onTweenCompleted(tag)
    if tag == 'songsignbye' then
        removeLuaSprite('shaggersSign', true)
        removeLuaText('shag', true)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'byebye' then
        doTweenX('shagsignbye', 'shaggersSign', -400, crochet / 200, 'quadInOut')
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
        setProperty('shaggersSign.x', 50)
    else
        doTweenX('shagsign', 'shaggersSign', 50, crochet / 500, 'quadInOut')
    end
    runTimer('byebye', 4)
end