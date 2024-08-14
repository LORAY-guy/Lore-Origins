package states.stages;

class Apology extends BaseStage
{
    var stageback:FlxSprite;
    var stagefront:FlxSprite;

    var stagecurtains:FlxSprite;
    var stagelight_left:FlxSprite;
    var stagelight_right:FlxSprite;

    var ourple_bg:FlxSprite;
    var matpat:FlxSprite;
    public static var blackness:FlxSprite;

    var otherStuff:Array<FlxSprite> = [];
    var mult:Float = 1.02;
    var flipped:Bool = false;
    var funni:Bool = true;

    override function create()
    {   
        stageback = new FlxSprite(-600, -300).loadGraphic(Paths.image('apology/stageback'));
        stageback.scrollFactor.set(1, 1);
        add(stageback);

        stagefront = new FlxSprite(-650, 600).loadGraphic(Paths.image('apology/stagefront'));
        stagefront.scrollFactor.set(1, 1);
        stagefront.scale.set(1.1, 1.1);
        stagefront.updateHitbox();
        add(stagefront);

        if (!ClientPrefs.data.lowQuality)
        {
            stagelight_left = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage_light'));
            stagelight_left.scrollFactor.set(1.1, 1.1);
            stagelight_left.scale.set(1.1, 1.1);
            stagelight_left.updateHitbox();
            add(stagelight_left);

            stagelight_right = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage_light'));
            stagelight_right.scrollFactor.set(1.1, 1.1);
            stagelight_right.scale.set(1.1, 1.1);
            stagelight_right.updateHitbox();
            stagelight_right.flipX = true;
            add(stagelight_right);

            stagecurtains = new FlxSprite(-525, -300).loadGraphic(Paths.image('apology/stagecurtains'));
            stagecurtains.scrollFactor.set(1.3, 1.3);
            stagecurtains.scale.set(0.9, 0.9);
            stagecurtains.updateHitbox();
            add(stagecurtains);
        }

        resetVars();
        super.create();
    }

