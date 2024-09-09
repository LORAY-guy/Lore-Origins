package states.stages;

import objects.Character;

class Fever extends BaseStage 
{
    var back:BGSprite;
    var stagefront:BGSprite;
    var curtains:BGSprite;
    var crowd:Null<BGSprite> = null;

    var thingsToBW:Array<Character> = [];

    var blackstuff:FlxSprite;

    override function create() {
        back = new BGSprite('fever/stageback', -660, -400, 1, 1);
        back.setGraphicSize(Std.int(back.width * 1.1));
        back.updateHitbox();
        add(back);

        stagefront = new BGSprite('stagefront', -675, 520, 1, 1);
        stagefront.setGraphicSize(Std.int(stagefront.width * 1.1));
        stagefront.updateHitbox();
        add(stagefront);

        super.create();
    }

    override function createPost() 
    {
        if (!ClientPrefs.data.lowQuality) 
        {
            curtains = new BGSprite('fever/stagecurtains', -730, -480, 1, 1);
            curtains.setGraphicSize(Std.int(curtains.width * 1.1));
            curtains.updateHitbox();
            curtains.antialiasing = false;
            add(curtains);

            crowd = new BGSprite('fever/crowd', -645, 475, 1, 1);
            crowd.setGraphicSize(Std.int(crowd.width * 1.1));
            crowd.updateHitbox();
            add(crowd);
        }

        blackstuff = new FlxSprite().makeGraphic(2000, 2000, FlxColor.BLACK);
        blackstuff.scrollFactor.set(0, 0);
        blackstuff.screenCenter(XY);
        blackstuff.alpha = 0.5;
        add(blackstuff);

        thingsToBW = [boyfriend, dad, gf];

        super.createPost();
    }

    override function stepHit() {
        if (curStep == 192 || curStep == 256 || curStep == 320 || curStep == 388 || curStep == 448 || curStep == 512 || curStep == 768 || curStep == 904 || curStep == 1024 || curStep == 1118 || curStep == 1280 || curStep == 1472 || curStep == 1536 || curStep == 1668 || curStep == 1728 || curStep == 2048 || curStep == 2176) {
            camGame.flash(FlxColor.WHITE, 0.9);
        }
        
        if ((curStep >= 304 && curStep < 320) || (curStep >= 368 && curStep < 388) || (curStep >= 432 && curStep < 448) || (curStep >= 496 && curStep < 512) || (curStep >= 992 && curStep < 1015) || (curStep >= 1110 && curStep < 1118) || (curStep >= 1584 && curStep < 1600) || (curStep >= 1648 && curStep < 1664) || (curStep >= 2288 && curStep < 2304)) {
            camZooming = false;
        }
        
        if (curStep == 176 || curStep == 1248 || curStep == 1456 || curStep == 1520 || curStep == 2016 || curStep == 2160 || curStep == 2032 || curStep == 2800) {
            camZooming = false;
        } else if (curStep == 192 || curStep == 320 || curStep == 388 || curStep == 448 || curStep == 512 || curStep == 1280 || curStep == 1472 || curStep == 1532 || curStep == 1732 || curStep == 2048 || curStep == 2176 || curStep == 2808) {
            camZooming = true;
        }
        
        if (curStep == 240 || curStep == 384 || curStep == 496 || curStep == 896 || curStep == 1016 || curStep == 1096 || curStep == 1520 || curStep == 1648 || curStep == 1776 || curStep == 1920 || curStep == 2800 || curStep == 2492 || curStep == 2512) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        } else if (curStep == 256 || curStep == 388 || curStep == 512 || curStep == 904 || curStep == 1024 || curStep == 1118 || curStep == 1536 || curStep == 1668 || curStep == 1792 || curStep == 2016 || curStep == 2816 || curStep == 2496 || curStep == 2528) {
            defaultCamZoom = 0.75;
            cameraSpeed = 1;
        }
        
        if ((curStep >= 256 && curStep < 512) || (curStep >= 1110 && curStep < 1118) || (curStep >= 1536 && curStep < 1776) || (curStep >= 2016 && curStep < 2048) || (curStep >= 2622 && curStep < 2657) || curStep >= 2752) {
            cameraSpeed = 100;
        }
        
