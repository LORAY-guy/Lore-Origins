package backend;

#if mobile
import flixel.group.FlxGroup;

class MobileUIControls extends FlxGroup
{
    public var upButton:MobileButton;
    public var downButton:MobileButton;
    public var leftButton:MobileButton;
    public var rightButton:MobileButton;
    public var acceptButton:MobileButton;
    
    // Virtual input states
    public var virtualInputs:Map<String, Bool> = new Map<String, Bool>();
    public var virtualJustPressed:Map<String, Bool> = new Map<String, Bool>();
    public var virtualJustReleased:Map<String, Bool> = new Map<String, Bool>();
    
    private var lastFrameInputs:Map<String, Bool> = new Map<String, Bool>();
    
    public function new(?rightSide:Bool = false)
    {
        super();
    
        resetVirtualInputs();

        var buttonSize:Int = 96;
        var centerX:Float = (rightSide) ? FlxG.width - (buttonSize * 2) : buttonSize * 2;
        var centerY:Float = FlxG.height - ((buttonSize * 3) - 100);
        var buttonSpacing:Float = buttonSize * 1.05;

        upButton = new MobileButton("ui_up", centerX - buttonSize/2, centerY - buttonSpacing - buttonSize/2, buttonSize, buttonSize);
        upButton.onPressed = function() { setVirtualInput("ui_up", true); };
        upButton.onReleased = function() { setVirtualInput("ui_up", false); };
        add(upButton);

        downButton = new MobileButton("ui_down", centerX - buttonSize/2, centerY + buttonSpacing - buttonSize/2, buttonSize, buttonSize);
        downButton.onPressed = function() { setVirtualInput("ui_down", true); };
        downButton.onReleased = function() { setVirtualInput("ui_down", false); };
        add(downButton);

        leftButton = new MobileButton("ui_left", centerX - buttonSpacing - buttonSize/2, centerY - buttonSize/2, buttonSize, buttonSize);
        leftButton.onPressed = function() { setVirtualInput("ui_left", true); };
        leftButton.onReleased = function() { setVirtualInput("ui_left", false); };
        leftButton.scrollFactor.set();
        add(leftButton);

        rightButton = new MobileButton("ui_right", centerX + buttonSpacing - buttonSize/2, centerY - buttonSize/2, buttonSize, buttonSize);
        rightButton.onPressed = function() { setVirtualInput("ui_right", true); };
        rightButton.onReleased = function() { setVirtualInput("ui_right", false); };
        add(rightButton);

        var acceptButtonSize:Float = buttonSize * 0.75;
        acceptButton = new MobileButton("ui_accept", centerX - acceptButtonSize/2, centerY - acceptButtonSize/2, acceptButtonSize, acceptButtonSize);
        acceptButton.onPressed = function() { setVirtualInput("accept", true); };
        acceptButton.onReleased = function() { setVirtualInput("accept", false); };
        add(acceptButton);
    }
    
    private function resetVirtualInputs():Void
    {
        var inputs:Array<String> = ["ui_up", "ui_down", "ui_left", "ui_right", "accept"];

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
        upButton.alpha = upButton.originalAlpha = alpha;
        downButton.alpha = downButton.originalAlpha = alpha;
        leftButton.alpha = leftButton.originalAlpha = alpha;
        rightButton.alpha = rightButton.originalAlpha = alpha;
        acceptButton.alpha = acceptButton.originalAlpha = alpha;
    }
    
    public function setVisible(visible:Bool):Void
    {
        upButton.visible = visible;
        downButton.visible = visible;
        leftButton.visible = visible;
        rightButton.visible = visible;
        acceptButton.visible = visible;
    }

    public function setScrollFactor(?x:Float, ?y:Float):Void
    {
        upButton.scrollFactor.set(x, y);
        downButton.scrollFactor.set(x, y);
        leftButton.scrollFactor.set(x, y);
        rightButton.scrollFactor.set(x, y);
        acceptButton.scrollFactor.set(x, y);
    }

    public function updateHitbox():Void
    {
        upButton.updateHitbox();
        downButton.updateHitbox();
        leftButton.updateHitbox();
        rightButton.updateHitbox();
        acceptButton.updateHitbox();
    }

    public function setCameras(cameras:Array<FlxCamera>):Void
    {
        this.cameras = cameras;
        upButton.cameras = cameras;
        downButton.cameras = cameras;
        leftButton.cameras = cameras;
        rightButton.cameras = cameras;
        acceptButton.cameras = cameras;
    }
}

class MobileButton extends FlxSprite
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