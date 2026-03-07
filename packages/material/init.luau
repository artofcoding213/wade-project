local wade = require(game.ReplicatedStorage.Packages.wade);
local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);

-- these are expanded in the files :)
export type Prop<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type Props<T> = {[number]: (...any) -> ()} & T;

local lib = {};

export type ButtonStyle = "Primary" | "Secondary" | "Danger" | "Success";
function lib.ButtonColor(x: ButtonStyle): Color3
    return ({
        ["Primary"] = Color3.new(0.9, 0.9, 0.9),
        ["Secondary"] = Color3.new(0.4, 0.4, 0.4),
        ["Danger"] = Color3.new(0.8, 0.3, 0.3),
        ["Success"] = Color3.new(0.08, 0.8, 0.3),
    })[x];
end

function lib.TextColor(x: "Primary" | "Secondary"): Color3
    return ({
        ["Primary"] = Color3.new(0.1, 0.1, 0.1),
        ["Secondary"] = Color3.new(0.8, 0.8, 0.8),
    })[x];
end

function lib.Font(weight: Enum.FontWeight?, style: Enum.FontStyle?)
    return Font.new("rbxassetid://11598121416", weight or Enum.FontWeight.Regular, style or Enum.FontStyle.Normal);
end

function lib.Lighten(c: Prop<Color3>, by: number): Color3
    if Charms.isCharm(c) then
        return wade.charmHook(c, function(col)
            return lib.Lighten(col, by);
        end);
    end

    assert(typeof(c) == "Color3");
    return Color3.new(math.clamp(c.R+by, 0, 1), math.clamp(c.G+by, 0, 1), math.clamp(c.B+by, 0, 1));
end

function lib.NumSeq(kpoints: {{number}}): NumberSequence
    local xs = {};

    for _, kp in ipairs(kpoints) do
        table.insert(xs, NumberSequenceKeypoint.new(kp[1], kp[2]));
    end

    return NumberSequence.new(xs);
end

function lib.ColSeq(kpoints: {{Color3 | number}}): ColorSequence
    local xs = {};

    for _, kp in ipairs(kpoints) do
        table.insert(xs, ColorSequenceKeypoint.new(kp[1], kp[2]));
    end

    return ColorSequence.new(xs);
end

function lib.Extract<T>(p: Prop<T>, def: T): T
    if Charms.isCharm(p) then
        return (p::wade.Charm<T>):get();
    elseif Charms.isAnimCharm(p) then
        return def;
    end

    return (p::T?) or def;
end

export type T = typeof(lib) & {
    Avatar: typeof(require(script.Avatar)),
    Button: typeof(require(script.Button)),
    Checkbox: typeof(require(script.Checkbox)),
    Dialog: typeof(require(script.Dialog)),
    HoverCard: typeof(require(script.HoverCard)),
    Input: typeof(require(script.Input)),
    Label: typeof(require(script.Label)),
    List: typeof(require(script.List)),
    RadioGroup: typeof(require(script.RadioGroup)),
    ScrollArea: typeof(require(script.ScrollArea)),
    Select: typeof(require(script.Select)),
    Slider: typeof(require(script.Slider)),
    Sonner: typeof(require(script.Sonner)),
};

local out = setmetatable({}, {
    __index = function(_, i)
        if lib[i] then
            return lib[i]
        end

        return require(script:FindFirstChild(i));
    end,
}) :: T;
_G._Material = out;

return (out::any) :: T;
