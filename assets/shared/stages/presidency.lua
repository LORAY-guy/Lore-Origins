function onCreate()
    makeLuaSprite("bg", "capitol", -4140, -3600)
    scaleObject("bg", 5, 5, true) -- bruh
    addLuaSprite("bg", false)

    makeLuaSprite("lecturn", "lecturn", 450.3625, 450)
    scaleObject("lecturn", 0.325, 0.325, true)
    addLuaSprite("lecturn", true)
end

function onCreatePost()
    setProperty("dad.x", getProperty("lecturn.x") + getProperty("lecturn.width") / 2 - 140)
    setProperty("camFollow.x", 641.5)
end