function onCreate()
	makeLuaSprite('bg', 'mario', -640, -200)
	scaleObject('bg', 1.1, 1.1)
	addLuaSprite('bg', false)

	makeLuaSprite('crowd', 'fever/crowd', -600, 465)
	scaleObject('crowd', 1.2, 1.2)
	updateHitbox('crowd')
	addLuaSprite('crowd', true)
end

function onBeatHit()
	setProperty('crowd.y', getProperty('crowd.y') + 20)
	doTweenY('crowdBop', 'crowd', getProperty('crowd.y') - 20, 0.15, 'cubeOut')
end