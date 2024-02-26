function onStepHit() 
	if getProperty('healthBar.percent') < 20 and curStep % 2 == 0 then
		flipped = not flipped
		setProperty('iconP1.flipX', flipped)
	end
	if (curStep % 4 == 0) and getProperty('boyfriend.imageFile') == 'characters/guyRTX' and getProperty('boyfriend.animation.curAnim.name') == 'idleflipped' then
		playAnim("boyfriend", "idleflipped", true)
		setProperty('boyfriend.y', getProperty('boyfriend.y') + 20)
		doTweenY('raise', 'boyfriend', getProperty('boyfriend.y') - 20, 0.15, 'cubeOut')
	end
end

function onUpdate(e)
	local angleOfs = math.random(-5, 5)
	if getProperty('healthBar.percent') < 20 then
		setProperty('iconP1.angle', angleOfs)
	else
		setProperty('iconP1.angle', 0)
	end
end