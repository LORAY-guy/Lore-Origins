package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	public var isCool:Bool = true;

	public function new(char:String = 'guy', isPlayer:Bool = false, ?allowGPU:Bool = true, ?isCool:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		this.isCool = isCool;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			if (width == 450)
			{
				this.isCool = true;
				loadGraphic(file, true, Math.floor(width / 3), Math.floor(height)); //Then load it fr
				iconOffsets[0] = (width - 150) / 3;
				iconOffsets[1] = (width - 150) / 3;
				iconOffsets[2] = (width - 150) / 3;
				updateHitbox();
				animation.add(char, [0, 1, 2], 0, false, isPlayer);
			} else {
				this.isCool = false;
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();
				animation.add(char, [0, 1], 0, false, isPlayer);
			}
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.data.antialiasing;
			if (char.endsWith('-pixel') || char.startsWith('guy')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
