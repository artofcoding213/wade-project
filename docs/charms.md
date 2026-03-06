# charms
A charm is like a signal. You can `:subscribe()` to it and listen for whenever you `:set()` to it.\
It's that simple.

Here's an example (there is no prompt() function in Luau):
```luau
local name = charm("No name provided yet.");

name:subscribe(function(x)
    print(`Your name is: {x}!`);
end);

task.spawn(function()
    name:set(prompt("What's your name?"));
end);
```
How does it work?\
Well, once you provide the user input, we call `:set()`.\
This internally sets the charms value to the input you provided.\
Then, it calls our `:subscribe()` function with the new value.\
We get our user input printed to the console!

# charm hooks
Take this example:\
You have a charm describing a player's coins. You want to display it to a text label like:\
`{x} coins`\
How would you do it?

Well, the correct answer would be charm hooks! I'm not sure what other people call it, maybe 'derive' would be a better name.\
Anyways, here's the syntax for it:
```luau
labelText = charmHook(coins, function(x)
    return `{x} coins`;
end);
```
Yeah, it's pretty simple. So simple in fact, we can break down its source code!
```luau
function exports.charmHook<T, T2>(closed: Charm<T>, f: (new: T, prev: T?) -> T2): Charm<T2>
    local c = exports.charm(f(closed:get(), nil));
```
First, we create a new charm. We call our hook function (`f`) on the current value of our closed over charm.\
This is to ensure, say in our example, we dont get back the number the first time we call charmHook(), but instead we get `{coins:get()} coins`.
```luau
    closed:subscribe(function(new, prev)
        c:set(f(new, prev));
    end);
```
Alright, now we subscribe to whenever our closed over charm is changed. We get the new value, and the previous value.\
This is the meat and potatoes of the charm hook. We `:set()` to `c` with the hook function (`f`) called on the new value.
```luau
return c;
```
We return our new charm. That's it!

# animation charms
Say we want to make a button's `BackgroundColor` to get lighter when we hover, and go back to normal when we unhover. We do this with animation charms!\
Here is the type definition:
```luau
function exports.animCharm<T>(_a: T, _b: T, ti: TweenInfo, startAtB: boolean?, initStartAtB: boolean?): AnimCharm<T>
```
Wow. That's a mouthful. We can start by eliminating the other parameters, those are self-explanatory, and are not used.\
Let's break it down:
* `_a`: This is the initial state of the animation. Once a property gets the charm, it will be set to this value.
* `_b`: This is the destination, or where the animation will end.
* `ti`: The `TweenInfo` object passed to `TweenService:Create()`. Describes how the animation plays.

And the type definition for `AnimCharm<T>`:
```luau
type AnimCharm<T> = {
    play: (self: AnimCharm<T>) -> (),
    playReverse: (self: AnimCharm<T>) -> (),
    stop: (self: AnimCharm<T>) -> (),
    setAB: (self: AnimCharm<T>, a: T?, b: T?) -> (),

    attach: (self: AnimCharm<T>, to: Instance, prop: string) -> (),
    destroy: (self: AnimCharm<T>) -> (),
    
    getCharm: (self: AnimCharm<T>) -> Charm<T>,
};
```
Let's go through every function:
* `:play()`: Plays the animation on all attached instances, but calls `:stop()` before doing so.
* `:playReverse()`: Yeah... I can't figure this one out either. Takes a PHD to learn this one, sorry.
* `:stop()`: Halts all playing tracks created by `:play()` and clears the tween track array.
* `:setAB(a?, b?)`: Updates the `_a` & `_b` parameters we initially gave the animation charm. Used by `:stop()` to flip & unflip `a` & `b` to play in reverse.
* `:attach(to, prop)`: Attaches the animation to the given instance. The Wade engine calls this for you if you provide the anim charm to a property.\
It adds the instance and property name to an array of them. When `:play()` is called, it will call `TweenService:Create(to, [ti], { [prop] = b })` on every attached
instance.
* `:destroy()`: Unattaches all instances and calls `:stop()`.
* `:getCharm()`: Returns a charm that calls `:set()` every time the animation changes a property.

Yeah... pretty simple. Here's the code for what we wanted to do:
```luau
local ti = TweenInfo.new(1);
local a = animCharm(Color3.new(0.5, 0.5, 0.5), Color3.new(1, 1, 1), ti);

local function onHover()
    a:play();
end

local function onUnhover()
    a:playReverse();
end

local function Button()
    return wade.element "TextButton" {
        BackgroundColor3 = a, -- Once the element is mounted, a:attach(TextButton, "BackgroundColor3") will be called
        [wade.Event.Hover] = onHover,
        [wade.Event.Unhover] = onUnhover,
    };
end

-- ... wade:mount() stuff ...
```