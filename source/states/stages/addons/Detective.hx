package states.stages.addons;

class Detective extends BaseStage 
{
    var coolfilter:FlxSprite;
    var rain:FlxSprite;

    var thingsToBW:Array<Dynamic>;

    override function create() 
    {
        coolfilter = new FlxSprite().loadGraphic(Paths.image('coolfilter'));
        coolfilter.cameras = [camHUD];
        coolfilter.scale.set(1.8, 1.8);
        coolfilter.updateHitbox();
        coolfilter.screenCenter(XY);
        add(coolfilter);

        super.create();
    }

    override function createPost() 
    {
        if (!ClientPrefs.data.lowQuality) 
        {
            rain = new FlxSprite(200, 300);
            rain.frames = Paths.getSparrowAtlas('rain');
            rain.animation.addByPrefix('rain', 'rain', 40, true);
            rain.animation.play('rain');
            rain.scale.set(4.25, 4.25);
            rain.updateHitbox();
            rain.antialiasing = false;
            rain.blend = ADD;
            rain.alpha = 0.1;
            rain.scrollFactor.set(1.3, 1.3);
            add(rain);
        }

        camZooming = true;
        defaultCamZoom = 0.7;
        cameraSpeed = 1.5;

        thingsToBW = [boyfriend, dad, gf, states.stages.Lore.floor, states.stages.Lore.wall];
        if (!ClientPrefs.data.lowQuality)
            thingsToBW.push(states.stages.Lore.curtains);

        for (i in 0...thingsToBW.length)
            FlxTween.color(thingsToBW[i], 0.01, thingsToBW[i].color, FlxColor.GRAY);

        super.createPost();
    }

    override function stepHit() {
        switch (curStep)
        {
            case 128, 1024:
                camGame.flash(FlxColor.WHITE, 0.9);

            case 256, 396:
                camGame.flash(FlxColor.WHITE, 0.9);
                defaultCamZoom = 0.7;

            case 384, 512:
                if (curStep == 512) camGame.flash(FlxColor.WHITE, 0.9);
                defaultCamZoom = 0.9;

            case 768:
                defaultCamZoom = 0.8;

            case 1008:
                defaultCamZoom = 1;
                cameraSpeed = 2.5;

            case 1272:
                defaultCamZoom = 1.1;

            case 1280:
                defaultCamZoom = 1;
                camGame.flash(FlxColor.WHITE, 0.9);

            case 1536:
                cameraSpeed = 1.5;
                camGame.flash(FlxColor.WHITE, 0.9);

            case 1792, 1920:
                camGame.flash(FlxColor.WHITE, 0.9);
                cameraSpeed = 1000;
                if (curStep == 1792) defaultCamZoom = 0.8;
                FlxTween.tween(camGame, {zoom: 1.1}, Std.int((Conductor.crochet / 1000) * 26), {ease: FlxEase.sineIn});

            case 1919:
                camZooming = true;

            case 2048:
                camGame.flash(FlxColor.WHITE, 0.9);
                cameraSpeed = 2.5;

            case 2560:
                camGame.flash(FlxColor.WHITE, 0.9);
                defaultCamZoom = 1;
                cameraSpeed = 1.5;

            case 2848:
                camGame.visible = false;
                camHUD.visible = false;
                camOther.flash(FlxColor.WHITE, 1.4);
        }

        super.stepHit();
    }

    override function beatHit() {
        if (curSection >= 112 && curSection < 119)
            camZooming = false;
        else if (curSection <= 120)
            camZooming = true;

        super.beatHit();
    }

    override function sectionHit() {
        if ((curSection >= 112 && curSection <= 126) && curSection % 2 == 0)
            camHUD.shake(0.002, Std.int((Conductor.crochet / 1000) * 5));

        super.sectionHit();
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
        if (eventName == 'coolzoom')
        {
            if (value1 == '1') {
                defaultCamZoom = flValue1;
                camGame.zoom = flValue1;
            } else {
                defaultCamZoom = flValue1 / 10;
                camGame.zoom = flValue1 / 10;
            }
        }
        
        super.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime);
    }
}