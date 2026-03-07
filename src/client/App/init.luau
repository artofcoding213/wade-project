local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;

return function()
    local children = {};

    for _, modScript in ipairs(script:GetChildren()) do
        if modScript:IsA("ModuleScript") then
            local mod = require(modScript);
            if typeof(mod) == "table" then
                if mod.render then
                    table.insert(children, mod:render());
                else
                    table.insert(children, mod);
                end
            elseif typeof(mod) == "function" then
                table.insert(children, mod());
            end
        end
    end

    return e "ScreenGui" {
        Children = children,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ScreenInsets = Enum.ScreenInsets.None,
    };
end