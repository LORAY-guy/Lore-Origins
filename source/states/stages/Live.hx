package states.stages;

class Live extends BaseStage {
    var stageback:FlxSprite;
    var boxes:FlxSprite;
    var boxes2:FlxSprite;
    public static var drone:FlxSprite;
    var dronecall:FlxSprite;

    public static var explosion:FlxSprite;

    public static var boom:Bool = false;

    override function create()
    {
        stageback = new FlxSprite(-550, -300).loadGraphic(Paths.image('live/live_bg_1'));
        stageback.scrollFactor.set(0.9, 0.9);
        stageback.setGraphicSize(Std.int(stageback.width * 2));
        stageback.updateHitbox();
        add(stageback);

        dronecall = new FlxSprite(20, 100);
        dronecall.frames = Paths.getSparrowAtlas('characters/drone_intro');
        dronecall.animation.addByPrefix('idle', 'calling drone', 24, true);
        dronecall.animation.play('idle', true);
        dronecall.visible = false;
        add(dronecall);

        drone = new FlxSprite(-900, 130).loadGraphic(Paths.image('drone'));
        drone.angle = 50;
        add(drone);

        explosion = new FlxSprite(450, 475);
        explosion.frames = Paths.getSparrowAtlas('explosion');
        explosion.animation.addByPrefix('boom', 'explosion idle', 24, false);
        explosion.setGraphicSize(Std.int(explosion.width * 2.5));
        explosion.updateHitbox();
        explosion.visible = false;
        add(explosion);

        resetVars();
        super.create();
    }

    override function createPost()
    {
        if (!ClientPrefs.data.lowQuality)
        {
            boxes = new FlxSprite(-250, 0).loadGraphic(Paths.image('live/live_bg_2'));
            boxes.scrollFactor.set(1.7, 1.7);
            boxes.setGraphicSize(Std.int(boxes.width * 1.7));
            boxes.updateHitbox();
            add(boxes);

            boxes2 = new FlxSprite(-1280, 0).loadGraphic(Paths.image('live/live_bg_2'));
            boxes2.scrollFactor.set(1.7, 1.7);
            boxes2.setGraphicSize(Std.int(boxes2.width * 1.7));
            boxes2.updateHitbox();
            boxes2.flipX = true;
            add(boxes2);
        }
        
        PlayState.instance.gf.visible = false;
        camGame.visible = false;
        
        super.createPost();
    }

    override function stepHit()
    {
        super.stepHit();

        switch (curStep) {
            case 132, 1924, 3460:
                lockCam(false);

            case 246, 2038, 3560:
                lockCam(true);

            case 256, 2048:
                lockCam();
                camHUD.flash(FlxColor.WHITE, 0.9);
                defaultCamZoom = 0.75;
                camGame.zoom = 0.75;
                cameraSpeed = 2;

            case 368, 2160:
                defaultCamZoom = 0.9;

            case 384, 2176:
                defaultCamZoom = 0.75;
                camGame.zoom = 0.75;

            case 768:
                defaultCamZoom = 0.9;
                cameraSpeed = 100;

            case 1024:
                cameraSpeed = 2;
                defaultCamZoom = 0.8;
            
            case 1152, 1154, 1216, 1218:
                camGame.zoom += 0.06;
                camHUD.zoom += 0.04;
            
            case 1272:
                defaultCamZoom = 1;
                camGame.zoom = 1;

            case 1280:
                camGame.flash(FlxColor.WHITE, 0.9);
                defaultCamZoom = 0.8;

            case 1792, 3328:
                camGame.flash(FlxColor.WHITE, 0.9);
                cameraSpeed = 100;
                defaultCamZoom = 1;
                camGame.zoom = 1;
                lockCam(true);

            case 2560:
                cameraSpeed = 2;
                FlxTween.tween(camGame, {zoom: 1}, (Conductor.crochet / 1000) * 32, {ease: FlxEase.sineIn});

            case 2688:
                camGame.flash(FlxColor.WHITE, 0.9);

            case 2790:
                gf.visible = true;
                gf.playAnim('welcome', true);

            case 2792:
                FlxTween.tween(drone, {y: 720}, 0.2, {ease: FlxEase.bounceOut, onComplete: function(twn:FlxTween) {
                    droneCrash();
                }});
                FlxTween.tween(drone, {angle: 180}, 0.2, {ease: FlxEase.cubeIn});

            case 2800, 2928, 3072:
                cameraSpeed = 100;
                defaultCamZoom = 1;
                camGame.zoom = 1;

            case 2816, 2944, 3088:
                camHUD.flash(FlxColor.WHITE, 0.9);
                cameraSpeed = 2;
                defaultCamZoom = 0.75;

            case 3200:
                cameraSpeed = 100;

            case 3264, 3280, 3296:
                defaultCamZoom += 0.1;
                camGame.zoom += 0.01;
                if (curStep == 3296) lockCam(true);

            case 3312:
                lockCam(true);

            case 3304, 3320:
                lockCam(false);

            case 3519:
                lockCam();

            case 3584:
                defaultCamZoom = 0.75;
                camGame.zoom = 0.75;

            case 3600:
                defaultCamZoom = 1;
                camGame.zoom = 1;

            case 3612:
                camGame.visible = false;
                camHUD.visible = false;
        }

        if (curSection == 86 || curSection == 94 || curSection == 100 || curSection == 108 || curSection == 175 || curSection == 183) {
            camGame.zoom += 0.01;
            camHUD.zoom += 0.01;
        }

        if (curStep == 2576) droneIntro();
    }

    override function beatHit() {
        super.beatHit();

        if (((curBeat >= 1 && curBeat < 64) || (curBeat >= 320 && curBeat < 448) || (curBeat >= 448 && curBeat < 512) || (curBeat >= 832 && curBeat < 896)) && (curBeat % 2 == 0)) {
            camGame.zoom += 0.02;
            camHUD.zoom += 0.02;
        }

        if ((curBeat >= 64 && curBeat < 192) || (curBeat >= 512 && curBeat < 640)) {
            camGame.zoom += 0.04;
            camHUD.zoom += 0.04;
        }

        if ((curBeat >= 192 && curBeat < 320) || (curBeat >= 704 && curBeat < 732) || (curBeat >= 736 && curBeat < 768)) {
            camGame.zoom += 0.04;
            camHUD.zoom += 0.02;
        }

        if ((curBeat >= 640 && curBeat < 672) && (curBeat % 2 == 0)) {
            camGame.zoom += 0.02;
            camHUD.zoom += 0.04;
        }
    }

    function droneIntro()
    {
        dronecall.visible = true;
        new FlxTimer().start(Std.int((Conductor.crochet / 1000) * 44), function(tmr:FlxTimer) {
            FlxTween.tween(drone, {x: 460, angle: 0}, 2.5, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
                dronecall.destroy();
            }});
        });
    }

    public static function droneCrash()
    {
        explosion.visible = true;
        explosion.animation.play('boom', false);
        FlxG.sound.play(Paths.sound('explosion'), 0.7, false);
        boom = true;
        drone.destroy();
        new FlxTimer().start(0.4, function(tmr:FlxTimer) {
            explosion.destroy();
        });
    }

    function resetVars()
    {
        boom = false;
    }
}