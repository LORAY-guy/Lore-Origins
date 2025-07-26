package substates;

import lime.system.BackgroundWorker;
import objects.Character;
import flixel.FlxObject;

import states.FreeplayState;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Character;
	var camFollow:FlxObject;
	var moveCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'playguy';
	public static var deathSoundName:String = 'ourple_death';
	public static var loopSoundName:String = 'wind';
	public static var endSoundName:String = '';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'playguy';
		deathSoundName = 'ourple_death';
		loopSoundName = 'wind';
		endSoundName = '';

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
		}
	}

	var charX:Float = 0;
	var charY:Float = 0;
	var brokenHeart:FlxSprite;
	override function create()
	{
		instance = this;

		Conductor.songPosition = 0;

		characterName = PlayState.instance.boyfriend.curCharacter;
		switch (PlayState.SONG.song.toLowerCase()) {
			case 'sunk':
				if (characterName == 'lixian') characterName += '-dead';
				else if (characterName != 'mark') characterName = 'playguy';
			case 'lua':
				characterName = 'LORAY';
			default:
				characterName = 'playguy';
		}

		boyfriend = new Character(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y, characterName, true);
		boyfriend.x += boyfriend.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];

		switch (characterName) {
			case 'mark':
				boyfriend.playAnim('singUP-alt');
				deathSoundName = 'crush';
				loopSoundName = 'gameOver';
				endSoundName = 'happyKids';
			case 'lixian-dead':
				boyfriend.updateHitbox();
				boyfriend.scrollFactor.set();
				boyfriend.x = FlxG.width - boyfriend.width - 185;
				boyfriend.y = FlxG.height - boyfriend.height - 20;
				boyfriend.playAnim('firstDeath');
				deathSoundName = 'crush';
				loopSoundName = 'gameOver';
				endSoundName = 'happyKids';
			case 'LORAY':
				deathSoundName = '';
				loopSoundName = '';
				endSoundName = '';
				boyfriend.visible = false;

				brokenHeart = new FlxSprite();
				brokenHeart.frames = Paths.getSparrowAtlas("lua/broken-heart");
				brokenHeart.scale.set(12, 12);
				brokenHeart.updateHitbox();
				brokenHeart.animation.addByPrefix("breaking", "heart", 1, false);
				brokenHeart.animation.play("breaking");
				brokenHeart.animation.callback = function(name:String, frame:Int, frameIndex:Int) {
					if (frame == 1)
						FlxG.sound.play(Paths.sound("heart_break"));
				};
				brokenHeart.screenCenter();
				add(brokenHeart);

				new FlxTimer().start(2, function(tmr:FlxTimer) {
					FlxG.sound.play(Paths.sound("heart_shattered"));

					brokenHeart.visible = false;

					for (i in 0...5) {
						var shard:FlxSprite = new FlxSprite();
						shard.frames = Paths.getSparrowAtlas("lua/heart-shard");
						shard.scale.set(12, 12);
						shard.updateHitbox();
						shard.animation.addByPrefix("shard", "shard", 8, true);
						shard.animation.play("shard");

						var heartCenter = brokenHeart.getGraphicMidpoint();
						shard.setPosition(heartCenter.x + (shard.width / 2), heartCenter.y + (shard.width / 2));

						var angle = (i / 5) * Math.PI * 2 + FlxG.random.float(-0.5, 0.5);
						var speed = FlxG.random.float(300, 500);
						shard.velocity.set(Math.cos(angle) * speed, Math.sin(angle) * speed);

						shard.acceleration.y = 900;
						shard.drag.x = 100;
						
						new FlxTimer().start(1.75, function(tmr:FlxTimer) {
							endBullshit();
						});
						add(shard);
					}
				}, 1);
			default: // Ourple Guy
				boyfriend.scrollFactor.set();
				boyfriend.x = 850;
				boyfriend.y = 500;
				FlxG.camera.zoom = 0.8;
				boyfriend.playAnim('firstDeath');
		}
		add(boyfriend);

		if (deathSoundName.length > 1)
			FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0], boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]);
		FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		add(camFollow);
		
		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public var startedDeath:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if ((controls.ACCEPT_P #if mobile || FlxG.mouse.justPressed #end) && PlayState.SONG.song.toLowerCase() != 'lua')
			endBullshit();

		if (controls.BACK_P)
		{
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			switch (PlayState.SONG.song.toLowerCase()) {
				case 'distractible', 'lua':
					MusicBeatState.switchState(new states.credits.CreditsSubgroupState(true));
				default:
					Mods.loadTopMod();
					MusicBeatState.switchState(new FreeplayState(true));	
			}

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		
		if (boyfriend.animation.curAnim != null)
		{
			if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished && startedDeath)
				boyfriend.playAnim('deathLoop');

			if(boyfriend.animation.curAnim.name == 'firstDeath')
			{
				if(boyfriend.animation.curAnim.curFrame >= 12 && !moveCamera)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0.6);
					moveCamera = true;
				}

				if (boyfriend.animation.curAnim.finished && !playingDeathSound)
				{
					startedDeath = true;
					coolStartDeath();
				}
			}
		}
		
		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		if (loopSoundName.length > 1)
			FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (boyfriend.curCharacter != 'mark') boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			if (endSoundName.length > 1) FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
