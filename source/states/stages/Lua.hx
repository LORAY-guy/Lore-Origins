package states.stages;

import psychlua.ModchartSprite;

class Lua extends BaseStage
{
    private var bgColor:BGSprite;
    private var stars:BGSprite;
    private var sky:BGSprite;
    private var moon:BGSprite;
    private var sun:BGSprite;
    private var cloudsBack:BGSprite;
    private var cloudsMid:BGSprite; // My face when the clouds are mid
    private var cloudsFront:BGSprite;
    private var waltuh:BGSprite;
    private var platform:BGSprite;
    private var haze:BGSprite;
    private var hazerays:BGSprite;

    private var luaRTX:ModchartSprite;
    private var lorayRTX:ModchartSprite;

    override public function create():Void
    {
        super.create();

        bgColor = new BGSprite("lua/base", 0, 0, 0.025, 1);
        bgColor.scale.set(500, 500);
        add(bgColor);

        if (!ClientPrefs.data.lowQuality) {
            stars = new BGSprite("lua/stars", -1330, -950, 0.037, 0.2);
            stars.scale.set(3, 3);
            add(stars);
        }

        sky = new BGSprite("lua/sky", -1250, -1250, 0.037, 0.2);
        sky.scale.set(4, 4);
        sky.blend = SCREEN;
        add(sky);

        moon = new BGSprite("lua/moon", 2500, -1750, 0.037, 0.2);
        moon.blend = LIGHTEN;
        add(moon);

        sun = new BGSprite("lua/thesun", -1000, -2250, 0.05, 0.2);
        sun.scale.set(1.5, 1.5);
        sun.blend = LIGHTEN;
        add(sun);

        cloudsBack = new BGSprite("lua/cloudsback", -1330, -950, 0.15, 0.5);
        cloudsBack.scale.set(3.03, 3.03);
        add(cloudsBack);

        cloudsMid = new BGSprite("lua/cloudsmid", -1250, 433, 0.25, 0.5);
        cloudsMid.scale.set(4, 4);
        add(cloudsMid);

        cloudsFront = new BGSprite("lua/cloudsfront", -1250, 433, 0.33, 0.5);
        cloudsFront.scale.set(4, 4);
        add(cloudsFront);

        waltuh = new BGSprite("lua/ocean", 0, 2250, 0.45, 0.5);
        waltuh.scale.set(4, 4);
        waltuh.blend = MULTIPLY;
        add(waltuh);

        platform = new BGSprite("lua/platform", -1800, 1000, 1, 1);
        add(platform);
    }

