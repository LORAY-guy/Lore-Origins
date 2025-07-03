package states.stages;

class Cronology extends BaseStage 
{
    var backstage:BGSprite;

    /**CUTSCENE SHIT**/
    var mult:Int = 1;
    var multPuzz:Int = 1;
    var loopCount:Int = 0;

    public static var fnafLogo:FlxSprite;
    var vintage:FlxSprite;

    var the:FlxText;
    var ultimate:FlxText;
    var fnaf:FlxText;
    var timeline:FlxText;
    var tragedy:FlxText;
    var jealousy:FlxText;
    var loss:FlxText;

    var epicTexts:Array<FlxText> = [];
    var puzzPieces:FlxTypedGroup<FlxSprite>;

    var puzzleNames:Array<String> = ['WilliamAftonLit', 'SaveThemLit', 'GiveCakeLit', 'BlinkingOn', 'CharlieDeathLit'];

    override function create()
    {
        backstage = new BGSprite('epicOffice', -480, -200, 1, 1);
        backstage.scale.set(3.25, 3.25);
        backstage.updateHitbox();
        backstage.antialiasing = false;
        add(backstage);

        fnafLogo = new FlxSprite().loadGraphic(Paths.image('introStuff/fnaflogo'));
        fnafLogo.cameras = [camOther];
        fnafLogo.scale.set(0.2, 0.2);
        fnafLogo.updateHitbox();
        fnafLogo.screenCenter(XY);
        add(fnafLogo);
        fnafLogo.velocity.x = 0;
        fnafLogo.velocity.y = 0;

        puzzlePieces();

        vintage = new FlxSprite(-400, -200);
        vintage.frames = Paths.getSparrowAtlas('vintage');
        vintage.animation.addByPrefix('idle', 'idle', 24, true);
        vintage.animation.play('idle', false, false, 0);
        vintage.cameras = [camOther];
        vintage.scale.set(2.5, 2.5);
        vintage.updateHitbox();
        vintage.screenCenter(XY);
        vintage.alpha = 0.4;
        add(vintage);

        tragedy = new FlxText(0, 0, 750, 'TRAGEDY', 128);
        tragedy.setFormat(Paths.font('matpat.ttf'), 128, FlxColor.WHITE, CENTER);
        tragedy.cameras = [camOther];
        tragedy.screenCenter(XY);
        tragedy.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, tragedy);

