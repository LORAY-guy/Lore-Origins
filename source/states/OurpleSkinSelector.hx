package states;

import flixel.addons.display.FlxBackdrop;

class OurpleSkinSelector extends MusicBeatState
{
    public var skinsData:Array<Dynamic> = [
        ['Ourple', ['Normal', 'Staring', 'Mad']],
        ['Bloxxy', ['Normal']],
        ['Blink', ['Normal']],
        ['Cool', ['Normal']],
        ['Hrey', ['Normal']],
        ['Nuu', ['Normal', 'Mad']],
        //['Vloo', ['Normal', 'Mad']],
        ['Wink', ['Normal']]
    ];

    private var bg:FlxSprite;
    private var ourple:FlxSprite;
    private var arrows:FlxSpriteGroup;

    private var grid:FlxBackdrop;
    private var lettabox1:FlxBackdrop;
    private var lettabox2:FlxBackdrop;

    private var ourpleName:Alphabet;
    private var skinName:Alphabet;
    private var selectOurpleTxt:FlxText;

    public static var curSkin:Int = 0;
    public static var curOurple:Int = 0;
    public static var curSelectedOurple:Int = 0;
    public static var curSkinName:String = 'Normal';
    public static var curOurpleName:String = 'Ourple';
    public static var curSelectedOurpleName:String = 'Ourple';

