local wade = require(game.ReplicatedStorage.Packages.wade);
local c = wade.charm;
local e = wade.element;
local a = wade.animCharm;

local Material = require(game.ReplicatedStorage.Packages.material);
local ScrollArea = Material.ScrollArea;
local Button = Material.Button;
local Dialog = Material.Dialog;
local Avatar = Material.Avatar;
local List = Material.List;
local Label = Material.Label;
local HoverCard = Material.HoverCard;
local Input = Material.Input;
local Progress = Material.Progress;

local Sonner = require(script.Parent.Sonner);

return function()
    local open = c(false);
    local objectCount = c(0);
    local inputValue = c("");
    local progressValue = a(0, 0, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out));

    task.spawn(function()
        local pgui = game.Players.LocalPlayer:WaitForChild("PlayerGui");
        while true do
            progressValue:setAB(progressValue.b, math.random());
            progressValue:play();

            objectCount:set(#pgui:QueryDescendants("GuiObject")); 
            task.wait(2);
        end
    end);

    return {
        Button {
            Position = UDim2.fromScale(0.8, 0.5),
            Size = UDim2.fromScale(0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Padding = UDim.new(0, 10),
            Style = "Secondary",

            Text = "Dialog Menu + more examples",
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

            Body = ScrollArea {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                StrokeTransparency = 1,
                Children = {
                    e "UIListLayout" {
                        FillDirection = Enum.FillDirection.Vertical,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 5),
                    },
                    Label {
                        LayoutOrder = 0,
                        Text = wade.charmHook(objectCount, function(x)
                            return `gui object count: {x}`;
                        end),
                        BackgroundTransparency = 0,
                    },
                    List {
                        LayoutOrder = 1,
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
                    List {
                        LayoutOrder = 2,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Children = {
                            Input {
                                LayoutOrder = 0,
                                BackgroundColor = Material.Lighten(Material.ButtonColor("Secondary"), -0.2),
                                PlaceholderText = "hello, input!",
                                Text = inputValue,

                                Icon = wade.charmHook(inputValue, function(x)
                                    return x == "" and "rbxassetid://10993876141" or "rbxassetid://127075876244307";
                                end),
                            },
                            Button {
                                Style = "Secondary",
                                Size = UDim2.fromScale(0, 0),
                                Padding = UDim.new(0, 10),

                                LayoutOrder = 1,
                                Text = "Toast",
                                AutomaticSize = Enum.AutomaticSize.XY,

                                [wade.Event.Activated] = function()
                                    Sonner:toast(inputValue:get(), {description = inputValue:get()});
                                end,
                            },
                        },
                    },
                    ScrollArea {
                        LayoutOrder = 3,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        Size = UDim2.new(1, -10, 0, 100),
                        ElementPadding = UDim.new(0, 0),

                        Children = {
                            Label { Text = "Hello," },
                            Label { Text = "world!" },
                            Label { Text = "I am a" },
                            Label { Text = "ScrollArea" },
                            Label { Text = "!" },
                            Label { Text = "foo" },
                            Label { Text = "bar" },
                            Label { Text = "baz" },
                        },
                    },
                    Progress {
                        Value = progressValue,
                    },
                },
            },
        }
    };
end