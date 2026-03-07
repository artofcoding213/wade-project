local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;

local Material = _G["_Material"]::any;

type p<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type Props = {[number]: (...any) -> ()} & {[string]: any} & {
    Text: p<string>;
    PlaceholderText: p<string>;
    Focused: p<boolean>;

    BackgroundColor: p<Color3>;
    TextColor: p<Color3>;
    PlaceholderColor: p<Color3>;

    Padding: p<UDim>;
    CornerRadius: p<UDim>;

    Size: p<UDim2>;
    Position: p<UDim2>;
    AnchorPoint: p<Vector2>;
    AutomaticSize: p<Enum.AutomaticSize>;
    Font: p<Font>;
    TextSize: p<number>;

    Charm: wade.Charm<TextBox>;
};

return function(props: Props)
    local focused: wade.Charm<boolean>;
    if props.Focused and Charms.isCharm(props.Focused) then
        focused = props.Focused;
    else
        focused = c(props.Focused or false);
    end

    local text: wade.Charm<string>;
    if props.Text and Charms.isCharm(props.Text) then
        text = props.Text;
    else
        text = c(props.Text or "");
    end

    local ti = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);
    local strokeThickness = a(0, 4, ti);
    local strokeTransparency = a(0.9, 0.88, ti);

    local bg = props.BackgroundColor or Material.ButtonColor("Secondary");
    local hover = a(bg, Material.Lighten(bg, 0.1), ti);

    focused:subscribe(function(x, prev)
        if x == prev then return; end

        if x then
            strokeThickness:play();
        else
            strokeThickness:playReverse();
        end
    end);

    return e "TextBox" {
        PlaceholderText = props.PlaceholderText,
        PlaceholderColor3 = props.PlaceholderColor or props.TextColor or Color3.new(0.8, 0.8, 0.8),

        BackgroundColor3 = hover,
        BorderSizePixel = 0,
        TextColor3 = props.TextColor or Color3.new(0.9, 0.9, 0.9),
        FontFace = props.Font or Material.Font(),
        TextSize = props.TextSize or 16,

        Size = props.Size or UDim2.fromOffset(100, 0),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = props.AnchorPoint,
        AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.XY,

        Text = text:get() or "",
        ClearTextOnFocus = false,

        Charm = props.Charm,
        InheritedProps = props,
        Children = {
            e "UICorner" {
                CornerRadius = props.CornerRadius or UDim.new(0, 10),
            },
            e "UIPadding" {
                PaddingLeft = props.Padding or UDim.new(0, 5),
                PaddingRight = props.Padding or UDim.new(0, 5),
                PaddingTop = props.Padding or UDim.new(0, 5),
                PaddingBottom = props.Padding or UDim.new(0, 5),
            },
            e "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                BorderStrokePosition = Enum.BorderStrokePosition.Center,

                Color = Color3.new(0, 0, 0),
                Thickness = 3,
                Transparency = strokeTransparency,

                Children = e "UIGradient" {
                    Rotation = -90,
                    Transparency = Material.NumSeq{ {0, 0}, {0.4, 1}, {1, 1} },
                },
            },
            e "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                BorderStrokePosition = Enum.BorderStrokePosition.Outer,

                Transparency = 0.6,
                Color = Material.Lighten(Material.ButtonColor("Secondary"), 0.4),
                Thickness = strokeThickness,
            },
            e "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                BorderStrokePosition = Enum.BorderStrokePosition.Outer,

                Transparency = 0.5,
                Color = Material.Lighten(Material.ButtonColor("Secondary"), 0.4),
                Thickness = 1,
            }
        },

        [wade.Event.Hover] = function()
            strokeTransparency:play();
            hover:play();
        end,
        [wade.Event.Unhover] = function()
            strokeTransparency:playReverse();
            hover:playReverse();
        end,
        
        [wade.Event.Focused] = function()
            focused:set(true);
        end,
        [wade.Event.ReturnPressedFromOnScreenKeyboard] = function()
            focused:set(false);
        end,
        [wade.Event.FocusLost] = function()
            focused:set(false);
        end,
    };
end