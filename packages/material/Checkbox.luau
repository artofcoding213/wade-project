local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local h = wade.charmHook;
local a = wade.animCharm;

local Material = require(script.Parent);

type p<T> = Material.Prop<T>;
export type Props = Material.Props<{
    On: wade.Charm<boolean>?;

    CheckboxSize: p<UDim2>;
    Position: p<UDim2>;

    Label: p<string>;
    LabelPosition: ("right" | "left")?;
    LabelProps: {[string]: any}?;
}>;

return function(props: Props)
    local on = props.On or c(false);
    local defValue = on:get();

    local ti = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);
    local imageTransparency = a(1, 0, ti);
    local fillTransparency = a(1, 0, ti);

    on:subscribe(function(x, prev)
        if x == prev then return; end

        if x then
            imageTransparency:play();
            fillTransparency:play();
        else
            imageTransparency:playReverse();
            fillTransparency:playReverse();
        end
    end);
    on:set(on:get());

    local label = nil;
    if props.Label then
        local labelProps = props.LabelProps or {};
        labelProps.Size = labelProps.Size or UDim2.fromScale(0, 0);
        labelProps.AutomaticSize = labelProps.AutomaticSize or Enum.AutomaticSize.XY;
        labelProps.LayoutOrder = labelProps.LayoutOrder or props.LabelPosition == "right" and 0 or 1;
        labelProps.Text = labelProps.Text or props.Label;
        labelProps.TextColor3 = labelProps.TextColor3 or Color3.new(0.9, 0.9, 0.9);
        labelProps.BackgroundTransparency = labelProps.BackgroundTransparency or 1;
        labelProps.FontFace = labelProps.FontFace or h(on, function(x)
            return Material.Font(x ~= defValue and Enum.FontWeight.SemiBold);
        end);
        labelProps.TextSize = labelProps.TextSize or 16;

        label = e "TextLabel"(labelProps);
    end

    return e "Frame" {
        Size = UDim2.fromScale(0, 0),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,

        Children = {
            e "UIListLayout" {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            },
            e "TextButton" {
                LayoutOrder = 1,
                AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = fillTransparency,

                Size = props.CheckboxSize or UDim2.fromOffset(20, 20),
                Text = "",  

                Children = {
                    e "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.new(0.9, 0.9, 0.9),
                        Transparency = 0.05,
                    },
                    e "ImageLabel" {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),

                        Image = "rbxassetid://123505575168158",
                        ImageColor3 = Color3.new(0, 0, 0),
                        ImageTransparency = imageTransparency,
                    },
                },

                [wade.Event.Activated] = function()
                    on:set(function(x)
                        return not x;
                    end);
                end,
            },
            label
        },
    };
end