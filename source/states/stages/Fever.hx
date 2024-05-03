package states.stages;

class Fever extends BaseStage 
{
    var back:BGSprite;
    var stagefront:BGSprite;
    var curtains:BGSprite;
    var crowd:BGSprite;

    var blackstuff:FlxSprite;

    override function create() {
        back = new BGSprite('fever/stageback', -660, -400, 1, 1);
        back.setGraphicSize(Std.int(back.width * 1.1));
        back.updateHitbox();
        add(back);

        stagefront = new BGSprite('stagefront', -675, 520, 1, 1);
        stagefront.setGraphicSize(Std.int(stagefront.width * 1.1));
        stagefront.updateHitbox();
        add(stagefront);

        super.create();
    }

    override function createPost() 
    {
        if (!ClientPrefs.data.lowQuality) 
        {
            curtains = new BGSprite('fever/stagecurtains', -730, -480, 1, 1);
            curtains.setGraphicSize(Std.int(curtains.width * 1.1));
            curtains.updateHitbox();
            curtains.antialiasing = false;
            add(curtains);

            crowd = new BGSprite('fever/crowd', -645, 475, 1, 1);
            crowd.setGraphicSize(Std.int(crowd.width * 1.1));
            crowd.updateHitbox();
            add(crowd);
        }

        blackstuff = new FlxSprite().makeGraphic(2000, 2000, FlxColor.BLACK);
        blackstuff.scrollFactor.set(0, 0);
        blackstuff.screenCenter(XY);
        blackstuff.alpha = 0.5;
        add(blackstuff);

        super.createPost();
    }

    override function stepHit() {
        if (curStep == 768 || curStep == 2432)
            crowd.loadGraphic(Paths.image('fever/crowdrtx'));
        else if (curStep == 1280 || curStep == 2560)
            crowd.loadGraphic(Paths.image('fever/crowd'));
        
        super.stepHit();
    }
}