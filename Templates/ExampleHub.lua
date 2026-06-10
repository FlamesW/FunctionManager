getgenv().Keybind = Enum.KeyCode.V

-- // @Instance Manager
local global, Game = (shared or (getgenv and getgenv()) or _G) :: any, game;
if global._Instance then 
    return
end

global._Instance = true;

-- // @Interface Settings
local __Version, __Project, __Game, __Logo = "1.01", "Example Hub ", "Example Game", "rbxassetid://18555199523";
if not (Game:IsLoaded()) then
    Game.Loaded:Wait();
end

-- // @Performance Variables
local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local type, typeof, pcall, tick, tonumber, match, warn, print, unpack, next, loadstring, setmetatable =
    type, typeof, pcall, tick, tonumber, match, warn, print, unpack, next, loadstring, setmetatable

local math_floor, math_random, math_clamp, math_max, math_min, math_sqrt, math_rad, math_huge =
    math.floor, math.random, math.clamp, math.max, math.min, math.sqrt, math.rad, math.huge

local string_format, string_sub, string_match, string_gsub, string_gmatch, string_lower =
    string.format, string.sub, string.match, string.gsub, string.gmatch, string.lower

local table_insert, table_clear, table_sort, table_remove, table_create, table_concat =
    table.insert, table.clear, table.sort, table.remove, table.create, table.concat

local task_wait, task_spawn, task_cancel, task_delay = task.wait, task.spawn, task.cancel, task.delay
local os_clock, os_time, os_date = os.clock, os.time, os.date
local pairs, ipairs = pairs, ipairs

local Vector3_new, Vector2_new, Vector3_zero, UDim2_fromOffset, Color3_fromRGB, Color3_fromHSV, CFrame_lookAt, CFrame_new, CFrame_Angles, Instance_new =
    Vector3.new, Vector2.new, Vector3.zero, UDim2.fromOffset, Color3.fromRGB, Color3.fromHSV, CFrame.lookAt, CFrame.new, CFrame.Angles, Instance.new

local write_file, read_file, is_file, make_folder, is_folder, del_folder, del_file, list_files =
    writefile, readfile, isfile, makefolder, isfolder, delfolder, delfile, listfiles

-- // @Asset Manager
local Assets = {
    ["Module.luau"] = "https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau",
    ["Modal.UI"] = "https://github.com/lxte/Modal/releases/latest/download/main.lua",
}

local function Notify(Description, Options)
    Options = Options or {}

    local Title = Options.Title or __Project
    local Duration = Options.Duration or 15
    local Type = Options.Type or "Info"

    local function Send_Message()
        if Window and Window.Notify then
            Window:Notify({Title = Title, Description = Description, Duration = Duration, Type = Type})
        end
    end

    if Window and Window.Notify then
        Send_Message()
    else
        task_spawn(function()
            while not (Window and Window.Notify) do
                task_wait(0.1)
            end
            Send_Message()
        end)
    end
end

local function LoadFile(luau, State)
    local Source = Assets[luau]
    if (Source == nil) then
        return Game:Shutdown()
    end

    if State == true then
        local Content = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
        return loadstring(Content)()
    end

    if not is_folder("@File_Caches") then 
        make_folder("@File_Caches") 
    end
    
    local File = "@File_Caches/" .. luau

    if is_file(File) then
        local Success, Content = pcall(read_file, File)
        if Success and Content then
            if luau == "Module.luau" then
                local Current_Version = Content:match('Build%s*=%s*"@([%d%.]+)"')
    
                local Repo = "https://raw.githubusercontent.com/FlamesW/FunctionManager"
                local GotVersion, Response = pcall(function()
                    return Game:HttpGet(Repo .. "/home/%40Version.cfg" .. "?nocache=" .. tostring(os_clock()))
                end)

                local Latest_Version = nil
                if GotVersion and Response then
                    Latest_Version = Response:match("@([%d%.]+)")
                end

                if Latest_Version and Current_Version and Latest_Version ~= Current_Version then
                    local FreshContent = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
                    pcall(write_file, File, FreshContent)

                    Notify("Module updated -> @" .. Latest_Version)
                    return loadstring(FreshContent)()
                else
                    return loadstring(Content)()
                end
            else
                task_spawn(function()
                    local Client_Check = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
                    if Client_Check ~= Content then
                        pcall(write_file, File, Client_Check)
                        Notify(luau .. " got updated!")
                    end
                end)
                return loadstring(Content)()
            end
        end
    end

    local Content = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
    pcall(write_file, File, Content)

    return loadstring(Content)()
