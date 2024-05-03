package options;

class LoreOriginsSubstate extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Lore Origins Settings';

		if (!OptionsState.onPlayState)
		{
			var option:OurpleOption = new OurpleOption('Guy :',
			"Select and play as your favorite Guy! (WIP)",
			'guy',
			'string',
			['Ourple', 'Vloo']);
			option.onChange = onChangeCursor;
			addOption(option);
		}

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

		var option:OurpleOption = new OurpleOption('Hide Old Covers', //Name
		'If checked, the covers considered old will be hidden from the freeplay menu.', //Description
		'hideOldCovers', //Save data variable name
		'bool'); //Variable type
		addOption(option);

		var option:OurpleOption = new OurpleOption('Exit Button Position:',
		"On what side of the screen should the Exit Button be located?",
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
			if (ClientPrefs.data.exitButtonX == 'Right')
				FlxTween.tween(exitButton, {x: FlxG.width - exitButton.width}, 1, {ease: FlxEase.bounceOut});
			else
				FlxTween.tween(exitButton, {x: 0}, 1, {ease: FlxEase.bounceOut});
		} else {
			exitButton.x = (ClientPrefs.data.exitButtonX == 'Right' ? FlxG.width - exitButton.width : 0);
		}
		options.OptionsState.exitButton.x = (ClientPrefs.data.exitButtonX == 'Right' ? FlxG.width - options.OptionsState.exitButton.width : 0);
	}

	function onChangeCursor()
	{
		var curGuy:String = ClientPrefs.data.guy.toLowerCase();
		FlxG.mouse.load('assets/shared/images/cursors/$curGuy-cursor.png', 1, -8, -7);
	}
}