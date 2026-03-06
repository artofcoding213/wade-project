--[[

Events 101
You can subscribe to an element's event like so:
e "ClassName" {
    [wade.Event.<eventName>] = function(...)

    end,
}

Or via charms:
local i = charm();
i:subscribe(function(x)
    local conn = wade:connectEventTo(x, wade.Event.<eventName>, function(...)

    end);
end);

e "ClassName" {
    Charm = i,
}

This file defines event names and callbacks.

]]

local function wrapEvent(name)
    return function(e, i, f)
        return i[name]:Connect(f);
    end
end

return {
    -- stuff you'll probably use all the time:
    Activated = wrapEvent("Activated"),
    Hover = wrapEvent("MouseEnter"),
    Unhover = wrapEvent("MouseLeave"),

    MouseEnter = wrapEvent("MouseEnter"),
    MouseLeave = wrapEvent("MouseLeave"),
    MouseButton1Click = wrapEvent("MouseButton1Click"),
    MouseButton1Down = wrapEvent("MouseButton1Down"),
    MouseButton1Up = wrapEvent("MouseButton1Up"),
    MouseButton2Click = wrapEvent("MouseButton2Click"),
    MouseButton2Down = wrapEvent("MouseButton2Down"),
    MouseButton2Up = wrapEvent("MouseButton2Up"),

    -- stuff you'll probably use 1/16 of the time:
    MouseMoved = wrapEvent("MouseMoved"),
    MouseWheelForward = wrapEvent("MouseWheelForward"),
    MouseWheelBackward = wrapEvent("MouseWheelBackward"),

    InputBegin = wrapEvent("InputBegan"),
    InputChanged = wrapEvent("InputChanged"),
    InputEnded = wrapEvent("InputEnded"),

    -- stuff you'll probably never use:
    SelectionGained = wrapEvent("SelectionGained"),
    SelectionLost = wrapEvent("SelectionLost"),
    
    -- (deprecated)
    DragBegin = wrapEvent("DragBegin"),
    DragStopped = wrapEvent("DragStopped"),
    -- (end deprecated)

    TouchLongPress = wrapEvent("TouchLongPress"),
    TouchPan = wrapEvent("TouchPan"),
    TouchPinch = wrapEvent("TouchPinch"),
    TouchRotate = wrapEvent("TouchRotate"),
    TouchSwipe = wrapEvent("TouchSwipe"),
    TouchTap = wrapEvent("TouchTap"),
};