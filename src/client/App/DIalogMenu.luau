local wade = require(game.ReplicatedStorage.Packages.wade);
local c = wade.charm;

local Material = require(game.ReplicatedStorage.Packages.material);
local Button = Material.Button;
local Dialog = Material.Dialog;

return function()
    local open = c(false);

    return {
        Button {
            Position = UDim2.fromScale(0.8, 0.5),
            Size = UDim2.fromScale(0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Padding = UDim.new(0, 10),
            Style = "Secondary",

            Text = "Dialog Menu",
            [wade.Event.Activated] = function()
                open:set(function(x)
                    return not x;
                end);
            end,
        },
        Dialog {
            IsOpen = open,
            TitleText = "Dialog Menu",
            Size = "big",
            ActionText = "",
            CancelText = "",
            CloseButton = true,

            Body = {},
        }
    };
end