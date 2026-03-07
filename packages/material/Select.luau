local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;

local Material = require(script.Parent);
local Button = require(script.Parent.Button);

type p<T> = Material.Prop<T>;
export type Props = Material.Props<{
    Items: p<{string}>;
    Selected: p<string>;
    Open: p<boolean>;

    DropdownSize: p<UDim2>;
    TriggerProps: Button.Props?;

    TextHook: ((new: string, prev: string) -> ())?,

    onSelectionChanged: ((new: string, old: string) -> ())?,
}>;

return function(props: Props)
    local open = c(false);
    if Charms.isCharm(props.Open) then
        local c = props.Open::wade.Charm<boolean>;
        open:set(c:get());

        open:subscribe(function(x)
            c:set(x);
        end);
    elseif typeof(props.Open) == "boolean" then
        open:set(props.Open);
    end

    local clickHandled = false;
    game.UserInputService.InputBegan:Connect(function(inp)
        if not (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
            return;
        end

        if clickHandled then
            return;
        end

        task.spawn(function()
            local dst = os.clock()+0.1;
            while task.wait() do
                if os.clock() > dst then
                    break;
                end
                if clickHandled then
                    return;
                end
            end
            
            open:set(false);
        end);
    end);

    local selected: wade.Charm<string>;
    if Charms.isCharm(props.Selected) then
        selected = props.Selected::wade.Charm<string>;
    else
        selected = c(props.Selected or (Material.Extract(props.Items, {"?"})[1]));
    end

    local buttonProps: Button.Props = props.TriggerProps or {};
    buttonProps.Style = buttonProps.Style or "Secondary";
    buttonProps.Text = buttonProps.Text or wade.charmHook(selected, function(x, y)
        if props.TextHook then
            return props.TextHook(x, y);
        end

        return tostring(x);
    end);
    buttonProps.AutomaticSize = buttonProps.AutomaticSize or Enum.AutomaticSize.XY;
    buttonProps.Padding = buttonProps.Padding or UDim.new(0, 10);
    buttonProps.Size = buttonProps.Size or UDim2.fromOffset(0, 0);
    buttonProps.Icon = "rbxassetid://11552476728";
    buttonProps.IconAt = "right";

    buttonProps[wade.Event.MouseButton1Down] = function()
        clickHandled = true;
        task.delay(0.01, function()
            clickHandled = false;
        end);
    end

    buttonProps[wade.Event.Activated] = function()
        open:set(function(x)
            return not x;
        end);
    end

    local btnCharm = c(nil);
    buttonProps.Charm = btnCharm;

    local ti = TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);
    local dropdownScale = a(0.8, 1, ti);
    local dropdownGroupTransparency = a(1, 0, ti);
    local dropdownStrokeTransparency = a(1, 0.5, ti);

    open:subscribe(function(x, prev)
        if x and (not prev) then
            dropdownScale:play();
            dropdownGroupTransparency:play();
            dropdownStrokeTransparency:play();
        end

        if (not x) and prev then
            dropdownScale:playReverse();
            dropdownGroupTransparency:playReverse();
            dropdownStrokeTransparency:playReverse();
        end
    end);

    local DropdownApp;
    local function DropdownMenu(btn: TextButton)
        local pos = c();
        local function f()
            pos:set(UDim2.fromOffset(btn.AbsolutePosition.X+5, btn.AbsolutePosition.Y+btn.AbsoluteSize.Y+5));
        end

        f();
        btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(f);
        btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(f);

        local children = {};
        local items = {};
        if Charms.isCharm(props.Items) then
            items = props.Items:get();

            local unsub;
            unsub = props.Items:subscribe(function()
                unsub();
                DropdownApp();
            end).unsubscribe;
        elseif typeof(props.Items) == "table" then
            items = props.Items;
        end

        for _, item in ipairs(items) do
            local text;
            if typeof(item) == "string" then
                text = item;
            end

            table.insert(children, Button {
                Size = UDim2.new(1, 0, 0, 30),
                TextXAlignment = Enum.TextXAlignment.Left,

                Style = "Secondary",
                BackgroundTransparency = wade.charmHook(selected, function(x)
                    return x == text and 0 or 0.8;
                end),

                Text = text,
                TextColor = Color3.new(1, 1, 1),
                TextSize = 15,
                Padding = UDim.new(0, 8),

                Icon = wade.charmHook(selected, function(x)
                    return x == text and "rbxassetid://123505575168158" or "";
                end),
                IconColor = Color3.new(1, 1, 1),
                IconSize = UDim2.fromOffset(20, 20),
                IconAt = "left",

                Interactable = open,

                [wade.Event.MouseButton1Down] = function()
                    clickHandled = true;
                    task.delay(0.01, function()
                        clickHandled = false;
                    end);
                end,

                [wade.Event.Activated] = function()
                    selected:set(text);
                end,
            });
        end

        return e "CanvasGroup" {
            Position = pos,
            Size = props.DropdownSize or UDim2.fromScale(0.2, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            
            BackgroundColor3 = Material.Lighten(Material.ButtonColor("Secondary"), -0.2),
            
            GroupTransparency = dropdownGroupTransparency,

            Children = {
                e "UIScale" {
                    Scale = dropdownScale,
                },
                e "UICorner" {
                    CornerRadius = UDim.new(0, 10),
                },
                e "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    BorderStrokePosition = Enum.BorderStrokePosition.Outer,

                    Color = Material.ButtonColor("Secondary"),
                    Thickness = 1,
                    Transparency = dropdownStrokeTransparency,
                },
                e "UIPadding" {
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                },
                e "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    Padding = UDim.new(0, 5),
                },

                children,
            },
        };
    end

    DropdownApp = function()
        local btn = btnCharm:get()::TextButton;
        local sgui = c();

        -- some weird roblox bug, this must be done for some reason
        sgui:subscribe(function(x)
            x.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets;
        end);

        return e "ScreenGui" {
            Name = "select-gui",

            DisplayOrder = 900,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
            Charm = sgui,

            Children = DropdownMenu(btn),
        };
    end

    local prevApp, conn;
    btnCharm:subscribe(function(x)
        if prevApp then
            prevApp:Destroy();
        end

        if conn then
            conn:Disconnect();
        end

        prevApp = wade:mount(DropdownApp, game.Players.LocalPlayer:WaitForChild("PlayerGui"))[1];
        wade:awaitMountFinish();

        conn = wade:onVisibilityChanged(x, function(isVisible)
            if open:get() and not isVisible then
                open:set(false);
            end
        end);
    end);
    
    return Button(buttonProps);
end
