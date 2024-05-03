package states.stages.addons;

class Repugnant extends BaseStage
{
    var cutsceneElts:FlxTypedGroup<FlxSprite>;
    var matSize:Float = 1.3;

    var redbg:FlxSprite;
    var gtlogo:FlxSprite;
    var fnaf2theory:FlxSprite;
    var gogogo:FlxSprite;
    var fnaf2:FlxSprite;
    var foxy:FlxSprite;
    var ourpleman:FlxSprite;
    var puppet:FlxSprite;
    var finger:FlxSprite;
    
    public static var matpat:FlxSprite;

    override function create() {
        if (!ClientPrefs.data.lowQuality)
        {
            cutsceneElts = new FlxTypedGroup<FlxSprite>();
            cutsceneElts.cameras = [camHUD];
            add(cutsceneElts);
    
            redbg = new FlxSprite().loadGraphic(Paths.image('gtbg'));
            redbg.scale.set((2/3), (2/3));
            redbg.updateHitbox();
            cutsceneElts.add(redbg);
            redbg.screenCenter(XY);
            redbg.visible = false;
    
            gtlogo = new FlxSprite().loadGraphic(Paths.image('gtLogo'));
            gtlogo.scale.set((1/3), (1/3));
            gtlogo.updateHitbox();
            cutsceneElts.add(gtlogo);
            gtlogo.screenCenter(XY);
            gtlogo.x = -FlxG.width - gtlogo.width;
            gtlogo.visible = false;
    
            fnaf2theory = new FlxSprite().loadGraphic(Paths.image('repugnant/fnaf2theory'));
            fnaf2theory.scale.set(0.475, 0.475);
            fnaf2theory.updateHitbox();
            cutsceneElts.add(fnaf2theory);
            fnaf2theory.screenCenter(XY);
            fnaf2theory.x = -FlxG.width - fnaf2theory.width;
            fnaf2theory.visible = false;
    
            gogogo = new FlxSprite().loadGraphic(Paths.image('repugnant/gogogo'));
            gogogo.scale.set((2/3), (2/3));
            gogogo.updateHitbox();
            cutsceneElts.add(gogogo);
            gogogo.screenCenter(XY);
            gogogo.antialiasing = false;
            gogogo.y = -FlxG.height - gogogo.height;
            gogogo.visible = false;
    
            fnaf2 = new FlxSprite().loadGraphic(Paths.image('repugnant/fnaf2'));
            cutsceneElts.add(fnaf2);
            fnaf2.screenCenter(XY);
            fnaf2.y = -FlxG.height - fnaf2.height;
            fnaf2.visible = false;
    
            foxy = new FlxSprite(0, 270).loadGraphic(Paths.image('repugnant/foxy'));
            cutsceneElts.add(foxy);
            foxy.scale.set(2.2, 2.2);
            foxy.updateHitbox();
            foxy.screenCenter(X);
            foxy.x = FlxG.width + foxy.width;
            foxy.antialiasing = false;
            foxy.visible = false;
    
            ourpleman = new FlxSprite(0, 200).loadGraphic(Paths.image('repugnant/ourpleman'));
            cutsceneElts.add(ourpleman);
            ourpleman.scale.set(2.6, 2.6);
            ourpleman.updateHitbox();
            ourpleman.screenCenter(X);
            ourpleman.x = -FlxG.width - ourpleman.width;
            ourpleman.antialiasing = false;
            ourpleman.visible = false;
    
            puppet = new FlxSprite(0, 140).loadGraphic(Paths.image('repugnant/puppet'));
            cutsceneElts.add(puppet);
            puppet.scale.set(1.2, 1.2);
            puppet.updateHitbox();
            puppet.screenCenter(X);
            puppet.x = FlxG.width + puppet.width;
            puppet.visible = false;
    
            finger = new FlxSprite(FlxG.width, FlxG.height).loadGraphic(Paths.image('finger'));
            cutsceneElts.add(finger);
            finger.scale.set(1.5, 1.5);
            finger.updateHitbox();
            finger.flipX = true;
            finger.antialiasing = false;
            finger.visible = false;
    
            matpat = new FlxSprite(0, 180).loadGraphic(Paths.image('daepicmatpat'));
            cutsceneElts.add(matpat);
            matpat.scale.set(1.3, 1.3);
            matpat.updateHitbox();
            matpat.screenCenter(X);
            matpat.x = -FlxG.width - matpat.width;
            matpat.visible = false;
        }

        super.create();
    }

    override function createPost() 
    {
        cameraSpeed = 1.75; //Default camSpeed for this song, putting it there to remember
        super.createPost();
    }

    override function sectionHit() 
    {
        if (ClientPrefs.data.lowQuality)
        {
            if ((curSection >= 96 && curSection <= 109) && curSection % 2 == 0)
                camHUD.shake(0.002, (Conductor.crochet / 1000) * 5);

            if (curSection == 110)
                camHUD.shake(0.002, (Conductor.crochet / 1000) * 2);
        }

        super.sectionHit();
    }

