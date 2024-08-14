package states.stages.addons;

class Awesomix extends BaseStage
{
    var flick:Bool = false;
    var camList:Array<FlxCamera>;

    var monitor:FlxSprite;
    var backstageblur:FlxSprite;
    public static var prange:FlxSprite;
    var ourple:FlxSprite;
    var equal:FlxText;
    var william:FlxSprite;
    var motorist:FlxSprite;
    var finger:FlxSprite;
    var mapa:FlxSprite;
    var whiteStuff:FlxSprite;
    var vcrshit:FlxSprite;
    var redboob:FlxSprite;

    override function create() {
        monitor = new FlxSprite();
        monitor.frames = Paths.getSparrowAtlas('monitor');
        monitor.animation.addByPrefix('open', 'Open', 24, false, false, false);
        monitor.animation.addByIndices('nothing', 'Close', [0], '.png', 24, false, false, false);
        monitor.animation.play('nothing', false, false, 0);
        monitor.cameras = [camHUD];
        monitor.screenCenter(XY);
        monitor.updateHitbox();
        monitor.visible = false;
        add(monitor);

        backstageblur = new FlxSprite().loadGraphic(Paths.image('bckrom-blur'));
        backstageblur.updateHitbox();
        backstageblur.cameras = [camOther];
        backstageblur.screenCenter(XY);
        add(backstageblur);

        prange = new FlxSprite(1280, 90);
        prange.frames = Paths.getSparrowAtlas('characters/prange');
        prange.animation.addByPrefix('idle', 'idle', 30, false, false, false);
        prange.animation.play('idle', false, false, 0);
        prange.scale.set(3, 3);
        prange.updateHitbox();
        prange.antialiasing = false;
        prange.flipX = true;
        prange.angle = 360;
        prange.cameras = [camOther];
        add(prange);

        ourple = new FlxSprite((FlxG.width / 2) - 150, 120);
        ourple.frames = Paths.getSparrowAtlas('characters/playguy');
        ourple.animation.addByPrefix('lol', 'idle', 24, false, false, false);
        ourple.animation.play('lol', false, false, 0);
        ourple.scale.set(3, 3);
        ourple.updateHitbox();
        ourple.antialiasing = false;
        ourple.visible = false;
        ourple.cameras = [camOther];
        add(ourple);

        equal = new FlxText(1280, 0, 80, '=', 96);
        equal.cameras = [camOther];
        equal.screenCenter(Y);
        add(equal);

        william = new FlxSprite(1280).loadGraphic(Paths.image('william'));
        william.scale.set(2.6, 2.6);
        william.updateHitbox();
        william.antialiasing = false;
        william.cameras = [camOther];
        william.screenCenter(Y);
        add(william);

        motorist = new FlxSprite(0, -1500).loadGraphic(Paths.image('motoristproof'));
        motorist.scale.set(0.7, 0.7);
        motorist.updateHitbox();
        motorist.antialiasing = false;
        motorist.cameras = [camOther];
        motorist.screenCenter(X);
        add(motorist);

        finger = new FlxSprite(-1000, -250).loadGraphic(Paths.image('finger'));
        finger.scale.set(1.3, 1.3);
        finger.updateHitbox();
        finger.cameras = [camOther];
        finger.angle = 50;
        add(finger);

        mapa = new FlxSprite(-375, 210);
        mapa.frames = Paths.getSparrowAtlas('characters/matpat2');
        mapa.animation.addByPrefix('lol', 'mat idle dance', 24, false, false, false);
        mapa.animation.play('lol', false, false, 0);
        mapa.scale.set(1.2, 1.2);
        mapa.updateHitbox();
        mapa.cameras = [camOther];
        add(mapa);

        whiteStuff = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE, false);
        whiteStuff.antialiasing = false;
        whiteStuff.alpha = 0;
        whiteStuff.cameras = [camOther];
        add(whiteStuff);

        vcrshit = new FlxSprite().loadGraphic(Paths.image('vcrshit'));
        vcrshit.cameras = [camHUD];
        vcrshit.visible = false;
        add(vcrshit);

