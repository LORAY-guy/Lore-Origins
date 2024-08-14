package states;

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

        changeSelection();
		
		#if desktop if (!FlxG.mouse.visible) FlxG.mouse.visible = true; #end
        super.create();

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
			if (controls.BACK_P) {
				selectedSomethin = true;
				FlxG.camera.zoom += 0.06;
				exitState(new MainMenuState(true));
			}
			if (controls.ACCEPT_P || (FlxG.mouse.overlaps(categoryIcon) && FlxG.mouse.justPressed)) {
				selectedSomethin = true;
				canClick = false;

				FlxG.camera.zoom += 0.06;
				FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut});

				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				FlxTween.tween(catName, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){catName.kill();}});
				FlxFlicker.flicker(categoryIcon, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					MusicBeatState.switchState(new FreeplayState(true));
				});
			} else if (FlxG.mouse.overlaps(matpat) && FlxG.mouse.justPressed) {
				FlxG.sound.play(Paths.sound('helloInternet'));
				matpat.setGraphicSize(Std.int(matpat.width * 1.1));
				#if ACHIEVEMENTS_ALLOWED
				Achievements.addScore("wake_up");
				#end
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
}