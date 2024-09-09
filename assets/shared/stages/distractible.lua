function onCreate()
    makeLuaSprite('bg', 'distractible', -965, -540)
    addLuaSprite('bg', true)

    makeLuaSprite("whiteStuff", "", 0.0, 0.0)
    makeGraphic("whiteStuff", 1280, 720, "FFFFFF")
    setObjectCamera("whiteStuff", "camOther")
    screenCenter("whiteStuff", 'xy')
    setProperty("whiteStuff.alpha", 0)
    addLuaSprite("whiteStuff")

    makeLuaText("awesomeText", "", 800, 0.0, 0.0)
    setObjectCamera("awesomeText", "camOther")
    setTextFont("awesomeText", "mark.ttf")
    setTextSize("awesomeText", 116)
    setTextBorder("awesomeText", 3, "000000")
    screenCenter("awesomeText", 'xy')
    setProperty("awesomeText.antialiasing", true)
    setProperty("awesomeText.visible", false)
    addLuaText("awesomeText")
end

function onCreatePost()
    triggerEvent("Camera Follow Pos", 0, 0)
    scaleObject("boyfriendGroup", 0.45, 0.45)
    scaleObject("gfGroup", 0.5, 0.5)
    scaleObject("dadGroup", 0.45, 0.45)

    for i = 0,3 do
		setPropertyFromGroup('strumLineNotes', i, 'x', -1000)
	end

	setDistractibleArrow(0)

    setProperty("boyfriend.alpha", 0.0001)
    setProperty("gf.alpha", 0.0001)
    setProperty("dad.alpha", 0.0001)

    setProperty("iconP1.alpha", 0)
    setProperty("iconP2.alpha", 0)

    setProperty("camZooming", true)
    setProperty("camGame.alpha", 0.00001)
    
    resetCharacters()
end

function onSongStart()
    setProperty("camGame.alpha", 1)
    cameraFlash("camGame", "FFFFFF", 1.2)
end

function onStepHit()
    if curStep == 67 then
        revealCharacter('boyfriend')
    elseif curStep == 74 then
        revealCharacter('gf')
    elseif curStep == 82 then
        revealCharacter('dad')
    end

    if curStep == 220 then
        doTweenAlpha("reverseCrash", "whiteStuff", 1, (stepCrochet / 1000) * 20, "sineIn")
    end

    if curStep == 237 then
        setProperty("awesomeText.visible", true)
        setAwesomeText('And ')
    end

    if curStep == 240 then
        setAwesomeText('And en ')
    end

    if curStep == 244 then
        setAwesomeText('And enjoy ')
    end

    if curStep == 251 then
        setAwesomeText('And enjoy  the ')
    end

    if curStep == 256 then
        setProperty("camGame.visible", true)
        setProperty("camHUD.visible", true)
        setAwesomeText('And enjoy  the show! ')
        doTweenAlpha("awesomeTextBye", "awesomeText", 0, crochet / 1000 * 2, "sineIn")
    end

    if curStep == 760 or curStep == 1264 or curStep == 1520 or curStep == 1904 or curStep == 2608 then
        resetArrowPos((crochet / 1000) * 4, 'sineInOut')
    end

    if curStep == 256 or curStep == 768 or curStep == 1024 or curStep == 1280 or curStep == 896 or curStep == 1152 or curStep == 1408 or curStep == 1536 or curStep == 1792 or curStep == 1920 or curStep == 2112 or curStep == 2624 or curStep == 2752 then
        cameraFlash("camHUD", "FFFFFF", 1.2)
    end

    if curStep == 768 or curStep == 1024 or curStep == 1280 or curStep == 1536 or curStep == 1584 or curStep == 1632 or curStep == 1696 or curStep == 1744 or curStep == 1768 or curStep == 1920 or curStep == 2082 or curStep == 2624 or curStep == 2816 then
        focusOnMark()
    end

    if curStep == 836 or curStep == 1088 or curStep == 1344 or curStep == 1552 or curStep == 1600 or curStep == 1664 or curStep == 1712 or curStep == 1752 or curStep == 1980 or curStep == 2068 or curStep == 2692 or curStep == 2846 then
        focusOnBob()
    end

    if curStep == 896 or curStep == 1152 or curStep == 1568 or curStep == 1616 or curStep == 1680 or curStep == 1736 or curStep == 1760 or curStep == 2056 or curStep == 2752 or curStep == 2864 then
        focusOnWade()
    end

    if curStep == 1220 or curStep == 1408 or curStep == 1776 then
        resetCharacters()
    end

    if curStep == 1200 or curStep == 1392 or curStep == 1760 then
        setDistractibleArrow((crochet / 1000) * 4, 'sineInOut')
    end

    if curStep == 2056 then
        setProperty("camGame.visible", true)
        setProperty("camHUD.visible", true)
        setProperty("whiteStuff.alpha", 0)
    end

    if curStep == 2104 then
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
    end

    if curStep == 2104 or curStep == 2106 or curStep == 2108 or curStep == 2110 then
        cancelTween("whiteStuffCoolEffect")
        setProperty("whiteStuff.alpha", 1)
        doTweenAlpha("whiteStuffCoolEffect", "whiteStuff", 0, 0.7, "sineOut")
    end

    if curStep == 2112 then
        cancelTween("whiteStuffCoolEffect")
        setProperty("whiteStuff.alpha", 0)
        setProperty("camGame.visible", true)
        setProperty("camHUD.visible", true)
        resetCharacters()
        setDistractibleArrow(0)
    end

    if curStep == 2036 or curStep == 2844 then
        doTweenAlpha("reverseCrashEnding", "whiteStuff", 1, (stepCrochet / 1000) * 20, "sineIn")
    end

    if curStep == 2864 then
        resetCharacters()
        setDistractibleArrow(0)
    end

    if curStep == 2896 then
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
        cameraFlash("camOther", "FFFFFF", 1.6)
    end
