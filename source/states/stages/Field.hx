package states.stages;

class Field extends BaseStage {
    //why am i wasting my time doing this... AGAIN??
    var obj1:BGSprite;
    var obj2:BGSprite;
    var obj3:BGSprite;

    var stool:BGSprite;
    var phone:BGSprite;
    var horsePhone:FlxSprite;

    var horses:FlxTypedGroup<BGSprite>;
    var horseAmount:Int = 0;

    var x_values:Array<Float> = [];
    var y_values:Array<Float> = [];

    var luck:Float = 0.2;
    var phoneFollow:Bool = true;

    override function create() {
        obj1 = new BGSprite('field', -870, -727, 1, 1);
        obj1.setGraphicSize(Std.int(obj1.width * 1.4));
        obj1.updateHitbox();
        insert(0, obj1);

        obj2 = new BGSprite('bushes', -998, -312, 1, 1);
        obj2.setGraphicSize(Std.int(obj2.width * 1.1));
        obj2.updateHitbox();
        insert(20, obj2);

        obj3 = new BGSprite('bushes', -78, -362, 1, 1);
        obj3.setGraphicSize(Std.int(obj3.width * 1.1));
        obj3.updateHitbox();
        insert(20, obj3);

        horses = new FlxTypedGroup<BGSprite>();
        add(horses);

        horseAmount = FlxG.random.int(2, 5);

        for (i in 0...horseAmount) {
            var x:Float = FlxG.random.float(-400, 1000);
            var y:Float = FlxG.random.float(-210, -130);
    
            x_values.push(x);
            y_values.push(y);
        }

        y_values.sort((a, b) -> Std.int(a) - Std.int(b));

        for (i in 0...horseAmount) {
            var horse:BGSprite;
            var x:Float = x_values[i];
            var y:Float = y_values[i];

            horse = new BGSprite('horse', x, y, 1, 1, ['Idle'], false);
            var isFlipped:Bool = (x >= 350);
            horse.flipX = isFlipped;

            var scale = Math.max(0.01, 0.35 - ((y + 210) / 300));
            horse.setGraphicSize(Std.int(horse.width * scale));
            horse.updateHitbox();

            horses.add(horse);
        }

        horsePhone = new FlxSprite(-1700, -380);
        horsePhone.frames = Paths.getSparrowAtlas('veryimportant/horseguy');
        horsePhone.animation.addByPrefix('idle', 'horseWALK', 1000, true);
        horsePhone.animation.play('idle', false, false, 0);
        horsePhone.scale.set(2.4, 1.7);
        horsePhone.updateHitbox();
        add(horsePhone);

        stool = new BGSprite('stoolphone', 405, 24, 1, 1);
        add(stool);

        phone = new BGSprite('phone', 0, -300, 1, 1);
        phone.angle = -25;
        add(phone);

        super.create();
    }

    override function createPost() {
        gf.visible = false;

        super.createPost();
    }

    override function beatHit() {
        super.beatHit();

        horses.forEach(function(horse:BGSprite) {
            horse.animation.play('Idle', false, false, 0);
        });
    }

    override function update(elapsed:Float) {
        if (FlxG.random.bool(luck)) {
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

    function horseFunni() {
        var speed:Float = FlxG.random.float(1, 6);

        var horse:FlxSprite = new FlxSprite(-1500, FlxG.random.int(-170, 500));
        horse.frames = Paths.getSparrowAtlas('veryimportant/horseguy');
        horse.animation.addByPrefix('walk', 'horseWALK', 1000, true, false, false);
        horse.animation.play('walk', false, false, 0);

        if (horse.y < 35) {
            insert(1, horse);
        } else if (horse.y > 35 && horse.y < 275) {
            insert(PlayState.instance.members.indexOf(dadGroup) - 1, horse);
        } else {
            insert(PlayState.instance.members.indexOf(obj3) - 1, horse);
        }

        horse.scale.set(FlxG.random.float(0.1, 2.2), FlxG.random.float(0.1, 1.5));
        horse.updateHitbox();
        FlxTween.tween(horse, {x: 1800}, speed, {ease: FlxEase.linear, onComplete: function(twn:FlxTween) {
            horse.destroy();
        }});
    }
}