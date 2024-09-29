package states;

import flixel.FlxObject;
import flixel.util.FlxSort;
import flixel.addons.display.FlxBackdrop;

import objects.Bar;

#if ACHIEVEMENTS_ALLOWED
class AchievementsMenuState extends MusicBeatState
{
	public var curSelected:Int = 0;
	public var unlockedAchievements:Int = 0;

	public var options:Array<Dynamic> = [];
	public var grpOptions:FlxSpriteGroup;
	public var nameText:FlxText;
	public var descText:FlxText;
	public var progressTxt:FlxText;
	public var progressBar:Bar;
	public var box:FlxSprite;
	public var ourpleFella:FlxSprite;
	private var distractibleCode:FlxText;

	var camFollow:FlxObject;

	var MAX_PER_ROW:Int = 4;

	var inCutscene:Bool = false;
	var showingCode:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		// prepare achievement list
		for (achievement => data in Achievements.achievements)
		{
			var unlocked:Bool = Achievements.isUnlocked(achievement); 
			options.push(makeAchievement(achievement, data, unlocked, data.mod));
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var menuBG:FlxBackdrop = new FlxBackdrop(Paths.image('achievements/wall'), X);
		menuBG.antialiasing = ClientPrefs.data.antialiasing;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.velocity.x = 20;
		menuBG.scrollFactor.set();
		add(menuBG);

		distractibleCode = new FlxText(0, 0, 0, "205777", 32);
		distractibleCode.setFormat(Paths.font('mark.ttf'), 32, FlxColor.GRAY, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		distractibleCode.scrollFactor.set();
		distractibleCode.borderSize = 1.5;
		distractibleCode.alpha = 0.5;
		distractibleCode.x = -distractibleCode.width;
		add(distractibleCode);

		grpOptions = new FlxSpriteGroup();
		grpOptions.scrollFactor.x = 0;

		options.sort(sortByID);
		for (option in options)
		{
			var graphic = Paths.image('achievements/' + (option.unlocked ? 'unlocked' : 'locked'));

			var spr:FlxSprite = new FlxSprite(0, Math.floor(grpOptions.members.length / MAX_PER_ROW) * 180).loadGraphic(graphic);
			spr.scrollFactor.x = 0;
			spr.ID = grpOptions.members.length;
			spr.screenCenter(X);
			if (spr.ID != 12) 
				spr.x += 180 * ((grpOptions.members.length % MAX_PER_ROW) - MAX_PER_ROW/2) + spr.width / 2 + 15;
			else {
				spr.x = ((grpOptions.width + 60) - (grpOptions.width / 4)) - 12.5;
				spr.y -= 10;
			}
			spr.alpha = 0.6;
			grpOptions.add(spr);
		}

		box = new FlxSprite(0, -10).loadGraphic(Paths.image('achievements/bg'));
		box.setGraphicSize(grpOptions.width + 60, grpOptions.height + 30);
		box.updateHitbox();
		box.scrollFactor.x = 0;
		box.screenCenter(X);
		add(box);
		add(grpOptions);

		if (unlockedAchievements == options.length)
		{
			if (!ClientPrefs.data.unlockedEverything) {
				showCutscene();
			} else {
				createGoldenFella();
			}
		}

		var box2:FlxSprite = new FlxSprite(0, 570).makeGraphic(1, 1, FlxColor.BLACK);
		box2.scale.set(FlxG.width, FlxG.height - box2.y);
		box2.updateHitbox();
		box2.alpha = 0.6;
		box2.scrollFactor.set();
		add(box2);
		
		nameText = new FlxText(50, box2.y + 10, FlxG.width - 100, "", 32);
		nameText.setFormat(Paths.font("ourple.ttf"), 32, FlxColor.WHITE, CENTER);
		nameText.scrollFactor.set();

		descText = new FlxText(50, nameText.y + 38, FlxG.width - 100, "", 24);
		descText.setFormat(Paths.font("ourple.ttf"), 24, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();

		progressBar = new Bar(0, 0);
        progressBar.y = (box2.y - progressBar.height) - 5;
		progressBar.screenCenter(X);
        progressBar.leftBar.color = FlxColor.fromRGB(64, 231, 129);
		progressBar.leftBar.height -= 25;
		progressBar.scrollFactor.set();
		progressBar.enabled = false;
		
		progressTxt = new FlxText(50, progressBar.y - 2, FlxG.width - 100, "", 32);
		progressTxt.setFormat(Paths.font("ourple.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		progressTxt.scrollFactor.set();
		progressTxt.borderSize = 2;

		add(progressBar);
		add(progressTxt);
		add(descText);
		add(nameText);

        var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = 635;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);
		
		_changeSelection();
		super.create();

        add(new ExitButton());
		
		FlxG.camera.follow(camFollow, null, 9);
		FlxG.camera.scroll.y = -FlxG.height;
	}

	function makeAchievement(achievement:String, data:Achievement, unlocked:Bool, mod:String = null)
	{
		var unlocked:Bool = Achievements.isUnlocked(achievement);
		if (unlocked) unlockedAchievements++; //For the big golden fella.
		return {
			name: achievement,
			displayName: (!data.hidden || unlocked) ? data.name : '???',
			description: (!data.hiddenDesc || unlocked) ? data.description : '????????',
			curProgress: data.maxScore > 0 ? Achievements.getScore(achievement) : 0,
			maxProgress: data.maxScore > 0 ? data.maxScore : 0,
			decProgress: data.maxScore > 0 ? data.maxDecimals : 0,
			unlocked: unlocked,
			ID: data.ID,
			mod: mod
		};
	}

	public static function sortByID(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.ID, Obj2.ID);

	var goingBack:Bool = false;
	override function update(elapsed:Float) {
		if(!goingBack && !inCutscene && options.length > 1)
		{
			var add:Int = 0;
			if (controls.UI_LEFT_P) add = -1;
			else if (controls.UI_RIGHT_P) add = 1;

			if(add != 0)
			{
				var oldRow:Int = Math.floor(curSelected / MAX_PER_ROW);
				var rowSize:Int = Std.int(Math.min(MAX_PER_ROW, options.length - oldRow * MAX_PER_ROW));
				
				grpOptions.members[curSelected].alpha = 0.6;
				curSelected += add;
				var curRow:Int = Math.floor(curSelected / MAX_PER_ROW);
				if(curSelected >= options.length) curRow++;

				if(curRow != oldRow)
				{
					if(curRow < oldRow) curSelected += rowSize;
					else curSelected = curSelected -= rowSize;
				}
				_changeSelection();
			}

			if(options.length > MAX_PER_ROW)
			{
				var add:Int = 0;
				if (controls.UI_UP_P) add = -1;
				else if (controls.UI_DOWN_P) add = 1;

				if(add != 0)
				{
					var diff:Int = curSelected - (Math.floor(curSelected / MAX_PER_ROW) * MAX_PER_ROW);
					grpOptions.members[curSelected].alpha = 0.6;
					curSelected += add * MAX_PER_ROW;
					if(curSelected < 0)
					{
						curSelected += Math.ceil(options.length / MAX_PER_ROW) * MAX_PER_ROW;
						if(curSelected >= options.length) curSelected -= MAX_PER_ROW;
					}
					if(curSelected >= options.length)
					{
						curSelected = diff;
					}

					_changeSelection();
				}
			}

            grpOptions.forEach(function(spr:FlxSprite) {
                if (FlxG.mouse.overlaps(spr) && curSelected != spr.ID) {
					grpOptions.members[curSelected].alpha = 0.6;
                    curSelected = spr.ID;
                    _changeSelection();
                }
            });

			if (ourpleFella != null && !CoolUtil.isGolden && FlxG.mouse.overlaps(ourpleFella) && FlxG.mouse.justPressed) {
				FlxG.sound.play(Paths.sound('goldenHum'));
				CoolUtil.reloadOurpleCursor(true);
			}
			
			if(controls.RESET && (options[curSelected].unlocked || options[curSelected].curProgress > 0))
			{
				openSubState(new ResetAchievementSubstate());
			}
		}

		if (controls.BACK) {
			exitState(new MainMenuState(true));
			goingBack = true;
		}
		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
	}

	public var barTween:FlxTween = null;
	function _changeSelection()
	{
		FlxG.camera.zoom += 0.03;

		FlxG.sound.play(Paths.sound('scrollMenu'));
		var hasProgress = options[curSelected].maxProgress > 0;
		nameText.text = options[curSelected].displayName;
		descText.text = options[curSelected].description;
		progressTxt.visible = progressBar.visible = hasProgress;

		if(barTween != null) barTween.cancel();

		if(hasProgress)
		{
			var val1:Float = options[curSelected].curProgress;
			var val2:Float = options[curSelected].maxProgress;
			progressTxt.text = CoolUtil.floorDecimal(val1, options[curSelected].decProgress) + ' / ' + CoolUtil.floorDecimal(val2, options[curSelected].decProgress);

			barTween = FlxTween.tween(progressBar, {percent: (val1 / val2) * 100}, 0.5, {ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) progressBar.updateBar(),
				onUpdate: function(twn:FlxTween) progressBar.updateBar()
			});
		}
		else progressBar.percent = 0;

		var maxRows = Math.floor(grpOptions.members.length / MAX_PER_ROW);
		if(maxRows > 0)
		{
			var camY:Float = FlxG.height / 2 + (Math.floor(curSelected / MAX_PER_ROW) / maxRows) * Math.max(0, grpOptions.height - FlxG.height / 2 - 50) - 100;
			camFollow.setPosition(0, camY);
		}
		else camFollow.setPosition(0, grpOptions.members[curSelected].getGraphicMidpoint().y - 100);

		grpOptions.members[curSelected].alpha = 1;

		if (!showingCode && FlxG.random.bool(1)) 
		{
			showingCode = true;
			distractibleCode.y = FlxG.random.float(80, FlxG.height - 80); //80 is the height of the lettaboxes, to avoid spawning the code behind them
			FlxTween.tween(distractibleCode, {x: distractibleCode.width + FlxG.width}, 20, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
				showingCode = false;
				distractibleCode.x = -distractibleCode.width;
			}});
		}
	}

