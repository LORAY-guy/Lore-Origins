package options;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.addons.display.FlxBackdrop;

import objects.CheckboxThingie;
import objects.AttachedText;
import options.OurpleOption;
import backend.InputFormatter;
import backend.Controls;

class BaseOptionsMenu extends MusicBeatSubstate
{
	private var curOption:OurpleOption = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<OurpleOption>;

	private var grpOptions:FlxTypedGroup<OptionFlxText>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedFlxText>;
	private var spikes:FlxTypedSpriteGroup<FlxSprite>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	public var bg:FlxSprite;
	public var exitButton:ExitButton;

	public function new()
	{
		super();

		if(title == null) title = 'Options';
		if(rpcTitle == null) rpcTitle = 'Setting the LOOOOOOOOOOOOORE';
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence(rpcTitle, null);
		#end

		var bg = new FlxSprite().loadGraphic(Paths.image('options/bg'));
		bg.setGraphicSize(1280);
		bg.updateHitbox();
		add(bg);
		spikes = new FlxSpriteGroup();
		
		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = FlxG.height - lettabox1.height;
		spikes.add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		spikes.add(lettabox2);

		var guy = new FlxSprite();
		guy.frames = Paths.getSparrowAtlas('options/guy');
		guy.animation.addByPrefix('s','guy g',8);
		guy.animation.play('s');
		guy.y = FlxG.height - guy.height;
		add(guy);

		add(spikes);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<OptionFlxText>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedFlxText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		var titleText = new FlxText(25, 80, 0, title, 32);
		titleText.setFormat(Paths.font("options.ttf"), 40, FlxColor.WHITE, CENTER,FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.alpha = 0.6;
		add(titleText);

		descText = new FlxText(50, 600, 1180, "", 28);
		descText.setFormat(Paths.font("options.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		add(descText);

		for (i in 0...optionsArray.length)
		{
			var optionText = new OptionFlxText(650,0,optionsArray[i].name);
			optionText.startPosition.y = 300;
			optionText.distancePerItem.y = 46.25;
			grpOptions.add(optionText);
			optionText.changeX = false;
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.snapToPosition();

			if(optionsArray[i].type == 'bool') {
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x + optionText.width + 10, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.offsetX = optionText.width + 155;
				checkbox.offsetY = -25;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			} else {
				var valueText:AttachedFlxText = new AttachedFlxText('' + optionsArray[i].getValue(), optionText.width + 10);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();

		exitButton = new ExitButton('options');
		add(exitButton);
	}

	public function addOption(option:OurpleOption) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
		return option;
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	var bindingKey:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:Alphabet;
	var bindingText2:Alphabet;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(bindingKey)
		{
			bindingKeyUpdate(elapsed);
			return;
		}

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK_P) {
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(nextAccept <= 0)
		{
			if(curOption.type == 'bool')
			{
				if(controls.ACCEPT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			}
			else
			{
				if(curOption.type == 'keybind')
				{
					if(controls.ACCEPT_P)
					{
						bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
						bindingBlack.scale.set(FlxG.width, FlxG.height);
						bindingBlack.updateHitbox();
						bindingBlack.alpha = 0;
						FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
						add(bindingBlack);
	
						bindingText = new Alphabet(FlxG.width / 2, 160, "Rebinding " + curOption.name, false);
						bindingText.alignment = CENTERED;
						add(bindingText);
						
						bindingText2 = new Alphabet(FlxG.width / 2, 340, "Hold ESC to Cancel\nHold Backspace to Delete", true);
						bindingText2.alignment = CENTERED;
						add(bindingText2);
	
						bindingKey = true;
						holdingEsc = 0;
						ClientPrefs.toggleVolumeKeys(false);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
				}
				else if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if(holdTime > 0.5 || pressed)
					{
						if(pressed)
						{
							var add:Dynamic = null;
							if(curOption.type != 'string')
								add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;

							switch(curOption.type)
							{
								case 'int' | 'float' | 'percent':
									holdValue = curOption.getValue() + add;
									if(holdValue < curOption.minValue) holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

									switch(curOption.type)
									{
										case 'int':
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);

										case 'float' | 'percent':
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
									}

								case 'string':
									var num:Int = curOption.curOption; //lol
									if(controls.UI_LEFT_P) --num;
									else num++;

									if(num < 0)
										num = curOption.options.length - 1;
									else if(num >= curOption.options.length)
										num = 0;

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); //lol
									//trace(curOption.options[num]);
							}
							updateTextFrom(curOption);
							curOption.change();
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else if(curOption.type != 'string')
						{
							holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
							if(holdValue < curOption.minValue) holdValue = curOption.minValue;
							else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

							switch(curOption.type)
							{
								case 'int':
									curOption.setValue(Math.round(holdValue));
								
								case 'float' | 'percent':
									curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if(curOption.type != 'string')
						holdTime += elapsed;
				}
				else if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
				{
					if(holdTime > 0.5) FlxG.sound.play(Paths.sound('scrollMenu'));
					holdTime = 0;
				}
			}

			if(controls.RESET_P)
			{
				var leOption:OurpleOption = optionsArray[curSelected];
				if(leOption.type != 'keybind')
				{
					leOption.setValue(leOption.defaultValue);
					if(leOption.type != 'bool')
					{
						if(leOption.type == 'string') leOption.curOption = leOption.options.indexOf(leOption.getValue());
						updateTextFrom(leOption);
					}
				}
				else
				{
					leOption.setValue(!Controls.instance.controllerMode ? leOption.defaultKeys.keyboard : leOption.defaultKeys.gamepad);
					updateBind(leOption);
				}
				leOption.change();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
	}

	function bindingKeyUpdate(elapsed:Float)
	{
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
				if (!controls.controllerMode) curOption.keys.keyboard = NONE;
				else curOption.keys.gamepad = NONE;
				updateBind(!controls.controllerMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else
		{
			holdingEsc = 0;
			var changed:Bool = false;
			if(!controls.controllerMode)
			{
				if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
				{
					var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
					var keyReleased:FlxKey = cast (FlxG.keys.firstJustReleased(), FlxKey);

					if(keyPressed != NONE && keyPressed != ESCAPE && keyPressed != BACKSPACE)
					{
						changed = true;
						curOption.keys.keyboard = keyPressed;
					}
					else if(keyReleased != NONE && (keyReleased == ESCAPE || keyReleased == BACKSPACE))
					{
						changed = true;
						curOption.keys.keyboard = keyReleased;
					}
				}
			}
			else if(FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY))
			{
				var keyPressed:FlxGamepadInputID = NONE;
				var keyReleased:FlxGamepadInputID = NONE;
				if(FlxG.gamepads.anyJustPressed(LEFT_TRIGGER))
					keyPressed = LEFT_TRIGGER; //it wasnt working for some reason
				else if(FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER))
					keyPressed = RIGHT_TRIGGER; //it wasnt working for some reason
				else
				{
					for (i in 0...FlxG.gamepads.numActiveGamepads)
					{
						var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
						if(gamepad != null)
						{
							keyPressed = gamepad.firstJustPressedID();
							keyReleased = gamepad.firstJustReleasedID();
							if(keyPressed != NONE || keyReleased != NONE) break;
						}
					}
				}

				if(keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
				{
					changed = true;
					curOption.keys.gamepad = keyPressed;
				}
				else if(keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
				{
					changed = true;
					curOption.keys.gamepad = keyReleased;
				}
			}

			if(changed)
			{
				var key:String = null;
				if(!controls.controllerMode)
				{
					if(curOption.keys.keyboard == null) curOption.keys.keyboard = 'NONE';
					curOption.setValue(curOption.keys.keyboard);
					key = InputFormatter.getKeyName(FlxKey.fromString(curOption.keys.keyboard));
				}
				else
				{
					if(curOption.keys.gamepad == null) curOption.keys.gamepad = 'NONE';
					curOption.setValue(curOption.keys.gamepad);
					key = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(curOption.keys.gamepad));
				}
				updateBind(key);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				closeBinding();
			}
		}
	}

	final MAX_KEYBIND_WIDTH = 320;
	function updateBind(?text:String = null, ?option:OurpleOption = null)
	{
		if(option == null) option = curOption;
		if(text == null)
		{
			text = option.getValue();
			if(text == null) text = 'NONE';

			if(!controls.controllerMode)
				text = InputFormatter.getKeyName(FlxKey.fromString(text));
			else
				text = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(text));
		}

		var bind:AttachedFlxText = cast option.child;
		var attach:AttachedFlxText = new AttachedFlxText(text, bind.offsetX);
		attach.sprTracker = bind.sprTracker;
		attach.copyAlpha = true;
		attach.ID = bind.ID;
		attach.size = Std.int(Math.min(1, MAX_KEYBIND_WIDTH / attach.width));
		attach.x = bind.x;
		attach.y = bind.y;

		option.child = attach;
		grpTexts.insert(grpTexts.members.indexOf(bind), attach);
		grpTexts.remove(bind);
		bind.destroy();
	}

	function closeBinding()
	{
		bindingKey = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.toggleVolumeKeys(true);
	}

	function updateTextFrom(option:OurpleOption) {
		if(option.type == 'keybind')
		{
			updateBind(option);
			return;
		}

		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == 'percent') val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		else if (curSelected >= optionsArray.length)
			curSelected = 0;

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		var bullShit:Int = 0;

		for (i in grpOptions.members) {
			i.targetY = bullShit - curSelected;
			bullShit++;

			i.alpha = 0.8;
			i.color = FlxColor.WHITE;
			i.borderColor = FlxColor.BLACK;
			if (i.targetY == 0) {
				i.alpha = 1;
				i.color = 0xFFA04EBA;
				i.borderColor = 0xFFFFFFFF;
			}
		}

		for (text in grpTexts) {
			text.alpha = 0.8;
			text.color = FlxColor.WHITE;
			text.borderColor = FlxColor.BLACK;
			if(text.ID == curSelected) {
				text.alpha = 1;
				text.color = 0xFFA04EBA;
				text.borderColor = 0xFFFFFFFF;
			}
		}

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		curOption = optionsArray[curSelected]; //shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
	}
}

class AttachedFlxText extends FlxText
{
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sprTracker:FlxSprite;
	public var copyVisible:Bool = true;
	public var copyAlpha:Bool = false;

	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0,?size:Int = 40, ?bold = 1) {
		super(0, 0, text, bold);

		setFormat(Paths.font("options.ttf"), size, FlxColor.WHITE, CENTER,FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if (copyVisible) visible = sprTracker.visible;
			if (copyAlpha) alpha = sprTracker.alpha;
		}

		super.update(elapsed);
	}
}

class OptionFlxText extends FlxText { //im honestly so fucking lost as to why i never did this before
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var isMenuItem:Bool = false;
	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); //for the calculations
	public var snapPosOnly:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?font:String = 'options.ttf',?size:Int = 40)
	{
		super(x, y);
		this.font = Paths.font(font);
		this.borderStyle = FlxTextBorderStyle.OUTLINE;
		this.borderColor = FlxColor.BLACK;
		this.startPosition.x = x;
		this.startPosition.y = y;
		this.text = text;
		this.size = size;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			if (!snapPosOnly) {
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
				if(changeX) x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
				if(changeY) y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
			}
			else {
				if(changeX) x = (targetY * distancePerItem.x) + startPosition.x;
				if(changeY) y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
			}
		}
		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if(changeX) x = (targetY * distancePerItem.x) + startPosition.x;
			if(changeY) y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}
}