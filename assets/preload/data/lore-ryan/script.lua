function onUpdate(elapsed)
    setPropertyFromClass('flixel.FlxG', 'sound.music.volume', 0.8)
end

function onStepHit()
    if curStep >= 1776 and curStep <= 1780 then
        characterPlayAnim('gf', 'singRIGHT', true)
    end

    if curStep == 1784 then
        characterPlayAnim('gf', 'singLEFT', true)
    elseif curStep == 1786 then
        characterPlayAnim('gf', 'singRIGHT', true)
    elseif curStep == 1788 or curStep == 1790 or curStep == 1791 then
        characterPlayAnim('gf', 'singUP', true)
    end

    if curStep == 1538 then
        doTweenAlpha('camhudbye', 'camHUD', 0, 1, 'quadInOut')
    elseif curStep == 1658 then
        doTweenAlpha('camhudhi', 'camHUD', 1, 1, 'quadInOut')
    end
end
