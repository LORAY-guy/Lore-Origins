package states.stages;

class Style extends BaseStage {
    var back:FlxSprite;
    var floor:FlxSprite;
    var chairs:FlxSprite;
    var assholes1:FlxSprite;
    var assholes2:FlxSprite;
    var assholes3:FlxSprite;
    var aster:FlxSprite;
    var doge:FlxSprite;

    public static var light:FlxSprite;
    public static var blackIntro:FlxSprite;
    public static var redAlarm:FlxSprite;

    override function create() {
        back = new FlxSprite(-400, -200).loadGraphic(Paths.image('lore-style/back'));
        back.scrollFactor.set(0.8, 0.8);
        back.setGraphicSize(Std.int(back.width * 1.5));
        back.updateHitbox();
        add(back);

        chairs = new FlxSprite(-400, 400).loadGraphic(Paths.image('lore-style/chairs'));
        chairs.scrollFactor.set(0.9, 0.9);
        chairs.setGraphicSize(Std.int(chairs.width * 1.2));
        chairs.updateHitbox();
        add(chairs);

        assholes3 = new FlxSprite(-200, 0);
        assholes3.frames = Paths.getSparrowAtlas('lore-style/assholes3');
        assholes3.animation.addByPrefix('idle', 'assholes3 idle', false);
        assholes3.scrollFactor.set(0.9, 0.9);
        assholes3.updateHitbox();
        add(assholes3);

        assholes2 = new FlxSprite(-400, 100);
        assholes2.frames = Paths.getSparrowAtlas('lore-style/assholes2');
        assholes2.animation.addByPrefix('idle', 'assholes2 idle', false);
        assholes2.setGraphicSize(Std.int(assholes2.width * 1.1));
        assholes2.scrollFactor.set(0.9, 0.9);
        assholes2.updateHitbox();
        add(assholes2);

        assholes1 = new FlxSprite(-400, 300);
        assholes1.frames = Paths.getSparrowAtlas('lore-style/assholes1');
        assholes1.animation.addByPrefix('idle', 'assholes1 idle', false);
        assholes1.setGraphicSize(Std.int(assholes1.width * 1.1));
        assholes1.scrollFactor.set(0.9, 0.9);
        assholes1.updateHitbox();
        add(assholes1);

        floor = new FlxSprite(-900, 550).loadGraphic(Paths.image('lore-style/floor'));
        floor.setGraphicSize(Std.int(floor.width * 1.4));
        floor.updateHitbox();
        add(floor);

        blackIntro = new FlxSprite().makeGraphic(2000, 2000, FlxColor.BLACK);
        blackIntro.scrollFactor.set();
        blackIntro.cameras = [camHUD];
        blackIntro.screenCenter(XY);
        blackIntro.alpha = 0.6;
        blackIntro.updateHitbox();
        add(blackIntro);

        if (ClientPrefs.data.flashing)
        {
            redAlarm = new FlxSprite().makeGraphic(1280, 720, FlxColor.RED);
            redAlarm.cameras = [camHUD];
            redAlarm.screenCenter(XY);
            redAlarm.alpha = 0;
            redAlarm.updateHitbox();
            add(redAlarm);
        }

        super.create();
    }

