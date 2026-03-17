package states.stages;

import flixel.addons.display.FlxRuntimeShader;

class ErectStage extends BaseStage
{
    private var solid:FlxSprite;
    private var crowd:FlxSprite;
    private var brightLightSmall:FlxSprite;
    private var bg:FlxSprite;
    private var server:FlxSprite;
    private var lights:FlxSprite;
    private var orangeLight:FlxSprite;
    private var lightgreen:FlxSprite;
    private var lightred:FlxSprite;
    private var lightAbove:FlxSprite;

    private var resolution:Float = FlxG.width / 1280;

    override public function create()
    {
        solid = new FlxSprite(500, -1000).makeGraphic(4200, 2000, 0xFF222026);
        solid.scrollFactor.set(0, 0);
        solid.antialiasing = ClientPrefs.data.antialiasing;
        add(solid);

        crowd = new FlxSprite(682, 290);
        crowd.frames = Paths.getSparrowAtlas('erectStage/crowd');
        crowd.animation.addByPrefix('idle', 'idle0', 12, true);
        crowd.animation.play('idle');
        crowd.scrollFactor.set(0.8, 0.8);
        crowd.antialiasing = ClientPrefs.data.antialiasing;
        add(crowd);

        brightLightSmall = new FlxSprite(967, -103);
        brightLightSmall.loadGraphic(Paths.image('erectStage/brightLightSmall'), true, false);
        brightLightSmall.scrollFactor.set(1.2, 1.2);
        brightLightSmall.antialiasing = ClientPrefs.data.antialiasing;
        add(brightLightSmall);

        bg = new FlxSprite(-765, -247);
        bg.loadGraphic(Paths.image('erectStage/bg'), false, false);
        bg.scrollFactor.set(1, 1);
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

        server = new FlxSprite(-991, 205);
        server.loadGraphic(Paths.image('erectStage/server'), false, false);
        server.scrollFactor.set(1, 1);
        server.antialiasing = ClientPrefs.data.antialiasing;
        add(server);

        lights = new FlxSprite(-847, -245);
        lights.loadGraphic(Paths.image('erectStage/lights'), false, false);
        lights.scrollFactor.set(1.2, 1.2);
        lights.antialiasing = ClientPrefs.data.antialiasing;
        add(lights);

        orangeLight = new FlxSprite(189, -500);
        orangeLight.loadGraphic(Paths.image('erectStage/orangeLight'), false, false);
        orangeLight.scrollFactor.set(1, 1);
        orangeLight.scale.set(1, 1700);
        orangeLight.updateHitbox();
        orangeLight.antialiasing = ClientPrefs.data.antialiasing;
        add(orangeLight);

        lightgreen = new FlxSprite(-171, 242);
        lightgreen.loadGraphic(Paths.image('erectStage/lightgreen'), false, false);
        lightgreen.scrollFactor.set(1, 1);
        lightgreen.antialiasing = ClientPrefs.data.antialiasing;
        add(lightgreen);

        lightred = new FlxSprite(-101, 560);
        lightred.loadGraphic(Paths.image('erectStage/lightred'), false, false);
        lightred.scrollFactor.set(1, 1);
        lightred.antialiasing = ClientPrefs.data.antialiasing;
        add(lightred);

        super.create();
    }

    override public function createPost() 
    {
        lightAbove = new FlxSprite(804, -117);
        lightAbove.loadGraphic(Paths.image('erectStage/lightAbove'), false, false);
        lightAbove.scrollFactor.set(1, 1);
        add(lightAbove);

        if (resolution == 1) {
            camGame.zoom = defaultCamZoom = 0.72;
        }

        gf.idleSuffix = "-alt";
        gf.recalculateDanceIdle();

        #if (!flash && sys)
        applyAdjustColorShaders();
        #end

        super.createPost();
    }

    #if (!flash && sys)
    private function applyAdjustColorShaders():Void
    {
        if (!ClientPrefs.data.shaders) return;

        applyErectShaderToChar(boyfriend, 12, 0, 7, -23);
        applyErectShaderToChar(dad, -32, 0, -23, -33);
        //applyErectShaderToChar(gf, -9, 0, -4, -30); Does not look good on Phone Guy
    }
    
    private function applyErectShaderToChar(char:FlxSprite, hue:Float, saturation:Float, contrast:Float, brightness:Float):Void
    {
        if (char == null) return;

        var shader = new FlxRuntimeShader(Paths.getTextFromFile('shaders/adjustColor.frag'));
        
        shader.setFloat('hue', hue);
        shader.setFloat('saturation', saturation);
        shader.setFloat('contrast', contrast);
        shader.setFloat('brightness', brightness);

        char.shader = shader;
    }
    #end

