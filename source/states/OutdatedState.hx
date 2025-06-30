package states;

class OutdatedState extends MusicBeatState
{
	var leftState:Bool = false;
	var warnText:FlxText;

	#if mobile
	var cancelButton:FlxSprite;
	var acceptButton:FlxSprite;
	#end

	override function create():Void
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Bro's fucked, he didn't update", null);
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var ourp = new FlxSprite().loadGraphic(Paths.image('ourp'));
		ourp.scale.set(2.5,2.5);
		ourp.updateHitbox();
		ourp.setPosition(FlxG.width-ourp.width - 100, (FlxG.height-ourp.height) / 2);
		add(ourp);

		warnText = new FlxText(25, 0, FlxG.width,
			"WHAT! YOU HAVE THE WRONG LORE?!? \n
			Your v" + MainMenuState.loreVersion + " is stinky now,\n
			c'mon, just download the v" + TitleState.updateVersion + " >:(\n
			\n
			Press ESCAPE to be a pussy.\n
			Thanks for playin' tho! :3",
			36);
		warnText.setFormat(Paths.font("ourple.ttf"), 36);
		warnText.screenCenter(Y);
		add(warnText);

		#if mobile
		cancelButton = new FlxSprite();
		cancelButton.frames = Paths.getSparrowAtlas('mobile/back');
		cancelButton.animation.addByPrefix('idle', 'idle', 12, true);
		cancelButton.animation.addByPrefix('pop', 'pop', 24, false);
		cancelButton.animation.addByPrefix('in', 'in', 24, false);
		cancelButton.animation.play('in');
		cancelButton.setGraphicSize(Std.int(cancelButton.width * 0.5));
		cancelButton.updateHitbox();
		cancelButton.antialiasing = false;
		cancelButton.x = (ClientPrefs.data.exitButtonX == 'Right' ? FlxG.width - cancelButton.width : 0);
		cancelButton.y = FlxG.height - cancelButton.height;
		cancelButton.scrollFactor.set();
		add(cancelButton);
		cancelButton.animation.finishCallback = function(name:String) {
			if (name == 'in')
				cancelButton.animation.play('idle');
		}

		acceptButton = new FlxSprite();
		acceptButton.frames = Paths.getSparrowAtlas('mobile/accept');
		acceptButton.animation.addByPrefix('idle', 'idle', 12, true);
		acceptButton.animation.addByPrefix('pop', 'pop', 24, false);
		acceptButton.animation.addByPrefix('in', 'in', 24, false);
		acceptButton.animation.play('in');
		acceptButton.setGraphicSize(Std.int(acceptButton.width * 0.5));
		acceptButton.updateHitbox();
		acceptButton.antialiasing = false;
		acceptButton.x = (ClientPrefs.data.exitButtonX == 'Right' ? 0 : FlxG.width - acceptButton.width);
		acceptButton.y = FlxG.height - acceptButton.height;
		acceptButton.scrollFactor.set();
		add(acceptButton);
		acceptButton.animation.finishCallback = function(name:String) {
			if (name == 'in')
				acceptButton.animation.play('idle');
		}
		#end

		FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 1);
		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if(!leftState) {
			#if mobile
			if (FlxG.mouse.justPressed) {
				if (acceptButton.overlapsPoint(FlxG.mouse.getPosition())) {
					acceptButton.animation.play('pop');
					leftState = true;
					CoolUtil.browserLoad("https://gamebanana.com/mods/476070");
				}
				else if (cancelButton.overlapsPoint(FlxG.mouse.getPosition())) {
					cancelButton.animation.play('pop');
					leftState = true;
				}
			}
			#else
			if (controls.ACCEPT_P || FlxG.mouse.justPressed) {
				leftState = true;
				CoolUtil.browserLoad("https://gamebanana.com/mods/476070");
			} else if (controls.BACK_P) {
				leftState = true;
			}
			#end

			if(leftState)
			{
				#if mobile
				cancelButton.animation.play('in', true, true);
				cancelButton.animation.finishCallback = function(name:String) {
					if (name == 'in')
						cancelButton.visible = false;
				}
				acceptButton.animation.play('in', true, true);
				acceptButton.animation.finishCallback = function(name:String) {
					if (name == 'in')
						acceptButton.visible = false;
				}
				#end
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new states.MainMenuState(true));
					}
				});
			}
		}
		super.update(elapsed);
	}
}