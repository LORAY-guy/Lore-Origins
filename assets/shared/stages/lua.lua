function onCreate()
    makeLuaSprite("bgcolour", 'lua/base', 0, 0)
    scaleObject("bgcolour", 500, 500, false)
    setScrollFactor("bgcolour", 0.025, 1)
    addLuaSprite("bgcolour")

    makeLuaSprite("stars", 'lua/stars', -1330, -950)
    scaleObject("stars", 3, 3, false)
    setScrollFactor("stars", 0.037, 0.2)
    addLuaSprite("stars")

    makeLuaSprite("sky", 'lua/sky', -1250 , -1250)
    scaleObject("sky", 4, 4, false)
    setScrollFactor("sky", 0.037, 0.2)
    setBlendMode('sky', 'screen')
    addLuaSprite("sky")

    makeLuaSprite("moon", 'lua/moon',2500 , -1750)
    scaleObject("moon", 1, 1, false)
    setScrollFactor("moon", 0.037, 0.2)
    setBlendMode('moon', 'lighten')
    addLuaSprite("moon")
    
    makeLuaSprite("sun", 'lua/thesun', -1000 , -2250)
    scaleObject("sun", 1.5, 1.5, false)
    setScrollFactor("sun", 0.05, 0.2)
    setBlendMode('sun', 'lighten')
    addLuaSprite("sun")

    makeLuaSprite("cloudsback", 'lua/cloudsback', -1330 , -950)
    scaleObject("cloudsback", 3.03, 3.03, false)
    setScrollFactor("cloudsback", 0.15, 0.5)
    addLuaSprite("cloudsback")

    makeLuaSprite("cloudsmid", 'lua/cloudsmid', -1250 , 433)
    scaleObject("cloudsmid", 4, 4, false)
    setScrollFactor("cloudsmid", 0.25, 0.5)
    addLuaSprite("cloudsmid")

    makeLuaSprite("cloudsfront", 'lua/cloudsfront', -1250 ,433)
    scaleObject("cloudsfront", 4, 4, false)
    setScrollFactor("cloudsfront", 0.33, 0.5)
    addLuaSprite("cloudsfront")

    makeLuaSprite("waltuh", 'lua/ocean', 0 , 2250)
    scaleObject("waltuh", 4, 4, false)
    setScrollFactor("waltuh", 0.45, 0.5)
    setBlendMode('waltuh', 'multiply')
    addLuaSprite("waltuh")

    -- fuck you loray, i do my code lol

    -- the end of that

    makeLuaSprite("plat", 'lua/platform', -1800 ,  1000)
    scaleObject("plat", 1, 1, false)
    addLuaSprite("plat")

    makeLuaSprite("haze", 'lua/hazemain', -5500 , -5200)
    scaleObject("haze", 4.5, 4.5, true)
    addLuaSprite("haze", true)
	
    makeLuaSprite("hazerays", 'lua/hazegodrays', 0 , 600)
    scaleObject("hazerays", 3.5, 3.5, false) 
	setScrollFactor("hazerays", 0.75, 0.75)
    setBlendMode('hazerays', 'mutiply')
    setProperty("hazerays.alpha", 0.75)
    addLuaSprite("hazerays", true)

    makeLuaSprite("lense1", 'lua/lensefirst', -100 , -75)
    setObjectCamera("lense1", "camHUD")
    scaleObject("lense1", 0.5, 0.5, false)
    setScrollFactor("lense1", 0.25, 0.25)
    setBlendMode('lense1', 'add')
    addLuaSprite("lense1", true)

    makeLuaSprite("lense2", 'lua/lensesecond', -225 , -50)
    setObjectCamera("lense2", "camHUD")
    scaleObject("lense2", 0.5, 0.5, false)
    setScrollFactor("lense2", 0.5, 0.5)
    setBlendMode('lense2', 'add')
    addLuaSprite("lense2", true)

    makeLuaSprite("lense", 'lua/lenselast', -325 , -20)
    setObjectCamera("lense", "camHUD")
    scaleObject("lense", 0.5, 0.5, false)
    setScrollFactor("lense", 0.75, 0.75)
    setBlendMode('lense', 'add')
    addLuaSprite("lense", true)
end

function onCreatePost()
    setProperty('hazerays.alpha', 0.5)

    setProperty('lense.alpha', 0)
    setProperty('lense1.alpha', 0)
    setProperty('lense2.alpha', 0)
end

function onSectionHit()
    if not mustHitSection then
        doTweenAlpha('lense','lense', 0.75, 0.25, smoothstepout)
        doTweenAlpha('lense1','lense1', 0.75, 0.25, smoothstepout)
        doTweenAlpha('lense2','lense2', 0.75, 0.25, smoothstepout)
    else
        doTweenAlpha('lense','lense', 0, 0.25, smoothstepout)
        doTweenAlpha('lense1','lense1', 0, 0.25, smoothstepout)
        doTweenAlpha('lense2','lense2', 0, 0.25, smoothstepout)
    end
end