    override function createPost() 
    {
        ourple_bg = new FlxSprite().loadGraphic(Paths.image('couch'));
        ourple_bg.cameras = [camOther];
        ourple_bg.screenCenter(XY);
        otherStuff.push(ourple_bg);
        add(ourple_bg);

        matpat = new FlxSprite().loadGraphic(Paths.image('daepicmatpat'));
        matpat.cameras = [camOther];
        matpat.scale.set(1.3, 1.3);
        matpat.updateHitbox();
        otherStuff.push(matpat);
        add(matpat);

        blackness = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        blackness.cameras = [camOther];
        add(blackness);

        super.createPost();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (curStep < 64 && matpat != null && ourple_bg != null) // Would crash when leaving the level for some reason
        {
            if (funni)
            {
                matpat.scale.x = FlxMath.lerp(1.3, matpat.scale.x, Math.exp(-elapsed * 10.5));
                matpat.scale.y = FlxMath.lerp(1.3, matpat.scale.y, Math.exp(-elapsed * 10.5));
                ourple_bg.scale.x = FlxMath.lerp(1, ourple_bg.scale.x, Math.exp(-elapsed * 10.5));
                ourple_bg.scale.y = FlxMath.lerp(1, ourple_bg.scale.y, Math.exp(-elapsed * 10.5));
            }

            if (dad.animation.curAnim.name != 'idle' && dad.animation.curAnim.curFrame == 0)
            {
                matpat.scale.set((matpat.scale.x * mult), (matpat.scale.y * mult));
                ourple_bg.scale.set((ourple_bg.scale.x * mult - 0.01), (ourple_bg.scale.y * mult - 0.01));
                matpat.x = 460;
                matpat.y = 150;
    
                if (curStep >= 24 && curStep <= 42)
                {
                    funni = false;
                    mult = 1.015;
                    if (!flipped)
                    {
                        flipped = true;
                        matpat.flipX = true;
                    }
                } else {
                    funni = true;
                    mult = 1.02;
                    if (flipped)
                    {
                        flipped = false;
                        matpat.flipX = false;
                    }
                }
            }

            matpat.screenCenter(X);
            ourple_bg.screenCenter(X);
            matpat.updateHitbox();
            ourple_bg.updateHitbox();
        }
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
        if (eventName == 'Play Animation' && value1 == 'ringstart' && curStep < 1728) {
            defaultCamZoom += 0.075;
            camGame.zoom = defaultCamZoom;
        }
        
        super.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime);
    }

    override function stepHit() {
        switch (curStep)
        {
            case 64:
                PlayState.instance.inLoreCutscene = false;
                camGame.flash(FlxColor.WHITE, 0.9);
                for (i in 0...otherStuff.length)
                    otherStuff[i].visible = false; //It just crashes all the time if i destroy them so im just gonna keep them invisible

            case 182, 310, 1338, 1462, 1590, 2742, 2616, 2870:
                defaultCamZoom = 1.3;
                cameraSpeed = 1000;

            case 192, 1344, 1472, 1600, 2624, 2752:
                defaultCamZoom = 0.9;
                camGame.zoom = 0.9;
                if (curStep == 1344 || curStep == 2624) camGame.flash(FlxColor.WHITE, 0.9);

            case 312:
                PlayState.instance.inLoreCutscene = true;
                strumBye();
                FlxTween.tween(camHUD, {alpha: 0}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut});
                FlxTween.tween(blackness, {alpha: 1}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
                    FlxTween.tween(blackness, {alpha: 0}, (Conductor.crochet / 1000) * 64, {ease: FlxEase.cubeIn});                
                }});

            case 320, 576:
                defaultCamZoom = 0.8;
                camGame.zoom = 0.8;

            case 448:
                PlayState.instance.inLoreCutscene = false;
                camGame.flash(FlxColor.WHITE, 0.9);
                camHUD.alpha = 1;
                strumHello();

            case 560:
                defaultCamZoom = 1.3;

            case 832, 1856:
                defaultCamZoom = 0.9;
                cameraSpeed = 1;
                if (curStep == 1856)
                {
                    camGame.flash(FlxColor.WHITE, 0.9);
                    camHUD.alpha = 0;
                    PlayState.instance.inLoreCutscene = true;
                    strumBye();
                }

            case 1120, 1184, 1248:
                epicBooms(false);

            case 1312:
                epicBooms(true);

            case 1824:
                FlxTween.tween(camGame, {zoom: 1.3}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween) {
                    defaultCamZoom = 1;
                    camGame.zoom = 1;
                }});

            case 1920, 1984:
                camGame.flash(FlxColor.WHITE, 0.9);
                if (curStep == 1984)
                {
                    defaultCamZoom = 0.9;
                    camHUD.alpha = 1;
                    strumHello();
                    PlayState.instance.inLoreCutscene = false;
                }

            case 2080:
                defaultCamZoom = 0.8;
                camGame.zoom = 0.8;
                cameraSpeed = 1000;

            case 2880:
                camGame.flash(FlxColor.WHITE, 0.9);
                defaultCamZoom = 0.9;
                camGame.zoom = 0.9;

            case 2888:
                FlxTween.tween(camGame, {zoom: 2}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween) {
                    camGame.visible = false;
                    camHUD.visible = false;
                }});
        }
        
        super.stepHit();
    }

    function epicBooms(isEnd:Bool)
    {
        camGame.zoom += 0.2;
        camHUD.zoom += 0.1;
        new FlxTimer().start((Conductor.stepCrochet / 1000) * 6, function(tmr:FlxTimer) {
            camGame.zoom += 0.2;
            camHUD.zoom += 0.1;
        }, 3);

        if (!isEnd)
        {
            new FlxTimer().start((Conductor.stepCrochet / 1000) * 24, function(tmr:FlxTimer) {
                camGame.zoom += 0.2;
                camHUD.zoom += 0.1;
                new FlxTimer().start((Conductor.stepCrochet / 1000) * 4, function(tmr:FlxTimer) {
                    camGame.zoom += 0.2;
                    camHUD.zoom += 0.1;
                    new FlxTimer().start((Conductor.stepCrochet / 1000) * 4, function(tmr:FlxTimer) {
                        camGame.flash(FlxColor.WHITE, 0.9);
                    });
                });
            });
        }
    }

    function strumBye()
    {
        for (i in 0...7)
        {
            var curNote = PlayState.instance.strumLineNotes.members[i % PlayState.instance.strumLineNotes.length];
            if (i < 4) {
                FlxTween.tween(curNote, {angle: -360, x: curNote.x - 750}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadIn});
            } else {
                FlxTween.tween(curNote, {angle: 360, x: curNote.x + 750}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadIn});
            }
        }
    }

    function strumHello()
    {
        for (i in 0...7)
        {
            var curNote = PlayState.instance.strumLineNotes.members[i % PlayState.instance.strumLineNotes.length];
            if (i < 4) {
                FlxTween.tween(curNote, {angle: 0, x: curNote.x + 750}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            } else {
                FlxTween.tween(curNote, {angle: 0, x: curNote.x - 750}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            }
        }
    }

    function resetVars()
    {
        mult = 1.2;
        flipped = false;
        funni = true;
    }
}