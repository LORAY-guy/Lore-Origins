package states.credits;

import backend.ExitButton;
import objects.AttachedSprite;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:FlxTypedGroup<AttachedSprite>;
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Lore Credits", null);
		#end

		Paths.clearUnusedMemory();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		var verttabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/verttabox'), Y, 0, 0);
		verttabox1.scrollFactor.set(0, 0);
		verttabox1.velocity.set(0, 40);
		add(verttabox1);

		var verttabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/verttabox2'), Y, 0, 0);
		verttabox2.scrollFactor.set(0, 0);
		verttabox2.velocity.set(0, -40);
		verttabox2.x = 1195;
		add(verttabox2);
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		iconArray = new FlxTypedGroup<AttachedSprite>();
		add(iconArray);

		var defaultList:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			['Lore Origins by'],
			['LORAY',				'loray',			'He gonna lore uranus',										 'https://www.youtube.com/@LORAY_',		'00FF55'],
			[''],
			['Additional Lore Origins Help'],
			['Whitey',				'whitey',			'Art',									 					 'https://twitter.com/Whitemungus',		'BBBBBB'],
			[''],
			['OG Lore by'],
			['Kiwiquest',			'lex',				'Original composer of Lore',								 'https://www.youtube.com/@kiwiquestlol','FF5102'],
			[''],
			['Lore Remixes by'],
			['RandoHorn',			'rando',			'Made Lore Ryan Mix',								 		 'https://twitter.com/RandoHorn',		'AAAAAA'],
			['PinkyMichael',		'pinky',			'Made Lore Apology Mix',								     'https://www.youtube.com/@pinkymichael76','FF63FF'],
			['RixFX',				'rix',				'Made Lore Awesomix Mix',								     'https://twitter.com/rixfx_',			'AAAAAA'],
			['KOSE',				'kose',				'Made Fever, Chronology, Detective',						 'https://www.youtube.com/@kosejumpscare','CC31C9'],
			['smily',				'smily',			'Made Chronology',								 		 	 'https://twitter.com/boi_smily',		'AAAAAA'],
			['Ari the when',	    'ari',				'Made Lore Style Mix',								 		 'https://twitter.com/Ari_the_when',	'AAAAAA'],
			['EthanTheDoodler',		'ethan',			'Made Live',								 		 		 'https://twitter.com/D00dlerEthan',	'AAAAAA'],
			['Clas25',				'clas',				'Made Lore Horse Mix',								 		 'https://www.youtube.com/@clasytpmv',	'AAAAAA'],
			['Ahloof',				'ahloof',			'Made Detective',								 		 	 'https://twitter.com/ahhhloof',		'AAAAAA'],
			['Fire_MF',				'fire',				'Made Measure Up',								 			 'https://www.youtube.com/@FireMarioFan','AAAAAA'],
			['maddiesmiles',		'maddie',			'Made Measure Up, Repugnant',								 'https://www.youtube.com/channel/UC4WF3mjcu68swFdK3541yuA',		'AAAAAA'],
			['Call',				'call',				'Made Action',									        	 'https://www.youtube.com/@Call_-_',	'38109E'],
			[''],
			['Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer and Head of Psych Engine',					 'https://ko-fi.com/shadowmario',		'444444'],
			['Riveren',				'riveren',			'Main Artist/Animator of Psych Engine',						 'https://twitter.com/riverennn',		'14967B'],
			[''],
			['Former Engine Members'],
			['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',							 'https://twitter.com/bbsub3',			'3E813A'],
			['shubs',				'',					'Ex-Programmer of Psych Engine\nI don\'t support them.',	 '',									'A1A1A1'],
			[''],
			['Engine Contributors'],
			['CrowPlexus',			'crowplexus',		'Input System v3, Major Help and Other PRs',				 'https://twitter.com/crowplexus',		'A1A1A1'],
			['Keoiki',				'keoiki',			'Note Splash Animations and Latin Alphabet',				 'https://twitter.com/Keoiki_',			'D2D2D2'],
			['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform', 'https://twitter.com/gedehari',		'E1843A'],
			['EliteMasterEric',		'mastereric',		'Runtime Shaders support',									 'https://twitter.com/EliteMasterEric',	'FFBD40'],
			['PolybiusProxy',		'proxy',			'.MP4 Video Loader Library (hxCodec)',						 'https://twitter.com/polybiusproxy',	'DCD294'],
			['Tahir',				'tahir',			'Implementing & Maintaining SScript and Other PRs',			 'https://twitter.com/tahirk618',		'A04397'],
			['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',	 'https://twitter.com/flicky_i',		'9E29CF'],
			['KadeDev',				'kade',				'Fixed some issues on Chart Editor and Other PRs',			 'https://twitter.com/kade0912',		'64A250'],
			['superpowers04',		'superpowers04',	'LUA JIT Fork',												 'https://twitter.com/superpowers04',	'B957ED'],
			['CheemsAndFriends',	'face',	'Creator of FlxAnimate\n(Icon will be added later, merry christmas!)',	 'https://twitter.com/CheemsnFriendos',	'A1A1A1'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",						 'https://twitter.com/ninja_muffin99',	'CF2D2D'],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",							 'https://twitter.com/PhantomArcade3K',	'FADC45'],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",							 'https://twitter.com/evilsk8r',		'5ABD4B'],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",							 'https://twitter.com/kawaisprite',		'378FC7']
		];
		
		for(i in defaultList) {
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Mods.currentModDirectory = creditsStuff[i][5];
				}

				var str:String = 'credits/missing_icon';
				if(creditsStuff[i][1] != null && creditsStuff[i][1].length > 0)
				{
					var fileName = 'credits/' + creditsStuff[i][1];
					if (Paths.fileExists('images/$fileName.png', IMAGE)) str = fileName;
					else if (Paths.fileExists('images/$fileName-pixel.png', IMAGE)) str = fileName + '-pixel';
				}

				var icon:AttachedSprite = new AttachedSprite(str);
				if (str.contains('missing')) icon.visible = false;
				if (str.endsWith('-pixel')) icon.antialiasing = false;
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss? NUH UH
				iconArray.add(icon);
				Mods.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;

		add(new ExitButton());

		changeSelection();
		super.create();

		FlxG.camera.y = 720;
		FlxTween.tween(FlxG.camera, {y: 0}, 1.2, {ease: FlxEase.expoInOut});

		if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	public var usingMouse:Bool = false;
	public var canClick:Bool = true;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP || downP)
					usingMouse = false;
				else if (FlxG.mouse.overlaps(grpOptions) || FlxG.mouse.overlaps(iconArray))
					usingMouse = true;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (usingMouse && FlxG.mouse.wheel != 0) changeSelection(-FlxG.mouse.wheel * shiftMult);

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT || (usingMouse && canClick && FlxG.mouse.justPressed && (FlxG.mouse.overlaps(grpOptions) || FlxG.mouse.overlaps(iconArray)))) {
				if (creditsStuff[curSelected][0] == 'LORAY')
				{
					quitting = true;
					canClick = false;
					FlxG.camera.zoom += 0.06;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(FlxG.camera, {y: 720}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
						MusicBeatState.switchState(new LorayState());
					}});
				}
				else if (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)
					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.zoom += 0.06;
				FlxTween.tween(FlxG.camera, {y: 720}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
					MusicBeatState.switchState(new MainMenuState());
				}});
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(item.x - 70, lastX, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(200 + -40 * Math.abs(item.targetY), item.x, lerpVal);
				}
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));

		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		if (FlxG.camera.zoom <= 1.125) FlxG.camera.zoom += 0.03;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
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

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
