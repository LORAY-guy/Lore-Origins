package states.stages;

import objects.HealthIcon;
import objects.Character;
import objects.StrumNote;

/**
 * Don't worry about the VERY specific values for the Tweens and such
 * Lua's interpretation of (stepCrochet / 1000) is very different from Haxe's cuz float's precision in Lua is more advanced, thus giving a much better result and feels more in the rythm of the song.
 * So i'm using Lua's value since they are more fitting with what I want to make
 */
class Distractible extends BaseStage
{
    private var bg:BGSprite;
    private var whiteStuff:FlxSprite;
    private var awesomeText:FlxText;

    override public function create():Void
    {
        super.create();

        bg = new BGSprite("distractible", -965, -540);

        whiteStuff = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
        whiteStuff.cameras = [camOther];
        whiteStuff.screenCenter(XY);
        whiteStuff.alpha = 0;
        whiteStuff.visible = ClientPrefs.data.flashing;
        add(whiteStuff);

        awesomeText = new FlxText(0, 0, 800, "", 116);
        awesomeText.cameras = [camOther];
        awesomeText.setFormat(Paths.font("mark.ttf"), 116, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        awesomeText.borderSize = 3;
        awesomeText.screenCenter(XY);
        awesomeText.antialiasing = ClientPrefs.data.antialiasing;
        awesomeText.visible = false;
        awesomeText.scrollFactor.set();
        add(awesomeText);
    }

    override public function createPost():Void
    {
        super.createPost();

        add(bg);

        PlayState.instance.triggerEvent("Camera Follow Pos", "0", "0", Conductor.songPosition);
        boyfriendGroup.scale.set(0.45, 0.45);
        boyfriendGroup.updateHitbox();
        gfGroup.scale.set(0.5, 0.5);
        gfGroup.updateHitbox();
        dadGroup.scale.set(0.45, 0.45);
        dadGroup.updateHitbox();

        PlayState.instance.opponentStrums.visible = false;

        setDistractibleArrow(0);

        boyfriend.alpha = 0.0001;
        gf.alpha = 0.0001;
        dad.alpha = 0.0001;

        iconP1.alpha = 0;
        iconP2.alpha = 0;

        camZooming = true;
        camGame.alpha = 0.0000001;

        resetCharacters();

        isCameraOnForcedPos = true;
        camFollow.x = 0;
        camFollow.y = 0;
    }

    override public function songStart():Void
    {
        super.songStart();

        camGame.alpha = 1;
        camGame.flash(FlxColor.WHITE, 1.2, null, true);
    }

    override public function stepHit():Void
    {
        super.stepHit();

        if (curStep == 67)
            revealCharacter(boyfriend);
        else if (curStep == 74)
            revealCharacter(gf);
        else if (curStep == 82)
            revealCharacter(dad);

        if (curStep == 128)
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.04", "0.02", Conductor.songPosition);

        if (curStep == 220)
            FlxTween.tween(whiteStuff, {alpha: 1}, 1.4285714285714, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                whiteStuff.alpha = 0;
                camGame.visible = false;
                camHUD.visible = false;
            }});
        
        if (curStep == 237) {
            awesomeText.visible = true;
            setAwesomeText("And ");
        }

        if (curStep == 240)
            setAwesomeText("And en ");

        if (curStep == 244)
            setAwesomeText("And enjoy ");

        if (curStep == 251)
            setAwesomeText("And enjoy  the ");

