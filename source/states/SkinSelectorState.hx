package states;

typedef SkinData = {
    name: String,
    skins: Array<SkinSubData>
}

typedef SkinSubData = {
    name: String,
    scale: Float
    //author: String
}

class SkinSelectorState extends MusicBeatState
{
    public static var skinData:Array<SkinData>;

    private var bg:FlxSprite;
    private var arrows:FlxSpriteGroup;
    private var grid:FlxBackdrop;
    private var lettabox1:FlxBackdrop;
    private var lettabox2:FlxBackdrop;

    private var characterName:Alphabet;
    private var skinName:Alphabet;
    private var characterList:FlxText;
    private var characterSprite:FlxSprite;

    private static var curChar:String = 'Ourple';
    private static var curSkin:String = 'Normal';
    private static var curCharIndex:Int = 0;
    private static var curSkinIndex:Int = 0;

    public var exitButton:ExitButton;

    #if mobile
    private var mobileControls:MobileUIControls;
    #end

    override public function create():Void
    {
        Paths.clearUnusedMemory();

        retrieveSkinData();

		var bg:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('mainmenu/bg'));
		var scaleMultiplier:Float = FlxG.width / 1280;
		var finalScale:Float = 1.7 * scaleMultiplier;
		finalScale = Math.max(finalScale, 1.0);
		finalScale = Math.min(finalScale, 2.5);
		bg.setGraphicSize(Std.int(bg.width * finalScale));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        grid = createBackdrop('mainmenu/grid', 40, 40, XY);
		grid.alpha = 0.5;
		add(grid);

        lettabox1 = createBackdrop('mainmenu/lettabox', 40);
        lettabox1.y = FlxG.height - lettabox1.height;
		add(lettabox1);

		lettabox2 = createBackdrop('mainmenu/lettabox2', -40);
		add(lettabox2);

        arrows = new FlxSpriteGroup();
        arrows.y += 18;
        createArrow(true);
        createArrow(false);
        add(arrows);

        updateSkinList();
        changeCharacter(curCharIndex);

        super.create();

        exitButton = new ExitButton();
        add(exitButton);

        #if mobile
        mobileControls = new MobileUIControls();
        add(mobileControls);

