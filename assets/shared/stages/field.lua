--why am i wasting my time doing this...
local horseAmount = 0

local x_values = {}
local y_values = {}

function onCreate()
	makeLuaSprite('obj1', 'field', -870, -727)
	scaleObject('obj1', 1.4, 1.4)
	setObjectOrder("obj1", 0)
	addLuaSprite('obj1', false)
	
	makeLuaSprite('obj2', 'bushes', -998, -312)
	scaleObject('obj2', 1.1, 1.1)
	addLuaSprite('obj2', true)
	
	makeLuaSprite('obj3', 'bushes', -78, -362)
	scaleObject('obj3', 1.1, 1.1)
	addLuaSprite('obj3', true)
end

function onCreatePost()
    horseAmount = getRandomInt(2, 5)

    for i = 1, horseAmount do
        local x = getRandomFloat(-400, 1000) 
        local y = getRandomFloat(-210, -130)

		table.insert(x_values, x)
		table.insert(y_values, y)
	end

	table.sort(y_values, function(a, b) return a > b end)

    for i = 1, horseAmount do
		local horseBgName = "bghorse"..i
		local x = x_values[i]
		local y = y_values[i]

        makeAnimatedLuaSprite(horseBgName, 'horse', x, y)
        local isFlipped = x >= 350
        setProperty(horseBgName..".flipX", isFlipped)

        local scale = math.max(0.01, 0.35 - ((y + 210) / 300))
        scaleObject(horseBgName, scale, scale)

        updateHitbox(horseBgName)
        addAnimationByPrefix(horseBgName, "idle", "Idle", 24, false)
        objectPlayAnimation(horseBgName, "idle", false)
		setObjectOrder(horseBgName, (getObjectOrder("obj1") + i))
        addLuaSprite(horseBgName)
    end
end

function onBeatHit()
	for i = 1, horseAmount do
		objectPlayAnimation("bghorse"..i, "idle", false)
	end
end