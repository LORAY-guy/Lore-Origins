animationsListPlayer = {'LEFT', 'DOWN', 'UP', 'RIGHT', 'UP-alt'}
animationsList = {'LEFT', 'DOWN', 'UP', 'RIGHT'}
startTimes = {}

bonus = 100
firstSpace = false
botplaySine = 0
cooldown = false

function onCreate()
    precacheSound('boop')
    precacheSound('sfx_taunt')

    makeLuaText('thankstext', 'Thanks for playing!', 0, 0)
	setObjectCamera('thankstext', 'camOther')
	setTextSize('thankstext', 72)
	setProperty('thankstext.visible', false)
	screenCenter('thankstext', 'xy')
	addLuaText('thankstext', true)

    makeAnimatedLuaSprite('tauntPlayer', 'taunt', 995, 275)
    addAnimationByPrefix('tauntPlayer', 'taunt', 'Taunt', 60, false)
    scaleObject('tauntPlayer', 3.75, 3.75)
    setProperty('tauntPlayer.visible', false)
    setProperty('tauntPlayer.antialiasing', false)
    setObjectOrder('tauntPlayer', getObjectOrder('gfGroup') + 1)
    addLuaSprite('tauntPlayer', false)

    makeAnimatedLuaSprite('tauntMatpat', 'taunt', 570, 310)
    addAnimationByPrefix('tauntMatpat', 'taunt', 'Taunt', 60, false)
    scaleObject('tauntMatpat', 3.75, 3.75)
    setProperty('tauntMatpat.visible', false)
    setProperty('tauntMatpat.antialiasing', false)
    setObjectOrder('tauntMatpat', getObjectOrder('gfGroup') + 1)
    addLuaSprite('tauntMatpat', false)

    makeLuaText('tutorialTxt', 'Press \'SPACE\' to taunt', 250, 990, 650)
	setTextColor('tutorialTxt', '3fe780')
	setTextSize('tutorialTxt', 26)
	addLuaText('tutorialTxt', true)

    setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
    math.randomseed(os.time())
end

function onCreatePost()
    if botPlay then
        setTextString('thankstext', 'Thanks for watching!')
        screenCenter('thankstext', 'xy')
    end
    doTweenColor('scoreTxt', 'scoreTxt', '3fe780', 0.01, 'linear')
    setProperty('gf.y', 450)
    setProperty('gf.visible', false)
    triggerEvent('Camera Follow Pos', '1048', '572.8')
end

function onUpdate(elapsed)
    for textName, startTime in pairs(startTimes) do
        if (getSongPosition() - startTime) / 1000 >= 1 then
            removeLuaText(textName)
            startTimes[textName] = nil -- Remove the entry from the table
        end
    end

    if luaTextExists('tutorialTxt') == true then
		botplaySine = botplaySine + 180 * elapsed
		setProperty('tutorialTxt.alpha', 1 - math.sin((math.pi * botplaySine) / 180)) --actually took that from the Psych source code lol
	elseif botplaySine ~= nil then
		botplaySine = nil
	end

    if firstSpace == true and getProperty('tutorialTxt.alpha') < 0.01 then
		removeLuaText('tutorialTxt', true)
		firstSpace = nil
	end
end

function onUpdatePost(elapsed)
    if curStep <= 3872 then
        if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE') == true and cooldown == false then
            if not firstSpace then
                firstSpace = true
            end
            cooldown = true
            playAnim('boyfriend', 'sing'..animationsListPlayer[math.random(#animationsListPlayer)], false, false, 4)
            playAnim('tauntPlayer', 'taunt', false, false, 0)
            setProperty('tauntPlayer.visible', true)
            runTimer('hideTauntPlayer', 0.3)
            playSound('sfx_taunt', 0.25)
            tauntScore()
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'hideTauntPlayer' then
        setProperty('tauntPlayer.visible', false)
        cooldown = false
    end

    if tag == 'hideTauntMatpat' then
        setProperty('tauntMatpat.visible', false)
    end
end

function onStepHit()
    if curStep == 2792 then
        setProperty('gf.y', -500)
        setProperty('gf.visible', true)
        doTweenY('gfDrop', 'gf', 450, 1, 'bounceOut')
    end

    if not isStoryMode then
        if curStep == 3872 then
            setProperty('camGame.visible', false)
            setProperty('camHUD.visible', false)
            setProperty('thankstext.visible', true)
        end
    end
end

function onBeatHit()
    if curBeat == 156 or curBeat == 158 or curBeat == 540 or curBeat == 542 or curBeat == 732 or curBeat == 734 then
        doFunnyTaunt()
    end

    if curBeat % 2.0 == 0.0 then
        bonus = 1000
    else
        bonus = 100
    end
end

function onSectionHit()
    if not mustHitSection then
        doTweenColor('timebar', 'timeBar', '3fe780', 0.4, 'sineOut')
        doTweenColor('scoreTxt', 'scoreTxt', '3fe780', 0.4, 'sineOut')
    else
        doTweenColor('timebar', 'timeBar', 'ee0860', 0.4, 'sineOut')
        doTweenColor('scoreTxt', 'scoreTxt', 'ee0860', 0.4, 'sineOut')
    end

    if gfSection then
        doTweenColor('timebar', 'timeBar', 'c8bfe7', 0.4, 'sineOut')
        doTweenColor('scoreTxt', 'scoreTxt', 'c8bfe7', 0.4, 'sineOut')
    end
end

function doFunnyTaunt()
    playAnim('dad', 'sing'..animationsList[math.random(#animationsList)], false, false, 3)
    playAnim('tauntMatpat', 'taunt', false, false, 0)
    setProperty('tauntMatpat.visible', true)
    bonus = bonus + 1500
    runTimer('hideTauntMatpat', 0.3)
end

function tauntScore()
    if not botPlay then
        songPos = getSongPosition()
        sprName = 'scoreTauntText'..songPos
        makeLuaText(sprName, '+'..bonus..' pts', 0, 1000, downScroll and 50 or 640)
        setTextSize(sprName, 36)
        setTextBorder(sprName, 2, '000000')
        setObjectCamera(sprName, 'camHUD')
        doTweenAlpha(sprName..'byeAlpha', sprName, 0, 1, 'sineOut')
        doTweenY(sprName..'byeY', sprName, getProperty(sprName..'.y') - 50, 1.2, 'sineOut')
        addLuaText(sprName)
        addScore(bonus)
        if bonus > 100 then
            addHealth(0.05)
        end
        startTimes[sprName] = songPos
    end
end