    override public function createPost():Void
    {
        super.createPost();

        if (!ClientPrefs.data.lowQuality) {
            lorayRTX = new ModchartSprite(boyfriend.x + 5, boyfriend.y);
            lorayRTX.frames = Paths.getSparrowAtlas("characters/LORAY");
            lorayRTX.animation.addByPrefix("idle", "shaggy_idle", 1, false);
            lorayRTX.animation.addByPrefix("singLEFT", "shaggy_right", 1, false);
            lorayRTX.animation.addByPrefix("singDOWN", "shaggy_down", 1, false);
            lorayRTX.animation.addByPrefix("singUP", "shaggy_up", 1, false);
            lorayRTX.animation.addByPrefix("singRIGHT", "shaggy_left", 1, false);
            lorayRTX.addOffset("idle", -1, -186);
            lorayRTX.addOffset("singLEFT", 130, -173);
            lorayRTX.addOffset("singDOWN", 97, -185);
            lorayRTX.addOffset("singUP", -34, -170);
            lorayRTX.addOffset("singRIGHT", -34, -185);
            lorayRTX.alpha = 0.25;
            lorayRTX.flipX = lorayRTX.flipY = true;
            lorayRTX.y += boyfriend.height + 100;
            insert(PlayState.instance.members.indexOf(platform) - 1, lorayRTX);

            luaRTX = new ModchartSprite(dad.x, dad.y);
            luaRTX.frames = Paths.getSparrowAtlas("characters/Lua");
            luaRTX.animation.addByPrefix("idle", "Idle", 1, false);
            luaRTX.animation.addByPrefix("singLEFT", "Left", 1, false);
            luaRTX.animation.addByPrefix("singDOWN", "Down", 1, false);
            luaRTX.animation.addByPrefix("singUP", "Up", 1, false);
            luaRTX.animation.addByPrefix("singRIGHT", "Left", 1, false);
            luaRTX.alpha = 0.25;
            luaRTX.flipY = true;
            luaRTX.y += dad.height - 120;
            luaRTX.visible = false;
            insert(PlayState.instance.members.indexOf(platform) - 1, luaRTX);

            haze = new BGSprite("lua/hazemain", -5500, -5200, 1, 1);
            haze.scale.set(4.5, 4.5);
            haze.updateHitbox();
            add(haze);

            hazerays = new BGSprite("lua/hazegodrays", 0, 600, 0.75, 0.75);
            hazerays.scale.set(3.5, 3.5);
            hazerays.blend = MULTIPLY;
            add(hazerays);
        }

        camHUD.alpha = 0;
        cameraSpeed = 1000;
        camFollow.y -= 3750;
        defaultCamZoom = 0.3;
        camGame.zoom = 0.3;

        gfGroup.flipX = true;
        gfGroup.alpha = 0;
        gfGroup.x += 1200;
        iconP2.visible = false;
        dadGroup.visible = false;
    }

    override public function songStart():Void
    {
        super.songStart();

        PlayState.instance.isCameraOnForcedPos = true;
        FlxTween.tween(camGame, {zoom: 0.175}, 9, {ease: FlxEase.quadInOut});
        cameraSpeed = 1;
        camGame.flash(FlxColor.WHITE, 2, null, true);
    }

