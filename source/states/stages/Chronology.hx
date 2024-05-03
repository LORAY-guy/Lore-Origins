package states.stages;

class Chronology extends BaseStage 
{
    var back:FlxSprite;
    var fredi:FlxSprite;

    override function create() 
    {
        back = new FlxSprite(-1075, -510).loadGraphic(Paths.image('chrono/sky'));
        back.scale.set(3, 3);
        back.updateHitbox();
        back.antialiasing = false;
        add(back);

        fredi = new FlxSprite(-1200, -510).loadGraphic(Paths.image('chrono/fredi'));
        fredi.scale.set(1.5, 1.5);
        fredi.updateHitbox();
        fredi.antialiasing = false;
        add(fredi);
        
        super.create();
    }
}