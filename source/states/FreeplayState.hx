package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;

#if !mobile
import objects.MusicPlayer;
import substates.GameplayChangersSubstate;
#end

import substates.ResetScoreSubState;

import flixel.math.FlxMath;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	public static var inSubstate:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:FlxTypedGroup<HealthIcon>;

	var bg:FlxSprite;
	var randomizer:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	#if !mobile
	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;
	var songName:String = 'Lore';
	#end

	var exitButton:ExitButton;
	var freeplayCategory:String = FreeplaySelectState.freeplayCats[FreeplaySelectState.curCategory].toLowerCase();

	#if mobile
	public var mobileControls:MobileUIControls;
	#end

	override function create()
	{
		Paths.clearUnusedMemory();

		createOurpleWeek();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing the Lore", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		var scaleMultiplier:Float = FlxG.width / 1280;
		bg.setGraphicSize(Std.int(bg.width * scaleMultiplier));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = (freeplayCategory == 'originals' ? 0xff00c3ff : 0xffa357ab);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0, 0);
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		iconArray = new FlxTypedGroup<HealthIcon>();
		add(iconArray);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, freeplayCategory == 'originals' ? CoolUtil.removeSymbol(songs[i].songName, "lore-") : 'Lore', true);
			songText.targetY = i;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			if (songs[i].songName == 'lore-sad') icon.animation.curAnim.curFrame = 1;
			icon.sprTracker = songText;
			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;
			icon.alpha = 0.6;

			// using a FlxGroup is too much fuss? NUH UH
			iconArray.add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("ourple.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.text = "Lore";
		add(diffText);

		add(scoreText);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("ourple.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		#if (desktop || html5)
		randomizer = new FlxText(FlxG.width - 590, 200, 550, "PRESS \'R\' OR CLICK ON ME TO PLAY A RANDOM LORE", 36);
		#else
		randomizer = new FlxText(FlxG.width - 590, 200, 550, "CLICK ON ME TO PLAY A RANDOM LORE", 36);
		#end
		randomizer.setFormat(Paths.font("ourple.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		randomizer.borderSize = 1.25;
		randomizer.antialiasing = false;
		add(randomizer);
		FlxTween.tween(randomizer, {angle: 10}, 2, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
			FlxTween.angle(randomizer, 10, -10, 2, {ease: FlxEase.sineInOut, type: PINGPONG});
		}});

		#if !mobile
		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		bottomString = leText;
		var size:Int = 14;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("ourple.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);

		player = new MusicPlayer(this);
		add(player);
		#end
		
		changeSelection();
		updateTexts();
		
		if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
		super.create();

		exitButton = new ExitButton('freeplayselect');
		add(exitButton);

		#if mobile
        mobileControls = new MobileUIControls(true);
        add(mobileControls);

        Controls.mobileControls = mobileControls;
		#end
	}

	override public function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		if (exitButton != null)
			exitButton.active = true;
		super.closeSubState();
	}

	override public function openSubState(SubState:flixel.FlxSubState):Void
	{
		if (exitButton != null)
			exitButton.active = false;
		super.openSubState(SubState);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	public var usingMouse:Bool = false;
	public var canClick:Bool = true;
	var exiting:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!inSubstate && !exiting)
		{
			#if !mobile
			if (!player.playingMusic)
			{
			#end
				scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
				positionHighscore();
				
				if(songs.length > 1)
				{
					if (controls.UI_DOWN || controls.UI_UP)
						usingMouse = false;
					else if (FlxG.mouse.justMoved || FlxG.mouse.wheel != 0)
						usingMouse = true;
					
					if(FlxG.keys.justPressed.HOME)
					{
						curSelected = 0;
						changeSelection();
						holdTime = 0;	
					}
					else if(FlxG.keys.justPressed.END)
					{
						curSelected = songs.length - 1;
						changeSelection();
						holdTime = 0;	
					}

					if (controls.UI_UP_P)
					{
						changeSelection(-shiftMult);
						holdTime = 0;
					}
					if (controls.UI_DOWN_P)
					{
						changeSelection(shiftMult);
						holdTime = 0;
					}
	
					if(controls.UI_DOWN || controls.UI_UP)
					{
						var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
						holdTime += elapsed;
						var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
	
						if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
							changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
	
					if(FlxG.mouse.wheel != 0)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
						changeSelection(-shiftMult * FlxG.mouse.wheel, false);
					}
				}
			#if !mobile
			}
			#end
	
			if (controls.BACK_P)
			{
				#if !mobile
				if (player.playingMusic)
				{
					FlxG.sound.music.stop();
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					instPlaying = -1;
	
					player.playingMusic = false;
					player.switchPlayMusic();
	
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(1, 0, 1);
				}
				else 
				{
				#end
					if(colorTween != null) {
						colorTween.cancel();
					}
					exiting = true;
					exitState(new states.FreeplaySelectState(true));
				#if !mobile
				}
				#end
			}
	
			#if !mobile
			if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
			{
				inSubstate = true;
				openSubState(new GameplayChangersSubstate());
			}
	
			else if (FlxG.keys.justPressed.SPACE)
			{
				if(instPlaying != curSelected && !player.playingMusic)
				{
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;

					Mods.currentModDirectory = songs[curSelected].folder;

					songName = songs[curSelected].songName.toLowerCase();

					var poop:String = Highscore.formatSong(songName, 0);
					PlayState.SONG = Song.loadFromJson(poop, songName, (freeplayCategory == 'covers'));
					
					if (PlayState.SONG.needsVoices)
					{
						try
						{
							vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
							if (vocals != null && vocals.length > 0) // ACTUALLY checking if the sound has loaded correctly, otherwise, the songs would have a weird crunchy glitch effect.
							{
								FlxG.sound.list.add(vocals);
								vocals.persist = true;
								vocals.looped = true;
							}
							else
							{
								destroyFreeplayVocals();
							}
						}
						catch (e:Dynamic)
						{
							destroyFreeplayVocals();
							trace("Failed to load vocals: " + e);
						}
					}

					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
					if(vocals != null) // Sync vocals to Inst
					{
						vocals.play();
						vocals.volume = 0.8;
					}
					instPlaying = curSelected;

					player.playingMusic = true;
					player.curTime = 0;
					player.switchPlayMusic();
				}
				else if (instPlaying == curSelected && player.playingMusic)
				{
					player.pauseOrResume(player.paused);
				}
			}
			#end

			else if (#if !mobile !player.playingMusic && #end ((FlxG.keys.justPressed.R) || (usingMouse && canClick && FlxG.mouse.justPressed && FlxG.mouse.overlaps(randomizer))))
			{
				canClick = false;
				persistentUpdate = false;
				exiting = true;
				FlxG.mouse.visible = false;
				var brub:Int = FlxG.random.int(0, songs.length-1);
				var songLowercase:String = Paths.formatToSongPath(songs[brub].songName);
				var poop:String = Highscore.formatSong(songLowercase, 0);
				trace(poop);
	
				PlayState.SONG = Song.loadFromJson(poop, songLowercase, (freeplayCategory == 'Covers'));
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
				if (songLowercase == 'sunk') PlayState.sunkMark = FlxG.random.getObject(['Mark', 'Captain']);
	
				FlxG.camera.zoom += 0.06;
				FlxG.sound.music.fadeOut(1.2, 0, function(twn:FlxTween) {FlxG.sound.music.stop();});
				FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
					LoadingState.loadAndSwitchState(new PlayState());
				}});
				destroyFreeplayVocals();
			}
	
			else if (#if !mobile !player.playingMusic && #end !FlxG.mouse.overlaps(exitButton) && ((controls.ACCEPT_P) || (usingMouse && canClick && FlxG.mouse.justPressed && ((FlxG.mouse.overlaps(grpSongs) || FlxG.mouse.overlaps(iconArray))))))
			{
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);

				if (songLowercase == 'sunk') {
					inSubstate = true;
					openSubState(new SelectSunkDifficulty());
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else {
					processSong(songLowercase);
				}
			}
			else if(controls.RESET_P #if !mobile && !player.playingMusic #end)
			{
				inSubstate = true;
				openSubState(new ResetScoreSubState(songs[curSelected].songName, 1, songs[curSelected].songCharacter));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		randomizer.color = FlxG.mouse.overlaps(randomizer) ? 0xFFa357ab : 0xFFFFFFFF;
		updateTexts(elapsed);
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if(vocals != null) {
			FlxG.sound.list.remove(vocals, true);
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		#if !mobile
		if (player.playingMusic)
			return;
		#end

		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		iconArray.members[curSelected].alpha = 0.6;

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, 0);
		intendedRating = Highscore.getRating(songs[curSelected].songName, 0);
		#end

		var bullShit:Int = 0;
	
		iconArray.members[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == curSelected)
				item.alpha = 1;
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.list = ['Lore'];
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray.members[i].visible = iconArray.members[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			var icon:HealthIcon = iconArray.members[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['mat2'];
		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], weekColor);
			if (songCharacters.length != 1)
				num++;
		}
	}

	private function createOurpleWeek():Void 
	{
		switch (freeplayCategory)
		{
			case 'covers':
				if (!ClientPrefs.data.hideOldCovers && ClientPrefs.data.guy == 'Ourple')
				{
					addWeek(
					[
						'lored',
						'lore-ryan',
						'lore-awesomix'
					], 
					0, 
					0xff797979);
				}
				if (ClientPrefs.data.guy != 'Ourple') {
					addWeek(
						[
							'lore-og'
						], 
						0,
						0xFF00ff00);
				} else {
					addWeek(
						[
							'lore-apology',
							'chronology',
							'live',
							'horse-lore',
							'detective',
							'measure-up',
							'action',
							'repugnant'
						], 
						0, 
						0xffa357ab);
				}
				PlayState.isCover = true;
			case 'originals':
				addWeek(
				[
					'lore-tropical',
					'lore-sad',
					'sunk',
					'lore-ar',
					'presidency'
				],
				0,
				0xff00c3ff);
				PlayState.isCover = false;
		};
	}

	public function processSong(songLowercase:String) {
		canClick = false;
		persistentUpdate = false;
		FlxG.mouse.visible = false;
		var poop:String = Highscore.formatSong(songLowercase, 0);

		PlayState.SONG = Song.loadFromJson(poop + (songLowercase == 'sunk' ? '-' + PlayState.sunkMark : ''), songLowercase, PlayState.isCover);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;

		if(colorTween != null) {
			colorTween.cancel();
		}
		
		FlxG.camera.zoom += 0.06;
		FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
			LoadingState.loadAndSwitchState(new PlayState());
		}});

		FlxG.sound.music.fadeOut(1.2, 0, function(twn:FlxTween) {FlxG.sound.music.stop();});
				
		destroyFreeplayVocals();
	}

	override function destroy():Void
	{
		#if mobile
		Controls.mobileControls = null;
		#end

		super.destroy();
		FlxG.autoPause = ClientPrefs.data.autoPause;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}

