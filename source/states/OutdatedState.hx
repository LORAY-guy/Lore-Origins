package states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	var warnText:FlxText;
	
	override function create()
	{
		super.create();

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
		warnText.antialiasing = false;
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT || FlxG.mouse.justPressed) {
				leftState = true;
				CoolUtil.browserLoad("https://gamebanana.com/mods/476070");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new states.MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
