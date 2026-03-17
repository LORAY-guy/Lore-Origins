package states.stages;

class Lore extends BaseStage 
{
    public static var wall:BGSprite;
    public static var floor:BGSprite;
    public static var curtains:BGSprite;

    private var resolution:Float;

    override function create()
    {   
        wall = new BGSprite('lore/wall', 0, 0, 1, 1);
        add(wall);

        floor = new BGSprite('lore/floor', -155, 1000, 1, 1);
        floor.setGraphicSize(Std.int(floor.width * 1.1));
        floor.updateHitbox();
        add(floor);

        resolution = FlxG.width / 1280;

        super.create();
    }

    override function createPost()
    {
        if (ClientPrefs.data.lowQuality) {
            return;
        }

        // if (resolution != 1) {
        //     curtains = new BGSprite('lore/curtain', -180 * resolution, 80 * resolution, 1.2, 1.2);
        //     curtains.scale.set(resolution * 0.85, resolution * 0.85);
        //     curtains.updateHitbox();
        //     add(curtains);
        // } else {
        //     curtains = new BGSprite('lore/curtain', 0, 220, 1.2, 1.2);
        //     add(curtains);
        // }
        curtains = new BGSprite("lore/curtain", -300, 135, 1.2, 1.2);
        curtains.setGraphicSize(Std.int(curtains.width * 1.2));
        curtains.updateHitbox();
        add(curtains);
    }
}