end

function revealCharacter(char)
    doTweenAlpha(char.."reveal", char, 1, 1, "quadOut")
    doTweenAlpha(char.."iconReveal", "iconP"..getNumFromChar(char), 1, 1, "quadOut")
end

function getNumFromChar(char)
    if char == 'gf' then
        return 3
    elseif char == 'dad' then
        return 2
    else
        return 1
    end
end

function onTweenCompleted(tag)
    if tag == 'reverseCrash' then
        setProperty("whiteStuff.alpha", 0)
        setProperty("camGame.visible", false)
        setProperty("camHUD.visible", false)
    end

    if tag == 'reverseCrashEnding' then
        setProperty("whiteStuff.alpha", 0)
    end

    if tag == 'awesomeTextBye' then
        removeLuaText("awesomeText", true)
    end

    if tag == 'switcharoo4' then
        for i = 4, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
    end
end

function setAwesomeText(txt)
    setTextString("awesomeText", txt)
    screenCenter("awesomeText", 'xy')
end

function setDistractibleArrow(time, tween)
    if time > 0 then
        noteTweenX("idk1", 4, 50, time, tween)
        noteTweenX("idk2", 5, 220, time, tween)
        noteTweenX("idk3", 6, 940, time, tween)
        noteTweenX("idk4", 7, 1110, time, tween)
        switcharoo(time, tween)
    else
        setPropertyFromGroup('playerStrums', 0, 'x', 50)
        setPropertyFromGroup('playerStrums', 1, 'x', 220)
        setPropertyFromGroup('playerStrums', 2, 'x', 940)
        setPropertyFromGroup('playerStrums', 3, 'x', 1110)
    end
end

function resetArrowPos(time, tween)
    if time > 0 then
        noteTweenX("idkReset1", 4, defaultPlayerStrumX0, time, tween)
        noteTweenX("idkReset2", 5, defaultPlayerStrumX1, time, tween)
        noteTweenX("idkReset3", 6, defaultPlayerStrumX2, time, tween)
        noteTweenX("idkReset4", 7, defaultPlayerStrumX3, time, tween)
        switcharoo(time, tween)
    else
        setPropertyFromGroup('playerStrums', 0, 'x', defaultPlayerStrumX0)
        setPropertyFromGroup('playerStrums', 1, 'x', defaultPlayerStrumX1)
        setPropertyFromGroup('playerStrums', 2, 'x', defaultPlayerStrumX2)
        setPropertyFromGroup('playerStrums', 3, 'x', defaultPlayerStrumX3)
    end
end

function switcharoo(time, tween)
    for i = 4, 7 do
        noteTweenAngle("switcharoo"..i, i, 360, time, tween)
    end
end

function focusOnMark()
    resetCharacters()
    scaleObject("boyfriendGroup", 0.7, 0.7)
    setObjectCamera("boyfriend", 'camHUD')
    setProperty("boyfriend.x", 0)
    setProperty("boyfriend.y", 0)
    characterDance("boyfriend")
end

function focusOnBob()
    resetCharacters()
    scaleObject("gfGroup", 0.885, 0.885)
    setObjectCamera("gf", 'camHUD')
    setProperty("gf.x", -208)
    setProperty("gf.y", -210)
    characterDance("gf")
end

function focusOnWade()
    resetCharacters()
    scaleObject("dadGroup", 0.75, 0.75)
    setObjectCamera("dad", 'camHUD')
    setProperty("dad.x", -48)
    setProperty("dad.y", -200)
    characterDance("dad")
end

function resetCharacters()
    setObjectCamera("boyfriend", 'camGame')
    setObjectCamera("dadGroup", 'camGame')
    setObjectCamera("gfGroup", 'camGame')

    scaleObject("boyfriend", 0.45, 0.45)
    scaleObject("gfGroup", 0.5, 0.5)
    scaleObject("dadGroup", 0.45, 0.45)

    setProperty("boyfriend.x", -1380)
    setProperty("boyfriend.y", -275)
    setProperty("dad.x", -445)
    setProperty("dad.y", -660)
    setProperty("gf.x", -18)
    setProperty("gf.y", -210)

    characterDance("boyfriend")
    characterDance("gf")
    characterDance("dad")
end