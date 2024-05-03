package states;

import backend.ExitButton;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;

class FreeplaySelectState extends MusicBeatState
{
    public static var freeplayCats:Array<String> = ['Covers', 'Originals'];
    public static var curCategory:Int = 0;
	private static var curSelected:Int = 0;

	public var catName:Alphabet;
	
	var bg:FlxSprite;
    var categoryIcon:FlxSprite;

	var matpat:FlxSprite;

	//HENRY STUFF
	private var inputBuffer:String = "";
	var charles:FlxSprite;
	var playedSound:Bool = false;
    
    override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing the Lore", null);
		#end

		Paths.clearUnusedMemory();

        bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFF00c2ff;
		add(bg);
	
		backend.Conductor.bpm = 130;
		persistentUpdate = persistentDraw = true;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0, 0);
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);

		matpat = new FlxSprite().loadGraphic(Paths.image('mainmenu/matpat_freeplay'));
		matpat.flipX = true;
		matpat.setGraphicSize(Std.int(matpat.width * 0.65));
		matpat.updateHitbox();
		matpat.x = (FlxG.width - matpat.width) + 155;
		add(matpat);

		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = 635;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);

        categoryIcon = new FlxSprite();
        categoryIcon.frames = Paths.getSparrowAtlas('category/category-' + freeplayCats[curSelected].toLowerCase());
        categoryIcon.animation.addByPrefix('idle', freeplayCats[curSelected].toLowerCase(), 24);
        categoryIcon.animation.play('idle');
		categoryIcon.screenCenter();
		categoryIcon.x -= 240;
		add(categoryIcon);

		catName = new Alphabet(0, (FlxG.height / 2) - 282, freeplayCats[curSelected], true);
		catName.screenCenter(X);
		catName.x -= 240;
		add(catName);

		/*charles = new FlxSprite(-800, -100);
		charles.scale.x = 0.5;
		charles.scale.y = 0.5;
		charles.updateHitbox();
		charles.frames = Paths.getSparrowAtlas('charles');
		charles.animation.addByPrefix('idle', 'idle', 24, false);
		charles.animation.addByPrefix('oh', 'oh', 24, false);
		charles.animation.addByPrefix('perfect', 'perfect', 24, false);*/

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        changeSelection();
		//if (FlxG.save.data.henryUnlocked) unlockCharles();
		
		#if desktop if (!FlxG.mouse.visible) FlxG.mouse.visible = true; #end
        super.create();

		FlxG.camera.y = 720;
		FlxTween.tween(FlxG.camera, {y: 0}, 1.2, {ease: FlxEase.expoInOut});

		add(new ExitButton());
    }

	public var selectedSomethin:Bool = false;
	public var canClick:Bool = true;
    override public function update(elapsed:Float)
	{
		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P) {
				changeSelection(-1);
			}
			if (controls.UI_RIGHT_P) {
				changeSelection(1);
			}
			if (FlxG.mouse.wheel != 0) {
				changeSelection(FlxG.mouse.wheel);
			}
			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.zoom += 0.06;
				FlxTween.tween(FlxG.camera, {y: 720}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
					MusicBeatState.switchState(new MainMenuState());
				}});
			}
			if (controls.ACCEPT || (FlxG.mouse.overlaps(categoryIcon) && FlxG.mouse.justPressed)) {
				selectedSomethin = true;
				canClick = false;

				FlxG.camera.zoom += 0.06;
				FlxTween.tween(FlxG.camera, {y: 720}, 1.2, {ease: FlxEase.expoInOut});

				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				FlxTween.tween(catName, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){catName.kill();}});
				FlxFlicker.flicker(categoryIcon, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					MusicBeatState.switchState(new FreeplayState());
				});
			} else if (FlxG.mouse.overlaps(matpat) && FlxG.mouse.justPressed) {
				FlxG.sound.play(Paths.sound('helloInternet'));
				matpat.setGraphicSize(Std.int(matpat.width * 1.1));
			}

			if (charles != null)
			{
				if (FlxG.mouse.overlaps(charles))
				{
					if (!playedSound) FlxG.sound.play(Paths.sound('scrollMenu'));
					playedSound = true;
					if (FlxG.mouse.pressed && canClick)
					{
						FlxG.sound.play(Paths.sound('plan'), 1, false);
						charles.animation.play('perfect', true, false, 0);
						selectedSomethin = true;
						canClick = FlxG.mouse.visible = false;

						FlxTween.tween(catName, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){catName.kill();}});

						new FlxTimer().start(1.2, function(tmr:FlxTimer) {
							PlayState.SONG = backend.Song.loadFromJson('lore-plan', 'lore-plan');
							PlayState.storyDifficulty = 2;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					}
				} else playedSound = false;
			}
		}
        curCategory = curSelected;
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
		matpat.scale.x = FlxMath.lerp(0.65, matpat.scale.x, Math.exp(-elapsed * 7.5));
		matpat.scale.y = FlxMath.lerp(0.65, matpat.scale.y, Math.exp(-elapsed * 7.5));
        super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;
    }

    function changeSelection(change:Int = 0) 
	{
		FlxG.camera.zoom += 0.03;
		curSelected += change;

		if (curSelected >= freeplayCats.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = freeplayCats.length - 1;

		catName.text = freeplayCats[curSelected];
		catName.screenCenter(X);
		catName.x -= 240;
		add(catName);

        categoryIcon.frames = Paths.getSparrowAtlas('category/category-' + freeplayCats[curSelected].toLowerCase());
        categoryIcon.animation.addByPrefix('idle', freeplayCats[curSelected].toLowerCase(), 24);
        categoryIcon.animation.play('idle');
        categoryIcon.screenCenter();
		categoryIcon.x -= 240;
		FlxG.sound.play(Paths.sound('scrollMenu'));
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

		if (charCode == Keyboard.BACKSPACE && inputBuffer.length > 0) 
			inputBuffer = inputBuffer.substring(0, inputBuffer.length - 1);
		else 
			inputBuffer += char;

		if (inputBuffer == "henry" && !FlxG.save.data.henryUnlocked) unlockCharles(true);

		if (inputBuffer.length > 4) inputBuffer = "";
	}

	private function unlockCharles(unlock:Bool = false)
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