    override public function stepHit():Void
    {
        super.stepHit();

        if (curStep == 112) {
            PlayState.instance.isCameraOnForcedPos = false;
            defaultCamZoom = 0.2;
            FlxTween.tween(camHUD, {alpha: 1}, 1.5, {ease: FlxEase.linear});
        }

        if (curStep == 128)
            camZooming = true;

        if (curStep == 256) {
            defaultCamZoom = 0.25;
            PlayState.instance.triggerEvent("Camera Follow Pos", '${camFollow.x + 250}', '${camFollow.y}', Conductor.songPosition);
            FlxTween.tween(gfGroup, {alpha: 0.2}, 1.5, {ease: FlxEase.quadIn});
        }

        if (curStep == 384) {
            PlayState.instance.triggerEvent("Camera Follow Pos", '', '', Conductor.songPosition);
            defaultCamZoom = 0.4;
        }

        if (curStep == 448) {
            PlayState.instance.triggerEvent("Camera Follow Pos", '${camFollow.x + 250}', '${camFollow.y}', Conductor.songPosition);
            defaultCamZoom = 0.5;
        }

        if (curStep == 480)
            defaultCamZoom = 0.65;

        if (curStep == 496) {
            PlayState.instance.triggerEvent("Camera Follow Pos", '', '', Conductor.songPosition);
            cameraSpeed = 2;
            dadGroup.visible = true;
            iconP2.visible = (!ClientPrefs.data.hideHud); //forgot about this settings, just imagine my face when i realized that i got to test every single song for the 15th time with this setting on this see if i didn't fuck things up
            luaRTX.visible = true;
            FlxTween.tween(gfGroup, {alpha: 0}, 0.75, {ease: FlxEase.quadOut});
        }

        if (curStep == 512) {
            cameraSpeed = 1;
            gfGroup.visible = true;
            defaultCamZoom = 0.4;
        }

        if (curStep == 784)
            FlxTween.tween(camGame, {zoom: 0.7}, 9, {ease: FlxEase.sineInOut});

        if (curStep == 880)
            defaultCamZoom = 0.5;

        if (curStep == 1136)
            defaultCamZoom = 0.6;

        if (curStep == 1152) {
            FlxTween.tween(camGame, {zoom: 0.25}, 9, {ease: FlxEase.sineInOut});
            camGame.flash(FlxColor.WHITE, 2, null, true);
            defaultCamZoom = 0.4;
            camGame.zoom = 0.4;
            cameraSpeed = 1000;
        }

        if (curStep == 1248) {
            defaultCamZoom = 0.225;
            cameraSpeed = 2;
        }

        if (curStep == 1306 || curStep == 1310 || curStep == 1338 || curStep == 1342 || curStep == 1370 || curStep == 1374)
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.02", "0.02", Conductor.songPosition);

        if (curStep == 1396 || curStep == 1400 || curStep == 1404 || curStep == 1405 || curStep == 1406 || curStep == 1407)
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.02", "0.02", Conductor.songPosition);
    
        if (curStep == 1568)
            defaultCamZoom = 0.225;

        if (curStep == 1576)
            defaultCamZoom = 0.25;

        if (curStep == 1584)
            defaultCamZoom = 0.2;

        if (curStep == 1632)
            defaultCamZoom = 0.25;

        if (curStep == 1664) {
            defaultCamZoom = 0.2;
            FlxTween.tween(camGame, {zoom: 0.25}, 9, {ease: FlxEase.sineInOut});
            PlayState.instance.triggerEvent("Camera Follow Pos", '${camFollow.x + 235}', '${camFollow.y}', Conductor.songPosition);
        }

        if (curStep == 1760)
            defaultCamZoom = 0.25;

        if (curStep == 1792)
            defaultCamZoom = 0.2;

        if (curStep == 1808) {
            cameraSpeed = 2;
            PlayState.instance.triggerEvent("Camera Follow Pos", '', '', Conductor.songPosition);
        }

        if (curStep == 1816)
            defaultCamZoom = 0.25;

        if (curStep == 1824) {
            cameraSpeed = 1;
            defaultCamZoom = 0.4;
        }

        if (curStep == 2080)
            defaultCamZoom = 0.2;

        if (curStep == 2336) {
            defaultCamZoom = 0.175;
            FlxTween.tween(camHUD, {alpha: 0}, 1.5, {ease: FlxEase.linear});
            PlayState.instance.triggerEvent("Camera Follow Pos", '${camFollow.x + 235}', '${camFollow.y}', Conductor.songPosition);
            PlayState.instance.isCameraOnForcedPos = true;
        }

        if (curStep == 2344)
            FlxTween.tween(camFollow, {y: camFollow.y - 3750}, 1.5, {ease: FlxEase.sineInOut});

        if (curStep == 2368) {
            camGame.visible = false;
            camHUD.visible = false;
            camOther.flash(FlxColor.WHITE, 3, null, true);
        }
    }

    override public function beatHit():Void
    {
        super.beatHit();

        if (!camZooming)
            return;

        if (curBeat >= 128 && curBeat < 192)
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.02", "0.02", Conductor.songPosition);

        if ((curBeat >= 224 && curBeat < 284) && (curBeat % 2 == 0))
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.02", "0.02", Conductor.songPosition);

        if (curBeat >= 320 && curBeat < 348)
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.02", "0.02", Conductor.songPosition);

        if ((curBeat >= 352 && curBeat < 448) && (curBeat % 2 != 0))
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.02", "0.02", Conductor.songPosition);

        if (curBeat >= 456 && curBeat < 584)
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.02", "0.02", Conductor.songPosition);
    }

    override public function updatePost(elapsed:Float):Void
    {
        super.updatePost(elapsed);

        if (!ClientPrefs.data.lowQuality) {
            if (lorayRTX != null) lorayRTX.playAnim(boyfriend.animation.curAnim.name, true, false, boyfriend.animation.curAnim.curFrame);
            if (luaRTX != null) luaRTX.playAnim(dad.animation.curAnim.name, true, false, dad.animation.curAnim.curFrame);
        }
    }
}
