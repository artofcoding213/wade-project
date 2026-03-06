local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local h = wade.charmHook;

return function(initCount: number?)
    local count = c(initCount or 0);

    return (e "TextButton") {
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(100, 60),

        Text = h(count, function(x)
            return `Count: {x}`;
        end),

        [wade.Event.Activated] = function()
            count:set(function(x)
                return x+1;
            end);
        end,
    };
end