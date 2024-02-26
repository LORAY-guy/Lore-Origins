local nextSpriteID = 1
local curHorses = {}
local luck = 0.2
local phoneFollow = true
--phone pos = 400, -120

function onCreate()
    makeLuaSprite("stool", 'stoolphone', 455, 24)
    addLuaSprite("stool")

    makeLuaSprite("phone", 'phone', 0, -300)
    setProperty("phone.angle", -25)
    addLuaSprite("phone")

    setObjectOrder("stool", getObjectOrder("gfGroup"))
    setObjectOrder("phone", (getObjectOrder("gfGroup") + 1))

    makeAnimatedLuaSprite('horsePhone', 'veryimportant/horseguy', -1700, -380)
    addAnimationByPrefix('horsePhone', 'walk', 'horseWALK', 1000)
    scaleObject('horsePhone', 2.4, 1.7)
    setObjectOrder("horsePhone", getObjectOrder("stool"))
    addLuaSprite('horsePhone')
end

function onCreatePost()
    setProperty("gf.visible", false)
end

function onUpdate()
    if getRandomBool(luck) then
        horseFunni()
    end

    for spriteID, horseData in pairs(curHorses) do
        local songPos = getSongPosition()
        if (songPos - horseData.startTime) >= horseData.animationTime then
            removeLuaSprite(horseData.name)
            curHorses[spriteID] = nil
        end
    end

    if phoneFollow == true then
        setProperty("phone.x", getProperty("horsePhone.x") + 250)
    end
end

function onSectionHit()
    if curSection % 64 == 0 then
        luck = luck + 0.2
    end
end

function horseFunni()
    local speed = getRandomFloat(1, 6)
    local horseName = 'horse_' .. nextSpriteID
    local spriteID = nextSpriteID

    makeAnimatedLuaSprite(horseName, 'veryimportant/horseguy', -1500, getRandomInt(-170, 500))
    addAnimationByPrefix(horseName, 'walk', 'horseWALK', 1000)
    addLuaSprite(horseName, true)

    if getProperty(horseName..'.y') < 35 then
        setObjectOrder(horseName, (getObjectOrder("gfGroup") - 1))
    elseif getProperty(horseName..'.y') > 35 and getProperty(horseName..'.y') < 275 then
        setObjectOrder(horseName, (getObjectOrder("dadGroup") - 1))
    else
        setObjectOrder(horseName, (getObjectOrder("obj3") - 1))
    end
    
    scaleObject(horseName, getRandomFloat(0.1, 2.2), getRandomFloat(0.1, 1.5), true)
    doTweenX('horsewalk_' .. spriteID, horseName, 1800, speed, 'linear')

    local horseData = {
        name = horseName,
        startTime = getSongPosition(),
        animationTime = speed * 1000,  -- Set your animation time here
    }
    nextSpriteID = nextSpriteID + 1
end

function introPhone()
    doTweenX("horsePhoneXMove", "horsePhone", 1500, 4, "linear")
    runTimer("phoneDrop", 2.25)
end

function onStepHit()
    if curStep == 1808 then
        introPhone()
    end
end

function onTweenCompleted(tag)
    if tag == 'phoneFallX' then
        removeLuaSprite("phone", true)
        removeLuaSprite("stool", true)
        setObjectOrder("horsePhone", (getObjectOrder("gfGroup") - 1))
        setProperty("gf.visible", true)
    end

    if tag == 'horsePhoneXMove' then
        removeLuaSprite("horsePhone", true)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'phoneDrop' then
        phoneFollow = false
        doTweenX("phoneFallX", "phone", 400, 0.4, "linear")
        doTweenY("phoneFallY", "phone", -120, 0.35, "cubeIn")
        doTweenAngle("phoneFallA", "phone", 0, 0.35, "cubeIn")
    end
end