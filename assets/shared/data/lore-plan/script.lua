local playing = false

function onCreate()
    setProperty('skipCountdown', true)

    precacheImage('characters/charles')

	makeAnimatedLuaSprite('charles', 'characters/charles', 1650, 0)
	addAnimationByPrefix('charles', 'idle', 'idle', 24, false)
	addAnimationByPrefix('charles', 'singLEFT', 'right', 24, false)
	addAnimationByPrefix('charles', 'singDOWN', 'down', 24, false)
	addAnimationByPrefix('charles', 'singUP', 'up', 24, false)
	addAnimationByPrefix('charles', 'singRIGHT', 'left', 24, false)
    addAnimationByPrefix('charles', 'oh', 'oh', 24, false)
	addAnimationByPrefix('charles', 'perfect', 'perfect', 24, false)
	setProperty('charles.flipX', true)
	addLuaSprite('charles', true)
    setProperty('camOther.alpha', 0)
    makeAnimationList()
end

function onBeatHit()
    if curBeat >= 96 then
        if curBeat % 2 == 0 and not playing then
            objectPlayAnimation('charles', 'idle', false)
        end
    end
end

animationsList = {}
holdTimers = {charles = -1.0}
noteDatas = {charles = 0}
function makeAnimationList()
	animationsList[0] = 'singLEFT'
	animationsList[1] = 'singDOWN'
	animationsList[2] = 'singUP'
	animationsList[3] = 'singRIGHT'
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if noteType == 'Special Sing' then
		if not isSustainNote then
			noteDatas.charles = direction
		end	
		characterToPlay = 'charles'
		animToPlay = noteDatas.charles
			
		playAnimation(characterToPlay, animToPlay, true)
	end
end

function playAnimation(character, animId, forced)
	animName = animationsList[animId]
	if character == 'charles' then
		objectPlayAnimation('charles', animName, forced)
        playing = true
	end
end

function onUpdate(elapsed)
    if getProperty("charles.animation.curAnim.finished") and getProperty("charles.animation.curAnim.name") ~= 'idle' then
        playing = false
    end
end

function onStepHit()
    if curStep == 12 then
        setProperty('camOther.alpha', 1)
    end

    if curStep == 352 then
        doTweenX('charkleshi', 'charles', 665, 2, 'quadInOut')
        setProperty('defaultCamZoom', 1)
    end

    if curStep == 372 then
        objectPlayAnimation('charles', 'oh', true)
    end

    if curStep == 448 then
        doTweenX('dadwoosh', 'dad', getProperty('dad.x') - 125, 1, 'quadInOut')
        doTweenX('henryhi', 'boyfriend', 250, 1, 'quadInOut')
        setProperty('boyfriend.flipX', true)
        setProperty('iconP1.flipX', false)
        setObjectOrder('boyfriendGroup', getObjectOrder('charles') + 1)
    end

    if curStep == 1138 then
        objectPlayAnimation('charles', 'perfect', true)
    end
end

function onUpdate(elapsed)
    if curStep >= 352 then
        setProperty('camFollow.x', 780)
        setProperty('camFollow.y', 400)
    end

    if curStep >= 448 then
        setProperty('boyfriend.flipX', true)
        setProperty('boyfriend.y', 229)
    end
end

function onEvent(e, value1, value2)
    if e == 'Change Character' then
        if value2 == 'henryphone' then
            setProperty('boyfriend.x', -400)
            setProperty('iconP1.flipX', true)
        end
    end
end