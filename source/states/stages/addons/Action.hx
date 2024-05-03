package states.stages.addons;

import flixel.FlxSubState;
import objects.StrumNote;

class Action extends BaseStage 
{
    var isBoth:Bool = false;
    var jingleStep:Int = -100;
    var flick:Bool = false;

    var screen:FlxSprite;
    var sky:FlxSprite;
    var skyfloor:FlxSprite;
    var bg:FlxSprite;
    var bg1:FlxSprite;
    var coolfilter:FlxSprite;
    public static var bOverlay:FlxSprite;

    var vcrshit:FlxSprite;
    var redboob:FlxSprite;
    var monitor:FlxSprite;

    var subtitles:FlxText;

    var eventTweens:FlxTweenManager = new FlxTweenManager();
	var eventTweensManager:Map<String, FlxTween> = new Map<String, FlxTween>();

    override function create() 
    {
        screen = new FlxSprite(325, 400).loadGraphic(Paths.image('action/screen'));
        screen.scale.set(1, 0.75);
        screen.updateHitbox();
        insert(PlayState.instance.members.indexOf(states.stages.Lore.wall) + 1, screen);
        screen.y = -600; //Precaching purposes...

        sky = new FlxSprite(-750, -625).loadGraphic(Paths.image('action/paradise'));
        sky.scrollFactor.set(0.2, 0.2);
        sky.scale.set(4, 4);
        sky.updateHitbox();
        sky.antialiasing = false;
        sky.visible = false;
        add(sky);

        skyfloor = new FlxSprite(-700, 1000).makeGraphic(4000, 1500);
        skyfloor.visible = false;
        add(skyfloor);

        bg = new FlxSprite(-100, -100).loadGraphic(Paths.image('action/bg'));
        bg.scrollFactor.set(0.8, 0.8);
        bg.scale.set(3.8, 3.8);
        bg.updateHitbox();
        bg.antialiasing = false;
        bg.visible = false;
        add(bg);

        bg1 = new FlxSprite(-200, -100).loadGraphic(Paths.image('action/bg1'));
        bg1.scale.set(3.8, 3.8);
        bg1.updateHitbox();
        bg1.antialiasing = false;
        bg1.visible = false;
        add(bg1);

        coolfilter = new FlxSprite().loadGraphic(Paths.image('coolfilter'));
        coolfilter.cameras = [camHUD];
        coolfilter.scale.set(1.8, 1.8);
        coolfilter.updateHitbox();
        coolfilter.screenCenter(XY);
        coolfilter.visible = false;
        add(coolfilter);

        bOverlay = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        bOverlay.cameras = [camOther];
        add(bOverlay);

        subtitles = new FlxText(0, 520, FlxG.width, '', 48);
        subtitles.setFormat(Paths.font('ourple.ttf'), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        subtitles.cameras = [camOther];
        subtitles.screenCenter(X);
        subtitles.visible = false;
        add(subtitles);

        if (!ClientPrefs.data.lowQuality) //This takes 500MB of RAM, which is a no-no for some computers
        {
            vcrshit = new FlxSprite().loadGraphic(Paths.image('vcrshit'));
            vcrshit.cameras = [camHUD];
            vcrshit.scale.set(1.075, 1.075);
            vcrshit.updateHitbox();
            vcrshit.screenCenter(XY);
            vcrshit.visible = false;
            add(vcrshit);

            redboob = new FlxSprite(150, 40).loadGraphic(Paths.image('red'));
            redboob.cameras = [camHUD];
            redboob.scale.set(0.925, 0.925);
            redboob.updateHitbox();
            redboob.visible = false;
            add(redboob);

            monitor = new FlxSprite();
            monitor.frames = Paths.getSparrowAtlas('monitor');
            monitor.animation.addByPrefix('open', 'Open', 24, false);
            monitor.animation.addByPrefix('close', 'Close', 24, false);
            monitor.animation.play('close', false, false, 0);
            monitor.cameras = [camHUD];
            monitor.screenCenter(XY);
            monitor.updateHitbox();
            monitor.visible = false;
            add(monitor);
        }

        eventTweens = new FlxTweenManager();
		eventTweensManager = new Map<String, FlxTween>();

        super.create();
    }

    override function createPost() 
    {
        camHUD.visible = false;
        cameraSpeed = 2;
        
        super.createPost();
    }

    override function stepHit()
    {
        /** ------Camera Flashes------ **/
        switch (curStep)
        {
            case 128, 256, 384, 512, 640, 772, 912, 1040, 1408, 1664, 1824, 1856, 1920, 2048, 2176, 2336, 2464, 2592, 2720, 2848, 2976:
                camHUD.flash(FlxColor.WHITE, 0.9);
        }

        if (ClientPrefs.data.flashing)
        {
            switch (curStep)
            {
                case 576, 592, 620, 1504, 1510, 1516, 1524, 1536, 2546, 2798, 2802:
                    camHUD.flash(FlxColor.WHITE, 0.6);
    
                case 608:
                    camHUD.flash(FlxColor.WHITE, 0.4);
            }
        }
        /** ------Camera Flashes------ **/

        /** ------Camera Zooms (manual)------ **/
        switch (curStep)
        {
            case 2542, 2546, 2550, 2798, 2802, 2806:
                camGame.zoom += 0.09;
                camHUD.zoom += 0.06;

            case 1504, 1510, 1516, 1524, 1532:
                coolCameraEffect(1, true);
        }
        /** ------Camera Zooms (manual)------ **/

        /** ------Just stuff------ **/
        switch (curStep)
        {
            case 128:
                camHUD.visible = true;

            case 384, 768:
                defaultCamZoom = 0.95;
                camGame.zoom = 0.95;
                
            case 640:
                subtitles.destroy();
                bOverlay.alpha = 0;
                defaultCamZoom = 0.7;
                camGame.zoom = 0.7;

            case 772, 912, 1040, 1824, 1856, 2048:
                defaultCamZoom = 0.7;
                if (curStep == 2048)
                {
                    cameraSpeed = 10000;
                    defaultCamZoom = 0.7;
                    camGame.zoom = 0.7;
                    camZooming = false;
                    eventTweensManager.set('camGameZoomInPhone', eventTweens.tween(camGame, {zoom: 1}, (Conductor.crochet / 1000) * 32, {ease: FlxEase.linear}));
                }

            case 896, 1024, 1152, 1812, 1838:
                defaultCamZoom = 1;
                camGame.zoom = 1;
                if (curStep == 1152)
                {
                    FlxTween.tween(bOverlay, {alpha: 0}, (Conductor.crochet / 1000) * 62, {ease: FlxEase.sineInOut});
                    FlxTween.tween(camGame, {zoom: 0.675}, (Conductor.crochet / 1000) * 62, {ease: FlxEase.sineInOut});
                }

            case 1148:
                bOverlay.cameras = [camHUD];
                FlxTween.tween(bOverlay, {alpha: 1}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.quadOut});
                FlxTween.tween(camGame, {zoom: 1}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.expoIn});
                
            case 1280, 2240:
                FlxTween.tween(screen, {y: 200}, (Conductor.crochet / 1000) * 28, {ease: FlxEase.linear});

            case 1400, 2032:
                defaultCamZoom = 1;

            case 1408, 2336:
                sky.visible = true;
                skyfloor.visible = true;
                defaultCamZoom = 0.55;
                if (curStep == 2336)
                {
                    camZooming = true;
                    cameraSpeed = 2;
                }

            case 1648:
                eventTweensManager.set('stuffIdk', eventTweens.tween(camGame, {zoom: 5}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.expoIn}));

