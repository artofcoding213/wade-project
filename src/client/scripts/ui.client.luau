local wade = require(game.ReplicatedStorage.Packages.wade);
local App = require(script.Parent.Parent.App);

local pgui = game.Players.LocalPlayer:WaitForChild("PlayerGui");
wade:mount(App, pgui);