-- macro for a Frame (autoSize=XY) + UIListLayout

local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;

local Material = _G["_Material"]::any;

type p<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type Props = {[number]: (...any) -> ()} & {
    FillDirection: p<Enum.FillDirection>;
    AutomaticSize: p<Enum.AutomaticSize>;
    HorizontalAlignment: p<Enum.HorizontalAlignment>;
    VerticalAlignment: p<Enum.VerticalAlignment>;
    Padding: p<UDim>;

    Size: p<UDim2>;
    Position: p<UDim2>;
    Children: wade.ChildrenType;
};

return function(props: Props)
    return e "Frame" {
        Size = props.Size or UDim2.fromScale(0, 0),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.XY,
        
        BackgroundTransparency = props.BackgroundTransparency or 1,
        InheritedProps = props,
        Children = {
            e "UIListLayout" {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = props.FillDirection or Enum.FillDirection.Vertical,
                HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
                VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center,
                Padding = props.Padding or UDim.new(0, 5),
            },
            props.Children,
        },
    };
end