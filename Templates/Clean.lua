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

local type, typeof, pcall, tick, tonumber, warn, print, unpack, next, loadstring, setmetatable =
    type, typeof, pcall, tick, tonumber, warn, print, unpack, next, loadstring, setmetatable

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

-- // @Farming Tab
local Components1 = Window:AddTab("Farming")

Components1:New("Title")({
    Title = "Farming Features",
})

Components1:New("Toggle")({
    Title = "Flight",
    Description = "Enables flight",
    Callback = function(Value)
        Script:Flight(Value, 70)
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

Window:SetTab("Farming")
