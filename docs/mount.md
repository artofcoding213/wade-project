# mount
This goes over how the Wade engine implements `mount()`, on top of how to use it properly.

## Adding elements to already mounted elements
In something like React-luau (or formerly Roact) you would just simply remount the component,
and the new children table would be there. The reconciler would notice there's new elements, and insert them accordingly.\
The tradeoff for having performant UI is that this process is a little bit more on the user.\
Let's think basic for our example: we just want to display `n` frames in a row. `n` will be a
random value from 1-10 and will update every second.

Let's get the app boilerplate & `n` picker out of the way:
```luau
local function Frames()
    local f = charm();
    local n = charm(0);

    task.spawn(function()
        f:wait();
        while task.wait(1) do
            n:set(math.random(1, 10));
        end
    end);

    n:subscribe(function()
        -- ... what goes here?
    end);

    return e "Frame" {
        Charm = f,
        Children = e "UIListLayout" {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
        },
    };
end

local function App()
    return e "ScreenGui" {
        Children = Frames();
    };
end

wade:mount(App, game.Players.LocalPlayer:WaitForChild("PlayerGui"));
```
You'll notice we only provided the `UIListLayout` to children, and we didn't insert any frames.\
This is because we must insert them whenever `n` changes. We already have a `:subscribe()` call,
so let's implement it:
```luau
n:subscribe(function()
    local frame = f:get();
    if not frame then
        return;
    end
```
First, we ensure we have a frame.\
Next, we have to clear the previous frames:
```luau
    for _, x in ipairs(frame:GetChildren()) do
        if x:IsA("Frame") then
            x:Destroy();
        end
    end
```
Cool. Now, let's parent the frames! We can do this with a `wade:mount()` call:
```luau
    local fs = {};
    for i = 1, n:get() do
        table.insert(fs, e "Frame" { LayoutOrder = i });
    end

    wade:mount(function() return fs; end, frame);
end);
```
Instead of calling `Instance.new()` and parenting the frames, this is the cleaner alternative,
and is recommended. In fact, `wade/material` uses this technique. If you want to see it in practice, check out `packages/material/Select.luau`

## The implementation of `wade:mount()`
> NOTE: The below source code of `wade:mount()` is outdated. See `packages/wade/init.luau` for the current in-production source code
It's surprisingly simple. Before we dive into the source code, let's knock this helper function out of the way: `parseChildren()`.\
You'll see it used once or twice, but all it does is condense a children type into a flat array (i.e. `{foo, {bar, baz}}` -> `{foo, bar, baz}`).

Okay, so the core piece of `wade:mount()` is the `getInstance()` function.\
It converts an `Element` into an `Instance`. But before we can get there, we look at the bottom of `wade:mount()`:
```luau
local app = parseChildren(App());
local is = {};

for _, x in ipairs(app) do
    local i = getInstance(x);
    table.insert(is, i);

    i.Parent = parent;
end

return is;
```

Initially, we parse the children from the App component.
Then we loop through all of the elements, parenting them into the `parent` argument and inserting them into this `is` array. `wade:mount()` is expected to return the top-level of instances mounted, so this special `is` array just helps us meet that.

Alright, now to getInstance:
```luau
local i = Instance.new(e.className);
local safeProps = table.clone(e.props);
safeProps.Charm = nil;
safeProps.Children = nil;
safeProps.InheritedProps = nil;
safeProps.InheritedZIndex = nil;
```
We start out by `Instance.new()`'ing with the element's class name.\
Then, we filter out properties that are just an abstraction by us.
```luau
for k, v in pairs(safeProps) do
    if typeof(k) == "number" then
        local callback = EventCallbacks[k];
        callback(e, i, v);

        continue;
    end

    if isCharm(v) then
        v:subscribe(function(x)
            i[k] = x;
        end);

        i[k] = v:get();
    elseif isAnimCharm(v) then
        v:attach(i, k);
    else
        i[k] = v;
    end
end
```
In the above snippet, we loop through all of our "safe" properties.\
If it's a number (`wade.Event` enum), we look up its callback and attach the event.\
If it's a string, we simply set the property (`i[k] = v`).\
If it's a charm, we set the property to the charm's current value, then subscribe for a
change, and update the prpoerty.\
If it's an animation charm, we let it handle everything from there on out.

If `props.InheritedProps` is specified, we can inherit those properties:
```luau
if e.props.InheritedProps then
    for k, v in pairs(e.props.InheritedProps) do
        if typeof(k) == "number" then
            local callback = EventCallbacks[k];
            callback(e, i, v);
        elseif typeof(k) == "string" then
            -- instance[prop] may fail because the property may not exist
            pcall(function()
                if not safeProps[k] then
                    i[k] = v;
                end
            end);
        end
    end
end
```

Now, we are ready to mount any children specified in `props.Children`:
```luau
if e.props.Children then
    for _, x in ipairs(parseChildren(e.props.Children)) do
        if isGuiObject(x.className) and e.props.InheritedZIndex then
            local zi = (x.props.ZIndex or 0)+e.props.InheritedZIndex;
            x.props.ZIndex = zi;
            x.props.InheritedZIndex = zi+1;
        end

        getInstance(x).Parent = i;
    end
end
```
This snippet would be much simpler without the `InheritedZIndex` bit, but we have to make things
complicated in the framework field.\
All it does is ensure the element gets the ZIndex field set and that its children inherit its ZIndex plus 1.

Then we can update any charms we need for it, and return the instance:
```luau
if e.props.Charm then
    e.props.Charm:set(i);
end

return i;
```

...and, that's it!