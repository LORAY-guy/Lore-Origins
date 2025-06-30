package states.credits;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

class LorayState extends MusicBeatState
{
    /**
        @param App_Name String
        @param Scale Float
        @param X_Offset Int/Float
        @param Link String
    **/
    public static var appCats:Array<Array<Dynamic>> = [
        ['Youtube', 0.45,  0,    'https://youtube.com/@LORAY_'],
        ['Twitter', 0.45,  45,   'https://twitter.com/LORAY_man'],
        ['Discord', 0.45,  0,    'https://discord.com/invite/JnsQV8az8C'],
        ['Paypal',  0.16,  0,    'https://paypal.me/LORAYman']
    ];

    var menuItems:FlxTypedGroup<FlxSprite>;
    var lorays:FlxTypedGroup<Loray>;
    var camFollow:FlxObject;

    public var appName:Alphabet;
    var bg:FlxSprite;

	public static var curSelected:Int = 0;
    
    override function create()
    {
        #if DISCORD_ALLOWED
        // Updating Discord Rich Presence
        DiscordClient.changePresence("LORAY UwU", null);
        #end

        Paths.clearUnusedMemory();

        FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

        camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

        bg = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
        var scaleMultiplier:Float = FlxG.width / 1280;
		bg.setGraphicSize(Std.int(bg.width * scaleMultiplier));
		bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set();
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
            var appItem:FlxSprite = new FlxSprite((i * 410 - (i * 5)) + offset, 120);
            var scaleItem:Float = appCats[i][1];
            appItem.x += 80 + appCats[i][2];
            appItem.frames = Paths.getSparrowAtlas('loray/loray_' + appCats[i][0].toLowerCase());
			appItem.animation.addByPrefix('idle', appCats[i][0].toLowerCase(), 24);
			appItem.animation.play('idle');
            appItem.scale.set(scaleItem, scaleItem);
			appItem.ID = i;
			menuItems.add(appItem);
			appItem.scrollFactor.set(1, 0);
            appItem.updateHitbox();
			appItem.antialiasing = ClientPrefs.data.antialiasing;
        }

        lorays.add(new Loray(false));
        lorays.add(new Loray(true));

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
        appName.scrollFactor.set();
		add(appName);

        add(new ExitButton('credits'));
        
        super.create();

        FlxG.camera.follow(camFollow, LOCKON, 9);
        camFollow.screenCenter(X);
        cameraTargetX = camFollow.x;
        changeSelection(0, false, false);
    
        if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
    }

    var canClick:Bool = true;
    var usingMouse:Bool = false;
    var quitting:Bool = false;
    var cameraTargetX:Float = 0;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.UI_UP_P || controls.UI_DOWN_P)
            usingMouse = false;
        else if (FlxG.mouse.overlaps(menuItems) || FlxG.mouse.overlaps(lorays))
            usingMouse = true;

        menuItems.forEachAlive(function(spr:FlxSprite) {
            if (usingMouse && FlxG.mouse.overlaps(spr) && curSelected != spr.ID)
                changeSelection(spr.ID, true);
        });

        if (controls.UI_LEFT_P) {
            changeSelection(-1);
        }
        if (controls.UI_RIGHT_P) {
            changeSelection(1);
        }

        if (usingMouse && FlxG.mouse.wheel != 0) changeSelection(-FlxG.mouse.wheel);

        if (controls.ACCEPT_P || (usingMouse && canClick && FlxG.mouse.justPressed && (FlxG.mouse.overlaps(menuItems)))) {
            lorays.forEachAlive(function(spr:Loray) {spr.beHappy();});
            FlxG.camera.zoom += 0.06;
            FlxG.sound.play(Paths.sound('confirmMenu'));
            FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, true, false, function(flick:FlxFlicker){CoolUtil.browserLoad(appCats[curSelected][3]);});
        } else if (controls.BACK_P) {
            canClick = false;
            quitting = true;
            MusicBeatState.switchState(new states.credits.CreditsState());
        }

        lorays.forEachAlive(function(spr:Loray) {
            if (usingMouse && FlxG.mouse.overlaps(spr) && canClick && FlxG.mouse.justPressed) 
                spr.beHappy(true);
        });

        camFollow.x = cameraTargetX;
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
    }

    function changeSelection(change:Int = 0, ?goTo:Bool = false, ?playSound:Bool = true)
    {
        FlxG.camera.zoom += 0.03;
        if (!goTo) curSelected += change; else curSelected = change;
        if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));

        if (curSelected >= menuItems.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = menuItems.length - 1;

        menuItems.forEach(function(spr:FlxSprite) {
            if (spr.ID == curSelected) {
                spr.scale.set(appCats[curSelected][1] * 1.2, appCats[curSelected][1] * 1.2);
                spr.updateHitbox();
                cameraTargetX = spr.x + (spr.width * 0.5);
            } else {
                spr.scale.set(appCats[spr.ID][1], appCats[spr.ID][1]);
                spr.updateHitbox();
            }
        });

        appName.clearLetters();
        appName.text = appCats[curSelected][0];
        appName.screenCenter(X);
        appName.softReloadLetters();
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

    public var happy:Bool = false;
    public var originX:Float = 0;
    public var originY:Float = 0;

    public function new(rightSide:Bool = false)
    {
        super(0, 0);
        
        frames = Paths.getSparrowAtlas('loray/OURPLE_LORAAAAAAAAAAY');
        animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        animation.addByPrefix('happy', 'Up', 24, false, false, false);
        animation.play('idle', false, false, 0);
        scale.x = 3;
        scale.y = 3;
        scrollFactor.set();
        ID = lorays.length;
        flipX = (ID % 2 == 0) ? true : false;
        updateHitbox();

        var offsetFromEdge:Float = FlxG.width / 20;
        
        if (rightSide)
            this.originX = x = FlxG.width - offsetFromEdge - width;
        else
            this.originX = x = offsetFromEdge;

        this.originY = y = FlxG.height - height + (height / 4);
        
        lorays.push(this);
    }

    public function beHappy(?unlockAchievement:Bool = false) 
    {
        happy = true;
        FlxG.camera.zoom += 0.06;
        FlxG.sound.play(Paths.soundRandom('loraySounds/ourple', 1, 10), 0.4);
        FlxTween.cancelTweensOf(this, ['y']);
        animation.play('happy', true, false, 0);
        x = originX - 45;
        y = originY - 80; // Use originY as reference instead of subtracting from current y
        flipX = (ID % 2 == 0) ? false : true;
        new FlxTimer().start(0.7, function(tmr:FlxTimer)
        {
            happy = false;
            x = originX;
            y = originY;
            flipX = (ID % 2 == 0) ? true : false; // Fix: should match the original flipX logic
            dance();
        });
        if (unlockAchievement) Achievements.unlock('loray_hater');
    }

    public function dance()
    {
        if (!happy)
        {
            animation.play('idle', true, false, 0);
            y = originY + 20; // Use originY as reference for consistent positioning
            flipX = !flipX;
            FlxTween.tween(this, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
        }
    }
}