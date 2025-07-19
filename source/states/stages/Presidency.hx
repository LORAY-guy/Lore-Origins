package states.stages;

class Presidency extends BaseStage
{
    private var bg:BGSprite;
    private var lecturn:BGSprite;

    override public function create():Void
    {
        super.create();

        bg = new BGSprite('capitol', -4140, -3600);
        bg.scale.set(5, 5);
        bg.updateHitbox();
        add(bg);
    }

    override public function createPost():Void
    {
        super.createPost();

        lecturn = new BGSprite('lecturn', 450.3625, 450);
        lecturn.scale.set(0.325, 0.325);
        lecturn.updateHitbox();
        add(lecturn);

        dadGroup.x = (lecturn.x + (lecturn.width / 2)) + getOffsetFromMatpatSkin();
        camFollow.x = 641.5;
    }

    override public function songStart():Void
    {
        super.songStart();

        defaultCamZoom = camGame.zoom = 0.65;
        camGame.flash();
        cameraSpeed = 1000;
    }

    override public function stepHit():Void
    {
        super.stepHit();

        if (curStep == 128)
            camGame.flash();

        if (curStep == 240)
            defaultCamZoom = camGame.zoom = 0.75;

        if (curStep == 256 || curStep == 576) {
            camGame.flash();
            cameraSpeed = 2;
            defaultCamZoom = 0.6;
        }

        if (curStep == 512 || curStep == 544) {
            cameraSpeed = 1000;
            defaultCamZoom = camGame.zoom = 0.65;
        }

        if (curStep == 528 || curStep == 534 || curStep == 540 || curStep == 560 || curStep == 566 || curStep == 572) {
            defaultCamZoom += 0.05;
            camGame.zoom += 0.05;
        }

        if (curStep == 752) {
            cameraSpeed = 1000;
            defaultCamZoom = camGame.zoom = 0.7;
        }

        if (curStep == 768 || curStep == 896) {
            camGame.flash();
            defaultCamZoom = 0.55;
        }

        if (curStep == 768 || curStep == 800 || curStep == 832 || curStep == 864 || curStep == 928 || curStep == 960 || curStep == 992)
            defaultCamZoom = 0.55;

        if (curStep == 784 || curStep == 816 || curStep == 848 || curStep == 880 || curStep == 912 || curStep == 944 || curStep == 976 || curStep == 1008)
            defaultCamZoom = camGame.zoom = 0.6;

        if (curStep == 790 || curStep == 796 || curStep == 822 || curStep == 828 || curStep == 854 || curStep == 860 || curStep == 886 || curStep == 892 || curStep == 916 || curStep == 920 || curStep == 924 || curStep == 980 || curStep == 984 || curStep == 988) {
            defaultCamZoom += 0.025;
            camGame.zoom += 0.025;
        }

        if (curStep == 1024) {
            camGame.flash();
            FlxTween.tween(boyfriend, {x: boyfriend.x + getOurpleWhisperingPosOffset()}, 0.4, {ease: FlxEase.smootherStepOut});
            isCameraOnForcedPos = true;
            PlayState.instance.triggerEvent("Camera Follow Pos", Std.string(camFollow.x + getOurpleWhisperingPosOffset()), Std.string(camFollow.y), Conductor.songPosition);
            if (boyfriend.curCharacter == 'playguy-staring')
                boyfriend.defaultX += getOurpleWhisperingPosOffset();
            defaultCamZoom = camGame.zoom = 0.8;
            cameraSpeed = 3;
        }

        if (curStep == 1088) {
            isCameraOnForcedPos = false;
            PlayState.instance.triggerEvent("Camera Follow Pos", "", "", Conductor.songPosition);
        }

        if (curStep == 1136)
            defaultCamZoom = camGame.zoom = 0.85;

        if (curStep == 1152) {
            camGame.flash();
            defaultCamZoom = 0.5;
        }

        if (curStep == 1264 || curStep == 1268 || curStep == 1272 || curStep == 1276) {
            defaultCamZoom += 0.025;
            camGame.zoom += 0.025;
        }

        if (curStep == 1280) {
            camGame.flash();
            defaultCamZoom = camGame.zoom = 0.5;
            cameraSpeed = 1000;
            camZooming = false;
            isCameraOnForcedPos = true;
            PlayState.instance.triggerEvent("Camera Follow Pos", "1094.5", "559.5", Conductor.songPosition);
            FlxTween.tween(camGame, {zoom: 0.7}, (Conductor.stepCrochet / 1000) * 96, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
                defaultCamZoom = camGame.zoom;
            }});
        }

        if (curStep == 1376 || curStep == 1382 || curStep == 1388) {
            defaultCamZoom += 0.025;
            camGame.zoom += 0.025;
        }

        if (curStep == 1392) {
            isCameraOnForcedPos = false;
            PlayState.instance.triggerEvent("Camera Follow Pos", "", "", Conductor.songPosition);
            defaultCamZoom = camGame.zoom = 0.75;
        }

        if (curStep == 1408) {
            camGame.flash();
            cameraSpeed = 2;
            defaultCamZoom = camGame.zoom = 0.6;
            FlxTween.tween(boyfriend, {x: boyfriend.x - getOurpleWhisperingPosOffset()}, 0.4, {ease: FlxEase.smootherStepOut});
            if (boyfriend.curCharacter == 'playguy-staring')
                boyfriend.defaultX -= getOurpleWhisperingPosOffset();
            camZooming = true;
        }

        if (curStep == 1648) {
            cameraSpeed = 1000;
            defaultCamZoom = camGame.zoom = 0.7;
        }

        if (curStep == 1664) {
            camGame.flash();
            defaultCamZoom = camGame.zoom = 0.5;
            isCameraOnForcedPos = true;
            PlayState.instance.triggerEvent("Camera Follow Pos", "75", "511.5", Conductor.songPosition);
            FlxTween.tween(camGame, {zoom: 0.7}, (Conductor.stepCrochet / 1000) * 128, {ease: FlxEase.linear});
            camZooming = false;
        }

        if (curStep == 1792) {
            camGame.flash();
            cameraSpeed = 2;
            PlayState.instance.triggerEvent("Camera Follow Pos", "", "", Conductor.songPosition);
            isCameraOnForcedPos = false;
            camZooming = true;
            defaultCamZoom = camGame.zoom = 0.6;
        }

        if (curStep == 1920) {
            camGame.flash();
            camZooming = true;
            cameraSpeed = 1000;
            defaultCamZoom = 0.6;
        }

        if (curStep == 2032) {
            isCameraOnForcedPos = true;
            PlayState.instance.triggerEvent("Camera Follow Pos", "75", "511.5", Conductor.songPosition);
            defaultCamZoom = camGame.zoom = 0.75;
        }

        if (curStep == 2048) {
            isCameraOnForcedPos = false;
            PlayState.instance.triggerEvent("Camera Follow Pos", "", "", Conductor.songPosition);
        }

        if (curStep == 2048 || curStep == 2080 || curStep == 2112 || curStep == 2144 || curStep == 2176 || curStep == 2208 || curStep == 2240 || curStep == 2272) {
            camGame.flash();
            defaultCamZoom = camGame.zoom = 0.6;
        }

        if (curStep == 2064 || curStep == 2096 || curStep == 2128 || curStep == 2160 || curStep == 2192 || curStep == 2224 || curStep == 2256 || curStep == 2288)
            defaultCamZoom = camGame.zoom = (!PlayState.SONG.notes[curSection].mustHitSection) ? 0.65 : 0.8;
    
        if (curStep == 2101 || curStep == 2108)
            defaultCamZoom = camGame.zoom = 0.65;

        if (curStep == 2304) {
            camGame.flash();
            defaultCamZoom = camGame.zoom = 0.8;
        }

        if (curStep == 2432) {
            camGame.flash();
            defaultCamZoom = camGame.zoom = 0.7;
        }

        if (curStep == 2560) {
            camGame.flash();
            defaultCamZoom = camGame.zoom = 0.6;
        }

        if (curStep == 2624)
            defaultCamZoom = 0.65;

        if (curStep == 2688) {
            camGame.flash();
            defaultCamZoom = camGame.zoom = 0.6;
            cameraSpeed = 2;
        }

        if (curStep == 2752)
            cameraSpeed = 1000;

        if (curStep == 2784)
            defaultCamZoom = camGame.zoom = 0.7;

        if (curStep == 2800)
            defaultCamZoom = camGame.zoom = 0.8;

        if (curStep == 2824)
            camGame.visible = camHUD.visible = false;
    }

    private var stepCheck:Int = 0;
    override public function opponentNoteHit(id:Int, direction:Int, noteType:String, isSustainNote:Bool):Void
    {
        super.opponentNoteHit(id, direction, noteType, isSustainNote);

        if (curSection == 119) {
            PlayState.instance.triggerEvent("Add Camera Zoom", "0.005", "0.01", Conductor.songPosition);
            defaultCamZoom += 0.005; 
        }

        if ((curSection == 129 || curSection == 131 || curSection == 137 || curSection == 139) && stepCheck != curStep) {
            stepCheck = curStep;
            defaultCamZoom += 0.025;
            camGame.zoom += 0.025;
        }
    }

    private function getOffsetFromMatpatSkin():Float
    {
        switch (dad.curCharacter) {
            case 'matpat-png':
                return -247;
            case 'matpat-faf':
                return -240;
            case 'matpat-sunk', 'matpat-sunk mad':
                return -287.5;
            default:
                return -280;
        }
    }

    private function getOurpleWhisperingPosOffset():Float // They bit the second child...
    {
        switch (boyfriend.curCharacter) {
            case 'playguy-staring':
                return -40;
            case 'playguy-afton':
                return -30;
            default:
                return -160;
        }
    }
}