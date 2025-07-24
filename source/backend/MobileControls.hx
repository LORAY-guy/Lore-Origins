package backend;

#if mobile
class MobileControls extends FlxTypedGroup<MobileButton>
{
    public var virtualInputs:Map<String, Bool> = new Map<String, Bool>();
    public var virtualPressed:Map<String, Bool> = new Map<String, Bool>();
    public var virtualJustPressed:Map<String, Bool> = new Map<String, Bool>();
    public var virtualJustReleased:Map<String, Bool> = new Map<String, Bool>();
    
    private var lastFrameInputs:Map<String, Bool> = new Map<String, Bool>();
    private var inputs:Array<String> = ["note_left", "note_down", "note_up", "note_right"];

    private var activeTouches:Map<Int, String> = new Map<Int, String>();
    
    public function new()
    {
        super();
    
        resetVirtualInputs();

        var posOffset:Float = 0;

        for (input in inputs) {
            var button = new MobileButton(input, posOffset);
            add(button);
            posOffset += FlxG.width / 4;
        }
    }
    
    private function resetVirtualInputs():Void
    {
        for (input in inputs)
        {
            virtualInputs[input] = false;
            virtualPressed[input] = false;
            virtualJustPressed[input] = false;
            virtualJustReleased[input] = false;
            lastFrameInputs[input] = false;
        }
    }
    
    private function setVirtualInput(input:String, pressed:Bool):Void
    {
        virtualInputs[input] = pressed;
    }

    private function isButtonPressed(buttonName:String):Bool
    {
        for (touchInput in activeTouches)
        {
            if (touchInput == buttonName)
                return true;
        }
        return false;
    }
    
    override public function update(elapsed:Float):Void
    {
        handleMultiTouchInput();

        forEachAlive(function(button:MobileButton) {
            var isPressed = isButtonPressed(button.name);
            button.setPressed(isPressed);
        });

        for (input in inputs)
        {
            var shouldBePressed = isButtonPressed(input);
            setVirtualInput(input, shouldBePressed);
        }

        super.update(elapsed);

        for (input in virtualInputs.keys())
        {
            var currentState:Bool = virtualInputs[input];
            var lastState:Bool = lastFrameInputs[input];
            
            virtualPressed[input] = currentState;
            virtualJustPressed[input] = currentState && !lastState;
            virtualJustReleased[input] = !currentState && lastState;

            lastFrameInputs[input] = currentState;
        }

    }
    
    private function handleMultiTouchInput():Void
    {
        var camera:FlxCamera = FlxG.cameras != null && FlxG.cameras.list.length > 0 ? FlxG.cameras.list[FlxG.cameras.list.length - 1] : FlxG.camera;
        var touchesToRemove:Array<Int> = [];

        for (touchId in activeTouches.keys())
        {
            var touchStillActive:Bool = false;

            for (i in 0...FlxG.touches.list.length)
            {
                var touch = FlxG.touches.list[i];
                if (touch.touchPointID == touchId && touch.pressed)
                {
                    touchStillActive = true;
                    break;
                }
            }

            if (touchId == 0 && FlxG.mouse.pressed)
                touchStillActive = true;

            if (!touchStillActive)
                touchesToRemove.push(touchId);
        }
        
        for (touchId in touchesToRemove)
            activeTouches.remove(touchId);

        for (i in 0...FlxG.touches.list.length)
        {
            var touch = FlxG.touches.list[i];
            var touchId:Int = touch.touchPointID;
            
            if (touch.pressed)
            {
                var touchX:Float = touch.getScreenPosition(camera).x;
                var touchY:Float = touch.getScreenPosition(camera).y;
                var touchedButton:String = null;

                forEachAlive(function(button:MobileButton) {
                    if (touchX >= button.x && touchX <= button.x + button.width && 
                        touchY >= button.y && touchY <= button.y + button.height)
                    {
                        touchedButton = button.name;
                    }
                });
                
                if (touchedButton != null)
                    activeTouches[touchId] = touchedButton;
                else
                    activeTouches.remove(touchId);
            }
            else
            {
                activeTouches.remove(touchId);
            }
        }
        
        var mouseId:Int = 0;
        if (FlxG.mouse.pressed)
        {
            var mouseX:Float = FlxG.mouse.getScreenPosition(camera).x;
            var mouseY:Float = FlxG.mouse.getScreenPosition(camera).y;

            var touchedButton:String = null;
            forEachAlive(function(button:MobileButton) {
                if (mouseX >= button.x && mouseX <= button.x + button.width && 
                    mouseY >= button.y && mouseY <= button.y + button.height)
                {
                    touchedButton = button.name;
                }
            });

            if (touchedButton != null)
                activeTouches[mouseId] = touchedButton;
            else
                activeTouches.remove(mouseId);
        }
        else
        {
            activeTouches.remove(mouseId);
        }
    }

