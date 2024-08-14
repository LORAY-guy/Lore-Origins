package states;

import lime.app.Promise;
import lime.app.Future;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import backend.StageData;

import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	// Browsers will load create(), you can make your song load a custom directory there
	// If you're compiling to desktop (or something that doesn't use NO_PRELOAD_ALL), search for getNextState instead
	// I'd recommend doing it on both actually lol
	
	// TO DO: Make this easier
	
	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;

	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	var funkay:FlxSprite;
	var loadingText:FlxText;
    var dots:String = ".";

	var uselessTipsList:Array<String> = [
		"If you don\'t hit a note, you will miss!",
		"There is multiple songs named \'Lore\'!",
		"If you look at the songs in Freeplay, you will find Matpat!",
		"If you click the \'X\' in windowed mode, you close the mod!",
		"You can navigate the menu using the controls!",
		"You can change your settings in settings!",
		"If you have 0 HP, then you die!",
		"[Insert tip with obscure lore here]",
		"Look at the tip screen for more helpful tips!",
		"Hit notes to increase your combo!",
		"The song \'Lore\' contains the motif of the song \'Lore\'",
		"Hello Internet, welcome to the LOOOOOOOOOOOOOADING screen!",
		"Well, well, well...",
		"Skibidi dop dop dop yes yes",
		"I always come back...",
		"Don't you tell me how many calories I need, bitch!",
		"So.... many.... \"HUNGRY\" middle-aged women...",
		"I am the HUMAN CONDOM!",
		"If Internet Explorer is brave enough to ask to be your default browser, you can be brave enough to ask that girl out.",
		"If you set the bar low enough, you have nowhere to go but up.",
		"The meaning of life is to find your gift.\nThe purpose of life is to give that gift to others.",
		"Ohh, look at that thick layer of cream, I want that thickness inside my body...",
		"You do realize that lunch is the most important meal of the day...",
		"Hello everybody, my name is Matpat.",
		"WAS THAT THE LOADING OF 87?!!",
		"Oh, Hi! welcome to my schooooooool house...",
		"https://www.youtube.com/watch?v=dQw4w9WgXcQ",
		"Hi, I'm Baldi! Nice to meet ya. Fuck me in the ass and call me Patricia. Book's your game? Just shout my name. When you let me use my whip... So that's one book right? But you're all wrong! You haven't even let me use my thong. While I sing you this song, It goes \"Ding dong\". Like the door I open on you. Here\'s a tip, abandon ship. Or you're gonna see me campfire willy. Oh, oh Oh hi there! Welcome to my hooker palace. Oh, oh, oh hi there! Please don't leave, I have no friends. Oh, oh, oh hi there! Let's go camping, Let me touch ya. Oh, oh, oh hi there! Haha, I tied you up!",
		"According to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees don't care what humans think is impossible. Yellow, black. Yellow, black. Yellow, black. Yellow, black. Ooh, black and yellow! Let's shake it up a little.  Barry! Breakfast is ready! Ooming! Hang on a second. Hello? - Barry? - Adam? - Oan you believe this is happening? - I can't. I'll pick you up. Looking sharp. Use the stairs. Your father paid good money for those. Sorry. I'm excited." // Bee movie script
	];

	override function create()
	{
		funkay = new FlxSprite().loadGraphic(Paths.image('loading/whitey'));
		funkay.setGraphicSize(funkay.width * (1/6));
		funkay.updateHitbox();
		add(funkay);
		funkay.antialiasing = ClientPrefs.data.antialiasing;
		funkay.scrollFactor.set();
		funkay.screenCenter();

		loadingText = new FlxText(FlxG.width - 400, FlxG.height - 90, 720, "Loading", 76);
        loadingText.setFormat(Paths.font('matpat.ttf'), 76, 0x3fe730, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingText.borderSize = 4;
        add(loadingText);

		var uselessTip:FlxText = new FlxText(0, FlxG.height - 210, FlxG.width - (FlxG.width * (1/4)), '', 48);
		uselessTip.setFormat(Paths.font('matpat.ttf'), 48, 0x3fe730, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		var tip:String = uselessTipsList[FlxG.random.int(0, uselessTipsList.length)];

		if (tip == null)
			tip = Std.string(FlxG.random.int(0, 255)) + '.' + Std.string(FlxG.random.int(0, 255)) + '.' + Std.string(FlxG.random.int(0, 255)) + '.' + Std.string(FlxG.random.int(0, 255)); // fake IP address generator ;)
		else if (tip.length > 200)
			uselessTip.y = 0;

		uselessTip.text = 'TIP: ' + tip;
		uselessTip.screenCenter(X);
		uselessTip.borderSize = 4;
        add(uselessTip);

		var timer = new FlxTimer();
        timer.start(0.5, onTimerTick, 0);

		initSongsManifest().onComplete
		(
			function (lib)
			{
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				if(directory != null && directory.length > 0 && directory != 'shared') {
					checkLibrary('week_assets');
				}

				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
	}
	
	function checkLibrary(library:String) {
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw new haxe.Exception("Missing library: " + library);

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null) FlxG.sound.music.stop();
		
		FlxTransitionableState.skipNextTransOut = false;
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxG.camera.fade(FlxG.camera.bgColor, 0.5, false, function() MusicBeatState.switchState(target));
		});
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);

		var loaded:Bool = false;
		
		if (!loaded)
			return new LoadingState(target, stopMusic, directory);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}

	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}

	private function onTimerTick(timer:FlxTimer):Void {
        dots += ".";
        if (dots.length > 3) {
            dots = ".";
        }
        loadingText.text = "Loading" + dots;
    }
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}