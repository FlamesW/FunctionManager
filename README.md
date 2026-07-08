##Function Manager
is a powerful developer tool packed with a wide range of ready-to-use functions, including :Flight, :XRay, :Noclip, and more. Every function is fully optimized for peak runtime performance, delivering ultimate clarity and efficiency to your code.

[See changelogs](https://github.com/FlamesW/FunctionManager/releases)

# Example Usage:

* Simple Rejoin:

```lua
-- >> @Prevents auto reloading
if typeof(_IsLoadedFM) == "function" and _IsLoadedFM() then
    warn("@Function Manager.luau is already running")
    return
end

local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local CallThisWhatever = Class.Launch({});

CallThisWhatever:Rejoin() -- // Rejoins
```
-------------------------------------------------------------------------------------------------------------------------------------

* Spectate:

```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local CallThisWhatever = Class.Launch({});

CallThisWhatever:Spectate("closestnpc") -- // args (random, closestnpc, nearest, farthest, bacons, furries, friends , nonfriends, names / displays (shortened))
-- // can also accept instances :Spectate(workspace.Carl)
```

-------------------------------------------------------------------------------------------------------------------------------------

* Fling:

```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local CallThisWhatever = Class.Launch({});

CallThisWhatever:Fling("random") -- // args (random, closestnpc, nearest, farthest, bacons, furries, friends , nonfriends, names / displays (shortened))
-- // can also accept instances :Fling(workspace.Carl)
```

-------------------------------------------------------------------------------------------------------------------------------------

* Spoofing

#### Requires hooking

```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local FunctionModule = Class.Launch({});

local LPlayer = FunctionModule.LocalPlayer

FunctionModule:Spoof(LPlayer, "Name", "FakeUsername")
print(LPlayer.Name) -- // Prints "FakeUsername".
task.wait(1)

FunctionModule:Unspoof(LPlayer, "Name")
print(LPlayer.Name) -- // Prints the real name.
```

-------------------------------------------------------------------------------------------------------------------------------------

* Auto Translation:
#### You can also lookup language codes on https://developers.google.com/workspace/admin/directory/v1/languages
```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local FunctionModule = Class.Launch({});

-- // @Spanish -> The fast brown fox jumps over the lazy dog
local Translated, DetectedCode, Original, OriginalCode = FunctionModule:Translate("El rápido zorro marrón salta sobre el perro perezoso", "auto")

print("Original Language: " .. Original)
print("Original Code: " .. OriginalCode)

print("Detected code: " .. DetectedCode)
print("Translated: " .. Translated)
```

-------------------------------------------------------------------------------------------------------------------------------------

* Queue Teleport:

```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local FunctionModule = Class.Launch({});

FunctionModule:QueueOnTeleport("Test", true, " repeat task.wait(0.2) until game:IsLoaded() print('hi')", {
    OnStart = function(Script)
        print("✅ Test has been queued for teleport!")
    end,
    OnFailed = function()
        warn("❌ Teleport failed!")
    end,
})

task.wait(1)
-- FunctionModule:SetQueue("Test", false)

FunctionModule:ToPlace(67)
```

-------------------------------------------------------------------------------------------------------------------------------------

* Convert Wordings:

```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local FunctionModule = Class.Launch({});

print(FunctionModule:Uwuify("hello my friends"))
print(FunctionModule:Nerdify("hello my friends")) -- // *Wrapped with autocorrect 👍

warn("====================================================================================")

local StoryTime = [[
so okay. this happened two weeks ago. i have been running diagnostics on it ever since. you know how in RPGs there is that one quest that seems simple talk to the blacksmith but then it triggers a three hour side plot involving goblin diplomacy and a stolen chicken? that was my tuesday.

i work in data validation. boring right? but i love it. spreadsheets do not gaslight you. anyway my boss let us call him kevin announces a team building exercise. my amygdala instantly starts screaming. kevin says we are doing an escape room.

cue my internal monologue. finally. my years of point and click adventure games and watching the crystal maze on youtube are about to pay off.

we get there. my team picks the egyptian tomb room. there is a fake sarcophagus some hieroglyphs and a heavy ankh shaped key on a pedestal. the game master locks us in. the timer starts 60 minutes.

my coworkers? they start panicking. they are yanking books off shelves randomly. one guy tries to pry the sarcophagus open with his car keys. another woman starts a rumor that the carpet is a pressure plate. chaos. no system.

so i go quiet. i start mapping the room in my head like it is a zelda dungeon. three chests one locked door five visible symbols. the ankh key is too obvious clearly a trap. i notice the hieroglyphs repeat in a pattern bird squiggly line eye bird. that is not decoration. that is a cipher key.

i whisper to my coworker do not touch the ankh. it is a decoy. the real trigger is matching those symbols to the drawer locks.

she stares at me like i just spoke klingon. which for the record i can also do. but not the point.

so i decode the sequence. bird equals ra. squiggly equals water. eye equals watch or see. combined they spell ra water see or rawatsee. wait no. reverse it. see water ra. c water ra. c 3po? no. see water ra. sea water ra. seawater ra. sewer rat?

i freeze. oh no. it is a pun. the puzzle is a pun. my nemesis.

i look at the ankh key. then at a small drain grate in the corner nobody noticed. i get on my hands and knees pop the grate open with a butter knife someone left in a vase because who leaves cutlery in a vase? and there it is. a magnetic key card stuck to the inside of the pipe.

the room solved itself after that. we escaped with 12 minutes left. kevin gave me a high five. everyone said i was surprisingly useful.

but here is the thing. on the drive home i realized the whole room was designed to punish brute force and reward pattern recognition. that escape room? it was not a game. it was a personality test.

and i passed. but now i am wondering if real life is just a series of escape rooms with worse lighting and no game master to reset you when you fail… am i still playing or is it playing me?

anyway that is why i am building a spreadsheet to model every possible conversation i might have at the office holiday party. want to help me beta test the small talk decision tree?
]]

print(FunctionModule:AutoCorrect(StoryTime))
```

-------------------------------------------------------------------------------------------------------------------------------------


* Merge Functions:

```lua
local FunctionModule = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))()
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
:Merge(TestModule):Merge({ 
    Superman = function(self)
        self:Flight(true, 70)
    end,
	WhyAreYouHere = function()
	    print("no")
	end,
	Rejoin = function()
	    print("cant overwrite")
	end,
    KYS = function(self)
        self:Unload()
    end,
})

Utility:WhyAreYouHere() --> Func will call testmodule's function because whatever set first gets prioritized.
task.wait(2)

Utility:Superman() --> Custom func to fly

task.wait(2)
Utility:KYS() --> Custom func to unload

task.wait(1)
Utility:Rejoin() -- // Rejoins and ignores overwroted functions, FunctionModule always wins.
```
-------------------------------------------------------------------------------------------------------------------------------------

* Log Github Commits (No api or ratelimit)

```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
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
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
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

* Sound Manager

```lua
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))();
local FunctionModule = Class.Launch({});

FunctionModule:SoundsAssets({
    ["Sans"] = 140692796870442,
})

FunctionModule:PlaySound("Sans", {OnEnded = function() print("Sound Ended.") end})
```

-------------------------------------------------------------------------------------------------------------------------------------

* Flag:

```lua
if typeof(_IsLoadedFM) == "function" and _IsLoadedFM() then
    warn("@Function Manager.luau is already running")
    return
end
```

* More docs soon~
