# Example Usage:

* Simple Rejoin:

```lua
local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/FunctionManager/refs/heads/home/Module.luau"))();
local CallThisWhatever = Class.Launch({});

CallThisWhatever:Rejoin(); -- // Rejoins
```
-------------------------------------------------------------------------------------------------------------------------------------

* Merge Functions:

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

* Log Github Commits (No api or ratelimit)

```lua
local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/FunctionManager/refs/heads/home/Module.luau"))();
local FunctionModule = Class.Launch({});

local Commit = FunctionModule:LogCommit("https://github.com/FlamesW/FunctionManager",
    "home", --> Branch
    1 --> Version (1 = latest commit)
);

if Commit then
    print("Author:", Commit.Author)
    print("Message:", Commit.Message)
    print("Sha:", Commit.Sha)
    print("Time Ago:", Commit.TimeAgo)
end
```

-------------------------------------------------------------------------------------------------------------------------------------

* Auth Verification:

```lua
local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/FunctionManager/refs/heads/home/Module.luau"))();
local FunctionModule = Class.Launch({});

local Success, Auth, Result = FunctionModule:Verify({
    Url = "https://pastebin.com/raw/your_whitelist_id", --> Supports links in almost any format doesnt matter.
    Hwids = {123456789, "Roblox_Username", 67, "Executor_Hwid", 0987654321, "Roblox_Hwid"}, --> Supports Both RobloxHwids, ExecutorHwids, User Ids, Roblox Usernames
})

if Success then
    print("Verified! Type: " .. Auth .. ", Result: " .. tostring(Result))
    -- ..Continue with your script
else
    warn("Verification failed...")
end

--[[ Recommended format for Urls:
{
  "Premium_User1": {
    "auth": ["Roblox_Hwid", "Executor_Hwid, "6767676767"],
  },
  "Beta_Tester2": {
    "auth": ["46363462134", "235235547325"],
  }
}
--]]
```

-------------------------------------------------------------------------------------------------------------------------------------

* Aimbot (Simple) *Subject to change

```lua
local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/FunctionManager/refs/heads/home/Module.luau"))();
local FunctionModule = Class.Launch({});

local Aimbot = FunctionModule:Aimbot({
    AimMethod = "Camera",
    Smoothness = 0.3,
    FOVRadius = 200,
    StickyRadius = 300,
    AutoStart = false,
    Flags = {
        StickyAim = true,
    },
})

FunctionModule:BindKeybind(Enum.KeyCode.V, function() --> Keybind is "V"
    if Aimbot:IsEnabled() then
        Aimbot:Stop()
        print("🔴 Aimbot OFF")
    else
        Aimbot:Start()
        print("🟢 Aimbot ON")
    end
end, "AimbotToggle")
```

* Flag:

```lua
if FunctionManager_Engine then --> Checks if function manager is loaded
   print("Function Manager");
end
```

* More docs soon~