	function createGoldenFella()
	{
		ourpleFella = new FlxSprite();
		ourpleFella.frames = Paths.getSparrowAtlas('goldenFella');
		ourpleFella.animation.addByPrefix('idle', 'idle', 20, true);
		ourpleFella.animation.play('idle');
		ourpleFella.scrollFactor.set();
		ourpleFella.scale.set(1.5, 1.5);
		ourpleFella.updateHitbox();
		add(ourpleFella);
		ourpleFella.y = (FlxG.height - ourpleFella.height) + 100;

		if (!inCutscene) {
			ourpleFella.x = (FlxG.width - ourpleFella.width) + 100;
			box.x = 50;
			grpOptions.x = -215;
		} else {
			ourpleFella.x = (FlxG.width + ourpleFella.width) - 225;
		}
	}

	function showCutscene()
	{
		inCutscene = true;
		createGoldenFella();
		var curVol:Float = FlxG.sound.music.volume;
		FlxG.sound.music.fadeOut(0.25, 0, function(twn:FlxTween) {FlxG.sound.music.pause();});

		var happyText:FlxSprite = new FlxSprite();
		happyText.frames = Paths.getSparrowAtlas('achievements/hediditnoway');
		happyText.animation.addByPrefix('idle', 'idle');
		happyText.animation.play('idle');
		happyText.scale.set(2.25, 2.25);
		happyText.updateHitbox();
		happyText.scrollFactor.set();
		happyText.screenCenter(XY);
		add(happyText);

		var confetti = new FlxSprite();
		confetti.frames = Paths.getSparrowAtlas('achievements/happy');
		confetti.animation.addByPrefix('idle', 'happy idle');
		confetti.animation.play('idle');
		confetti.setGraphicSize(FlxG.width);
		confetti.updateHitbox();
		confetti.scrollFactor.set();
		confetti.screenCenter(XY);
		add(confetti);

		FlxTween.tween(happyText, {y: (FlxG.height - happyText.height) / 2}, 1, {ease: FlxEase.backOut, startDelay: 0.25});
		FlxG.sound.play(Paths.sound('fanfare'), 1, false, function() {
			happyText.destroy();
			FlxG.sound.play(Paths.sound('thatfuckingrock'));
			FlxTween.tween(box, {x: 50}, 0.4, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(grpOptions, {x: -215}, 0.4, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(ourpleFella, {x: (FlxG.width - ourpleFella.width) + 100}, 8, {ease: FlxEase.smootherStepInOut, onComplete: function(twn:FlxTween) {
				confetti.destroy();
				FlxG.sound.music.resume();
				FlxG.sound.music.fadeIn(1, curVol, 1);
				inCutscene = false;
				ClientPrefs.data.unlockedEverything = true;
				ClientPrefs.saveSettings();
			}});
		});
	}
}

class ResetAchievementSubstate extends MusicBeatSubstate
{
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		var text:Alphabet = new Alphabet(0, 180, "Reset Achievement:", true);
		text.screenCenter(X);
		text.scrollFactor.set();
		add(text);
		
		var state:AchievementsMenuState = cast FlxG.state;
		var text:FlxText = new FlxText(50, text.y + 90, FlxG.width - 100, state.options[state.curSelected].displayName, 40);
		text.setFormat(Paths.font("ourple.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		text.borderSize = 2;
		add(text);
		
		yesText = new Alphabet(0, text.y + 120, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		yesText.scrollFactor.set();
		for(letter in yesText.letters) letter.color = FlxColor.RED;
		add(yesText);
		noText = new Alphabet(0, text.y + 120, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		noText.scrollFactor.set();
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK)
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		super.update(elapsed);

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			onYes = !onYes;
			updateOptions();
		}

		if(controls.ACCEPT)
		{
			if(onYes)
			{
				onConfirm();
				if (ClientPrefs.data.unlockedEverything)
				{
					ClientPrefs.data.unlockedEverything = false;
					var state:AchievementsMenuState = cast FlxG.state;
					state.ourpleFella.destroy();
					state.ourpleFella = null;
					state.box.screenCenter(X);
					state.grpOptions.x = 0;
				}

				ClientPrefs.saveSettings();
				Achievements.save();
				FlxG.save.flush();

				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			close();
			return;
		}
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function onConfirm(?resetOption:Null<Int> = null) {
		var state:AchievementsMenuState = cast FlxG.state;
		var option:Dynamic = null;
		if (resetOption != null)
			option = state.options[resetOption];
		else
			option = state.options[state.curSelected];

		Achievements.variables.remove(option.name);
		Achievements.achievementsUnlocked.remove(option.name);
		option.unlocked = false;
		option.curProgress = 0;
		if(option.maxProgress > 0) state.progressTxt.text = '0 / ' + option.maxProgress;
		state.grpOptions.members[state.curSelected].loadGraphic(Paths.image('achievements/locked'));
		state.grpOptions.members[state.curSelected].antialiasing = ClientPrefs.data.antialiasing;

		if(state.progressBar.visible)
		{
			if(state.barTween != null) state.barTween.cancel();
			state.barTween = FlxTween.tween(state.progressBar, {percent: 0}, 0.5, {ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) state.progressBar.updateBar(),
				onUpdate: function(twn:FlxTween) state.progressBar.updateBar()
			});
		}

		switch (option.name)
		{
			case 'lore_enjoyer':
				ClientPrefs.data.songPlayed.set('Covers', []);
				ClientPrefs.data.songPlayed.set('Originals', []);
				ClientPrefs.data.ourpleUsed = [];

			case 'true_theorist':
				for (i in 0...11) {
					onConfirm(i);
				}
		}
	}
}
#end