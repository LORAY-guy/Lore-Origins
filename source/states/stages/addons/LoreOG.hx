package states.stages.addons;

class LoreOG extends BaseStage
{
    var black:FlxSprite;

    override function create() 
    {
        black = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        black.cameras = [camHUD];
        black.visible = false;
        add(black);

        super.create();
    }

    override function createPost() 
    {
        camGame.alpha = 0.001;
        super.createPost();
    }

    override function stepHit() {
        switch (curStep)
        {
            case 132, 1668, 2948:
                camGame.zoom = 1.3;
                defaultCamZoom = 1.3;
                lockCam(false);

            case 138, 1680, 2960:
                lockCam();
            
            case 242, 246, 250, 252, 254, 1076, 1078, 1080, 1082, 1084, 1086, 1088, 1204, 1206, 1208, 1210, 1212, 1214:
                camGame.zoom += 0.05;
                camHUD.zoom += 0.03;

            case 368, 1904, 2296:
                defaultCamZoom = 1.2;

            case 384, 1920, 2432:
                defaultCamZoom = 0.75;
                camGame.zoom = 0.75;
                if (curStep == 2432) cameraSpeed = 1000;

            case 256, 1792:
                PlayState.instance.triggerEvent('Change Scroll Speed', '1.05', '0.25', Conductor.songPosition);
                defaultCamZoom = 0.75;

            case 512:
                cameraSpeed = 1;
                defaultCamZoom = 0.9;
                PlayState.instance.triggerEvent('Change Scroll Speed', '1.025', '0.25', Conductor.songPosition);
        
            case 608, 614, 620, 736, 742, 748:
                camGame.zoom += 0.05;
                camHUD.zoom += 0.10;

            case 624, 626, 628:
                camGame.zoom += 0.02;
                camHUD.zoom += 0.02;

            case 912, 914, 916:
                camGame.zoom += 0.10;
                camHUD.zoom += 0.10;

            case 1536:
                camGame.zoom = 1.1;
				defaultCamZoom = 1.1;
                cameraSpeed = 1000;
                PlayState.instance.triggerEvent('Change Scroll Speed', '1', '0.25', Conductor.songPosition);

            case 2048:
                black.visible = true;
                FlxTween.tween(black, {alpha: 0}, 8, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
                    black.destroy();
                }});
                cameraSpeed = 1;

            case 2416:
                defaultCamZoom = 1;
            
            case 2816:
                defaultCamZoom = 1.1;
                camGame.zoom = 1.1;

            case 3072:
                camGame.zoom = 0.75;
                defaultCamZoom = 0.75;

            case 3096:
                camGame.visible = false;
                camHUD.visible = false;
        }

        super.stepHit();
    }

    override function beatHit() {
        if ((curBeat <= 64 || curBeat >= 384 && curBeat <= 448 || curBeat >= 704) && curBeat % 2 == 0) {
            camGame.zoom += 0.02;
            camHUD.zoom += 0.02;
        }
    
        if (curBeat >= 64 && curBeat <= 92 || curBeat >= 96 && curBeat <= 128 || curBeat >= 192 && curBeat <= 256 || curBeat >= 448 && curBeat <= 476 || curBeat >= 480 && curBeat <= 512 || curBeat >= 576 && curBeat <= 604 || curBeat >= 608 && curBeat <= 704) {
            camGame.zoom += 0.05;
            camHUD.zoom += 0.03;
        }
    
        if (curBeat >= 128 && curBeat <= 152 || curBeat >= 160 && curBeat <= 192 || curBeat >= 256 && curBeat <= 326) {
            camGame.zoom += 0.03;
            camHUD.zoom += 0.02;
        }
        
        super.beatHit();
    }
}