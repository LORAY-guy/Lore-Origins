package states.stages;

class Sad extends BaseStage 
{
    public static var allowCountdown:Bool = false;
    public static var firstOpening:Dynamic = false;
    public static var blocked:Bool = false;

    var remainingTheories:String = "";

    var botplaySine:Dynamic = 0;

    var wall:BGSprite;
    var floor:BGSprite;
    public static var spotlightMatpat:BGSprite;
    var spotlightOurpleGuy:BGSprite;
    var spotlightPhoneGuy:BGSprite;
    var curtains:BGSprite;
    
    var darkStuff:FlxSprite;
    public static var blackIntro:FlxSprite;

    var timerBar:FlxSprite;
    var countdown:FlxText;

    public static var sadStuff:FlxTypedGroup<Dynamic>;

    var tutorialTxt:FlxText;

    override function create() 
    {
        wall = new BGSprite('lore/wall', -320, 0, 1, 1);
        wall.setGraphicSize(Std.int(wall.width * 1.3));
        wall.updateHitbox();
        add(wall);

        floor = new BGSprite('lore/floor', -350, 950, 1, 1);
        floor.setGraphicSize(Std.int(floor.width * 1.3));
        floor.updateHitbox();
        add(floor);

        darkStuff = new FlxSprite().makeGraphic(2500, 2500, FlxColor.BLACK);
        darkStuff.alpha = 0.9;
        add(darkStuff);

        spotlightMatpat = new BGSprite('spotlight', 640, 240, 1, 1);
        spotlightMatpat.blend = ADD;
        spotlightMatpat.alpha = 0.45;
        spotlightMatpat.visible = false;
        insert(3, spotlightMatpat);

        spotlightOurpleGuy = new BGSprite('spotlight', 1370, 240, 1, 1);
        spotlightOurpleGuy.blend = ADD;
        spotlightOurpleGuy.alpha = 0.45;
        spotlightOurpleGuy.visible = false;
        insert(5, spotlightOurpleGuy);

        spotlightPhoneGuy = new BGSprite('spotlight', 1005, 160, 1, 1);
        spotlightPhoneGuy.blend = ADD;
        spotlightPhoneGuy.alpha = 0.45;
        spotlightPhoneGuy.visible = false;
        insert(6, spotlightPhoneGuy);

        blackIntro = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        blackIntro.screenCenter(XY);
        blackIntro.cameras = [camOther];
        add(blackIntro);

        tutorialTxt = new FlxText(10, (ClientPrefs.data.downScroll) ? 110 : 640, 300, 'Press \'TAB\' to open the countdown', 26);
        tutorialTxt.setFormat(Paths.font('matpat-timer.ttf'), 26, FlxColor.GREEN, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        tutorialTxt.cameras = [camHUD];
        add(tutorialTxt);

        sadStuff = new FlxTypedGroup<Dynamic>();
        sadStuff.cameras = [camHUD];
		add(sadStuff);

        resetVars();
        super.create();
    }

    override function createPost() 
    {
        if (!ClientPrefs.data.lowQuality) {
            curtains = new BGSprite("lore/curtain", -75, 135, 1.2, 1.2);
            curtains.setGraphicSize(Std.int(curtains.width * 1.2));
            curtains.updateHitbox();
            FlxTween.color(curtains, 0.01, curtains.color, FlxColor.fromRGB(44, 44, 44));
            add(curtains);
        }

        var currentDate = Date.now();
        var targetDate = new Date(2024, 2, 9, 0, 0, 0);
        var remainingTime = (targetDate.getTime() - currentDate.getTime()) / (1000 * 60 * 60 * 24);
        var weeksRemaining = Std.int(remainingTime / 7);
        
        var remainingTheories:String;
        if (remainingTime < 0) {
            remainingTheories = "FAREWELL, MATPAT!";
        } else {
            remainingTheories = "- " + weeksRemaining + " THEORIES REMAIN -";
        }

        timerBar = new FlxSprite(0, 420).makeGraphic(1280, 120); //hehe... 420...
        timerBar.screenCenter(X);
        timerBar.alpha = 0;
        sadStuff.add(timerBar);

        countdown = new FlxText(0, (!ClientPrefs.data.downScroll) ? 437 : 45, 1280, remainingTheories, 68);
        countdown.setFormat(Paths.font('matpat-timer.ttf'), 68, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        countdown.borderSize = 1;
        countdown.alpha = 0;
        countdown.screenCenter(X);
        sadStuff.add(countdown);

        super.createPost();
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (tutorialTxt != null) {
            botplaySine += 180 * elapsed;
            tutorialTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);	
        } else if (botplaySine != null) {
            botplaySine = null;
        }

        if (firstOpening && tutorialTxt.alpha < 0.01) {
            tutorialTxt.destroy();
            firstOpening = null;
        }
    }

    override function stepHit()
    {
        switch (curStep) 
        {
            case 66:
                spotlightOurpleGuy.visible = true;
            
            case 2036:
                spotlightPhoneGuy.visible = true;
        }
    }

    public static function updatePost(elapsed:Float)
    {
        if (FlxG.keys.justPressed.TAB && !blocked) {
            blocked = true;

            for (i in 0...sadStuff.length)
            {
                var targetAlpha:Int = (sadStuff.members[i].alpha == 0) ? 1 : 0;
                FlxTween.tween(sadStuff.members[i], {alpha: targetAlpha}, 0.5, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
                    blocked = false;
                }});
            }

            if (!firstOpening) firstOpening = true;
        }
    }

    public static function resetVars() //Fix GameOver not resetting the current variables
    {
        allowCountdown = false;
        firstOpening = false;
        blocked = false;
    }

    override function sectionHit() {
        super.sectionHit();

        if ((boyfriend.curCharacter.startsWith('playguy')) && (curSection >= 112 && curSection <= 126) && curSection % 2 == 0)
            camHUD.shake(0.002, (Std.int(Conductor.crochet) / 1000) * 4);
    }
}