package states;

import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var guy:FlxSprite;
	var arm:FlxSprite;

	var delay:Float = 0;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		guy = new FlxSprite(600).loadGraphic(Paths.image('warning/guy'));
		guy.y = FlxG.height + 200;
		add(guy);

		arm = new FlxSprite().loadGraphic(Paths.image('warning/arm'));
		arm.y = FlxG.height + 200;
		arm.angle = -1;
		arm.origin.set(580,700);
		add(arm);
		arm.x = guy.x - 500;

		FlxTween.tween(guy, {y: FlxG.height - guy.height + 100}, 0.65, {ease: FlxEase.bounceOut});
		FlxTween.tween(arm, {y: FlxG.height - arm.height + 100}, 0.65, {ease: FlxEase.bounceOut, onComplete: function (twn:FlxTween) {
			FlxTween.angle(arm, -1, 1, 6, {ease: FlxEase.sineInOut, type: PINGPONG});
		}});
		FlxG.camera.shake(0.003, 1.5);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK_P;
			if (controls.ACCEPT_P || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				if(!back) {
					delay = 0.5;
					ClientPrefs.data.flashing = false;
					arm.setGraphicSize(Std.int(arm.width * 1.05));
					FlxTween.tween(arm.scale, {x: 1, y: 1}, 0.4, {ease: FlxEase.sineOut});
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					new FlxTimer().start(1.5, function (tmr:FlxTimer) {
						MusicBeatState.switchState(new TitleState());
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					new FlxTimer().start(1, function (tmr:FlxTimer) {
						MusicBeatState.switchState(new TitleState());
					});
				}

				FlxTween.tween(guy, {y: FlxG.height + 200}, 0.8, {ease: FlxEase.bounceOut, startDelay: delay});
				FlxTween.tween(arm, {y: FlxG.height + 200}, 0.8, {ease: FlxEase.bounceOut, startDelay: delay});
			}
		}
		super.update(elapsed);
	}
}