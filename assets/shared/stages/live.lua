function onCreate()
	makeLuaSprite('stageback', 'live/live_bg_1', -600, -300)
	setScrollFactor('stageback', 0.9, 0.9)
	scaleObject('stageback', 2.0, 2.0)

	if not lowQuality then
		makeLuaSprite('boxes', 'live/live_bg_2', -250, 0)
		setScrollFactor('boxes', 1.7, 1.7)
		scaleObject('boxes', 1.7, 1.7)

		makeLuaSprite('boxes2', 'live/live_bg_2', -1025, 100)
		setScrollFactor('boxes2', 1.7, 1.7)
		setProperty('boxes2.flipX', true)
		scaleObject('boxes2', 1.7, 1.7)
	end

	addLuaSprite('stageback', false)
	addLuaSprite('boxes', true)
	addLuaSprite('boxes2', true)
end