    public function checkJustPressed(input:String):Bool
    {
        return virtualJustPressed.exists(input) ? virtualJustPressed[input] : false;
    }
    
    public function checkPressed(input:String):Bool
    {
        return virtualInputs.exists(input) ? virtualInputs[input] : (virtualPressed.exists(input) ? virtualPressed[input] : false);
    }
    
    public function checkJustReleased(input:String):Bool
    {
        return virtualJustReleased.exists(input) ? virtualJustReleased[input] : false;
    }

    public function setAlpha(alpha:Float):Void
    {
        forEachAlive(function(button:MobileButton) {
            button.alpha = button.originalAlpha = alpha;
        });
    }
    
    public function setVisible(visible:Bool):Void
    {
        forEachAlive(function(button:MobileButton) {
            button.visible = visible;
        });
    }

    public function setScrollFactor(?x:Float, ?y:Float):Void
    {
        forEachAlive(function(button:MobileButton) {
            button.scrollFactor.set(x, y);
        });
    }

    public function updateHitbox():Void
    {
        forEachAlive(function(button:MobileButton) {
            button.updateHitbox();
        });
    }

    public function setCameras(cameras:Array<FlxCamera>):Void
    {
        this.cameras = cameras;
        forEachAlive(function(button:MobileButton) {
            button.cameras = cameras;
        });
    }
}

class MobileButton extends FlxSprite
{
    public var name:String;
    private var isPressed:Bool = false;
    public var originalAlpha:Float = ClientPrefs.data.mobileUIAlpha;
    
    public function new(name:String, x:Float)
    {
        super(x);

        loadGraphic(Paths.image("mobile/control_" + name));
        setGraphicSize(FlxG.width / 4, FlxG.height);
        scrollFactor.set();
        updateHitbox();

        this.name = name;

        if (originalAlpha <= 0.8)
            originalAlpha *= 0.5;
        else if (originalAlpha >= 0.2)
            originalAlpha *= 1.2;
    
        alpha = originalAlpha;
    }
    
    public function setPressed(pressed:Bool):Void
    {
        if (pressed != isPressed)
        {
            isPressed = pressed;
            
            if (isPressed)
            {
                if (originalAlpha < 1)
                    alpha = Math.max(0, Math.min(1, originalAlpha * 1.5));
                else if (originalAlpha == 1)
                    alpha = originalAlpha * 0.5;
            }
            else
            {
                alpha = originalAlpha;
            }
        }
    }
}

class MobileUIControls extends FlxTypedGroup<MobileUIButton>
{
    public var virtualInputs:Map<String, Bool> = new Map<String, Bool>();
    public var virtualJustPressed:Map<String, Bool> = new Map<String, Bool>();
    public var virtualJustReleased:Map<String, Bool> = new Map<String, Bool>();
    
    private var lastFrameInputs:Map<String, Bool> = new Map<String, Bool>();

    private var inputs:Array<String> = ["ui_up", "ui_down", "ui_left", "ui_right", "accept"];
    
    public function new(?rightSide:Bool = false)
    {
        super();
    
        resetVirtualInputs();

        var buttonSize:Int = 96;
        var centerX:Float = (rightSide) ? FlxG.width - (buttonSize * 2) : buttonSize * 2;
        var centerY:Float = FlxG.height - ((buttonSize * 3) - 100);
        var buttonSpacing:Float = buttonSize * 1.05;

        for (input in inputs) {
            var button:MobileUIButton;
            switch (input) {
                case 'ui_up':
                    button = new MobileUIButton(input, centerX - buttonSize/2, centerY - buttonSpacing - buttonSize/2, buttonSize, buttonSize);
                case 'ui_down':
                    button = new MobileUIButton(input, centerX - buttonSize/2, centerY + buttonSpacing - buttonSize/2, buttonSize, buttonSize);
                case 'ui_left':
                    button = new MobileUIButton(input, centerX - buttonSpacing - buttonSize/2, centerY - buttonSize/2, buttonSize, buttonSize);
                case 'ui_right':
                    button = new MobileUIButton(input, centerX + buttonSpacing - buttonSize/2, centerY - buttonSize/2, buttonSize, buttonSize);
                default: // just gonna default to the accept button, fuck it
                    var acceptButtonSize:Float = buttonSize * 0.75;
                    button = new MobileUIButton(input, centerX - acceptButtonSize/2, centerY - acceptButtonSize/2, acceptButtonSize, acceptButtonSize);
            }
            button.onPressed = function() { setVirtualInput(input, true); };
            button.onReleased = function() { setVirtualInput(input, false); };
            add(button);
        }
    }
    