        redboob = new FlxSprite(167, 59).loadGraphic(Paths.image('red'));
        redboob.cameras = [camHUD];
        redboob.scale.set(0.8, 0.8);
        redboob.updateHitbox();
        redboob.visible = false;
        add(redboob);

        resetVars();
        super.create();
    }

    override function createPost() {
        for (cams in 0...camList.length) {
            camList[cams].visible = false;
        }
        super.createPost();
    }

    override function stepHit() {
        switch (curStep) 
        {
            case 26:
                camOther.zoom = 1.05;
                camOther.flash(FlxColor.WHITE, 0.75);
                prange.destroy();
                ourple.visible = true;
                FlxTween.tween(camOther, {zoom: 1}, 0.75, {ease: FlxEase.cubeOut});

            case 39:
                FlxTween.tween(mapa, {x: 50}, 0.5, {ease: FlxEase.cubeOut});

            case 46:
                FlxTween.tween(ourple, {x: ourple.x - 180}, 0.5, {ease: FlxEase.cubeOut});
                FlxTween.tween(equal, {x: (FlxG.width / 2) - 15}, 0.4, {ease: FlxEase.cubeOut});
                FlxTween.tween(william, {x: ourple.x + 220}, 0.5, {ease: FlxEase.cubeOut});
            
            case 58:
                var ourples:Array<Dynamic> = [ourple, william, equal];
                for (guy in 0...ourples.length)
                    FlxTween.tween(ourples[guy], {y: 750}, 0.6, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween) {
                        ourples[guy].destroy();
                    }});

            case 61:
                FlxTween.tween(motorist, {y: 0}, 0.7, {ease: FlxEase.sineOut});

            case 71:
                FlxTween.tween(whiteStuff, {alpha: 1}, Std.int((Conductor.stepCrochet / 1000) * 29), {ease: FlxEase.expoIn});

            case 73:
                FlxTween.tween(motorist, {x: motorist.x - 310}, 0.5, {ease: FlxEase.sineOut});
                FlxTween.tween(motorist, {y: motorist.x - 80}, 0.5, {ease: FlxEase.sineOut});
                FlxTween.tween(motorist.scale, {x: 1}, 0.5, {ease: FlxEase.sineOut});
                FlxTween.tween(motorist.scale, {y: 1}, 0.5, {ease: FlxEase.sineOut});

            case 77:
                FlxTween.tween(finger, {x: 530}, 0.25, {ease: FlxEase.sineOut});
                FlxTween.tween(finger, {y: 235}, 0.25, {ease: FlxEase.sineOut});

            case 87:
                var ourples:Array<Dynamic> = [finger, motorist];
                for (guy in 0...ourples.length)
                    FlxTween.tween(ourples[guy], {y: 1000}, 0.6, {ease: FlxEase.cubeIn});
                FlxTween.tween(mapa, {x: (FlxG.width / 2) - 200}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(mapa, {y: mapa.y - 30}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(mapa.scale, {x: 1.4}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(mapa.scale, {y: 1.4}, 0.5, {ease: FlxEase.sineInOut});

            case 100, 1924, 2180:
                camGame.flash();
                if (curStep == 100) {
                    whiteStuff.destroy();
                    for (i in 0...camList.length)
                        camList[i].visible = true;
                    var ourples:Array<Dynamic> = [mapa, backstageblur]; 
                    for (guy in 0...ourples.length)
                        ourples[guy].destroy();
                    PlayState.instance.inLoreCutscene = false;
                }
            
            case 2046:
                monitor.visible = true;
                monitor.animation.play('open', false);
                new FlxTimer().start(0.4, function(tmr:FlxTimer) {
                    defaultCamZoom = 1.2;
                    camGame.zoom = 1.2;
                    dad.x += 75;
                    monitor.destroy();
                    vcrshit.visible = true;
                });

            case 2948:
                camGame.visible = false;
                camHUD.visible = false;
                camOther.flash();
        }

        if (vcrshit.visible && curStep % 4 == 0)
        {
            redboob.visible = flick;
            flick = !flick;
        }

        super.stepHit();
    }

    function resetVars()
    {
        flick = false;
        camList = [camGame, camHUD];
    }
}