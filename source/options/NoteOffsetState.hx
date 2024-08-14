package options;

import backend.StageData;
import objects.Character;
import objects.Bar;
import flixel.addons.display.shapes.FlxShapeCircle;

class NoteOffsetState extends MusicBeatState
{
	var boyfriend:Character;
	var gf:Character;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var coolText:FlxText;
	var rating:FlxSprite;
	var comboNums:FlxSpriteGroup;
	var dumbTexts:FlxTypedGroup<FlxText>;

	var barPercent:Float = 0;
	var delayMin:Int = -500;
	var delayMax:Int = 500;
	var timeBar:Bar;
	var timeTxt:FlxText;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var originY:Float = 0;

	var changeModeText:FlxText;

	var controllerPointer:FlxSprite;
	var _lastControllerMode:Bool = false;

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Delay/Combo Offset Menu", null);
		#end

		// Cameras
		camGame = initPsychCamera();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

		FlxG.camera.scroll.set(120, 130);

		persistentUpdate = true;
		FlxG.sound.pause();

		// STAGE SHIT
		var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);

		if(!ClientPrefs.data.lowQuality) {
			var curtains:BGSprite = new BGSprite('lore/curtain', -500, -300, 1.3, 1.3);
			curtains.setGraphicSize(Std.int(curtains.width * 0.9));
			curtains.updateHitbox();
			add(curtains);
		}

		// Characters
		gf = new Character(400, 130, 'phone');
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		gf.scrollFactor.set(0.95, 0.95);
		var spriteName:String = (ClientPrefs.data.guy == 'Ourple' ? 'playguy' : ClientPrefs.data.guy.toLowerCase());
		var subSpriteName:String = (ClientPrefs.data.ourpleData.get(ClientPrefs.data.guy) == 'Normal' ? '' : '-' + ClientPrefs.data.ourpleData.get(ClientPrefs.data.guy)).toLowerCase();
		boyfriend = new Character(770, 100, spriteName + subSpriteName, true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(gf);
		add(boyfriend);

		coolText = new FlxText(0, 0, 0, '', 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		// Note delay stuff
		beatText = new Alphabet(0, 0, 'Beat Hit!', true);
		beatText.setScale(0.6, 0.6);
		beatText.x += 260;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		add(beatText);

		timeTxt = new FlxText(0, 600, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("ourple.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		timeTxt.cameras = [camHUD];

		barPercent = ClientPrefs.data.noteOffset;
		updateNoteDelay();
		
		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 3), 'OurpleHUD/healthBar', function() return barPercent, delayMin, delayMax);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.cameras = [camHUD];
		timeBar.leftBar.color = FlxColor.LIME;

		add(timeBar);
		add(timeTxt);

		///////////////////////

		var blackBox:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 40, FlxColor.BLACK);
		blackBox.scrollFactor.set();
		blackBox.alpha = 0.6;
		blackBox.cameras = [camHUD];
		add(blackBox);
		
		changeModeText = new FlxText(0, 4, FlxG.width, 'Note/Beat Delay', 32);
		changeModeText.setFormat(Paths.font("ourple.ttf"), 32, FlxColor.WHITE, CENTER);
		changeModeText.scrollFactor.set();
		changeModeText.cameras = [camHUD];
		add(changeModeText);

		controllerPointer = new FlxShapeCircle(0, 0, 20, {thickness: 0}, FlxColor.WHITE);
		controllerPointer.offset.set(20, 20);
		controllerPointer.screenCenter();
		controllerPointer.alpha = 0.6;
		controllerPointer.cameras = [camHUD];
		add(controllerPointer);

		_lastControllerMode = true;

		Conductor.bpm = 128.0;
		FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);

		super.create();

		originY = boyfriend.y;
	}

	var holdTime:Float = 0;
	var holdingObjectType:Null<Bool> = null;

	var startMousePos:FlxPoint = new FlxPoint();
	var startComboOffset:FlxPoint = new FlxPoint();

	override public function update(elapsed:Float)
	{
		var addNum:Int = 1;
		if(FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyPressed(LEFT_SHOULDER))
			addNum = 3;

		if(FlxG.gamepads.anyJustPressed(ANY)) controls.controllerMode = true;
		else if(FlxG.mouse.justPressed) controls.controllerMode = false;

		if(controls.controllerMode != _lastControllerMode)
		{
			//trace('changed controller mode');
			FlxG.mouse.visible = !controls.controllerMode;
			controllerPointer.visible = controls.controllerMode;

			// changed to controller mid state
			if(controls.controllerMode)
			{
				var mousePos = FlxG.mouse.getScreenPosition(camHUD);
				controllerPointer.x = mousePos.x;
				controllerPointer.y = mousePos.y;
			}
			_lastControllerMode = controls.controllerMode;
		}

		if(controls.UI_LEFT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset - 1, delayMax));
			updateNoteDelay();
		}
		else if(controls.UI_RIGHT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset + 1, delayMax));
			updateNoteDelay();
		}

		var mult:Int = 1;
		if(controls.UI_LEFT || controls.UI_RIGHT)
		{
			holdTime += elapsed;
			if(controls.UI_LEFT) mult = -1;
		}

		if(controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;

		if(holdTime > 0.5)
		{
			barPercent += 100 * addNum * elapsed * mult;
			barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
			updateNoteDelay();
		}

		if(controls.RESET_P)
		{
			holdTime = 0;
			barPercent = 0;
			updateNoteDelay();
		}

		if(controls.BACK_P)
		{
			if(zoomTween != null) zoomTween.cancel();
			if(beatTween != null) beatTween.cancel();

			persistentUpdate = false;
			MusicBeatState.switchState(new options.OptionsState(true));
			if(OptionsState.onPlayState)
			{
				if(ClientPrefs.data.pauseMusic != 'None')
					FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));
				else
					FlxG.sound.music.volume = 0;
			}
			else FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.mouse.visible = false;
		}

		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	var flippedIdle:Bool = false;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
			return;

		if (curBeat % 2 == 0)
		{
			boyfriend.dance();
			gf.dance();
			if (boyfriend.curCharacter.startsWith('playguy') && !boyfriend.curCharacter.contains('mad'))
			{
				boyfriend.flipX = flippedIdle;
				if (boyfriend.curCharacter.contains('staring')) boyfriend.x = (boyfriend.flipX ? boyfriend.x + 32 : boyfriend.x - 32);
				flippedIdle = !flippedIdle;
				boyfriend.y = (boyfriend.y + 20);
				FlxTween.tween(boyfriend, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
			}
		}
		
		if(curBeat % 4 == 2)
		{
			FlxG.camera.zoom = 1.15;

			if(zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween) {
				zoomTween = null;
			}});

			beatText.alpha = 1;
			beatText.y = 320;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
				beatTween = null;
			}});
		}

		lastBeatHit = curBeat;
	}

	function createTexts()
	{
		for (i in 0...4)
		{
			var text:FlxText = new FlxText(10, 48 + (i * 30), 0, '', 24);
			text.setFormat(Paths.font("ourple.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 2;
			dumbTexts.add(text);
			text.cameras = [camHUD];

			if(i > 1)
				text.y += 24;
		}
	}

	function updateNoteDelay()
	{
		ClientPrefs.data.noteOffset = Math.round(barPercent);
		timeTxt.text = 'Current offset: ' + Math.floor(barPercent) + ' ms';
	}
}
