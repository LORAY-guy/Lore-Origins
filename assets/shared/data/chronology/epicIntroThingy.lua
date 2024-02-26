--I'm putting the intro code into a separated lua file cuz i feel like this is gonna get messy
local mult = 1
local multPuz = 1
local num = 0
local loopCount = 0

local puzzleNames = {
    {img = 'WilliamAftonLit', name = 'puzzle1'},
    {img = 'SaveThemLit', name = 'puzzle2'},
    {img = 'GiveCakeLit', name = 'puzzle3'},
    {img = 'BlinkingOn', name = 'puzzle4'},
    {img = 'CharlieDeathLit', name = 'puzzle5'}
}

function onCreate()
    makeLuaSprite('fnafLogo', 'introStuff/fnaflogo', 0, 0)
    setObjectCamera('fnafLogo', 'camOther')
    scaleObject('fnafLogo', 0.2, 0.2)
    screenCenter('fnafLogo', 'xy')
    setProperty('fnafLogo.visible', false)
    addLuaSprite('fnafLogo', false)
    setProperty('fnafLogo.velocity.x', 0)
    setProperty('fnafLogo.velocity.y', 0)

    puzzlePieces(puzzleNames)

    makeAnimatedLuaSprite('vintage', 'vintage', -400, -200)
	addAnimationByPrefix('vintage', 'idle', 'idle', 24, true)
	objectPlayAnimation('vintage', 'idle', false)
    setObjectCamera('vintage', 'camOther')
	scaleObject('vintage', 2.5, 2.5)
    screenCenter('vintage', 'xy')
    setProperty('vintage.alpha', 0.4)
    setProperty('vintage.visible', false)
	addLuaSprite('vintage', false)

    setProperty('skipCountdown', true)
    setProperty('vocals.volume', 0)
    setPropertyFromClass('flixel.FlxG.sound.music', 'volume', 0)
end

function onCreatePost()
    math.randomseed(os.time())
    setProperty('camGame.visible', false)
end

function onSongStart()
    cameraFlash('camOther', 'FFFFFF', 1.7)
	setProperty('camHUD.visible', false)
    setProperty('vintage.visible', true)
    setProperty('fnafLogo.visible', true)
    doTweenX('fnafLogoScaleX', 'fnafLogo.scale', 0.225, 3, 'linear')
    doTweenY('fnafLogoScaleY', 'fnafLogo.scale', 0.225, 3, 'linear')
    setProperty('vocals.volume', 1)
    setPropertyFromClass('flixel.FlxG.sound.music', 'volume', 1)
end

function onStepHit()
    if curStep == 30 then
        createText('19', 'BOOKS')
        doTweenAlpha('fnafLogoFadeOut', 'fnafLogo', 0, 0.75, 'sineInOut')
    end

    if curStep == 42 then
        createText('11', 'GAMES')
    end

    if curStep == 56 then
        createText('8', 'YEARS')
    end

    if curStep == 82 then
        doTweenAlpha('numbers3fadeOut', 'numbers3', 0, 1.25, 'sineIn')
        doTweenAlpha('subject3fadeOut', 'subject3', 0, 1.25, 'sineIn')
    end

    if curStep == 105 then
        createEpicText()
        setProperty('the.alpha', 1)
    end

    if curStep == 109 then
        setProperty('ultimate.alpha', 1)
    end

    if curStep == 117 then
        setProperty('FNAF.alpha', 1)
    end

    if curStep == 123 then
        setProperty('TIMELINE.alpha', 1)
    end

    if curStep == 137 then
        for i = 1, #epicTexts do
            doTweenAlpha(epicTexts[i]..'fadeOut', epicTexts[i], 0, 1.25, 'sineIn')
        end
        runTimer('puzzleMove', 1, 5)
    end

    if curStep == 206 then
        makeLuaText('tragedy', 'TRAGEDY', 750, 0, 0)
        setTextFont('tragedy', 'matpat.otf')
        setTextColor('tragedy', 'FFFFFF')
        setTextSize('tragedy', 128)
        setObjectCamera('tragedy', 'camOther')
        screenCenter('tragedy', 'xy')
        setObjectOrder('tragedy', getObjectOrder('vintage') - 1)
        doTweenAlpha('tragedyFadeOut', 'tragedy', 0, 0.75, 'sineIn')
        addLuaText('tragedy', false)
    end

    if curStep == 217 then
        makeLuaText('jealousy', 'JEALOUSY', 750, 0, 0)
        setTextFont('jealousy', 'matpat.otf')
        setTextColor('jealousy', 'FFFFFF')
        setTextSize('jealousy', 128)
        setObjectCamera('jealousy', 'camOther')
        screenCenter('jealousy', 'xy')
        setObjectOrder('jealousy', getObjectOrder('vintage') - 1)
        doTweenAlpha('jealousyFadeOut', 'jealousy', 0, 0.75, 'sineIn')
        addLuaText('jealousy', false)
    end

    if curStep == 228 then
        makeLuaText('loss', 'LOSS', 750, 0, 0)
        setTextFont('loss', 'matpat.otf')
        setTextColor('loss', 'FFFFFF')
        setTextSize('loss', 128)
        setObjectCamera('loss', 'camOther')
        screenCenter('loss', 'xy')
        setObjectOrder('loss', getObjectOrder('vintage') - 1)
        doTweenAlpha('lossFadeOut', 'loss', 0, 0.6, 'sineIn')
        addLuaText('loss', false)
    end

    if curStep == 236 then
        for _, data in ipairs(puzzleNames) do
            removeLuaSprite(data.name, true)
        end
        removeLuaSprite('vintage', true)
    end

    if curStep == 256 then
		setProperty('camGame.visible', true)
		setProperty('camHUD.visible', true)
		cameraFlash('camHUD', 'FFFFFF', 1.2)
	end
