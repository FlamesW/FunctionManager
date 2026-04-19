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
local TestModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/AddonTest/refs/heads/home/Test.luau"))()

--[[ >>>>[Contents inside "TestModule"]

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

* More docs soon~