        if (curStep == 256) {
            camGame.visible = true;
            camHUD.visible = true;
            setAwesomeText("And enjoy  the show! ");
            FlxTween.tween(awesomeText, {alpha: 0}, 0.57142857142857, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                awesomeText.visible = false;
            }});
        }

        if (curStep == 528 || curStep == 592 || curStep == 656 || curStep == 720 || curStep == 2384 || curStep == 2448 || curStep == 2512 || curStep == 2576)
            coolEffectIdfk();

        if (curStep == 544 || curStep == 608 || curStep == 672 || curStep == 736 || curStep == 2400 || curStep == 2464 || curStep == 2528 || curStep == 2792)
            camGame.flash(FlxColor.WHITE, 1.2);

        if (curStep == 760 || curStep == 1264 || curStep == 1520 || curStep == 1904 || curStep == 2608)
            resetArrowPos(1.1428571428571);
        
        if (curStep == 256 || curStep == 768 || curStep == 1024 || curStep == 1280 || curStep == 896 || curStep == 1152 || curStep == 1408 || curStep == 1536 || curStep == 1792 || curStep == 1920 || curStep == 2112 || curStep == 2624 || curStep == 2752)
            camHUD.flash(FlxColor.WHITE, 1.2, null, true);

        if (curStep == 768 || curStep == 1024 || curStep == 1280 || curStep == 1536 || curStep == 1584 || curStep == 1632 || curStep == 1696 || curStep == 1744 || curStep == 1768 || curStep == 1920 || curStep == 2082 || curStep == 2624 || curStep == 2816)
            focusOnMark();

        if (curStep == 836 || curStep == 1088 || curStep == 1344 || curStep == 1552 || curStep == 1600 || curStep == 1664 || curStep == 1712 || curStep == 1752 || curStep == 1980 || curStep == 2068 || curStep == 2692 || curStep == 2846)
            focusOnBob();

        if (curStep == 896 || curStep == 1152 || curStep == 1568 || curStep == 1616 || curStep == 1680 || curStep == 1736 || curStep == 1760 || curStep == 2056 || curStep == 2752 || curStep == 2864)
            focusOnWade();

        if (curStep == 1220 || curStep == 1408 || curStep == 1776)
            resetCharacters();

        if (curStep == 1200 || curStep == 1392 || curStep == 1760)
            setDistractibleArrow(1.1428571428571);

        if (curStep == 1264)
            FlxTween.tween(camGame, {zoom: 5}, 2.2857142857143, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
                defaultCamZoom = 0.67;
                camGame.zoom = 0.67;
            }});

        if (curStep == 2056) {
            camGame.visible = true;
            camHUD.visible = true;
            whiteStuff.alpha = 0;
        }
        
        if (curStep == 2104) {
            camGame.visible = false;
            camHUD.visible = false;
        }

        if (curStep == 2104 || curStep == 2106 || curStep == 2108 || curStep == 2110) {
            FlxTween.cancelTweensOf(whiteStuff);
            whiteStuff.alpha = 1;
            FlxTween.tween(whiteStuff, {alpha: 0}, 0.42857142857143, {ease: FlxEase.sineOut});
        }

        if (curStep == 2112) {
            FlxTween.cancelTweensOf(whiteStuff);
            whiteStuff.alpha = 0;
            camGame.visible = true;
            camHUD.visible = true;
            resetCharacters();
            setDistractibleArrow(0);
        }

        if (curStep == 2036 || curStep == 2844)
            FlxTween.tween(whiteStuff, {alpha: 1}, 1.4285714285714, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                whiteStuff.alpha = 0;
            }});

        if (curStep == 2864) {
            resetCharacters();
            setDistractibleArrow(0);
        }

        if (curStep == 2896) {
            camGame.visible = false;
            camHUD.visible = false;
            camOther.flash(FlxColor.WHITE, 1.6, null, true);
        }
    }

    private function revealCharacter(char:Character):Void
    {
        FlxTween.tween(char, {alpha: 1}, 1, {ease: FlxEase.quadOut});
        FlxTween.tween(getIconFromChar(char.curCharacter), {alpha: 1}, 1, {ease: FlxEase.quadOut});
    }

    private function getIconFromChar(char:String):HealthIcon
    {
        switch (char.toLowerCase()) {
            case "lordminion": return iconP2;
            case "muyskerm": return iconP3;
            default: return iconP1;
        }
    }

    private function setAwesomeText(text:String):Void
    {
        awesomeText.text = text;
        awesomeText.screenCenter(XY);
    }

    private function setDistractibleArrow(time:Float):Void
    {
        if (time > 0) {
            PlayState.instance.playerStrums.forEachAlive(function(note:StrumNote) {
                FlxTween.tween(note, {x: getPosFromNoteID(note.ID)}, time, {ease: FlxEase.sineInOut});
            });
            switcharoo(time);
        } else {
            PlayState.instance.playerStrums.forEachAlive(function(note:StrumNote) {
                note.x = getPosFromNoteID(note.ID);
            });
        }
    }

    private function resetArrowPos(time:Float):Void
    {
        if (time > 0) {
            PlayState.instance.playerStrums.forEachAlive(function(note:StrumNote) {
                FlxTween.tween(note, {x: getPosFromNoteID(note.ID, true)}, time, {ease: FlxEase.sineInOut});
            });
            switcharoo(time);
        } else {
            PlayState.instance.playerStrums.forEachAlive(function(note:StrumNote) {
                note.x = getPosFromNoteID(note.ID, true);
            });
        }
    }

    private function switcharoo(time:Float):Void
    {
        PlayState.instance.playerStrums.forEachAlive(function(note:StrumNote) {
            FlxTween.tween(note, {angle: 360}, time, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
                note.angle = 0;
            }});
        });
    }

    private function focusOnMark():Void
    {
        resetCharacters();
        boyfriendGroup.scale.set(0.7, 0.7);
        boyfriendGroup.updateHitbox();
        boyfriend.cameras = [camHUD];
        boyfriend.x = boyfriend.y = 0;
        boyfriend.dance();
    }

    private function focusOnBob():Void
    {
        resetCharacters();
        gfGroup.scale.set(0.885, 0.885);
        gfGroup.updateHitbox();
        gf.cameras = [camHUD];
        gf.x = -208;
        gf.y = -210;
        gf.dance();
    }

    private function focusOnWade():Void
    {
        resetCharacters();
        dadGroup.scale.set(0.75, 0.75);
        dadGroup.updateHitbox();
        dad.cameras = [camHUD];
        dad.x = -48;
        dad.y = -200;
        dad.dance();
    }

    private function resetCharacters():Void
    {
        boyfriend.cameras = [camGame];
        dadGroup.cameras = [camGame];
        gfGroup.cameras = [camGame];

        boyfriend.scale.set(0.45, 0.45);
        boyfriend.updateHitbox();
        gfGroup.scale.set(0.5, 0.5);
        gfGroup.updateHitbox();
        dadGroup.scale.set(0.45, 0.45);
        dadGroup.updateHitbox();

        boyfriend.x = -1380;
        boyfriend.y = -275;
        dad.x = -445;
        dad.y = -660;
        gf.x = -18;
        gf.y = -210;

        boyfriend.dance();
        gf.dance();
        dad.dance();
    }

    private function coolEffectIdfk():Void
    {
        PlayState.instance.triggerEvent("Add Camera Zoom", "0.06", "0.06", Conductor.songPosition);
        new FlxTimer().start(0.42857142857143, function(tmr:FlxTimer) {
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.06", "0.06", Conductor.songPosition);
        });
        if (ClientPrefs.data.flashing)
            camGame.flash(FlxColor.WHITE, 0.7);
    }

    private function getPosFromNoteID(id:Int, ?defState:Bool = false):Float // I mean, it works...
    {
        switch (id) {
            case 0: return (defState) ? defaultPlayerStrumX[0] : 50;
            case 1: return (defState) ? defaultPlayerStrumX[1] : 220;
            case 2: return (defState) ? defaultPlayerStrumX[2] : 940;
            case 3: return (defState) ? defaultPlayerStrumX[3] : 1110;
        }
        return 0;
    }
}
