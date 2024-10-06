package states.credits;

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

	var subGroup:String;

	var exitButton:ExitButton;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Lore Credits", null);
		#end

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		Paths.clearUnusedMemory();

		subGroup = CreditsSubgroupState.subGroups[CreditsSubgroupState.curSubGroup];

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

		initCredits();
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.75;
		descBox.alpha = 0.75;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 36);
		descText.setFormat(Paths.font("ourple.ttf"), 36, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;

		exitButton = new ExitButton('creditsSubgroup');
		add(exitButton);

		changeSelection();
		super.create();

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
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(controls.ACCEPT_P || (usingMouse && canClick && FlxG.mouse.justPressed && (FlxG.mouse.overlaps(grpOptions) || FlxG.mouse.overlaps(iconArray)))) {
					if (creditsStuff[curSelected][0] == 'LORAY') {
						quitting = true;
						canClick = false;
						MusicBeatState.switchState(new LorayState());
					} else if (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)
						CoolUtil.browserLoad(creditsStuff[curSelected][3]);
				}

				if (controls.BACK_P)
				{
					if(colorTween != null)
						colorTween.cancel();
					FlxG.camera.zoom += 0.06;
					canClick = false;
					exitState(new CreditsSubgroupState(true));
					quitting = true;
				}
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
				if(item.targetY == 0) {
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(item.x - 70, lastX, lerpVal);
				} else {
					item.x = FlxMath.lerp(200 + -40 * Math.abs(item.targetY), item.x, lerpVal);
				}
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));

		super.update(elapsed);

		if (subGroup == 'Assets')
			iconArray.members[0].angle = FlxG.random.float(-5, 5);

		Conductor.songPosition = FlxG.sound.music.time;
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
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}

	function initCredits()
	{
		var defaultList:Array<Array<String>>;
		switch (subGroup)
		{
			case 'Lore Origins':
				defaultList = [
					['Lore Origins by'],
					['LORAY',				'loray',			'Lore man',										 'https://www.youtube.com/@LORAY_',		'00FF55'],
					[''],
					['Contributers'],
					['Serby', 				'serby', 			'Made ending custcene in \"I can, tho\"', 		 'https://x.com/SerbyAnimations',		'A848C6'],
					//Add Ech0 here
					['Whitey',				'whitey',			'Art',									 		 'https://x.com/Whitemungus',			'BBBBBB'],
					['Who',					'who',				'Made Lore Sad Mix art cover',					 'https://x.com/agustheartist',			'919191'],
					['Loopy',				'loopy',			'Made Skins banner art',						 'https://x.com/ExeWiglett',			'EB7A34'],
					['TimNail',				'tim',				'Playtesting',									 'https://x.com/FnfTimothy',			'BBBBBB'],
					//['bobz', 				'bobz', 			'Charted Lore AR mix',  	 'https://x.com/bobzforvever', 								'05F505'], They lowkey did basically nothing, I actually made ~90% of the chart
					['Ahloof',				'ahloof',			'Playtested \"I can, tho\"',					 'https://x.com/ahhhloof',			    '01FF8D'],
					['PinkyMichael',		'pinky',			'Helped with Distractible song / Playtested',	 'https://x.com/PinkyMichael76',		'FF63FF'],
				];
			case 'Composers':
				defaultList = [
					['OG Lore by'],
					['Kiwiquest',			'lex',				'Original composer of Lore/Lore D-Sides',					 'https://www.youtube.com/@kiwiquestlol','FF5102'],
					[''],
					['Lore Remixes by'],
					['RandoHorn',			'rando',			'Made Lore Ryan Mix',								 		 'https://x.com/RandoHorn',		'AAAAAA'],
					['PinkyMichael',		'pinky',			'Made Lore Apology Mix',								     'https://x.com/PinkyMichael76','FF63FF'],
					['RixFX',				'rix',				'Made Lore Awesomix Mix',								     'https://x.com/rixfx_',			'AAAAAA'],
					['KOSE',				'kose',				'Made Chronology, Detective',						 'https://www.youtube.com/@kosejumpscare','CC31C9'],
					['smily',				'smily',			'Made Chronology',								 		 	 'https://x.com/boi_smily',		'AAAAAA'],
					['EthanTheDoodler',		'ethan',			'Made Live',								 		 		 'https://x.com/D00dlerEthan',	'AAAAAA'],
					['Clas25',				'clas',				'Made Lore Horse Mix',								 		 'https://www.youtube.com/@clasytpmv',	'AAAAAA'],
					['Ahloof',				'ahloof',			'Made Detective',								 		 	 'https://x.com/ahhhloof',		'01FF8D'],
					['Fire_MF',				'fire',				'Made Measure Up',								 			 'https://www.youtube.com/@FireMarioFan','AAAAAA'],
					['maddiesmiles',		'maddie',			'Made Measure Up, Repugnant',								 'https://www.youtube.com/channel/UC4WF3mjcu68swFdK3541yuA',		'AAAAAA'],
					['ALDR',				'call',				'Made Action',									        	 'https://www.youtube.com/@Call_-_',	'38109E'],
					[''],
					['Lore Original Remixes by'],
					['LORAY',				'loray',			'Lore man',										 			 'https://www.youtube.com/@LORAY_',		'00FF55'],
					['TEC Again',			'TEC',				'Helped mixing AR Mix',							 			 'https://www.youtube.com/@TECAgain',	'1BFF00']
				];
			case 'Assets':
				defaultList = [
					['Most of the assets come from'],
					['Vs Ourple Guy',		'guy',				'95% of the visuals/sounds assets come from this mod, please consider playing it!', 'https://ourpleguy.neocities.org',							'A357AB'],
					//[''],
					//['Lua Sprites'],
					//['Nestoku',				'nestoku',			'Made the Lua Sprites (DarknessXM commisionned them)', 								'https://x.com/TheFeloxselUwU',								'222222'],
					[''],
					['Additional Assets come from'],
					['Scott Cawthon', 		'scott', 			'God himself at this point', 														'https://www.youtube.com/channel/UC2Xp5JeeO9sP6bhc-9yD1xA', '328BA8']
				];
			default: //Psych Engine & FNF team
				defaultList = [
					['Psych Engine Team'],
					['Shadow Mario',		'shadowmario',		'Main Programmer and Head of Psych Engine',					 'https://ko-fi.com/shadowmario',		'444444'],
					['Riveren',				'riveren',			'Main Artist/Animator of Psych Engine',						 'https://x.com/riverennn',				'14967B'],
					[''],
					['Former Engine Members'],
					['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',							 'https://twitter.com/bbsub3',			'3E813A'],
					['shubs',				'',					'Ex-Programmer of Psych Engine\nI don\'t support them.',	 '',									'A1A1A1'],
					[''],
					['Engine Contributors'],
					['CrowPlexus',			'crowplexus',		'Input System v3, Major Help and Other PRs',				 'https://x.com/crowplexus',			'A1A1A1'],
					['Keoiki',				'keoiki',			'Note Splash Animations and Latin Alphabet',				 'https://x.com/Keoiki_',				'D2D2D2'],
					['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform', 'https://x.com/gedehari',				'E1843A'],
					['EliteMasterEric',		'mastereric',		'Runtime Shaders support',									 'https://x.com/EliteMasterEric',		'FFBD40'],
					['PolybiusProxy',		'proxy',			'.MP4 Video Loader Library (hxCodec)',						 'https://x.com/polybiusproxy',			'DCD294'],
					['Tahir',				'tahir',			'Implementing & Maintaining SScript and Other PRs',			 'https://x.com/tahirk618',				'A04397'],
					['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',	 'https://x.com/flicky_i',				'9E29CF'],
					['KadeDev',				'kade',				'Fixed some issues on Chart Editor and Other PRs',			 'https://x.com/kade0912',				'64A250'],
					['superpowers04',		'superpowers04',	'LUA JIT Fork',												 'https://x.com/superpowers04',			'B957ED'],
					['CheemsAndFriends',	'face',	'Creator of FlxAnimate\n(Icon will be added later, merry christmas!)',	 'https://x.com/CheemsnFriendos',		'A1A1A1'],
					[''],
					["Funkin' Crew"],
					['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",						 'https://x.com/ninja_muffin99',		'CF2D2D'],
					['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",							 'https://x.com/PhantomArcade3K',		'FADC45'],
					['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",							 'https://x.com/evilsk8r',				'5ABD4B'],
					['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",							 'https://x.com/kawaisprite',			'378FC7']
				];
		}
		
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
	}

	var flippedIcon:Bool = false;
	override function stepHit()
	{
		super.stepHit();

		if (subGroup == 'Assets')
		{
			if (curStep % 2 == 0)
			{
				iconArray.members[0].flipX = flippedIcon;
				flippedIcon = !flippedIcon;
			}
		}
	}
}