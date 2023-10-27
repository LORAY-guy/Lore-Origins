function onCreate()
      
    makeLuaSprite('back','fever/stageback', -660,-400)
	scaleObject('back', 1.1, 1.1)
	updateHitbox('back')
	setObjectOrder('back',0)
	addLuaSprite('back',false)
      
    makeLuaSprite('stagefront', 'stagefront', -675,520)
	scaleObject('stagefront', 1.1, 1.1)
	updateHitbox('stagefront')
	setObjectOrder('stagefront',1)
	addLuaSprite('stagefront',false)

	makeLuaSprite('blackstuff', '', 0, 0)
	setScrollFactor('blackstuff', 0, 0)
	makeGraphic('blackstuff', 2000, 2000, '000000')
	screenCenter('blackstuff', 'xy')
	setProperty('blackstuff.alpha', 0.5)
	setObjectOrder('blackstuff', 20)
	addLuaSprite('blackstuff', true)
     
    makeLuaSprite('curtains','fever/stagecurtains', -730,-480)
	scaleObject('curtains', 1.1, 1.1)
	updateHitbox('curtains')
	setProperty('curtains.antialiasing', false)
	setObjectOrder('curtains', 6)
	addLuaSprite('curtains',true)

	makeLuaSprite('crowd','fever/crowd', -645,475)
	scaleObject('crowd', 1.1, 1.1)
	updateHitbox('crowd')
	addLuaSprite('crowd', true)

end

function onStepHit()
	if curStep == 768 or curStep == 2432 then
		loadGraphic('crowd', 'fever/crowdrtx')
	elseif curStep == 1280 or curStep == 2560 then
		loadGraphic('crowd', 'fever/crowd')
	end
end

function onBeatHit()
	setProperty('crowd.y', getProperty('crowd.y') + 20)
	doTweenY('crowdBop', 'crowd', getProperty('crowd.y') - 20, 0.15, 'cubeOut')
end