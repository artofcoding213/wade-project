local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local h = wade.charmHook;
local a = wade.animCharm;

local Material = _G["_Material"]::any;

type p<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type Props = {[number]: (...any) -> ()} & {
    Position: p<UDim2>;

    Selected: p<string>;
    Items: p<{string}>;

    Padding: p<UDim>;
};

return function(props: Props)
    local selected: wade.Charm<string>;
    if props.Selected and Charms.isCharm(props.Selected) then
        selected = props.Selected;
    else
        local items = props.Items or {};
        if Charms.isCharm(items) then
            items = items:get();
        end

        selected = c(items[1] or "?");
    end

    local def = selected:get();

    local containerCharm = c(nil);
    local function RadioButtons()
        local container = containerCharm:get();
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy();
            end
        end

        local items = props.Items or {};
        if Charms.isCharm(items) then
            items:subscribe(function()
                RadioButtons();
            end);

            items = items:get();
        end

        wade:mount(function()
            local children = {};

            for i, item in ipairs(items) do
                local ti = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);
                local startAtB = selected:get() == item;
                local innerSize = a(UDim2.fromOffset(0, 0), UDim2.fromOffset(8, 8), ti, nil, startAtB);
                selected:subscribe(function(x, prev)
                    if x == item then
                        innerSize:play();
                    elseif prev == item then
                        innerSize:playReverse();
                    end
                end);

                table.insert(children, e "TextButton" {
                    Size = UDim2.fromScale(0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,

                    LayoutOrder = i,
                    Children = {
                        e "UIListLayout" {
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            FillDirection = Enum.FillDirection.Horizontal,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0, 8),
                        },

                        e "Frame" {
                            Size = UDim2.fromOffset(16, 16),
                            BackgroundColor3 = Color3.new(1, 1, 1),
                            BackgroundTransparency = h(selected, function(x)
                                return x == item and 0 or 0.9;
                            end),
                            
                            Children = {
                                e "UICorner" {
                                    CornerRadius = UDim.new(1, 0),
                                },
                                e "Frame" {
                                    Size = innerSize,
                                    Position = UDim2.fromScale(0.5, 0.5),
                                    AnchorPoint = Vector2.new(0.5, 0.5),

                                    BackgroundColor3 = Color3.new(0, 0, 0),
                                    Children = e "UICorner" {
                                        CornerRadius = UDim.new(1, 0),
                                    },
                                },
                            },
                        },

                        e "TextLabel" {
                            Size = UDim2.fromScale(0, 0),
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundTransparency = 1,

                            LayoutOrder = 1,
                            Text = item,
                            TextColor3 = Color3.new(0.9, 0.9, 0.9),
                            TextSize = 16,
                            FontFace = wade.charmHook(selected, function(x)
                                return Material.Font(if (item == def and x ~= def) then Enum.FontWeight.Bold else nil);
                            end),
                        },
                    },

                    [wade.Event.Activated] = function()
                        selected:set(item);
                    end,
                });
            end

            return children;
        end, container);
    end

    containerCharm:subscribe(RadioButtons);

    return e "Frame" {
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(0, 0),

        BackgroundTransparency = 1,
        Children = e "UIListLayout" {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = props.Padding or UDim.new(0, 5),
        },

        Charm = containerCharm,
    };
end