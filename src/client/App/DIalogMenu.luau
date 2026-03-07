local wade = require(game.ReplicatedStorage.Packages.wade);
local c = wade.charm;
local e = wade.element;

local Material = require(game.ReplicatedStorage.Packages.material);
local Button = Material.Button;
local Dialog = Material.Dialog;
local Avatar = Material.Avatar;
local List = Material.List;
local Label = Material.Label;
local HoverCard = Material.HoverCard;

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

            Body = {
                e "UIListLayout" {
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    Padding = UDim.new(0, 5),
                },
                List {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Children = {
                        HoverCard {
                            Trigger = Avatar {
                                UserId = game.Players.LocalPlayer.UserId,
                                Badge = Color3.new(0, 0.8, 0),
                            },
                            Content = {
                                e "UIListLayout" {},
                                Label {
                                    Text = "This avatar uses a solid color badge",
                                },
                            },
                        },
                        HoverCard {
                            Trigger = Avatar {
                                UserId = game.Players.LocalPlayer.UserId,
                                Badge = Color3.new(0.3, 0.3, 0.3),
                            },
                            Content = {
                                e "UIListLayout" {},
                                Label {
                                    Text = "This avatar uses a solid color badge",
                                },
                            },
                        },
                        HoverCard {
                            Trigger = Avatar {
                                UserId = game.Players.LocalPlayer.UserId,
                                Badge = "rbxassetid://7577357898",
                                BadgeSize = UDim2.fromOffset(20, 20),
                            },
                            Content = {
                                e "UIListLayout" {},
                                Label {
                                    Text = "This avatar uses an image badge (scaled up so you can see it)",
                                },
                            },
                        },
                        Label {
                            Text = "These avatars have hover cards!",
                        },
                    },
                },
            },
        }
    };
end