    override function createPost() {
        light = new FlxSprite(-305, -350).loadGraphic(Paths.image('lore-style/light'));
        light.scrollFactor.set(1.3, 1.3);
        light.setGraphicSize(Std.int(light.width * 1.6), Std.int(light.width * 1.4));
        light.blend = ADD;
        light.alpha = 0.8;
        light.visible = false;
        light.updateHitbox();
        add(light);

        aster = new FlxSprite(-550, 300);
        aster.frames = Paths.getSparrowAtlas('lore-style/aster');
        aster.animation.addByPrefix('idle', 'aster idle', 24, false);
        aster.scrollFactor.set(1.3, 1.3);
        aster.setGraphicSize(Std.int(aster.width * 1.2));
        aster.updateHitbox();
        add(aster);

        doge = new FlxSprite(1000, 300);
        doge.frames = Paths.getSparrowAtlas('lore-style/doge');
        doge.animation.addByPrefix('idle', 'doge idle', 24, false);
        doge.scrollFactor.set(1.3, 1.3);
        doge.setGraphicSize(Std.int(doge.width * 1.2));
        doge.updateHitbox();
        add(doge);

        super.createPost();
    }
    override function beatHit() {
        super.beatHit();

        if (curStep % 2 == 0) {
            assholes1.animation.play('idle', true, false, 0);
            assholes2.animation.play('idle', true, false, 0);
            assholes3.animation.play('idle', true, false, 0);
            aster.animation.play('idle', true, false, 0);
            doge.animation.play('idle', true, false, 0);
        }

        if ((curBeat >= 64 && curBeat <= 160) || (curBeat >= 356 && curBeat <= 412) || (curBeat >= 512 && curBeat <= 604)) {
            camGame.zoom += 0.06;
            camHUD.zoom += 0.04;
        }

        if (curBeat >= 224 && curBeat <= 288) {
            camGame.zoom += 0.04;
            camHUD.zoom += 0.02;
        }

        if (((curBeat >= 224 && curBeat <= 288) || (curBeat >= 608 && curBeat <= 668)) && (curBeat % 4 == 0)) {
            camGame.zoom += 0.04;
            camHUD.zoom += 0.04;
        }
    }

    override function sectionHit() {
        super.sectionHit();

        if (ClientPrefs.data.flashing)
        {
            if (curSection >= 104 && curSection <= 128)
            {
                redAlarm.alpha = 0.5;
                FlxTween.tween(redAlarm, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.linear});
            }
        }
    }

    override function stepHit() {
        if (curStep == 110 || curStep == 240 || curStep == 880 || curStep == 1392 || curStep == 1648 || curStep == 2032 || curStep == 2416 || curStep == 2672) {
            camZooming = false;
        } else if (curStep == 128 || curStep == 256 || curStep == 896 || curStep == 1408 || curStep == 1664 || curStep == 2048 || curStep == 2432 || curStep == 2688) {
            camZooming = true;
        }
    
        if (curStep == 110 || curStep == 880) {
            defaultCamZoom = 1.0;
            camGame.zoom = 1;
        } else if (curStep == 128 || curStep == 896) {
            defaultCamZoom = 0.8;
            cameraSpeed = 1;
        }
    
        if (curStep == 240 || curStep == 624 || curStep == 1138 || curStep == 1392 || curStep == 1648 || curStep == 2032 || curStep == 2416 || curStep == 2672) {
            defaultCamZoom = 1.0;
        } else if (curStep == 256 || curStep == 640 || curStep == 1152 || curStep == 1408 || curStep == 1664 || curStep == 2048 || curStep == 2432 || curStep == 2688) {
            defaultCamZoom = 0.8;
            cameraSpeed = 1;
        }
    
        if (curStep == 128 || curStep == 640 || curStep == 896 || curStep == 1152 || curStep == 1280 || curStep == 1664 || curStep == 2432 || curStep == 2688 || curStep == 2944) {
            camGame.flash(FlxColor.WHITE, 0.9);
        }
    
        if (curStep == 1280 || curStep == 1920) {
            FlxTween.tween(camGame, {zoom: 1.05}, Std.int((Conductor.stepCrochet / 1000) * 112), {ease: FlxEase.cubeInOut});
        }
    
        if (curStep == 2964) {
            camGame.visible = false;
            camHUD.visible = false;
        }

        if (curStep == 125 || curStep == 520) {
            cameraSpeed = 100;
            lockCam(false);
        } else if (curStep == 127 || curStep == 527) {
            lockCam();
        }

        if (curStep == 584 || curStep == 2376) {
            cameraSpeed = 100;
            lockCam(true);
        } else if (curStep == 591 || curStep == 2383) {
            lockCam();
        }

        super.stepHit();
    }
}