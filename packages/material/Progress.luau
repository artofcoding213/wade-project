local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;
local h = wade.charmHook;

local Material = _G["_Material"]::any;

type p<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type Props = {[number]: (...any) -> ()} & {[string]: any} & {
    LayoutOrder: p<number>;
    BackgroundColor: p<Color3>;
    FillColor: p<Color3>;

    Value: p<number>; -- 0-1

    Size: p<UDim2>;
    Position: p<UDim2>;

    CornerRadius: p<UDim>;

    Children: wade.ChildrenType;
};

return function(props: Props)
    local fillColor = props.FillColor or Color3.new(0.9, 0.9, 0.9);
    local value: wade.Charm<number>; -- 0-1
    if props.Value and (Charms.isCharm(props.Value) or Charms.isAnimCharm(props.Value)) then
        value = props.Value;
    else
        value = c(props.Value or 0);
    end

    return e "CanvasGroup" {
        Size = props.Size or UDim2.fromOffset(100, 10),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),

        BackgroundColor3 = props.BackgroundColor or Color3.new(0.2, 0.2, 0.2),
        BorderSizePixel = 0,

        InheritedProps = props,
        Children = {
            e "UICorner" {
                CornerRadius = props.CornerRadius or UDim.new(1, 0),
            },
            e "Frame" {
                BackgroundColor3 = fillColor,
                BorderSizePixel = 0,

                Size = UDim2.fromScale(1, 1),
                Position = h(value, function(x)
                    print(`h: {x}`);
                    return UDim2.fromScale(-(1-x), 0);
                end),
            },
        },
    };
end