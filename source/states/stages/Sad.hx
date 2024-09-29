package states.stages;

import objects.HealthIcon;

class Sad extends BaseStage 
{
    public static var allowCountdown:Bool = false;
    public static var firstOpening:Null<Bool> = false;
    public static var blocked:Bool = false;
    var isShaking:Bool = false;

    var remainingTheories:String = "";

    var botplaySine:Dynamic = 0;

    var wall:BGSprite;
    var floor:BGSprite;
    public static var spotlightMatpat:BGSprite;
    var spotlightOurpleGuy:BGSprite;
    var spotlightPhoneGuy:BGSprite;
    var curtains:BGSprite;

    var couchBg:BGSprite;
    var matpat:BGSprite;
    var phoneIcon:HealthIcon;
    
    var darkStuff:FlxSprite;
    public static var blackIntro:FlxSprite;

    var timerBar:FlxSprite;
    var countdown:FlxText;

    public static var sadStuff:FlxTypedGroup<Dynamic>;

    var tutorialTxt:FlxText;

    override function create() 
    {
        wall = new BGSprite('lore/wall', -320, 0, 1, 1);
        wall.setGraphicSize(Std.int(wall.width * 1.3));
        wall.updateHitbox();
        add(wall);

        floor = new BGSprite('lore/floor', -350, 950, 1, 1);
        floor.setGraphicSize(Std.int(floor.width * 1.3));
        floor.updateHitbox();
        add(floor);

        darkStuff = new FlxSprite().makeGraphic(2500, 2500, FlxColor.BLACK);
        darkStuff.alpha = 0.9;
        add(darkStuff);

        spotlightMatpat = new BGSprite('spotlight', 640, 240, 1, 1);
        spotlightMatpat.blend = ADD;
        spotlightMatpat.alpha = 0.45;
        spotlightMatpat.visible = false;
        insert(3, spotlightMatpat);

        spotlightOurpleGuy = new BGSprite('spotlight', 1370, 240, 1, 1);
        spotlightOurpleGuy.blend = ADD;
        spotlightOurpleGuy.alpha = 0.45;
        spotlightOurpleGuy.visible = false;
        insert(5, spotlightOurpleGuy);

        spotlightPhoneGuy = new BGSprite('spotlight', 1005, 160, 1, 1);
        spotlightPhoneGuy.blend = ADD;
        spotlightPhoneGuy.alpha = 0.45;
        spotlightPhoneGuy.visible = false;
        insert(6, spotlightPhoneGuy);

        blackIntro = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        blackIntro.screenCenter(XY);
        blackIntro.cameras = [camOther];
        blackIntro.alpha = 0.9999; //Precachine purposes
        add(blackIntro);

        tutorialTxt = new FlxText(10, (ClientPrefs.data.downScroll) ? 65 : 640, 300, 'Press \'TAB\' to open the countdown', 26);
        tutorialTxt.setFormat(Paths.font('matpat-timer.ttf'), 26, FlxColor.GREEN, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        tutorialTxt.borderSize = 2;
        tutorialTxt.cameras = [camHUD];
        add(tutorialTxt);

        sadStuff = new FlxTypedGroup<Dynamic>();
        sadStuff.cameras = [camHUD];
		add(sadStuff);

        resetVars();
        super.create();
    }

    override function createPost() 
    {
        super.createPost();

        if (!ClientPrefs.data.lowQuality) {
            curtains = new BGSprite("lore/curtain", -75, 135, 1.2, 1.2);
            curtains.setGraphicSize(Std.int(curtains.width * 1.2));
            curtains.updateHitbox();
            FlxTween.color(curtains, 0.01, curtains.color, FlxColor.fromRGB(44, 44, 44));
            add(curtains);
        }

        var currentDate = Date.now();
        var targetDate = new Date(2024, 2, 9, 0, 0, 0);
        var remainingTime = (targetDate.getTime() - currentDate.getTime()) / (1000 * 60 * 60 * 24);
        var weeksRemaining = Std.int(remainingTime / 7);
        
        //Since each theory came out every week (on average), this makes this mechanic much easier to make
        var remainingTheories:String = (remainingTime < 0 ? 'FAREWELL, MATPAT!' : '- $weeksRemaining THEORIES REMAIN -');

        timerBar = new FlxSprite(0, 420).makeGraphic(1280, 120);
        timerBar.screenCenter(X);
        timerBar.alpha = 0;
        sadStuff.add(timerBar);

        countdown = new FlxText(0, (!ClientPrefs.data.downScroll) ? 437 : 45, 1280, remainingTheories, 68);
        countdown.setFormat(Paths.font('matpat-timer.ttf'), 68, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        countdown.borderSize = 1;
        countdown.alpha = 0;
        countdown.screenCenter(X);
        sadStuff.add(countdown);

        couchBg = new BGSprite('couch');
        couchBg.color = 0xFF555555;
        couchBg.cameras = [camHUD];
        couchBg.screenCenter();
        couchBg.scrollFactor.set(0.75, 0.75);
        couchBg.visible = false;
        add(couchBg);

        matpat = new BGSprite('daepicmatpat', 0, 140);
        matpat.scale.set(1.3, 1.3);
        matpat.updateHitbox();
        matpat.color = 0xFFDDDDDD;
        matpat.cameras = [camHUD];
        matpat.screenCenter(X);
        matpat.visible = false;
        matpat.alpha = 0;
        add(matpat);

        phoneIcon = new HealthIcon('phone', false, true);
        phoneIcon.animation.curAnim.curFrame = 1;
        phoneIcon.cameras = [camOther];
        phoneIcon.scale.set(1.6, 1.6);
        phoneIcon.updateHitbox();
        phoneIcon.setPosition(FlxG.width - phoneIcon.width + 15, 50);
        phoneIcon.flipX = true;
        phoneIcon.angle = -25;
        phoneIcon.visible = false;
        phoneIcon.alpha = 0.0001; //Precaching purposes
        
        phoneIcon.updateHitbox();
        add(phoneIcon);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (tutorialTxt != null) {
            botplaySine += 180 * elapsed;
            tutorialTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);	
        } else if (botplaySine != null) {
            botplaySine = null;
        }

        if (firstOpening && tutorialTxt.alpha < 0.01) {
            tutorialTxt.destroy();
            firstOpening = null;
        }

        //So it doesn't show it through the whole song if the player doesn't care (kind of a useless mechanic now honestly, idk if i should actually remove it now, I think people already got the point)
        if (firstOpening != null && Conductor.songPosition > 30000 && !firstOpening) {
            firstOpening = true;
        }

		if (isShaking) {
			phoneIcon.angle = FlxG.random.float(-30, -20);
		} else {
			phoneIcon.angle = -25;
		}

        if (FlxG.keys.justPressed.TAB && !blocked) {
            blocked = true;

            for (i in 0...sadStuff.length)
            {
                var targetAlpha:Int = (sadStuff.members[i].alpha == 0) ? 1 : 0;
                FlxTween.tween(sadStuff.members[i], {alpha: targetAlpha}, 0.5, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
                    blocked = false;
                }});
            }

            if (!firstOpening) firstOpening = true;
        }
    }

    override function stepHit()
    {
        switch (curStep)
        {
            case 128, 1664:
                camGame.flash();

            case 132:
                spotlightOurpleGuy.visible = true;
                FlxG.sound.play(Paths.sound('spotlight'));

            case 496, 2032:
                defaultCamZoom = 1.1;

            case 512, 2048:
                camGame.flash();
                defaultCamZoom = 0.75;

            case 768, 1280:
                defaultCamZoom = 1;

            case 1008:
                defaultCamZoom = 1.1;

            case 1024:
                camGame.flash();
                defaultCamZoom = 0.8;

            case 1536, 3328:
                camGame.flash();
                camGame.zoom = 0.9;
                defaultCamZoom = 0.9;
                cameraSpeed = 1000;
            
            case 1540, 2848, 3344:
                cameraSpeed = 1;

            case 2304:
                camHUD.flash();
                camGame.visible = false;
                PlayState.instance.inLoreCutscene = false;
                PlayState.instance.uiGroup.visible = false;
                PlayState.instance.noteGroup.visible = false;
                PlayState.instance.camZooming = false;
                PlayState.instance.vocals.volume = 1; //If the player missed before the cutscene starts, the phone sound won't play, since it's played on the player's voice track. Here's a fix
                couchBg.visible = true;
            
            case 2816:
                spotlightPhoneGuy.visible = true;
                FlxG.sound.play(Paths.sound('spotlight'));
                camGame.visible = true;
                PlayState.instance.uiGroup.visible = true;
                PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled; //Idk why that thing reappears but whatever
                PlayState.instance.noteGroup.visible = true;
                PlayState.instance.camZooming = true;
                PlayState.instance.inLoreCutscene = true;
                matpat.visible = false;
                couchBg.visible = false;
                phoneIcon.visible = false;
                camGame.flash();
                camHUD.zoom = 1;
                camGame.zoom = 0.75;
                defaultCamZoom = 0.75;
                cameraSpeed = 1000;

            case 3064:
                defaultCamZoom = 0.9;

            case 3072:
                camGame.flash();
                defaultCamZoom = 1.1;
        }

        if (curStep == 2316) {
            matpat.visible = true;
            FlxTween.tween(matpat, {alpha: 1}, 2, {ease: FlxEase.sineInOut});
        }

        if (curStep == 2385 || curStep == 2416 || curStep == 2448 || curStep == 2528 || curStep == 2586 || curStep == 2667 || curStep == 2687 || curStep == 2767 || curStep == 2798) { 
            matpatAnim();
        } else if (curStep == 2395 || curStep == 2556 || curStep == 2632 || curStep == 2677 || curStep == 2696 || curStep == 2741 || curStep == 2772) {
            matpatAnim(false);
        } else if (curStep == 2440 || curStep == 2457 || curStep == 2477) {
            matpatAnim(false, true);
        } else if (curStep == 2472) {
            matpatAnim(true, false);
        } else if (curStep == 2505 || curStep == 2807) {
            matpatAnim(false, false);
        } else if (curStep == 2717) {
            matpatAnim(true, true);
        }

        if (curStep == 2432) {
            FlxTween.tween(camHUD, {zoom: 1.25}, (Conductor.stepCrochet / 1000) * (2800 - 2432), {ease: FlxEase.quadInOut});
        }

        if (curStep == 2472) {
            phoneIcon.visible = true;
            FlxTween.tween(phoneIcon, {alpha: 0.5}, (Conductor.stepCrochet / 1000) * (2624 - 2432), {ease: FlxEase.quadInOut});
        }

        if (curStep == 3868) {
            matpat.alpha = 0;
            matpat.visible = true;
            matpat.x = matpat.width / 2;
            FlxTween.tween(matpat, {alpha: 0.25}, 1.25, {ease: FlxEase.quadInOut});
        }

        if (curStep == 3882) {
            FlxTween.tween(matpat, {alpha: 0}, 2.5, {ease: FlxEase.quadInOut});
        }

        super.stepHit();
    }

    function matpatAnim(flip:Bool = true, ?hap:Null<Bool> = null)
    {
        matpat.flipX = flip;
        matpat.y -= 20;
        FlxTween.tween(matpat, {y: matpat.y + 20}, 0.2, {ease: FlxEase.cubeOut});
        if (hap != null) matpat.loadGraphic(Paths.image((hap ? 'daepicmatpatbuthap' : 'daepicmatpat')));
    }

    public static function resetVars() //Fix GameOver not resetting the current variables
    {
        allowCountdown = false;
        firstOpening = false;
        blocked = false;
    }

    override function sectionHit() {
        super.sectionHit();

        if (curSection == 156) {
            camHUD.shake(0.00025, (Std.int(Conductor.crochet) / 1000 * 4), function() {
                isShaking = false;
            });
            isShaking = true;
        }

        if (curSection == 158) {
            camHUD.shake(0.0005, (Std.int(Conductor.crochet) / 1000 * 4), function() {
                isShaking = false;
            });
            isShaking = true;
        }

        if ((curSection >= 160 && curSection <= 174) && curSection % 2 == 0) {
            camHUD.shake(0.001, (Std.int(Conductor.crochet) / 1000 * 4), function() {
                isShaking = false;
            });
            isShaking = true;
        }
    }
}