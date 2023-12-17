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

class LorayState extends MusicBeatState
{
    public static var appCats:Array<Array<String>> = [ // App Name, Scale, X Offset, Link
        ['Youtube', '0.45', '0',    'https://youtube.com/@LORAY_'],
        ['Twitter', '0.45', '45',   'https://twitter.com/LORAY_man'], 
        ['Discord', '0.45', '0',    'https://discord.com/invite/JnsQV8az8C']
    ];
    var menuItems:FlxTypedGroup<FlxSprite>;

    public var NameAlpha:Alphabet;
    var bg:FlxSprite;
    var categoryIcon:FlxSprite;
    var ourpleLorayLeft:FlxSprite;
    var ourpleLorayRight:FlxSprite;

    var originY:Int = 460;
	var curSelected:Int = 0;

    var happyAnim:Bool = false;
    var flippedIdle:Bool = false;
    
    override function create()
    {
        #if desktop
        // Updating Discord Rich Presence
        DiscordClient.changePresence("LORAY UwU", null);
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
            appItem.frames = Paths.getSparrowAtlas('loray/loray_' + appCats[i][0].toLowerCase());
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

        ourpleLorayLeft = new FlxSprite(180, originY);
        ourpleLorayLeft.frames = Paths.getSparrowAtlas('loray/OURPLE_LORAAAAAAAAAAY');
        ourpleLorayLeft.animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        ourpleLorayLeft.animation.addByPrefix('happy', 'Up', 24, false, false, false);
        ourpleLorayLeft.animation.play('idle', false, false, 0);
        ourpleLorayLeft.scale.x = 3;
        ourpleLorayLeft.scale.y = 3;
        ourpleLorayLeft.antialiasing = false;
        add(ourpleLorayLeft);

        ourpleLorayRight = new FlxSprite(935, originY);
        ourpleLorayRight.frames = Paths.getSparrowAtlas('loray/OURPLE_LORAAAAAAAAAAY');
        ourpleLorayRight.animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        ourpleLorayRight.animation.addByPrefix('happy', 'Up', 24, false, false, false);
        ourpleLorayRight.animation.play('idle', false, false, 0);
        ourpleLorayRight.flipX = true;
        ourpleLorayRight.scale.x = 3;
        ourpleLorayRight.scale.y = 3;
        ourpleLorayRight.antialiasing = false;
        add(ourpleLorayRight);

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
            MusicBeatState.switchState(new CreditsState());
        }
        if (controls.ACCEPT) {
            CoolUtil.browserLoad(appCats[curSelected][3]);
            happyAnim = true;
            ourpleLorayLeft.animation.play('happy', true, false, 0);
            ourpleLorayRight.animation.play('happy', true, false, 0);
            ourpleLorayLeft.flipX = false;
            ourpleLorayRight.flipX = true;
            new FlxTimer().start(0.7, function(tmr:FlxTimer)
                {
                    ourpleLorayLeft.y = originY;
                    ourpleLorayRight.y = originY;
                    happyAnim = false;
                });
        }

        if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);

        if (ourpleLorayLeft.animation.curAnim.name == 'happy') {
            ourpleLorayLeft.x = 145;
            ourpleLorayLeft.y = 380;
        } else {
            ourpleLorayLeft.x = 180;
        }

        if (ourpleLorayRight.animation.curAnim.name == 'happy') {
            ourpleLorayRight.x = 890;
            ourpleLorayRight.y = 380;
        } else {
            ourpleLorayRight.x = 935;
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
            ourpleLorayLeft.animation.play('idle', false, false, 0);
            ourpleLorayRight.animation.play('idle', false, false, 0);
			ourpleLorayLeft.flipX = flippedIdle;
            ourpleLorayRight.flipX = !flippedIdle;
			flippedIdle = !flippedIdle;
			ourpleLorayLeft.y = (ourpleLorayLeft.y + 20);
            ourpleLorayRight.y = (ourpleLorayRight.y + 20);
			FlxTween.tween(ourpleLorayLeft, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
            FlxTween.tween(ourpleLorayRight, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
        }
    }
}