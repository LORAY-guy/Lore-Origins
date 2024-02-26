function onCreate() --bg made by AI, fr
	makeLuaSprite('beach', 'beach', 400, 125)
	scaleObject('beach', 0.3, 0.3)
	updateHitbox('beach')
	addLuaSprite('beach',false)

	makeLuaSprite('stool', 'stool', 1020, 680)
	scaleObject('stool', 0.11, 0.11)
	updateHitbox('stool')
	addLuaSprite('stool',false)
end

function onCreatePost()
	runHaxeCode([[
        game.timeBarBG.loadGraphic(Paths.image('lore'));
    ]])
	setObjectOrder("timeBarBG", getObjectOrder("timeBar") + 1)
	setObjectOrder("timeTxt", getObjectOrder("timeBarBG") + 1)
	setObjectOrder("healthBarBG", getObjectOrder("healthBar") + 1)
	setObjectOrder("pizzaIconP1", getObjectOrder("healthBarBG") + 1)
end