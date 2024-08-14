package states.stages;

import flixel.math.FlxRect;

class AR extends BaseStage
{
    var bg:BGSprite;
    var bgBlur:BGSprite;
    var phone:FlxSprite;

    var warning:FlxSprite;
    var warningTime:Float = 0.0;
    var warningSine:Float = 0.0;
    var warningDensity:Int = 0;
    var warningSound:FlxSound;

    override function create():Void
    {
        phone = new FlxSprite();
        phone.frames = Paths.getSparrowAtlas('ar/phone');
        phone.animation.addByPrefix('Idle', 'Idle', 1);
        phone.animation.addByPrefix('Call', 'Call', 30, false);
        phone.animation.addByPrefix('InCall', 'InCall', 1);
        phone.animation.play('Idle');
        phone.scale.set(0.5, 0.5);
        phone.updateHitbox();
        phone.screenCenter();
        phone.cameras = [camHUD];
        add(phone);

        phoneCam.width = Std.int(435 * 0.5);
        phoneCam.height = Std.int(869 * 0.5);

        bg = new BGSprite('couchUnblurred', 0, 0, 1, 1);
        bg.scale.set(1.25, 1.25);
        bg.updateHitbox();
        bg.cameras = [phoneCam];
        bg.screenCenter();
        add(bg);

        warningSound = new FlxSound();
        warningSound.loadEmbedded(Paths.sound('alarm'));
        FlxG.sound.defaultSoundGroup.add(warningSound);

        super.create();
    }

    override function createPost():Void
    {
        super.createPost();

        bgBlur = new BGSprite('couch', 0, 0, 0, 0);
        bgBlur.scale.set(1.25, 1.25);
        bgBlur.updateHitbox();
        bgBlur.screenCenter();
        add(bgBlur);

        dad.visible = false;

        boyfriend.cameras = [phoneCam];
        boyfriend.scrollFactor.set(1, 1);
        boyfriend.scale.set(2, 2);
        boyfriend.updateHitbox();
        boyfriend.screenCenter();
        boyfriend.x += 172;
        boyfriend.defaultX = boyfriend.x;
        boyfriend.y += 197;
        boyfriend.defaultY = boyfriend.y;
        boyfriend.alpha = 0;

        warning = new FlxSprite().loadGraphic(Paths.image('ar/warning'));
        warning.scale.set(1.75, 1.75);
        warning.updateHitbox();
        warning.scrollFactor.set();
        warning.cameras = [camHUD];
        warning.screenCenter();
        warning.antialiasing = false;
        warning.visible = false;
        add(warning);
    }

    private function moveOurple():Void
    {
        FlxTween.tween(boyfriend, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
            var xPos:Float = FlxG.random.float(0, 1050);
            var yPos:Float = FlxG.random.float(0, 420);
            boyfriend.defaultX = xPos;
            boyfriend.defaultY = yPos;
            boyfriend.setPosition(xPos, yPos);
            FlxTween.tween(boyfriend, {alpha: 1}, 2, {ease: FlxEase.quadInOut});
        }});
    }

    override function update(elapsed:Float):Void
    {
        var mouseScreenPos:FlxPoint = FlxG.mouse.getScreenPosition(camHUD);
        phone.setPosition(mouseScreenPos.x - phone.width / 2, mouseScreenPos.y - phone.height / 2);
        phoneCam.setPosition(phone.x + 8, phone.y + 36);
        warning.setPosition(mouseScreenPos.x - warning.width / 2, mouseScreenPos.y - warning.height / 2);
        phoneCam.focusOn(mouseScreenPos);

        super.update(elapsed);

        updateWarning(elapsed, mouseScreenPos);
    }

    private function updateWarning(elapsed:Float, mouseScreenPos:FlxPoint):Void {
        if (!checkForOurple()) {
            warningTime += elapsed;
        } else if (warningTime > 0) {
            warningTime = 0;
            warningDensity = 0;
            warning.visible = false;
            warningSound.stop();
        }

        if (warningTime >= 3 && warningTime < 7.5 && warningDensity != 1) {
            warningDensity = 1;
            warning.loadGraphic(Paths.image('ar/warning'));
            warning.updateHitbox();
            warning.visible = true;
        } else if (warningTime >= 7.5 && warningDensity != 2) {
            warningDensity = 2;
            warning.loadGraphic(Paths.image('ar/warningRed'));
            warning.updateHitbox();
        }

        if (warning.visible) {
            warningSine += 240 * elapsed;
			warning.alpha = 1 - Math.sin((Math.PI * warningSine * warningDensity) / 240);
        } else if (warning.alpha > 0) {
            warning.alpha = 0;
        }
    }

    private function checkForOurple():Bool
    {
        var spriteRect:FlxRect = new FlxRect(boyfriend.x - boyfriend.offset.x - 75, boyfriend.y - boyfriend.offset.y, boyfriend.width / 2.25, boyfriend.height / 2);
        var cameraRect:FlxRect = new FlxRect(phoneCam.scroll.x, phoneCam.scroll.y, phoneCam.width / 3.5, phoneCam.height);
        var boolThing:Bool = spriteRect.overlaps(cameraRect);
        spriteRect.destroy();
        spriteRect = null;
        cameraRect.destroy();
        cameraRect = null;
        return boolThing;
    }

    override function stepHit():Void
    {
        super.stepHit();

        if (curStep == 64) {
            FlxTween.tween(boyfriend, {alpha: 1}, 2, {ease: FlxEase.quadInOut});
        }

        if (curStep == 384 ||
            curStep == 816 ||
            curStep == 1024 ||
            curStep == 1280 ||
            curStep == 2048 ||
            curStep == 2176 ||
            curStep == 2304 ||
            curStep == 2432 ||
            curStep == 2816) {
            moveOurple();
        }

        if (curStep == 2176) {
            phone.animation.play('Call');
        }

        if (curStep == 2416) {
            phone.animation.play('InCall');
        }

        if (curStep == 3072) {
            FlxTween.tween(boyfriend, {alpha: 0}, 2, {ease: FlxEase.sineInOut});
        }

        if (curStep == 3104) {
            phone.animation.play('Idle');
        }

        if (warningDensity > 0 && curStep % (16 / warningDensity) == 0) {
            PlayState.instance.health -= 0.075 * warningDensity;
        }
    }

    override function beatHit():Void
    {
        super.beatHit();
        if (curBeat % (4 / warningDensity) == 0 && warning.visible) warningSound.play();
    }
}