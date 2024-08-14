package flixel.system;

import flixel.FlxState;

class FlxSplash extends FlxState
{
	public static var nextState:Class<FlxState>;

	/**
	 * @since 4.8.0
	 */
	public static var muted:Bool = #if html5 true #else false #end;

	var _text:FlxText;
    var _bg:FlxSprite;
    var _gtlogo:FlxSprite;
    var _graphic:FlxSprite;

	var _times:Array<Float>;
	var _colors:Array<Int>;
	var _curPart:Int = 0;
	var _cachedTimestep:Bool;
	var _cachedAutoPause:Bool;

	override public function create():Void
	{
		// This is required for sound and animation to synch up properly
		_cachedTimestep = FlxG.fixedTimestep;
		FlxG.fixedTimestep = false;

		_cachedAutoPause = FlxG.autoPause;
		FlxG.autoPause = false;

		#if FLX_KEYBOARD
		FlxG.keys.enabled = false;
		#end

		_times = [0.25, 0.50, 0.62, 0.87];
		_colors = [0xfe0000, 0xffff00, 0x00c6fa, 0x00e41f];

		for (time in _times)
			new FlxTimer().start(time, timerCallback);

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

        _bg = new FlxSprite().loadGraphic(Paths.image('gtbg'));
        _bg.setGraphicSize(stageWidth, stageHeight);
        _bg.screenCenter(XY);
        add(_bg);

        _gtlogo = new FlxSprite().loadGraphic(Paths.image('gtLogo'));
        _gtlogo.scale.set(0.25, 0.25);
        _gtlogo.updateHitbox();
        _gtlogo.screenCenter(XY);
        _gtlogo.y -= 40;
        add(_gtlogo);

		_text = new FlxText(0, 0, 550, "LORE ORIGINS");
        _text.setFormat(Paths.font('matpat.ttf'), 72, 0x00e41f, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        _text.borderSize = 2.5;
		_text.bold = true;
        _text.screenCenter(XY);
        _text.y += 187;
		add(_text);

        _graphic = new FlxSprite().makeGraphic(stageWidth, stageHeight, FlxColor.BLACK);
        _graphic.screenCenter(XY);
        _graphic.alpha = 0;
        add(_graphic);

		if (!muted) FlxG.sound.load(Paths.music('splash'), 0.5).play();
	}

	override public function destroy():Void
	{
		_text = null;
		_times = null;
		_colors = null;
        _bg = null;
        _gtlogo = null;
        _graphic = null;

		super.destroy();
	}

	function timerCallback(Timer:FlxTimer):Void
	{
		_text.color = _colors[_curPart];
		_curPart++;

		if (_curPart == 4)
            FlxTween.tween(_graphic, {alpha: 1}, 3.0, {ease: FlxEase.quadOut, onComplete: onComplete});
	}

	function onComplete(Tween:FlxTween):Void
	{
		FlxG.fixedTimestep = _cachedTimestep;
		FlxG.autoPause = _cachedAutoPause;
		#if FLX_KEYBOARD
		FlxG.keys.enabled = true;
		#end
		FlxG.switchState(Type.createInstance(nextState, []));
	}
}