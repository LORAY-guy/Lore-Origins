package options;

import backend.ExitButton;
import flixel.addons.display.FlxBackdrop;

class OurpleSkinSelector extends MusicBeatSubstate
{
    var skinsData:Array<Dynamic> = [
        ['Ourple', ['Normal', 'Staring', 'Mad']],
        ['Vloo', ['Normal', 'Mad']],
    ];

    var ourple:FlxSprite;

    var ourpleName:Alphabet;
    var skinName:Alphabet;

    var arrowLeft:FlxSprite;
    var arrowRight:FlxSprite;

    var curSkin:Int = 0;
    var curOurple:Int = 0;
    var curSkinName:String = 'Normal';
    var curOurpleName:String = 'Ourple';

    public function new()
    {
        super();

        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Ourple Skin Selector (WIP)", null);
		#end

        var bg:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.7));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0, 0);
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);

        var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = FlxG.height - lettabox1.height;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);

        arrowLeft = new FlxSprite(0, 380);
        arrowLeft.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        arrowLeft.animation.addByPrefix('idle', 'arrow left', 1, false);
        arrowLeft.animation.addByPrefix('press', 'arrow push left', 1, false);
        arrowLeft.animation.play('idle', false, false, 0);
        arrowLeft.x = arrowLeft.width - 25;
        arrowLeft.screenCenter(Y);
        add(arrowLeft);

        arrowRight = new FlxSprite(0, 380);
        arrowRight.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        arrowRight.animation.addByPrefix('idle', 'arrow right', 1, false);
        arrowRight.animation.addByPrefix('press', 'arrow push right', 1, false);
        arrowRight.animation.play('idle', false, false, 0);
        arrowRight.x = FlxG.width - arrowRight.width - 25;
        arrowRight.screenCenter(Y);
        add(arrowRight);

        var tutorialTxt:FlxText = new FlxText(45, FlxG.height - 200, 400, 'Press \'Enter\' or \'Space\' to save your selection!', 38);
        tutorialTxt.setFormat(Paths.font('ourple.ttf'), 38, 0xFFA04EBA, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
        add(tutorialTxt);

        changeOurple();
        add(new ExitButton('options'));
    }

    var flippedIdle:Bool = false;
	override function update(elapsed:Float)
	{
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
		super.update(elapsed);

        if (controls.UI_UP_P)
            changeOurple(-1);
        if (controls.UI_DOWN_P)
            changeOurple(1);
        
        if (controls.UI_LEFT_P)
        {
            changeSkin(-1);
            arrowLeft.animation.play('press', false, false, 0);
        }
        if (controls.UI_RIGHT_P)
        {
            changeSkin(1);
            arrowRight.animation.play('press', false, false, 0);
        }

        if (controls.ACCEPT)
            saveOurple();

        if (FlxG.keys.justPressed.SPACE)
            trace(ClientPrefs.data.ourpleData);

        if (arrowLeft.animation.curAnim.name != 'idle' && !FlxG.keys.pressed.LEFT)
            arrowLeft.animation.play('idle', false, false, 0);
    
        if (arrowRight.animation.curAnim.name != 'idle' && !FlxG.keys.pressed.RIGHT)
            arrowRight.animation.play('idle', false, false, 0);

        if (controls.BACK) {
            close();
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }
	}

    override function destroy() 
    {
        ClientPrefs.saveSettings();
        super.destroy();
    }

    function changeSkin(change:Int = 0, ?goTo:Bool = false)
    {
        if (skinsData[curOurple][1].length > 1)
        {
            FlxG.camera.zoom += 0.03;
            if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
    
            if (goTo) curSkin = change;
            else curSkin += change;
        
            if (curSkin >= skinsData[curOurple][1].length)
                curSkin = 0;
            if (curSkin < 0)
                curSkin = Std.int(skinsData[curOurple][1].length - 1);
        
            curSkinName = skinsData[curOurple][1][curSkin];
        
            reloadOurple();
        }
    }

    function changeOurple(change:Int = 0)
    {
        FlxG.camera.zoom += 0.03;
        if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        curOurple += change;

		if (curOurple >= skinsData.length)
			curOurple = 0;
		if (curOurple < 0)
			curOurple = skinsData.length - 1;

        curOurpleName = skinsData[curOurple][0];

        changeSkin(0, true);
        reloadOurple();

        if (ourpleName != null) ourpleName.destroy();
        ourpleName = new Alphabet(0, (FlxG.height / 2) - 282, curOurpleName, true);
        ourpleName.screenCenter(X);
        insert(20, ourpleName);
    }

    function reloadOurple()
    {
        var subSpriteName:String = curSkinName;
        var spriteName:String = curOurpleName;
        var path:String = 'options/skins/' + ((spriteName == 'Ourple' ? 'playguy' : spriteName) + (subSpriteName == 'Normal' ? '' : subSpriteName)).toLowerCase();
        
        if (ourple != null)
        {
            FlxTween.cancelTweensOf(ourple);
            FlxTween.tween(ourple, {x: FlxG.width + ourple.width}, 0.2, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween) {
                destroyAndCreateOurple(path);
            }});
        }
        else
            destroyAndCreateOurple(path);
    
        if (skinName != null) skinName.destroy();
        skinName = new Alphabet(0, FlxG.height - 200, curSkinName, false);
        skinName.screenCenter(X);
        insert(20, skinName);
    }

    function destroyAndCreateOurple(path:String):Void
    {
        if (ourple != null) ourple.destroy();
        ourple = new FlxSprite().loadGraphic(Paths.image(path));
        ourple.x = -FlxG.width - ourple.width;
        ourple.scale.set(2.5, 2.5);
        ourple.updateHitbox();
        insert(10, ourple);
        ourple.screenCenter(XY);
        var xPos:Float = ourple.x;
        ourple.x = -FlxG.width - ourple.width;
        FlxTween.tween(ourple, {x: xPos}, 0.2, {ease: FlxEase.cubeOut});
    }

    function saveOurple()
    {
        ClientPrefs.data.ourpleData.set(curOurpleName, curSkinName);
        ClientPrefs.saveSettings();

        var saved:Alphabet = new Alphabet(FlxG.width - 350, FlxG.height - 140, 'SAVED !', true);
        add(saved);
        FlxTween.tween(saved, {y: saved.y - 75, alpha: 0}, 0.7, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
            saved.destroy();
        }});
    }
}