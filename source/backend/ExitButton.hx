package backend;

class ExitButton extends FlxSprite
{
    public var prevState:Dynamic;
    public var prevStateString:String;

    var clicked:Bool = false;
    var elapsedSinceMouseLeft:Float = 0.0;
    var delayDuration:Float = 2.0;

    public function new(prevState:String = ''):Void
    {
        super(0, -5);
        frames = Paths.getSparrowAtlas('exitbutton');
        animation.addByPrefix('idle', 'idle', 12, true);
        animation.addByPrefix('pop', 'pop', 24, false);
        animation.addByPrefix('in', 'in', 24, false);
        animation.play('idle');
        setGraphicSize(Std.int(this.width * 0.5));
        updateHitbox();
        antialiasing = false;
        visible = false;
        x = (ClientPrefs.data.exitButtonX == 'Right' ? FlxG.width - width : 0);

        this.prevState = getStateFromString(prevState);
        this.prevStateString = prevState.toLowerCase(); //Just in case I need it.
    }

    override function update(elapsed:Float):Void
    {    
        if (FlxG.mouse.overlaps(this))
        {
            if (!visible)
            {
                visible = true;
                animation.play('in', true);
            }
    
            if (FlxG.mouse.justPressed)
                handleButtonClick();
    
            elapsedSinceMouseLeft = 0.0;
        } 
        else if (visible) 
        {
            elapsedSinceMouseLeft += elapsed;
    
            if (!clicked && elapsedSinceMouseLeft >= delayDuration && this.animation.curAnim.name != 'in')
                animation.play('in', false, true);
        }
    
        handleAnimationEnd();

        super.update(elapsed);
    }
    
    function handleButtonClick():Void
    {
        clicked = true;
        animation.play('pop');
        new FlxTimer().start(0.3, function(tmr:FlxTimer) {
            this.visible = false;
        });

        FlxG.sound.play(Paths.sound('cancelMenu'), 0.9);
        
        FlxTween.tween(FlxG.camera, {y: 720}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
            if (this.prevStateString != 'playstate' || this.prevStateString != 'options') 
                MusicBeatState.switchState(this.prevState);
            else
                LoadingState.loadAndSwitchState(this.prevState);
        }});
    }
    
    function handleAnimationEnd():Void
    {
        if (this.animation.curAnim.name == 'pop' && this.animation.curAnim.finished) 
            animation.play('in', false, true);
    
        if (this.animation.curAnim.name == 'in' && this.animation.curAnim.finished && !clicked)
        {
            if (this.animation.curAnim.reversed) 
                visible = false;
            else 
                animation.play('idle');
        }
    
        if (!clicked && this.animation.curAnim.finished && this.animation.curAnim.name != 'idle') 
            animation.play('idle');
    }

    private function getStateFromString(type:String = ''):Dynamic {
		switch(type.toLowerCase().trim())
		{
			case 'mainmenu': return new states.MainMenuState();
			case 'freeplay': return new states.FreeplayState();
			case 'freeplayselect': return new states.FreeplaySelectState();
			case 'options': return new options.OptionsState();
            case 'title': return new states.TitleState();
            case 'credits': return new states.credits.CreditsState();
            case 'exit': 
                exitGame();
                return null;
		}
        return new states.MainMenuState();
	}

    public static function exitGame():Void
    {
        #if windows
        Sys.exit(0);
        #elseif html5
        js.Browser.window.close();
        #elseif linux
        Sys.command("pkill Lore Origins");
        #elseif mac
        Sys.command("pkill -f Lore Origins");
        #end
    }
}