package states.stages;

class Apology extends BaseStage
{
    var stageback:FlxSprite;
    var stagefront:FlxSprite;

    var stagecurtains:FlxSprite;
    var stagelight_left:FlxSprite;
    var stagelight_right:FlxSprite;

    var redbg:FlxSprite;
    var gtlogo:FlxSprite;
    var gtRoom:FlxSprite;
    var matpatIntro:FlxSprite;

    override function create()
    {   
        stageback = new FlxSprite(-600, -300).loadGraphic(Paths.image('apology/stageback'));
        stageback.scrollFactor.set(1, 1);
        stageback.antialiasing = ClientPrefs.data.antialiasing;
        add(stageback);

        stagefront = new FlxSprite(-650, 600).loadGraphic(Paths.image('apology/stagefront'));
        stagefront.scrollFactor.set(1, 1);
        stagefront.scale.set(1.1, 1.1);
        stagefront.updateHitbox();
        stagefront.antialiasing = ClientPrefs.data.antialiasing;
        add(stagefront);

        if (!ClientPrefs.data.lowQuality)
        {
            stagelight_left = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage_light'));
            stagelight_left.scrollFactor.set(1.1, 1.1);
            stagelight_left.scale.set(1.1, 1.1);
            stagelight_left.updateHitbox();
            stagelight_left.antialiasing = ClientPrefs.data.antialiasing;
            add(stagelight_left);

            stagelight_right = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage_light'));
            stagelight_right.scrollFactor.set(1.1, 1.1);
            stagelight_right.scale.set(1.1, 1.1);
            stagelight_right.updateHitbox();
            stagelight_right.flipX = true;
            stagelight_right.antialiasing = ClientPrefs.data.antialiasing;
            add(stagelight_right);

            stagecurtains = new FlxSprite(-525, -300).loadGraphic(Paths.image('apology/stagecurtains'));
            stagecurtains.scrollFactor.set(1.3, 1.3);
            stagecurtains.scale.set(0.9, 0.9);
            stagecurtains.updateHitbox();
            stagecurtains.antialiasing = ClientPrefs.data.antialiasing;
            add(stagecurtains);
        }

        super.create();
    }

    override function createPost() 
    {
        redbg = new FlxSprite().loadGraphic(Paths.image('gtbg'));
        redbg.scrollFactor.set();
        redbg.scale.set((2/3), (2/3));
        redbg.updateHitbox();
        redbg.screenCenter();
        redbg.antialiasing = ClientPrefs.data.antialiasing;
        add(redbg);
        redbg.alpha = 0.0001;

        gtlogo = new FlxSprite().loadGraphic(Paths.image('gtLogo'));
        gtlogo.scrollFactor.set();
        gtlogo.scale.set((1/3), (1/3));
        gtlogo.updateHitbox();
        gtlogo.screenCenter();
        gtlogo.antialiasing = ClientPrefs.data.antialiasing;
        add(gtlogo);
        gtlogo.alpha = 0.0001;

        gtRoom = new FlxSprite().loadGraphic(Paths.image('couch'));
        gtRoom.scale.set(1.2, 1.2);
        gtRoom.updateHitbox();
        gtRoom.cameras = [camOther];
        gtRoom.screenCenter();
        gtRoom.antialiasing = ClientPrefs.data.antialiasing;
        add(gtRoom);
        gtRoom.alpha = 0.001;

        matpatIntro = new FlxSprite().loadGraphic(Paths.image('daepicmatpat'));
        matpatIntro.scale.set(1.4, 1.4);
        matpatIntro.updateHitbox();
        matpatIntro.y = 100;
        matpatIntro.cameras = [camOther];
        matpatIntro.screenCenter(X);
        matpatIntro.antialiasing = ClientPrefs.data.antialiasing;
        add(matpatIntro);
        matpatIntro.alpha = 0.001;

        super.createPost();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (curStep >= 320 && curStep < 336) {
            gtlogo.angle = FlxMath.lerp(1, gtlogo.angle, Math.exp(-elapsed * 7.5));
            gtlogo.scale.set(FlxMath.lerp((1/3), gtlogo.scale.x, Math.exp(-elapsed * 7.5)), FlxMath.lerp((1/3), gtlogo.scale.y, Math.exp(-elapsed * 7.5)));
            gtlogo.updateHitbox();
            gtlogo.screenCenter();
        }
    }

