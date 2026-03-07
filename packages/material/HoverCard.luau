local Material = require(script.Parent);

local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;

type p<T> = Material.Prop<T>;
export type Props = Material.Props<{
    Trigger: wade.Element;
    Content: wade.ChildrenType;

    ContentSize: p<UDim2>;
    ContentAutomaticSize: p<Enum.AutomaticSize>;
    ContentPadding: p<UDim>;
}>;

return function(props: Props)
    local trigger = c();
    props.Trigger.props.Charm = trigger;

    local open = c(false);

    local ti = TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);
    local cardScale = a(0.8, 1, ti);
    local cardGroupTransparency = a(1, 0, ti);
    local cardStrokeTransparency = a(1, 0.5, ti);

    open:subscribe(function(x, prev)
        if x and (not prev) then
            cardScale:play();
            cardGroupTransparency:play();
            cardStrokeTransparency:play();
        end

        if (not x) and prev then
            cardScale:playReverse();
            cardGroupTransparency:playReverse();
            cardStrokeTransparency:playReverse();
        end
    end);

    props.Trigger.props[wade.Event.MouseEnter] = function()
        open:set(true);
    end;

    props.Trigger.props[wade.Event.MouseLeave] = function()
        open:set(false);
    end;

    local HoverApp;
    local function HoverCard(trigger: GuiObject)
        local pos = c();
        local function f()
            pos:set(UDim2.fromOffset(trigger.AbsolutePosition.X+5, trigger.AbsolutePosition.Y+trigger.AbsoluteSize.Y+5));
        end

        f();
        trigger:GetPropertyChangedSignal("AbsolutePosition"):Connect(f);
        trigger:GetPropertyChangedSignal("AbsoluteSize"):Connect(f);

        return e "CanvasGroup" {
            Position = pos,
            Size = props.ContentSize or UDim2.fromScale(0, 0),
            AutomaticSize = props.ContentAutomaticSize or Enum.AutomaticSize.XY,

            BackgroundColor3 = Material.Lighten(Material.ButtonColor("Secondary"), -0.2),
            GroupTransparency = cardGroupTransparency,
            Children = {
                e "UIScale" {
                    Scale = cardScale,
                },
                e "UICorner" {
                    CornerRadius = UDim.new(0, 10),
                },
                e "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    BorderStrokePosition = Enum.BorderStrokePosition.Outer,

                    Color = Material.ButtonColor("Secondary"),
                    Thickness = 1,
                    Transparency = cardStrokeTransparency,
                },
                e "UIPadding" {
                    PaddingTop = props.ContentPadding or UDim.new(0, 8),
                    PaddingBottom = props.ContentPadding or UDim.new(0, 8),
                    PaddingLeft = props.ContentPadding or UDim.new(0, 4),
                    PaddingRight = props.ContentPadding or UDim.new(0, 4),
                },
                props.Content,
            },
        };
    end

    HoverApp = function()
        local t = trigger:get();
        local sgui = c();

        sgui:subscribe(function(x)
            x.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets;
        end);

        return e "ScreenGui" {
            Name = "hover-gui",

            DisplayOrder = 899,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
            Charm = sgui,

            Children = HoverCard(t),
        };
    end

    local prevApp, conn;
    trigger:subscribe(function(x)
        if prevApp then
            prevApp:Destroy();
        end

        if conn then
            conn:Discnnect();
        end

        prevApp = wade:mount(HoverApp, game.Players.LocalPlayer:WaitForChild("PlayerGui"))[1];
        wade:awaitMountFinish();
        conn = wade:onVisibilityChanged(x, function(isVisible)
            if open:get() and not isVisible then
                open:set(false);
            end
        end);
    end);

    return props.Trigger;
end