    override public function stepHit()
    {
        super.stepHit();

        switch (curStep)
        {
            case 480:
                defaultCamZoom += 0.15;
            case 496:
                cameraSpeed = 1.5;
            case 512:
                camGame.flash(0xFFFFFFFF, 0.9);
                defaultCamZoom -= 0.15;
            case 624:
                defaultCamZoom += 0.15;
            case 640:
                defaultCamZoom -= 0.15;
            case 768:
                camGame.flash(0xFFFFFFFF, 0.9);
                defaultCamZoom += 0.1;
            case 880:
                defaultCamZoom += 0.1;
            case 896:
                camGame.flash(0xFFFFFFFF, 0.9);
                defaultCamZoom -= 0.1;
            case 1008:
                defaultCamZoom += 0.1;
            case 1024:
                if (resolution != 1) defaultCamZoom += 0.1;
                PlayState.instance.triggerEvent("Camera Follow Pos", "84", "504.5", Conductor.songPosition);
                fadePlayerArrows(0);
            case 1136:
                fadePlayerArrows(1);
            case 1152:
                PlayState.instance.triggerEvent("Camera Follow Pos", "850", "590", Conductor.songPosition);
                fadeOpponentArrows(0);
            case 1264:
                fadeOpponentArrows(1);
                if (resolution != 1) defaultCamZoom -= 0.1;
            case 1280:
                PlayState.instance.triggerEvent("Camera Follow Pos", "", "", Conductor.songPosition);
                defaultCamZoom -= 0.2;
                camGame.flash(0xFFFFFFFF, 0.9);
            case 1792:
                camGame.flash(0xFFFFFFFF, 0.9);
                cameraSpeed = 1;
            case 2288:
                defaultCamZoom += 0.15;
                cameraSpeed = 1.5;
            case 2304:
                camGame.flash(0xFFFFFFFF, 0.9);
                defaultCamZoom -= 0.15;
            case 2416:
                defaultCamZoom += 0.15;
            case 2432:
                defaultCamZoom -= 0.15;
            case 2544:
                defaultCamZoom += 0.15;
            case 2560:
                cameraSpeed = 1000;
                camGame.flash(0xFFFFFFFF, 0.9);
                gf.idleSuffix = "";
		        gf.recalculateDanceIdle();
                gf.dance();
                camGame.zoom -= 0.15;
                defaultCamZoom -= 0.15;
                FlxTween.tween(camGame, {zoom: camGame.zoom + 0.3}, (Conductor.crochet / 1000) * 60, {ease: FlxEase.sineInOut});
            case 2688:
                camGame.flash(0xFFFFFFFF, 0.9);
            case 2800:
                cameraSpeed = 1;
            case 3056:
                cameraSpeed = 1000;
                camGame.zoom += 0.2;
                defaultCamZoom += 0.2;
            case 3063:
                cameraSpeed = 1.5;
            case 3072:
                camGame.flash(0xFFFFFFFF, 0.9);
                defaultCamZoom -= 0.2;
            case 3176:
                cameraSpeed = 1000;
            case 3184:
                PlayState.instance.triggerEvent("Camera Follow Pos", "84", "504.5", Conductor.songPosition);
                defaultCamZoom += 0.15;
                camGame.zoom += 0.15;
            case 3200:
                PlayState.instance.triggerEvent("Camera Follow Pos", "", "", Conductor.songPosition);
                defaultCamZoom -= 0.15;
                cameraSpeed = 1.5;
            case 3328:
                camGame.flash(0xFFFFFFFF, 0.9);
                defaultCamZoom += 0.1;
            case 3568:
                defaultCamZoom += 0.1;
            case 3584:
                camGame.flash(0xFFFFFFFF, 0.9);
                cameraSpeed = 1000;
                defaultCamZoom -= 0.2;
                camGame.zoom -= 0.2;
            case 3600:
                cameraSpeed = 1;
            case 4064:
                defaultCamZoom += 0.15;
            case 4096:
                defaultCamZoom -= 0.15;
            case 4120:
                camGame.visible = false;
                camHUD.visible = false;
        }
    }

    private function fadePlayerArrows(alpha:Float):Void
    {
        PlayState.instance.playerStrums.forEach(function(strum:objects.StrumNote) {
            FlxTween.tween(strum, {alpha: alpha}, 1, {ease: FlxEase.linear});
        });
    }

    private function fadeOpponentArrows(alpha:Float):Void
    {
        PlayState.instance.opponentStrums.forEach(function(strum:objects.StrumNote) {
            FlxTween.tween(strum, {alpha: alpha}, 1, {ease: FlxEase.linear});
        });
    }
}