    override function sectionHit()
    {
        super.sectionHit();

        if (curSection >= 54 && curSection <= 69) { //nice...
            coolCameraEffect(1.5, true);
            camGame.zoom += 0.05;
            camHUD.zoom += 0.05;
        }
    }

    override function stepHit() 
    {
        super.stepHit();

        if (curStep == 2) { //Adding a delay to the cutscene lets the game load the sprites. Would cause lag on transition if inserted in createPost
            gtRoom.alpha = 1;
            matpatIntro.alpha = 1;
        }

        if (curStep == 12) {
            matpatIntro.flipX = true;
        }

        if (curStep == 24) {
            matpatIntro.loadGraphic(Paths.image('daepicmatpatbuthap'));
            matpatIntro.flipX = false;
            matpatIntro.scale.set(1.5, 1.5);
            matpatIntro.updateHitbox();
            matpatIntro.screenCenter(X);
            
            gtRoom.scale.set(1.275, 1.275);
            gtRoom.updateHitbox();
            gtRoom.screenCenter();
        }

        if (curStep == 32) {
            matpatIntro.flipX = true;
            matpatIntro.scale.set(1.6, 1.6);
            matpatIntro.updateHitbox();
            matpatIntro.screenCenter(X);

            gtRoom.scale.set(1.325, 1.325);
            gtRoom.updateHitbox();
            gtRoom.screenCenter();
        }

        if (curStep == 37) {
            matpatIntro.flipX = false;
            matpatIntro.scale.set(1.7, 1.7);
            matpatIntro.updateHitbox();
            matpatIntro.screenCenter(X);

            gtRoom.scale.set(1.4, 1.4);
            gtRoom.updateHitbox();
            gtRoom.screenCenter();
        }

        if (curStep == 45) {
            matpatIntro.flipX = true;
            matpatIntro.scale.set(1.4, 1.4);
            matpatIntro.updateHitbox();
            matpatIntro.screenCenter(X);

            gtRoom.scale.set(1.2, 1.2);
            gtRoom.updateHitbox();
            gtRoom.screenCenter();
        }

        if (curStep == 64) {
            remove(gtRoom);
            remove(matpatIntro);
            camGame.flash(FlxColor.WHITE, 1.2);
            cameraSpeed = 1000;
        }

        if (curStep == 182) {
            defaultCamZoom = 1.2;
        }

        if (curStep == 192) {
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
            camGame.flash(FlxColor.WHITE, 1.2);
            cameraSpeed = 1;
        }

        if (curStep == 304) {
            defaultCamZoom = 1.2;
        }

        if (curStep == 320) {
            defaultCamZoom = 1;
            camGame.zoom = 1;

            camGame.zoom += 0.08;
            camHUD.zoom += 0.08;
            gtlogo.alpha = 1;
            redbg.alpha = 1;

            gtLogoAnim(false);
        }

        if (curStep == 324) {
            gtLogoAnim(true);
        }

        if (curStep == 328) {
            gtLogoAnim(false);
        }

        if (curStep == 330) {
            gtLogoAnim(true);
        }

        if (curStep == 334) {
            gtLogoAnim(false);
        }

        if (curStep == 336) {
            camHUD.fade(FlxColor.BLACK, (Conductor.crochet / 1000) * 4, false, true);
            FlxTween.tween(gtlogo, {angle: 360, x: -gtlogo.width}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) {
                remove(gtlogo);
                remove(redbg);
            }});
            FlxTween.tween(gtlogo, {x: -gtlogo.width}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.quadIn});
            FlxTween.tween(camGame, {zoom: 5}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.expoIn});
            strumBye();
        }

        if (curStep == 352) {
            FlxTween.cancelTweensOf(camGame);
            defaultCamZoom = 1;
            camGame.zoom = 1;
            camHUD.fade(FlxColor.BLACK, 0, true, true);
            camGame.fade(FlxColor.BLACK, (Conductor.crochet / 1000) * 64, true, true);
            camHUD.visible = false;
            cameraSpeed = 1000;
        }

        if (curStep == 464) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 480) {
            strumHello();
            defaultCamZoom = 1;
            camGame.zoom = 1;
            camGame.flash(FlxColor.WHITE, 1.2);
            camHUD.visible = true;
        }

        if (curStep == 592) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 608) {
            defaultCamZoom = 0.8;
            camGame.zoom = 0.8;
        }

        if (curStep == 854) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 856) {
            defaultCamZoom = 0.9;
        }

        if (curStep == 1368) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 1376) {
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
            camGame.flash(FlxColor.WHITE, 1.2);
        }

        if (curStep == 1494) {
            defaultCamZoom = 1.2;
        }
        
        if (curStep == 1504) {
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
        }

        if (curStep == 1616) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 1632) {
            defaultCamZoom = 0.8;
            camGame.zoom = 0.8;
        }

        if (curStep == 1878) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 1888) {
            defaultCamZoom = 0.8;
            camGame.zoom = 0.8;
        }

        if (curStep == 2016) {
            camGame.zoom += 0.02;
            camHUD.zoom += 0.02;
            camGame.flash(FlxColor.WHITE, 1.2);
            defaultCamZoom = 1;
            camGame.zoom = 1;
        }

        if (curStep == 2202) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 2208) {
            defaultCamZoom = 0.8;
            camGame.zoom = 0.8;
            camGame.flash(FlxColor.WHITE, 1.2);
        }

        if (curStep == 2454) {
            defaultCamZoom = 1.3;
            camGame.zoom = 1.3;
        }

        if (curStep == 2464) {
            defaultCamZoom = 0.8;
            camGame.zoom = 0.8;
            camGame.flash(FlxColor.WHITE, 1.2);
        }

        if (curStep == 2712) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 2720) {
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
            camGame.flash(FlxColor.WHITE, 1.2);
        }

        if (curStep == 2838) {
            defaultCamZoom = 1.2;
        }

        if (curStep == 2848) {
            defaultCamZoom = 0.9;
            camGame.zoom = 0.9;
            camGame.flash(FlxColor.WHITE, 1.2);
        }

        if (curStep == 2960) {
            defaultCamZoom = 1.2;
            camGame.zoom = 1.2;
        }

        if (curStep == 2976) {
            defaultCamZoom = 0.8;
            camGame.zoom = 0.8;
            camGame.zoom += 0.04;
            camHUD.zoom += 0.04;

            PlayState.instance.camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
            PlayState.instance.camFollow.x += gf.cameraPosition[0] + PlayState.instance.girlfriendCameraOffset[0];
            PlayState.instance.camFollow.y += gf.cameraPosition[1] + PlayState.instance.girlfriendCameraOffset[1];

            cameraSpeed = 0;
        }

        if (curStep == 2992) {
            camGame.visible = false;
            camHUD.visible = false;
        }
    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) 
    {
        if (eventName == "Add Camera Zoom" && flValue1 == 0.04 && flValue2 == 0.03) {
            coolCameraEffect(1.5, true);
        }
        super.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime);
    }

    var mult:Int = 1;
    private function coolCameraEffect(power:Float, zoom:Bool)
    {
        FlxTween.cancelTweensOf(camGame, ['angle']);
        FlxTween.cancelTweensOf(camHUD, ['angle']);

        camGame.angle = (power * mult);
        camHUD.angle = (power * -mult);

        if (zoom)
        {
            camGame.zoom += (power / 10);
            camHUD.zoom += (power / 10) / 2;
        }

        FlxTween.tween(camGame, {angle: 0}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
        FlxTween.tween(camHUD, {angle: 0}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
        mult = -mult;
    }

    private function gtLogoAnim(reverse:Bool)
    {
        gtlogo.angle = reverse ? -15 : 15;
        camGame.zoom += 0.025;
        camHUD.zoom += 0.025;
        gtlogo.scale.set(0.4, 0.4);
        gtlogo.updateHitbox();
        gtlogo.screenCenter();
    }

    function strumBye()
    {
        for (i in 0...8)
        {
            var curNote = PlayState.instance.strumLineNotes.members[i % PlayState.instance.strumLineNotes.length];
            if (i < 4) {
                FlxTween.tween(curNote, {angle: -360, x: -curNote.width}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadIn});
            } else {
                FlxTween.tween(curNote, {angle: 360, x: curNote.width + FlxG.width}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadIn});
            }
        }
    }

    function strumHello()
    {
        for (i in 0...8)
        {
            var curNote = PlayState.instance.strumLineNotes.members[i % PlayState.instance.strumLineNotes.length];
            if (i < 4) {
                FlxTween.tween(curNote, {angle: 0, x: defaultOpponentStrumX[i]}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            } else {
                FlxTween.tween(curNote, {angle: 0, x: defaultPlayerStrumX[i-4]}, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.quadOut});
            }
        }
    }
}