    override function stepHit() 
    {
        switch (curStep)
        {
            case 128, 1152:
                camGame.flash(FlxColor.WHITE, 1);

            case 240, 1264, 760:
                defaultCamZoom = 1.2;

            case 256, 1280:
                camGame.flash(FlxColor.WHITE, 1);
                cameraSpeed = 1.75;
                defaultCamZoom = 0.9;
                camGame.zoom = 0.9;

            case 512:
                camGame.flash(FlxColor.WHITE, 1);
                cameraSpeed = 1000;
                lockCam(true);

            case 574, 592, 704, 720, 1856, 1872, 1984, 2000:
                defaultCamZoom += 0.15;

            case 608, 736, 1888, 2016:
                defaultCamZoom -= 0.15;

            case 624:
                cameraSpeed = 1.75;

            case 640:
                camGame.flash(FlxColor.WHITE, 1);
                defaultCamZoom = 0.9;
                camGame.zoom = 0.9;
                lockCam(false);

            case 768:
                camGame.flash(FlxColor.WHITE, 1);
                defaultCamZoom = 0.9;
                lockCam();

            case 1024, 2304:
                camGame.flash(FlxColor.WHITE, 1);
                defaultCamZoom = 1;
                camGame.zoom = 1;
                cameraSpeed = 1000;

            case 1536:
                camGame.flash(FlxColor.WHITE, 1);
                if (ClientPrefs.data.lowQuality)
                    FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
                else
                    showGTLogo();

            case 1580:
                fnaf2theory.visible = true;
                FlxTween.tween(fnaf2theory, {x: 600}, 1, {ease: FlxEase.sineOut});
                FlxTween.tween(fnaf2theory, {angle: FlxG.random.int(15, 25)}, 1, {ease: FlxEase.sineInOut});

            case 1600:
                gogogo.visible = true;
                ourpleman.visible = true;
                FlxTween.tween(ourpleman, {x: 460}, 1, {ease: FlxEase.sineOut});
                FlxTween.tween(gogogo, {y: 0}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                    gtlogo.destroy();
                    redbg.destroy();
                }});

            case 1604:
                matpat.flipX = true;

            case 1622:
                foxy.visible = true;
                FlxTween.tween(foxy, {x: 900}, 0.5, {ease: FlxEase.sineOut});

            case 1640:
                FlxTween.tween(ourpleman.scale, {x: 3.2, y: 3.2}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(gogogo.scale, {x: 0.85, y: 0.85}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(ourpleman, {x: 650}, 0.5, {ease: FlxEase.sineOut});
                FlxTween.tween(foxy, {x: 1400}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                    foxy.destroy();
                }});

            case 1651:
                finger.visible = true;
                finger.angle = 11;
                FlxTween.tween(finger, {x: 847, y: 230}, 0.5, {ease: FlxEase.sineOut});

            case 1704:
                FlxTween.tween(finger, {y: 1000}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                    finger.destroy();
                }});
                fnaf2.visible = true;
                FlxTween.tween(fnaf2, {y: 0}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                    gogogo.destroy();
                }});
                FlxTween.tween(ourpleman.scale, {x: 2.6, y: 2.6}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(ourpleman, {x: 460}, 0.5, {ease: FlxEase.sineOut});

            case 1706:
                matpat.flipX = false;

            case 1712:
                puppet.visible = true;
                FlxTween.tween(puppet, {x: 840}, 1, {ease: FlxEase.sineOut});

            case 1745:
                matSize = 1.5;
                FlxTween.tween(matpat.scale, {x: 1.5, y: 1.5}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(matpat, {x: 385, y: 80}, 0.5, {ease: FlxEase.sineInOut});
                FlxTween.tween(puppet, {x: (FlxG.width + puppet.width)}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                    puppet.destroy();
                }});
                FlxTween.tween(ourpleman, {x: (-ourpleman.width)}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                    ourpleman.destroy();
                }});

            case 1760:
                defaultCamZoom = 1.2;
                camGame.zoom = 1.2;
                camGame.flash();
                cameraSpeed = 1000;
                matpat = null;
                cutsceneElts.destroy();

            case 1792:
                camGame.flash(FlxColor.WHITE, 1);
                defaultCamZoom = 0.9;
                camGame.zoom = 0.9;
                cameraSpeed = 1.75;

            case 2416:
                cameraSpeed = 3;
                defaultCamZoom = 1.1;

            case 2432:
                camGame.flash(FlxColor.WHITE, 1);
                defaultCamZoom = 0.9;

            case 2560:
                defaultCamZoom = 0.75;

            case 2568:
                camGame.visible = false;
                camHUD.visible = false;
                camOther.flash(FlxColor.WHITE, 1.2);
        }

        super.stepHit();
    }

    override function update(elapsed:Float) 
    {
        if (!ClientPrefs.data.lowQuality && matpat != null)
        {
            matpat.scale.set(FlxMath.lerp(matSize, matpat.scale.x, Math.exp(-elapsed * 7.5)), FlxMath.lerp(matSize, matpat.scale.y, Math.exp(-elapsed * 7.5)));
            matpat.updateHitbox();
        }

        super.update(elapsed);
    }

    function showGTLogo()
    {
        camHUD.flash(FlxColor.WHITE, 1.2);
        FlxTween.tween(gtlogo, {x: 363}, 2, {ease: FlxEase.cubeOut});
        FlxTween.tween(gtlogo, {angle: 360}, 2, {ease: FlxEase.cubeInOut});
        gtlogo.visible = true;
        redbg.visible = true;
        matpat.visible = true;
        FlxTween.tween(matpat, {x: 90}, 2, {ease: FlxEase.cubeOut, startDelay: 0.4});
    }
}