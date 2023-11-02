package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class ShaggersState extends MusicBeatState
{
    public static var appCats:Array<Array<String>> = [ // App Name, Scale, X Offset, Link
        ['Youtube', '0.45', '0',    'https://youtube.com/@Shaggers'],
        ['Twitter', '0.45', '45',   'https://twitter.com/Shaggers_real?t=G27exZKT-OxLIQGURFe3bA&s=09'], 
        ['Discord', '0.45', '0',    'https://discord.com/invite/JnsQV8az8C']
    ];
    private var grpCats:FlxTypedGroup<FlxSprite>;
    public var NameAlpha:Alphabet;
	var curSelected:Int = 0;
    var menuItems:FlxTypedGroup<FlxSprite>;
    var bg:FlxSprite;
    var categoryIcon:FlxSprite;

    var ourpleShaggersLeft:FlxSprite;
    var ourpleShaggersRight:FlxSprite;
    //var ourpleShaggersLeft:Character;
    //var ourpleShaggersRight:Character;
    var happyAnim:Bool = false;
    var flippedIdle:Bool = false;
    var originY:Int;

    override function create()
    {
        #if desktop
        // Updating Discord Rich Presence
        DiscordClient.changePresence("Shaggers UwU", null);
        #end

        persistentUpdate = true;
        bg = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
        add(bg);
        bg.screenCenter();

        var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0, 0);
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);

        menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...appCats.length)
        {
            var offset:Float = (Math.max(appCats.length, 4) - 4) * 75;
            var appItem:FlxSprite = new FlxSprite((i * 410 - (i * 5)) + offset, 0);
            var scaleItem:Float = Std.parseFloat(appCats[i][1]);
            appItem.x += 80 + Std.parseInt(appCats[i][2]);
            appItem.frames = Paths.getSparrowAtlas('shaggers/shaggers_' + appCats[i][0].toLowerCase());
			appItem.animation.addByPrefix('idle', appCats[i][0].toLowerCase(), 24);
			appItem.animation.play('idle');
            appItem.scale.x = scaleItem;
            appItem.scale.y = scaleItem;
            appItem.screenCenter(Y);
			appItem.ID = i;
			menuItems.add(appItem);
			var scr:Float = (appCats.length - 4) * 0.135;
			if(appCats.length < 6) scr = 0;
			appItem.scrollFactor.set(0, scr);
			appItem.antialiasing = ClientPrefs.globalAntialiasing;
			appItem.updateHitbox();
        }

        ourpleShaggersLeft = new FlxSprite(100, 260);
        ourpleShaggersLeft.frames = Paths.getSparrowAtlas('shaggers/OURPLE_SHAGGEEEEEEEEEERS');
        ourpleShaggersLeft.animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        ourpleShaggersLeft.animation.addByPrefix('happy', 'Up', 24, false, false, false);
        ourpleShaggersLeft.animation.play('idle', false, false, 0);
        add(ourpleShaggersLeft);

        ourpleShaggersRight = new FlxSprite(885, 260);
        ourpleShaggersRight.frames = Paths.getSparrowAtlas('shaggers/OURPLE_SHAGGEEEEEEEEEERS');
        ourpleShaggersRight.animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        ourpleShaggersRight.animation.addByPrefix('happy', 'Up', 24, false, false, false);
        ourpleShaggersRight.animation.play('idle', false, false, 0);
        ourpleShaggersRight.flipX = true;
        add(ourpleShaggersRight);

         /*ourpleShaggersLeft = new Character(100, 260, 'ourple_shaggers');
        ourpleShaggersLeft.dance();
        add(ourpleShaggersLeft);

        ourpleShaggersRight = new Character(885, 260, 'ourple_shaggers');
        ourpleShaggersRight.dance();
        ourpleShaggersRight.flipX = true;
        add(ourpleShaggersRight);*/

        originY = 260;

		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = 635;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);

        NameAlpha = new Alphabet(20, (FlxG.height / 2) + 220, appCats[curSelected][0].toLowerCase(), true);
		NameAlpha.screenCenter(X);
        Highscore.load();
		add(NameAlpha);

        changeSelection();
        super.create();
    }

    override public function update(elapsed:Float){
        if (controls.UI_LEFT_P) {
            changeSelection(-1);
        }
        if (controls.UI_RIGHT_P) {
            changeSelection(1);
        }
        if (controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }
        if (controls.ACCEPT) {
            CoolUtil.browserLoad(appCats[curSelected][3]);
            happyAnim = true;
            //ourpleShaggersLeft.playAnim('singUP', true, false, 0);
            //ourpleShaggersRight.playAnim('singUP', true, false, 0);
            ourpleShaggersLeft.animation.play('happy', true, false, 0);
            ourpleShaggersRight.animation.play('happy', true, false, 0);
            ourpleShaggersLeft.flipX = false;
            ourpleShaggersRight.flipX = true;
            new FlxTimer().start(0.7, function(tmr:FlxTimer)
                {
                    happyAnim = false;
                });
        }

        if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);

        if (ourpleShaggersLeft.animation.curAnim.name == 'happy') {
            ourpleShaggersLeft.x = 45;
            ourpleShaggersLeft.y = 225;
        } else {
            ourpleShaggersLeft.x = 100;
        }

        if (ourpleShaggersRight.animation.curAnim.name == 'happy') {
            ourpleShaggersRight.x = 830;
            ourpleShaggersRight.y = 225;
        } else {
            ourpleShaggersRight.x = 885;
        }
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			if (spr.ID == curSelected)
			{
                spr.scale.x = Std.parseFloat(appCats[curSelected][1]) + 0.1;
                spr.scale.y = Std.parseFloat(appCats[curSelected][1]) + 0.1;
				spr.centerOffsets();
			}
            else
            {
                spr.scale.x = Std.parseFloat(appCats[spr.ID][1]);
                spr.scale.y = Std.parseFloat(appCats[spr.ID][1]);
                spr.centerOffsets();
            }
            spr.updateHitbox();
        });

        NameAlpha.destroy();
		NameAlpha = new Alphabet(20, (FlxG.height / 2) + 220, appCats[curSelected][0], true);
		NameAlpha.screenCenter(X);
		add(NameAlpha);
    }

    override public function beatHit()
    {
        if (curBeat % 1 == 0 && !happyAnim)
        {
            //ourpleShaggersLeft.dance();
            //ourpleShaggersRight.dance();
            ourpleShaggersLeft.animation.play('idle', false, false, 0);
            ourpleShaggersRight.animation.play('idle', false, false, 0);
			ourpleShaggersLeft.flipX = flippedIdle;
            ourpleShaggersRight.flipX = !flippedIdle;
			flippedIdle = !flippedIdle;
			ourpleShaggersLeft.y = (ourpleShaggersLeft.y + 20);
            ourpleShaggersRight.y = (ourpleShaggersRight.y + 20);
			FlxTween.tween(ourpleShaggersLeft, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
            FlxTween.tween(ourpleShaggersRight, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
        }
    }
}