package options;

class LoreOriginsSubstate extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Lore Origins Settings';

		var option:OurpleOption = new OurpleOption('LORAY Watermark', //Name
		'If unchecked, the LORAY credit at the beginning of every song will be disabled.', //Description
		'lorayWatermark', //Save data variable name
		'bool'); //Variable type
		addOption(option);

		var option:OurpleOption = new OurpleOption('Character Ghost', //Name
		'If checked, every character will create a ghost if multiple animations are played at the same time.', //Description
		'characterGhost', //Save data variable name
		'bool'); //Variable type
		addOption(option);

		var option:OurpleOption = new OurpleOption('Misc. Events Mult.', //Name
		'Multiplier of how random events may occur during a game (used for Achievements). Set to 0 to disable.', //Description
		'miscEvents', //Save data variable name
		'float'); //Variable type
		addOption(option);

		option.minValue = 0.0;
		option.maxValue = 3.0;
		option.changeValue = 0.5;
		option.displayFormat = '%vx';

		var option:OurpleOption = new OurpleOption('Hide Old Covers', //Name
		'If checked, the covers considered old will be hidden from the freeplay menu.', //Description
		'hideOldCovers', //Save data variable name
		'bool'); //Variable type
		addOption(option);

		var option:OurpleOption = new OurpleOption('Exit Button Position:',
		'On what side of the screen should the Exit Button be located?',
		'exitButtonX',
		'string',
		['Left', 'Right']);
		option.onChange = onChangeExitButton;
		addOption(option);

		super();
	}

    function onChangeExitButton()
    {
		if (exitButton.visible) {
			FlxTween.tween(exitButton, {x: (ClientPrefs.data.exitButtonX == 'Right' ? FlxG.width - exitButton.width : 0)}, 1, {ease: FlxEase.bounceOut});
		} else {
			exitButton.x = (ClientPrefs.data.exitButtonX == 'Right' ? FlxG.width - exitButton.width : 0);
		}
		options.OptionsState.exitButton.x = (ClientPrefs.data.exitButtonX == 'Right' ? FlxG.width - options.OptionsState.exitButton.width : 0);
	}
}