end

-- // @Module.Luau
local Function_Manager = LoadFile("Module.luau", false)
local Script = Function_Manager.Launch({})

-- // @Modal.UI
local Modal = LoadFile("Modal.UI", false)

local Window = Modal:CreateWindow({
    Title = __Project .. __Version,
    SubTitle = __Game,
    Size = UDim2_fromOffset(400, 400),
    MinimumSize = Vector2_new(250, 200),
    Transparency = 0,
    Icon = __Logo,
})

getgenv().Window = Window

-- // @Keybind Listener
local Keybind_Connection = Script.UserInputService.InputBegan:Connect(function(Input, Game_Processed)
    if Game_Processed then return end

    if Input.KeyCode == (getgenv().Keybind or Enum.KeyCode.V) then
        local __Instance = Script:FindCore("_Window")
        local Core_Button = __Instance and __Instance.Parent:FindFirstChild("TextButton")
        local Pos = Core_Button and Core_Button.Position

        if Pos and (Pos.Y.Offset == -50 or Pos.Y.Offset == -49) and Pos.X.Scale == 0.5 and Pos.X.Offset == 0 then
            __Instance.Visible = not __Instance.Visible
            Notify(__Instance.Visible and "Hi!" or "Bye!", {Duration = 1, Type = "Success"})
        end
    end
end)

Window:SetTheme("Midnight")

-- // @Info Tab
local Info = Window:AddTab("Info")

Info:New("Title")({
    Title = "Player Information",
})

local FriendsList = Script:GetFriends()
Info:New("Title")({
    Title = "Total Friends: " .. #FriendsList,
})

Info:New("Title")({
    Title = "Device: " .. Script:GetDevice().Name,
})

Info:New("Title")({
    Title = "Country: " .. (function()
        local Code, Country = Script:GetCountry()
        return Country or "Unknown"
    end)(),
})

Info:New("Title")({
    Title = "Ping: " .. Script:GetPing() .. " ms",
})

Info:New("Title")({
    Title = "FPS: " .. Script:GetFps(),
})

Info:New("Title")({
    Title = "Movement Statistics",
})

Info:New("Title")({
    Title = "Speed: " .. (function()
        local speed = Script:CalculateSpeed("KPH", 1)
        return speed .. " KPH"
    end)(),
})

Info:New("Title")({
    Title = "Velocity: " .. (function()
        local vel = Script:GetVelocity()
        return string_format("X: %.1f, Y: %.1f, Z: %.1f", vel.X, vel.Y, vel.Z)
    end)(),
})

Info:New("Title")({
    Title = "Magnitude: " .. (function()
        return string_format("%.1f", Script:GetVelocity().Magnitude)
    end)(),
})

Info:New("Button")({
    Title = "Teleport fakeout",
    Description = "Go to coordinates (0, 500, 0)",
    Callback = function()
        Script:Fakeout(CFrame.new(0, 500, 0), 1)
        Notify("Teleported!", {Duration = 1, Type = "Success"})
    end,
})

Info:New("Button")({
    Title = "Reset Character",
    Description = "Force respawn",
    Callback = function()
        Script:ForceReset()
        Notify("Resetting character...", {Duration = 1, Type = "Info"})
    end,
})

