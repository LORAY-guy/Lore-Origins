package states;

import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Section;
import backend.Rating;
import backend.Credits;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;

import cutscenes.DialogueBoxPsych;

import states.StoryMenuState;
import states.FreeplayState;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import substates.PauseSubState;
import substates.GameOverSubstate;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
#end

#if VIDEOS_ALLOWED
import hxcodec.flixel.FlxVideoSprite as VideoHandler;
#end

import objects.Note.EventNote;
import objects.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if SScript
import tea.SScript;
#end

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -269;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var markMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	public var instancesExclude:Array<String> = [];
	#end

	#if LUA_ALLOWED
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public var MARK_X:Float = 180;
	public var MARK_Y:Float = 70;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var markGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;
	public static var isOurpleNote:Bool = true;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;
	public var mark:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;
	public var combo:Int = 0;

	public var healthBar:Bar;
	public var timeBar:Bar;
	var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = Rating.loadDefault();

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;

	public var guitarHeroSustains:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconP3:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camVideo:FlxCamera;
	public var phoneCam:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var missesTxt:FlxText;
	var missText:String;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var missesTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;
	public var markCameraOffset:Array<Float> = null;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Lua shit
	public static var instance:PlayState;
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;
	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	/**Lore Origins shit**/
	public static var eventTweens:FlxTweenManager = new FlxTweenManager();
	public static var eventTweensManager:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var eventTimers:FlxTimerManager = new FlxTimerManager();

	public static var isCover:Bool = false;
	public static var sunkMark:String;
	public var iconPositionLocked:Bool = false;
	
	public var stars:FlxSpriteGroup;
	public var hudAssets:FlxSpriteGroup;

	public var loraySign:FlxSprite;
	public var lorayTxt:FlxText;

	private var creditsJSON:Null<CreditsData> = null;
	var creditsStep:Int = -1;

	public var inLoreCutscene:Bool = false;

	#if VIDEOS_ALLOWED
	public var midSongVideo:VideoHandler; //LETS GOOOOO CUTSCENES!!!!
	#end

	#if ACHIEVEMENTS_ALLOWED
	/**Achievement shit**/
	private var inputBuffer:String = "";
	var skippedSong:Bool = false; //Avoid people farming achievements

	//U scawy Achievement
	var scaredTime:Float = 0;

	//Lolbit Achievement
	var lolBitState:Bool = false;
    var lolBitWarning:FlxSprite;
	var lolBitSound:FlxSound;
	var lolBitLuck:Float = 0.15 * ClientPrefs.data.miscEvents;

	//Bonnet Achievement
	var bonnet:FlxSprite;
	var bonnetLuck:Float = 0.25 * ClientPrefs.data.miscEvents;
	var bonnetSound:FlxSound;

	//Trash and the Gang Achievement
	var no1crate:FlxSprite;
	var bucketBob:FlxSprite;
	var no1crateReady:Bool = false;
	var bucketBobLuck:Float = 0.15 * ClientPrefs.data.miscEvents;
	var no1crateLuck:Float = 0.15 * ClientPrefs.data.miscEvents;
	var boomNoise:FlxSound;
	var whisper:FlxSound;
	var curWhisper:Int;
	#end

	override public function create()
	{
		Paths.clearUnusedMemory();

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');
		guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camVideo = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camVideo.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		if (SONG.song == 'lore-ar') {
			phoneCam = new FlxCamera();
			FlxG.cameras.add(phoneCam, false);
		}

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camVideo, false);
		FlxG.cameras.add(camOther, false);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		eventTweens = new FlxTweenManager();
		eventTweensManager = new Map<String, FlxTween>();
		eventTimers = new FlxTimerManager();

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if DISCORD_ALLOWED
		detailsText = "Playing the LOOOOOOOOOORE";
		detailsPausedText = "Paused the Lore";
		#end

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		curStage = SONG.stage;

		#if VIDEOS_ALLOWED
		midSongVideo = new VideoHandler();
		add(midSongVideo);
		midSongVideo.cameras = [camVideo];
	    #end

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else {
			if (stageData.isPixelStage)
				stageUI = "pixel";
		}

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		MARK_X = stageData.mark[0];
		MARK_Y = stageData.mark[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		markCameraOffset = stageData.camera_mark;
		if(markCameraOffset == null)
			markCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
		markGroup = new FlxSpriteGroup(MARK_X, MARK_Y);

		switch (curStage)
		{
			/*COVERS*/
			case 'lore': new states.stages.Lore(); //LOOOOOOOOOORE
			case 'apology': new states.stages.Apology(); //PinkyMicheal would be so proud...
			case 'cronology': new states.stages.Cronology(); //The ultimate lore
			case 'chronology': new states.stages.Chronology(); //The new bg (for the vloo guy stuff (before it was cancelled that is))
			case 'fever': new states.stages.Fever(); //I have a bad case of lore fever v2
			case 'field': new states.stages.Field(); //He could eat a horse... for real...
			case 'live': new states.stages.Live(); //So what is going on Internet, Game Theory back again...
			case 'style': new states.stages.Style(); //He was already handsome as is... but now I'm doubting my sexuality...
			case 'mariotennis': new states.stages.MarioTennis(); //Time for the Ourple pixel measurement everyone has been waiting for...

			/*ORIGINALS*/
			case 'beach': new states.stages.Beach(); //Da Beach (fun fact: the bg was AI generated... yep... I hate myself)
			case 'sad': new states.stages.Sad(); //This was a sad day for gamers...
			case 'sunk': new states.stages.Sunk(); //Funny Iron Lung remix
			case 'ar': new states.stages.AR(); //Why was this game taken down?
		}

		switch (SONG.song.toLowerCase())
		{
			case 'lore-awesomix': new states.stages.addons.Awesomix(); //Don't you tell many how many lores I need, bitch!
			case 'detective': new states.stages.addons.Detective(); //Detective Matpat, at your service.
			case 'action': new states.stages.addons.Action(); //But, y'know... it's just a theory...
			case 'repugnant': new states.stages.addons.Repugnant(); //Phone guy's in love with foxy, Rule34 is in shambles
			case 'lore-og': new states.stages.addons.LoreOG(); //The REAL lore (but without the og ourple).
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);
		add(markGroup);
		add(dadGroup);
		add(boyfriendGroup);

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		startLuasNamed('stages/' + curStage + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + curStage + '.hx');
		#end

		if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterScripts(gf.curCharacter);
		}

		if (sunkMark == 'Mark') stageData.hide_mark = false;

		if (!stageData.hide_mark)
		{
			mark = new Character(0, 0, SONG.player4);
			startCharacterPos(mark);
			markGroup.add(mark);
			startCharacterScripts(mark.curCharacter);

			if (SONG.song.toLowerCase() == 'sunk' && sunkMark == 'Mark')
			{
				mark.cameras = [camHUD];
				mark.x = 154;
				#if html5 //preload for html
				mark.alpha = 0.00001;
				mark.y = -400;
				new FlxTimer().start(0.1, function(tmr:FlxTimer) {
					mark.y = -1037;
					mark.alpha = 1;
				});
				#else
				mark.y = -1037;
				#end
				mark.setGraphicSize(Std.int(mark.width * 0.875));
				mark.updateHitbox();
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterScripts(dad.curCharacter);

		if ((((SONG.song.toLowerCase() == 'lore-og') && ClientPrefs.data.guy != 'Ourple') || ClientPrefs.data.guy == 'Ourple') && SONG.player1 == 'playguy') { // Pretty linear condition but I'll fix that on the future update, for now, idk how to set every song to be Ourple Variant compatible or not.
			var spriteName:String = (ClientPrefs.data.guy == 'Ourple' ? 'playguy' : ClientPrefs.data.guy.toLowerCase());
			var subSpriteName:String = (ClientPrefs.data.ourpleData.get(ClientPrefs.data.guy) == 'Normal' ? '' : '-' + ClientPrefs.data.ourpleData.get(ClientPrefs.data.guy)).toLowerCase();
			boyfriend = new Character(0, 0, spriteName + subSpriteName, true);
		} else {
			boyfriend = new Character(0, 0, SONG.player1, true);
		}

		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterScripts(boyfriend.curCharacter);

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		stagesFunc(function(stage:BaseStage) stage.createPost());

		comboGroup = new FlxSpriteGroup();
		add(comboGroup);
		noteGroup = new FlxTypedGroup<FlxBasic>();
		add(noteGroup);
		uiGroup = new FlxSpriteGroup();
		add(uiGroup);

		hudAssets = new FlxSpriteGroup();
		stars = new FlxSpriteGroup();
		if (ClientPrefs.data.hideHud) {
			hudAssets.visible = false;
			stars.visible = false;
		}

		Conductor.songPosition = -5000 / Conductor.songPosition;
		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 243, 22, 400, "", 30);
		timeTxt.setFormat(Paths.font("ourple.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = updateTime = showTime;
		timeTxt.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = CoolUtil.removeSymbol(SONG.song, 'lore-');
		updateTime = showTime;

		timeBar = new Bar(0, (ClientPrefs.data.downScroll ? 640 : -15), 'OurpleHUD/lore', function() return songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		timeBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), FlxColor.BLACK);
		hudAssets.add(timeBar);
		hudAssets.add(timeTxt);
		
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		noteGroup.add(strumLineNotes);

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001; //cant make it invisible or it won't allow precaching

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		noteGroup.add(grpNoteSplashes);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.84 : 0.11), 'OurpleHUD/healthBar', function() return health, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		uiGroup.add(healthBar);

		var pizzaSpr = Paths.image('OurpleHUD/pizzas/pizza' + (ClientPrefs.data.guy != 'Ourple' ? '-' + ClientPrefs.data.guy : ''));
		if (pizzaSpr == null) pizzaSpr = Paths.image('OurpleHUD/pizzas/pizza');
		var leftPizza:FlxSprite = new FlxSprite(healthBar.bg.getGraphicMidpoint().x - (152 / 2.2) - (healthBar.bg.width / 2), healthBar.bg.getGraphicMidpoint().y - (142 / 1.85)).loadGraphic(pizzaSpr);
		leftPizza.scrollFactor.set();
		switch (ClientPrefs.data.guy)
		{
			case 'Vloo':
				leftPizza.y -= 10;
				leftPizza.x -= 30;
		}
		leftPizza.updateHitbox();
		
		var rightPizza:FlxSprite = new FlxSprite(healthBar.bg.getGraphicMidpoint().x - (152 / 1.8) + (healthBar.bg.width / 2), healthBar.bg.getGraphicMidpoint().y - (142 / 1.85)).loadGraphic(pizzaSpr);
		rightPizza.scrollFactor.set();
		switch (ClientPrefs.data.guy)
		{
			case 'Vloo':
				rightPizza.flipX = true;
				rightPizza.y -= 10;
		}
		rightPizza.updateHitbox();

		stars.cameras = [camHUD];
		for (i in -2...3)
		{
			var star:FlxSprite = new FlxSprite(healthBar.bg.getGraphicMidpoint().x + ((i * 75)) - (150 / 2), healthBar.bg.getGraphicMidpoint().y - (50 / 2));
			star.frames = Paths.getSparrowAtlas('OurpleHUD/star');
			star.animation.addByPrefix('flash', 'star', 30, true);
			star.animation.addByIndices('still', 'star', [19], "", 30, true);
			star.animation.play('still', true);
			star.cameras = [camHUD];
			star.scrollFactor.set();
			star.scale.set(0.85, 0.85);
			stars.add(star);
		}

		hudAssets.add(rightPizza);
		hudAssets.add(leftPizza);
		hudAssets.add(healthBar);

		uiGroup.add(hudAssets);
		uiGroup.add(stars);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 72;
		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 72;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP2);

		if (gf != null)
		{
			iconP3 = new HealthIcon(gf.healthIcon, false);
			iconP3.y = healthBar.y - 72;
			iconP3.visible = !ClientPrefs.data.hideHud;
			iconP3.alpha = ClientPrefs.data.healthBarAlpha;
			uiGroup.add(iconP3);
			iconP3.visible = false;
		}

		scoreTxt = new FlxText(0, (ClientPrefs.data.downScroll && (!ClientPrefs.data.middleScroll && songName != 'lore-ar') ? 0.78 : 0.11) * FlxG.height, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("DIGILF__.TTF"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		scoreTxt.screenCenter(X);
		if (ClientPrefs.data.middleScroll || songName == 'lore-ar') {
			if (ClientPrefs.data.downScroll) scoreTxt.y = healthBar.getGraphicMidpoint().y - 50;
			else scoreTxt.y = healthBar.getGraphicMidpoint().y - 90;
		} 
		uiGroup.add(scoreTxt);

		missesTxt = new FlxText(0, healthBar.getGraphicMidpoint().y - (ClientPrefs.data.downScroll && (ClientPrefs.data.middleScroll || songName == 'lore-ar') ? 90 : 50), FlxG.width, "", 20);
		missesTxt.setFormat(Paths.font("DIGILF__.TTF"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missesTxt.scrollFactor.set();
		missesTxt.borderSize = 1.25;
		missesTxt.visible = !ClientPrefs.data.hideHud;
		missesTxt.screenCenter(X);
		updateScore(false);
		uiGroup.add(missesTxt);

		missText = getMissText();

		botplayTxt = new FlxText(708, timeBar.y + 20, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("DIGILF__.TTF"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		uiGroup.add(botplayTxt);
		if(ClientPrefs.data.downScroll)
			botplayTxt.y = timeBar.y + 30;
		if (ClientPrefs.data.middleScroll || songName == 'lore-ar')
			botplayTxt.screenCenter(X);

		if (ClientPrefs.data.lorayWatermark)
		{
			loraySign = new FlxSprite(0, 207).loadGraphic(Paths.image('OurpleHUD/'+ (SONG.song.toLowerCase() == 'lore-sad' ? 'sadLoraySign' : 'loraySign')));
			loraySign.scrollFactor.set();
			loraySign.scale.set(0.7, 0.7);
			loraySign.updateHitbox();
			loraySign.x = -loraySign.width;
			uiGroup.add(loraySign);
	
			lorayTxt = new FlxText(loraySign.x, 239, loraySign.width, (isCover ? 'Coded by\nLORAY' : 'by\nLORAY'), 48);
			lorayTxt.setFormat(Paths.font("ourple.ttf"), 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			uiGroup.add(lorayTxt);

			creditsJSON = Credits.getCreditsFile(SONG.song);
			if (creditsJSON == null) creditsJSON = Credits.dummy();
		}

		uiGroup.cameras = [camHUD];
		noteGroup.cameras = [camHUD];
		comboGroup.cameras = [camHUD];

		switch (SONG.song.toLowerCase())
		{
			case 'lore-sad', 'lore-awesomix', 'chronology', 'action', 'lore-apology':
				skipCountdown = true;
		}

		if (FlxG.sound.muted) skipCountdown = true;

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		startCallback();
		RecalculateRating();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('hitsound');
		for (i in 1...4) Paths.sound('missnote$i');
		Paths.image('alphabet');

		if (PauseSubState.songName != null)
			Paths.music(PauseSubState.songName);
		else if(Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		resetRPC();

		callOnScripts('onCreatePost');
		if (boyfriend.curCharacter.startsWith('playguy')) boyfriend.defaultY = boyfriend.y;
		if (boyfriend.curCharacter.contains('staring')) boyfriend.defaultX = boyfriend.x;

		switch (SONG.song.toLowerCase())
		{
			case 'chronology':
				gf.visible = false;
				vocals.volume = 0;
				FlxG.sound.music.volume = 0;
				inLoreCutscene = true;

			case 'lore-apology':
				vocals.volume = 0;
				FlxG.sound.music.volume = 0;
				inLoreCutscene = true;
			
			case 'lore-sad':
				gf.visible = false;
				camHUD.visible = false;
				defaultCamZoom = 0.9;
				cameraSpeed = 100;

				FlxTween.color(boyfriend, 0.01, boyfriend.color, FlxColor.fromRGB(44, 44, 44));
				FlxTween.color(dad, 0.01, dad.color, FlxColor.fromRGB(44, 44, 44));
				FlxTween.color(gf, 0.01, gf.color, FlxColor.fromRGB(44, 44, 44));

			case 'lore-tropical':
				isCameraOnForcedPos = true;
				camFollow.x = 1046;
				camFollow.y = 562.8;

			case 'lore-ar':
				isCameraOnForcedPos = true;
				cameraSpeed = 0;
			
			case 'sunk':
				cameraSpeed = 100;
				isCameraOnForcedPos = true;
				camFollow.x = 197.5;
				camFollow.y = 171;
		}

		iconP1.scale.set(1.2, 1.2); //i feel so schizo for doing this BUT it fixes the icons being incorrect spot at the beginning of a song
		iconP2.scale.set(1.2, 1.2);
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null) 
		{
			iconP3.scale.set(1.2, 1.2);
			iconP3.updateHitbox();
		}

		cacheCountdown();
		cachePopUpScore();
		#if ACHIEVEMENTS_ALLOWED cacheAchievementsStuff(); #end

		super.create();
		Paths.clearUnusedMemory();

		if(eventNotes.length < 1) checkEventNote();
	}

	public function playVideo(video:String)
	{
		#if VIDEOS_ALLOWED
		midSongVideo.play(Paths.video(video));
		//midSongVideo.height = FlxG.height;
		//midSongVideo.width = FlxG.width+5;
		#end
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function reloadHealthBarColors() {
		healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}

			case 3:
				if(mark != null && !markMap.exists(newCharacter)) {
					var newMark:Character = new Character(0, 0, newCharacter);
					markMap.set(newCharacter, newMark);
					markGroup.add(newMark);
					startCharacterPos(newMark, true);
					newMark.alpha = 0.00001;
					startCharacterScripts(newMark.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getSharedPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getSharedPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		#end
		{
			scriptFile = Paths.getSharedPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}

		if(doPush)
		{
			if(SScript.global.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		#end
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
			#if (hxCodec >= "3.0.0")
			// Recent versions
			video.play(filepath);
			video.bitmap.onEndReached.add(function()
			{
				video.destroy();
				startAndEnd();
				return;
			}, true);
			#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	#if ACHIEVEMENTS_ALLOWED
	function cacheAchievementsStuff()
	{
		if (ClientPrefs.data.miscEvents > 0)
		{
			Paths.sound('lolbit');
			Paths.sound('nosepush');
			Paths.sound('boom');

			lolBitWarning = new FlxSprite().loadGraphic(Paths.image('miscEvents/lolbit'));
			lolBitWarning.cameras = [camHUD];
			lolBitWarning.scale.set(0.75, 0.75);
			lolBitWarning.updateHitbox();
			lolBitWarning.screenCenter(XY);
			add(lolBitWarning);
			lolBitWarning.visible = false;
	
			lolBitSound = new FlxSound();
			lolBitSound.loadEmbedded(Paths.sound('lolbit'));
			lolBitSound.volume = 0;
			lolBitSound.looped = true;
			lolBitSound.play();

			resetBonnet();

			for (i in 1...5)
				Paths.sound('whispers/whisper' + i);

			resetNo1Crate();

			curWhisper = FlxG.random.int(1, 5);
			whisper = new FlxSound();

			Paths.image('miscEvents/bob1');
			Paths.image('miscEvents/bob2');

			bucketBob = new FlxSprite().loadGraphic(Paths.imageRandom('miscEvents/bob', 1, 2));
			bucketBob.cameras = [camOther];
			add(bucketBob);
			bucketBob.visible = false;
			bucketBob.scale.set(4/3, 4/3);
			bucketBob.updateHitbox();
			bucketBob.scrollFactor.set();
			bucketBob.screenCenter(XY);
			bucketBob.antialiasing = ClientPrefs.data.antialiasing;

			boomNoise = new FlxSound();
			boomNoise.loadEmbedded(Paths.sound('boom'));
			boomNoise.onComplete = function() {
				bucketBob.visible = false;
				bucketBob.loadGraphic(Paths.imageRandom('miscEvents/bob', 1, 2));
				no1crate.visible = false;
				no1crate.loadGraphic(Paths.imageRandom('miscEvents/no1crate-', 1, 3));
				resetNo1Crate();
				Achievements.unlock('trash_gang');
			}
		}
	}

	function resetBonnet() //It is possible to get bonnet more than once in a single game.
	{
		bonnet = new FlxSprite();
		bonnet.cameras = [camOther];
		bonnet.frames = Paths.getSparrowAtlas('miscEvents/bonnet');
		bonnet.animation.addByPrefix('idle', 'Idle', 24, true);
		bonnet.animation.addByPrefix('jumpscare', 'Jumpscare', 24, false);
		bonnet.animation.play('idle');
		add(bonnet);
		bonnet.visible = false;
		bonnet.scale.set(1.25, 1.25);
		bonnet.updateHitbox();
		bonnet.scrollFactor.set();
		bonnet.setPosition(FlxG.width + bonnet.width, (FlxG.height - bonnet.height) + 40);
		bonnet.antialiasing = ClientPrefs.data.antialiasing;

		bonnetSound = new FlxSound();
		bonnetSound.loadEmbedded(Paths.sound('nosepush'));
	}

	function resetNo1Crate() 
	{
		no1crate = new FlxSprite().loadGraphic(Paths.image('miscEvents/no1crate-ready'));
		no1crate.cameras = [camOther];
		no1crate.scrollFactor.set();
		no1crate.scale.set(0.75, 0.75);
		no1crate.updateHitbox();
		no1crate.setPosition(50, FlxG.height - no1crate.height);
		no1crate.antialiasing = ClientPrefs.data.antialiasing;
		add(no1crate);
		no1crate.visible = false;
	}

    private function loadAndPlayWhisper():Void {
        var soundPath = 'whispers/whisper' + curWhisper;
        whisper.loadEmbedded(Paths.sound(soundPath), true);
        
        whisper.onComplete = function() {
            if (FlxG.random.bool(40)) {
                handleCrateAnimation();
				whisper.looped = false;
				whisper.stop();
            } else {
                curWhisper = FlxG.random.int(1, 5, [curWhisper]);
                loadAndPlayWhisper();
            }
        };

        whisper.play();
    }

    private function handleCrateAnimation():Void {
        no1crate.loadGraphic(Paths.imageRandom('miscEvents/no1crate-', 1, 3));
        no1crate.scale.set(4/3, 4/3);
        no1crate.updateHitbox();
        no1crate.screenCenter(XY);
        boomNoise.play();
    }
	#end

	function cacheCountdown()
	{
		var guy:String = (ClientPrefs.data.guy != 'Ourple' ? '-' + ClientPrefs.data.guy : '');
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['${stageUI}UI/ready-pixel' + guy, '${stageUI}UI/set-pixel' + guy, '${stageUI}UI/date-pixel' + guy];
			case "normal": ["OurpleHUD/countdowns/ready" + guy, "OurpleHUD/countdowns/set" + guy, "OurpleHUD/countdowns/go" + guy];
			default: ['${stageUI}UI/ready' + guy, '${stageUI}UI/set' + guy, '${stageUI}UI/go' + guy];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);

		Paths.sound('intros/intro3' + introSoundsSuffix + guy);
		Paths.sound('intros/intro2' + introSoundsSuffix + guy);
		Paths.sound('intros/intro1' + introSoundsSuffix + guy);
		Paths.sound('intros/introGo' + introSoundsSuffix + guy);
	}

	public function startCountdown()
	{
		switch (SONG.song.toLowerCase()) {
			case 'lore-sad':
				if (!states.stages.Sad.allowCountdown)
				{
					new FlxTimer().start(2.6, function(tmr:FlxTimer) {
						states.stages.Sad.allowCountdown = true;
						startCountdown();
					});
					FlxTween.tween(camGame, {zoom: 0.9}, 3.5, {ease:FlxEase.sineOut});
					FlxTween.tween(states.stages.Sad.blackIntro, {alpha: 0}, 2.5, {ease:FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
						states.stages.Sad.blackIntro.destroy();
					}});
					return false;
				}

			case 'fever':
				FlxTween.tween(camGame, {zoom: 0.9}, 4, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
					camZooming = true;
				}});
				camZooming = false;
				defaultCamZoom = 0.9;
		}

		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				var guy:String = (ClientPrefs.data.guy != 'Ourple' ? '-' + ClientPrefs.data.guy : '');
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['${stageUI}UI/ready-pixel' + guy, '${stageUI}UI/set-pixel' + guy, '${stageUI}UI/date-pixel' + guy];
					case "normal": ["OurpleHUD/countdowns/ready" + guy, "OurpleHUD/countdowns/set" + guy, "OurpleHUD/countdowns/go" + guy];
					default: ['${stageUI}UI/ready' + guy, '${stageUI}UI/set' + guy, '${stageUI}UI/go' + guy];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;
				var mute:Bool = (introSoundsSuffix == '-nothing');

				if (!mute)
				{
					switch (swagCounter)
					{
						case 0:
							var sound = Paths.sound('intros/intro3' + introSoundsSuffix + guy);
							if (sound == null) sound =  Paths.sound('intros/intro3' + introSoundsSuffix);
							FlxG.sound.play(sound, 0.6);
							tick = THREE;
						case 1:
							countdownReady = createCountdownSprite(introAlts[0], antialias);
							var sound = Paths.sound('intros/intro2' + introSoundsSuffix + guy);
							if (sound == null) sound =  Paths.sound('intros/intro2' + introSoundsSuffix);
							FlxG.sound.play(sound, 0.6);
							tick = TWO;
						case 2:
							countdownSet = createCountdownSprite(introAlts[1], antialias);
							var sound = Paths.sound('intros/intro1' + introSoundsSuffix + guy);
							if (sound == null) sound =  Paths.sound('intros/intro1' + introSoundsSuffix);
							FlxG.sound.play(sound, 0.6);
							tick = ONE;
						case 3:
							countdownGo = createCountdownSprite(introAlts[2], antialias);
							var sound = Paths.sound('intros/introGo' + introSoundsSuffix + guy);
							if (sound == null) sound =  Paths.sound('intros/introGo' + introSoundsSuffix);
							FlxG.sound.play(sound, 0.6);
							tick = GO;
						case 4:
							tick = START;
					}
				} else {
					switch (swagCounter)
					{
						case 0:
							tick = THREE;
						case 1:
							tick = TWO;
						case 2:
							tick = ONE;
						case 3:
							tick = GO;
						case 4:
							tick = START;
					}
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.data.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if((ClientPrefs.data.middleScroll || songName == 'lore-ar') && !note.mustPress)
							note.alpha *= 0.35;
					}
				});

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();
		spr.angle = FlxG.random.float(5, 12);

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(noteGroup), spr);
		FlxTween.tween(spr, {y: spr.y + 66, alpha: 0, angle: 0}, Conductor.crochet / 800, {
			ease: FlxEase.cubeIn
		});

		FlxTween.tween(spr.scale, {y: 0.7, x: 0.7}, Conductor.crochet / 800, {
			ease: FlxEase.cubeIn,
			onComplete: function(twn:FlxTween)
			{
				remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}
	public function addBehindMark(obj:FlxBasic)
	{
		insert(members.indexOf(markGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}

	public dynamic function updateScore(miss:Bool = false)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		var str:String = ratingName;
		if(totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str += ' (${percent}%) - ${ratingFC}';
		}

		scoreTxt.text = 'Score:' + ((ClientPrefs.data.middleScroll || songName == 'lore-ar') ? ' ' : '\n') + songScore;
		scoreTxt.size = 42;

		missesTxt.text = missText + songMisses;
		missesTxt.size = 42;

		if (!miss && !cpuControlled)
			doScoreBop();

		callOnScripts('onUpdateScore', [miss]);
	}

	public dynamic function fullComboFunction()
	{
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;
	
		ratingFC = "";
		if (songMisses == 0) {
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else {
			ratingFC = songMisses < 10 ? 'SDCB' : 'Clear';
		}
	
		var playFlash:Bool = ratingFC.endsWith('FC');
	
		for (i in 0...stars.members.length) {
			if (playFlash) {
				if (stars.members[i].animation.curAnim.name != 'flash') {
					stars.members[i].animation.play('flash', true);
					stars.members[i].color = 0xFFFFFFFF;
				}
			} else {
				if (stars.members[i].animation.curAnim.name != 'still') {
					stars.members[i].animation.play('still', true);
				}
	
				var threshold:Int = 0;
				if (ratingPercent * 100 > 95) threshold = 100;
				else if (ratingPercent * 100 > 90) threshold = 5;
				else if (ratingPercent * 100 > 80) threshold = 4;
				else if (ratingPercent * 100 > 70) threshold = 3;
				else if (ratingPercent * 100 > 60) threshold = 2;
				else if (ratingPercent * 100 > 50) threshold = 1;
	
				starCheck(i, threshold);
			}
		}
	}

	public function doScoreBop():Void {
		if(!ClientPrefs.data.scoreZoom)
			return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});

		if(missesTxtTween != null)
			missesTxtTween.cancel();

		missesTxt.scale.x = 1.075;
		missesTxt.scale.y = 1.075;
		missesTxtTween = FlxTween.tween(missesTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				missesTxtTween = null;
			}
		});
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			opponentVocals.time = time;
			#if FLX_PITCH
			vocals.pitch = playbackRate;
			opponentVocals.pitch = playbackRate;
			#end
		}
		vocals.play();
		opponentVocals.play();
		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 0.85, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.volume = 0.85;
		vocals.play();
		opponentVocals.volume = 0.85;
		opponentVocals.play();

		if(startOnTime > 0) setSongTime(startOnTime - 500);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		if (ClientPrefs.data.lorayWatermark)
		{
			if (creditsJSON != null && creditsJSON.step > 0)
				creditsStep = creditsJSON.step;
			else if (creditsJSON != null)
				showCredits();
		}

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength);
		#end
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');

		switch (SONG.song.toLowerCase())
		{
			case 'lore-awesomix':
				inLoreCutscene = true;
				FlxTween.tween(states.stages.addons.Awesomix.prange, {x: (FlxG.width / 2) - 210, angle: 0}, 1.5, {ease: FlxEase.cubeOut});

			case 'lore-apology':
				FlxG.sound.music.volume = 0.9;
				vocals.volume = 0.85;
				opponentVocals.volume = 0.85;
				states.stages.Apology.blackness.alpha = 0; 

			case 'chronology':
				camOther.flash(FlxColor.WHITE, 1.7);
				vocals.volume = 0.85;
				opponentVocals.volume = 0.85;
				FlxG.sound.music.volume = 1;
				FlxTween.tween(states.stages.Cronology.fnafLogo.scale, {x: 0.225, y: 0.225}, 3, {ease: FlxEase.linear});

			case 'lore-style':
				camGame.flash(FlxColor.WHITE, 0.9);
				states.stages.Style.blackIntro.destroy();
				states.stages.Style.light.visible = true;

			case 'live':
				camGame.visible = true;
				camHUD.flash(FlxColor.WHITE, 0.9);
				cameraSpeed = 100;
				defaultCamZoom = 1;
				camGame.zoom = 1;
				camLock(true);

			case 'detective':
				camGame.flash(FlxColor.WHITE, 0.9);
				defaultCamZoom = 1;

			case 'measure-up':
				camGame.flash(FlxColor.WHITE, 0.9);

			case 'action':
				FlxTween.tween(states.stages.addons.Action.bOverlay, {alpha: 0}, Std.int((Conductor.crochet / 1000) * 32), {startDelay: 0.7, ease: FlxEase.sineInOut});
				FlxTween.tween(camGame, {zoom: 1}, Std.int((Conductor.crochet / 1000) * 28), {startDelay: 0.7, ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
					camZooming = true;
					defaultCamZoom = 0.8;
				}});

			case 'repugnant':
				cameraSpeed = 1000;
				defaultCamZoom = 1;

			case 'lore-sad':
				camHUD.visible = true;
				FlxTween.color(dad, 0.01, dad.color, FlxColor.WHITE);
				states.stages.Sad.spotlightMatpat.visible = true;
				FlxG.sound.play(Paths.sound('spotlight'));
				cameraSpeed = 1;
				camLock(true);

			case 'lore-og':
				camGame.alpha = 1;
				cameraSpeed = 1000;
				camGame.flash(FlxColor.WHITE, 0.7);
				camGame.zoom = 1.1;
				defaultCamZoom = 1.1;
		}
	}

	var debugNum:Int = 0;
	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, ((boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile) + (SONG.song.toLowerCase() == 'sunk' ? '-$sunkMark' : ''));
				vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, ((dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile) + (SONG.song.toLowerCase() == 'sunk' ? '-$sunkMark' : ''));
				if(oppVocals != null) opponentVocals.loadEmbedded(oppVocals);
			}
		}
		catch(e:Dynamic) {}

		#if FLX_PITCH
		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		#end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		inst = new FlxSound();
		try {
			inst.loadEmbedded(Paths.inst(songData.song));
		}
		catch(e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		#else
		if (OpenFlAssets.exists(file))
		#end
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
				for (i in 0...event[1].length)
					makeEvent(event, i);
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = ((section.gfSection) && (songNotes[1]<4)) || (section.gfIsSinging && section.mustHitSection);
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				unspawnNotes.push(swagNote);

				final susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				final floorSus:Int = Math.floor(susLength);

				if(floorSus > 0) {
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = ((section.gfSection) && (songNotes[1]<4)) || (section.gfIsSinging && section.mustHitSection);
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.updateHitbox();
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.updateHitbox();
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if((ClientPrefs.data.middleScroll || songName == 'lore-ar'))
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if((ClientPrefs.data.middleScroll || songName == 'lore-ar'))
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypes.contains(swagNote.noteType)) {
					noteTypes.push(swagNote.noteType);
				}
			}
		}
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'mark' | 'markiplier' | '3':
						charType = 3;
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != LuaUtils.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var strumLineX:Float = (ClientPrefs.data.middleScroll || songName == 'lore-ar') ? STRUM_X_MIDDLESCROLL : STRUM_X;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll || songName == 'lore-ar') targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(ClientPrefs.data.middleScroll || songName == 'lore-ar')
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	var pausedmidSongVideo:Bool = false;
	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
			}
			eventTweens.active = false;
			eventTimers.active = false;

			#if ACHIEVEMENTS_ALLOWED
			if (ClientPrefs.data.miscEvents > 0) {
				if (whisper.playing) whisper.pause();
				if (lolBitState) lolBitSound.pause();
			} 
			#end

			#if VIDEOS_ALLOWED
			if (midSongVideo != null && midSongVideo.bitmap.isPlaying) {
				midSongVideo.bitmap.pause();
				pausedmidSongVideo = true;
			}
			#end
			
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		super.closeSubState();
		
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);

			paused = false;

			eventTweens.active = true;
			eventTimers.active = true;

			#if ACHIEVEMENTS_ALLOWED
			if (ClientPrefs.data.miscEvents > 0) {
				if (no1crate.visible) whisper.resume();
				if (lolBitState) lolBitSound.resume();
			}
			#end

			#if VIDEOS_ALLOWED
			if (midSongVideo != null && pausedmidSongVideo) {
				midSongVideo.bitmap.resume();
				pausedmidSongVideo = false;
			}
			#end

			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}
	}

	override public function onFocus():Void
	{
		if (health > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if DISCORD_ALLOWED
		if (health > 0 && !paused && autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		#end

		super.onFocusLost();
	}

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
		else
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength);
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
		}

		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
		}
		vocals.play();
		opponentVocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;
	var angleOfs:Float = 0;
	var ringing:Bool = false;

	override public function update(elapsed:Float)
	{
		if(!inCutscene && !paused && !freezeCamera) {
			FlxG.camera.followLerp = 2.4 * cameraSpeed * playbackRate;
		} else {
			FlxG.camera.followLerp = 0;
		}
		callOnScripts('onUpdate', [elapsed]);

		if (healthBar.percent < 20) {
			iconP1.angle = FlxG.random.float(-5, 5);
		} else {
			iconP1.angle = 0;
		}

		if (ClientPrefs.data.lorayWatermark)
		{
			if (loraySign != null)
			{
				if (FlxG.mouse.overlaps(loraySign, camHUD)) //Doesn't work with FlxTexts, so here's a workaround ig
				{
					lorayTxt.color = 0x3fe780;
					if (FlxG.mouse.justPressed)
						CoolUtil.browserLoad('https://youtube.com/@LORAY_');
				} else {
					lorayTxt.color = 0xFFFFFF;
				}
			} else {
				lorayTxt.color = 0xFFFFFF;
			}
		}

		super.update(elapsed);

		eventTweens.update(elapsed);
		eventTimers.update(elapsed);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		if(botplayTxt != null && botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE_P && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		//You ain't getting the editors, lol
		#if !html5
		if(!endingSong && !inCutscene && allowDebugKeys && startedCountdown)
		{
			if (controls.justPressed('debug_1'))
				openChartEditor();
			else if (controls.justPressed('debug_2'))
				openCharacterEditor();
		}
		#end

		if (healthBar.bounds.max != null && health > healthBar.bounds.max)
			health = healthBar.bounds.max;

		updateIconsScale(elapsed);

		if (!isPixelStage && !iconPositionLocked){
			iconP1.x = healthBar.bg.getGraphicMidpoint().x + (healthBar.bg.width / 2) - (iconP1.width / 2.5);
			iconP2.x = healthBar.bg.getGraphicMidpoint().x - (healthBar.bg.width / 2) - (iconP2.width / 2.5);
			
			if (gf != null && iconP3.visible) {
				if (SONG.notes[curSection].gfIsSinging) iconP3.x = iconP1.x;
				else iconP3.x = (SONG.notes[curSection].mustHitSection ? iconP1.x : iconP2.x);
			}
		}

		if (startedCountdown && !paused)
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET_P && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			canReset = false;
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();
				else
					playerDance();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if(daNote.mustPress)
							{
								if(cpuControlled && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteHit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
							{
								if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
									noteMiss(daNote);

								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		if (gf != null)
		{
			if (gf.animation.curAnim.name == 'ringstart' && gf.animation.curAnim.finished)
				gf.animation.play('ringloop', true, false, 0);
	
			if (gf.animation.curAnim.name.contains('ring') && !gf.animation.curAnim.name.endsWith('end')) {
				ringing = true;
				angleOfs = FlxG.random.float(-5, 5);
				iconP3.angle = angleOfs;
			} else if (ringing) {
				iconP3.angle = 0;
				ringing = false; //If you wanna mess around with the icon's angle in the future, this is necessary
			}
		}

		#if ACHIEVEMENTS_ALLOWED
		if (healthBar.percent < 20.0 && scaredTime <= 60)
		{
			scaredTime += elapsed;
			if (scaredTime >= 60) Achievements.unlock('u_scawy');
		}
		
		if (!endingSong && !startingSong && FlxG.sound.muted)
		{
			Achievements.unlock('cheater');
			skippedSong = true;
			clearNotesBefore(FlxG.sound.music.length - 10);
			setSongTime(FlxG.sound.music.length - 10);
			endSong();
			vocals.volume = 0;
			opponentVocals.volume = 0;
		}
		
		if (FlxG.keys.pressed.C && FlxG.keys.pressed.D && (FlxG.keys.justPressed.NUMPADPLUS || FlxG.keys.justPressed.PLUS))
		{
			skippedSong = true;
			Achievements.unlock('exploiter');
			KillNotes();
			endSong();
			vocals.volume = 0;
			opponentVocals.volume = 0;
		}

		if (bonnet.visible && FlxG.mouse.overlaps(bonnet, camOther) && FlxG.mouse.justPressed)
		{
			bonnetSound.play();
			FlxTween.tween(bonnet, {y: FlxG.height + bonnet.height}, 0.3, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween) {
				FlxTween.cancelTweensOf(bonnet);
				FlxG.mouse.visible = false;
				resetBonnet();
				Achievements.unlock('bonnet');
			}});
		}

		if (bucketBob.visible) {
			bucketBob.setPosition(FlxG.random.float(-5, 5), FlxG.random.float(-5, 5));
			if (FlxG.random.bool(0.25)) bucketBob.loadGraphic(Paths.imageRandom('miscEvents/bob', 1, 2));
		}

		if (no1crate.visible && boomNoise.playing) {
			no1crate.setPosition(FlxG.random.float(-5, 5), FlxG.random.float(-5, 5));
			if (FlxG.random.bool(0.25)) no1crate.loadGraphic(Paths.imageRandom('miscEvents/no1crate-', 1, 3));
		}
		#end

		setOnScripts('cameraX', camFollow.x);
		setOnScripts('cameraY', camFollow.y);
		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		switch (SONG.song.toLowerCase())
		{	
			case 'lore-tropical':
				if (states.stages.Beach.brubMoment) {
					if (FlxG.keys.justPressed.SPACE && !states.stages.Beach.cooldown) {
						var amongus:String = states.stages.Beach.taunt();
						FlxG.sound.play(Paths.sound('taunt'), 0.25, false);
						boyfriend.playAnim('sing' + amongus, true, false, 4);
						
						if (!ClientPrefs.getGameplaySetting('botplay'))
						{
							var scoreTauntText:FlxText = new FlxText((ClientPrefs.data.downScroll ? 575 : 1320), (ClientPrefs.data.downScroll ? 370 : 770), 0, '+ ' + Std.string((states.stages.Beach.bonus) + (states.stages.Beach.matpatTaunt ? 1500 : 0)) + (ClientPrefs.data.downScroll ? '' : 'pts'), 36);
							scoreTauntText.setFormat(Paths.font('ourple.ttf'), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							scoreTauntText.borderSize = 2;
							FlxTween.tween(scoreTauntText, {alpha: 0, y: scoreTauntText.y - 50}, 1.2, {ease:FlxEase.sineOut, onComplete: function(twn:FlxTween) {
								scoreTauntText.destroy();
							}});
							
							add(scoreTauntText);
							songScore += states.stages.Beach.bonus + (states.stages.Beach.matpatTaunt ? 1500 : 0);
							RecalculateRating();
							health += 0.05;
						}
					}
				}
		}
	}

	// Health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP1.scale.set(mult, mult);

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP2.scale.set(mult, mult);

		if (gf != null)
		{
			var mult:Float = FlxMath.lerp(1, iconP3.scale.x, Math.exp(-elapsed * 9 * playbackRate));
			iconP3.scale.set(mult, mult);
		}
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float // You can alter how icon animations work here
	{
		if(!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		// update health bar
		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		if (iconP1.isCool)
		{
			if (healthBar.percent < 20) {
				iconP1.animation.curAnim.curFrame = 1;
			} else if (healthBar.percent >= 20 && healthBar.percent <= 80) {
				iconP1.animation.curAnim.curFrame = 0;
			} else if (healthBar.percent > 80) {
				iconP1.animation.curAnim.curFrame = 2;
			}
		}
		else 
		{
			if (healthBar.percent < 20) {
				iconP1.animation.curAnim.curFrame = 1;
			} else {
				iconP1.animation.curAnim.curFrame = 0;
			}
		}

		if (iconP2.isCool)
		{
			if (healthBar.percent < 20) {
				iconP2.animation.curAnim.curFrame = 2;
			} else if (healthBar.percent >= 20 && healthBar.percent <= 80) {
				iconP2.animation.curAnim.curFrame = 0;
			} else if (healthBar.percent > 80) {
				iconP2.animation.curAnim.curFrame = 1;
			}
		}
		else
		{
			if (healthBar.percent > 80) {
				iconP2.animation.curAnim.curFrame = 1;
			} else {
				iconP2.animation.curAnim.curFrame = 0;
			}
		}

		if (gf != null)
		{
			if (iconP3.isCool)
			{
				if (healthBar.percent < 20) {
					iconP3.animation.curAnim.curFrame = 2;
				} else if (healthBar.percent >= 20 && healthBar.percent <= 80) {
					iconP3.animation.curAnim.curFrame = 0;
				} else if (healthBar.percent > 80) {
					iconP3.animation.curAnim.curFrame = 1;
				}
			}
			else
			{
				if (healthBar.percent > 80) {
					iconP3.animation.curAnim.curFrame = 1;
				} else {
					iconP3.animation.curAnim.curFrame = 0;
				}
			}
		}
		return health;
	}

	function openPauseMenu()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}
		openSubState(new PauseSubState());

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		chartingMode = true;
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Charting the LOOOOOOOOOOORE", null, null, true);
		DiscordClient.resetClientID();
		#end

		MusicBeatState.switchState(new ChartingState());
	}

	function openCharacterEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop) {
				FlxG.animationTimeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				opponentVocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				#if LUA_ALLOWED
				modchartTimers.clear();
				modchartTweens.clear();
				#end

				#if ACHIEVEMENTS_ALLOWED
				if (ClientPrefs.data.miscEvents > 0)
				{
					if (lolBitState) {
						lolBitWarning.destroy();
						lolBitSound.destroy();
						inputBuffer = "";
						lolBitState = false;
					}
					boomNoise.destroy();
					whisper.destroy();
				}
				#end

				if (SONG.song.toLowerCase() == 'lore-sad' && songHits == 0 && canReset)
					Achievements.unlock('too_sad');

				if (SONG.song == 'lore-ar')
					phoneCam.visible = false;

				openSubState(new GameOverSubstate());

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence("Bro, this guy sucks, he fucking died dude!", SONG.song, iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEvent(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.35) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					case 'mark' | 'markiplier':
						char = mark;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					isCameraOnForcedPos = false;
					if(flValue1 != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if(flValue1 == null) flValue1 = 0;
						if(flValue2 == null) flValue2 = 0;
						camFollow.x = flValue1;
						camFollow.y = flValue2;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					case 'mark' | 'markiplier':
						char = mark;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					case 'mark' | 'markiplier':
						charType = 3;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);

							if (boyfriend.curCharacter.startsWith('playguy')) {
								boyfriend.defaultY = boyfriend.y;
							}

							if (boyfriend.curCharacter.contains('staring')) {
								boyfriend.defaultX = boyfriend.x;
							}
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
								iconP3.changeIcon(gf.healthIcon);
							}
							setOnScripts('gfName', gf.curCharacter);
						}
					case 3:
						if(mark.curCharacter != value2) {
							if(!markMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = mark.alpha;
							mark.alpha = 0.00001;
							mark = markMap.get(value2);
							mark.alpha = lastAlpha;
						}
						setOnLuas('markName', mark.curCharacter);
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				try
				{
					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], value2);
					} else {
						LuaUtils.setVarInArray(this, value1, value2);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}

			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);
		}

		if (boyfriend.curCharacter.startsWith('playguy')) {
			if (eventName == 'Play Animation' && (value2 == 'bf' || flValue2 == 0)) {
				if (eventTweensManager.exists('raise')) eventTweensManager.get('raise').cancel();
				boyfriend.y = boyfriend.defaultY;
				if (boyfriend.curCharacter.contains('staring')) boyfriend.x = boyfriend.defaultX;
				boyfriend.flipX = true;
			}
		}

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		if (gf != null && SONG.notes[sec].gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		moveCamera(isDad);
		callOnScripts('onMoveCamera', [isDad ? 'dad' : 'boyfriend']);
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	public function tweenCamIn() {
		if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return false;
			}
		}

		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		inLoreCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if (ClientPrefs.data.miscEvents > 0)
		{
			if (lolBitState) closeLolBitState(false);
			if (no1crate.visible) {
				whisper.destroy();
				no1crate.destroy();
			}
			if (bucketBob.visible) bucketBob.destroy();
			boomNoise.destroy();
		}
			

		if (!skippedSong) checkForAchievement(['frame_by_frame', 'lore_enjoyer', 'ourple_lover', 'true_theorist']);
		#end

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != LuaUtils.Function_Stop && !transitioning)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
			playbackRate = 1;

			#if !html5
			if (chartingMode)
			{
				openChartEditor();
				return false;
			}
			#end

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					Mods.loadTopMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				Mods.loadTopMod();
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

				MusicBeatState.switchState(new FreeplayState(true));
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
		return true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;
	// Stores HUD Objects in a Group
	public var uiGroup:FlxSpriteGroup;
	// Stores Note Objects in a Group
	public var noteGroup:FlxTypedGroup<FlxBasic>;

	private function cachePopUpScore()
	{
		var uiPrefix:String = '';
		var uiSuffix:String = '';
		var guy:String = (ClientPrefs.data.guy != 'Ourple' ? '-' + ClientPrefs.data.guy : '');
		if (stageUI != "normal") {
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
		} else {
			uiPrefix = 'OurpleHUD/ratings/';
		}

		for (rating in ratingsData)
			Paths.image(uiPrefix + rating.image + uiSuffix + guy);
		for (i in 0...10)
			Paths.image('num' + i + uiSuffix);
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 0.85;

		if (!ClientPrefs.data.comboStacking && comboGroup.members.length > 0) {
			for (spr in comboGroup) {
				spr.destroy();
				comboGroup.remove(spr);
			}
		}

		var placement:Float = FlxG.width * 0.35;
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashData.disabled)
			spawnNoteSplashOnNote(note);

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var uiPrefix:String = "";
		var uiSuffix:String = '';
		var guy:String = (ClientPrefs.data.guy != 'Ourple' ? '-' + ClientPrefs.data.guy : '');
		var antialias:Bool = ClientPrefs.data.antialiasing;

		if (stageUI != "normal") {
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
			antialias = !isPixelStage;
		} else {
			uiPrefix = 'OurpleHUD/ratings/';
		}

		var isitonehundra:String = '';
		if (ratingFC == 'SFC' && (daRating.image == 'sick')) isitonehundra = '100';

		rating.loadGraphic(Paths.image(uiPrefix + daRating.image + isitonehundra + uiSuffix + guy));
		rating.cameras = [camHUD];
		rating.setPosition(iconP1.getGraphicMidpoint().x + 75, iconP1.getGraphicMidpoint().y - 50);
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 200) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 20) * playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && showRating);
		rating.angle = FlxG.random.int(-10, 10);
		rating.angularVelocity = FlxG.random.int(-20, 20) * playbackRate;
		rating.scrollFactor.set();
		rating.scale.set(0.85, 0.85);

		if (isitonehundra == '100') {
			rating.color = FlxColor.YELLOW;
			FlxTween.color(rating, 0.25, FlxColor.YELLOW, FlxColor.WHITE);
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo' + uiSuffix));
		comboSpr.screenCenter();
		comboSpr.x = placement;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		comboGroup.add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
			comboGroup.add(comboSpr);

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i) + uiSuffix));
			numScore.screenCenter();
			numScore.x = (iconP2.getGraphicMidpoint().x - 175) + (43 * daLoop) - 90;
			numScore.y = iconP2.getGraphicMidpoint().y;

			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;
			numScore.antialiasing = antialias;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				comboGroup.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	public var authorizedKeys:Array<String> = ['l', 'o'];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			//Prevents crash specifically on debug without needing to try catch shit
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
		}

		var char:String = String.fromCharCode(event.charCode).toLowerCase();

		#if ACHIEVEMENTS_ALLOWED
		if (key == -1 || authorizedKeys.contains(char)) //Runs if the key pressed isn't part of the player's controls
		{
			inputBuffer += char;
	
			if (ClientPrefs.data.miscEvents > 0 && lolBitState)
			{
				if (char == 'l' || char == 'o') 
					FlxG.sound.play(Paths.sound('cameraBlip'), 1);
				else
					inputBuffer = "";
			}
	
			switch (inputBuffer) 
			{
				case "lol":
					if (ClientPrefs.data.miscEvents > 0 && lolBitState) 
						closeLolBitState();
					else
						inputBuffer = "";
			}
	
			if (inputBuffer.length >= 4) inputBuffer = "";
		}
		#end
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || boyfriend.stunned) return;

		var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return n != null && canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		var shouldMiss:Bool = !ClientPrefs.data.ghostTapping;

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}
			goodNoteHit(funnyNote);
		}
		else if(shouldMiss)
		{
			callOnScripts('onGhostTap', [key]);
			noteMissPress(key);
		}

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		var spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyRelease', [key]);
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			if(controls.controllerMode)
			{
				pressArray.push(controls.justPressed(key));
				releaseArray.push(controls.justReleased(key));
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) { // I can't do a filter here, that's kinda awesome
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					if (guitarHeroSustains)
						canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						var released:Bool = !holdArray[n.noteData];

						if (!released)
							goodNoteHit(n);
					}
				}
			}

			if (!holdArray.contains(true) || endingSong)
				playerDance();
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		noteMissCommon(daNote.noteData, daNote);

		if (boyfriend.curCharacter.startsWith('playguy'))
		{
			if (!daNote.gfNote) {
				if (eventTweensManager.exists('raise')) eventTweensManager.get('raise').cancel();
				boyfriend.y = boyfriend.defaultY;
				if (boyfriend.curCharacter.contains('staring')) boyfriend.x = boyfriend.defaultX;
				boyfriend.flipX = true;
			}
		}

		if (boyfriend.curCharacter.startsWith('bloxxy')) FlxG.sound.play(Paths.sound('OOF')); //Funni mechanic ig

		if (!ClientPrefs.data.lowQuality && boyfriend.curCharacter.startsWith('hrey')) {
			var splash:FlxSprite = new FlxSprite().loadGraphic(Paths.imageRandom('ink/ink', 1, 4));
			splash.angle = FlxG.random.int(-15, 15);
			splash.scale.set(FlxG.random.float(0.4, 0.7), FlxG.random.float(0.4, 0.7));
			splash.cameras = [camOther];
			splash.setPosition(FlxG.random.float(-FlxG.width / 2, FlxG.width / 2), FlxG.random.float(-FlxG.height / 2, FlxG.height / 2));
			add(splash);
			FlxG.sound.play(Paths.sound('splash'), 0.5);
			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
				FlxTween.tween(splash, {y: splash.y + 75, alpha: 0}, 0.4, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
					splash.destroy();
				}});
			});
		}

		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null)
	{
		// score and data
		var subtract:Float = 0.05;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && guitarHeroSustains && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.35;
				for(childNote in note.tail) {
					childNote.alpha = note.alpha;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}
				note.missed = true;
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -Tahir
			}

			if (note.missed)
				return;
		}
		if (note != null && guitarHeroSustains && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				for (child in parentNote.tail) if (child != note) {
					child.missed = true;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		var lastCombo:Int = combo;
		combo = 0;

		health -= subtract * healthLoss;
		if(!practiceMode) songScore -= 10;
		if(!endingSong) songMisses++;
		totalPlayed++;
		RecalculateRating(true);

		// play character anims
		var char:Character = boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			var suffix:String = '';
			if(note != null) suffix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + suffix;
			char.playAnim(animToPlay, true);

			if(char != gf && lastCombo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}
		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void
	{
		var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHitPre', [note]);

		if (songName != 'tutorial' && songName != 'lore-ar')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
					altAnim = '-alt';

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + altAnim;
			if(note.gfNote) char = gf;
			else if (note.markNote) char = mark;
			else if (note.singWithMark) {
				mark.playAnim(animToPlay, true);
				mark.holdTimer = 0;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (ClientPrefs.data.characterGhost)
		{
			if (dad.ghostData.strumTime == note.strumTime && !note.isSustainNote) createGhost(dad);

			if (!note.isSustainNote) {
				dad.ghostData.strumTime = note.strumTime;
				updateGData(dad);
			}
		}

		if (ClientPrefs.data.lowQuality && SONG.song.toLowerCase() == 'repugnant')
		{
			if (note.noteType == 'Matpat Talking') {
				dad.animation.play(singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))], true);
				dad.holdTimer = 0;
			} else {
				var matpat:FlxSprite = states.stages.addons.Repugnant.matpat;
				matpat.scale.set(matpat.scale.x + 0.1, matpat.scale.y + 0.1);
			}
		}

		if(opponentVocals.length <= 0) vocals.volume = 0.85;
		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		note.hitByOpponent = true;
		
		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		if (!note.isSustainNote) invalidateNote(note);
	}

	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && note.ignoreNote) return;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHitPre', [note]);

		note.wasGoodHit = true;

		if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), ClientPrefs.data.hitsoundVolume);

		if(note.hitCausesMiss) {
			if(!note.noMissAnimation) {
				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animOffsets.exists('hurt')) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
			}

			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote) spawnNoteSplashOnNote(note);
			if(!note.isSustainNote) invalidateNote(note);
			return;
		}

		if(!note.noAnimation) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];

			var char:Character = boyfriend;
			var animCheck:String = 'hey';
			if(note.gfNote)
			{
				char = gf;
				animCheck = 'cheer';
			}

			if(note.markNote)
			{
				char = mark;
				animCheck = 'singUP';
			}

			if (note.singWithMark)
			{
				mark.playAnim(animToPlay + note.animSuffix, true);
				mark.holdTimer = 0;
			}

			if(char != null)
			{
				char.playAnim(animToPlay + note.animSuffix, true);
				char.holdTimer = 0;

				if(note.noteType == 'Hey!') {
					if(char.animOffsets.exists(animCheck)) {
						char.playAnim(animCheck, true);
						char.specialAnim = true;
						char.heyTimer = 0.6;
					}
				}
			}
		}

		if(!cpuControlled)
		{
			var spr = playerStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true);
		}
		else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		vocals.volume = 0.85;

		if (!note.isSustainNote)
		{
			combo++;
			if(combo > 9999) combo = 9999;
			popUpScore(note);
		}
		var gainHealth:Bool = true; // prevent health gain, *if* sustains are treated as a singular note
		if (guitarHeroSustains && note.isSustainNote) gainHealth = false;
		if (gainHealth) health += note.hitHealth * healthGain;

		if (boyfriend.curCharacter.startsWith('playguy'))
		{
			if (!note.gfNote) {
				if (eventTweensManager.exists('raise')) eventTweensManager.get('raise').cancel();
				boyfriend.y = boyfriend.defaultY;
				if (boyfriend.curCharacter.contains('staring')) boyfriend.x = boyfriend.defaultX;
				boyfriend.flipX = true;
			}
		}

		if (SONG.song.toLowerCase() == 'lore-apology' && leType == 'GF Sing' && SONG.notes[curSection].gfSection && SONG.notes[curSection].mustHitSection)
		{
			if (eventTweensManager.exists('raise')) eventTweensManager.get('raise').cancel();
			boyfriend.y = boyfriend.defaultY;
			if (boyfriend.curCharacter.contains('staring')) boyfriend.x = boyfriend.defaultX;
			boyfriend.flipX = true;
			boyfriend.animation.play(singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, leData)))], true, false, 0);
			boyfriend.holdTimer = 0;
		}

		if (ClientPrefs.data.characterGhost)
		{
			if (boyfriend.ghostData.strumTime == note.strumTime && !isSus) createGhost(boyfriend);
			if (gf != null && gf.ghostData.strumTime == note.strumTime && !isSus && (leType == 'GF Sing' || SONG.notes[curSection].gfSection)) createGhost(gf);
	
			if (!isSus)
			{
				if (gf != null && (SONG.notes[curSection].gfSection || leType == 'GF Sing')) {
					gf.ghostData.strumTime = note.strumTime;
					updateGData(gf);
				} else {
					boyfriend.ghostData.strumTime = note.strumTime;
					updateGData(boyfriend);
				}
			}
		}

		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHit', [note]);

		if(!note.isSustainNote) invalidateNote(note);
	}

	public function updateGData(char:Character)
	{
		char.ghostData.frameName = char.animation.frameName;
		char.ghostData.offsetX = char.offset.x;
		char.ghostData.offsetY = char.offset.y;
	}

	public function createGhost(char:Character)
	{
		if (char.visible) 
		{
			var ghost:FlxSprite = new FlxSprite(char.x, char.y);
			ghost.frames = Paths.getSparrowAtlas(char.imageFile);
			ghost.cameras = char.cameras;
			ghost.scale.set(char.scale.x, char.scale.y);
			ghost.scrollFactor.set(ghost.scrollFactor.x, ghost.scrollFactor.y);
			ghost.antialiasing = !char.noAntialiasing;
			ghost.flipX = char.flipX;
			ghost.color = char.color; //For Detective
			ghost.alpha = char.alpha;
			FlxTween.tween(ghost, {alpha: 0}, 0.4, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
				ghost.destroy();
			}});
			ghost.animation.frameName = char.ghostData.frameName;
			ghost.offset.x = char.ghostData.offsetX;
			ghost.offset.y = char.ghostData.offsetY;
	
			if (!char.isPlayer) {
				if (char.curCharacter.toLowerCase().contains('phone') || char.curCharacter.toLowerCase().contains('gf'))
					addBehindGF(ghost);
				else
					addBehindDad(ghost);
			} else {
				addBehindBF(ghost);
			}
		}
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				script.call('onDestroy');
				script.destroy();
			}

		while (hscriptArray.length > 0)
			hscriptArray.pop();
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.animationTimeScale = 1;
		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		Note.globalRgbShaders = [];
		backend.NoteTypesConfig.clearNoteTypesData();
		instance = null;
		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		if (SONG.needsVoices && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset)
		{
			var timeSub:Float = Conductor.songPosition - Conductor.offset;
			var syncTime:Float = 20 * playbackRate;
			if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime ||
			(vocals.length > 0 && Math.abs(vocals.time - timeSub) > syncTime) ||
			(opponentVocals.length > 0 && Math.abs(opponentVocals.time - timeSub) > syncTime))
			{
				resyncVocals();
			}
		}

		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		if (ClientPrefs.data.lorayWatermark && curStep == creditsStep) showCredits();

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');

		if (boyfriend.curCharacter.startsWith('playguy') && !boyfriend.curCharacter.contains('mad'))
		{
			if (healthBar.percent < 20 && curStep % 2 == 0)
			{
				boyfriend.flipped = !boyfriend.flipped;
				iconP1.flipX = boyfriend.flipped;
			}
			if (curStep % 4 == 0 && boyfriend.animation.curAnim.name == 'idle' && !boyfriend.stunned)
			{
				boyfriend.flippedIdle = !boyfriend.flippedIdle;
				boyfriend.flipX = boyfriend.flippedIdle;
				if (boyfriend.curCharacter.contains('staring')) boyfriend.x = (boyfriend.flipX ? boyfriend.defaultX + 32 : boyfriend.defaultX - 32);
				boyfriend.y = boyfriend.defaultY; //Just to be sure...
				boyfriend.animation.play('idle', true, false, 0);
				boyfriend.y -= 20;
				eventTweensManager.set('raise', eventTweens.tween(boyfriend, {y: boyfriend.y + 20}, 0.15, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
					eventTweensManager.remove('raise');
				}}));
			}
		}

		switch (SONG.song.toLowerCase()) //Oh boi...
		{
			case 'lored':
				switch (curStep) {
					case 1537:
						eventTweensManager.set("byehud", eventTweens.tween(camHUD, {alpha: 0}, 0.6, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove("byehud");
						}}));
					
					case 1664:
						cameraSpeed = 100;

					case 1672, 1688, 1704, 1720, 1736, 1752, 1768:
						defaultCamZoom += 0.05;
						camGame.zoom += 0.05;
					
					case 1776:
						defaultCamZoom = 0.9;
						cameraSpeed = 1;
						eventTweensManager.set("camzooooooooom", eventTweens.tween(camGame, {zoom: 0.9}, 0.8, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove("camzooooooooom");
						}}));

					case 1782:
						eventTweensManager.set("hellohud", eventTweens.tween(camHUD, {alpha: 1}, 0.6, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove("hellohud");
						}}));
				}

			case 'lore-ryan':
				switch (curStep) {
					case 1538:
						eventTweensManager.set("camhudbye", eventTweens.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove("camhudbye");
						}}));
					
					case 1658:
						eventTweensManager.set("camhudhi", eventTweens.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove("camhudhi");
						}}));

					case 1776, 1777, 1778, 1779, 1780, 1786:
						gf.playAnim('singRIGHT', true);
					
					case 1784:
						gf.playAnim('singLEFT', true);

					case 1788, 1790, 1791:
						gf.playAnim('singUP', true);
				}
			
			case 'measure-up':
				switch (curStep) {
					case 128, 384, 640, 896, 1152, 1280, 1408, 1664, 1792, 2304, 2560:
						camGame.flash(FlxColor.WHITE, 1.2);
				
					case 240, 760, 1016, 1264, 2416, 2672:
						cameraSpeed = 1000;
						camGame.zoom = 1;
						defaultCamZoom = 1;
				
					case 256, 768:
						camGame.flash(FlxColor.WHITE, 1.2);
						cameraSpeed = 1.75;
						defaultCamZoom = 0.75;
				
					case 512, 1536, 2176:
						if (curStep == 512 || curStep == 2176) camGame.flash(FlxColor.WHITE, 1.2);
						if (curStep == 1536) {
							eventTweensManager.set("camGame", eventTweens.tween(camGame, { zoom: 1.1 }, Std.int((Conductor.crochet / 1000) * 32), { ease: FlxEase.sineInOut, onComplete: function(twn: FlxTween) {
								eventTweensManager.remove("camGame");
							} }));
						}
						defaultCamZoom = 0.85;
						cameraSpeed = 1000;
				
					case 1024:
						camGame.flash(FlxColor.WHITE, 1.2);
						cameraSpeed = 1.75;
						defaultCamZoom = 0.85;
				
					case 1660:
						camLock(true);
				
					case 1668:
						camLock();
						cameraSpeed = 1.75;
						camGame.zoom = 0.85;
						defaultCamZoom = 0.85;
				
					case 1904:
						camGame.zoom = 0.8;
						defaultCamZoom = 0.8;
						cameraSpeed = 1000;
				
					case 1920:
						camGame.flash(FlxColor.WHITE, 1.2);
						defaultCamZoom = 0.75;
						cameraSpeed = 1.75;
				
					case 2432, 2688:
						camGame.zoom = 0.85;
						defaultCamZoom = 0.85;
						cameraSpeed = 1000;
						if (curStep == 2688)
							camOther.flash(FlxColor.WHITE, 1.2);
						else
							camGame.flash(FlxColor.WHITE, 1.2);

					case 2696:
						camGame.visible = false;
						camHUD.visible = false;
				}

			case 'lore-tropical':
				switch(curStep)
				{
					case 2792:
						gf.y = -500;
						gf.visible = true;
						eventTweensManager.set('gfDrop', eventTweens.tween(gf, {y: 450}, 1, {ease:FlxEase.bounceOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove('gfDrop');
						}}));
					
					case 3872:
						camGame.visible = false;
						camHUD.visible = false;
				}
			
			case 'lore-sad':
				switch (curStep) {
					case 132:
						eventTweensManager.set("idkColorThingy", eventTweens.color(boyfriend, 0.01, boyfriend.color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							eventTweensManager.remove("idkColorThingy");
						}}));
						camLock(false);
					
					case 144:
						camLock();
					
					/*case 236,1516,2800:
						defaultCamZoom = 1.2;
					
					case 256,1536:
						camGame.flash(FlxColor.WHITE, 1.2);
						defaultCamZoom = 0.7;
					
					case 1024:
						defaultCamZoom = 1;
					
					case 368,512,1648:
						defaultCamZoom = 0.9;
					
					case 768:
						defaultCamZoom = 0.8;
				
					case 384,1664:
						defaultCamZoom = 0.7;
					
					case 1280,2560:
						cameraSpeed = 1000;
						defaultCamZoom = 0.9;
						camGame.flash(FlxColor.WHITE, 1.2);

					case 1920:
						cameraSpeed = 1000;
						defaultCamZoom = 1;
						camGame.flash(FlxColor.WHITE, 1.2);
				
					case 1344,1984,2624:
						cameraSpeed = 1;
					
					case 1792:
						camGame.flash(FlxColor.WHITE, 1.2);
						cameraSpeed = 1000;
						defaultCamZoom = 0.9;
						eventTweensManager.set('zoomInLmao', eventTweens.tween(camGame, {zoom: 1.3}, (Std.int(Conductor.crochet)/1000) * 32, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove('zoomInLmao');
						}}));

					case 2032:
						camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
						camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];*/
					
					case 2816:
						eventTweensManager.set("idkColorThingy", eventTweens.color(gf, 0.01, gf.color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							eventTweensManager.remove("idkColorThingy");
						}}));
						gf.visible = true;
					
					/*case 2688:
						camGame.flash(FlxColor.WHITE, 1.2);

					case 2816:
						defaultCamZoom = 0.7;
						camGame.zoom = 0.7;*/
					
					case 3840:
						eventTweensManager.set('finalAlphaIn', eventTweens.tween(camGame, {alpha: 0}, 2.5, {ease:FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove('finalAlphaIn');
						}}));
						eventTweensManager.set('finalZoomIn', eventTweens.tween(camGame, {zoom: 1.4}, 2.5, {ease:FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
							eventTweensManager.remove('finalZoomIn');
						}}));
				}

			case 'sunk':
				switch (curStep)
				{
					case 1:
						cameraSpeed = 0;		
					case 2292:
						if (sunkMark == 'Mark') markTransitionStart();
					case 2816:
						if (sunkMark == 'Mark') markTransitionEnd();
					case 3008:
						if (sunkMark == 'Mark') 
						{
							states.stages.Sunk.markBg.x = 0;
							states.stages.Sunk.markBgOverlay.x = 0;
							mark.x = -574;
							markTransitionAltStart();
						}
					case 3072:
						FlxTween.tween(states.stages.Sunk.end, {alpha: 1}, 2, {ease: FlxEase.quadIn});
				}
		}
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null)
		{
			iconP3.scale.set(1.2, 1.2);
			iconP3.updateHitbox();
		}

		characterBopper(curBeat);

		super.beatHit();
		lastBeatHit = curBeat;

		if (boyfriend.curCharacter.startsWith('playguy')) {
			if (healthBar.percent > 20) {
				boyfriend.flipped = !boyfriend.flipped;
				iconP1.flipX = boyfriend.flipped;
			}
		}

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.getAnimationName().startsWith('sing') && !gf.stunned)
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.getAnimationName().startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
			dad.dance();
		if (mark != null && beat % mark.danceEveryNumBeats == 0 && !mark.getAnimationName().startsWith('sing') && !mark.stunned)
			mark.dance();
	}

	public function playerDance():Void
	{
		var anim:String = boyfriend.getAnimationName();
		if(boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			boyfriend.dance();
	}

	var changeToGF:Null<Bool>;
	var changedIcons:Bool = false;
	var gfIsSinging:Bool = false;
	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();

		if (SONG.notes[curSection] != null && gf != null) { //If your still charting the song and didn't finish it all, The game would crash. Well, not anymore with this.
			var gfColor = FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]); //Remaking it if the character got changed mid-song
			if (!SONG.notes[curSection].gfSection)
			{
				if (!SONG.notes[curSection].mustHitSection) {
					timeBar.tweenBarColors(healthBar.leftBar.color, null, 0.4, 'sineOut');
					FlxTween.color(timeTxt, 0.4, timeTxt.color, healthBar.leftBar.color, {ease: FlxEase.sineOut});
				} else {
					timeBar.tweenBarColors(healthBar.rightBar.color, null, 0.4, 'sineOut');
					FlxTween.color(timeTxt, 0.4, timeTxt.color, healthBar.rightBar.color, {ease: FlxEase.sineOut});
				}
			} else {
				if (SONG.notes[curSection].mustHitSection) {
					timeBar.tweenBarColors(gfColor, null, 0.4, 'sineOut');
					FlxTween.color(timeTxt, 0.4, timeTxt.color, gfColor, {ease: FlxEase.sineOut});
				}
			}
	
			var dadColor = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
			var bfColor = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
			if (SONG.notes[curSection].gfSection) {
				if (!changeToGF) changeToGF = true;
			}
			else if (SONG.notes[curSection].gfIsSinging) {
				if (iconP1.visible) iconP1.visible = false;
				if (!iconP3.visible) iconP3.visible = true;
				if (!iconP3.flipX) iconP3.flipX = false;
				gfIsSinging = true;
				healthBar.tweenBarColors(dadColor, gfColor, 0.4, 'sineOut');
			} else if (!changeToGF) {
				healthBar.tweenBarColors(((healthBar.leftBar.color != dadColor) ? dadColor : null), ((healthBar.rightBar.color != bfColor) ? bfColor : null), 0.4, 'sineOut');
	
				if (changedIcons) {
					(!iconP1.visible ? iconP1 : iconP2).visible = true;
					changedIcons = false;
				}
				iconP3.visible = false;
	
				changeToGF = null;
			}
	
			if (changeToGF) {
				(!iconP1.visible ? iconP1 : iconP2).visible = true;
				changedIcons = true;
				(SONG.notes[curSection].mustHitSection ? iconP1 : iconP2).visible = false;
				if (!iconP3.visible) iconP3.visible = true;
				iconP3.flipX = SONG.notes[curSection].mustHitSection;

				healthBar.tweenBarColors((SONG.notes[curSection].mustHitSection ? dadColor : gfColor), (SONG.notes[curSection].mustHitSection ? gfColor : bfColor), 0.4, 'sineOut');
				
				changeToGF = false;
			}

			if (gfIsSinging && !SONG.notes[curSection].gfIsSinging)
			{
				iconP1.visible = true;
				gfIsSinging = false;
			}
		}

		#if ACHIEVEMENTS_ALLOWED
		//Lolbit Achievement Shit
		if (ClientPrefs.data.miscEvents > 0 && !skippedSong && !inLoreCutscene)
		{
			if (!lolBitState && FlxG.random.bool(lolBitLuck))
			{
				lolBitState = true;
				boyfriend.stunned = true;
				inputBuffer = '';
	
				lolBitWarning.visible = true;
				lolBitSound.volume = 0.75;
			}

			if (!bonnet.visible && (FlxG.random.bool(bonnetLuck)))
			{
				bonnet.visible = true;
				FlxG.sound.play(Paths.soundRandom('bonnet', 1, 2));
				FlxTween.tween(bonnet, {x: -bonnet.width}, 9, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
					bonnet.scale.set(1.1, 1.1);
					bonnet.updateHitbox();
					bonnet.setPosition(-50, -70);
					FlxG.sound.play(Paths.sound('bonnetJumpscare'), 0.6);
					bonnet.animation.play('jumpscare', true);
					new FlxTimer().start(FlxG.random.float(1.25, 1.8), function(tmr:FlxTimer) {
						bonnetSound.stop();
						health = 0;
						vocals.volume = 0;
						opponentVocals.volume = 0;
						FlxG.sound.music.volume = 0;
						doDeathCheck();
					});
				}});
				FlxG.mouse.visible = true;
			}

			if (!no1crate.visible && !bucketBob.visible && FlxG.random.bool(no1crateLuck)) {
				no1crate.visible = true;
				loadAndPlayWhisper();
			}

			if (!bucketBob.visible && !no1crate.visible && FlxG.random.bool(bucketBobLuck))
			{
				bucketBob.visible = true;
				boomNoise.play();
			}
		}
		#end

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			if(newScript.parsingException != null)
			{
				addTextToDebug('ERROR ON LOADING: ${newScript.parsingException.message}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
					{
						if (e != null)
						{
							var len:Int = e.message.indexOf('\n') + 1;
							if(len <= 0) len = e.message.length;
								addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, len)}', FlxColor.RED);
						}
					}

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize tea interp!!! ($file)');
				}
				else trace('initialized tea interp successfully: $file');
			}

		}
		catch(e)
		{
			var len:Int = e.message.indexOf('\n') + 1;
			if(len <= 0) len = e.message.length;
			addTextToDebug('ERROR - ' + e.message.substr(0, len), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;
		for(i in 0...len) {
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try {
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
					{
						var len:Int = e.message.indexOf('\n') + 1;
						if(len <= 0) len = e.message.length;
						addTextToDebug('ERROR (${callValue.calledFunction}) - ' + e.message.substr(0, len), FlxColor.RED);
					}
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}

					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			if(!instancesExclude.contains(variable))
				instancesExclude.push(variable);
			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	function starCheck(i:Int, cap:Int)
	{
		if (i < cap)
		{
			if (stars.members[i].color != 0xFFFCDD03)
			{
				stars.members[i].y -= 20;
				FlxTween.tween(stars.members[i], {y: stars.members[i].y + 20}, 0.25, {ease: FlxEase.sineOut});
			}
			stars.members[i].color = 0xFFFCDD03;
		}
		else
		{
			stars.members[i].color = 0xFFFFFFFF;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != LuaUtils.Function_Stop)
		{
			ratingName = '?';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				if(ratingPercent < 1)
					for (i in 0...ratingStuff.length-1)
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
	}

	function showCredits()
	{
		if (creditsJSON.skip) {
			loraySign.x = 0;
			lorayTxt.x = 95;
		} else {
			FlxTween.tween(loraySign, {x: 0}, Conductor.crochet / 300, {ease: FlxEase.bounceOut});
			FlxTween.tween(lorayTxt, {x: 95}, Conductor.crochet / 300, {ease: FlxEase.bounceOut});
		}

		FlxG.mouse.visible = true;

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			FlxG.mouse.visible = false;
			FlxTween.tween(lorayTxt, {x: (-lorayTxt.width + 95)}, Conductor.crochet / 250, {ease: FlxEase.quadIn});
			FlxTween.tween(loraySign, {x: -loraySign.width}, Conductor.crochet / 250, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween)
				{
					loraySign.kill();
					lorayTxt.kill();
				}
			});
		});
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null)
	{
		if(chartingMode) return;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));
		if(cpuControlled) return;

		for (name in achievesToCheck) {
			if(!Achievements.exists(name)) continue;

			var unlock:Bool = false;
			switch(name)
			{
				case 'frame_by_frame':
					unlock = (ClientPrefs.data.framerate < 30 && !usedPractice);
				case 'lore_enjoyer':
					if (!usedPractice && isCover && !ClientPrefs.data.songPlayed.get('Covers').contains(SONG.song))
						ClientPrefs.data.songPlayed.get('Covers').push(SONG.song);
					unlock = (ClientPrefs.data.songPlayed.get('Covers').length >= 10);
				case 'ourple_lover':
					if (!usedPractice && ClientPrefs.data.guy != 'Ourple' && !ClientPrefs.data.ourpleUsed.contains(ClientPrefs.data.guy))
						ClientPrefs.data.ourpleUsed.push(ClientPrefs.data.guy);
					unlock = (ClientPrefs.data.ourpleUsed.length >= 5);
				case 'true_theorist':
					if (!usedPractice && !isCover && !ClientPrefs.data.songPlayed.get('Originals').contains(SONG.song))
						ClientPrefs.data.songPlayed.get('Originals').push(SONG.song);
					unlock = (Achievements.isUnlocked('lore_enjoyer') && ClientPrefs.data.songPlayed.get('Originals').length >= 2 && Achievements.isUnlocked('ourple_lover'));
			}

			if(unlock) Achievements.unlock(name);
		}
		ClientPrefs.saveSettings(false);
	}

	function closeLolBitState(unlock:Bool = true)
	{
		boyfriend.stunned = false;
		lolBitWarning.visible = false;
		lolBitSound.volume = 0;
		if (unlock) Achievements.unlock('lolbit');
		inputBuffer = "";
		lolBitState = false;
	}
	#end

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
			#else
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
			#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
	#end

	public function camLock(isDad:Null<Bool> = null)
	{
		if (isDad != null) {
			moveCamera(isDad);
			var xPos:Float = camFollow.x;
			var yPos:Float = camFollow.y;
			triggerEvent('Camera Follow Pos', Std.string(xPos), Std.string(yPos), Conductor.songPosition);
		} else {
			triggerEvent('Camera Follow Pos', '', '', Conductor.songPosition);
		}
	}

	private function getMissText():String
	{
		if (ClientPrefs.data.guy != 'Ourple') {
			switch (ClientPrefs.data.guy)
			{
				case 'Vloo': return 'Pizzas Brunt: ';
				case 'Bloxxy': return 'Oof Sound Played: ';
				case 'Cool': return 'Not Cool Moves: ';
				case 'Hrey': return 'Inks Leaked: ';
				case 'Nuu': return 'Broken Engines: ';
				case 'Wink': return 'Freaky Winks: ';
				default: return 'Misses: ';
			}
		} else if (!boyfriend.curCharacter.toLowerCase().contains('playguy')) {
			switch (boyfriend.curCharacter.toLowerCase())
			{
				case 'lixian': return 'Notas Perdidas: ';
				case 'mark': return 'Small Brain Moments: ';
				default: return 'Misses: ';
			}
		} else {
			return 'Revived Kids: ';
		}
		return 'Misses: ';
	}

	function markTransitionStart()
	{
		for (i in 4...8) {
			FlxTween.tween(strumLineNotes.members[(i - 4) % strumLineNotes.length], {x: playerStrums.members[(i - 4)].x, y: (playerStrums.members[(i - 4)].y + 300)}, 0.75, {ease: FlxEase.quadInOut});
			FlxTween.tween(strumLineNotes.members[i % strumLineNotes.length], {x: opponentStrums.members[(i - 4)].x, y: opponentStrums.members[(i - 4)].y}, 0.75, {ease: FlxEase.quadInOut});
		}
		rotationAnim(1);
		FlxTween.tween(states.stages.Sunk.markBg, {y: 0}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(states.stages.Sunk.markBgOverlay, {y: 0}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(mark, {y: -429}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(timeBar, {x: timeBar.x - 326}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(timeTxt, {x: timeTxt.x - 326}, 0.75, {ease: FlxEase.bounceOut});
		boyfriend.animation.play('scared', false, false, 0);
		FlxTween.tween(boyfriend, {y: boyfriend.y + 950}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(boyfriend, {angle: -90}, 0.45, {ease: FlxEase.linear});
		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			boyfriend.visible = false;
		});
	}

	function markTransitionEnd()
	{
		for (i in 4...8) {
			FlxTween.tween(strumLineNotes.members[(i - 4) % strumLineNotes.length], {y: (playerStrums.members[(i - 4)].y), x: playerStrums.members[(i - 4)].x}, 0.75, {ease: FlxEase.quadInOut});
			FlxTween.tween(strumLineNotes.members[i % strumLineNotes.length], {x: opponentStrums.members[(i - 4)].x}, 0.75, {ease: FlxEase.quadInOut});
		}
		rotationAnim(-1);
		FlxTween.tween(states.stages.Sunk.markBg, {y: -550}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(states.stages.Sunk.markBgOverlay, {y: -550}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(mark, {y: -1241}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(timeBar, {x: timeBar.x + 326}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(timeTxt, {x: timeTxt.x + 326}, 0.75, {ease: FlxEase.bounceOut});
		boyfriend.animation.play('scared', false, false, 0);
		FlxTween.tween(boyfriend, {y: boyfriend.y - 950}, 0.75, {ease: FlxEase.bounceOut});
		boyfriend.angle = 0;
		boyfriend.visible = true;
	}

	function markTransitionAltStart() 
	{
		for (i in 0...4) FlxTween.tween(strumLineNotes.members[i % strumLineNotes.length], {y: 345}, 0.75, {ease: FlxEase.quadInOut});
		FlxTween.tween(states.stages.Sunk.markBg, {y: 0}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(states.stages.Sunk.markBgOverlay, {y: 0}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(mark, {y: -429}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(timeBar, {x: timeBar.x + 322}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(timeTxt, {x: timeTxt.x + 322}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(dad, {y: dad.y + 950}, 0.75, {ease: FlxEase.bounceOut});
		FlxTween.tween(dad, {angle: -90}, 0.45, {ease: FlxEase.linear});
	}

	function rotationAnim(mult:Float)
	{
		for (i in 0...8)
		{
			FlxTween.tween(strumLineNotes.members[i % strumLineNotes.length], {angle: (360 * mult)}, 0.75, {ease: FlxEase.sineOut, onComplete: function(tween:FlxTween) {
				strumLineNotes.members[i % strumLineNotes.length].angle = 0;
			}});
		}
	}
}