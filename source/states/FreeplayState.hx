package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;

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
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	public static var inSubstate:Bool = false;

	private var curPlaying:Bool = false;

	var cabinets:FlxTypedGroup<Cabinets>;
	var arrows:FlxSpriteGroup;
	//var friends:FlxTypedGroup<DancingFuck>;

	var wall:FlxBackdrop;
	var randomizer:FlxText;

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

	override public function create():Void
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
				addSong(song[0], i);
			}
		}
		Mods.loadTopMod();

		if (curSelected >= songs.length) curSelected = songs.length - 1;

		wall = new FlxBackdrop(Paths.image('freeplay/wall'), X);
		wall.y = -50;
		wall.setGraphicSize(1280, 720);
		wall.updateHitbox();
		add(wall);

		cabinets = new FlxTypedGroup<Cabinets>();
		add(cabinets);

		arrows = new FlxSpriteGroup();
		add(arrows);

		for (i in 0...songs.length)
		{
			Mods.currentModDirectory = songs[i].folder;
			
			var thesong = Highscore.getScore(songs[i].songName, 0) > 0 ? 'lore' : 'blank';
			var cab = new Cabinets('freeplay/arcade/$thesong');
			cab.scale.set(1.5, 1.5);
			cab.updateHitbox();
			cab.y = FlxG.height - cab.height;
			cab.changeY = false;
			cab.startPosition.x = (FlxG.width - cab.width) / 2;
			cab.distancePerItem.x = 500;
			cabinets.add(cab);
		}
		WeekData.setDirectoryFromWeek();

		var arrow = new FlxSprite();
		arrow.frames = Paths.getSparrowAtlas('mainmenu/arrows');
		arrow.animation.addByPrefix('i', 'normal', 12);
		arrow.animation.addByPrefix('s', 'press', 12);
		arrow.animation.play('i');
		arrow.scale.set(2, 2);
		arrow.updateHitbox();
		arrow.setPosition(cabinets.members[curSelected].startPosition.x - arrow.width - 10, (cabinets.members[curSelected].height - arrow.height) / 2);
		arrow.flipX = true;
		arrows.add(arrow);

		var arrow = new FlxSprite();
		arrow.frames = Paths.getSparrowAtlas('mainmenu/arrows');
		arrow.animation.addByPrefix('i', 'normal', 12);
		arrow.animation.addByPrefix('s', 'press', 12);
		arrow.animation.play('i');
		arrow.scale.set(2, 2);
		arrow.updateHitbox();
		arrow.setPosition(cabinets.members[curSelected].startPosition.x + cabinets.members[curSelected].width + 10,
			(cabinets.members[curSelected].height - arrow.height) / 2);
		arrows.add(arrow);

		var blackStuff = new FlxSprite().makeGraphic(FlxG.width, 50, FlxColor.BLACK);
		blackStuff.y = FlxG.height - blackStuff.height;
		add(blackStuff);
		blackStuff.alpha = 0.6;

		scoreText = new FlxText(0, 0, FlxG.width, '');
		scoreText.setFormat(Paths.font("options.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.y = FlxG.height - scoreText.height + 20;
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

		#if (desktop || html5)
		randomizer = new FlxText(0, 70, 0, "PRESS \'R\' OR CLICK ON ME TO PLAY A RANDOM LORE", 36);
		#else
		randomizer = new FlxText(0, 70, 0, "CLICK ON ME TO PLAY A RANDOM LORE", 36);
		#end
		randomizer.setFormat(Paths.font("ourple.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		randomizer.borderSize = 1.25;
		randomizer.screenCenter(X);
		randomizer.antialiasing = false;
		add(randomizer);
		FlxTween.tween(randomizer, {angle: 2}, 2, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
			FlxTween.angle(randomizer, 2, -2, 2, {ease: FlxEase.sineInOut, type: PINGPONG});
		}});

		#if !mobile
		bottomBG = new FlxSprite().makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		bottomString = leText;
		var size:Int = 14;
		bottomText = new FlxText(bottomBG.x, 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("ourple.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);

		player = new MusicPlayer(this);
		add(player);
		#end
		
		changeSelection(0, false);
		
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

	override public function closeSubState():Void
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

	public function addSong(songName:String, weekNum:Int):Void
	{
		songs.push(new SongMetadata(songName, weekNum));
	}

	private function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	private var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	private var holdTime:Float = 0;
	public var usingMouse:Bool = false;
	public var canClick:Bool = true;
	public var selectedSomethin:Bool = false;
	override public function update(elapsed:Float):Void
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

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!inSubstate && !selectedSomethin)
		{
			#if !mobile
			if (!player.playingMusic)
			{
			#end
				var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
				if(ratingSplit.length < 2) { //No decimals, add an empty space
					ratingSplit.push('');
				}
				
				while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
					ratingSplit[1] += '0';
				}
				
				scoreText.text = 'Score: $lerpScore / Rating: ${ratingSplit.join('.')}%';
				
				if(songs.length > 1)
				{
					if (controls.UI_LEFT || controls.UI_RIGHT)
						usingMouse = false;
					else if (FlxG.mouse.justMoved || FlxG.mouse.wheel != 0)
						usingMouse = true;
					
					var leftP = controls.UI_LEFT_P;
					var rightP = controls.UI_RIGHT_P;
					
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

					if (leftP || (FlxG.mouse.overlaps(arrows.members[0]) && !FlxG.mouse.overlaps(exitButton) && FlxG.mouse.justPressed))
					{
						arrows.members[0].animation.play('s');
						changeSelection(-shiftMult);
						holdTime = 0;
					}
					if (rightP || (FlxG.mouse.overlaps(arrows.members[1]) && !FlxG.mouse.overlaps(exitButton) && FlxG.mouse.justPressed))
					{
						arrows.members[1].animation.play('s');
						changeSelection(shiftMult);
						holdTime = 0;
					}
	
					if (controls.UI_LEFT_R || FlxG.mouse.justReleased)
						arrows.members[0].animation.play('i');
					if (controls.UI_RIGHT_R || (FlxG.mouse.justReleased))
						arrows.members[1].animation.play('i');

					if(controls.UI_LEFT || controls.UI_RIGHT)
					{
						var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
						holdTime += elapsed;
						var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
	
						if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
							changeSelection((checkNewHold - checkLastHold) * (controls.UI_LEFT ? -shiftMult : shiftMult));
					}
	
					if(FlxG.mouse.wheel != 0)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
						changeSelection(-shiftMult * FlxG.mouse.wheel, false);
					}

					if(FlxG.mouse.justPressed && usingMouse)
					{
						for (i in 0...cabinets.members.length)
						{
							if(FlxG.mouse.overlaps(cabinets.members[i]))
							{
								if(i != curSelected)
								{
									var difference = i - curSelected;
									changeSelection(difference, true);
									return;
								}
								break;
							}
						}
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
					selectedSomethin = true;
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
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				var brub:Int = FlxG.random.int(0, songs.length-1);
				var songLowercase:String = Paths.formatToSongPath(songs[brub].songName);
				var poop:String = Highscore.formatSong(songLowercase, 0);
				trace(poop);
	
				PlayState.SONG = Song.loadFromJson(poop, songLowercase, (freeplayCategory == 'Covers'));
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
				if (songLowercase == 'sunk') PlayState.sunkMark = FlxG.random.getObject(['Mark', 'Captain']); // Select a random difficulty for Sunk if selected by the randomizer
	
				FlxG.camera.zoom += 0.06;
				FlxG.sound.music.fadeOut(1.2, 0, function(twn:FlxTween) {FlxG.sound.music.stop();});
				FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
					LoadingState.loadAndSwitchState(new PlayState());
				}});
				destroyFreeplayVocals();
			}
	
			else if (#if !mobile !player.playingMusic && #end
				!FlxG.mouse.overlaps(exitButton) &&
				(!FlxG.mouse.overlaps(arrows.members[0]) || !FlxG.mouse.overlaps(arrows.members[1])) &&
				((controls.ACCEPT_P) ||
					(usingMouse && canClick &&
					FlxG.mouse.justPressed &&
					FlxG.mouse.overlaps(cabinets.members[curSelected]))))
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
				openSubState(new ResetScoreSubState(songs[curSelected].songName, 1));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		randomizer.color = FlxG.mouse.overlaps(randomizer) ? 0xFFa357ab : 0xFFFFFFFF;
		
		// for (i in friends)
		// {
		// 	if (i.ID == curSelected)
		// 	{
		// 		i.offsetX = FlxMath.lerp(i.offsetX, 115, CoolUtil.boundTo(elapsed * 18, 0, 1));
		// 		i.offsetY = FlxMath.lerp(i.offsetY, -110, CoolUtil.boundTo(elapsed * 18, 0, 1));
		// 	}
		// 	else
		// 	{
		// 		i.offsetY = FlxMath.lerp(i.offsetY, -100, CoolUtil.boundTo(elapsed * 18, 0, 1));
		// 		if (i.ID < curSelected)
		// 		{
		// 			i.offsetX = FlxMath.lerp(i.offsetX, 95, CoolUtil.boundTo(elapsed * 18, 0, 1));
		// 		}
		// 		else if (i.ID > curSelected)
		// 		{
		// 			i.offsetX = FlxMath.lerp(i.offsetX, 135, CoolUtil.boundTo(elapsed * 18, 0, 1));
		// 		}
		// 	}
		// }
		
		cabinets.forEachExists(function(cab:Cabinets) {
			if (cab.targetY == 0)
			{
				wall.x = cab.x;
				arrows.members[0].x = FlxMath.lerp(arrows.members[0].x, cab.x - arrows.members[0].width - 10, CoolUtil.boundTo(elapsed * 26, 0, 1));
				arrows.members[1].x = FlxMath.lerp(arrows.members[1].x, cab.x + cab.width + 10, CoolUtil.boundTo(elapsed * 26, 0, 1));
				cab.scale.x = FlxMath.lerp(cab.scale.x, 1.6, CoolUtil.boundTo(elapsed * 18, 0, 1));
				cab.scale.y = FlxMath.lerp(cab.scale.y, 1.6, CoolUtil.boundTo(elapsed * 18, 0, 1));
				cab.y = FlxMath.lerp(cab.y, FlxG.height - cab.height - 20, CoolUtil.boundTo(elapsed * 18, 0, 1));
			}
			else
			{
				cab.scale.x = FlxMath.lerp(cab.scale.x, 1.5, CoolUtil.boundTo(elapsed * 18, 0, 1));
				cab.scale.y = FlxMath.lerp(cab.scale.y, 1.5, CoolUtil.boundTo(elapsed * 18, 0, 1));
				cab.y = FlxMath.lerp(cab.y, FlxG.height - cab.height, CoolUtil.boundTo(elapsed * 18, 0, 1));
			}
		});
		
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals():Void
	{
		if(vocals != null) {
			FlxG.sound.list.remove(vocals, true);
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	private function changeSelection(change:Int = 0, playSound:Bool = true):Void
	{
		#if !mobile
		if (player.playingMusic)
			return;
		#end

		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, 0);
		intendedRating = Highscore.getRating(songs[curSelected].songName, 0);
		#end

		var bullShit:Int = 0;

		cabinets.forEachExists(function(cab:Cabinets) {
			cab.targetY = bullShit - curSelected;
			bullShit++;

			if (change == 0 && playSound)
				cab.snapToPosition();
		});

		PlayState.storyWeek = songs[curSelected].week;
	}

	public function addWeek(songs:Array<String>, weekNum:Int = 0):Void
	{
		for (song in songs)
		{
			addSong(song, weekNum);
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
					]);
				}
				if (ClientPrefs.data.guy != 'Ourple') {
					addWeek(
						[
							'lore-og'
						]);
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
						]);
				}
				PlayState.isCover = true;
			case 'originals':
				addWeek(
				[
					'lore-tropical',
					'lore-sad',
					'sunk',
					'lore-ar',
					'presidency',
					'youtube'
				]);
				PlayState.isCover = false;
		};
	}

	public function processSong(songLowercase:String):Void
	{
		canClick = false;
		persistentUpdate = false;
		selectedSomethin = true;
		FlxG.mouse.visible = false;
		var poop:String = Highscore.formatSong(songLowercase, 0);

		PlayState.SONG = Song.loadFromJson(poop + (songLowercase == 'sunk' ? '-' + PlayState.sunkMark : ''), songLowercase, PlayState.isCover);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		
		FlxG.camera.zoom += 0.06;
		FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
			LoadingState.loadAndSwitchState(new PlayState());
		}});

		FlxG.sound.music.fadeOut(1.2, 0, function(twn:FlxTween) {FlxG.sound.music.stop();});
				
		destroyFreeplayVocals();
	}

	override public function destroy():Void
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
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int)
	{
		this.songName = song;
		this.week = week;
		this.folder = Mods.currentModDirectory;

		if(this.folder == null)
			this.folder = '';
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

class Cabinets extends FlxSprite
{
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var isMenuItem:Bool = true;
	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);
	public var snapPosOnly:Bool = false;
	public var pngOption:Bool = false;

	public function new(path:String, ?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
		loadGraphic(Paths.image(path));
		this.startPosition.x = x;
		this.startPosition.y = y;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			if (!snapPosOnly)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
				if (changeX)
					x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
				if (changeY)
					y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
			}
			else
			{
				if (changeX)
					x = (targetY * distancePerItem.x) + startPosition.x;
				if (changeY)
					y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
			}
		}
		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if (changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if (changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}
}

class DancingFuck extends FlxSprite
{
	public var tracker:FlxSprite;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new(graphic:String, ?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
		offsetX = x;
		offsetY = y;
		frames = Paths.getSparrowAtlas('freeplay/$graphic');
		animation.addByPrefix('dance', 'idle', 12);
		animation.play('dance');
	}

	override function update(elapsed)
	{
		super.update(elapsed);

		if (tracker != null)
		{
			x = tracker.x + offsetX;
			y = tracker.y + offsetY;
		}
	}

	public function snaptoPos():Void
	{
		if (tracker != null)
		{
			x = tracker.x + offsetX;
			y = tracker.y + offsetY;
		}
	}
}