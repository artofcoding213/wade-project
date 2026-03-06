local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;

local Material = require(script.Parent);
local Button = require(script.Parent.Button);

type p<T> = Material.Prop<T>;
export type Props = Material.Props<{
    LayoutOrder: p<number>,
    Text: p<string>,
}> & {[string]: any};

return function(props: Props)
    local labelProps = props;
    local function p(name, val)
        labelProps[name] = labelProps[name] or val;
    end

    p("FontFace", Material.Font());
    p("TextColor3", Color3.new(0.95, 0.95, 0.95));
    p("TextSize", 16);
    p("Size", UDim2.fromScale(0, 0));
    p("Position", UDim2.fromScale(0.5, 0.5));
    p("AutomaticSize", Enum.AutomaticSize.XY);
    p("BackgroundTransparency", 1);
    p("BackgroundColor3", Color3.new(0.2, 0.2, 0.2));
    if labelProps.BackgroundTransparency then
        p("Children", {
            e "UICorner" {
                CornerRadius = UDim.new(0, 10),
            },
            e "UIPadding" {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
            },
        });    
    end

    return e "TextLabel"(labelProps);
end