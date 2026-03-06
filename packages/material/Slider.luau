local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;
local h = wade.charmHook;

local Material = require(script.Parent);

type p<T> = Material.Prop<T>;
export type Props = Material.Props<{
    LayoutOrder: p<number>;
    BackgroundColor: p<Color3>;
    FillColor: p<Color3>;

    Value: p<number>; -- 0-1
    Steps: p<number>;

    Size: p<UDim2>;
    Position: p<UDim2>;

    onSlideBegin: (() -> ())?;
    onSlideEnd: (() -> ())?;
}>;

return function(props: Props)
    local slideThickness = a(1, 5, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out));

    local value: wade.Charm<number>; -- 0-1
    if props.Value and Charms.isCharm(props.Value) then
        value = props.Value;
    else
        value = c(props.Value or 0);
    end

    local fillColor = props.FillColor or Color3.new(0.9, 0.9, 0.9);

    local conn: RBXScriptConnection;
    local barCharm: wade.Charm<Frame> = c();

    local slideOk = false;

    game.UserInputService.TouchStarted:Connect(function()
        slideOk = true;
    end);

    game.UserInputService.TouchEnded:Connect(function()
        slideOk = false;
    end);

    game.UserInputService.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then
            slideOk = true;
        end
    end);

    game.UserInputService.InputEnded:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then
            slideOk = false;
        end
    end);

    local function onDisconnect()
        slideThickness:playReverse();
        if props.onSlideEnd then
            props.onSlideEnd();
        end
    end

    local function slide()
        if conn then
            return;
        end

        if props.onSlideBegin then
            props.onSlideBegin();
        end

        slideThickness:play();
        conn = game.RunService.PreRender:Connect(function()
            local bar = barCharm:get();
            if not bar then
                return;
            end

            if not slideOk then
                onDisconnect();
                conn:Disconnect();
                conn = nil;
                return;
            end

            local a = bar.AbsolutePosition.X;
            local b = a+bar.AbsoluteSize.X;
            local p = game.UserInputService:GetMouseLocation().X;

            local out = math.clamp((p-a)/(b-a), 0, 1);
            if props.Steps then
                local s = props.Steps;
                if Charms.isCharm(s) then
                    s = s:get();
                end

                if s > 0 then
                    out = math.round(out*s)/s;
                end
            end

            value:set(out);
        end);
    end

    return e "Frame" {
        LayoutOrder = props.LayoutOrder,

        Size = props.Size or UDim2.fromOffset(100, 10),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,

        Children = {
            e "CanvasGroup" {
                Name = "Bar",
                Size = UDim2.fromScale(1, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),

                BackgroundColor3 = props.BackgroundColor or Color3.new(0.2, 0.2, 0.2),
                BorderSizePixel = 0,

                Charm = barCharm,
                Children = {
                    e "UICorner" {
                        CornerRadius = UDim.new(1, 0),
                    },
                    e "Frame" {
                        BackgroundColor3 = fillColor,
                        BorderSizePixel = 0,

                        Size = UDim2.fromScale(1, 1),
                        Position = h(value, function(x)
                            return UDim2.fromScale(-(1-x), 0);
                        end),
                    },
                },
            },
            e "TextButton" {
                Name = "Slide",
                Size = UDim2.new(0, 16, 1, 0),

                Text = "",
                BackgroundColor3 = fillColor,
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = h(value, function(x)
                    return UDim2.fromScale(x, 0.5);
                end),

                Children = {
                    e "UIAspectRatioConstraint" {
                        AspectRatio = 1,
                    },
                    e "UICorner" {
                        CornerRadius = UDim.new(1, 0),
                    },
                    e "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        BorderStrokePosition = Enum.BorderStrokePosition.Outer,

                        Color = Material.Lighten(fillColor, -0.5),
                        Thickness = slideThickness,
                        Transparency = 0.5,
                    },
                },

                [wade.Event.MouseButton1Down] = function()
                    slide();
                end,
                [wade.Event.MouseButton1Up] = function()
                    if conn then
                        onDisconnect();
                        conn:Disconnect();
                        conn = nil;
                    end
                end,
            },
        },
    };
end