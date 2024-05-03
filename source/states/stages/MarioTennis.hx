package states.stages;

class MarioTennis extends BaseStage {
    var bg:BGSprite;
    var crowd:BGSprite;

    override function create() {
        bg = new BGSprite('mario', -640, -200, 1, 1);
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        bg.updateHitbox();
        add(bg);

        super.create();
    }

    override function createPost() 
    {
        if (!ClientPrefs.data.lowQuality)
        {
            crowd = new BGSprite('fever/crowd', -645, 475, 1, 1);
            crowd.setGraphicSize(Std.int(crowd.width * 1.2));
            crowd.updateHitbox();
            add(crowd);
        }

        super.createPost();
    }
    
    override function beatHit() {
        super.beatHit();
        
        if (!ClientPrefs.data.lowQuality)
        {
            crowd.y = crowd.y + 20;
            FlxTween.tween(crowd, {y: crowd.y - 20}, 0.15, {ease: FlxEase.cubeOut});
        }
    }

    override function sectionHit() {
        super.sectionHit();

        if ((curSection >= 96 && curSection <= 118) && curSection % 2 == 0)
            camHUD.shake(0.002, (Std.int(Conductor.crochet) / 1000) * 4);
    }

    override function stepHit() {
        switch (curStep) {
            case 128, 256, 384, 512, 640, 768, 896, 1024, 1152, 1280, 1408, 1536, 1664, 1792, 1920, 2176, 2304, 2432, 2560:
                camGame.flash(FlxColor.WHITE, 1.2);
                switch (curStep) {
                    case 256, 768, 1280:
                        cameraSpeed = 1.75;
                        defaultCamZoom = 0.75;
                    case 512, 1536, 2176:
                        defaultCamZoom = (curStep == 1536) ? 1.1 : 0.85;
                        cameraSpeed = (curStep == 1536) ? Std.int((Conductor.crochet / 1000) * 32) : 1000;
                    case 1024:
                        cameraSpeed = 1.75;
                        defaultCamZoom = 0.85;
                    case 1920:
                        defaultCamZoom = 0.75;
                        cameraSpeed = 0.75;
                    case 2432:
                        camGame.zoom = 0.85;
                        defaultCamZoom = 0.85;
                        cameraSpeed = 1000;
                }
            case 240, 760, 1016, 1264, 2416, 2672:
                cameraSpeed = 1000;
                camGame.zoom = 1;
                defaultCamZoom = 1;
            case 1660:
                lockCam(true);
            case 1668:
                lockCam();
                cameraSpeed = 1.75;
                camGame.zoom = 0.85;
                defaultCamZoom = 0.85;
            case 1904:
                defaultCamZoom = 0.8;
                camGame.zoom = 0.8;
                cameraSpeed = 1000;
            case 2688:
                camGame.zoom = 0.75;
                defaultCamZoom = 0.75;
                camOther.flash(FlxColor.WHITE, 1.2);
            case 2696:
                camHUD.visible = false;
                camGame.visible = false;
        }
        
        super.stepHit();
    }
}