    override public function create():Void
    {
        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Ourple Skin Selector (WIP)", null);
		#end

        bg = new FlxSprite(-10).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.7));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        grid = createBackdrop('mainmenu/grid', 40, 40);
		grid.alpha = 0.5;
		add(grid);

        lettabox1 = createBackdrop('mainmenu/lettabox', 40);
        lettabox1.y = FlxG.height - lettabox1.height;
		add(lettabox1);

		lettabox2 = createBackdrop('mainmenu/lettabox2', -40);
		add(lettabox2);

        arrows = new FlxSpriteGroup();
        arrows.y += 18;
        add(arrows);

        createArrow(true);
        createArrow(false);

        createText(45, FlxG.height - 225, 400, "Press 'Enter' or 'Space' to save your selection!");
        createText(FlxG.width - 515, FlxG.height - 225, 500, "Press 'CTRL' to enter the Character Selector Menu!");

        selectOurpleTxt = new FlxText(FlxG.width - 450, 80, 400, 'Current Ourple: ?', 38);
        selectOurpleTxt.setFormat(Paths.font('ourple.ttf'), 38, 0xFFA04EBA, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
        selectOurpleTxt.visible = false;
        add(selectOurpleTxt);

        super.create();

        changeOurple();
        add(new ExitButton());
    }

    var flippedIdle:Bool = false;
    var inSelectOurple:Bool = false;
	override public function update(elapsed:Float):Void
	{
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
		super.update(elapsed);

        if (!inSelectOurple) {
            handleMainInput();
        } else {
            handleSelectOurpleInput();
        }
	}

    private function handleMainInput():Void
    {
        if (controls.UI_UP_P)
            changeOurple(-1);
        if (controls.UI_DOWN_P)
            changeOurple(1);
        
        if (controls.UI_LEFT_P) {
            if (skinsData[curOurple][1].length > 1) {
                changeSkin(-1);
            } else {
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
            arrows.members[0].animation.play('s');
        }
        if (controls.UI_RIGHT_P)
        {
            if (skinsData[curOurple][1].length > 1) {
                changeSkin(1);
            } else {
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
            arrows.members[1].animation.play('s');
        }

        if (controls.UI_LEFT_R)
            arrows.members[0].animation.play('i');
    
        if (controls.UI_RIGHT_R)
            arrows.members[1].animation.play('i');

        if (controls.ACCEPT_P)
            saveOurple();

        if (FlxG.keys.justPressed.CONTROL)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            arrows.visible = false;
            inSelectOurple = !inSelectOurple;
            selectOurpleTxt.visible = inSelectOurple;
            changeSelectedOurple();
        }

        if (controls.BACK_P) {
            exitState(new MainMenuState(true));
        }
    }

    private function handleSelectOurpleInput():Void
    {
        if (controls.UI_LEFT_P)
            changeSelectedOurple(-1);
        if (controls.UI_RIGHT_P)
            changeSelectedOurple(1);
        
        if (controls.BACK_P || FlxG.keys.justPressed.CONTROL) 
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            saveOurple();
            inSelectOurple = false;
            arrows.visible = true;
            selectOurpleTxt.visible = false;
        }
    }
    
    private function changeSkin(change:Int = 0, ?goTo:Bool = false):Void
    {
        if (skinsData[curOurple][1].length > 1)
        {
            FlxG.camera.zoom += 0.03;
            if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        
            curSkin = goTo ? change : curSkin + change;

            if (curSkin >= skinsData[curOurple][1].length)
                curSkin = 0;
            if (curSkin < 0)
                curSkin = Std.int(skinsData[curOurple][1].length - 1);
        
            curSkinName = skinsData[curOurple][1][curSkin];

            reloadOurple(change);
        }
    }

    private function changeOurple(change:Int = 0):Void
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
        reloadOurple(change, true);

        if (ourpleName != null) ourpleName.destroy();
        ourpleName = new Alphabet(0, (FlxG.height / 2) - 282, curOurpleName, true);
        ourpleName.screenCenter(X);
        add(ourpleName);
    }

    private function changeSelectedOurple(change:Int = 0, ?goTo:Bool = false):Void
    {
        if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

        curSelectedOurple = goTo ? change : curSelectedOurple + change;

        if (curSelectedOurple >= skinsData.length)
            curSelectedOurple = 0;
        if (curSelectedOurple < 0)
            curSelectedOurple = skinsData.length - 1;

        curSelectedOurpleName = skinsData[curSelectedOurple][0];
        selectOurpleTxt.text = 'Current Ourple: ' + curSelectedOurpleName;
    }

    private function reloadOurple(change:Int = 0, fromTop:Bool = false):Void
    {
        var subSpriteName:String = curSkinName;
        var spriteName:String = curOurpleName;
        var path:String = 'skins/' + ((spriteName == 'Ourple' ? 'playguy' : spriteName) + (subSpriteName == 'Normal' ? '' : subSpriteName)).toLowerCase();

        if (Paths.image(path) == null)
        {
            curSkin = 0;
            curSkinName = 'Normal';
            path = 'skins/' + ((curOurpleName == 'Ourple' ? 'playguy' : curOurpleName) + (curSkinName == 'Normal' ? '' : curSkinName)).toLowerCase();
        }
        
        if (ourple != null) {
            FlxTween.cancelTweensOf(ourple, ['x', 'y']);
            if (fromTop) {
                FlxTween.tween(ourple, {y: (change > 0 ? FlxG.height + ourple.height : -FlxG.height - ourple.height)}, 0.2, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween) {
                    destroyAndCreateOurple(path, change, fromTop);
                }});
            } else {
                FlxTween.tween(ourple, {x: (change > 0 ? FlxG.width + ourple.width : -FlxG.width - ourple.width)}, 0.2, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween) {
                    destroyAndCreateOurple(path, change, fromTop);
                }});
            }
        } else {
            destroyAndCreateOurple(path);
        }
    
        if (skinName != null) skinName.destroy();
        skinName = new Alphabet(0, FlxG.height - 200, curSkinName, false);
        skinName.screenCenter(X);
        add(skinName);
    }

    private function destroyAndCreateOurple(path:String, change:Int = 0, fromTop:Bool = false):Void
    {
        if (ourple != null) ourple.destroy();

        ourple = new FlxSprite().loadGraphic(Paths.image(path));
        ourple.x = -FlxG.width - ourple.width;
        ourple.scale.set(2.5, 2.5);
        ourple.updateHitbox();
        insert(members.indexOf(lettabox1), ourple);
        ourple.screenCenter(XY);

        if (fromTop) {
            var yPos:Float = ourple.y;
            ourple.y = (change > 0) ? -FlxG.height - ourple.height : FlxG.height + ourple.height;
            FlxTween.tween(ourple, {y: yPos}, 0.2, {ease: FlxEase.cubeOut});
        } else {
            var xPos:Float = ourple.x;
            ourple.x = (change > 0) ? -FlxG.width - ourple.width : FlxG.width + ourple.width;
            FlxTween.tween(ourple, {x: xPos}, 0.2, {ease: FlxEase.cubeOut});
        }
    }

    private function createBackdrop(image:String, velocityX:Float = 0, velocityY:Float = 0):FlxBackdrop
    {
        var backdrop = new FlxBackdrop(Paths.image(image), X);
        backdrop.scrollFactor.set(0, 0);
        backdrop.velocity.set(velocityX, velocityY);
        return backdrop;
    }

    private function createArrow(flipX:Bool):FlxSprite
    {
        var arrow = new FlxSprite();
        arrow.frames = Paths.getSparrowAtlas('mainmenu/arrows');
        arrow.animation.addByPrefix('i', 'normal', 12);
        arrow.animation.addByPrefix('s', 'press', 12);
        arrow.animation.play('i');
        arrow.scale.set(2, 2);
        arrow.updateHitbox();
        arrow.scrollFactor.set();
        arrow.flipX = flipX;
        arrow.x = flipX ? 0 : FlxG.width - arrow.width;
        arrows.add(arrow);
        return arrow;
    }

    private function createText(x:Int, y:Int, width:Int, text:String):FlxText
    {
        var tutorialTxt = new FlxText(x, y, width, text, 38);
        tutorialTxt.setFormat(Paths.font('ourple.ttf'), 38, 0xFFA04EBA, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
        add(tutorialTxt);
        FlxTween.tween(tutorialTxt, {angle: 10}, 2, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
            FlxTween.angle(tutorialTxt, 10, -10, 2, {ease: FlxEase.sineInOut, type: PINGPONG});
        }});
        return tutorialTxt;
    }

    private function saveOurple():Void
    {
        if (inSelectOurple) 
            ClientPrefs.data.guy = curSelectedOurpleName;
        else
            ClientPrefs.data.ourpleData.set(curOurpleName, curSkinName);

        ClientPrefs.saveSettings();
        CoolUtil.reloadOurpleCursor();

        var saved:Alphabet = new Alphabet(FlxG.width - 375, 40, 'SAVED !', true);
        add(saved);
        FlxTween.tween(saved, {y: saved.y + 75, alpha: 0}, 0.7, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
            saved.destroy();
        }});
    }

    override public function destroy():Void
    {
        ClientPrefs.saveSettings();
        super.destroy();
    }
}