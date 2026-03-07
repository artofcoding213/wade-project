local wade = require(game.ReplicatedStorage.Packages.wade);

local Material = require(game.ReplicatedStorage.Packages.material);
local Button = Material.Button;

local Sonner = require(script.Parent.Sonner);

return function()
    return Button {
        Position = UDim2.fromScale(0.8, 0.7),
        Size = UDim2.fromScale(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Padding = UDim.new(0, 10),
        Style = "Secondary",

        Text = "Toast (sonner)",
        [wade.Event.Activated] = function()
            Sonner:toast("hello,", {description = "world!"});
        end,
    };
end