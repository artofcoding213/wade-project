local wade = require(game.ReplicatedStorage.Packages.wade);
local Material = require(game.ReplicatedStorage.Packages.material);

local Sonner = require(game.ReplicatedStorage.Packages.material.Sonner);

return {
    toastC = wade.charm(),
    toast = function(self, title: string, props: Sonner.ToastProps)
        self.toastC:get()(title, props);
    end,

    render = function(self)
        return Sonner {
            Position = UDim2.fromScale(0.5, 0),

            toastFn = self.toastC,
        };
    end,
};