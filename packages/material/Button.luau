local Material = require(script.Parent);

local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local a = wade.animCharm;

type p<T> = Material.Prop<T>;
export type Props = Material.Props<{
    -- transform
    Position: p<UDim2>;
    Size: p<UDim2>;
    AnchorPoint: p<Vector2>;
    AutomaticSize: p<Enum.AutomaticSize>;

    -- constraints
    AspectRatio: p<number>;
    MinSize: p<Vector2>;
    MaxSize: p<Vector2>;

    -- button style
    Padding: p<UDim>;
    CornerRadius: p<UDim>;
    Style: p<Material.ButtonStyle>;

    BackgroundColor: p<Color3>;
    BackgroundTransparency: p<number>;
    TextColor: p<Color3>;

    Text: p<string>;
    TextSize: p<number>;
    TextXAlignment: p<Enum.TextXAlignment>;
    FontFace: p<Font>;

    Interactable: p<boolean>;
    Visible: p<boolean>;

    -- icon
    Icon: p<string>;
    IconSize: p<UDim2>;
    IconColor: p<Color3>;
    IconTranparency: p<number>;
    IconSpacing: number?;
    IconAt: ("left" | "right")?;

    -- wade stuff
    Children: wade.ChildrenType?;
    Charm: wade.Charm<TextButton>?;
}>;

local s = UDim2.fromScale;
local o = UDim2.fromOffset;

return function(props: Props)
    local children = {};

    if props.AspectRatio then
        table.insert(children, e "UIAspectRatioConstraint" {
            AspectRatio = props.AspectRatio,
        });
    end

    if props.MinSize or props.MaxSize then
        table.insert(children, e "UISizeConstraint" {
            MinSize = props.MinSize,
            MaxSize = props.MaxSize,
        });
    end

    if props.Padding then
        table.insert(children, e "UIPadding" {
            PaddingLeft = props.Padding,
            PaddingRight = props.Padding,
            PaddingBottom = props.Padding,
            PaddingTop = props.Padding, 
        });
    end

    table.insert(children, e "UICorner" {
        CornerRadius = props.CornerRadius or UDim.new(0, 10),
    });

    local bg = props.BackgroundColor or Color3.new(1, 1, 1);
    if props.Style then
        bg = Material.ButtonColor(props.Style);
    end

    local ti = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);
    local borderThicknessIn = a(0, 2, ti);
    local borderThicknessOut = a(2, 0, ti, nil, true);
    local thicknessIsIn = false;

    local hover = a(nil, Material.Lighten(bg, 0.1), ti);
    local hoverOut = a(Material.Lighten(bg, 0.1), bg, ti, nil, true);

    local strokeTransparencyIn = a(0.9, 0.88, ti);
    local strokeTransparencyOut = a(0.88, 0.9, ti, nil, true);

    table.insert(children, e "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        BorderStrokePosition = Enum.BorderStrokePosition.Inner,

        Color = Material.Lighten(bg, -0.1),
        Thickness = wade.mergeAnimCharms({ borderThicknessIn, borderThicknessOut }),
    });

    table.insert(children, e "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        BorderStrokePosition = Enum.BorderStrokePosition.Center,

        Color = Color3.new(0, 0, 0),
        Thickness = 3,
        Transparency = wade.mergeAnimCharms({ strokeTransparencyIn, strokeTransparencyOut }),

        Children = e "UIGradient" {
            Rotation = -90,
            Transparency = Material.NumSeq{ {0, 0}, {0.4, 1}, {1, 1} },
        },
    });

    if props.Style == "Secondary" then
        table.insert(children, e "UIStroke" {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            BorderStrokePosition = Enum.BorderStrokePosition.Outer,

            Color = Material.Lighten(Material.ButtonColor("Secondary"), -0.05),
            Thickness = 1,
        });
    end

    local textColor = if props.Style then Material.TextColor(props.Style) else (props.TextColor or Color3.new(0.98, 0.98, 0.98));
    local text = props.Text or "";
    local textSize = props.TextSize or 16;
    local textXAlignment = props.TextXAlignment;
    local fontFace = props.FontFace or Material.Font();

    if props.Icon then
        local hz = ({
            [Enum.TextXAlignment.Center] = Enum.HorizontalAlignment.Center,
            [Enum.TextXAlignment.Left] = Enum.HorizontalAlignment.Left,
            [Enum.TextXAlignment.Right] = Enum.HorizontalAlignment.Right,
        })[textXAlignment or Enum.TextXAlignment.Center];
        table.insert(children, e "UIListLayout" {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment =  hz,
            Padding = UDim.new(0, props.IconSpacing or 3),
        });

        if text ~= "" then
            table.insert(children, e "TextLabel" {
                Size = UDim2.fromScale(0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,

                TextColor3 = textColor,
                Text = text,
                TextSize = textSize,
                TextXAlignment = textXAlignment,
                FontFace = fontFace,
                RichText = true,
                LayoutOrder = 1,
            });
        end

        table.insert(children, e "ImageLabel" {
            ImageColor3 = props.IconColor or Color3.new(1, 1, 1),
            Image = props.Icon,
            ImageTransparency = props.IconTranparency,
            Size = props.IconSize or UDim2.fromOffset(textSize, textSize),
            BackgroundTransparency = 1,

            Visible = if Charms.isCharm(props.Icon) then wade.charmHook(props.Icon, function(x)
                return if x == "" then false else true;
            end) else true,

            LayoutOrder = props.IconAt == "right" and 2 or 0,
        });
    end

    return e "TextButton" {
        Position = props.Position or s(0.5, 0.5),
        Size = props.Size or o(100, 60),
        AnchorPoint = props.AnchorPoint,
        AutomaticSize = props.AutomaticSize,

        BorderSizePixel = 0,
        AutoButtonColor = false,
        
        BackgroundColor3 = wade.mergeAnimCharms({ hover, hoverOut }),
        BackgroundTransparency = props.BackgroundTransparency or 0,
        TextColor3 = textColor,
        Text = props.Icon ~= nil and "" or text,
        TextXAlignment = textXAlignment,
        TextSize = textSize,
        FontFace = fontFace,
        RichText = true,
        
        InheritedProps = props,
        Children = {children, props.Children},
        Charm = props.Charm,

        Interactable = props.Interactable,
        Visible = props.Visible,

        [wade.Event.Hover] = function()
            hover:play();
            strokeTransparencyIn:play();
        end,
        [wade.Event.Unhover] = function()
            hoverOut:play();
            strokeTransparencyOut:play();
            if thicknessIsIn then
                borderThicknessOut:play();
                thicknessIsIn = false;
            end
        end,

        [wade.Event.MouseButton1Down] = function()
            borderThicknessIn:play();
            thicknessIsIn = true;
        end,
        [wade.Event.MouseButton1Up] = function()
            if thicknessIsIn then
                borderThicknessOut:play();
                thicknessIsIn = false;
            end
        end,

        [wade.Event.SelectionGained] = function()
            borderThicknessIn:play();
        end,
        [wade.Event.SelectionLost] = function()
            borderThicknessOut:play();
        end,
    };
end