Info:New("Slider")({
    Title = "UI Transparency",
    Description = "Change the transparency of the UI",
    Default = 0,
    Minimum = 0,
    Maximum = 0.8,
    DecimalCount = 2,
    Callback = function(Amount)
        Window:SetTransparency(Amount)
    end,
})

-- // @Farming Tab
local Farming = Window:AddTab("Farming")

Farming:New("Title")({
    Title = "Server Features",
})

Farming:New("Slider")({
    Title = "Walk Speed",
    Default = 16,
    Minimum = 16,
    Maximum = 500,
    Callback = function(Value)
        Script:SetSpeed(Value)
    end,
})

Farming:New("Slider")({
    Title = "Jump Power",
    Default = 50,
    Minimum = 50,
    Maximum = 500,
    Callback = function(Value)
        Script:SetJumpPower(Value)
    end,
})

Farming:New("Button")({
    Title = "Rejoin Game",
    Description = "Rejoin the same server",
    Callback = function()
        Script:Rejoin()
    end,
})

Farming:New("Button")({
    Title = "Rejoin + Respawn",
    Description = "Rejoin the same server + respawns",
    Callback = function()
        Script:RejoinRe()
    end,
})

Farming:New("Button")({
    Title = "Server Hop (Low Players)",
    Description = "Find server with few players",
    Callback = function()
        Script:ServerHop({Mode = "low", MaxRetries = 3})
    end,
})

Farming:New("Button")({
    Title = "Server Hop (High Players)",
    Description = "Find server with many players",
    Callback = function()
        Script:ServerHop({Mode = "high", MaxRetries = 3})
    end,
})

Farming:New("Button")({
    Title = "Server Hop (Random)",
    Description = "Find random server",
    Callback = function()
        Script:ServerHop({Mode = "random", MaxRetries = 3})
    end,
})

Farming:New("Title")({
    Title = "Movement Features",
})

Farming:New("Toggle")({
    Title = "Flight",
    Description = "Enables flight mode (WASD to move, Space/Control up/down)",
    Callback = function(Value)
        Script:Flight(Value, 70)
    end,
})


Farming:New("Toggle")({
    Title = "Infinite Jump",
    Description = "Jump infinitely",
    Callback = function(Value)
        Script:InfiniteJump(Value)
    end,
})

Farming:New("Slider")({
    Title = "Walk Speed",
    Description = "Adjust walking speed",
    Default = 16,
    Minimum = 16,
    Maximum = 250,
    DecimalCount = 0,
    Callback = function(Value)
        Script:SetSpeed(Value)
    end,
})

Farming:New("Slider")({
    Title = "Jump Power",
    Description = "Adjust jump height",
    Default = 50,
    Minimum = 50,
    Maximum = 200,
    DecimalCount = 0,
    Callback = function(Value)
        Script:SetJumpPower(Value)
    end,
})

Farming:New("Title")({
    Title = "Combat Features",
})

Farming:New("Button")({
    Title = "Fling Nearest",
    Description = "Flings nearest person",
    Callback = function()
        local Success, Name = Script:Fling("nearest")
        Notify(Success and "Flung: " .. Name or "No player found!", {Duration = 2, Type = Success and "Success" or "Error"})
    end,
})

Farming:New("Button")({
    Title = "Fling Random",
    Description = "Flings random person",
    Callback = function()
        local Success, Name = Script:Fling("random")
        Notify(Success and "Flung: " .. Name or "No player found!", {Duration = 2, Type = Success and "Success" or "Error"})
    end,
})

-- // @Visuals Tab
local Visuals = Window:AddTab("Visuals")

Visuals:New("Title")({
    Title = "Camera Settings",
})

Visuals:New("Slider")({
    Title = "Camera Zoom Distance",
    Description = "Max camera zoom distance",
    Default = 50,
    Minimum = 10,
    Maximum = 500,
    DecimalCount = 0,
    Callback = function(Value)
        Script:Zoom(Value)
    end,
})

