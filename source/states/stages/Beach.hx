package states.stages;

class Beach extends BaseStage 
{
    var beach:BGSprite;
    var stool:BGSprite;

    var thanksText:FlxText;
    var tutorialTxt:FlxText;
    public static var tauntPlayer:FlxSprite;
    public static var tauntMatpat:FlxSprite;

    public static var animationsListPlayer:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP-alt'];
    public static var animationsList:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

    public static var matpatTaunt:Bool = false;
    public static var bonus:Int = 100;
    public static var firstSpace:Bool = false;
    public static var cooldown:Bool = false;
    public static var brubMoment:Bool = true;

    var botplaySine:Float = 0;

    override function create() {
        beach = new BGSprite('beach', 400, 125, 1, 1);
        beach.setGraphicSize(Std.int(beach.width * 0.3));
        beach.updateHitbox();
        add(beach);

        stool = new BGSprite('stool', 1020, 680, 1, 1);
        stool.setGraphicSize(Std.int(beach.width * 0.15));
        stool.updateHitbox();
        add(stool);

        thanksText = new FlxText(0, 0, 0, 'Thanks for playing!', 72);
        thanksText.setFormat(Paths.font('ourple.ttf'), 72, FlxColor.GREEN);
        thanksText.visible = false;
        thanksText.cameras = [camOther];
        thanksText.screenCenter(XY);
        add(thanksText);

        tauntPlayer = new FlxSprite(1190, 520);
        tauntPlayer.frames = Paths.getSparrowAtlas('taunt');
        tauntPlayer.animation.addByPrefix('taunt', 'Taunt', 60, false);
        tauntPlayer.setGraphicSize(Std.int(tauntPlayer.width * 3.75));
        tauntPlayer.visible = false;
        tauntPlayer.antialiasing = false;
        insert(3, tauntPlayer);

        tauntMatpat = new FlxSprite(780, 490);
        tauntMatpat.frames = Paths.getSparrowAtlas('taunt');
        tauntMatpat.animation.addByPrefix('taunt', 'Taunt', 60, false);
        tauntMatpat.setGraphicSize(Std.int(tauntMatpat.width * 3.75));
        tauntMatpat.visible = false;
        tauntMatpat.antialiasing = false;
        insert(3, tauntMatpat);

        tutorialTxt = new FlxText(990, 650, 250, 'Press \'SPACE\' to taunt', 26);
        tutorialTxt.setFormat(Paths.font('ourple.ttf'), 26, 0xFF3fe780);
        tutorialTxt.visible = false;
        tutorialTxt.cameras = [camOther];
        tutorialTxt.screenCenter(XY);
        add(tutorialTxt);
        
        resetVars();
        super.create();
    }

    override function createPost() 
    {
        if (ClientPrefs.getGameplaySetting('botplay')) {
            thanksText.text = 'Thanks for watching!';
            thanksText.screenCenter(XY);
        }
        PlayState.instance.gf.y = 450;
        PlayState.instance.gf.visible = false;

        super.createPost();
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (tutorialTxt != null) {
            botplaySine = botplaySine + 180 * elapsed;
            tutorialTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
        }

        if (firstSpace && tutorialTxt.alpha < 0.01) {
            tutorialTxt.destroy();
        }
    }

    override function stepHit() {
        super.stepHit();
        
        if (curStep == 3872) {
            brubMoment = false;
            thanksText.visible = true;
        }
    }

    override function beatHit() {
        super.beatHit();

        if (curBeat == 156 || curBeat == 158 || curBeat == 540 || curBeat == 542 || curBeat == 732 || curBeat == 734) doFunnyTaunt();
        
        if (curBeat % 2 == 0)
            bonus = 1000;
        else
            bonus = 100;
    }

    function doFunnyTaunt()
    {
        tauntMatpat.animation.play('taunt', true, false, 0);
        tauntMatpat.visible = true;
        PlayState.instance.dad.playAnim('sing' + animationsList[FlxG.random.int(0, animationsList.length-1)], true, false, 4);
        matpatTaunt = true;
        bonus += 1500;
        new FlxTimer().start(0.35, function(tmr:FlxTimer) {
            tauntMatpat.visible = false;
            matpatTaunt = false;
        });
    }

    public static function taunt()
    {
        if (firstSpace) firstSpace = true;
        cooldown = true;
        tauntPlayer.animation.play('taunt', true, false, 0);
        tauntPlayer.visible = true;
        new FlxTimer().start(0.35, function(tmr:FlxTimer) {
            tauntPlayer.visible = false;
            cooldown = false;
        });
        var randomAnimation:String = animationsListPlayer[FlxG.random.int(0, animationsListPlayer.length-1)];
        return randomAnimation;
    }

    function resetVars()
    {
        cooldown = false;
        firstSpace = false;
        brubMoment = true;
        matpatTaunt = false;
        bonus = 100;
    }
}