local wade = require(game.ReplicatedStorage.Packages.wade);
local c = wade.charm;
local e = wade.element;

local Material = require(game.ReplicatedStorage.Packages.material);
local Dialog = Material.Dialog;
local Button = Material.Button;
local Checkbox = Material.Checkbox;
local RadioGroup = Material.RadioGroup;
local Select = Material.Select;
local Slider = Material.Slider;
local Label = Material.Label;
local List = Material.List;

local music = Instance.new("Sound");
music.SoundId = "rbxassetid://109145705737899";
music.Volume = 0;
music.PlaybackSpeed = 0.1;
music.Looped = false;
music:Play();
music.Parent = game.SoundService;

return function()
    local open = c(false);
    local actionText = c("Hello,");
    local checkboxOn = c(false);
    local sz = c("big");
    local sliderValue = c(0);
    local loudness = c(0);

    checkboxOn:subscribe(function(x)
        music.Looped = x;
    end);

    local timePosition = c(0);
    local timePositionLocked = c(false);
    timePositionLocked:subscribe(function(x)
        if x then
            music:Pause();
        else
            music.TimePosition = timePosition:get()*music.TimeLength;
            music:Resume();
        end
    end);

    game.RunService.PreRender:Connect(function(dt)
        loudness:set(
            math.clamp(math.lerp(loudness:get(), music.PlaybackLoudness/1000, dt*10)*sliderValue:get()*1.5, 0, 1)
        );

        if timePositionLocked:get() then
            return;
        end

        local a = music.TimePosition/music.TimeLength;
        timePosition:set(a);
    end);

    sliderValue:subscribe(function(x)
        music.Volume = x*4;
    end);

    return {
        Button {
            Position = UDim2.fromScale(0.2, 0.5),
            Size = UDim2.fromScale(0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Padding = UDim.new(0, 10),
            Style = "Secondary",

            Text = "Dialog + Form items",
            [wade.Event.Activated] = function()
                open:set(function(x)
                    return not x;
                end);
            end,
        },
        Dialog {
            IsOpen = open,
            TitleText = "Dialog + Form items",
            Size = sz,
            ActionText = actionText,
            CancelText = "Cancel",

            Body = {
                e "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    Padding = UDim.new(0, 5),
                },
                RadioGroup {
                    Selected = actionText,
                    Items = {
                        "Hello,",
                        "RadioGroup!",
                        "-wade/material",
                    },
                },
                Checkbox {
                    On = checkboxOn,
                    Label = "Looped",
                },
                List {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = UDim.new(0, 10),

                    Children = {
                        Label {
                            LayoutOrder = 2,
                            BackgroundTransparency = 0,
                            Text = wade.charmHook(sliderValue, function(x)
                                return `Volume: {math.floor(x*100)}%`;
                            end),
                        },
                        Slider {
                            LayoutOrder = 1,
                            Value = sliderValue,
                            Size = UDim2.new(0.5, 0, 0, 10),
                        },
                    },
                },
                List {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = UDim.new(0, 10),

                    Children = {
                        Label {
                            LayoutOrder = 2,
                            BackgroundTransparency = 0,
                            Text = wade.charmHook(timePosition, function(x)
                                return `Time Position: {math.floor(x*100)}%`;
                            end),
                        },
                        Slider {
                            LayoutOrder = 1,
                            Value = timePosition,
                            Size = UDim2.new(0.5, 0, 0, 10),

                            onSlideBegin = function()
                                timePositionLocked:set(true);
                            end,
                            onSlideEnd = function()
                                timePositionLocked:set(false);
                            end,
                        },
                    },
                },
                List {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = UDim.new(0, 10),

                    Children = {
                        Label {
                            LayoutOrder = 2,
                            BackgroundTransparency = 0,
                            Text = wade.charmHook(loudness, function(x)
                                return `Loudness: {math.floor(x*100)}%`;
                            end),
                        },
                        Slider {
                            LayoutOrder = 1,
                            Value = loudness,
                            Size = UDim2.new(0.5, 0, 0, 10),
                        },
                    },
                },
                Select {
                    TriggerProps = {
                        Position = UDim2.fromScale(0, 0),
                    },

                    Items = {"big", "medium", "small"},
                    Selected = sz,
                    TextHook = function(x)
                        return `Size: <mark color="rgb(10, 10, 10)" transparency="0.5">{x}</mark>`;
                    end,
                },
            },
        },
    };
end