Visuals:New("Dropdown")({
    Title = "Camera Occlusion",
    Description = "How camera handles walls",
    Options = {"Off", "Zoom", "Invisicam"},
    Callback = function(Value)
        Script:SetCameraOcclusion(Value)
    end,
})

Visuals:New("Slider")({
    Title = "Field of View",
    Description = "Adjust camera FOV",
    Default = 70,
    Minimum = 70,
    Maximum = 120,
    DecimalCount = 0,
    Callback = function(Value)
        Script:SetFOV(Value)
    end,
})

Visuals:New("Toggle")({
    Title = "Third Person",
    Description = "Toggle third person camera",
    Callback = function(Value)
        Script:ThirdPerson(Value)
    end,
})

Visuals:New("Toggle")({
    Title = "X-Ray",
    Description = "See through walls",
    Callback = function(Value)
        Script:XRay(Value)
    end,
})

Visuals:New("Title")({
    Title = "World Effects",
})

Visuals:New("Slider")({
    Title = "Gravity",
    Description = "Change server gravity",
    Default = 196.2,
    Minimum = 0,
    Maximum = 300,
    DecimalCount = 1,
    Callback = function(Value)
        Script:SetGravity(Value)
    end,
})

Visuals:New("Slider")({
    Title = "Time of Day",
    Description = "Change lighting time",
    Default = 14,
    Minimum = 0,
    Maximum = 24,
    DecimalCount = 1,
    Callback = function(Value)
        Script:SetTime(Value)
    end,
})

Visuals:New("Title")({
    Title = "Movement Bypasses",
})

Visuals:New("Toggle")({
    Title = "Bypass WalkSpeed",
    Description = "Custom walkspeed bypass (more stable)",
    Callback = function(Value)
        if Value then
            Script:BypassWS(true, 50)
        else
            Script:BypassWS(false)
        end
    end,
})

Visuals:New("Slider")({
    Title = "Bypass WalkSpeed Speed",
    Description = "Speed for bypass walkspeed",
    Default = 50,
    Minimum = 10,
    Maximum = 200,
    DecimalCount = 0,
    Callback = function(Value)
        Script:SetBypassedWS(Value)
    end,
})

Visuals:New("Toggle")({
    Title = "Bypass JumpPower",
    Description = "Custom jump power bypass",
    Callback = function(Value)
        if Value then
            Script:BypassJP(true, 100)
        else
            Script:BypassJP(false)
        end
    end,
})


-- // @Players Tab
local PlayersTab = Window:AddTab("Players")

PlayersTab:New("Title")({
    Title = "Player ESP (Individual)",
})

PlayersTab:New("Button")({
    Title = "Highlight Nearest Player",
    Description = "Add highlight to closest player",
    Callback = function()
        local closest = Script:GetClosestPlayer()
        if closest and closest.Character then
            Script:CreateHighlight(closest.Character, {
                FillColor = Color3_fromRGB(255, 0, 0),
                OutlineColor = Color3_fromRGB(255, 255, 255),
                FillTransparency = 0.3
            })
            Notify("Highlighted: " .. closest.Name, {Duration = 2, Type = "Success"})
        else
            Notify("No player found!", {Duration = 2, Type = "Error"})
        end
    end,
})

PlayersTab:New("Button")({
    Title = "Remove All Highlights",
    Callback = function()
        Script:ClearHighlights()
        Notify("All highlights removed!", {Duration = 1, Type = "Info"})
    end,
})

PlayersTab:New("Title")({
    Title = "Player Interactions",
})

PlayersTab:New("Button")({
    Title = "Get Closest Player",
    Description = "Find nearest player",
    Callback = function()
        local Closest, Dist = Script:GetClosestPlayer()
        if Closest then
            Notify("Closest: " .. Closest.Name .. " (" .. math.floor(Dist) .. " studs)", {Duration = 3, Type = "Success"})
        else
            Notify("No players nearby!", {Duration = 2, Type = "Error"})
        end
    end,
})

