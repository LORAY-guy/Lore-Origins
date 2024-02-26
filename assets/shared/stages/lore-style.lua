function onCreate()
	setProperty('defaultCamZoom',0.8)

	makeLuaSprite('back','lore-style/back', -400, -200)
	scaleObject('back', 1.5, 1.5)
	setScrollFactor('back', 0.8, 0.8)

	makeLuaSprite('floor','lore-style/floor', -900, 550)
	scaleObject('floor', 1.4, 1.4)
	setScrollFactor('floor', 1, 1)

	makeLuaSprite('chairs','lore-style/chairs', -400, 400)
	scaleObject('chairs', 1.2, 1.2)
	setScrollFactor('chairs', 0.9, 0.9)

	makeLuaSprite('light', 'lore-style/light', -305, -350)
	scaleObject('light', 1.6, 1.4)
	setScrollFactor('light', 1.3, 1.3)
	setBlendMode('light','add')
	setProperty('light.alpha', 0.8)

	makeAnimatedLuaSprite('assholes1','lore-style/assholes1', -400, 300)
	addAnimationByPrefix('assholes1','dance','assholes1 idle',24,true);
	scaleObject('assholes1', 1.1, 1.1)
	setScrollFactor('assholes1', 0.9, 0.9)

	makeAnimatedLuaSprite('assholes2','lore-style/assholes2', -400, 100)
	addAnimationByPrefix('assholes2','dance','assholes2 idle',24,true);
	scaleObject('assholes2', 1.1, 1.1)
	setScrollFactor('assholes2', 0.9, 0.9)

	makeAnimatedLuaSprite('assholes3','lore-style/assholes3', -200, 0)
	addAnimationByPrefix('assholes3','dance','assholes3 idle',24,true);
	scaleObject('assholes3', 1, 1)
	setScrollFactor('assholes3', 0.9, 0.9)

	makeAnimatedLuaSprite('aster','lore-style/aster', -550, 300)
	addAnimationByPrefix('aster','dance','aster idle',24,true);
	scaleObject('aster', 1.2, 1.2)
	setScrollFactor('aster', 1.3, 1.3)

	makeAnimatedLuaSprite('doge','lore-style/doge', 1000, 300)
	addAnimationByPrefix('doge','dance','doge idle',24,true);
	scaleObject('doge', 1.2, 1.2)
	setScrollFactor('doge', 1.3, 1.3)

	addLuaSprite('back',false)
	addLuaSprite('chairs',false)
	addLuaSprite('light',true)
	addLuaSprite('assholes3',false)
	addLuaSprite('assholes2',false)
	addLuaSprite('assholes1',false)
	addLuaSprite('floor',false)
	addLuaSprite('aster',true)
	addLuaSprite('doge',true)
end

function onBeatHit()
    if curBeat % 2 == 0 then
        objectPlayAnimation('assholes1','dance',true);
    end

    if curBeat % 2 == 0 then
        objectPlayAnimation('assholes2','dance',true);
    end

    if curBeat % 2 == 0 then
        objectPlayAnimation('aster','dance',true);
    end

    if curBeat % 2 == 0 then
        objectPlayAnimation('doge','dance',true);
    end

    if curBeat % 2 == 0 then
        objectPlayAnimation('assholes3','dance',true);
    end
end