end

function onUpdate(elapsed)
    if curStep < 256 then
        setProperty('fnafLogo.velocity.x', getProperty('fnafLogo.velocity.x') + 0.5 * mult)
        setProperty('fnafLogo.velocity.y', getProperty('fnafLogo.velocity.y') + 0.25 * mult)

        if getProperty('fnafLogo.velocity.x') >= 25 then
            mult = -1
        elseif getProperty('fnafLogo.velocity.x') <= -25 then
            mult = 1
        end

        if getProperty('fnafLogo.velocity.y') >= 25 then
            mult = -1
        elseif getProperty('fnafLogo.velocity.y') <= -25 then
            mult = 1
        end

        setProperty('fnafLogo.angle', getProperty('fnafLogo.velocity.x') / 100)
    end
end

function onTweenCompleted(tag)
    if tag == 'fnafLogoFadeOut' then
        removeLuaSprite('fnafLogo', true)
    end

    if tag == 'numbers'..(num - 1)..'fadeOut' then
        removeLuaText('numbers'..(num - 1), true)
        removeLuaText('subject'..(num - 1), true)
    end

    if tag == 'tragedyFadeOut' then
        removeLuaText('tragedy', true)
    end

    if tag == 'jealousyFadeOut' then
        removeLuaText('jealousy', true)
    end

    if tag == 'lossFadeOut' then
        removeLuaText('loss', true)
    end

    for i = 1, #epicTexts do
        if tag == epicTexts[i]..'fadeOut' then
            removeLuaText(epicTexts[i], true)
            epicTexts[i] = nil
        end
    end
end

function createText(number, subject)
    makeLuaText('numbers'..(num + 1), number, 450, 0, 0)
    setTextFont('numbers'..(num + 1), 'matpat.otf')
    setTextColor('numbers'..(num + 1), 'FFFF00')
    setTextSize('numbers'..(num + 1), 300)
    setObjectCamera('numbers'..(num + 1), 'camOther')
    screenCenter('numbers'..(num + 1), 'xy')
    setObjectOrder('numbers'..(num + 1), getObjectOrder('vintage') - 1)
    setProperty('numbers'..(num + 1)..'.y', getProperty('numbers'..(num + 1)..'.y') - 25)
    setProperty('numbers'..(num + 1)..'.alpha', 0)
    addLuaText('numbers'..(num + 1), false)

    makeLuaText('subject'..(num + 1), subject, 450, 0, 0)
    setTextFont('subject'..(num + 1), 'matpat.otf')
    setTextColor('subject'..(num + 1), 'FFFFFF')
    setTextSize('subject'..(num + 1), 106)
    setObjectCamera('subject'..(num + 1), 'camOther')
    screenCenter('subject'..(num + 1), 'xy')
    setObjectOrder('subject'..(num + 1), getObjectOrder('vintage') - 1)
    setProperty('subject'..(num + 1)..'.y', getProperty('numbers'..(num + 1)..'.y') + 250)
    setProperty('subject'..(num + 1)..'.alpha', 0)
    addLuaText('subject'..(num + 1), false)

    switchTexts()
