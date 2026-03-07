local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;

local Material = _G["_Material"]::any;
local Label = Material.Label;

type p<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type ToastProps = {
    description: string;

    showTitle: p<boolean>;
    showDescription: p<boolean>;
    body: ((toastCharm: wade.Charm<CanvasGroup>) -> wade.ChildrenType)?;
};

export type Props = {[number]: (...any) -> ()} & {
    Position: UDim2?;
    AnchorPoint: p<UDim2>;

    toastFn: wade.Charm<(title: string, toastProps: ToastProps?) -> ()>;
};

-- config
local maxVisibleToasts = 5;
local toastLifetime = 8; -- 6

return function(props: Props)
    local containerCharm = c();
    local sguiCharm = c();
    local expanded = c(false);
    local onToast = c();

    local pos = props.Position or UDim2.fromScale(0.5, 0.05);

    local function toast(title: string, toastProps: ToastProps?)
        onToast:set();

        local currPos = pos;
        local currScale = 1;
        local currI = 0;

        local ti = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);
        local startPos = UDim2.new(pos.X, UDim.new(-0.3, 0));
        local toastPos = a(startPos, pos, ti);
        local toastScale = a(1.05, 1, ti);
        local toastTransparency = a(1, 0, ti);
        local toastStrokeTransparency = a(1, 0.6, ti);
        local toastCharm = c();
        local conns = {};

        toastScale:onAttach(function()
            toastScale:play();
        end);
        
        toastPos:onAttach(function()
            toastPos:play();
        end);

        toastTransparency:onAttach(function()
            toastTransparency:play()
        end);

        toastStrokeTransparency:onAttach(function()
            toastStrokeTransparency:play();
        end);

        expanded:subscribe(function(x, prev)
            local dstPos = UDim2.new(pos.X, UDim.new(pos.Y.Scale, pos.Y.Offset + currI*80));
            if x == prev then return; end

            if x then
                toastPos:setAB(currPos, dstPos);
                toastPos:play();

                toastScale:setAB(currScale, 1);
                toastScale:play();
            else
                toastPos:setAB(dstPos, currPos);
                toastPos:play();

                toastScale:setAB(1, currScale);
                toastScale:play();
            end
        end);

        local function destroyToast(t: Frame)
            for _, conn in ipairs(conns) do
                if conn.unsubscribe then
                    conn:unsubscribe();
                elseif conn.Disconnect then
                    conn:Disconnect();
                end
            end

            toastScale:setAB(toastScale.b, math.clamp(toastScale.b-0.2, 0, 1));
            toastScale:play();
            toastScale:wait();

            toastPos:setAB(currPos, startPos);
            toastPos:play();
            currPos = startPos;

            toastStrokeTransparency:setAB(toastStrokeTransparency.b, 1);
            toastStrokeTransparency:play();

            toastTransparency:setAB(0, 1);
            toastTransparency:play();
            toastTransparency:wait();
        end

        local function animateToast(t: Frame)
            if currI > maxVisibleToasts then
                destroyToast(t);
                return;
            end

            t.ZIndex = (maxVisibleToasts-currI);

            local prevPos = currPos;
            local prevScale = currScale;
            currPos = UDim2.new(currPos.X, UDim.new(currPos.Y.Scale, currPos.Y.Offset + (maxVisibleToasts/currI)*8));
            currScale = 1-(currI/maxVisibleToasts);

            toastPos:setAB(prevPos, currPos);
            toastPos:play();

            toastScale:setAB(prevScale, currScale);
            toastScale:play();
        end

        table.insert(conns, onToast:subscribe(function()
            if not toastCharm:get() then
                return;
            end
            
            local t = toastCharm:get();
            currI += 1;

            animateToast(t);
        end));

        task.delay(toastLifetime, function()
            if not toastCharm:get() then
                return;
            end

            destroyToast(toastCharm:get());
        end);

        local toast = e "CanvasGroup" {
            Position = toastPos,
            AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0),
            Size = UDim2.fromOffset(200, 200),

            BackgroundColor3 = Material.Lighten(Material.ButtonColor("Secondary"), -0.2),
            ZIndex = maxVisibleToasts+1,

            GroupTransparency = toastTransparency,
            Charm = toastCharm,
            Children = {
                e "UIAspectRatioConstraint" {
                    AspectRatio = 3,
                },
                e "UICorner" {
                    CornerRadius = UDim.new(0, 10),
                },
                e "UIScale" {
                    Scale = toastScale,
                },
                e "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    BorderStrokePosition = Enum.BorderStrokePosition.Outer,

                    Color = Material.Lighten(Material.ButtonColor("Secondary"), -0.15),
                    Thickness = 1,
                    Transparency = toastTransparency,
                },
                e "UIStroke" {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    BorderStrokePosition = Enum.BorderStrokePosition.Center,

                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Transparency = toastStrokeTransparency,

                    Children = e "UIGradient" {
                        Rotation = -90,
                        Transparency = Material.NumSeq{ {0, 0}, {0.4, 1}, {1, 1} },
                    },
                },
                e "UIPadding" {
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                },
                e "UIListLayout" {
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                },
                Label {
                    Visible = toastProps.showTitle,
                
                    LayoutOrder = 1,
                    Text = title,
                    TextSize = 18,
                    FontFace = Material.Font(Enum.FontWeight.Bold),

                    Size = UDim2.new(1, 0, 0, 17),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                },
                Label {
                    Visible = toastProps.showDescription,

                    LayoutOrder = 2,
                    Text = toastProps.description or "",

                    Size = UDim2.fromScale(1, 1),
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                },

                if toastProps.body then toastProps.body() else nil,
            },
        };

        wade:mount(function() return toast; end, sguiCharm:get());
    end

    local function App()
        sguiCharm:subscribe(function(x)
            x.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets;
        end);

        return e "ScreenGui" {
            Name = "sonner-gui",

            DisplayOrder = 900,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
            Charm = sguiCharm,
        };
    end

    containerCharm:subscribe(function()
        wade:mount(App, game.Players.LocalPlayer:WaitForChild("PlayerGui"));

        props.toastFn:set(function()
            return toast;
        end);
    end);

    return e "Frame" {
        Position = pos,
        AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0),
        Size = UDim2.fromOffset(200, 200),

        BackgroundTransparency = 1,
        Charm = containerCharm,

        ZIndex = 6700, -- 676767676767767676767676767676767676767676767676767676767676767677667676767676767677676767676767676767676767676767677667676767676767677676767676767766767676767676767
        [wade.Event.Hover] = function()
            expanded:set(true);
        end,
        [wade.Event.Unhover] = function()
            expanded:set(false);
        end,
    };
end