            case 1664, 2720:
                sky.visible = false;
                skyfloor.visible = false;
                bg.visible = true;
                bg1.visible = true;
                coolfilter.visible = true;
                if (eventTweensManager.exists('stuffIdk'))
                {
                    eventTweensManager.get('stuffIdk').cancel();
                    eventTweensManager.remove('stuffIdk');
                } 
                defaultCamZoom = 0.65;
                camGame.zoom = 0.65;
                cameraSpeed = 2.5;
                
            case 1788:
                eventTweensManager.set('bOverlayIn', eventTweens.tween(bOverlay, {alpha: 1}, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.quadOut}));

            case 1792:
                if (eventTweensManager.exists('bOverlayIn')) {
                    eventTweensManager.get('bOverlayIn').cancel();
                    eventTweensManager.remove('bOverlayIn');
                } 
                bOverlay.alpha = 0;
                bg.visible = false;
                bg1.visible = false;
                coolfilter.visible = false;
                FlxTween.tween(screen, {y: -600}, (Conductor.crochet / 1000) * 28, {ease: FlxEase.linear});
                cameraSpeed = 2;
                defaultCamZoom = 0.7;
                camGame.zoom = 0.7;

            case 2176:
                if (eventTweensManager.exists('camGameZoomInPhone')) {
                    eventTweensManager.get('camGameZoomInPhone').cancel();
                    eventTweensManager.remove('camGameZoomInPhone');
                } 
                cameraSpeed = 2;
                camGame.zoom = 0.8;

            case 2304:
                cameraSpeed = 10000;
                camZooming = false;
                eventTweensManager.set('stuffIdk', eventTweens.tween(camGame, {zoom: 0.9}, (Conductor.crochet / 1000) * 2, {ease: FlxEase.sineOut}));

            case 2312:
                if (eventTweensManager.exists('stuffIdk'))
                {
                    eventTweensManager.get('stuffIdk').cancel();
                    eventTweensManager.remove('stuffIdk');
                } 
                camGame.zoom = 0.8;
                defaultCamZoom = 0.8;

            case 2320:
                camGame.zoom = 0.7;
                defaultCamZoom = 0.7;

            case 2550, 2806:
                bOverlay.alpha = 0;
                FlxTween.tween(bOverlay, {alpha: 0}, (Conductor.stepCrochet / 1000) * 10, {ease: FlxEase.linear});

            case 2170:
                defaultCamZoom = 0.65;

            case 2848:
                bg.visible = false;
                bg1.visible = false;
                coolfilter.visible = false;
                FlxTween.tween(screen, {y: -600}, (Conductor.crochet / 1000) * 28, {ease: FlxEase.linear});
                cameraSpeed = 2;
                defaultCamZoom = 0.9;
                camGame.zoom = 0.9;

            case 3090:
                defaultCamZoom = 0.9;

            case 3104:
                defaultCamZoom = 0.7;
        }

        if (!ClientPrefs.data.lowQuality)
        {
            switch (curStep)
            {
                case 1402, 2330:
                    monitor.visible = true;
                    monitor.animation.play('open', false);
                
                case 1408, 2336:
                    vcrshit.visible = true;
                    monitor.visible = false;
                    states.stages.Lore.curtains.visible = false;

                case 1792, 2848:
                    monitor.visible = true;
                    monitor.animation.play('close', false);
                    redboob.visible = false;
                    vcrshit.visible = false;
                    states.stages.Lore.curtains.visible = true;

                case 1798, 2854:
                    monitor.visible = false;
            }

            if (vcrshit.visible && curStep % 4 == 0)
            {
                redboob.visible = flick;
                flick = !flick;
            }
        }

        if (curStep == 3136)
        {
            camGame.visible = false;
            camHUD.visible = false;
        }
        /** ------Just stuff------ **/

        //For the weird timer thing cuz using stepCrochets doesn't fucking works

        if (curStep == (jingleStep + 7)) {
            coolArrowWaveEffectPlayer(true);
        } else if (curStep == (jingleStep + 14)) {
            coolArrowWaveEffectOpponent(true);
        } else if (curStep == (jingleStep + 18)) {
            coolArrowWaveEffectPlayer(false);
        } else if (curStep == (jingleStep + 23)) {
            coolArrowWaveEffectOpponent(false);
            if (isBoth) {
                coolArrowWaveEffectPlayer(true);
                isBoth = false;
            } else {
                isBoth = true;
            }
        } else if (curStep == (jingleStep + 32) && isBoth) {
            noteJingle();
        }
    }

    override function beatHit() {

        if (((curBeat >= 32 && curBeat < 96) || (curBeat >= 544 && curBeat < 576) || (curBeat >= 712 && curBeat <= 772)) && curBeat % 2 == 0) {
            camGame.zoom += 0.06;
            camHUD.zoom += 0.03;
        }

        if ((curBeat >= 96 && curBeat < 128) && curBeat % 4 == 0) {
            camGame.zoom += 0.06;
            camHUD.zoom += 0.03;
        }

        if (curBeat >= 456 && curBeat < 459) {
            camGame.zoom += 0.06;
            camHUD.zoom += 0.03;
        }

        if ((curBeat >= 128 && curBeat < 144) && curBeat % 2 == 0) {
            coolCameraEffect(1, true);
        }
        
        if (((curBeat >= 144 && curBeat < 156) || (curBeat >= 159 && curBeat < 192) || (curBeat >= 193 && curBeat < 224) || (curBeat >= 228 && curBeat < 256) || (curBeat >= 260 && curBeat < 287) || (curBeat >= 352 && curBeat < 376) || (curBeat >= 384 && curBeat < 416) || (curBeat >= 464 && curBeat < 508) || (curBeat >= 584 && curBeat < 636) || (curBeat >= 640 && curBeat < 700) || (curBeat >= 704 && curBeat < 712))) {
            coolCameraEffect(1, true);
        }

        switch (curBeat)
        {
            case 176, 208, 240, 272, 600, 632:
                noteJingle();
        }
        
        super.beatHit();
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
        if (eventName == 'Set Text')
        {
            if (value1 == null) {
                subtitles.visible = false;
                bOverlay.alpha = 0;
            } else {
                subtitles.visible = true;
                subtitles.text = value1;
                subtitles.screenCenter(X);

                if (value2 == "1")
                {
                    bOverlay.alpha = 1;
                    subtitles.screenCenter(Y);
                    subtitles.size = 82;
                }
            }
        }

        if (eventName == 'Add Camera Zoom')
            coolCameraEffect(1, false);
        
        super.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime);
    }

    override function sectionHit() {
        if ((curSection >= 128 && curSection <= 142) && curSection % 2 == 0)
            camHUD.shake(0.002, Std.int((Conductor.crochet / 1000) * 4));

        if (curSection == 144)
            camHUD.shake(0.003, Std.int((Conductor.crochet / 1000) * 2));

        super.sectionHit();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        eventTweens.update(elapsed);
    }

    function noteJingle()
    {
        coolArrowWaveEffectOpponent(false);
        jingleStep = curStep;
    }

    function coolArrowWaveEffectPlayer(inv:Bool = true)
    {
        var num:Int = 0;
        if (!inv)
        {
            if (eventTweensManager.exists('coolArrowWavePlayer' + num)) {
                eventTweensManager.get('coolArrowWavePlayer' + num).cancel();
                eventTweensManager.remove('coolArrowWavePlayer' + num);
            }

            PlayState.instance.playerStrums.forEach(function(arrow:StrumNote) {
                eventTweensManager.set('coolArrowWavePlayer' + num, eventTweens.tween(arrow, {y: arrow.y - 25}, 0.075, {ease: FlxEase.sineOut, startDelay: (0.035 * num), onComplete: function(twn:FlxTween) {
                    FlxTween.tween(arrow, {y: arrow.y + 25}, 0.075, {ease: FlxEase.sineOut});
                }}));
                num++;
            });
        } else {
            var i:Int = 7;
            while (i != 3)
            {
                if (eventTweensManager.exists('coolArrowWavePlayer' + i)) {
                    eventTweensManager.get('coolArrowWavePlayer' + i).cancel();
                    eventTweensManager.remove('coolArrowWavePlayer' + i);
                }

                var curNote = PlayState.instance.strumLineNotes.members[i % PlayState.instance.strumLineNotes.length];
                eventTweensManager.set('coolArrowWavePlayer' + i, eventTweens.tween(curNote, {y: curNote.y - 25}, 0.075, {ease: FlxEase.sineOut, startDelay: (0.035 * num), onComplete: function(twn:FlxTween) {
                    FlxTween.tween(curNote, {y: curNote.y + 25}, 0.075, {ease: FlxEase.sineOut});
                }}));
                i--;
                num++;
            }
        }
    }

    function coolArrowWaveEffectOpponent(inv:Bool = true)
    {
        var num:Int = 0;
        if (!inv)
        {
            if (eventTweensManager.exists('coolArrowWaveOpponent' + num)) {
                eventTweensManager.get('coolArrowWaveOpponent' + num).cancel();
                eventTweensManager.remove('coolArrowWaveOpponent' + num);
            }

            PlayState.instance.opponentStrums.forEach(function(arrow:StrumNote) {
                eventTweensManager.set('coolArrowWaveOpponent' + num, eventTweens.tween(arrow, {y: arrow.y - 25}, 0.075, {ease: FlxEase.sineOut, startDelay: (0.035 * num), onComplete: function(twn:FlxTween) {
                    FlxTween.tween(arrow, {y: arrow.y + 25}, 0.075, {ease: FlxEase.sineOut});
                }}));
                num++;
            });
        } else {
            var i:Int = 3;
            while (i != -1)
            {
                if (eventTweensManager.exists('coolArrowWaveOpponent' + i)) {
                    eventTweensManager.get('coolArrowWaveOpponent' + i).cancel();
                    eventTweensManager.remove('coolArrowWaveOpponent' + i);
                }

                var curNote = PlayState.instance.strumLineNotes.members[i % PlayState.instance.strumLineNotes.length];
                eventTweensManager.set('coolArrowWaveOpponent' + i, eventTweens.tween(curNote, {y: curNote.y - 25}, 0.075, {ease: FlxEase.sineOut, startDelay: (0.035 * num), onComplete: function(twn:FlxTween) {
                    FlxTween.tween(curNote, {y: curNote.y + 25}, 0.075, {ease: FlxEase.sineOut});
                }}));
                i--;
                num++;
            }
        }
    }

    var mult:Int = 1;
    public function coolCameraEffect(power:Float, zoom:Bool)
    {
        if (eventTweensManager.exists('camGameEffect')) {
            eventTweensManager.get('camGameEffect').cancel();
            eventTweensManager.remove('camGameEffect');
        }

        if (eventTweensManager.exists('camHUDEffect')) {
            eventTweensManager.get('camHUDEffect').cancel();
            eventTweensManager.remove('camHUDEffect');
        }

        camGame.angle = (power * mult);
        camHUD.angle = (power * -mult);

        if (zoom)
        {
            camGame.zoom += (power / 10);
            camHUD.zoom += (power / 10) / 2;
        }

        eventTweensManager.set('camGameEffect', eventTweens.tween(camGame, {angle: 0}, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.sineOut}));
        eventTweensManager.set('camHUDEffect', eventTweens.tween(camHUD, {angle: 0}, (Conductor.stepCrochet / 1000) * 6, {ease: FlxEase.sineOut}));
        mult = -mult;
    }

    override function openSubState(SubState:FlxSubState) {
        eventTweens.active = false;
        super.openSubState(SubState);
    }

    override function closeSubState() {
        eventTweens.active = true;
        super.closeSubState();
    }
}