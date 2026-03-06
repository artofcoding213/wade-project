local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local a = wade.animCharm;

return function()
    local colorEffect = a(Color3.new(1, 1, 1), Color3.new(1, 1, 1),
        TweenInfo.new(1));
    local scaleUpEffect = a(1.3, 1,
        TweenInfo.new(0.3), nil, true);
    local scaleDownEffect = a(0.7, 1,
        TweenInfo.new(0.3), nil, true);

    return e "TextButton" {
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(100, 60),

        Text = `{math.random(1, 100)}`, -- this number should never change because we never re-mount!
        BackgroundColor3 = colorEffect,
        AutoButtonColor = false,

        [wade.Event.Activated] = function(_, clickCount)
            scaleUpEffect:play();
            if clickCount == 1 then
                colorEffect:setAB(nil, Color3.new(1, 1, 1));
            end

            colorEffect:setAB(Color3.new(math.random(), math.random(), math.random()));
            colorEffect:play();
        end,

        [wade.Event.MouseButton2Down] = function()
            scaleDownEffect:play();

            colorEffect:setAB(nil, Color3.new(math.random(), math.random(), math.random()));
            colorEffect:play();
        end,

        Children = {
            e "UIScale" {
                Scale = wade.mergeAnimCharms({ scaleUpEffect, scaleDownEffect }),
            },
        },
    };
end