local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;

local Material = _G["_Material"]::any;

type p<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type Props = {[number]: (...any) -> ()} & {
    -- UIListLayout:
    FillDirection: p<Enum.FillDirection>;
    HorizontalAlignment: p<Enum.HorizontalAlignment>;
    VerticalAlignment: p<Enum.VerticalAlignment>;
    ElementPadding: p<UDim>;
    
    -- ScrollingFrame:
    ScrollbarThickness: p<number>;
    StrokeTransparency: p<number>;

    Size: p<UDim2>;
    Position: p<UDim2>;
    AnchorPoint: p<Vector2>;
    
    BackgroundColor: p<Color3>;
    CornerRadius: p<UDim>;
    Padding: p<UDim>;

    Children: wade.ChildrenType,
};

return function(props: Props)
    return e "ScrollingFrame" {
        AutomaticCanvasSize = Enum.AutomaticSize.XY,
        CanvasSize = UDim2.fromScale(0, 0),

        Size = props.Size or UDim2.fromScale(1, 1),
        Position = props.Position or UDim2.fromScale(0, 0),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        ScrollBarThickness = props.ScrollbarThickness or 10,
        ScrollBarImageColor3 = Color3.new(1, 1, 1),
        ScrollBarImageTransparency = 0.6,

        Children = {
            e "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                Color = Material.ButtonColor "Secondary",
                Transparency = props.StrokeTransparency or 0,
                Thickness = 1,
            },
            e "UIListLayout" {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = props.FillDirection or Enum.FillDirection.Vertical,
                HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
                VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center,
                Padding = props.ElementPadding or UDim.new(0, 5),
            },
            e "UIPadding" {
                PaddingLeft = props.Padding or UDim.new(0, 5),
                PaddingRight = props.Padding or UDim.new(0, 5),
                PaddingTop = props.Padding or UDim.new(0, 5),
                PaddingBottom = props.Padding or UDim.new(0, 5),
            },
            e "UICorner" {
                CornerRadius = props.CornerRadius or UDim.new(0, 10),
            },
            props.Children,
        },
    };
end