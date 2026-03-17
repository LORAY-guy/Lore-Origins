package options;

import backend.InputFormatter;
import objects.AttachedSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class ControlsSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;
	var curAlt:Bool = false;

	//Show on gamepad - Display name - Save file key - Rebind display name
	var options:Array<Dynamic> = [
		[true, 'NOTES'],
		[true, 'Left', 'note_left', 'Note Left'],
		[true, 'Down', 'note_down', 'Note Down'],
		[true, 'Up', 'note_up', 'Note Up'],
		[true, 'Right', 'note_right', 'Note Right'],
		[true],
		[true, 'UI'],
		[true, 'Left', 'ui_left', 'UI Left'],
		[true, 'Down', 'ui_down', 'UI Down'],
		[true, 'Up', 'ui_up', 'UI Up'],
		[true, 'Right', 'ui_right', 'UI Right'],
		[true],
		[true, 'Reset', 'reset', 'Reset'],
		[true, 'Accept', 'accept', 'Accept'],
		[true, 'Back', 'back', 'Back'],
		[true, 'Pause', 'pause', 'Pause'],
		[false],
		[false, 'VOLUME'],
		[false, 'Mute', 'volume_mute', 'Volume Mute'],
		[false, 'Up', 'volume_up', 'Volume Up'],
		[false, 'Down', 'volume_down', 'Volume Down'],
		[false],
		[false, 'DEBUG'],
		[false, 'Key 1', 'debug_1', 'Debug Key #1'],
		[false, 'Key 2', 'debug_2', 'Debug Key #2'],
		[false],
		[false, 'LORE ORIGINS'],
		[false, 'Skins', 'skins', 'Skins']
	];
	var curOptions:Array<Int>;
	var curOptionsValid:Array<Int>;
	static var defaultKey:String = 'Reset to Default Keys';

	var grpDisplay:FlxTypedGroup<ControlText>;
	var grpBlacks:FlxTypedGroup<AttachedSprite>;
	var grpOptions:FlxTypedGroup<ControlText>;
	var grpBinds:FlxTypedGroup<ControlText>;
	var selectSpr:AttachedSprite;

	var gamepadColor:FlxColor = 0xfffd7194;
	var keyboardColor:FlxColor = 0xff7192fd;
	var onKeyboardMode:Bool = true;
	
	var controllerSpr:FlxSprite;
	
	public function new()
	{
		super();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Controls Menu", null);
		#end

		options.push([true]);
		options.push([true]);
		options.push([true, defaultKey]);

		grpDisplay = new FlxTypedGroup<ControlText>();
		add(grpDisplay);
		grpOptions = new FlxTypedGroup<ControlText>();
		add(grpOptions);
		grpBlacks = new FlxTypedGroup<AttachedSprite>();
		add(grpBlacks);
		selectSpr = new AttachedSprite();
		selectSpr.makeGraphic(250, 78, FlxColor.WHITE);
		selectSpr.copyAlpha = false;
		selectSpr.alpha = 0.75;
		add(selectSpr);
		grpBinds = new FlxTypedGroup<ControlText>();
		add(grpBinds);

		controllerSpr = new FlxSprite(50, 40).loadGraphic(Paths.image('controllertype'), true, 82, 60);
		controllerSpr.antialiasing = ClientPrefs.data.antialiasing;
		controllerSpr.animation.add('keyboard', [0], 1, false);
		controllerSpr.animation.add('gamepad', [1], 1, false);
		add(controllerSpr);

		var text:ControlText = new ControlText(42, 100, 200, 'CTRL', 36, FlxColor.WHITE, FlxTextAlign.LEFT);
		text.antialiasing = false;
		add(text);

		createTexts();

		add(new ExitButton('options'));
	}

	private var lastID:Int = 0;
	private function createTexts():Void
	{
		curOptions = [];
		curOptionsValid = [];
		grpDisplay.forEachAlive(function(text:ControlText) text.destroy());
		grpBlacks.forEachAlive(function(black:AttachedSprite) black.destroy());
		grpOptions.forEachAlive(function(text:ControlText) text.destroy());
		grpBinds.forEachAlive(function(text:ControlText) text.destroy());
		grpDisplay.clear();
		grpBlacks.clear();
		grpOptions.clear();
		grpBinds.clear();

		var myID:Int = 0;
		for (i in 0...options.length)
		{
			var option:Array<Dynamic> = options[i];
			if(option[0] || onKeyboardMode)
			{
				if(option.length > 1)
				{
					var isCentered:Bool = (option.length < 3);
					var isDefaultKey:Bool = (option[1] == defaultKey);
					var isDisplayKey:Bool = (isCentered && !isDefaultKey);

					var text:ControlText = new ControlText(200, 240, FlxG.width - 400, option[1], 32, FlxColor.WHITE, isCentered ? FlxTextAlign.CENTER : FlxTextAlign.LEFT);
					text.bold = true;
					text.isMenuItem = true;
					text.changeX = false;
					text.distancePerItem.y = 60;
					text.targetY = myID;
					if(isDisplayKey)
						grpDisplay.add(text);
					else {
						grpOptions.add(text);
						curOptions.push(i);
						curOptionsValid.push(myID);
					}
					text.ID = myID;
					lastID = myID;

					if(isCentered) addCenteredText(text, option, myID);
					else addKeyText(text, option, myID);

					text.snapToPosition();
					text.y += FlxG.height * 2;
				}
				myID++;
			}
		}
		updateText();
	}

	private function addCenteredText(text:ControlText, option:Array<Dynamic>, id:Int):Void
	{
		text.size += 4;
		text.screenCenter(X);
		text.y -= (text.text == defaultKey) ? 60 : 20;
		text.startPosition.y -= (text.text == defaultKey) ? 60 : 20;
		text.borderSize = 2;
	}

	private function addKeyText(text:ControlText, option:Array<Dynamic>, id:Int):Void
	{
		for (n in 0...2)
		{
			var textX:Float = 350 + n * 300;

			var key:String = null;
			if(onKeyboardMode)
			{
				var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option[2]);
				key = InputFormatter.getKeyName((savKey[n] != null) ? savKey[n] : NONE);
			}
			else
			{
				var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option[2]);
				key = InputFormatter.getGamepadName((savKey[n] != null) ? savKey[n] : NONE);
			}

			var attach:ControlText = new ControlText(textX + 210, 248, 230, key, 32, FlxColor.WHITE, FlxTextAlign.CENTER);
			attach.isMenuItem = true;
			attach.changeX = false;
			attach.distancePerItem.y = 60;
			attach.targetY = text.targetY;
			attach.ID = Math.floor(grpBinds.length / 2);
			attach.snapToPosition();
			attach.y += FlxG.height * 2;
			grpBinds.add(attach);
			//attach.text = key;

			// spawn black bars at the right of the key name
			var black:AttachedSprite = new AttachedSprite();
			black.makeGraphic(250, 78, FlxColor.BLACK);
			black.alphaMult = 0.4;
			black.sprTracker = text;
			black.yAdd = -6;
			black.xAdd = textX;
			grpBlacks.add(black);
		}
	}

	private function updateBind(num:Int, text:String):Void
	{
		var bind:ControlText = grpBinds.members[num];
		var attach:ControlText = new ControlText(350 + (num % 2) * 300, 248, 230, text, 32, FlxColor.WHITE, FlxTextAlign.CENTER);
		attach.isMenuItem = true;
		attach.changeX = false;
		attach.distancePerItem.y = 60;
		attach.targetY = bind.targetY;
		attach.ID = bind.ID;
		attach.x = bind.x;
		attach.y = bind.y;

		bind.kill();
		grpBinds.remove(bind);
		grpBinds.insert(num, attach);
		bind.destroy();
	}

	private var binding:Bool = false;
	private var holdingEsc:Float = 0;
	private var bindingBlack:FlxSprite;
	private var bindingText:ControlText;
	private var bindingText2:ControlText;

	private var timeForMoving:Float = 0.1;
	override public function update(elapsed:Float):Void
	{
		if(timeForMoving > 0) //Fix controller bug
		{
			timeForMoving = Math.max(0, timeForMoving - elapsed);
			super.update(elapsed);
			return;
		}

		if(!binding)
		{
			if(FlxG.keys.justPressed.ESCAPE || FlxG.gamepads.anyJustPressed(B))
			{
				close();
				return;
			}
			if(FlxG.keys.justPressed.CONTROL || FlxG.gamepads.anyJustPressed(LEFT_SHOULDER) || FlxG.gamepads.anyJustPressed(RIGHT_SHOULDER)) swapMode();

			if(FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT || FlxG.gamepads.anyJustPressed(DPAD_LEFT) || FlxG.gamepads.anyJustPressed(DPAD_RIGHT) ||
				FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_LEFT) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_RIGHT)) updateAlt(true);

			if(FlxG.keys.justPressed.UP || FlxG.gamepads.anyJustPressed(DPAD_UP) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_UP)) updateText(-1);
			else if(FlxG.keys.justPressed.DOWN || FlxG.gamepads.anyJustPressed(DPAD_DOWN) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_DOWN)) updateText(1);

			if(FlxG.keys.justPressed.ENTER || FlxG.gamepads.anyJustPressed(START) || FlxG.gamepads.anyJustPressed(A))
			{
				if(options[curOptions[curSelected]][1] != defaultKey)
				{
					bindingBlack = new FlxSprite().makeGraphic(1, 1, /*FlxColor.BLACK*/ FlxColor.WHITE);
					bindingBlack.scale.set(FlxG.width, FlxG.height);
					bindingBlack.updateHitbox();
					bindingBlack.alpha = 0;
					FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
					add(bindingBlack);

					bindingText = new ControlText(0, 160, FlxG.width, "Rebinding " + options[curOptions[curSelected]][3], 48, FlxColor.WHITE, FlxTextAlign.CENTER);
					add(bindingText);
					bindingText2 = new ControlText(0, 340, FlxG.width, "Hold ESC to Cancel\nHold Backspace to Delete", 32, FlxColor.WHITE, FlxTextAlign.CENTER);
					add(bindingText2);

					binding = true;
					holdingEsc = 0;
					ClientPrefs.toggleVolumeKeys(false);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				else
				{
					// Reset to Default
					ClientPrefs.resetKeys(!onKeyboardMode);
					ClientPrefs.reloadVolumeKeys();
					var lastSel:Int = curSelected;
					createTexts();
					curSelected = lastSel;
					updateText();
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			}
		}
		else
		{
			var altNum:Int = curAlt ? 1 : 0;
			var curOption:Array<Dynamic> = options[curOptions[curSelected]];
			if(FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
			{
				holdingEsc += elapsed;
				if(holdingEsc > 0.5)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					closeBinding();
				}
			}
			else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
			{
				holdingEsc += elapsed;
				if(holdingEsc > 0.5)
				{
					ClientPrefs.keyBinds.get(curOption[2])[altNum] = NONE;
					ClientPrefs.clearInvalidKeys(curOption[2]);
					updateBind(Math.floor(curSelected * 2) + altNum, onKeyboardMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
					FlxG.sound.play(Paths.sound('cancelMenu'));
					closeBinding();
				}
			}
			else
			{
				holdingEsc = 0;
				var changed:Bool = false;
				var curKeys:Array<FlxKey> = ClientPrefs.keyBinds.get(curOption[2]);
				var curButtons:Array<FlxGamepadInputID> = ClientPrefs.gamepadBinds.get(curOption[2]);

				if(onKeyboardMode)
				{
					if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
					{
						var keyPressed:Int = FlxG.keys.firstJustPressed();
						var keyReleased:Int = FlxG.keys.firstJustReleased();
						if (keyPressed > -1 && keyPressed != FlxKey.ESCAPE && keyPressed != FlxKey.BACKSPACE)
						{
							curKeys[altNum] = keyPressed;
							changed = true;
						}
						else if (keyReleased > -1 && (keyReleased == FlxKey.ESCAPE || keyReleased == FlxKey.BACKSPACE))
						{
							curKeys[altNum] = keyReleased;
							changed = true;
						}
					}
				}
				else if(FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY))
				{
					var keyPressed:Null<FlxGamepadInputID> = NONE;
					var keyReleased:Null<FlxGamepadInputID> = NONE;
					if(FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)) keyPressed = LEFT_TRIGGER; //it wasnt working for some reason
					else if(FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)) keyPressed = RIGHT_TRIGGER; //it wasnt working for some reason
					else
					{
						for (i in 0...FlxG.gamepads.numActiveGamepads)
						{
							var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
							if(gamepad != null)
							{
								keyPressed = gamepad.firstJustPressedID();
								keyReleased = gamepad.firstJustReleasedID();

								if(keyPressed == null) keyPressed = NONE;
								if(keyReleased == null) keyReleased = NONE;
								if(keyPressed != NONE || keyReleased != NONE) break;
							}
						}
					}

					if (keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
					{
						curButtons[altNum] = keyPressed;
						changed = true;
					}
					else if (keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
					{
						curButtons[altNum] = keyReleased;
						changed = true;
					}
				}

				if(changed)
				{
					if (onKeyboardMode)
					{
						if(curKeys[altNum] == curKeys[1 - altNum])
							curKeys[1 - altNum] = FlxKey.NONE;
					}
					else
					{
						if(curButtons[altNum] == curButtons[1 - altNum])
							curButtons[1 - altNum] = FlxGamepadInputID.NONE;
					}

					var option:String = options[curOptions[curSelected]][2];
					ClientPrefs.clearInvalidKeys(option);
					for (n in 0...2)
					{
						var key:String = null;
						if(onKeyboardMode)
						{
							var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option);
							key = InputFormatter.getKeyName(savKey[n] != null ? savKey[n] : NONE);
						}
						else
						{
							var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option);
							key = InputFormatter.getGamepadName(savKey[n] != null ? savKey[n] : NONE);
						}
						updateBind(Math.floor(curSelected * 2) + n, key);
					}
					FlxG.sound.play(Paths.sound('confirmMenu'));
					closeBinding();
				}
			}
		}
		super.update(elapsed);
	}

	private function closeBinding():Void
	{
		binding = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.reloadVolumeKeys();
	}

	private function updateText(?move:Int = 0):Void
	{
		if(move != 0)
		{
			//var dir:Int = Math.round(move / Math.abs(move));
			curSelected += move;

			if(curSelected < 0) curSelected = curOptions.length - 1;
			else if (curSelected >= curOptions.length) curSelected = 0;
		}

		var num:Int = curOptionsValid[curSelected];
		var addNum:Int = 0;
		if(num < 3) addNum = 3 - num;
		else if(num > lastID - 4) addNum = (lastID - 4) - num;

		grpDisplay.forEachAlive(function(item:ControlText) {
			item.targetY = item.ID - num - addNum;
		});

		grpOptions.forEachAlive(function(item:ControlText)
		{
			item.targetY = item.ID - num - addNum;
			item.alpha = (item.ID == num) ? 1 : 0.6;
		});
		grpBinds.forEachAlive(function(item:ControlText)
		{
			var parent:ControlText = grpOptions.members[item.ID];
			item.targetY = parent.targetY;
			item.alpha = parent.alpha;
		});

		updateAlt();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function swapMode():Void
	{
		onKeyboardMode = !onKeyboardMode;

		curSelected = 0;
		curAlt = false;
		controllerSpr.animation.play(onKeyboardMode ? 'keyboard' : 'gamepad');
		createTexts();
	}

	private function updateAlt(?doSwap:Bool = false):Void
	{
		if(doSwap)
		{
			curAlt = !curAlt;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		selectSpr.sprTracker = grpBlacks.members[Math.floor(curSelected * 2) + (curAlt ? 1 : 0)];
		selectSpr.visible = (selectSpr.sprTracker != null);
	}
}

class ControlText extends FlxText
{
	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);

	public function new(x:Float, y:Float, width:Float, text:String, size:Int = 32, color:Int = 0xFFFFFFFF, alignment:FlxTextAlign = LEFT)
	{
		super(x, y, width, text, size);

		this.setFormat(#if html5 Paths.font("ourple.ttf") #else Paths.font("options.ttf") #end, size, color, alignment, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		this.startPosition.x = x;
		this.startPosition.y = y;
		this.borderSize = 1;
	}

	override public function update(elapsed:Float)
	{
		if (isMenuItem) {
			var lerpVal:Float = Math.exp(-elapsed * 9.6);
			if (changeX)
				x = FlxMath.lerp((targetY * distancePerItem.x) + startPosition.x, x, lerpVal);
			if (changeY)
				y = FlxMath.lerp((targetY * 1.3 * distancePerItem.y + 90) + startPosition.y, y, lerpVal);
		}
		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem) {
			if (changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if (changeY)
				y = (targetY * 1.3 * distancePerItem.y + 90) + startPosition.y;
		}
	}
}
