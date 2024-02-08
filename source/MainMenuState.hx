package;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end

import editors.MasterEditorMenu;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxSound;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;

#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is used for Discord RPC
	public static var loreVersion:String = '1.5.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	private var inputBuffer:String = "";
	var charles:FlxSprite;
	var playedSound:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	
	var optionShit:Array<String> = [
		'lore',
		'credits',
		'options'
	];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Lore Menu", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		Conductor.changeBPM(130);
		persistentUpdate = persistentDraw = true;

		//var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.5));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
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
		lettabox1.y = 635;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 92 - (Math.max(optionShit.length, 4) - 4) * 80;
			var sizeOffset:Float = 1;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 150) + offset);
			if (optionShit[i] == 'lore') 
			{
				sizeOffset = 1.15;
				menuItem.y -= 15;
			}
			menuItem.scale.x = scale * sizeOffset;
			menuItem.scale.y = scale * sizeOffset;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('ourple.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Lore Origins v" + loreVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('ourple.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		/*charles = new FlxSprite(-800, -100);
		charles.scale.x = 0.5;
		charles.scale.y = 0.5;
		charles.updateHitbox();
		charles.frames = Paths.getSparrowAtlas('charles');
		charles.animation.addByPrefix('idle', 'idle', 24, false);
		charles.animation.addByPrefix('oh', 'oh', 24, false);
		charles.animation.addByPrefix('perfect', 'perfect', 24, false);*/

		// NG.core.calls.event.logEvent('swag').send();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		changeItem();

		//if (FlxG.save.data.henryUnlocked) unlockCharles();

		super.create();
	}

	var selectedSomethin:Bool = false;

	public var usingMouse:Bool = false;
	public var canClick:Bool = true;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (controls.UI_UP_P || controls.UI_DOWN_P)
			usingMouse = false;
		else if (FlxG.mouse.overlaps(menuItems))
			usingMouse = true;

		if (!selectedSomethin)
		{
			if (usingMouse)
			{
				menuItems.forEach(function(spr:FlxSprite)
				{
					if (FlxG.mouse.overlaps(spr, camGame))
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

							menuItems.forEach(function(spr:FlxSprite)
							{
								if (curSelected != spr.ID)
								{
									FlxTween.tween(spr, {alpha: 0}, 0.4, {
										ease: FlxEase.quadOut,
										onComplete: function(twn:FlxTween)
										{
											spr.kill();
										}
									});
								}
							});

							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'lore':
										MusicBeatState.switchState(new FreeplaySelectState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					} 
					else if (spr.animation.curAnim.name != 'idle')
					{
						spr.animation.play('idle');
						spr.updateHitbox();
					}
				});
			} 
			else 
			{
				if (controls.UI_UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
	
				if (controls.UI_DOWN_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
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

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'lore':
									MusicBeatState.switchState(new FreeplaySelectState());
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options':
									LoadingState.loadAndSwitchState(new options.OptionsState());
							}
						});
					}
				});
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			if (charles != null)
			{
				if (FlxG.mouse.overlaps(charles, camGame))
				{
					if (!playedSound) FlxG.sound.play(Paths.sound('scrollMenu'));
					playedSound = true;
					if (FlxG.mouse.pressed && canClick)
					{
						FlxG.sound.play(Paths.sound('plan'), 1, false);
						charles.animation.play('perfect', true, false, 0);
						selectedSomethin = true;
						canClick = FlxG.mouse.visible = false;

						menuItems.forEach(function(spr:FlxSprite)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						});

						new FlxTimer().start(1.2, function(tmr:FlxTimer) {
							PlayState.SONG = Song.loadFromJson('lore-plan', 'lore-plan');
							PlayState.storyDifficulty = 2;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					}
				} else playedSound = false;
			}
		}

		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}

	private function onKeyDown(e:KeyboardEvent):Void 
	{
        var keyCode:Int = e.keyCode;
        
        if ((keyCode >= Keyboard.A && keyCode <= Keyboard.Z) || keyCode == Keyboard.BACKSPACE) 
            handleInput(e.charCode);
    }

    private function handleInput(charCode:Int):Void 
	{
        var char:String = String.fromCharCode(charCode).toLowerCase();

        if (charCode == Keyboard.BACKSPACE && inputBuffer.length > 0) {
            inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
        } else {
            inputBuffer += char;
        }

        if (inputBuffer == "henry" && !FlxG.save.data.henryUnlocked) //Making the check here in case i'll add another secret word later
			//unlockCharles(true);
        
		
		if (inputBuffer.length > 4)
			inputBuffer = "";
    }

	function unlockCharles(unlock:Bool = false)
	{
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			FlxG.sound.play(Paths.sound('oh'), 1, false);
			if (unlock) FlxG.save.data.henryUnlocked = true;

			add(charles);

			FlxTween.tween(charles, {x: -270}, 0.5, {ease: FlxEase.sineInOut});
			charles.animation.play('oh', false, false, 0);
		});
	}

	override function beatHit()
	{
		super.beatHit();

		if (charles != null && curBeat % 2 == 0 && canClick) charles.animation.play('idle', false);
	}
}
