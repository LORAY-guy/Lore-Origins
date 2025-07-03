function onCreatePost()
    if not lowQuality then
        initRTXCharacters()
    end
end

function onUpdatePost()
    if not lowQuality then
        playAnim("lorayRTX", getProperty("boyfriend.animation.curAnim.name"), true, false, getProperty("boyfriend.animation.curAnim.curFrame"))
        playAnim("luaRTX", getProperty("dad.animation.curAnim.name"), true, false, getProperty("dad.animation.curAnim.curFrame"))
    end
end

function initRTXCharacters()
    precacheImage("characters/LORAY", true)
    makeAnimatedLuaSprite("lorayRTX", "characters/LORAY", getProperty("boyfriend.x") + 5, getProperty("boyfriend.y"))
    addAnimationByPrefix("lorayRTX", "idle", "shaggy_idle", 1, false)
    addAnimationByPrefix("lorayRTX", "singLEFT", "shaggy_right", 1, false)
    addAnimationByPrefix("lorayRTX", "singDOWN", "shaggy_down", 1, false)
    addAnimationByPrefix("lorayRTX", "singUP", "shaggy_up", 1, false)
    addAnimationByPrefix("lorayRTX", "singRIGHT", "shaggy_left", 1, false)
    addOffset("lorayRTX", "idle", -1, -186)
    addOffset("lorayRTX", "singLEFT", 130, -173)
    addOffset("lorayRTX", "singDOWN", 97, -185)
    addOffset("lorayRTX", "singUP", -34, -170)
    addOffset("lorayRTX", "singRIGHT", -34, -185)
    setProperty("lorayRTX.alpha", 0.25)
    setProperty("lorayRTX.flipY", true)
    setProperty("lorayRTX.flipX", true)
    setProperty("lorayRTX.y", getProperty("lorayRTX.y") + getProperty("boyfriend.height") + 100)
    addLuaSprite("lorayRTX", false)
    setObjectOrder("lorayRTX", getObjectOrder("plat") - 1)

    precacheImage("characters/Lua", true)
    makeAnimatedLuaSprite("luaRTX", "characters/Lua", getProperty("dad.x"), getProperty("dad.y"))
    addAnimationByPrefix("luaRTX", "idle", "Idle", 1, false)
    addAnimationByPrefix("luaRTX", "singLEFT", "Left", 1, false)
    addAnimationByPrefix("luaRTX", "singDOWN", "Down", 1, false)
    addAnimationByPrefix("luaRTX", "singUP", "Up", 1, false)
    addAnimationByPrefix("luaRTX", "singRIGHT", "Left", 1, false)
    setProperty("luaRTX.alpha", 0.25)
    setProperty("luaRTX.flipY", true)
    setProperty("luaRTX.y", getProperty("luaRTX.y") + getProperty("dad.height") - 120)
    setProperty("luaRTX.visible", false)
    addLuaSprite("luaRTX", false)
    setObjectOrder("luaRTX", getObjectOrder("plat") - 1)
end