end

function switchTexts()
    doTweenAlpha('numbers'..num..'fadeOut', 'numbers'..num, 0, 0.75, 'sineIn')
    doTweenAlpha('subject'..num..'fadeOut', 'subject'..num, 0, 0.75, 'sineIn')
    num = num + 1
    doTweenAlpha('numbers'..num..'fadeIn', 'numbers'..num, 1, 0.75, 'sineIn')
    doTweenAlpha('subject'..num..'fadeIn', 'subject'..num, 1, 0.75, 'sineIn')
    doTweenX('numbers'..num..'ScaleX', 'numbers'..num..'.scale', 1.1, 3, 'linear')
    doTweenY('numbers'..num..'ScaleY', 'numbers'..num..'.scale', 1.1, 3, 'linear')
    doTweenX('subject'..num..'ScaleX', 'subject'..num..'.scale', 1.1, 3, 'linear')
    doTweenY('subject'..num..'ScaleY', 'subject'..num..'.scale', 1.1, 3, 'linear')
end

function createEpicText()
    setupText('the', 'matpat.otf', 'FFFFFF', 450, 106, -285, -50)
    setupText('ultimate', 'matpat.otf', 'FFFFFF', 750, 106, 275, -50)
    setupText('FNAF', 'matpat.otf', 'FFFF00', 450, 128, -325, 50)
    setupText('TIMELINE', 'matpat.otf', 'FFFF00', 750, 128, 375, 50)

    epicTexts = {'the', 'ultimate', 'FNAF', 'TIMELINE'}
end

function setupText(text, font, color, width, size, offsetX, offsetY)
    makeLuaText(text, text:upper(), width, 0, 0)
    setTextFont(text, font)
    setTextColor(text, color)
    setTextSize(text, size)
    setObjectCamera(text, 'camOther')
    screenCenter(text, 'xy')
    setObjectOrder(text, getObjectOrder('vintage') - 1)
    setProperty(text..'.y', getProperty(text..'.y') + offsetY)
    if text == 'ultimate' then
        setProperty(text..'.x', getProperty('the.x') + offsetX)
    elseif text == 'TIMELINE' then
        setProperty(text..'.x', getProperty('FNAF.x') + offsetX)
    else
        setProperty(text..'.x', getProperty(text..'.x') + offsetX)
    end
    setProperty(text..'.alpha', 0)
    addLuaText(text, false)
end

function puzzlePieces(spr)
    for _, data in ipairs(spr) do
        makeLuaSprite(data.name, 'introStuff/'..data.img, (250 * _), 0)
        setObjectCamera(data.name, 'camOther')
        scaleObject(data.name, 0.34, 0.34)
        screenCenter(data.name, 'y')
        setProperty(data.name..'.x', getProperty(data.name..'.x') - 250)
        setProperty(data.name..'.y', getProperty(data.name..'.y') + 750 * multPuz)
        setObjectOrder(data.name, getObjectOrder('vintage') - 1)
        addLuaSprite(data.name, false)
        multPuz = -multPuz
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'puzzleMove' then
        loopCount = loopCount + 1
        bringThePiecesIn(puzzleNames, loopCount)
    end
end

function bringThePiecesIn(spr, loop)
    local thingyX = 1
    local thingyY = 1

    for _, data in ipairs(spr) do
        if ('puzzle'..loop == data.name) then
            if getProperty(data.name..'.x') > 500 then
                thingyX = -1
            end

            if getProperty(data.name..'.y') > 0 then
                thingyY = 1
            else
                thingyY = -1
            end

            doTweenX(data.name..'MoveX', data.name, getProperty(data.name..'.x') + (20 * thingyX), 1.2, 'quadOut')
            doTweenY(data.name..'MoveY', data.name, getProperty(data.name..'.y') - (540 * thingyY), 1.2, 'quadOut')
            doTweenAngle(data.name..'MoveAngle', data.name, math.random(-15, 15), 1.2, 'quadOut')
        end
    end
end