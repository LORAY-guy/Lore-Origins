package states.credits;

import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import backend.ExitButton;

class LorayState extends MusicBeatState
{
    public static var appCats:Array<Array<String>> = [ // App Name, Scale, X Offset, Link
        ['Youtube', '0.45', '0',    'https://youtube.com/@LORAY_'],
        ['Twitter', '0.45', '45',   'https://twitter.com/LORAY_man'], 
        ['Discord', '0.45', '0',    'https://discord.com/invite/JnsQV8az8C']
    ];

    var menuItems:FlxTypedGroup<FlxSprite>;
    var lorays:FlxTypedGroup<Loray>;

    public var appName:Alphabet;
    var bg:FlxSprite;

	var curSelected:Int = 0;
    
    override function create()
    {
        #if DISCORD_ALLOWED
        // Updating Discord Rich Presence
        DiscordClient.changePresence("LORAY UwU", null);
        #end

        Paths.clearUnusedMemory();

        FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

        persistentUpdate = true;

        bg = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
        bg.screenCenter();
        add(bg);

        var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0, 0);
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);
        
        menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

        lorays = new FlxTypedGroup<Loray>();
		add(lorays);

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
			appItem.antialiasing = ClientPrefs.data.antialiasing;
			appItem.updateHitbox();
        }

        lorays.add(new Loray(180));
        lorays.add(new Loray(935));

		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = 635;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);

        appName = new Alphabet(20, (FlxG.height / 2) + 220, appCats[curSelected][0].toLowerCase(), true);
		appName.screenCenter(X);
		add(appName);

        add(new ExitButton('credits'));

        changeSelection(0, false, false);
        super.create();

        FlxG.camera.y = 720;
		FlxTween.tween(FlxG.camera, {y: 0}, 1.2, {ease: FlxEase.expoInOut});

        if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
    }

    var canClick:Bool = true;
    var usingMouse:Bool = false;
    var quitting:Bool = false;
    override public function update(elapsed:Float){
        if (!quitting)
        {
            if (controls.UI_UP_P || controls.UI_DOWN_P)
                usingMouse = false;
            else if (FlxG.mouse.overlaps(menuItems) || FlxG.mouse.overlaps(lorays))
                usingMouse = true;

            menuItems.forEachAlive(function(spr:FlxSprite){if (usingMouse && FlxG.mouse.overlaps(spr) && curSelected != spr.ID) changeSelection(spr.ID, true);});

            if (controls.UI_LEFT_P) {
                changeSelection(-1);
            }
            if (controls.UI_RIGHT_P) {
                changeSelection(1);
            }

            if (usingMouse && FlxG.mouse.wheel != 0) changeSelection(-FlxG.mouse.wheel);

            if (controls.BACK) {
                canClick = false;
                quitting = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.mouse.visible = false;
                FlxG.camera.zoom += 0.06;
                FlxTween.tween(FlxG.camera, {y: 720}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
					MusicBeatState.switchState(new states.credits.CreditsState());
				}});
            }
            else if (controls.ACCEPT || (usingMouse && canClick && FlxG.mouse.justPressed && (FlxG.mouse.overlaps(menuItems)))) {
                lorays.forEachAlive(function(spr:Loray) {spr.beHappy();});
                FlxG.camera.zoom += 0.06;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, true, false, function(flick:FlxFlicker){CoolUtil.browserLoad(appCats[curSelected][3]);});
            }

            lorays.forEachAlive(function(spr:Loray){if (usingMouse && FlxG.mouse.overlaps(spr) && canClick && FlxG.mouse.justPressed) spr.beHappy();});
        }

        if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
        super.update(elapsed);
    }

    function changeSelection(change:Int = 0, ?goTo:Bool = false, ?playSound:Bool = true) {
        FlxG.camera.zoom += 0.03;
        if (!goTo) curSelected += change; else curSelected = change;
        if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));

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

        appName.destroy();
		appName = new Alphabet(20, (FlxG.height / 2) + 220, appCats[curSelected][0], true);
		appName.screenCenter(X);
		add(appName);
    }

    override public function beatHit()
    {
        lorays.forEachAlive(function(spr:Loray) {
            spr.dance();
        });
    }
}

class Loray extends FlxSprite
{
    public static var lorays:Array<Loray> = [];
	public static var tweensMap:Map<String, FlxTween> = new Map<String, FlxTween>();

    public var happy:Bool = false;
    public var originX:Float = 0;
    public var originY:Float = 460;

    public function new(x:Float = 0)
    {
        super(x, originY);
        
        frames = Paths.getSparrowAtlas('loray/OURPLE_LORAAAAAAAAAAY');
        animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        animation.addByPrefix('happy', 'Up', 24, false, false, false);
        animation.play('idle', false, false, 0);
        scale.x = 3;
        scale.y = 3;
        antialiasing = false;
        ID = lorays.length;
        flipX = (ID % 2 == 0) ? true : false;
        lorays.push(this);

        this.originX = x;
    }

    public function beHappy() 
    {
        happy = true;
        FlxG.camera.zoom += 0.06;
        FlxG.sound.play(Paths.soundRandom('loraySounds/ourple', 1, 10), 0.4);
        cancelTween('idle' + ID);
        animation.play('happy', true, false, 0);
        x = originX - 45;
        y = 380;
        flipX = (ID % 2 == 0) ? false : true;
        new FlxTimer().start(0.7, function(tmr:FlxTimer)
        {
            happy = false;
            x = originX;
            y = originY;
            flipX = (ID % 2 == 0) ? false : true;
            dance();
        });
    }

    public function dance()
    {
        if (!happy)
        {
            animation.play('idle', true, false, 0);
            y = (y + 20);
            flipX = !flipX;
            tweensMap.set('idle' + ID, FlxTween.tween(this, {y: originY}, 0.15, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {tweensMap.remove('idle' + ID);}}));
        }
    }

    public function cancelTween(ID:String)
    {
        if (tweensMap.exists(ID)) tweensMap.get(ID).cancel();
        tweensMap.remove(ID);
    }
}