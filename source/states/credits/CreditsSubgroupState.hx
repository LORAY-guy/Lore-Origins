package states.credits;

import backend.Highscore;
import backend.Song;

import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;

class CreditsSubgroupState extends MusicBeatState
{
    public static var subGroups:Array<String> = ['Lore Origins', 'Composers', 'Assets', 'Psych Engine'];
    public static var curSubGroup:Int = 0;
	private static var curSelected:Int = 0;

	public var subGroupsNames:FlxTypedGroup<Alphabet>;

	var keypad:Keypad;
	var cameraId:FlxSprite;

    var exitButton:ExitButton;

    override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Credits Subgroup Menu", null);
		#end

		Paths.clearUnusedMemory();
        if (FlxG.camera.visible == false) FlxG.camera.visible = true;

        persistentUpdate = persistentDraw = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0, 0);
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);

		#if desktop
		keypad = new Keypad(40, FlxG.height - 500);
		add(keypad);

		cameraId = new FlxSprite().loadGraphic(Paths.image('credits/keypad/cameraId'));
		cameraId.setPosition(20, FlxG.height - cameraId.height * 2);
		cameraId.alpha = 0.5;
		add(cameraId);
		#end

        subGroupsNames = new FlxTypedGroup<Alphabet>();
        add(subGroupsNames);

        for (i in 0...subGroups.length)
        {
            var offset:Float = (i * 140) + (48 * (subGroups.length - 4) * 0.135);
            var subGroup:Alphabet = new Alphabet(0, offset + 75, subGroups[i], true);
            subGroup.scrollFactor.set(0, 1);
            subGroup.updateHitbox();
            subGroup.screenCenter(X);
            subGroup.ID = i;
            subGroupsNames.add(subGroup);
        }

		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = 635;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);

        changeSelection();
		
		#if desktop if (!FlxG.mouse.visible) FlxG.mouse.visible = true; #end
        super.create();

        exitButton = new ExitButton();
		add(exitButton);
    }

	public var selectedSomethin:Bool = false;
	public var canClick:Bool = true;
    override public function update(elapsed:Float)
	{
		if (!selectedSomethin)
		{
			if (controls.UI_UP_P) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
			}
			if (FlxG.mouse.wheel != 0) {
				changeSelection(-FlxG.mouse.wheel);
			}
			if (controls.BACK_P) {
				selectedSomethin = true;
				FlxG.camera.zoom += 0.06;
				exitState(new MainMenuState(true));
			}
			if (controls.ACCEPT_P || (!FlxG.mouse.overlaps(exitButton) && #if desktop !FlxG.mouse.overlaps(keypad) && #end FlxG.mouse.justPressed)) {
				selectedSomethin = true;
				canClick = false;

				FlxG.camera.zoom += 0.06;
				FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut});

				FlxG.sound.play(Paths.sound('confirmMenu'));
				
                subGroupsNames.forEach(function(spr:Alphabet) {
                    if (spr.ID == curSelected) {
                        FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
                            MusicBeatState.switchState(new CreditsState(true));
                        });
                    } else {
                        FlxTween.tween(spr, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){spr.destroy();}});
                    } 
                });
			}
		}
        curSubGroup = curSelected;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));

		#if desktop
		cameraId.alpha = FlxMath.lerp(0, cameraId.alpha, Math.exp(-elapsed * 2));

		if (FlxG.mouse.justMoved) {
			cameraId.alpha += 0.05;
		}

		if (FlxG.mouse.overlaps(cameraId) && !keypad.playingAnimation) {
			if (keypad.opened) keypad.closeHandUnit();
			else keypad.openHandUnit();
		}
		#end

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) 
	{
		FlxG.camera.zoom += 0.03;

        for (letter in subGroupsNames.members[curSelected].letters) letter.color = 0xFFFFFFFF;

		curSelected += change;

		if (curSelected >= subGroups.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = subGroups.length - 1;

        for (letter in subGroupsNames.members[curSelected].letters) letter.color = 0xFFA357AB;
        
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

class Keypad extends FlxTypedGroup<FlxSprite>
{
    public var handunit:FlxSprite;

    public var enteredCode:String = "";
    private var codeDisplay:FlxText;

    private var buttonSprites:Array<FlxSprite>;
    private var buttonImages:Array<String> = [
        "keypad1", "keypad2", "keypad3",
        "keypad4", "keypad5", "keypad6",
        "keypad7", "keypad8", "keypad9",
                   "keypad0"
    ];

    private var dotSprites:Array<FlxSprite> = [];

    private var startX:Float;
    private var startY:Float;
    private var buttonSize:Int;
    private var padding:Int;

    public var opened:Bool = false;
    public var playingAnimation:Bool = false;

    public function new(x:Float, y:Float):Void
    {
        super();
        startX = x;
        startY = y;
        buttonSize = 50;
        padding = 10;

        createHandunit();
        createButtons();
        createDotDisplay();
    }

    private function createHandunit():Void 
    {
        handunit = new FlxSprite();
        handunit.frames = Paths.getSparrowAtlas('credits/keypad/handunit');
        handunit.animation.addByPrefix('Idle', 'Idle', 24, false);
        handunit.animation.finishCallback = function(name:String) {
            if (!handunit.animation.curAnim.reversed) {
                for (button in buttonSprites) {
                    button.visible = true;
                }
                for (dot in dotSprites) {
                    dot.visible = true;
                }
            } else {
                handunit.visible = false;
            }
            playingAnimation = false;
        };
        handunit.x = startX - 10;
        handunit.y = startY;
        handunit.visible = false;
        handunit.antialiasing = ClientPrefs.data.antialiasing;
        add(handunit);
    }

    public function openHandUnit():Void 
    {
        playingAnimation = true;
        opened = true;
        handunit.visible = true;
        handunit.animation.play('Idle');
        FlxG.sound.play(Paths.sound('keypad/open'), 0.9);
    }
    
    public function closeHandUnit():Void
    {
        playingAnimation = true;
        for (button in buttonSprites) {
            button.visible = false;
        }
        for (dot in dotSprites) {
            dot.visible = false;
        }
        handunit.animation.play('Idle', false, true);
        FlxG.sound.play(Paths.sound('keypad/open'), 0.9);
        opened = false;
    }

    private function createButtons():Void {
        buttonSprites = [];

        // Keypad layout: 1-3 on first row, 4-6 on second row, 7-9 on third row, 0 on fourth row centered
        for (i in 0...buttonImages.length) {
            var buttonX:Float;
            var buttonY:Float;

            if (i == 9) { // Place '0' button
                buttonX = startX + buttonSize + padding;
                buttonY = startY + 3 * (buttonSize + padding);
            } else { // Place other buttons
                buttonX = startX + (i % 3) * (buttonSize + padding);
                buttonY = startY + Math.floor(i / 3) * (buttonSize + padding);
            }

            var btn:FlxSprite = new FlxSprite(buttonX + 200, buttonY + 165).loadGraphic(Paths.image('credits/keypad/' + buttonImages[i]));
            btn.setGraphicSize(buttonSize, buttonSize);
            btn.updateHitbox();
            btn.ID = i;
            btn.visible = false;
            btn.antialiasing = false;
            buttonSprites.push(btn);
            add(btn);
        }
    }

    private function createDotDisplay():Void
    {
        for (i in 0...6)
        {
            var dotX:Float = startX + i * (buttonSize / 2 + padding / 2) + 155;
            var dotY:Float = startY + 140;

            var dot:FlxSprite = new FlxSprite(dotX, dotY);
            dot.loadGraphic(Paths.image('credits/keypad/dot'));
            dot.setGraphicSize(buttonSize / 2, buttonSize / 2);
            dot.updateHitbox();
            dot.alpha = 0;
            dot.antialiasing = false;

            dotSprites.push(dot);
            add(dot);
        }
    }

    private function onButtonClick(number:Int):Void 
    {
        if (enteredCode.length < dotSprites.length) {
            enteredCode += Std.string(number);
            dotSprites[enteredCode.length - 1].alpha = 1;
        }

        FlxG.sound.play(Paths.soundRandom('keypad/input', 1, 2));

        switch (enteredCode)
        {
            case '395248':
                CoolUtil.openMinigame();
            case '555882':
                trace('play secret Lua song');
            case '205777':
                resetCode(false);
                PlayState.SONG = Song.loadFromJson('distractible', 'distractible', PlayState.isCover);
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = 0;

                FlxG.camera.zoom += 0.06;
                FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
                    LoadingState.loadAndSwitchState(new PlayState());
                }});

                FlxG.sound.music.fadeOut(1.2, 0, function(twn:FlxTween) {FlxG.sound.music.stop();});
            case '69420':
                trace('lol');
                FlxG.sound.play(Paths.sound('keypad/69420'));
                resetCode(false);
        }

        if (enteredCode.length == 6) {
            resetCode();
            return;
        }
    }

    private function resetCode(playSound:Bool = true):Void 
    {
        enteredCode = "";
        for (dot in dotSprites) {
            dot.alpha = 0;
        }
        if (playSound) FlxG.sound.play(Paths.sound('keypad/denied'));
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        for (btn in buttonSprites) {
            if (FlxG.mouse.justPressed && btn.overlapsPoint(FlxG.mouse.getScreenPosition())) {
                onButtonClick(btn.ID == 9 ? 0 : btn.ID + 1);
            }
        }

        updateInput();
    }

    public function updateInput():Void
    {
        if (FlxG.keys.justPressed.NUMPADZERO) onButtonClick(0);
        if (FlxG.keys.justPressed.NUMPADONE) onButtonClick(1);
        if (FlxG.keys.justPressed.NUMPADTWO) onButtonClick(2);
        if (FlxG.keys.justPressed.NUMPADTHREE) onButtonClick(3);
        if (FlxG.keys.justPressed.NUMPADFOUR) onButtonClick(4);
        if (FlxG.keys.justPressed.NUMPADFIVE) onButtonClick(5);
        if (FlxG.keys.justPressed.NUMPADSIX) onButtonClick(6);
        if (FlxG.keys.justPressed.NUMPADSEVEN) onButtonClick(7);
        if (FlxG.keys.justPressed.NUMPADEIGHT) onButtonClick(8);
        if (FlxG.keys.justPressed.NUMPADNINE) onButtonClick(9);
    }
}