    private function resetVirtualInputs():Void
    {
        for (input in inputs)
        {
            virtualInputs[input] = false;
            virtualJustPressed[input] = false;
            virtualJustReleased[input] = false;
            lastFrameInputs[input] = false;
        }
    }
    
    private function setVirtualInput(input:String, pressed:Bool):Void
    {
        virtualInputs[input] = pressed;
    }
    
    override public function update(elapsed:Float):Void
    {
        for (input in virtualInputs.keys())
        {
            var currentState:Bool = virtualInputs[input];
            var lastState:Bool = lastFrameInputs[input];
            
            virtualJustPressed[input] = currentState && !lastState;
            virtualJustReleased[input] = !currentState && lastState;
            
            lastFrameInputs[input] = currentState;
        }

        super.update(elapsed);
    }

    public function checkJustPressed(input:String):Bool
    {
        return virtualJustPressed.exists(input) ? virtualJustPressed[input] : false;
    }
    
    public function checkPressed(input:String):Bool
    {
        return virtualInputs.exists(input) ? virtualInputs[input] : false;
    }
    
    public function checkJustReleased(input:String):Bool
    {
        return virtualJustReleased.exists(input) ? virtualJustReleased[input] : false;
    }

    public function setAlpha(alpha:Float):Void
    {
        forEachAlive(function(button:MobileUIButton) {
            button.alpha = button.originalAlpha = alpha;
        });
    }
    
    public function setVisible(visible:Bool):Void
    {
        forEachAlive(function(button:MobileUIButton) {
            button.visible = visible;
        });
    }

    public function setScrollFactor(?x:Float, ?y:Float):Void
    {
        forEachAlive(function(button:MobileUIButton) {
            button.scrollFactor.set(x, y);
        });
    }

    public function updateHitbox():Void
    {
        forEachAlive(function(button:MobileUIButton) {
            button.updateHitbox();
        });
    }

    public function setCameras(cameras:Array<FlxCamera>):Void
    {
        this.cameras = cameras;
        forEachAlive(function(button:MobileUIButton) {
            button.cameras = cameras;
        });
    }
}

class MobileUIButton extends FlxSprite
{
    public var name:String;

    public var onPressed:Void->Void;
    public var onReleased:Void->Void;

    private var isPressed:Bool = false;
    public var originalAlpha:Float = ClientPrefs.data.mobileUIAlpha;
    
    public function new(name:String, x:Float, y:Float, width:Float, height:Float)
    {
        super(x, y);

        loadGraphic(Paths.image('mobile/button_' + name));
        setGraphicSize(width, height);
        scrollFactor.set();
        updateHitbox();

        this.name = name;
        alpha = originalAlpha;
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var camera:FlxCamera = FlxG.cameras != null && FlxG.cameras.list.length > 0 ? FlxG.cameras.list[FlxG.cameras.list.length - 1] : FlxG.camera;

        var mouseX:Float = FlxG.mouse.getScreenPosition(camera).x;
        var mouseY:Float = FlxG.mouse.getScreenPosition(camera).y;

        var inBounds:Bool = mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height;

        if (inBounds)
        {
            if (FlxG.mouse.justPressed && !isPressed)
            {
                isPressed = true;
                if (originalAlpha < 1)
                    alpha = Math.max(0, Math.min(1, originalAlpha * 1.5));
                else if (originalAlpha == 1)
                    alpha = originalAlpha * 0.5;
                if (onPressed != null) onPressed();
            }
        }
        
        if (isPressed && FlxG.mouse.justReleased)
        {
            isPressed = false;
            alpha = originalAlpha;
            if (onReleased != null) onReleased();
        }
    }
}
#end