package states;

import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	private var guy:FlxSprite;
	private var arm:FlxSprite;

	#if mobile
	private var cancelButton:FlxSprite;
	private var acceptButton:FlxSprite;
	#end

	private var delay:Float = 0;

	override public function create():Void
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		guy = new FlxSprite().loadGraphic(Paths.image('warning/guy'));
		guy.x = FlxG.width / 2;
		guy.x -= 40 * (FlxG.width / 1280);
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
		acceptButton.scrollFactor.set();
		add(acceptButton);
		acceptButton.animation.finishCallback = function(name:String) {
			if (name == 'in')
				acceptButton.animation.play('idle');
		}
		#end

		super.create();
	}

	private function handleAccept(back:Bool):Void
	{
		leftState = true;
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

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
		
		if (!back) {
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

	override public function update(elapsed:Float):Void
	{
		if(!leftState) {
			#if mobile
			if (FlxG.mouse.justPressed) {
				if (acceptButton.overlapsPoint(FlxG.mouse.getPosition())) {
					acceptButton.animation.play('pop');
					handleAccept(false);
				}
				else if (cancelButton.overlapsPoint(FlxG.mouse.getPosition())) {
					cancelButton.animation.play('pop');
					handleAccept(true);
				}
			}
			#else
			var back:Bool = controls.BACK_P;
			if (controls.ACCEPT_P || back)
				handleAccept(back);
			#end
		}
		
		super.update(elapsed);
	}
}