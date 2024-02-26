package options;

import states.MainMenuState;
import backend.StageData;

import flixel.addons.display.FlxBackdrop;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<FlxText>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	public static var spikes:FlxSpriteGroup; 

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg = new FlxSprite().loadGraphic(Paths.image('options/bg'));
		bg.setGraphicSize(1280);
		bg.updateHitbox();
		add(bg);

		var guy = new FlxSprite();
		guy.frames = Paths.getSparrowAtlas('options/guy');
		guy.animation.addByPrefix('s','guy g',8);
		guy.animation.play('s');
		guy.y = FlxG.height - guy.height;
		add(guy);

		spikes = new FlxSpriteGroup();

		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = FlxG.height - lettabox1.height;
		spikes.add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		spikes.add(lettabox2);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		add(spikes);

		for (i in 0...options.length)
		{
			var optionstxt = new FlxText(650,0,0,options[i]);
			optionstxt.setFormat(Paths.font("options.ttf"), 40, FlxColor.WHITE, CENTER,FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionstxt.screenCenter(Y);
			optionstxt.y += (60 * (i - (options.length / 2))) + 50;
			optionstxt.ID = i;
			grpOptions.add(optionstxt);
		}

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		for (i in grpOptions) {
			i.alpha = 0.8;
			i.color = FlxColor.WHITE;
			i.borderColor = FlxColor.BLACK;
			if (i.ID == curSelected){
				i.alpha = 1;
				i.color = 0xFFA04EBA;
				i.borderColor = 0xFFFFFFFF;
			} 
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}