package states.credits;

class Loray extends FlxSprite 
{
    public static var lorays:Array<Loray> = [];
	public static var tweensMap:Map<String, FlxTween> = new Map<String, FlxTween>();

    public var happy:Bool = false;
    public var originX:Float = 0;
    public var originY:Float = 460;

    public function new(x:Float = 0)
    {
        super(x, originY);
        
        frames = Paths.getSparrowAtlas('loray/OURPLE_LORAAAAAAAAAAY');
        animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        animation.addByPrefix('happy', 'Up', 24, false, false, false);
        animation.play('idle', false, false, 0);
        scale.x = 3;
        scale.y = 3;
        antialiasing = false;
        ID = lorays.length;
        flipX = (ID % 2 == 0) ? true : false;
        lorays.push(this);

        this.originX = x;
    }

    public function beHappy() 
    {
        happy = true;
        cancelTween('idle' + ID);
        animation.play('happy', true, false, 0);
        x = originX - 45;
        y = 380;
        flipX = (ID % 2 == 0) ? false : true;
        new FlxTimer().start(0.7, function(tmr:FlxTimer)
        {
            happy = false;
            x = originX;
            y = originY;
            flipX = (ID % 2 == 0) ? false : true;
            dance();
        });
    }

    public function dance()
    {
        if (!happy)
        {
            animation.play('idle', true, false, 0);
            y = (y + 20);
            flipX = !flipX;
            tweensMap.set('idle' + ID, FlxTween.tween(this, {y: originY}, 0.15, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {tweensMap.remove('idle' + ID);}}));
        }
    }

    public function cancelTween(ID:String)
    {
        if (tweensMap.exists(ID)) tweensMap.get(ID).cancel();
        tweensMap.remove(ID);
    }
}