        if (curStep == 1118) {
            cameraSpeed = 1;
        }
        
        if (curStep == 760) {
            defaultCamZoom = 1.2;
        } else if (curStep == 768) {
            defaultCamZoom = 0.75;
            cameraSpeed = 100;
        }
        
        if (curStep == 768 || curStep == 2432) {
            blackstuff.alpha += 0.2;
            for (i in 0...thingsToBW.length)
                FlxTween.color(thingsToBW[i], 0.01, thingsToBW[i].color, FlxColor.fromRGB(235, 235, 235));
            defaultCamZoom = 0.75;
            cameraSpeed = 1;
        }
        
        if (curStep == 786) {
            FlxTween.tween(camGame, {zoom: 1.1}, 6, {ease: FlxEase.cubeInOut});
        }

        if (curStep == 1118) {
            PlayState.instance.moveCamera(false);
        }
        
        if (curStep == 1808) {
            FlxTween.tween(camGame, {zoom: 1.1}, (Conductor.stepCrochet / 1000) * (16 * 7), {ease: FlxEase.cubeInOut});
        }

        if (curStep == 2416 || curStep == 2544) {
            FlxTween.tween(camGame, {zoom: 2}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween) {
                FlxTween.tween(camGame, {zoom: 0.75}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.expoOut});
            }});
        }

        if (curStep == 1280 || curStep == 2560) {
            blackstuff.alpha -= 0.2;
            for (i in 0...thingsToBW.length)
                FlxTween.color(thingsToBW[i], 0.01, thingsToBW[i].color, FlxColor.WHITE);
        }
        
        if (curStep == 2846) {
            blackstuff.alpha = 1;
            blackstuff.cameras = [camOther];
        }
        
        if (curStep == 2492 || curStep == 2512 || curStep == 2796)
        {
            camFollow.x = 691.5;
            camFollow.y = 353;
            cameraSpeed = 0;
        }

        if (curStep == 2496 || curStep == 2528)
            cameraSpeed = 1;

        if (!ClientPrefs.data.lowQuality) {
            if (curStep == 768 || curStep == 2432)
                crowd.loadGraphic(Paths.image('fever/crowdrtx'));
            else if (curStep == 1280 || curStep == 2560)
                crowd.loadGraphic(Paths.image('fever/crowd'));
        }
        
        super.stepHit();
    }

    override function beatHit() {
        super.beatHit();

        if ((curBeat >= 64 && curBeat < 76) || 
            (curBeat >= 80 && curBeat < 92) || 
            (curBeat >= 97 && curBeat < 108) || 
            (curBeat >= 112 && curBeat < 124) || 
            (curBeat >= 226 && curBeat < 248) || 
            (curBeat >= 352 && curBeat < 380) || 
            (curBeat >= 384 && curBeat < 396) || 
            (curBeat >= 400 && curBeat < 412) || 
            (curBeat >= 417 && curBeat < 428) || 
            (curBeat >= 432 && curBeat < 444) || 
            (curBeat >= 544 && curBeat < 572) || 
            (curBeat >= 576 && curBeat < 604) || 
            (curBeat >= 672 && curBeat < 700)) {
            camGame.zoom += 0.04;
            camHUD.zoom += 0.02;
        }
        
        if (((curBeat >= 128 && curBeat < 190) || 
             (curBeat >= 320 && curBeat < 352) || 
             (curBeat >= 640 && curBeat < 672)) && curBeat % 2 == 0) {
            camGame.zoom += 0.04;
            camHUD.zoom += 0.02;
        }
        
        if ((curBeat >= 256 && curBeat < 273) || 
            (curBeat >= 280 && curBeat < 312) || 
            (curBeat >= 512 && curBeat < 540) || 
            (curBeat >= 608 && curBeat < 632) || 
            (curBeat >= 624 && curBeat < 628) || 
            (curBeat >= 632 && curBeat < 635)) {
            camGame.zoom += 0.06;
            camHUD.zoom += 0.04;
        }

        if (!ClientPrefs.data.lowQuality) {
            crowd.y = crowd.y + 20;
            FlxTween.tween(crowd, {y: crowd.y - 20}, 0.15, {ease: FlxEase.cubeOut});
        }
    }
}