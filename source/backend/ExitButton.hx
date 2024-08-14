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
        scrollFactor.set();

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
    
            if (!clicked && FlxG.mouse.justPressed) {
                handleButtonClick();
            }
    
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

        switch (this.prevStateString)
        {
            case 'options':
                MusicBeatSubstate.getSubState().close();
            case 'credits':
                MusicBeatState.switchState(this.prevState);
            default:
                FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {
                    ease: FlxEase.expoInOut, 
                    onComplete: function(twn:FlxTween) {
                        switch (this.prevStateString) {
                            case 'playstate':
                                StageData.loadDirectory(PlayState.SONG);
                                LoadingState.loadAndSwitchState(this.prevState);
                                FlxG.sound.music.volume = 0;
                            default:
                                MusicBeatState.switchState(this.prevState);
                        }
                    }
                });
        }
    }
    
    function handleAnimationEnd():Void 
    {
        if (animation.curAnim.finished) {
            switch (animation.curAnim.name) 
            {
                case 'pop':
                    animation.play('in', false, true);
                case 'in':
                    if (!clicked) {
                        if (animation.curAnim.reversed) visible = false;
                        else animation.play('idle');
                    }
                default:
                    if (!clicked) animation.play('idle');
            }
        }
    }

    private function getStateFromString(type:String = ''):Dynamic {
		switch(type.toLowerCase().trim())
		{
			case 'freeplay': return new states.FreeplayState(true);
			case 'freeplayselect': return new states.FreeplaySelectState(true);
			case 'options': return new options.OptionsState(true);
            case 'credits': return new states.credits.CreditsState();
            case 'creditssubgroup': return new states.credits.CreditsSubgroupState(true);
            case 'title': return new states.TitleState();
            case 'playstate': return new states.PlayState();
            case 'exit': 
                Main.exitGame();
                return null;
            default: return new states.MainMenuState(true);
		}
	}
}