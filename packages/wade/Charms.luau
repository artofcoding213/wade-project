--[[

Charms 101
A charm is like a Signal but it closes over some arbitrary value.
You may set and get this value with their respective functions.
But, you may listen to whenever the value is changed with the :subscribe() function.
This is what Wade does under the hood when you pass a charm as a value in a property list, it subscribes to it then updates the property to the new value.

A charm hook is just a wrapper around a charm where you can modify the value in any way you want, for example,
maybe you want to add a unit to say your coins so you'd do
Text = charmHook(coinsCharm, function(x) return `Coins: {x}`; end)

]]
export type Charm<T> = {
    set: (self: Charm<T>, value: T | ((prev: T) -> T)) -> (),
    get: (self: Charm<T>) -> T,

    wait: (self: Charm<T>) -> (),

    subscribe: (self: Charm<T>, f: (new: T, prev: T?) -> ()) -> { unsubscribe: () -> () },
};

--[[

Charms 101 (cnt.)
Animation charms are special to Wade. Their internal 'value' is playing animation tracks and attached instances.
The 'subscription' function is :attach(), where you subscribe the instance & a property to be subject to these animations

When you call :play() it just calls :stop() then loops through every attached instance and plays the Tween on it, inserting the track into a list for :stop(),
which just clears the tracks and stops them all.

]]
export type AnimCharm<T> = {
    play: (self: AnimCharm<T>) -> (),
    playReverse: (self: AnimCharm<T>) -> (),
    stop: (self: AnimCharm<T>) -> (),
    setAB: (self: AnimCharm<T>, a: T?, b: T?) -> (),

    wait: (self: AnimCharm<T>) -> (),

    attach: (self: AnimCharm<T>, to: Instance, prop: string) -> (),
    onAttach: (self: AnimCharm<T>, f: (to: Instance, prop: string) -> ()) -> RBXScriptConnection,
    destroy: (self: AnimCharm<T>) -> (),
    
    getCharm: (self: AnimCharm<T>) -> Charm<T>,
};

local exports = {};

function exports.charm<T>(initValue: T): Charm<T>
    local x = initValue;
    local subscriptions = {};

    return {
        __is_charm = "charm",

        set = function(self, y)
            local prev = x;

            if typeof(y) == "function" then
                x = y(x);
            else
                x = y;
            end

            for _, s in ipairs(subscriptions) do
                task.spawn(s, x, prev);
            end
        end,

        get = function(self)
            return x;
        end,

        wait = function(self)
            local a = false;
            local function f()
                a = true;
            end

            table.insert(subscriptions, f);

            while not a do
                task.wait();
            end

            table.remove(subscriptions, table.find(subscriptions, f));
        end,

        subscribe = function(self, f)
            table.insert(subscriptions, f);
            return {
                unsubscribe = function()
                    local i = table.find(subscriptions, f);
                    if typeof(i) ~= "number" then
                        return;
                    end

                    table.remove(subscriptions, i);
                end,
            };
        end,
    };
end

function exports.isCharm(x: any)
    return typeof(x) == "table" and x.__is_charm == "charm";
end

function exports.charmHook<T, T2>(closed: Charm<T>, f: (new: T, prev: T?) -> T2): Charm<T2>
    local c = exports.charm(f(closed:get(), nil));

    closed:subscribe(function(new, prev)
        c:set(f(new, prev));
    end);

    return c;
end

function exports.animCharm<T>(_a: T, _b: T, ti: TweenInfo, startAtB: boolean?, initStartAtB: boolean?)
    local tracks = {};
    local attached: {{Instance | string}} = {};
    local conns = {};

    return {
        __is_charm = "animCharm",
        a = _a,
        b = _b,

        wait = function(self)
            for _, t in ipairs(tracks) do
                t.Completed:Wait();
            end
        end,

        play = function(self)
            self:stop();

            for _, att in ipairs(attached) do
                local i = att[1];
                local k = att[2];
                local val = if startAtB then self.b else self.a;
                if val then
                    if exports.isCharm(val) then
                        val = val:get();
                    end

                    i[k] = val;
                end

                local t = game.TweenService:Create(i, ti, { [k] = self.b });
                t:Play();
                table.insert(tracks, t);
            end
        end,

        playReverse = function(self)
            local oldA, oldB = self.a, self.b;
            
            self:setAB(self.b, self.a);
            self:play();
            self:setAB(oldA, oldB);
        end,

        stop = function(self)
            for _, a in ipairs(tracks) do
                a:Pause();
            end

            table.clear(tracks);
        end,

        setAB = function(self, a, b)
            self.a = a or self.a;
            self.b = b or self.b;
        end,

        attach = function(self, to, prop)
            local sab = if initStartAtB ~= nil then initStartAtB else startAtB;
            local val = if sab then self.b else self.a;
            if val ~= nil then
                if exports.isCharm(val) then
                    val = val:get();
                end

                to[prop] = val;
            end
            
            table.insert(attached, {to, prop});

            for _, f in ipairs(conns) do
                f(to, prop);
            end
        end,

        onAttach = function(self, f)
            table.insert(conns, f);

            return {
                Disconnect = function(self)
                    local i = table.find(conns, f);
                    if not i then
                        return;
                    end 

                    table.remove(conns, i);
                end,
                disconnect = function(self)
                    self:Disconnect();
                end,
            }::RBXScriptConnection;
        end,

        destroy = function(self)
            for _, track in ipairs(tracks) do
                track:Stop();
            end

            table.clear(attached);
        end,

        getCharm = function(self)
        end,
    };
end

function exports.isAnimCharm(x: any)
    return typeof(x) == "table" and x.__is_charm == "animCharm";
end

function exports.mergeAnimCharms<T>(charms: {AnimCharm<T>}, initValue: (Charm<T> | T)?)
    return {
        __is_charm = "animCharm",

        attach = function(self, to, prop)
            if initValue then
                if exports.isCharm(initValue) then
                    initValue = (initValue::Charm<T>):get();
                end
                to[prop] = initValue;
            end

            for _, c in ipairs(charms) do
                c:attach(to, prop);
            end
        end,
    };
end

return exports;