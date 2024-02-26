package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;

import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is used for Discord RPC
	public static var loreVersion:String = '1.6.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'lore',
		'options',
		'credits'
	];

	private var camGame:FlxCamera;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Lore Menu", null);
		#end

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var xScroll:Float = Math.min(0.1 - (0.05 * (optionShit.length - 4)), 0.01);
		if (xScroll < 0) xScroll = 0;
		var bg:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set(xScroll, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.7));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

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

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1.4;

		for (i in 0...optionShit.length)
		{
			var offset:Float = (i * 410) + (48 * (optionShit.length - 4) * 0.135);
			var menuItem:FlxSprite = new FlxSprite(offset + 125, 128);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + '_idle', 8);
			menuItem.animation.addByPrefix('selected', optionShit[i] + '_s', 8);
			menuItem.animation.play('idle');
			menuItem.updateHitbox();
			menuItem.centerOffsets();
			menuItem.ID = i;
			menuItems.add(menuItem);

			var scr:Float = (optionShit.length < 4) ? 0 : 1;
			menuItem.scrollFactor.set(scr, 0.25);
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font('ourple.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var loreVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Lore Origins v" + loreVersion, 12);
		loreVer.scrollFactor.set();
		loreVer.setFormat(Paths.font('ourple.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loreVer);

		changeItem();
		super.create();

		#if !html5 if (!FlxG.mouse.visible) FlxG.mouse.visible = true; #end
	}

	var selectedSomethin:Bool = false;

	public var usingMouse:Bool = false;
	public var canClick:Bool = true;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			usingMouse = false;
		else
			usingMouse = (FlxG.mouse.overlaps(menuItems));
		
		if (!selectedSomethin)
		{
			if (usingMouse)
			{
				menuItems.forEach(function(spr:FlxSprite)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						curSelected = spr.ID;

						if (spr.animation.curAnim.name != 'selected')
						{
							FlxG.sound.play(Paths.sound('scrollMenu'));
							spr.animation.play('selected');

							var add:Float = 0;
							if(menuItems.length > 4) {
								add = menuItems.length * 8;
							}
							camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
							spr.centerOffsets();
						}

						if (FlxG.mouse.pressed)
						{
							selectedSomethin = true;
							canClick = false;
							FlxG.sound.play(Paths.sound('confirmMenu'));
							processItems();
						}
					} 
					else if (spr.animation.curAnim.name != 'idle')
					{
						spr.animation.play('idle');
						spr.updateHitbox();
					}
				});
			} else {
				if (controls.UI_LEFT_P)
					changeItem(-1);
	
				if (controls.UI_RIGHT_P)
					changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				processItems();
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}

	private function processItems():Void
	{
		menuItems.forEach(function(spr:FlxSprite) {
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, { alpha: 0 }, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				if (spr.animation.curAnim.name != 'selected') spr.animation.play('selected');
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					var daChoice:String = optionShit[curSelected];
		
					switch (daChoice)
					{
						case 'lore':
							MusicBeatState.switchState(new states.FreeplaySelectState());
						case 'credits':
							MusicBeatState.switchState(new states.credits.CreditsState());
						case 'options':
							LoadingState.loadAndSwitchState(new options.OptionsState());
					}
				});
			}
		});
	}
}