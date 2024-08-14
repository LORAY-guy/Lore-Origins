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
			add(markBg);
			markBg.cameras = [camHUD];
		}

		end = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFF000000);
		end.scrollFactor.set();
		add(end);
		end.cameras = [camOther];
		end.screenCenter(XY);
		end.alpha = 0;
	}

	override function createPost() {
		if (PlayState.sunkMark == 'Mark')
		{
			markBgOverlay = new BGSprite('office-overlay', 730, -350, 1, 1);
			markBgOverlay.scale.x = 0.55;
			markBgOverlay.scale.y = 0.45;
			markBgOverlay.updateHitbox();
			markBgOverlay.cameras = [camHUD];
			add(markBgOverlay);
		}
	}
}