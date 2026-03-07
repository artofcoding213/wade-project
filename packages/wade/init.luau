--[[

Wade 101
Creating your first app:

local wade = require(game.ReplicatedStorage.Packages.wade);

local function Hello()
    return wade.element "TextLabel" {
        Text = "Hello, world!",
        Position = UDim2.fromScale(0.5, 0.5),
    };
end

local function App()
    return wade.element "ScreenGui" {
        Children = Hello(),
    };
end

wade:mount(App, game.Players.LocalPlayer:WaitForChild("PlayerGui"));

Creating a counter (replace Hello() calls in the above example with Counter()):
local function Counter()
    local count = wade.charm(0);

    return wade.element "TextButton" {
        Text = wade.charmHook
    };
end

]]

-- utils

local function isGuiObject(className: string)
    return Instance.new(className):IsA("GuiObject");
end

-- ....

export type Event = number;

local Events = require(script.Events);
local EventEnum = {};
local EventCallbacks = {};

do
    local i = 0;
    for eventName, eventCallback in pairs(Events) do
        i += 1;
        EventEnum[eventName] = i;
        EventCallbacks[i] = eventCallback;
    end
end

local Charms = require(script.Charms);
local charm, isCharm, charmHook = Charms.charm, Charms.isCharm, Charms.charmHook;
local animCharm, isAnimCharm, mergeAnimCharms = Charms.animCharm, Charms.isAnimCharm, Charms.mergeAnimCharms;

export type Charm<T> = Charms.Charm<T>;
export type AnimCharm<T> = Charms.AnimCharm<T>;

export type ElementProps = {[string | Event]: any} & {
    Charm: Charm<Instance>?, -- Same as a React-luau Ref to a gui instance except we just do it with charms
    Children: ChildrenType?, 
    InheritedProps: {[string | Event]: any}, -- Events from these properties will be passed down
    InheritedZIndex: number?, -- Children of this element ZIndex will be InheritedZIndex + El.ZIndex
};

export type Element = {
    tt: "Element",
    className: string,
    props: ElementProps,
};

export type ChildrenType = (Element | {ChildrenType})?;

export type WadeAPI = {
    -- state
    mountStack: {any},

    -- enums
    Event: {[keyof<typeof(Events)>]: number},

    -- ui primitives
    element: (className: string) -> ((props: ElementProps) -> Element),

    mount: (self: WadeAPI, App: () -> ChildrenType, parent: Instance) -> {Instance},

    -- utils
    connectEventTo: (self: WadeAPI, to: Instance, e: Event, f: (...any) -> ()) -> RBXScriptConnection,
    onVisibilityChanged: (self: WadeAPI, x: GuiObject, f: (isVisible: boolean) -> ()) -> RBXScriptConnection,
    awaitMountFinish: (self: WadeAPI) -> (),

    -- charms
    charm: typeof(charm),
    charmHook: typeof(charmHook),

    animCharm: typeof(animCharm),
    mergeAnimCharms: typeof(mergeAnimCharms),
};

local wade: WadeAPI = {} :: WadeAPI;
wade.Event = EventEnum;
wade.charm = charm;
wade.charmHook = charmHook;
wade.animCharm = animCharm;
wade.mergeAnimCharms = mergeAnimCharms;
wade.mountStack = {};

function wade.element(className)
    return function(props)
        return {
            tt = "Element",
            className = className,
            props = props,
        };
    end
end

function wade:mount(App, parent): {Instance}
    table.insert(wade.mountStack, 0);

    -- children can be a single element: e, an array of elements: {e},
    -- or an array of elements of infinite depth (i.e.) {e, {e, e, {e, e}}, {e, e, e}, e}
    -- recursion isnt necessary here but we do it because we only mount one time
    local function parseChildren(x: ChildrenType): {Element}
        if type(x) ~= "table" then
            return {};
        end

        if x["tt"] == "Element" then
            return {x :: Element};
        end

        local out = {};
        for _, y in ipairs(x) do
            local z = parseChildren(y);
            for _, a in ipairs(z) do
                table.insert(out, a);
            end
        end

        return out;
    end

    local function getInstance(e: Element): Instance
        local i = Instance.new(e.className);
        local safeProps = table.clone(e.props);
        safeProps.Charm = nil;
        safeProps.Children = nil;
        safeProps.InheritedProps = nil;
        safeProps.InheritedZIndex = nil;

        local function attach(k, v)
            if isCharm(v) then
                v:subscribe(function(x)
                    pcall(function()
                        i[k] = x
                    end);
                end);

                i[k] = v:get();
            elseif isAnimCharm(v) then
                v:attach(i, k);
            else
                i[k] = v;
            end
        end

        for k, v in pairs(safeProps) do
            if typeof(k) == "number" then
                local callback = EventCallbacks[k];
                callback(e, i, v);

                continue;
            end

            attach(k, v);
        end

        if e.props.InheritedProps then
            for k, v in pairs(e.props.InheritedProps) do
                if typeof(k) == "number" then
                    local callback = EventCallbacks[k];
                    callback(e, i, v);
                elseif typeof(k) == "string" then
                    -- instance[prop] may fail because the property may not exist
                    pcall(function()
                        if not safeProps[k] then
                            attach(k, v);
                        end
                    end);
                end
            end
        end

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

        if e.props.Charm then
            e.props.Charm:set(i);
        end

        return i;
    end

    local app = parseChildren(App());
    local is = {};

    for _, x in ipairs(app) do
        local i = getInstance(x);
        table.insert(is, i);

        i.Parent = parent;
    end

    table.remove(wade.mountStack);
    return is;
end

function wade:connectEventTo(to, e, f)
    local callback = EventCallbacks[e];

    return callback(nil, to, f);
end

function wade:onVisibilityChanged(x, f)
    local conns = {};
    table.insert(conns, x:GetPropertyChangedSignal("Visible"):Connect(function()
        f(x.Visible);
    end));

    local function iterate(x: GuiObject?)
        if typeof(x) ~= "Instance" then
            return;
        end

        table.insert(conns, x:GetPropertyChangedSignal("Visible"):Connect(function()
            f(x.Visible);
        end));

        iterate(x:FindFirstAncestorWhichIsA("GuiObject"));
    end

    iterate(x:FindFirstAncestorWhichIsA("GuiObject"));

    return {
        Disconnect = function(self)
            for _, conn in ipairs(conns) do
                conn:Disconnect();
            end
            table.clear(conns);
        end,
        disconnect = function(self)
            self:Disconnect();
        end,
    }::RBXScriptConnection;
end

function wade:awaitMountFinish()
    if #wade.mountStack == 0 then
        return;
    end

    local baseI = #wade.mountStack;
    while #wade.mountStack == baseI do
        task.wait();
    end

    return;
end

return wade;