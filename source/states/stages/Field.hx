package states.stages;

class Field extends BaseStage
{
    //why am i wasting my time doing this... AGAIN??
    var obj1:BGSprite;
    var obj2:BGSprite;
    var obj3:BGSprite;

    var stool:BGSprite;
    var phone:BGSprite;
    var horsePhone:FlxSprite;

    var horses:FlxTypedGroup<BGSprite>;
    var horseAmount:Int = 0;
    var horsePositions:Array<Float> = [];

    var x_values:Array<Float> = [];
    var y_values:Array<Float> = [];

    var luck:Float = 0.2;
    var phoneFollow:Bool = true;

    override function create()
    {
        obj1 = new BGSprite('field', -920, -787, 1, 1);
        obj1.setGraphicSize(Std.int(obj1.width * 1.5));
        obj1.updateHitbox();
        insert(0, obj1);

        obj2 = new BGSprite('bushes', -1048, -312, 1, 1);
        obj2.setGraphicSize(Std.int(obj2.width * 1.1) );
        obj2.updateHitbox();
        insert(20, obj2);

        obj3 = new BGSprite('bushes', -128, -362, 1, 1);
        obj3.setGraphicSize(Std.int(obj3.width * 1.1));
        obj3.updateHitbox();
        insert(20, obj3);

        if (!ClientPrefs.data.lowQuality) {
            horses = new FlxTypedGroup<BGSprite>();
            add(horses);
            horseAmount = FlxG.random.int(2, 5);

            var horseSprites:Array<BGSprite> = [];
            for (i in 0...horseAmount) {
                var x:Float = FlxG.random.float(-400, 1000);
                var y:Float = FlxG.random.float(-210, -130);
                
                var horse:BGSprite = new BGSprite('horse', x, y, 1, 1, ['Idle'], false);
                var isFlipped:Bool = (x >= 350);
                horse.flipX = isFlipped;
                var scale = Math.max(0.01, 0.35 - ((y + 210) / 300));
                horse.setGraphicSize(Std.int(horse.width * scale));
                horse.updateHitbox();
                
                horseSprites.push(horse);
            }

            horseSprites.sort((a, b) -> {
                var bottomA = a.y + a.height;
                var bottomB = b.y + b.height;
                return Std.int(bottomA) - Std.int(bottomB);
            });

            for (horse in horseSprites)
                horses.add(horse);
        }

        horsePhone = new FlxSprite(-1700, -380);
        horsePhone.frames = Paths.getSparrowAtlas('veryimportant/horseguy');
        horsePhone.animation.addByPrefix('idle', 'horseWALK', 1000, true);
        horsePhone.animation.play('idle', false, false, 0);
        horsePhone.scale.set(2.4, 1.7);
        horsePhone.updateHitbox();
        horsePhone.visible = false;
        add(horsePhone);

        stool = new BGSprite('stoolphone', 405, 24, 1, 1);
        add(stool);

        phone = new BGSprite('phone', 0, -300, 1, 1);
        phone.angle = -25;
        add(phone);

        super.create();
    }

    override function createPost()
    {
        gf.visible = false;

        if ((FlxG.width / 1920) != 1)
            defaultCamZoom = 0.8;
        camGame.zoom = defaultCamZoom;

        super.createPost();
    }

    override function beatHit()
    {
        super.beatHit();

        if (!ClientPrefs.data.lowQuality && horses != null) {
            horses.forEach(function(horse:BGSprite) {
                horse.animation.play('Idle', false, false, 0);
            });
        }
    }

    override function update(elapsed:Float)
    {
        if (!ClientPrefs.data.lowQuality && FlxG.random.bool(luck)) {
            horseFunni();
        }

        if (phoneFollow) {
            phone.x = horsePhone.x + 250;
        }

        super.update(elapsed);
    }

    override function sectionHit() {
        if (curSection % 64 == 0) luck += 0.2;

        super.sectionHit();
    }

    override function stepHit() {
        if (curStep == 1808)
        {
            horsePhone.visible = true;
            FlxTween.tween(horsePhone, {x: 1500}, 4, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
                horsePhone.destroy();
            }});
            new FlxTimer().start(2.25, function(tmr:FlxTimer) {
                phoneFollow = false;
                FlxTween.tween(phone, {x: 350}, 0.4, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
                    phone.destroy();
                    stool.destroy();
                    remove(horsePhone);
                    insert(PlayState.instance.members.indexOf(gfGroup) - 1, horsePhone);
                    gf.visible = true;
                }});
                FlxTween.tween(phone, {y: -120, angle: 0}, 0.35, {ease: FlxEase.cubeIn});
            });
        }

        if (curStep == 2528)
        {
            camGame.visible = false;
            camHUD.visible = false;
        }
        
        super.stepHit();
    }

    function horseFunni()
    {
        var speed:Float = FlxG.random.float(1, 6);
        var horse:FlxSprite = new FlxSprite(-1500, FlxG.random.int(-170, 500));
        horse.frames = Paths.getSparrowAtlas('veryimportant/horseguy');
        horse.animation.addByPrefix('walk', 'horseWALK', 1000, true, false, false);
        horse.animation.play('walk', false, false, 0);

        horse.scale.set(FlxG.random.float(0.1, 2.2), FlxG.random.float(0.1, 1.5));
        horse.updateHitbox();
        var horseBottom = horse.y + horse.height;

        var depthObjects = [
            {obj: stool, bottom: stool.y + stool.height},
            {obj: PlayState.instance.gf, bottom: PlayState.instance.gf.y + PlayState.instance.gf.height},
            {obj: PlayState.instance.dad, bottom: PlayState.instance.dad.y + PlayState.instance.dad.height},
            {obj: PlayState.instance.boyfriend, bottom: PlayState.instance.boyfriend.y + PlayState.instance.boyfriend.height},
            {obj: obj3, bottom: obj3.y + obj3.height},
            {obj: obj2, bottom: obj2.y + obj2.height}
        ];

        depthObjects.sort(function(a, b) return Std.int(a.bottom - b.bottom));

        var insertIndex = 2;

        for (depthObj in depthObjects) {
            if (horseBottom <= depthObj.bottom) {
                var objIndex = PlayState.instance.members.indexOf(depthObj.obj);
                if (objIndex != -1) {
                    insertIndex = objIndex;
                    break;
                }
            }
        }
        
        insert(insertIndex, horse);
        
        FlxTween.tween(horse, {x: 1800}, speed, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
            horse.destroy();
        }});
    }
}