        Controls.mobileControls = mobileControls;
        #end
    }

    public var selectedSomethin:Bool = false;
    override public function update(elapsed:Float):Void
	{
        if (!selectedSomethin)
        {
            if (controls.UI_UP_P)
                changeCharacter(-1);
            if (controls.UI_DOWN_P)
                changeCharacter(1);

            if (controls.UI_LEFT_P || (FlxG.mouse.overlaps(arrows.members[0]) && !FlxG.mouse.overlaps(exitButton) && FlxG.mouse.justPressed)) {
                if (skinData[curCharIndex].skins.length > 1) {
                    changeSkin(-1);
                } else {
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                }
                arrows.members[0].animation.play('s');
            }
            if (controls.UI_RIGHT_P || (FlxG.mouse.overlaps(arrows.members[1]) && !FlxG.mouse.overlaps(exitButton) && FlxG.mouse.justPressed)) {
                if (skinData[curCharIndex].skins.length > 1) {
                    changeSkin(1);
                } else {
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                }
                arrows.members[1].animation.play('s');
            }
            if (controls.UI_LEFT_R || (FlxG.mouse.overlaps(arrows.members[0]) && !FlxG.mouse.overlaps(exitButton) && FlxG.mouse.released))
                arrows.members[0].animation.play('i');
            if (controls.UI_RIGHT_R || (FlxG.mouse.overlaps(arrows.members[1]) && !FlxG.mouse.overlaps(exitButton) && FlxG.mouse.released))
                arrows.members[1].animation.play('i');

            if (controls.ACCEPT_P)
                saveOurple();

            if (controls.BACK_P) {
                selectedSomethin = true;
                FlxG.camera.zoom += 0.06;
                exitState(new MainMenuState(true));
            }
        }
        
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
		
        super.update(elapsed);
	}

    private function changeCharacter(change:Int = 0):Void
    {
        FlxG.camera.zoom += 0.03;

        if (change != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));

        curCharIndex += change;

        if (curCharIndex >= skinData.length)
            curCharIndex = 0;
        if (curCharIndex < 0)
            curCharIndex = skinData.length - 1;

        curChar = skinData[curCharIndex].name;
        curSkinIndex = 0;
        curSkin = skinData[curCharIndex].skins[0].name;

        reloadCharacter(change, true);

        if (characterName != null) characterName.destroy();
        characterName = new Alphabet(0, (FlxG.height / 2) - 282, coolerNameFormatter(curChar), true);
        characterName.screenCenter(X);
        add(characterName);

        updateSkinDisplay();
    }

    private function changeSkin(change:Int = 0):Void
    {
        FlxG.camera.zoom += 0.03;
        if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

        curSkinIndex += change;

        if (curSkinIndex >= skinData[curCharIndex].skins.length)
            curSkinIndex = 0;
        if (curSkinIndex < 0)
            curSkinIndex = skinData[curCharIndex].skins.length - 1;
    
        curSkin = skinData[curCharIndex].skins[curSkinIndex].name;

        reloadCharacter(change);
        updateSkinDisplay();
    }

    private function updateSkinList():Void
    {
        if (characterList != null)
            characterList.destroy();
        checkForSkinExistence();
        characterList = new FlxText(FlxG.width - 360, FlxG.height - 200, 0, 'Ourple Guy: ${ClientPrefs.data.ourpleSkin}\nMatpat: ${ClientPrefs.data.matpatSkin}\nPhone Guy: ${ClientPrefs.data.phoneGuySkin}', 26);
        characterList.setFormat(Paths.font('ourple.ttf'), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        characterList.antialiasing = false;
        add(characterList);
    }

    private function updateSkinDisplay():Void
    {
        if (skinName != null)
            skinName.destroy();
        skinName = new Alphabet(0, FlxG.height - 200, curSkin == 'Loray' ? curSkin.toUpperCase() : curSkin, false);
        skinName.screenCenter(X);
        add(skinName);
    }

    private function reloadCharacter(change:Int = 0, fromTop:Bool = false):Void
    {
        var spriteName:String = curChar;
        var subSpriteName:String = curSkin;
        var path:String = 'skins/' + ((spriteName == 'Ourple' ? 'playguy' : spriteName) + (subSpriteName == 'Normal' ? '' : subSpriteName)).toLowerCase();

        if (Paths.image(path) == null)
        {
            curSkinIndex = 0;
            curSkin = 'Normal';
            path = 'skins/' + ((curChar == 'Ourple' ? 'playguy' : curChar) + (curSkin == 'Normal' ? '' : curSkin)).toLowerCase();
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }

        if (characterSprite != null) {
            FlxTween.cancelTweensOf(characterSprite, ['x', 'y']);
            if (fromTop) {
                FlxTween.tween(characterSprite, {y: (change > 0 ? FlxG.height + characterSprite.height : -FlxG.height - characterSprite.height)}, 0.2, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween) {
                    destroyAndCreateCharacter(path, change, fromTop);
                }});
            } else {
                FlxTween.tween(characterSprite, {x: (change > 0 ? FlxG.width + characterSprite.width : -FlxG.width - characterSprite.width)}, 0.2, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween) {
                    destroyAndCreateCharacter(path, change, fromTop);
                }});
            }
        } else {
            destroyAndCreateCharacter(path);
        }
    }

    private function destroyAndCreateCharacter(path:String, change:Int = 0, fromTop:Bool = false):Void
    {
        if (characterSprite != null) characterSprite.destroy();

        var characterScale:Float = skinData[curCharIndex].skins[curSkinIndex].scale;
        if (characterScale < 0)
            characterScale = 0.75;
        characterSprite = new FlxSprite().loadGraphic(Paths.image(path));
        characterSprite.x = -FlxG.width - characterSprite.width;
        characterSprite.scale.set(characterScale, characterScale);
        characterSprite.updateHitbox();
        characterSprite.antialiasing = (characterScale < 1);
        insert(members.indexOf(lettabox1), characterSprite);
        characterSprite.screenCenter(XY);

        if (fromTop) {
            var yPos:Float = characterSprite.y;
            characterSprite.y = (change > 0) ? -FlxG.height - characterSprite.height : FlxG.height + characterSprite.height;
            FlxTween.tween(characterSprite, {y: yPos}, 0.2, {ease: FlxEase.cubeOut});
        } else {
            var xPos:Float = characterSprite.x;
            characterSprite.x = (change > 0) ? -FlxG.width - characterSprite.width : FlxG.width + characterSprite.width;
            FlxTween.tween(characterSprite, {x: xPos}, 0.2, {ease: FlxEase.cubeOut});
        }
    }

    private function createBackdrop(image:String, velocityX:Float = 0, velocityY:Float = 0, ?axes = flixel.util.FlxAxes.X):FlxBackdrop
    {
        var backdrop = new FlxBackdrop(Paths.image(image), axes);
        backdrop.scrollFactor.set(0, 0);
        backdrop.velocity.set(velocityX, velocityY);
        return backdrop;
    }

    private function createArrow(flipX:Bool):FlxSprite
    {
        var arrow = new FlxSprite();
        arrow.frames = Paths.getSparrowAtlas('mainmenu/arrows');
        arrow.animation.addByPrefix('i', 'normal', 12);
        arrow.animation.addByPrefix('s', 'press', 12);
        arrow.animation.play('i');
        arrow.scale.set(2, 2);
        arrow.updateHitbox();
        arrow.scrollFactor.set();
        arrow.flipX = flipX;
        arrow.x = flipX ? 0 : FlxG.width - arrow.width;
        arrows.add(arrow);
        return arrow;
    }

    private function saveOurple():Void
    {
        switch (curChar) {
            case 'Matpat':
                ClientPrefs.data.matpatSkin = curSkin;
            case 'Phone':
                ClientPrefs.data.phoneGuySkin = curSkin;
            default:
                ClientPrefs.data.ourpleSkin = curSkin;
        }

        ClientPrefs.saveSettings();
        CoolUtil.reloadOurpleCursor();

        updateSkinList();
        var saved:Alphabet = new Alphabet(FlxG.width - 375, 40, 'SAVED !', true);
        add(saved);
        FlxTween.tween(saved, {y: saved.y + 75, alpha: 0}, 0.7, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
            saved.destroy();
            saved = null;
        }});
    }

    inline private function coolerNameFormatter(character:String):String
    {
        switch (character) {
            case 'Matpat':
                return 'MatPat';
            case 'Phone':
                return 'Phone Guy';
            default:
                return 'Ourple Guy';
        }
    }

    public static function retrieveSkinData():Void
    {
        try {
            var jsonPath = Paths.json("skinData");
            #if MODS_ALLOWED
            if (FileSystem.exists("skins/skinData.json"))
                jsonPath = "skins/skinData.json";
            var rawJson:String = sys.io.File.getContent(jsonPath);
            #else
            var rawJson:String = openfl.utils.Assets.getText(jsonPath);
            #end
            skinData = haxe.Json.parse(rawJson);

            if (skinData == null || skinData.length == 0)
                throw 'No skin data found.';

            var totalSkins:Int = 0;
            for (char in skinData)
                totalSkins += char.skins.length;
            trace('Loaded successfully skin data: ${totalSkins} skins found.');
        } catch (e:Dynamic) {
            trace('Failed to load skin data, using default data instead. Error: ${e}');
            skinData = [
                {
                    name: "Ourple",
                    skins: [
                        {name: "Normal", scale: 2.5},
                        {name: "RTX", scale: 2.5},
                        {name: "Mad", scale: 2.5},
                        {name: "Staring", scale: 2.4},
                        {name: "Afton", scale: 2.4},
                        {name: "Shaggy", scale: 0.65},
                        {name: "Loray", scale: 2.5}
                    ]
                },
                {
                    name: "Matpat",
                    skins: [
                        {name: "Normal", scale: 0.75},
                        {name: "RTX", scale: 0.75},
                        {name: "Sad", scale: 0.75},
                        {name: "PNG", scale: 1.2},
                        {name: "FAF", scale: 0.6},
                        {name: "Sunk", scale: 0.325},
                        {name: "Sunk Mad", scale: 0.325}
                    ]
                },
                {
                    name: "Phone",
                    skins: [
                        {name: "Normal", scale: 0.8},
                        {name: "RTX", scale: 0.8}
                    ]
                }
            ];
        }
    }

    public static function checkForSkinExistence():Void
    {
        // Check if the skin stored in the ClientPrefs exists in the skinData, if not, set it to 'Normal'
        if (ClientPrefs.data.ourpleSkin == null || ClientPrefs.data.ourpleSkin == '' || skinData[0].skins.filter(function(s:SkinSubData) {return s.name == ClientPrefs.data.ourpleSkin;}).length == 0) {
            ClientPrefs.data.ourpleSkin = 'Normal';
            ClientPrefs.saveSettings(false);
        }
        if (ClientPrefs.data.matpatSkin == null || ClientPrefs.data.matpatSkin == '' || skinData[1].skins.filter(function(s:SkinSubData) {return s.name == ClientPrefs.data.matpatSkin;}).length == 0) {
            ClientPrefs.data.matpatSkin = 'Normal';
            ClientPrefs.saveSettings(false);
        }
        if (ClientPrefs.data.phoneGuySkin == null || ClientPrefs.data.phoneGuySkin == '' || skinData[2].skins.filter(function(s:SkinSubData) {return s.name == ClientPrefs.data.phoneGuySkin;}).length == 0) {
            ClientPrefs.data.phoneGuySkin = 'Normal';
            ClientPrefs.saveSettings(false);
        }
    }

    override public function destroy():Void
    {
        ClientPrefs.loadPrefs();
        #if mobile
        Controls.mobileControls = null;
        #end
        super.destroy();
    }
}