class SelectSunkDifficulty extends MusicBeatSubstate //Basically copied the ResetScoreSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onMark:Bool = false;
	var markText:Alphabet;
	var captainText:Alphabet;
	var freeplay:FreeplayState = cast FlxG.state;
	var enterReleased:Bool = #if mobile true #else false #end; //Would just always be false cuz it would instantly select on open

	#if mobile
	private var mobileControls:MobileUIControls;
	#end

	public function new()
	{
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var text:Alphabet = new Alphabet(0, 180, "Select the ending:", true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		markText = new Alphabet(0, text.y + 150, 'Mark', true);
		markText.screenCenter(X);
		markText.x -= 200;
		add(markText);

		captainText = new Alphabet(0, text.y + 150, 'Captain', true);
		captainText.screenCenter(X);
		captainText.x += 215;
		add(captainText);

		add(new ExitButton('freeplay'));

		#if mobile
		mobileControls = new MobileUIControls(true);
		add(mobileControls);

		Controls.mobileControls = mobileControls;
		#end

		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			onMark = !onMark;
			updateOptions();
		}
		if(controls.BACK_P) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FreeplayState.inSubstate = false;
			close();
		} else if(enterReleased && controls.ACCEPT_P) {
			if(onMark) {
				PlayState.sunkMark = 'Mark';
			} else {
				PlayState.sunkMark = 'Captain';
			}
			FlxG.sound.play(Paths.sound('confirmMenu'));
			freeplay.processSong('sunk');
			FreeplayState.inSubstate = false;
			close();
		}

		if (controls.ACCEPT_R)
			enterReleased = true;

		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onMark ? 1 : 0;

		markText.alpha = alphas[confirmInt];
		markText.scale.set(scales[confirmInt], scales[confirmInt]);
		captainText.alpha = alphas[1 - confirmInt];
		captainText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}

	override public function close():Void
	{
		#if mobile
		if (freeplay.mobileControls != null)
			Controls.mobileControls = freeplay.mobileControls;
		else
			Controls.mobileControls = null;
		#end
		super.close();
	}
}