package states;

class OutdatedState extends MusicBeatState
{
	var leftState:Bool = false;
	var warnText:FlxText;
	
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
			"WHAT! YOU HAVE THE WRONG LORE?!?   \n
			Your v" + MainMenuState.loreVersion + " is stinky now,\n
			c'mon, just download the v" + TitleState.updateVersion + " >:(\n
			\n
			Press ESCAPE to be a pussy.\n
			Thanks for playin' tho! :3",
			36);
		warnText.setFormat(Paths.font("ourple.ttf"), 36);
		warnText.screenCenter(Y);
		add(warnText);

		FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 1);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if(!leftState) {
			if (controls.ACCEPT_P || FlxG.mouse.justPressed) {
				leftState = true;
				CoolUtil.browserLoad("https://gamebanana.com/mods/476070");
			}
			else if(controls.BACK_P) {
				leftState = true;
			}

			if(leftState)
			{
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
