package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

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
        this.happy = true;
        cancelTween('idle' + this.ID);
        this.animation.play('happy', true, false, 0);
        this.x = this.originX - 45;
        this.y = 380;
        this.flipX = (this.ID % 2 == 0) ? false : true;
        new FlxTimer().start(0.7, function(tmr:FlxTimer)
        {
            this.happy = false;
            this.x = this.originX;
            this.y = originY;
            this.flipX = (this.ID % 2 == 0) ? false : true;
            this.dance();
        });
    }

    public function dance()
    {
        if (!this.happy)
        {
            this.animation.play('idle', false, false, 0);
            this.y = (this.y + 20);
            this.flipX = !this.flipX;
            tweensMap.set('idle' + this.ID, FlxTween.tween(this, {y: originY}, 0.15, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {tweensMap.remove('idle' + this.ID);}}));
        }
    }

    public function cancelTween(ID:String)
    {
        if (tweensMap.exists(ID)) tweensMap.get(ID).cancel();
        tweensMap.remove(ID);
    }
}