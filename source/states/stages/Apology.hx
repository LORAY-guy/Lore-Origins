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
    
        if (curStep == 2) {
            showSprites();
        } else if (curStep == 12) {
            matpatIntro.flipX = true;
        } else if (curStep == 24 || curStep == 32 || curStep == 37 || curStep == 45) {
            scaleSprites();
        } else if (curStep == 64) {
            cleanUpScene();
        } else if (curStep == 182 || curStep == 304 || curStep == 464 || curStep == 592 || curStep == 854 || curStep == 1368 || curStep == 1878 || curStep == 2202 || curStep == 2454) {
            zoomCamera(1.2);
        } else if (curStep == 192 || curStep == 480 || curStep == 1376 || curStep == 1504 || curStep == 2016 || curStep == 2720 || curStep == 2848) {
            zoomFlash(0.9, 1.2, 1.0);
        } else if (curStep == 856 || curStep == 1632 || curStep == 1888 || curStep == 2208 || curStep == 2464 || curStep == 2976) {
            zoomFlash(0.8, 1.2);
        } else if (curStep == 330 || curStep == 334) {
            gtLogoAnimToggle();
        } else if (curStep == 336) {
            fadeAndTween();
        } else if (curStep == 352) {
            cancelTweensAndFade();
        } else if (curStep == 1616 || curStep == 2838 || curStep == 2960) {
            zoomCamera(1.2);
        } else if (curStep == 2992) {
            hideCameras();
        }
    }
    
    private function showSprites() 
    {
        gtRoom.alpha = 1;
        matpatIntro.alpha = 1;
    }
    
    private function scaleSprites() 
    {
        var scales = [1.5, 1.6, 1.7, 1.4];
        var roomScales = [1.275, 1.325, 1.4, 1.2];
        var index = curStep == 24 ? 0 : curStep == 32 ? 1 : curStep == 37 ? 2 : 3;
        
        matpatIntro.scale.set(scales[index], scales[index]);
        matpatIntro.updateHitbox();
        matpatIntro.screenCenter(X);
        
        gtRoom.scale.set(roomScales[index], roomScales[index]);
        gtRoom.updateHitbox();
        gtRoom.screenCenter();
    }
    
    private function cleanUpScene() 
    {
        remove(gtRoom);
        remove(matpatIntro);
        camGame.flash(FlxColor.WHITE, 1.2);
        cameraSpeed = 1000;
    }
    
    private function zoomCamera(zoomValue:Float) 
    {
        defaultCamZoom = zoomValue;
        camGame.zoom = zoomValue;
    }
    
    private function zoomFlash(newZoom:Float, flashDuration:Float, initialZoom:Float = 0) 
    {
        defaultCamZoom = newZoom;
        camGame.zoom = newZoom;
        camGame.flash(FlxColor.WHITE, flashDuration);
        if (initialZoom != 0) {
            camHUD.zoom = initialZoom;
        }
    }
    
    private function gtLogoAnimToggle() {
        gtLogoAnim(curStep == 330 || curStep == 336);
    }
    
    private function fadeAndTween() 
    {
        camHUD.fade(FlxColor.BLACK, (Conductor.crochet / 1000) * 4, false, true);
        FlxTween.tween(gtlogo, {angle: 360, x: -gtlogo.width}, (Conductor.crochet / 1000) * 4, {
            ease: FlxEase.quadIn,
            onComplete: function(twn:FlxTween) {
                remove(gtlogo);
                remove(redbg);
            }
        });
        FlxTween.tween(camGame, {zoom: 5}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.expoIn});
        strumBye();
    }
    
    private function cancelTweensAndFade() 
    {
        FlxTween.cancelTweensOf(camGame);
        defaultCamZoom = 1;
        camGame.zoom = 1;
        camHUD.fade(FlxColor.BLACK, 0, true, true);
        camGame.fade(FlxColor.BLACK, (Conductor.crochet / 1000) * 64, true, true);
        camHUD.visible = false;
        cameraSpeed = 1000;
    }
    
    private function hideCameras() 
    {
        camGame.visible = false;
        camHUD.visible = false;
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