        jealousy = new FlxText(0, 0, 750, 'JEALOUSY', 128);
        jealousy.setFormat(Paths.font('matpat.ttf'), 128, FlxColor.WHITE, CENTER);
        jealousy.cameras = [camOther];
        jealousy.screenCenter(XY);
        jealousy.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, jealousy);

        loss = new FlxText(0, 0, 750, 'LOSS', 128);
        loss.setFormat(Paths.font('matpat.ttf'), 128, FlxColor.WHITE, CENTER);
        loss.cameras = [camOther];
        loss.screenCenter(XY);
        loss.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, loss);

        super.create();
    }

    override function createPost() 
    {
        super.createPost();
        camGame.visible = false;
        camHUD.visible = false;
    }

    override function stepHit()
    {
        super.stepHit();

        if (curStep == 30) {
            createText('19', 'BOOKS');
            FlxTween.tween(fnafLogo, {alpha: 0}, 0.75, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
                fnafLogo.visible = false;
            }});
        }
        if (curStep == 42)
            createText('11', 'GAMES');
        if (curStep == 56)
            createText('8', 'YEARS', 1.35);
        if (curStep == 105) {
            setupText();
            the.alpha = 1;
        }
        if (curStep == 109)
            ultimate.alpha = 1;
        if (curStep == 117)
            fnaf.alpha = 1;
        if (curStep == 123)
            timeline.alpha = 1;
        if (curStep == 137) {
            for (i in 0...epicTexts.length) {
                epicTexts[i].alpha = 1;
                FlxTween.tween(epicTexts[i], {alpha: 0}, 1.25, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                    epicTexts[i].visible = false;
                }});
            }
            new FlxTimer().start(1, function(tmr:FlxTimer) {
                bringThePiecesIn(puzzPieces.members[loopCount]);
                loopCount++;
            }, 5);
        }
        if (curStep == 206) {
            tragedy.alpha = 1;
            FlxTween.tween(tragedy, {alpha: 0}, 0.75, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                tragedy.visible = false;
            }});
            insert(PlayState.instance.members.indexOf(vintage) - 1, tragedy);
        }
        if (curStep == 217) {
            jealousy.alpha = 1;
            FlxTween.tween(jealousy, {alpha: 0}, 0.75, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                jealousy.visible = false;
            }});
        }
        if (curStep == 228) {
            loss.alpha = 1;
            FlxTween.tween(loss, {alpha: 0}, 0.6, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                loss.visible = false;
            }});
        }
        if (curStep == 236) {
            for (i in 0...puzzPieces.members.length)
                puzzPieces.members[i].visible = false;
            vintage.visible = false;
        }
        if (curStep == 256) {
            camGame.visible = true;
            camHUD.visible = true;
            camHUD.flash(FlxColor.WHITE, 1.2);
            PlayState.instance.inLoreCutscene = false;
        }
        if (curStep == 506) {
            defaultCamZoom = 0.9;
            cameraSpeed = 1000;
        }
        if (curStep == 512 || curStep == 1840) {
            camGame.flash(FlxColor.WHITE, 1.2);
            defaultCamZoom = 0.7;
            cameraSpeed = 1.5;
        }
        if (curStep == 704 || curStep == 720) {
            camGame.flash(FlxColor.WHITE, Std.int((Conductor.crochet / 1000) * 3));
            defaultCamZoom += 0.1;
        }
        if (curStep == 736 || curStep == 744 || curStep == 752) {
            camGame.flash(FlxColor.WHITE, Std.int((Conductor.stepCrochet / 1000) * 7));
            defaultCamZoom += 0.05;
        }
        if (curStep == 768)
            defaultCamZoom = 0.7;
        if (curStep == 800 || curStep == 1312)
            camGame.flash(FlxColor.WHITE, 1.2);
        if (curStep == 1060 || curStep == 2064)
            defaultCamZoom = 0.9;
        if (curStep == 1068) {
            defaultCamZoom = 0.7;
            camGame.flash(FlxColor.WHITE, 1.2);
        }
        if (curStep == 1552) {
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
        }
        if (curStep == 1568) {
            defaultCamZoom = 0.7;
            camGame.flash(FlxColor.WHITE, 1.2);
        }
        if (curStep == 1824) {
            cameraSpeed = 1000;
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
        }
        if (curStep == 2080) {
            camGame.flash(FlxColor.WHITE, 1.2);
            cameraSpeed = 1000;
            defaultCamZoom = 0.8;
        }
        if (curStep == 2340 || curStep == 3392)
            camGame.flash(FlxColor.WHITE, 1.2);
        if (curStep == 2592 || curStep == 2856 || curStep == 3524 || curStep == 3648 || curStep == 3792) {
            camGame.flash(FlxColor.WHITE, 1.2);
            defaultCamZoom = 0.7;
            cameraSpeed = 1.5;
        }
        if (curStep == 2848 || curStep == 3520 || curStep == 3640 || curStep == 3776 || curStep == 4160) {
            cameraSpeed = 1000;
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
            if (curStep == 3640) {
                cameraSpeed = 1000;
                camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
                camFollow.x -= boyfriend.cameraPosition[0] - PlayState.instance.boyfriendCameraOffset[0];
                camFollow.y += boyfriend.cameraPosition[1] + PlayState.instance.boyfriendCameraOffset[1];
            }
        }
        if (curStep == 3641)
            cameraSpeed = 1.5;
        if (curStep == 3104) {
            cameraSpeed = 1000;
            defaultCamZoom = 0.8;
            camGame.zoom = 0.8;
            camHUD.alpha = 0;
            PlayState.instance.inLoreCutscene = true;
        }
        if (curStep == 3120) {
            defaultCamZoom = 0.7;
            cameraSpeed = 1.5;
            PlayState.instance.inLoreCutscene = false;
            FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
        }
        if (curStep == 3904) {
            camGame.flash(FlxColor.WHITE, 1.2);
            cameraSpeed = 1000;
        }
        if (curStep == 4032)
            cameraSpeed = 1.5;
        if (curStep == 4168) {
            cameraSpeed = 1.5;
            camGame.flash(FlxColor.WHITE, 1.2);
            defaultCamZoom = 0.7;
        }
        if (curStep == 4288)
            defaultCamZoom = 0.8;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!fnafLogo.visible)
            return;
        fnafLogo.velocity.x += 0.5 * mult;
        fnafLogo.velocity.y += 0.25 * mult;
        if (fnafLogo.velocity.x >= 25)
            mult = -1;
        else if (fnafLogo.velocity.x <= -25)
            mult = 1;
        if (fnafLogo.velocity.y >= 25)
            mult = -1;
        else if (fnafLogo.velocity.y <= -25)
            mult = 1;
        fnafLogo.angle = (fnafLogo.velocity.x / 100);
    }

    function createText(number:String, subject:String, startDelay:Float = 0)
    {
        var numbers:FlxText = new FlxText(0, 0, 450, number, 300);
        numbers.setFormat(Paths.font('matpat.ttf'), 300, FlxColor.YELLOW, CENTER);
        numbers.cameras = [camOther];
        numbers.screenCenter(XY);
        numbers.y -= 25;
        numbers.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, numbers);

        FlxTween.tween(numbers, {alpha: 1}, 0.75, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
            FlxTween.tween(numbers, {alpha: 0}, 0.75, {startDelay: startDelay, ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                numbers.destroy();
            }});
        }});
        FlxTween.tween(numbers.scale, {x: 1.1, y: 1.1}, 3, {ease: FlxEase.linear});

        var subjects:FlxText = new FlxText(0, 0, 450, subject, 106);
        subjects.setFormat(Paths.font('matpat.ttf'), 106, FlxColor.WHITE, CENTER);
        subjects.cameras = [camOther];
        subjects.screenCenter(XY);
        subjects.y = numbers.y + 250;
        subjects.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, subjects);

        FlxTween.tween(subjects, {alpha: 1}, 0.75, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
            FlxTween.tween(subjects, {alpha: 0}, 0.75, {startDelay: startDelay, ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                subjects.destroy();
            }});
        }});
        FlxTween.tween(subjects.scale, {x: 1.1, y: 1.1}, 3, {ease: FlxEase.linear});
    }

    function puzzlePieces()
    {
        FlxG.random.shuffle(puzzleNames);

        puzzPieces = new FlxTypedGroup<FlxSprite>();
        add(puzzPieces);

        for (i in 0...puzzleNames.length)
        {
            var spr:FlxSprite = new FlxSprite((FlxG.width / 5) * (i - 1)).loadGraphic(Paths.image('introStuff/' + puzzleNames[i]));
            spr.cameras = [camOther];
            spr.scale.set(0.34, 0.34);
            spr.screenCenter(Y);
            spr.y += 750 * multPuzz;
            puzzPieces.add(spr);
            multPuzz = -multPuzz;
        }
    }

    function setupText()
    {
        the = new FlxText(0, 0, 450, 'THE', 106);
        the.setFormat(Paths.font('matpat.ttf'), 106, FlxColor.WHITE, CENTER);
        the.cameras = [camOther];
        the.screenCenter(XY);
        the.y -= 50;
        the.x -= 285;
        the.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, the);

        ultimate = new FlxText(0, 0, 750, 'ULTIMATE', 106);
        ultimate.setFormat(Paths.font('matpat.ttf'), 106, FlxColor.WHITE, CENTER);
        ultimate.cameras = [camOther];
        ultimate.screenCenter(XY);
        ultimate.y -= 50;
        ultimate.x = the.x + 275;
        ultimate.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, ultimate);

        fnaf = new FlxText(0, 0, 450, 'FNAF', 128);
        fnaf.setFormat(Paths.font('matpat.ttf'), 128, FlxColor.YELLOW, CENTER);
        fnaf.cameras = [camOther];
        fnaf.screenCenter(XY);
        fnaf.y += 50;
        fnaf.x -= 325;
        fnaf.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, fnaf);

        timeline = new FlxText(0, 0, 750, 'TIMELINE', 128);
        timeline.setFormat(Paths.font('matpat.ttf'), 128, FlxColor.YELLOW, CENTER);
        timeline.cameras = [camOther];
        timeline.screenCenter(XY);
        timeline.y += 50;
        timeline.x = fnaf.x + 375;
        timeline.alpha = 0;
        insert(PlayState.instance.members.indexOf(vintage) - 1, timeline);

        epicTexts = [the, ultimate, fnaf, timeline]; // kinda epik
    }

    function bringThePiecesIn(spr:FlxSprite)
    {
        var thingyX:Int = 1;
        var thingyY:Int = 1;

        if (spr.x > 500)
            thingyX = -1;
        if (spr.y < 0)
            thingyY = -1;

        FlxTween.tween(spr, {
            x: (spr.x + (20 * thingyX)),
            y: (spr.y - (540 * thingyY)),
            angle: FlxG.random.int(-15, 15)
        }, 1.2, {ease: FlxEase.quadOut});
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
    {
        super.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime);

        if (eventName == 'Play Animation')
        {
            switch (value1)
            {
                case 'singDOWN':
                    camGame.visible = false;
                    camHUD.visible = false;
                case 'singUP':
                    defaultCamZoom += 0.05;
                case 'welcome':
                    gf.visible = true;
            }
        }
    }

    override public function destroy():Void
    {
        for (i in 0...puzzPieces.members.length)
            puzzPieces.members[i].destroy();
        remove(puzzPieces);
        puzzPieces.destroy();
        remove(puzzPieces);
        puzzPieces.destroy();
        remove(fnafLogo);
        fnafLogo.destroy();
        remove(vintage);
        vintage.destroy();
        remove(the);
        the.destroy();
        remove(ultimate);
        ultimate.destroy();
        remove(fnaf);
        fnaf.destroy();
        remove(timeline);
        timeline.destroy();
        remove(tragedy);
        tragedy.destroy();
        remove(jealousy);
        jealousy.destroy();
        remove(loss);
        loss.destroy();

        super.destroy();
    }
}