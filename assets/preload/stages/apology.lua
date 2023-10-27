function onCreate()
	
	makeLuaSprite('stageback', 'apology/stageback', -600, -300)
	--setScrollFactor('stageback', 0.9, 0.9)
	
	makeLuaSprite('stagefront', 'apology/stagefront', -650, 600)
	--setScrollFactor('stagefront', 0.9, 0.9)
	scaleObject('stagefront', 1.1, 1.1)

	makeLuaSprite('stagecurtains', 'apology/stagecurtains', -525, -300)
	setScrollFactor('stagecurtains', 1.3, 1.3)
	scaleObject('stagecurtains', 0.9, 0.9)
	
	if not lowQuality then
		makeLuaSprite('stagelight_left', 'stage_light', -125, -100)
		setScrollFactor('stagelight_left', 1.1, 1.1)
		scaleObject('stagelight_left', 1.1, 1.1)
		
		makeLuaSprite('stagelight_right', 'stage_light', 1225, -100)
		setScrollFactor('stagelight_right', 1.1, 1.1)
		scaleObject('stagelight_right', 1.1, 1.1)
		setProperty('stagelight_right.flipX', true)
	end

	addLuaSprite('stageback', false)
	addLuaSprite('stagefront', false)
	addLuaSprite('stagelight_left', false)
	addLuaSprite('stagelight_right', false)
	addLuaSprite('stagecurtains', false)
end
