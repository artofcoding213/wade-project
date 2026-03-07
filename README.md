# wade-project
This project contains two libraries:\
`packages/material`: wade/material, shadcn-inspired components that look good out-of-the box.\
`packages/wade`: Wade, a React-style code-first UI framework.

In `src/` you will not find the source code to either of these libaries but an example.
You can find the example live here: https://www.roblox.com/games/110055621957540/wade-material-Programmatic-Material-UI-Demo

Sorry about this, this is actually the source code to that live game above, but I had to put the libraries in there for Rojo's sake.\
I did write the libraries from scratch, but they're nothing to write home about. Roblox with still use React, and so will developers.

# wade/material
Inspired by Shadcn, create and group premade components together to make good-looking, modern UI without any styling on your end.

# wade
Wade is similar to Roact or React-luau but with some rules:
* Mount only once. This saves on a lot of performance.\
If you want to add items you call wade:mount() manually.
* Charms should be the only way of editing properties (on top of getting a reference to the Instance).\
Animations are done with special animation charms, and you can hook to a charm to close over a charm and
edit its value before the property is updated. At the engine level this is the same as `el[prop] = newVal` compared to
calling every component, reconciling the trees, then updating `el[prop]`.
* Only elements can be passed to the Wade engine. You must call the components (unless passing App to wade:mount()) yourself.

Some notes:
* Creating elements
    Frameworks like React-luau use this syntax:\
    `lib.createElement(className, props, children)`\
    Wade chooses the cleaner alternative:\
    `wade.element(className)(props)`

    For short, you can omit parenthesis, i.e.:\
    `wade.element "<className>" { <props> }`\
    but do note that this only works if you pass a string literal and then a table.
* Special propreties
    * Children can be recursive, i.e.:
        * `Children = {foo, {bar, baz, a, b, {c, d}}}`\
        Expands to: `{foo, bar, baz, a, b, c, d}`
        * `Children = foo`\
        Expands to: `{foo}`
        * This is extremely useful if you only have 1 child, or want to mix in some external children from your props with say a UICorner
        * You can pass the `Children` property inside of an elements properties
    * You take reference to an element by charms i.e.:
        * `local c = wade.charm(nil);`
        * `Charm = c`
        * Like with `Children` you can pass the `Charm` property inside of an elements properties.\
        The charm will *only* be updated once its children have been mounted
    * Misc:
        * You can pass `InheritedProps` so the Wade engine will automatically connect events in the table to the instance, it also acts as a secondary to normal properties, if they don't exist, the inherited prop will be set on the instance.
        * You can pass `InheritedZIndex` so children inherit the ZIndex property as well as `InheritedZIndex+1`. This is extremely
        helpful for wade/material's Dialog component
* Applying multiple animation charms to an instance:
    Normally you do `Prop = animCharm`,
    but if you have multiple animation charms (i.e. hover in, hover out),
    you can merge them with the wade.mergeAnimCharms() method:\
    `Prop = wade.mergeAnimCharms{hoverIn, hoverOut}`
* The new Luau type solver is required for this, we use `type function`s for things like `wade.Event` autocompletion

## Example
A basic counter:
```luau
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local h = wade.charmHook;

local function Counter()
    local count = c(0);

    return e "TextButton" {
        Size = UDim2.fromOffset(100, 60),
        Position = UDim2.fromScale(0.5, 0.5),
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

local function App()
    return e "ScreenGui" {
        Children = Counter(),
    };
end

wade:mount(App, game.Players.LocalPlayer:WaitForChild("PlayerGui"));
```

The advantage of having to create a ScreenGui element is that we don't have to use portals to mount into things like SurfaceGuis or BillboardGuis.\
It also allows customization of the ScreenGui.

You can find some basic examples like this in `packages/material/test/`, including animation charms\
Documentation for wade can be found in `docs/`

## Why I made Wade
I made an asymmetrical survival game (or asym for short) that used my own handrolled version of react-luau. If you couldn't tell, I like handrolling libraries.\
It didn't reconcile trees or anything crazy like that, it just reconciled the instances themselves if that makes sense.\
I had a stamina bar that triggered a re-render every frame, but then there were ability cooldowns that also triggered re-renders every 0.1s.
You can probably imagine having 4 abilities on cooldown and a stamina bar updating every frame to be not the most performant.\
I tried to optimize the component hotpath by just returning nil out of some components if they weren't visible outright, but the impact was minimal.\
Then I made the terrible decision of going through the MicroProfiler hell to figure out that the `remount()` was taking 2ms every frame. It's not bad, but it's still
absolutely terrible.

If you skipped ahead to here, you should thank yourself. You probably understand that yeah, React has problems. If you didn't, you should still definitely get that.\
So how does Wade solve it? It's simple: it only mounts once.\
Then you ask: well, how do you update anything? With Charms. It's actually extremely similar to the classic Roblox UI, just ported over to code.\
Updating a charm connected to a property is the same as just doing `instance[prop] = value`. It's just more elegant, with very, very minimal performance overhead compared to React.

wade/material was just the next obvious step. I don't like building my own components in the middle of a project, and I love shadcn, so how about we recreate some of the components?\
The most challenging one by far was Select. You can't just directly put the select menu into the trigger button no, because then AutomaticSize would get messed up.
Instead, you have to make a whole new ScreenGui ontop of everything and position it under the trigger button. `items` can also be a charm that can update, not some static nonsense,
so we also have to remount the menu when `items` updates.

# Installing wade & wade/material
Assuming you're working with rojo, you can just `git clone` this entire repo, and you'll have a Rojo project that's ready to go,
including an example!\
If you don't want to work with wade/material, just delete it from the `packages/`.