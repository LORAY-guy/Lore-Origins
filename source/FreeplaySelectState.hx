package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end

class FreeplaySelectState extends MusicBeatState{
    public static var freeplayCats:Array<String> = ['Covers', 'Originals'];
    public static var curCategory:Int = 0;
	public var catName:Alphabet;
	var grpCats:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var bg:FlxSprite;
    var categoryIcon:FlxSprite;
    
    override function create(){
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing the Lore", null);
		#end

        bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFF00c2ff;
		add(bg);
		
		persistentUpdate = persistentDraw = true;

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

        categoryIcon = new FlxSprite();
        categoryIcon.frames = Paths.getSparrowAtlas('category/category-' + freeplayCats[curSelected].toLowerCase());
        categoryIcon.animation.addByPrefix('idle', freeplayCats[curSelected].toLowerCase(), 24);
        categoryIcon.animation.play('idle');
		categoryIcon.updateHitbox();
		categoryIcon.screenCenter();
		add(categoryIcon);

		catName = new Alphabet(20, (FlxG.height / 2) - 282, freeplayCats[curSelected], true);
		catName.screenCenter(X);
		add(catName);

        changeSelection();

        super.create();
    }

	var selectedSomethin:Bool = false;
	var canClick:Bool = true;
    override public function update(elapsed:Float){
		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P) {
				changeSelection(-1);
			}
			if (controls.UI_RIGHT_P) {
				changeSelection(1);
			}
			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			if (controls.ACCEPT || (FlxG.mouse.overlaps(categoryIcon) && FlxG.mouse.pressed)) {
				selectedSomethin = true;
				canClick = false;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				FlxTween.tween(catName, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){catName.kill();}});
				FlxFlicker.flicker(categoryIcon, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					MusicBeatState.switchState(new FreeplayState());
				});
			}
		}
        curCategory = curSelected;
        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) {
		curSelected += change;

		if (curSelected >= freeplayCats.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = freeplayCats.length - 1;

		catName.destroy();
		catName = new Alphabet(20, (FlxG.height / 2) - 282, freeplayCats[curSelected], true);
		catName.screenCenter(X);
		add(catName);

        categoryIcon.frames = Paths.getSparrowAtlas('category/category-' + freeplayCats[curSelected].toLowerCase());
        categoryIcon.animation.addByPrefix('idle', freeplayCats[curSelected].toLowerCase(), 24);
        categoryIcon.animation.play('idle');
        categoryIcon.screenCenter();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}