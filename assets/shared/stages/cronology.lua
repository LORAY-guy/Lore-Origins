function onCreate() 
	makeLuaSprite('backstage', 'epicOffice', -480, -200)
	scaleObject('backstage', 3.25, 3.25)
	updateHitbox('backstage')
	setProperty('backstage.antialiasing', false)
	addLuaSprite('backstage',false)
end

function onCreatePost()
	setProperty('gf.visible', false)
end