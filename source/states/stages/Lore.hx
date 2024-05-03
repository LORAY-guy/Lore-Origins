package states.stages;

class Lore extends BaseStage 
{
    public static var wall:BGSprite;
    public static var floor:BGSprite;
    public static var curtains:BGSprite;

    override function create()
    {   
        wall = new BGSprite('lore/wall', 0, 0, 1, 1);
        add(wall);

        floor = new BGSprite('lore/floor', 0, 1000, 1, 1);
        add(floor);

        super.create();
    }

    override function createPost()
    {
        if (!ClientPrefs.data.lowQuality) {
            curtains = new BGSprite('lore/curtain', 0, 220, 1.2, 1.2);
            add(curtains);
        }
    }
}