PlayersTab:New("Button")({
    Title = "Spectate Nearest",
    Description = "Spectate closest player",
    Callback = function()
        local Closest, Dist = Script:GetClosestPlayer()
        if Closest then
            Script:Spectate(Closest)
            Notify("Spectating: " .. Closest.Name, {Duration = 2, Type = "Success"})
        else
            Notify("No players nearby!", {Duration = 2, Type = "Error"})
        end
    end,
})

PlayersTab:New("Button")({
    Title = "Stop Spectating",
    Callback = function()
        Script:StopSpectate()
        Notify("Stopped spectating", {Duration = 1, Type = "Info"})
    end,
})


PlayersTab:New("Button")({
    Title = "List All Players",
    Description = "Show all players in console",
    Callback = function()
        local Players = Script:GetPlayers(true)
        local List = ""
        for i, v in ipairs(Players) do
            List = List .. v.Name .. (i < #Players and ", " or "")
        end
        Notify("Players (" .. #Players .. "): " .. List, {Duration = 5, Type = "Info"})
    end,
})

PlayersTab:New("Title")({
    Title = "Friend Management",
})

PlayersTab:New("Button")({
    Title = "Check If Friend",
    Description = "Check if nearest is friend",
    Callback = function()
        local Closest, Dist = Script:GetClosestPlayer()
        if Closest then
            local IsFriend = Script:IsAFriend(Closest)
            Notify(Closest.Name .. (IsFriend and " is your friend!" or " is not your friend"), {Duration = 2, Type = IsFriend and "Success" or "Info"})
        else
            Notify("No players nearby!", {Duration = 2, Type = "Error"})
        end
    end,
})

-- // @NPC Tab
local NPCTab = Window:AddTab("NPC")

NPCTab:New("Title")({
    Title = "NPC Features",
})

NPCTab:New("Button")({
    Title = "Get Closest NPC",
    Description = "Find nearest NPC",
    Callback = function()
        local NPC, Model, Dist, Name = Script:GetClosestNPC()
        if NPC then
            Notify("NPC Found: " .. Name .. " (" .. math.floor(Dist) .. " studs)", {Duration = 3, Type = "Success"})
        else
            Notify("No NPCs nearby!", {Duration = 2, Type = "Error"})
        end
    end,
})

NPCTab:New("Button")({
    Title = "Kill Closest NPC",
    Description = "Kills nearest NPC",
    Callback = function()
        local NPC, Model = Script:GetClosestNPC()
        if NPC then
            NPC:Kill()
            Notify("NPC killed!", {Duration = 1, Type = "Success"})
        else
            Notify("No NPC found!", {Duration = 2, Type = "Error"})
        end
    end,
})

NPCTab:New("Button")({
    Title = "Teleport to Closest NPC",
    Callback = function()
        local NPC, Model, Dist = Script:GetClosestNPC()
        if NPC then
            NPC:Teleport()
            Notify("Teleported to NPC!", {Duration = 1, Type = "Success"})
        else
            Notify("No NPC found!", {Duration = 2, Type = "Error"})
        end
    end,
})

-- // @Tools Tab
local ToolsTab = Window:AddTab("Tools")

ToolsTab:New("Title")({
    Title = "Developer Tools",
})

ToolsTab:New("Button")({
    Title = "Infinite Yield",
    Description = "Load admin script",
    Callback = function()
        Script:Infinite_Yield()
        Notify("Infinite Yield loaded!", {Duration = 2, Type = "Success"})
    end,
})

ToolsTab:New("Button")({
    Title = "Simple Spy",
    Description = "Load remote spy",
    Callback = function()
        Script:Simple_Spy()
        Notify("Simple Spy loaded!", {Duration = 2, Type = "Success"})
    end,
})

ToolsTab:New("Button")({
    Title = "Dex Explorer",
    Description = "Load Dex Explorer",
    Callback = function()
        Script:Dex_Explorer()
        Notify("Dex Explorer loaded!", {Duration = 2, Type = "Success"})
    end,
})

ToolsTab:New("Title")({
    Title = "Anti Features",
})

ToolsTab:New("Button")({
    Title = "Anti-AFK",
    Description = "Prevent being kicked for idling",
    Callback = function()
        Script:AntiAFK()
        Notify("Anti-AFK enabled!", {Duration = 2, Type = "Success"})
    end,
})

ToolsTab:New("Toggle")({
    Title = "Anti-Void (Type 1)",
    Description = "Prevent falling (boosts you up)",
    Callback = function(Value)
        Script:AntiVoid1(Value)
    end,
})

ToolsTab:New("Toggle")({
    Title = "Anti-Void (Type 2)",
    Description = "Prevent falling (disables kill height)",
    Callback = function(Value)
        Script:AntiVoid2(Value)
    end,
})

ToolsTab:New("Toggle")({
    Title = "Anti-Collider",
    Description = "Prevent being flung by others",
    Callback = function(Value)
        Script:AntiCollider(Value)
    end,
})


ToolsTab:New("Title")({
    Title = "Performance",
})

ToolsTab:New("Slider")({
    Title = "FPS Cap",
    Description = "Limit your frame rate",
    Default = 60,
    Minimum = 30,
    Maximum = 240,
    DecimalCount = 0,
    Callback = function(Value)
        Script:SetFpsCap(Value)
        Notify("FPS cap set to: " .. Value, {Duration = 1, Type = "Info"})
    end,
})


-- // @Fun Tab
local Fun = Window:AddTab("Fun")

Fun:New("Title")({
    Title = "Text Fun",
})

Fun:New("Input")({
    Title = "UwUify Text",
    Description = "Convert text to uwu language",
    Placeholder = "Enter text here...",
    Callback = function(Text)
        local UwU = Script:Uwuify(Text)
        Notify(UwU, {Duration = 5, Type = "Success"})
    end,
})

Fun:New("Input")({
    Title = "Nerdify Text",
    Description = "Make text sound nerdy",
    Placeholder = "Enter text here...",
    Callback = function(Text)
        local Nerd = Script:Nerdify(Text)
        Notify(Nerd, {Duration = 5, Type = "Success"})
    end,
})

Fun:New("Input")({
    Title = "Auto Correct Text",
    Description = "Automatically corrects grammar",
    Placeholder = "Enter text here...",
    Callback = function(Text)
        local Corrected = Script:AutoCorrect(Text)
        Notify(Corrected, {Duration = 5, Type = "Success"})
    end,
})

Fun:New("Input")({
    Title = "Reverse Text",
    Description = "Reverses the entire string",
    Placeholder = "Enter text here...",
    Callback = function(Text)
        local Reversed = Script:Reverseify(Text)
        Notify(Reversed, {Duration = 5, Type = "Success"})
    end,
})

Fun:New("Title")({
    Title = "Translation",
})

local Language_Options = {
    "Auto", "Home", "English", "Spanish", "French", "German", "Italian", "Portuguese",
    "Russian", "Japanese", "Korean", "Chinese", "Arabic", "Hindi", "Dutch", "Polish",
    "Turkish", "Vietnamese", "Thai", "Greek", "Hebrew", "Swedish", "Norwegian", "Danish",
    "Finnish", "Czech", "Hungarian", "Romanian", "Bulgarian", "Croatian", "Slovak", "Slovenian"
}

local Target_Language, Source_Language = "Home", "Auto"

Fun:New("Dropdown")({
    Title = "Source Language",
    Description = "Language to translate FROM (Auto = detect)",
    Options = Language_Options,
    Default = "Auto",
    Callback = function(Value)
        Source_Language = Value
        if Source_Language == "Home" then
            local Code, Country, Language = Script:GetCountry()
            Source_Language = Language or "English"
            Notify("Source set to: " .. Source_Language .. " (Your region)", {Duration = 3, Type = "Info"})
        elseif Source_Language == "Auto" then
            Notify("Source set to: Auto-detect", {Duration = 3, Type = "Info"})
        else
            Notify("Source set to: " .. Source_Language, {Duration = 3, Type = "Info"})
        end
    end,
})

Fun:New("Dropdown")({
    Title = "Target Language",
    Description = "Language to translate TO",
    Options = Language_Options,
    Default = "Home",
    Callback = function(Value)
        Target_Language = Value
        if Target_Language == "Home" then
            local Code, Country, Language = Script:GetCountry()
            Target_Language = Language or "English"
            Notify("Target set to: " .. Target_Language .. " (Your region)", {Duration = 3, Type = "Info"})
        else
            Notify("Target set to: " .. Target_Language, {Duration = 3, Type = "Info"})
        end
    end,
})

Fun:New("Input")({
    Title = "Translate Text",
    Description = "Translates text",
    Placeholder = "Enter text to translate...",
    Callback = function(Text)
        local SourceLang, TargetLang = Source_Language, Target_Language
        
        if SourceLang == "Auto" then SourceLang = "auto" end
        if SourceLang == "Home" then
            local Code, Country, Language = Script:GetCountry()
            SourceLang = Language or "en"
        end
        if TargetLang == "Home" then
            local Code, Country, Language = Script:GetCountry()
            TargetLang = Language or "en"
        end
        
        local Translated, Detected, Original, DetectedLang = Script:Translate(Text, TargetLang, SourceLang)
        
        if Translated then
            local Message = string.format(
                "Original: %s\nTranslated: %s\n%s",
                Original or Text,
                Translated,
                DetectedLang and DetectedLang ~= "auto" and "Detected: " .. DetectedLang or ""
            )
            Notify(Message, {Duration = 10, Type = "Success"})
        else
            Notify("Translation failed!", {Duration = 2, Type = "Error"})
        end
    end,
})

Fun:New("Title")({
    Title = "Random Generators",
})

Fun:New("Button")({
    Title = "Random Number",
    Description = "Generate random number (1-1,000,000)",
    Callback = function()
        local Num = Script:GetRandomNumber(1, 1000000)
        Notify("Random number: " .. Num, {Duration = 2, Type = "Success"})
    end,
})

Fun:New("Button")({
    Title = "Random String",
    Description = "Generate random 15 characters",
    Callback = function()
        local Str = Script:RandomString(15)
        Notify("Random string: " .. Str, {Duration = 2, Type = "Success"})
    end,
})

Fun:New("Button")({
    Title = "Random Color",
    Description = "Generate random hex color",
    Callback = function()
        local Color = Script:RandomColor()
        local Hex = Script:RGBToHex(Color)
        Notify("Random color: " .. Hex, {Duration = 2, Type = "Success"})
    end,
})

Fun:New("Button")({
    Title = "Random Vector",
    Description = "Generate random position",
    Callback = function()
        local Vec = Script:RandomVector3(100, 100, 100)
        Notify("Random vector: " .. tostring(Vec), {Duration = 2, Type = "Success"})
    end,
})

Fun:New("Title")({
    Title = "Fun Actions",
})

Fun:New("Button")({
    Title = "Sit",
    Description = "Make character sit",
    Callback = function()
        Script:Sit(true)
        Notify("Sitting...", {Duration = 1, Type = "Info"})
    end,
})

Fun:New("Button")({
    Title = "Stand Up",
    Callback = function()
        Script:Sit(false)
        Notify("Standing up", {Duration = 1, Type = "Info"})
    end,
})

Fun:New("Button")({
    Title = "Click Simulator",
    Description = "Simulate a mouse click",
    Callback = function()
        Script:Click()
        Notify("Click simulated!", {Duration = 1, Type = "Success"})
    end,
})

-- // @Misc Tab
local Misc = Window:AddTab("Misc")

Misc:New("Title")({
    Title = "Information",
})

Misc:New("Button")({
    Title = "Get Country Info",
    Description = "Show detailed country info",
    Callback = function()
        local Code, Country, Language, Flag, Locale = Script:GetCountry()
        local Message = string.format("%s %s\nCode: %s\nLanguage: %s\nLocale: %s", Flag or "", Country, Code, Language, Locale)
        Notify(Message, {Duration = 5, Type = "Info"})
    end,
})

Misc:New("Button")({
    Title = "Get Ping",
    Description = "Show current ping",
    Callback = function()
        local Ping = Script:GetPing()
        Notify("Ping: " .. Ping .. " ms", {Duration = 2, Type = "Info"})
    end,
})

Misc:New("Button")({
    Title = "Get FPS",
    Description = "Show current FPS",
    Callback = function()
        local FPS = Script:GetFps()
        Notify("FPS: " .. FPS, {Duration = 2, Type = "Info"})
    end,
})

Misc:New("Button")({
    Title = "Get HWID",
    Description = "Get Roblox HWID",
    Callback = function()
        local HWID = Script:GetHWID("Roblox")
        Notify("Roblox HWID: " .. HWID, {Duration = 5, Type = "Info"})
    end,
})

Misc:New("Button")({
    Title = "Get Position",
    Description = "Show your current position",
    Callback = function()
        local Root = Script:GetRoot()
        if Root then
            local Pos = Root.Position
            Notify(string.format("Position: X: %.1f, Y: %.1f, Z: %.1f", Pos.X, Pos.Y, Pos.Z), {Duration = 3, Type = "Info"})
        end
    end,
})

Misc:New("Title")({
    Title = "Utilities",
})

local Control_State = false

Misc:New("Button")({
    Title = "Control F9",
    Description = "Toggle developer console",
    Callback = function()
        Control_State = not Control_State
        Script:ControlF9(Control_State)
        Notify("Console " .. (Control_State and "opened" or "closed") .. "!", {Duration = 1, Type = "Info"})
    end,
})

Misc:New("Button")({
    Title = "Bring All Tools",
    Description = "Bring tools to you",
    Callback = function()
        Script:BringTools(50, 0.5, 5, {workspace})
        Notify("Bringing tools...", {Duration = 2, Type = "Info"})
    end,
})

Misc:New("Button")({
    Title = "Stop Bringing Tools",
    Callback = function()
        Script:StopBringTools()
        Notify("Stopped bringing tools", {Duration = 1, Type = "Info"})
    end,
})

Misc:New("Button")({
    Title = "Get Tools List",
    Description = "Show your tools",
    Callback = function()
        local Tools = Script:GetTools()
        if #Tools > 0 then
            local List = ""
            for i, v in ipairs(Tools) do
                List = List .. v.Name .. (i < #Tools and ", " or "")
            end
            Notify("Tools (" .. #Tools .. "): " .. List, {Duration = 3, Type = "Info"})
        else
            Notify("No tools found!", {Duration = 2, Type = "Info"})
        end
    end,
})

-- // @Settings Tab
local Settings = Window:AddTab("Settings")

Settings:New("Title")({
    Title = "UI Settings"
})

Settings:New("Dropdown")({
    Title = "Themes",
    Description = "Select your theme",
    Options = {"Light", "Dark", "Midnight", "Rose", "Emerald"},
    Callback = function(Theme)
        Window:SetTheme(Theme)
    end,
})

Settings:New("Button")({
    Title = "Unload UI",
    Callback = function()
        if Keybind_Connection then 
            Keybind_Connection:Disconnect()
            Keybind_Connection = nil
        end

        if Window then 
            Window:Destroy()
            getgenv().Window = nil
        end

        if Script then
            Script:Unload()
        end

        global._Instance = nil
    end,
})

Window:SetTab("Info")
