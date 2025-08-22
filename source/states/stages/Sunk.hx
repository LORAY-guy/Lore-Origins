package states.stages;

class Sunk extends BaseStage
{
	public static var bg:BGSprite;
	public static var end:FlxSprite;
	public static var markBg:BGSprite;
	public static var markBgOverlay:BGSprite;

	override function create()
	{
		bg = new BGSprite('sinking', -750, -470, 1, 1);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		add(bg);

		if (PlayState.sunkMark == 'Mark')
		{
			markBg = new BGSprite('office', 730, -350, 1, 1);
			markBg.flipX = true;
			markBg.scale.x = 0.55;
			markBg.scale.y = 0.45;
			markBg.updateHitbox();
			markBg.x = FlxG.width - markBg.width;
			markBg.cameras = [camHUD];
			add(markBg);
		}

		end = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		end.scrollFactor.set();
		add(end);
		end.cameras = [camOther];
		end.screenCenter(XY);
		end.alpha = 0;
	}

	override function createPost()
	{
		super.createPost();

		if (PlayState.sunkMark == 'Mark')
		{
			markBgOverlay = new BGSprite('office-overlay', 730, -350, 1, 1);
			markBgOverlay.scale.x = 0.55;
			markBgOverlay.scale.y = 0.45;
			markBgOverlay.updateHitbox();
			markBgOverlay.cameras = [camHUD];
			markBgOverlay.x = FlxG.width - markBgOverlay.width;
			add(markBgOverlay);
		}

		cameraSpeed = 100;
		isCameraOnForcedPos = true;
		camFollow.x = 197.5;
		camFollow.y = 171;
	}

	override public function songStart():Void
	{
		super.songStart();

		cameraSpeed = 0;
	}
}