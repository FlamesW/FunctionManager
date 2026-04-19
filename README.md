# Example Usage:

* Simple Rejoin:

```lua
local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/FunctionManager/refs/heads/home/Module.luau"))();
local CallThisWhatever = Class.Launch({});

CallThisWhatever:Rejoin(); -- // Rejoins
```
-------------------------------------------------------------------------------------------------------------------------------------

* Merges:

```lua
local FunctionModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/FunctionManager/home/Module.luau"))()
local TestModule = loadstring(game:HttpGet("https://pastefy.app/gYqC5OUA/raw"))()

--[[
local Test = {}

function Test:WhyAreYouHere()
   print("TestYip");
end

function Test:Rejoin()
    print("Did you just get overwrote?");
end

return Test
]]

local Utility = FunctionModule.Launch({})
:Merge(TestModule) --> @Merge

Utility:WhyAreYouHere() --> Func
task.wait(2)
Utility:Rejoin() -- // Rejoins and ignores overwroted functions, FunctionModule always wins.
```

-------------------------------------------------------------------------------------------------------------------------------------

* Flag:

```lua
if FunctionManager_Engine then --> Checks if function manager is loaded
   print("Function Manager");
end
```

* More docs soon~
