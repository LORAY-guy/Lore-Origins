package states.credits;

import openfl.utils.IAssetCache;
import flixel.graphics.FlxGraphic;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;

class LorayState extends MusicBeatState
{
    /**
        @param App_Name String
        @param Scale Float
        @param X_Offset Float
        @param Link String
    **/
    public static var appCats:Array<Array<Dynamic>> = [
        ['Youtube', 0.5,   20,      'https://youtube.com/@LORAY_'],
        ['Twitter', 0.5,   -20,     'https://twitter.com/LORAY_man'],
        ['GitHub',  0.5,   -120,    'https://github.com/LORAY-guy'],
        ['Ko-fi',   0.525, -80,     'https://ko-fi.com/loray'],
        ['Paypal',  0.4,   -180,    'https://paypal.me/LORAYman']
    ];

    private var menuItems:FlxTypedGroup<FlxSprite>;
    public static var lorays:FlxTypedGroup<Loray>;
    private var camFollow:FlxObject;

    private var animatedBackdrop:AnimatedBackdrop;
    public var appName:Alphabet;

	public static var curSelected:Int = 0;
    
    override public function create():Void
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
        
        var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0.025, 0);
		grid.velocity.set(20, 20);
		grid.alpha = 0.5;
		add(grid);

        animatedBackdrop = new AnimatedBackdrop(FlxG.width, FlxG.height);
        add(animatedBackdrop);
        
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
            if (i > 0) appItem.x += appCats[i-1][2]; // Gets the offset of the previous element
            appItem.frames = Paths.getSparrowAtlas('loray/loray_' + appCats[i][0].toLowerCase());
			appItem.animation.addByPrefix('idle', appCats[i][0].toLowerCase(), 30);
			appItem.animation.play('idle');
            appItem.scale.set(scaleItem, scaleItem);
			appItem.ID = i;
			menuItems.add(appItem);
			appItem.scrollFactor.set(1, 0);
            appItem.updateHitbox();
			appItem.antialiasing = false;
        }

        lorays.add(new Loray(false));
        lorays.add(new Loray(true));

		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('loray/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = FlxG.height - lettabox1.height;
        lettabox1.flipY = true;
        lettabox1.antialiasing = ClientPrefs.data.antialiasing;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('loray/lettabox'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
        lettabox2.antialiasing = ClientPrefs.data.antialiasing;
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

    private var canClick:Bool = true;
    private var usingMouse:Bool = false;
    private var quitting:Bool = false;
    private var cameraTargetX:Float = 0;
    override public function update(elapsed:Float):Void
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

    private function changeSelection(change:Int = 0, ?goTo:Bool = false, ?playSound:Bool = true):Void
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

    override public function beatHit():Void
    {
        lorays.forEachAlive(function(spr:Loray) {
            spr.dance();
        });
    }

    override public function destroy():Void
    {
        animatedBackdrop.destroy();
        animatedBackdrop = null;
        menuItems.destroy();
        menuItems = null;
        lorays.destroy();
        lorays = null;
        appName.destroy();
        appName = null;

        super.destroy();
    }
}

class Loray extends FlxSprite
{
    private var happy:Bool = false;
    private var originX:Float = 0;
    private var originY:Float = 0;
    private var happyTimer:FlxTimer = new FlxTimer();

    public function new(rightSide:Bool = false)
    {
        super();
        
        frames = Paths.getSparrowAtlas('loray/OURPLE_LORAAAAAAAAAAY');
        animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        animation.addByPrefix('happy', 'Up', 24, false, false, false);
        animation.play('idle', false, false, 0);
        scale.x = 3;
        scale.y = 3;
        scrollFactor.set();
        ID = cast LorayState.lorays.length;
        flipX = (ID % 2 == 0) ? true : false;
        updateHitbox();

        var offsetFromEdge:Float = FlxG.width / 20;
        
        if (rightSide)
            this.originX = x = FlxG.width - offsetFromEdge - width;
        else
            this.originX = x = offsetFromEdge;

        this.originY = y = FlxG.height - height + (height / 4);
    }

    public function beHappy(?unlockAchievement:Bool = false):Void
    {
        happy = true;
        FlxG.camera.zoom += 0.06;
        FlxG.sound.play(Paths.soundRandom('loraySounds/ourple', 1, 10), 0.4);
        FlxTween.cancelTweensOf(this, ['y']);
        animation.play('happy', true, false, 0);
        x = originX - 45;
        y = originY - 80;
        flipX = (ID % 2 == 0) ? false : true;
        if (happyTimer != null) happyTimer.cancel();
        happyTimer.start(0.7, function(tmr:FlxTimer)
        {
            happy = false;
            x = originX;
            y = originY;
            flipX = (ID % 2 == 0) ? true : false;
            dance();
        });
        if (unlockAchievement) Achievements.unlock('loray_hater');
    }

    public function dance():Void
    {
        if (!happy)
        {
            animation.play('idle', true, false, 0);
            y = originY + 20;
            flipX = !flipX;
            FlxTween.tween(this, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
        }
    }
}

class AnimatedBackdrop extends FlxTypedGroup<FlxSprite>
{
    public static inline var TILE_WIDTH:Int = 96;
    public static inline var TILE_HEIGHT:Int = 108;
    
    private var columns:Int;
    private var rows:Int;

    private var blueGraphics:Array<FlxGraphic> = [];
    private var redGraphics:Array<FlxGraphic> = [];
    
    private var animTimer:FlxTimer;
    private var currentFrame:Int = 0;
    
    private var tileColors:Array<Bool> = [];
    
    public function new(width:Float, height:Float)
    {
        super();
        
        columns = Math.ceil(width / TILE_WIDTH) + 2; // Extra column for extra added scroll factor effect
        rows = Math.ceil(height / TILE_HEIGHT) + 1;
        
        for (i in 1...13) {
            blueGraphics.push(Paths.image('loray/frames/b${i}'));
            redGraphics.push(Paths.image('loray/frames/r${i}'));
        }
        
        createTileGrid();
        modifyTiles();
        
        animTimer = new FlxTimer().start(0.075, function(tmr:FlxTimer) {
            currentFrame = (currentFrame + 1) % blueGraphics.length;
            if (currentFrame == 0)
                modifyTiles();
            updateTileFrames();
        }, 0);
    }
    
    private function createTileGrid():Void
    {
        for (row in 0...rows) {
            for (col in 0...columns) {
                var x:Float = col * TILE_WIDTH;
                var y:Float = row * TILE_HEIGHT;

                var isBlue:Bool = FlxG.random.bool(50);
                tileColors.push(isBlue);

                var tile:FlxSprite = new FlxSprite(x, y);
                tile.loadGraphic(isBlue ? blueGraphics[0] : redGraphics[0]);
                tile.scrollFactor.set(0.05, 0);
                tile.velocity.set(-20, 15);
                add(tile);
            }
        }
    }
    
    private function modifyTiles():Void
    {
        forEachAlive(function(tile:FlxSprite) {
            tile.alpha = FlxG.random.float(0.2, 1);
            tileColors[this.members.indexOf(tile)] = FlxG.random.bool(50);
        });
    }

    private function updateTileFrames():Void
    {
        var i:Int = 0;

        forEachAlive(function(tile:FlxSprite) {
            tile.loadGraphic(tileColors[i] ? blueGraphics[currentFrame] : redGraphics[currentFrame]);
            i++;
        });
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        forEachAlive(function(tile:FlxSprite) {
            if (tile.x < -TILE_WIDTH - TILE_WIDTH * (1 + tile.scrollFactor.x))
                tile.x += columns * TILE_WIDTH;
            if (tile.y > (rows * TILE_HEIGHT) - tile.height)
                tile.y -= rows * TILE_HEIGHT;
        });
    }
    
    override public function destroy():Void
    {
        if (animTimer != null) {
            animTimer.cancel();
            animTimer = null;
        }
        
        super.destroy();
    }
}
