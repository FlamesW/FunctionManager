-- // @FunctionManager.luau
local Game: DataModel = game;
if not (Game:IsLoaded()) then Game.Loaded:Wait() end

local global = (shared or (getgenv and getgenv()) or _G) :: any;
(global.FunctionManager_Engine or {Unload = function() end}):Unload();

-- // @Performance.vars
local cloneref: (Instance) -> Instance = (cloneref or clonereference or function(instance: Instance)
    return instance
end)

local typeof, pcall, tick, tonumber, warn, print,unpack, next, loadstring, setmetatable =
    typeof, pcall, tick, tonumber, warn, print, unpack, next, loadstring, setmetatable

local math_floor, math_random, math_clamp, math_max, math_min, math_sqrt, math_abs, math_rad, math_ceil, math_huge =
    math.floor, math.random, math.clamp, math.max, math.min, math.sqrt, math.abs, math.rad, math.ceil, math.huge

local string_format, string_sub, string_match, string_gsub, string_gmatch, string_lower =
    string.format, string.sub, string.match, string.gsub, string.gmatch, string.lower

local table_insert, table_clear, table_sort, table_remove, table_create, table_concat =
    table.insert, table.clear, table.sort, table.remove, table.create, table.concat

local task_wait, task_spawn, task_cancel, task_delay = task.wait, task.spawn, task.cancel, task.delay

local os_clock, os_time, os_date = os.clock, os.time, os.date
local pairs, ipairs = pairs, ipairs

local task_running, task_resume, task_yield, task_create, task_close = 
    coroutine.running, coroutine.resume, coroutine.yield, coroutine.create, coroutine.close

local Vector3_new, Vector2_new, Vector3_zero, Color3_fromRGB, Color3_fromHSV, CFrame_lookAt, CFrame_new, CFrame_Angles, Instance_new =
    Vector3.new, Vector2.new, Vector3.zero, Color3.fromRGB, Color3.fromHSV, CFrame.lookAt, CFrame.new, CFrame.Angles, Instance.new

local write_file, read_file, is_file, make_folder, is_folder, del_folder, del_file, list_files =
    writefile, readfile, isfile, makefolder, isfolder, delfolder, delfile, listfiles

local globalEnv = (getgenv and getgenv() or _G) :: any;

-- // @Main Module
local API = {}
API.__index = API

-- // @Variables
local Workspace, GetService, Class = workspace, Game.GetService, API;
local Project = {Name = "Function Manager", Build = "@2.15", Author = "FlamesW", File = "Module.luau"}

local Players: Players? = cloneref(GetService(Game, "Players"));
local RunService: RunService? = cloneref(GetService(Game, "RunService"));
local UserInputService: UserInputService? = cloneref(GetService(Game, "UserInputService"));
local ReplicatedStorage: ReplicatedStorage? = cloneref(GetService(Game, "ReplicatedStorage"));
local HttpService: HttpService? = cloneref(GetService(Game, "HttpService"));
local TweenService: TweenService? = cloneref(GetService(Game, "TweenService"));
local SoundService: SoundService? = cloneref(GetService(Game, "SoundService"));
local CoreGui: CoreGui? = cloneref(GetService(Game, "CoreGui"));

local MarketplaceService: MarketplaceService? = GetService(Game, "MarketplaceService");
local TeleportService: TeleportService? = GetService(Game, "TeleportService");
local RbxAnalyticsService: RbxAnalyticsService? = GetService(Game, "RbxAnalyticsService");
local LocalizationService: LocalizationService? = GetService(Game, "LocalizationService");
local TextChatService: TextChatService? = GetService(Game, "TextChatService");
local StarterGuiService: StarterGuiService? = GetService(Game, "StarterGui");
local GuiService: GuiService? = GetService(Game, "GuiService");
local Performance: Performance? = GetService(Game, "Stats");
local LightingService: LightingService? = GetService(Game, "Lighting");

local VirtualInputManager: VirtualInputManager? = Instance_new("VirtualInputManager");
local LocalPlayer: Player? = nil
local Character: Model?, Roots: BasePart?, Humanoid: Humanoid? = nil, nil, nil;
local CurrentCamera: Camera? = Workspace.CurrentCamera;

local QueueOnTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport);
local GetConnections: GetConnections? = getconnections or get_signal_cons;
local Get_Asset = getcustomasset or getsynasset;

repeat task_wait() LocalPlayer = Players.LocalPlayer until LocalPlayer ~= nil
global.FunctionManager_Engine = API -- // @Enviroment exposure

local Runtime = os_clock()

-- // @RunService
local RenderStepped = RunService.RenderStepped;
local Heartbeat = RunService.Heartbeat;
local Stepped = RunService.Stepped;
local BindToRenderStep = RunService.BindToRenderStep;
local UnbindFromRenderStep = RunService.UnbindFromRenderStep;

-- // @UserInputService
local InputBegan = UserInputService.InputBegan;
local IsKeyDown = UserInputService.IsKeyDown;
local GetMouseLocation = UserInputService.GetMouseLocation;
local GetPlatform = UserInputService.GetPlatform;

-- // @Workspace / @Game
local WorkspaceRaycast, RaycastParamsNew = Workspace.Raycast, RaycastParams.new;
local PlaceId, JobId, GameId = Game.PlaceId, Game.JobId, Game.GameId;

--[[
-- // @KeyCode Enums
local Enum_KeyCode_W, Enum_KeyCode_A, Enum_KeyCode_S, Enum_KeyCode_D = 
    Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D;

local Enum_KeyCode_Space, Enum_KeyCode_LeftControl = 
    Enum.KeyCode.Space, Enum.KeyCode.LeftControl;
    
local Enum_KeyCode_Equals, Enum_KeyCode_Minus = 
    Enum.KeyCode.Equals, Enum.KeyCode.Minus;

local Enum_KeyCode_KeypadPlus, Enum_KeyCode_KeypadMinus = 
    Enum.KeyCode.KeypadPlus, Enum.KeyCode.KeypadMinus;
--]]

-- // @Signal.luau
function API:_Connect(...): () 
    local Signal = {...}; if #Signal == 1 and typeof(Signal[1]) == "table" then Signal = Signal[1] end; local function Connect(Name, Object) if type(Name) ~= "string" then return end; self._Signal = self._Signal or {}; self._Signal[Name] = self._Signal[Name] or {}; local Service = self._Signal[Name]; if typeof(Object) == "table" then for _, v in ipairs(Object) do Service[#Service + 1] = v end else Service[#Service + 1] = Object end end; if #Signal >= 2 then for i = 1, #Signal, 2 do local Name = Signal[i]; local Object = Signal[i + 1]; Connect(Name, Object) end end 
end

function API:_Disconnect(...): () 
    local Signal = {...}; if #Signal == 1 and typeof(Signal[1]) == "table" then Signal = Signal[1] end; for _, Name in ipairs(Signal) do if type(Name) ~= "string" then continue end; local Objects = self._Signal and self._Signal[Name]; if not Objects then continue end; local function Disconnect(Object) if Object == nil then return end; local ObjectType = typeof(Object); if ObjectType == "RBXScriptConnection" then pcall(function() Object:Disconnect() end) elseif ObjectType == "thread" then pcall(function() task_cancel(Object) end) elseif ObjectType == "Instance" then if Object.ClassName == "AnimationTrack" then pcall(function() Object:Stop() end) end; pcall(function() Object:Destroy() end) elseif ObjectType == "table" then for _, Sub in pairs(Object) do CleanUP(Sub) end; table_clear(Object) elseif ObjectType == "function" then pcall(Object) end end; for i = 1, #Objects do Disconnect(Objects[i]) end; self._Signal[Name] = nil end 
end

function API:_ExitFM(): ()
    for Name, _ in pairs(self._Signal or {}) do self:_Disconnect(Name) end; self._Signal = nil
end

function API:_Inject(Url, t)
    local fn = self:LoadFile(Url); local env = getfenv(fn); for k,v in pairs(t or {}) do env[k]=v end; setfenv(fn, env); return fn()
end

function globalEnv._IsLoadedFM() --> typeof(_IsLoadedFM) == "function" and _IsLoadedFM();
    return global.FunctionManager_Engine ~= nil
end

function globalEnv._Clean(Object, ...)
    if not Object then return end

    if type(table.clear) == "function" then
        pcall(table.clear, Object)
    end

    if type(setmetatable) == "function" then
        pcall(setmetatable, Object, nil)
    end

    pcall(function()
        for Key in pairs(Object) do
            rawset(Object, Key, nil)
        end
    end)
end

-- // @Engine.luau
local function Build_Engine(Running: Model)
    if Running and typeof(Running) ~= "boolean" then
        Character, Roots, Humanoid = Running, Running:WaitForChild("HumanoidRootPart",5), Running:WaitForChild("Humanoid",5);
        Class.Character, Class.Roots, Class.Humanoid = Character, Roots, Humanoid;
	end

    CurrentCamera = Workspace.CurrentCamera; Class.CurrentCamera = CurrentCamera;
end

Build_Engine(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait());
API:_Connect("@Engine.luau", {LocalPlayer.CharacterAdded:Connect(Build_Engine), Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Build_Engine(nil) end)})

-- // @Window Listener.luau
local Window_Focused = true

API:_Connect("@WindowListener", {
    UserInputService.WindowFocused:Connect(function()
        Window_Focused = true
    end),

    UserInputService.WindowFocusReleased:Connect(function()
        Window_Focused = false
    end)
})

-- // @Functions.module
function API:CreateInstance(ClassName: string, Properties: { [string]: any }?)
    local InstanceObj = Instance_new(ClassName)
    if Properties then
        for k, v in pairs(Properties) do
            InstanceObj[k] = v
        end
    end
    return InstanceObj
end

function API:CreateDrawing(DrawType: string, Properties: { [string]: any }?)
    if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then
        return nil
    end

    local DrawingObj = Drawing.new(DrawType)
    
    if not DrawingObj then return nil end

    if Properties then
        for k, v in pairs(Properties) do
            DrawingObj[k] = v
        end
    end

    self.DrawingsList = self.DrawingsList or {}
    table_insert(self.DrawingsList, DrawingObj)

    return DrawingObj
end

function API:UpdateDrawing(DrawingObj, Properties)
    if not DrawingObj then return nil end
    
    if Properties then
        for k, v in pairs(Properties) do
            DrawingObj[k] = v
        end
    end
    
    return DrawingObj
end

function API:ShowDrawing(DrawingObj)
    if DrawingObj then
        DrawingObj.Visible = true
    end
end

function API:HideDrawing(DrawingObj)
    if DrawingObj then
        DrawingObj.Visible = false
    end
end

function API:RemoveDrawing(DrawingObj)
    if not DrawingObj then return end
    
    DrawingObj:Remove()
    
    if self.DrawingsList then
        for i = #self.DrawingsList, 1, -1 do
            if self.DrawingsList[i] == DrawingObj then
                table_remove(self.DrawingsList, i)
                break
            end
        end
    end
end

function API:ToggleDrawing(DrawingObj)
    if DrawingObj then
        DrawingObj.Visible = not DrawingObj.Visible
        return DrawingObj.Visible
    end
    return false
end

function API:ClearDrawings()
    if not self.DrawingsList then return end
    
    for _, DrawingObj in ipairs(self.DrawingsList) do
        DrawingObj:Remove()
    end
    
    table_clear(self.DrawingsList)
end

function API:CreateDrawingManager()
    if typeof(self.DrawingManager) ~= "table" then
        self.DrawingManager = {Drawings = {}, Connections = {},
            System = {
                ["Player"] = {
                    type = "Player",
                    getPosition = function(Target) 
                        return self:ResolvePosition(Target) or nil
                    end,
                    isValid = function(Target) 
                        return Target and Target.Parent ~= nil
                    end,
                    onRespawn = function(Target, Callback)
                        local Connection = Target.CharacterAdded:Connect(Callback)
                        self:_Connect("@Draw_Respawn_Manager", Connection)
                        return Connection
                    end,
                    onRemove = function(Target, Callback)
                        local Connection = Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                        self:_Connect("@Draw_Remove_Manager", Connection)
                        return Connection
                    end
                },
                ["Character"] = {
                    type = "Model",
                    getPosition = function(Target)
                        return self:ResolvePosition(Target) or nil
                    end,
                    isValid = function(Target)
                        return Target and Target.Parent ~= nil and Target:FindFirstChild("Humanoid") ~= nil
                    end,
                    onRespawn = nil,
                    onRemove = function(Target, Callback)
                        local Connection = Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                        self:_Connect("@Draw_Remove_Manager", Connection)
                        return Connection
                    end
                },
                ["Part"] = {
                    type = "BasePart",
                    getPosition = function(Target) 
                        return self:ResolvePosition(Target) or nil
                    end,
                    isValid = function(Target) 
                        return Target and Target.Parent ~= nil 
                    end,
                    onRespawn = nil,
                    onRemove = function(Target, Callback)
                        local Connection = Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                        self:_Connect("@Draw_Remove_Manager", Connection)
                        return Connection
                    end
                },
                ["Vector3"] = {
                    type = "Vector3",
                    getPosition = function(Target) 
                        return self:ResolvePosition(Target) or nil
                    end,
                    isValid = function(Target) 
                        return true 
                    end,
                    onRespawn = nil,
                    onRemove = nil
                },
                ["Instance"] = {
                    type = "Instance",
                    getPosition = function(Target)
                        return self:ResolvePosition(Target) or nil
                    end,
                    isValid = function(Target) 
                        return Target and Target.Parent ~= nil 
                    end,
                    onRespawn = function(Target, Callback)
                        if Target:IsA("Player") then
                            local Connection = Target.CharacterAdded:Connect(Callback)
                            self:_Connect("@Draw_Respawn_Manager", Connection)
                            return Connection
                        end
                        return nil
                    end,
                    onRemove = function(Target, Callback)
                        local Connection = Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                        self:_Connect("@Draw_Remove_Manager", Connection)
                        return Connection
                    end
                }
            }
        }
    end
end

function API:GetDrawingSystem(Target)
    self:CreateDrawingManager()

    local Type = typeof(Target)
    
    if Type == "Player" then
        return self.DrawingManager.System.Player
    elseif Type == "Vector3" then
        return self.DrawingManager.System.Vector3
    elseif Type == "Instance" then
        if Target:IsA("BasePart") then
            return self.DrawingManager.System.Part
        elseif Target:IsA("Model") and Target:FindFirstChild("Humanoid") then
            return self.DrawingManager.System.Character
        else
            return self.DrawingManager.System.Instance
        end
    end
    
    return nil
end

function API:CreateDrawingV(DrawType, Properties, Target, OnUpdate, SpecifiedSystem)
    self:CreateDrawingManager()

    local DrawingObj = self:CreateDrawing(DrawType, Properties)
    if not DrawingObj then return nil end
    
    if not Target then return DrawingObj end

    local System = nil
    if SpecifiedSystem then
        System = self.DrawingManager.System[SpecifiedSystem]
        if not System then
            System = self:GetDrawingSystem(Target)
        end
    else
        System = self:GetDrawingSystem(Target)
    end

    if not System then return DrawingObj end

    local DrawingID = self:RandomString(15)
    self.DrawingManager.Drawings[DrawingID] = {
        Id = DrawingID,
        Drawing = DrawingObj,
        Target = Target,
        System = System,
        OnUpdate = OnUpdate,
        SpecifiedSystem = SpecifiedSystem,
        IsActive = true,
        LastScreenPos = nil
    }

    local Data = self.DrawingManager.Drawings[DrawingID]
    local Connections = {Remove = "@Draw_Remove: " .. DrawingID, Render = "@Draw_Render: " .. DrawingID, Respawn = "@Draw_Respawn: " .. DrawingID}

    if System.onRemove then
        local Removed_Connection = System.onRemove(Target, function()
            if Data.IsActive then
                if Data.Drawing then
                    self:RemoveDrawing(Data.Drawing)
                end

                self:_Disconnect(Connections.Remove, Connections.Render, Connections.Respawn)
                self.DrawingManager.Drawings[DrawingID] = nil
            end
        end)

        self:_Connect(Connections.Remove, Removed_Connection)
    end

    local function CreateRendered()
        local Render_Connection = RenderStepped:Connect(function()
            if not Data or not Data.IsActive then return end

            if not Data.System.isValid(Data.Target) then
                self:HideDrawing(Data.Drawing)
                return
            end

            local Position = Data.System.getPosition(Data.Target)
            if not Position then
                self:HideDrawing(Data.Drawing)
                return
            end

            local ScreenPos, OnScreen = self:WorldToScreen(Position)
            
            if OnScreen and ScreenPos then
                self:ShowDrawing(Data.Drawing)
        
                if DrawType == "Text" then
                    Data.Drawing.Position = Vector2_new(ScreenPos.X, ScreenPos.Y)
                elseif DrawType == "Circle" or DrawType == "Square" then
                    Data.Drawing.Position = Vector2_new(ScreenPos.X, ScreenPos.Y)
                elseif DrawType == "Line" and Data.LastScreenPos then
                    Data.Drawing.From = Data.LastScreenPos
                    Data.Drawing.To = Vector2_new(ScreenPos.X, ScreenPos.Y)
                end

                if OnUpdate then
                    OnUpdate(Data.Drawing, Data.Target, ScreenPos, OnScreen)
                end
                
                Data.LastScreenPos = Vector2_new(ScreenPos.X, ScreenPos.Y)
            else
                self:HideDrawing(Data.Drawing)
            end
        end)

        return Render_Connection
    end
    
    self:_Connect(Connections.Render, CreateRendered())
    
    if System.onRespawn then
        local function On_Respawn()
            if Data and Data.IsActive then
                self:_Disconnect(Connections.Render)

                self:_Connect(Connections.Render, CreateRendered())
            end
        end

        self:_Connect(Connections.Respawn, System.onRespawn(Target, On_Respawn))
    end

    return {
        Drawing = DrawingObj,
        System = System,
        Specified = SpecifiedSystem ~= nil,
        SpecifiedName = SpecifiedSystem,
        Remove = function()
            if Data.IsActive then
                Data.IsActive = false
                self:_Disconnect(Connections.Remove, Connections.Render, Connections.Respawn)

                if Data.Drawing then
                    self:RemoveDrawing(Data.Drawing)
                end
                self.DrawingManager.Drawings[DrawingID] = nil
            end
        end,
        Update = function(_, newProps)
            return self:UpdateDrawing(DrawingObj, newProps)
        end,
        Show = function() self:ShowDrawing(DrawingObj) end,
        Hide = function() self:HideDrawing(DrawingObj) end
    }
end

function API:ClearDrawingsV()
    if not self.DrawingManager then return end

    for Instance, Data in pairs(self.DrawingManager.Drawings) do
        if Data and Data.IsActive then
            Data.IsActive = false
            self:_Disconnect("@Draw_Remove: " .. Instance, "@Draw_Render: " .. Instance, "@Draw_Respawn: " .. Instance, "@Draw_Remove_Manager", "@Draw_Respawn_Manager")

            if Data.Drawing then
                self:RemoveDrawing(Data.Drawing)
            end
        end
    end

    table_clear(self.DrawingManager.Drawings)
end

function API:PlaySound(Id, Options)
    Options = Options or {}
    self.Sounds = self.Sounds or {}

    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    
    if typeof(SoundId) == "number" or (typeof(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end

    local Data
    if Options.Stack then
        Data = {
            Instance = self:CreateInstance("Sound", {
                Name = self:RandomString(15),
                SoundId = SoundId,
                Parent = SoundService
            })
        }
        self.Sounds[SoundId .. "_" .. self:RandomString(15)] = Data
    else
        Data = self.Sounds[SoundId]
        if not Data then
            Data = {
                Instance = self:CreateInstance("Sound", {
                    Name = self:RandomString(15),
                    SoundId = SoundId,
                    Parent = SoundService
                })
            }
            self.Sounds[SoundId] = Data
        end
        
        if Data.Connection then
            self:_Disconnect(Data.Connection)
            Data.Connection = nil
        end
        
        if Data.Instance.Playing then
            Data.Instance:Stop()
        end
    end

    Data.Instance.TimePosition = 0
    Data.Instance.Volume = Options.Volume or 1
    Data.Instance.Looped = Options.Looped or false
    Data.Instance:Play()

    local Manager = "@Sound_" .. self:RandomString(15)
    local Connection = Data.Instance.Ended:Connect(function()
        Data.Instance:Stop()
        Data.Instance:Destroy()

        for Key, Value in pairs(self.Sounds) do
            if Value == Data then
                self.Sounds[Key] = nil
                break
            end
        end

        self:_Disconnect(Manager)

        if Options.OnEnded then
            Options.OnEnded(Data.Instance)
        end
    end)

    self:_Connect(Manager, Connection)
    Data.Connection = Manager

    return Data.Instance
end

function API:IsSoundPlaying(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end

    if typeof(SoundId) == "number" or (typeof(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end
    
    local Data = self.Sounds[SoundId]
    return Data and Data.Instance and Data.Instance.Playing or false
end

function API:PauseSound(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end

    if typeof(SoundId) == "number" or (typeof(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end
    
    local Data = self.Sounds[SoundId]
    if Data and Data.Instance then
        Data.Instance:Pause()
        return true
    end
    return false
end

function API:ResumeSound(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end

    if typeof(SoundId) == "number" or (typeof(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end

    local Data = self.Sounds[SoundId]
    if Data and Data.Instance then
        Data.Instance:Resume()
        return true
    end
    return false
end

function API:StopSound(...)
    self.Sounds = self.Sounds or {}

    for _, Id in ipairs({...}) do
        local SoundId = Id
        if self.Sounds.Assets and self.Sounds.Assets[Id] then
            SoundId = self.Sounds.Assets[Id]
        end
        
        if typeof(SoundId) == "number" or (typeof(SoundId) == "string" and SoundId:match("^%d+$")) then
            SoundId = "rbxassetid://" .. tostring(SoundId)
        end

        local Data = self.Sounds[SoundId]
        if Data and Data.Instance then
            if Data.Connection then
                self:_Disconnect(Data.Connection)
                Data.Connection = nil
            end
            Data.Instance:Stop()
        end
    end
end

function API:SetVolume(Id, Volume)
    self.Sounds = self.Sounds or {}

    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end

    if typeof(SoundId) == "number" or (typeof(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end

    local Data = self.Sounds[SoundId]
    if Data and Data.Instance then
        Data.Instance.Volume = Volume
        return true
    end
    
    return false
end

function API:Preload(...)
    self.Sounds = self.Sounds or {}

    for _, Id in ipairs({...}) do
        local SoundId = Id
        if self.Sounds.Assets and self.Sounds.Assets[Id] then
            SoundId = self.Sounds.Assets[Id]
        end
        
        if typeof(SoundId) == "number" or (typeof(SoundId) == "string" and SoundId:match("^%d+$")) then
            SoundId = "rbxassetid://" .. tostring(SoundId)
        end

        if not self.Sounds[SoundId] then
            local SoundInstance = self:CreateInstance("Sound", {
                Name = self:RandomString(15),
                SoundId = SoundId,
                Volume = 0,
                Parent = SoundService
            })
            SoundInstance:Play()
            task_wait(0.05)
            SoundInstance:Stop()
            self.Sounds[SoundId] = {Instance = SoundInstance}
        end
    end
end

function API:SoundsAssets(Assets)
    self.Sounds = self.Sounds or {}
    self.Sounds.Assets = Assets
end

function API:ClearSounds()
    if not self.Sounds then return end

    for SoundId, Data in pairs(self.Sounds) do
        if typeof(Data) == "table" and Data.Instance then
            if Data.Connection then
                self:_Disconnect(Data.Connection)
            end

            pcall(function()
                Data.Instance:Stop()
                Data.Instance:Destroy()
            end)
        end
    end

    table_clear(self.Sounds)
end

function API:LoadCustomAsset(Asset, Url)
    if not is_file(Asset) then
        local Success, Content = pcall(function()
            return Game:HttpGet(Url)
        end)

        if Success then 
            write_file(Asset, Content) 
        else 
            return Url 
        end
    end

    if Get_Asset then
        return Get_Asset(Asset)
    else
        return is_file(Asset) and "rbxasset://" .. Asset or Url
    end
end

function API:GetAssetInfo(Id)
    self.AssetCache = self.AssetCache or {}

    if self.AssetCache[Id] then 
        return self.AssetCache[Id] 
    end

    local Success, Info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, Id)
    if not Success or not Info then return nil end
    
    local Asset_Types = {
        [1] = "Image", [2] = "TShirt", [3] = "Audio", [4] = "Mesh", [5] = "Lua",
        [8] = "Hat", [9] = "Place",[10] = "Model", [11] = "Shirt", [12] = "Pants",
        [13] = "Decal", [17] = "Head",[18] = "Face", [19] = "Gear", [21] = "Badge",
        [24] = "Animation", [27] = "Torso", [28] = "RightArm", [29] = "LeftArm",
        [30] = "LeftLeg", [31] = "RightLeg", [32] = "Package", [34] = "GamePass",
        [38] = "Plugin",[41] = "MeshPart",[42] = "Video",[43] = "Tool"
    }
    
    local Result = {
        Id = Id,
        Name = Info.Name,
        Creator = Info.Creator and Info.Creator.Name,
        CreatorId = Info.Creator and Info.Creator.Id,
        TypeId = Info.AssetTypeId,
        TypeName = Asset_Types[Info.AssetTypeId] or "Unknown",
        Description = Info.Description,
        Created = Info.Created,
        Updated = Info.Updated,
        Price = Info.PriceInRobux,
        IsForSale = Info.IsForSale,
        IsLimited = Info.IsLimited,
        IsLimitedUnique = Info.IsLimitedUnique,
        CollectibleItemId = Info.CollectibleItemId,
        SaleLocation = Info.SaleLocation,
        Genres = Info.Genres,
        ItemRestrictions = Info.ItemRestrictions
    }

    self.AssetCache[Id] = Result
    return Result
end

function API:GetDescendants(Instance, Class, Limit)
    local Descendants = Instance:GetDescendants()

    local Total = #Descendants
    Limit = Limit or Total
    
    local Results = table_create(Limit)
    local Count = 0
    
    for i = 1, Total do
        if Count >= Limit then break end
        
        local obj = Descendants[i]
        if obj:IsA(Class) then
            Count = Count + 1
            Results[Count] = obj
        end
    end
    
    if Count < Limit then
        local Trimmed = table_create(Count)
        for i = 1, Count do
            Trimmed[i] = Results[i]
        end
        return Trimmed, Count
    end
    
    return Results, Count
end

function API:GetChildren(Instance, Class)
    local Children = Instance:GetChildren()
    local Results = table_create(#Children)
    local Count = 0

    for i = 1, #Children do
        local Instance = Children[i]
        if Instance:IsA(Class) then
            Count = Count + 1
            Results[Count] = Instance
        end
    end
    
    return Results, Count
end

function API:GetClasses(Instance, Class, GetChildren)
    local Objects = GetChildren and Instance:GetChildren() or Instance:GetDescendants()
    local Results = {}
    local Count = 0
    
    for i = 1, #Objects do
        local obj = Objects[i]
        if obj:IsA(Class) then
            Count = Count + 1
            Results[Count] = obj
        end
    end
    
    return Results, Count
end

function API:HasClass(Instance, Class, GetChildren)
    local Objects = GetChildren and Instance:GetChildren() or Instance:GetDescendants()

    for i = 1, #Objects do
        local obj = Objects[i]
        if obj:IsA(Class) then
            return true
        end
    end
    
    return false
end

function API:CreateEventBus()
    return {
        _Events = {}, _OnceEvents = {},

        On = function(self, Name, Callback)
            if not self._Events[Name] then
                self._Events[Name] = {}
            end
            table_insert(self._Events[Name], Callback)
        end,

        Once = function(self, Name, Callback)
            if not self._OnceEvents[Name] then
                self._OnceEvents[Name] = {}
            end
            table_insert(self._OnceEvents[Name], Callback)
        end,
        
        Off = function(self, Name, Callback)
            if self._Events[Name] then
                for i, cb in ipairs(self._Events[Name]) do
                    if cb == Callback then
                        table_remove(self._Events[Name], i)
                        break
                    end
                end
            end
        end,
        
        Emit = function(self, Name, ...)
            local args = {...}
            
            if self._Events[Name] then
                for _, Callback in ipairs(self._Events[Name]) do
                    task_spawn(function()
                        Callback(unpack(args))
                    end)
                end
            end

            if self._OnceEvents[Name] then
                local Get_Events = self._OnceEvents[Name]

                self._OnceEvents[Name] = {}
                for _, Callback in ipairs(Get_Events) do
                    task_spawn(function()
                        Callback(unpack(args))
                    end)
                end
            end
        end,

        Clear = function(self)
            self._Events, self._OnceEvents = {}, {}
        end
    }
end

function API:Hotpath(Path)
    if not Path or Path == "" then return "" end
    Path = Path:gsub("\\", "/")
    Path = Path:gsub("//+", "/")
    Path = Path:gsub("/$", "")
    return Path
end

function API:SaveData(FileName, Data)
    FileName = self:Hotpath(FileName)

    if FileName == "" then return false end
    
    local Directory = FileName:match("(.+)/")
    if Directory and Directory ~= "" then
        local Created = self:CreateDirectory(Directory)
        if not Created then
            return false
        end
    end

    local Success, Encoded = pcall(function()
        return HttpService:JSONEncode(Data)
    end)
    if not Success then 
        return false 
    end

    local Success, Err = pcall(function()
        write_file(FileName, Encoded)
    end)
    
    return Success
end

function API:LoadData(FileName)
    FileName = self:Hotpath(FileName)

    if FileName == "" then return nil end
    
    if not is_file(FileName) then 
        return nil 
    end

    local Success, Content = pcall(function()
        return read_file(FileName)
    end)
    if not Success then 
        return nil 
    end
    
    local Success, Decoded = pcall(function()
        return HttpService:JSONDecode(Content)
    end)

    return Success and Decoded or nil
end

function API:DeleteData(FileName)
    FileName = self:Hotpath(FileName)

    if not is_file(FileName) then
        return false
    end
    
    if del_file then
        del_file(FileName)
        return true
    end
    return false
end

function API:ExecuteFile(FileName)
    local Data = self:LoadData(FileName)
    if not Data then return false end

    if typeof(Data) == "string" then
        local Success, Result = pcall(function()
            return loadstring(Data)()
        end)
        return Success, Result
    end

    if typeof(Data) == "table" and Data.Code then
        local Success, Result = pcall(function()
            return loadstring(Data.Code)()
        end)
        return Success, Result
    end

    return false
end

function API:GetFileSize(Path)
    if not is_file(Path) then return nil end
    local Data = read_file(Path)
    return #Data
end

function API:CreateDirectory(Path)
    Path = self:Hotpath(Path)

    if Path == "" then return false end
    
    if is_folder(Path) then
        return true
    end

    local function Recursive(Find)
        Find = self:Hotpath(Find)
        if Find == "" or is_folder(Find) then
            return
        end

        local Parent = Find:match("(.*)/")
        if Parent and Parent ~= "" then
            Recursive(Parent)
        end

        make_folder(Find)
    end
    
    Recursive(Path)
    return true
end

function API:DeleteDirectory(Path, Recursive)
    Path = self:Hotpath(Path)

    if not is_folder(Path) then
        return false
    end

    if Recursive then
        local Contents = self:GetDirectoryContents(Path, true)

        for i = #Contents, 1, -1 do
            local Item = Contents[i]
            if Item.Type == "Folder" then
                if is_folder(Item.Path) then
                    del_folder(Item.Path)
                end
            else
                if del_file then
                    del_file(Item.Path)
                end
            end
        end
    end

    del_folder(Path)
    return true
end

function API:GetDirectoryContents(Path, Recursive)
    Path = self:Hotpath(Path)

    if not is_folder(Path) then 
        return {} 
    end

    local Contents = {}
    local Files = list_files(Path)
    
    for _, Item in ipairs(Files) do
        if Item:find("/$") then
            table_insert(Contents, {
                Name = Item:gsub("/$", ""),
                Type = "Folder",
                Path = Path .. Item
            })

            if Recursive then
                local SubContents = self:GetDirectoryContents(Path .. Item, true)
                for _, SubItem in ipairs(SubContents) do
                    table_insert(Contents, SubItem)
                end
            end
        else
            table_insert(Contents, {
                Name = Item,
                Type = "File",
                Path = Path .. Item
            })
        end
    end
    
    return Contents
end

function API:FileExists(FileName)
    FileName = self:Hotpath(FileName)
    return is_file(FileName) or false
end

function API:FolderExists(Path)
    Path = self:Hotpath(Path)
    return is_folder(Path) or false
end

function API:CreateConfig(Defaults)
    local Config = {}
    local Events, Current_File = self:CreateEventBus(), "Config.json"

    local function Recrusive(Table, Path)
        Path = Path or {}
    
        local Meta = {__index = function(t, k)
                return rawget(t, k)
            end,
            __newindex = function(t, k, v)
                local old = rawget(t, k)

                local Full_Path = table_concat(Path, ".")
                local Full_Key = Full_Path ~= "" and (Full_Path .. "." .. k) or k
                
                Events:Emit("_Change", Full_Key, v, old)
                Events:Emit("_Change_" .. Full_Key, v, old)
                
                if Full_Path ~= "" then
                    Events:Emit("_Change_" .. Full_Path, v, old)
                end
                
                Events:Emit("_Change_Key", k, v, old, Full_Key)

                rawset(t, k, v)

                if typeof(v) == "table" then
                    local New_Path = {}

                    for _, p in ipairs(Path) do
                        table_insert(New_Path, p)
                    end
                    table_insert(New_Path, k)

                    Recrusive(v, New_Path)
                end
            end,
        }
        setmetatable(Table, Meta)
    end

    Recrusive(Config)
    
    for k, v in pairs(Defaults) do
        Config[k] = v
    end
    
    function Config:OnChange(Callback)
        Events:On("_Change", Callback)
    end
    
    function Config:OnceChange(Callback)
        Events:Once("_Change", Callback)
    end
    
    function Config:OnChangeKey(Key, Callback)
        Events:On("_Change_" .. Key, Callback)
    end
    
    function Config:OnChangeDirectory(Directory, Callback)
        Events:On("_Change_" .. Directory, Callback)
    end
    
    function Config:OnAnyKey(Callback)
        Events:On("_Change_Key", Callback)
    end
    
    function Config:OnReset(Callback)
        Events:On("_Reset", Callback)
    end
    
    function Config:OffChange(Callback)
        Events:Off("_Change", Callback)
    end

    function Config:OffReset(Callback)
        Events:Off("_Reset", Callback)
    end

    function Config:GetAll()
        local Result = {}
        for k, v in pairs(Defaults) do
            Result[k] = self[k]
        end
        return Result
    end

    function Config:Reset(Remove_File)
        if Remove_File then
            self:DeleteData(Current_File)
        end

        for k, v in pairs(Defaults) do
            self[k] = v
        end
        Events:Emit("_Reset", self:GetAll())
    end

    function Config:Save(File)
        Current_File = File or Current_File
        return self:SaveData(Current_File, self:GetAll())
    end

    function Config:Load(File)
        Current_File = File or Current_File
        local Data = self:LoadData(Current_File)
    
        if Data then
            for k, v in pairs(Data) do
                if Defaults[k] ~= nil then
                    self[k] = v
                end
            end
            Events:Emit("_Change", "Loaded", Data, nil) -- > @Use key == "Loaded" to detect if config was loaded.
            return true
        end
        return false
    end
    
    function Config:DeleteFile(File)
        return self:DeleteData(File or Current_File)
    end

    function Config:GetCurrentFile()
        return Current_File
    end

    return Config
end

function API:GetDevice()
    return GetPlatform(UserInputService)
end

function API:IsMobile()
    local Plat = self:GetDevice()
    return Plat == Enum.Platform.IOS or Plat == Enum.Platform.Android
end

function API:IsConsole()
    local Plat = self:GetDevice()
    return Plat == Enum.Platform.XBox or Plat == Enum.Platform.PS4
end

function API:IsPC()
    local Plat = self:GetDevice()
    return Plat == Enum.Platform.Windows or Plat == Enum.Platform.MacOS or Plat == Enum.Platform.Linux
end

function API:ToPlace(Place)
    TeleportService:Teleport(Place)
end

function API:Time(Format, Offset)
    Format = Format or "%H:%M:%S"
    local Current_Time = os_time()
    
    if Offset then
        local Utc = os_time(os_date("!*t", Current_Time))
        Current_Time = Utc + (Offset * 3600)
        return os_date("!" .. Format, Current_Time)
    end
    
    return os_date(Format, Current_Time)
end

function API:Date(Format, Offset)
    Format = Format or "%Y/%m/%d"
    local Current_Time = os_time()
    
    if Offset then
        local Utc = os_time(os_date("!*t", Current_Time))
        Current_Time = Utc + (Offset * 3600)
        return os_date("!" .. Format, Current_Time)
    end
    
    return os_date(Format, Current_Time)
end

function API:GetPing(Format)
    local Ping = Performance.Network.ServerStatsItem["Data Ping"]:GetValue()
    Format = Format or "%.2f"
    return tonumber(string_format(Format, Ping))
end

function API:GetFps(Format)
    Format = Format or "%.1f"

    if not self.Fps_Counter then
        self.Current_Fps = 0

        self.Fps_Counter = RenderStepped:Connect(function(Delta)
            if Delta > 0 then
                self.Current_Fps = 1 / Delta
            end
        end)

        self:_Connect("@Statistics_Fps", self.Fps_Counter)
    end

    return string_format(Format, self.Current_Fps or 0)
end

function API:StopFps()
    if self.Fps_Counter then
        self:_Disconnect("@Statistics_Fps")

        self.Fps_Counter, self.Current_Fps = nil,0
    end
end

function API:QueueOnTeleport(Flag, State, Script, Callbacks)
    if not self.Queues_Loaded then
        local Data = self:LoadData("@QueueSystem.json")
        if Data and Data.Queues then
            self.Teleport_Queues = Data.Queues
        else
            self.Teleport_Queues = {}
        end
        self.Queues_Loaded = true
    end

    if Callbacks and typeof(Callbacks) == "table" then
        self.QueueCallbacks = self.QueueCallbacks or {}
        self.QueueCallbacks[Flag] = Callbacks
    end

    if State == false then
        self.Teleport_Queues = self.Teleport_Queues or {}
        self.Teleport_Queues[Flag] = nil

        self:SaveData("@QueueSystem.json", { Queues = self.Teleport_Queues })
        return false
    end

    self.Teleport_Queues = self.Teleport_Queues or {}
    self.Teleport_Queues[Flag] = Script

	self:SaveData("@QueueSystem.json", { Queues = self.Teleport_Queues })

    if not self.TeleportListener then
        self.TeleportListener = LocalPlayer.OnTeleport:Connect(function(TeleportState)
            for f, s in pairs(self.Teleport_Queues) do
                if QueueOnTeleport then
                    pcall(QueueOnTeleport, s)
                end
            end

            if TeleportState == Enum.TeleportState.Failed then
                for f, cb in pairs(self.QueueCallbacks or {}) do
                    if cb.OnFailed then pcall(cb.OnFailed) end
                end
            end
        end)
        self:_Connect("@Teleport_Queue", self.TeleportListener)
    end

    local Call = self.QueueCallbacks and self.QueueCallbacks[Flag]
    if Call and Call.OnStart then
        pcall(Call.OnStart, Script)
    end

    return true
end

function API:SetQueue(Flag, State)
    self.Teleport_Queues = self.Teleport_Queues or {}

    if Flag == false and State == nil then
        self:_Disconnect("@Teleport_Queue")
        return
    end

    if State then
        local Script = self.Teleport_Queues[Flag]
        if Script then
            return self:QueueOnTeleport(Flag, true, Script)
        end
        return false
    else
        return self:QueueOnTeleport(Flag, false)
    end
end

function API:DetectAnim(Target)
    local Model, Humanoid, Controller = nil, nil, nil

    if Target:IsA("Model") then
        Model = Target
        Humanoid = Target:FindFirstChildOfClass("Humanoid")
        Controller = Target:FindFirstChildOfClass("AnimationController")
    elseif Target:IsA("Humanoid") then
        Humanoid = Target
        Model = Target.Parent
    elseif Target:IsA("AnimationController") then
        Controller = Target
        Model = Target.Parent
    elseif Target:IsA("Player") then
        if Target.Character then
            Model = Target.Character
            Humanoid = Model:FindFirstChildOfClass("Humanoid")
        end
    elseif Target:IsA("Part") or Target:IsA("BasePart") then
        Model = Target.Parent
        if Model and Model:IsA("Model") then
            Humanoid = Model:FindFirstChildOfClass("Humanoid")
        end
    end

    if not Humanoid and not Controller then
        return {}
    end

    local Animator = nil
    if Humanoid then
        Animator = Humanoid:FindFirstChildOfClass("Animator")
    end
    if not Animator and Controller then
        Animator = Controller:FindFirstChildOfClass("Animator")
    end
    if not Animator then
        return {}
    end

    local Tracks = Animator:GetPlayingAnimationTracks()
    if #Tracks == 0 then
        return {}
    end

    local Data = {}
    for _, Track in ipairs(Tracks) do
        local Object = Track.Animation

        local Asset_Id = Object and Object.AnimationId and tonumber(Object.AnimationId:match("%d+"))
        local Asset_Info = Asset_Id and self:GetAssetInfo(Asset_Id)

        Data[#Data + 1] = {
            Name = Track.Name,
            Speed = Track.Speed,
            TimePosition = Track.TimePosition,
            AnimationId = Object and Object.AnimationId,

            AssetName = Asset_Info and Asset_Info.Name,
            Creator = Asset_Info and Asset_Info.Creator,
            Type = Asset_Info and Asset_Info.Type,
            Description = Asset_Info and Asset_Info.Description,
        }
    end

    return Data
end

function API:LoadFile(Url)
    local Success, Result = pcall(function()
        return loadstring(Game:HttpGet(Url .. "?nocache=" .. tostring(os_clock())))()
    end)

    return Success and Result or nil
end

function API:ConnectSocket(Url)
    local SocketBoy = WebSocket

    if not SocketBoy then
        return false
    end

    if self.Websocket and self.Websocket.Connected then
        return true
    end
    
    local Success, Connection = pcall(function()
        return SocketBoy.connect(Url)
    end)
    
    if Success and Connection then
        self.Websocket = {
            Connection = Connection,
            Connected = true,
            Url = Url,
            Handlers = {},
            OnDisconnect = nil,
            OnError = nil
        }

        self:_Connect("@WebSocket_Message", Connection.OnMessage:Connect(function(message)
            if self.Websocket and self.Websocket.Handlers then
                for _, handler in ipairs(self.Websocket.Handlers) do
                    pcall(handler, message)
                end
            end
        end))

        self:_Connect("@WebSocket_Close", Connection.OnClose:Connect(function()
            if self.Websocket then
                self.Websocket.Connected = false
                if self.Websocket.OnDisconnect then
                    pcall(self.Websocket.OnDisconnect)
                end
            end
        end))
        
        if Connection.OnError then
            self:_Connect("@WebSocket_Error", Connection.OnError:Connect(function(Err)
                if self.Websocket and self.Websocket.OnError then
                    pcall(self.Websocket.OnError, Err)
                end
            end))
        end
        
        return true
    end

    return false
end

function API:OnSocketMessage(Callback)
    if not self.Websocket then
        self.Websocket = { Handlers = {} }
    end
    if not self.Websocket.Handlers then
        self.Websocket.Handlers = {}
    end
    table_insert(self.Websocket.Handlers, Callback)
end

function API:SendSocket(Message)
    if not self.Websocket or not self.Websocket.Connection or not self.Websocket.Connected then
        return false
    end
    
    return pcall(function()
        self.Websocket.Connection:Send(Message)
    end)
end

function API:IsSocketConnected()
    return self.Websocket and self.Websocket.Connected or false
end

function API:OnSocketDisconnect(Callback)
    if not self.Websocket then
        self.Websocket = {}
    end
    self.Websocket.OnDisconnect = Callback
end

function API:OnSocketError(Callback)
    if not self.Websocket then
        self.Websocket = {}
    end
    self.Websocket.OnError = Callback
end

function API:ClearWebSockets()
    if not self.Websocket then return end

    self:_Disconnect("@WebSocket_Message", "@WebSocket_Close", "@WebSocket_Error")

    local Success = pcall(function()
        self.Websocket.Connection:Close()
    end)

    self.Websocket.Connected = false
    table_clear(self.Websocket)

    return Success
end

function API:ToColor3(Color)
    if not Color then return Color3_fromRGB(255, 255, 255) end
    
    local ColorType = typeof(Color)
    
    if ColorType == "Color3" then
        return Color
    end
    
    if ColorType == "string" then
        if Color:match("^#?%x%x%x%x%x%x$") then
            return self:HexToRGB(Color)
        end
        local R, G, B = Color:match("(%d+)[%s,]*(%d+)[%s,]*(%d+)")
        if R and G and B then
            return Color3_fromRGB(tonumber(R), tonumber(G), tonumber(B))
        end
    end
    
    if ColorType == "table" then
        if Color[1] and Color[2] and Color[3] then
            return Color3_fromRGB(Color[1], Color[2], Color[3])
        end

        if (Color.r or Color.R) and (Color.g or Color.G) and (Color.b or Color.B) then
            return Color3_fromRGB(
                Color.r or Color.R,
                Color.g or Color.G,
                Color.b or Color.B
            )
        end
	
        if (Color.H or Color.h) and (Color.S or Color.s) and (Color.V or Color.v) then
            return Color3_fromHSV(Color.H or Color.h, Color.S or Color.s, Color.V or Color.v)
        end
    end

    if Color.h and Color.s and Color.v then
        return Color3_fromHSV(Color.h, Color.s, Color.v)
    end
    
    return Color3_fromRGB(255, 255, 255)
end

function API:StringToRGB(String)
    if not String then return nil end
    
    local R = tonumber(string_match(String, "(%d+)[%s]*,[%s]*%d+[%s]*,[%s]*%d+"))
    local G = tonumber(string_match(String, "%d+[%s]*,[%s]*(%d+)[%s]*,[%s]*%d+"))
    local B = tonumber(string_match(String, "%d+[%s]*,[%s]*%d+[%s]*,[%s]*(%d+)"))
    
    if R and G and B then
        return Color3_fromRGB(R, G, B)
    end
    
    return nil
end

function API:RGBToString(Rgb)
    return math_floor(Rgb.R * 255) .. ", " .. math_floor(Rgb.G * 255) .. ", " .. math_floor(Rgb.B * 255)
end

function API:HexToRGB(Hex)
    Hex = Hex:gsub("#", "")
    local R = tonumber(Hex:sub(1, 2), 16)
    local G = tonumber(Hex:sub(3, 4), 16)
    local B = tonumber(Hex:sub(5, 6), 16)
    return Color3_fromRGB(R, G, B)
end

function API:RGBToHex(Rgb)
    local R = math_floor(Rgb.R * 255)
    local G = math_floor(Rgb.G * 255)
    local B = math_floor(Rgb.B * 255)
    return string_format("#%02X%02X%02X", R, G, B)
end

function API:HSVToRGB(H, S, V)
    return Color3_fromHSV(H, S, V)
end

function API:RGBToHSV(Rgb)
    return Rgb.R, Rgb.G, Rgb.B
end

function API:Rainbowify(Speed)
    Speed = Speed or 1

    local Time = tick() * Speed
    return Color3_fromHSV(Time % 1, 1, 1)
end

function API:LightenColor(Color, Amount)
    Amount = Amount or 0.15

    local Color3 = self:ToColor3(Color)
    local H, S, V = Color3:ToHSV()
    V = math_clamp(V + Amount, 0, 1)
    return Color3_fromHSV(H, S, V)
end

function API:DarkenColor(Color, Amount)
    Amount = Amount or 0.15

    local Color3 = self:ToColor3(Color)
    local H, S, V = Color3:ToHSV()
    V = math_clamp(V - Amount, 0, 1)
    return Color3_fromHSV(H, S, V)
end

function API:RandomColor()
    return Color3_fromHSV(math_random(), math_random(), 1)
end

function API:Gitport(Owner, Repo, Version, File)
    local Tag = (Version == "latest" and "latest/download" or "download/" .. Version)    
    return self:LoadFile(("https://github.com/%s/%s/releases/%s/%s"):format(Owner, Repo, Tag, File))
end

function API:ControlF9(State)
    pcall(function()
        StarterGuiService:SetCore("DevConsoleVisible", State or false)
    end)
end

function API:RandomString(Length)
    Length = Length or 15
    local Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local Testicles = table_create(Length)

    for i = 1, Length do
        local RandomIndex = math_random(1, #Characters)
        Testicles[i] = string_sub(Characters, RandomIndex, RandomIndex)
    end

    return table_concat(Testicles)
end

function API:SpeedTest(Func, Iterations, ...)
    Iterations = Iterations or 100
    local args = {...}
    
    local Start = os_clock()
    for i = 1, Iterations do
        pcall(function() Func(unpack(args)) end)
    end
    local TotalMs = (os_clock() - Start) * 1000
    
    local Result = {
        Total = TotalMs,
        Average = TotalMs / Iterations,
        Iterations = Iterations
    }

    print(string_format("[SpeedTest]: %d iterations: %.2f ms total (avg: %.3f ms)", Iterations, TotalMs, Result.Average))

    return Result
end

function API:HowLong(Ago)
    if Ago < 60 then
        return "Just now"
    elseif Ago >= 31536000 then
        local y = math_floor(Ago / 31536000)
        return y .. " year" .. (y == 1 and "" or "s") .. " ago"
    elseif Ago >= 2592000 then
        local m = math_floor(Ago / 2592000)
        return m .. " month" .. (m == 1 and "" or "s") .. " ago"
    elseif Ago >= 604800 then
        local w = math_floor(Ago / 604800)
        return w .. " week" .. (w == 1 and "" or "s") .. " ago"
    elseif Ago >= 86400 then
        local d = math_floor(Ago / 86400)
        return d .. " day" .. (d == 1 and "" or "s") .. " ago"
    elseif Ago >= 3600 then
        local h = math_floor(Ago / 3600)
        return h .. " hour" .. (h == 1 and "" or "s") .. " ago"
     else
        local min = math_floor(Ago / 60)
        return min .. " minute" .. (min == 1 and "" or "s") .. " ago"
    end
end

function API:Version() 
    return Project;
end

function API:LogCommit(Repo, Branch, Version)
    local Owner, RepoName

    local Matches = {Repo:match("github%.com/([^/]+)/([^/]+)")}
    if #Matches >= 2 then
        Owner = Matches[1]
        RepoName = Matches[2]
        RepoName = RepoName:gsub("%.git$", "")
    else
        return nil
    end

    local function StripString(s)
        if not s then return "Unknown" end
        s = s:match("^%s*(.-)%s*$")
        s = s:gsub("%s+", " ")
        return s
    end

    local Selected = Branch or "main"
    local Github = "https://github.com/" .. Owner .. "/" .. RepoName .. "/commits/" .. Selected .. ".atom"

    local Success, Response = pcall(function()
        return Game:HttpGet(Github .. "?nocache=" .. os_clock())
    end)

    if not Success then warn("Failed to fetch commit logs~") return nil end

    local Commits = {}
    local StartPoint = 1

    while true do
        local Entry = Response:match("<entry>(.-)</entry>", StartPoint)
        if not Entry then break end

        local Author = StripString(Entry:match("<name>(.-)</name>"))
        local Message = StripString(Entry:match("<title>(.-)</title>"))
        local Updated = Entry:match("<updated>(.-)</updated>")
        local FullSha = StripString(Entry:match("<id>.-[Cc]ommit/(.-)</id>"))
        local Sha = FullSha and FullSha:sub(1, 7) or "Unknown"

        if Updated and FullSha then
            local commitTime = DateTime.fromIsoDate(Updated)
            local now = DateTime.now()
            local timeAgo = self:HowLong(now.UnixTimestamp - commitTime.UnixTimestamp)

            table_insert(Commits, {
                Author = Author,
                Message = Message,
                Sha = Sha,
                FullSha = FullSha,
                TimeAgo = timeAgo,
                Timestamp = commitTime,
                RawDate = Updated,
                Version = #Commits + 1
            })
        end

        StartPoint = Response:find("</entry>", StartPoint) + 8
        if #Commits >= Version then break end
    end

    if Version then
        if Commits[Version] then
            return Commits[Version]
        else
            warn("Version " .. Version .. " not found. Only " .. #Commits .. " commits available.")
            return nil
        end
    else
        return Commits[1] or nil
    end
end

function API:UpdateTrack(FilePath, RemoteUrl, OnDownloaded, OnChanged, Options)
    task_spawn(function()
        Options = Options or {}
        local MaxSize = Options.MaxSize or math_huge
        
        local FileName = FilePath:match("[^/]+$")
        local Dir = FilePath:match("^(.+)/[^/]+$")
        if Dir then
            local path = ""
            for folder in Dir:gmatch("[^/]+") do
                path = path .. folder .. "/"
                if not is_folder(path) then make_folder(path) end
            end
        end
        
        local Success, Remote = pcall(function()
            return Game:HttpGet(RemoteUrl .. "?v=" .. os_time())
        end)
        if not Success then return warn("[Update Tracker]: Failed: " .. RemoteUrl) end
        
        local StoredContent = Remote
        local Truncated = false
        if #Remote > MaxSize then
            StoredContent = Remote:sub(1, MaxSize)
            Truncated = true
        end
        
        local Exists = is_file(FilePath)
        local Old = Exists and read_file(FilePath) or nil
        local Changed = Exists and Old ~= StoredContent
        
        write_file(FilePath, StoredContent)
        
        if not Exists and OnDownloaded then
            OnDownloaded({FileName = FileName, Content = Remote, Size = #Remote, StoredSize = #StoredContent, Truncated = Truncated})
        elseif Changed and OnChanged then
            OnChanged({FileName = FileName, Content = Remote, OldSize = #Old, NewSize = #Remote, Truncated = Truncated})
        end
        
        return {FileName = FileName, Changed = Changed, New = not Exists, Content = Remote, StoredSize = #StoredContent}
    end)
end

function API:AbbreviateNumber(Number, ShownDigits)
    local Suffixes = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "O", "N", "De",
    "Ud", "Dd", "TdD", "QdD", "QnD", "SxD", "SpD", "OcD", "NvD"}

    local Prefix = ""
    ShownDigits = ShownDigits or 3

    if Number < 0 then
        Number = math_abs(Number)
        Prefix = "-"
    end

    local Intial = ("%.0f"):format(Number)
    local Digits = #Intial

    if Digits <= 3 then
        return Prefix .. Intial
    end

    local Suffix: string? = Suffixes[math_ceil(Digits / 3)]
    local Decimal_Position = (Digits - 1) % 3 + 1

    if not Suffix then
        Suffix = "e" .. math_ceil((Digits - 3) / 3) * 3
    end

    local Abbreviated_Number = string_sub(Intial, 1, Decimal_Position)
    if Decimal_Position < ShownDigits then
        Abbreviated_Number ..= "." .. string_sub(Intial, Decimal_Position + 1, ShownDigits)
    end

    return Prefix .. Abbreviated_Number .. Suffix
end

function API:GetAveragePosition(Targets)
    local TotalX, TotalY, TotalZ = 0, 0, 0
    local Count = 0
    
    local Index, Target = next(Targets)
    while Index do
        local Pos = self:ResolvePosition(Target)
        if Pos then
            TotalX = TotalX + Pos.X
            TotalY = TotalY + Pos.Y
            TotalZ = TotalZ + Pos.Z
            Count = Count + 1
        end
        Index, Target = next(Targets, Index)
    end
    
    if Count == 0 then return nil end
    
    local InvCount = 1 / Count
    return Vector3_new(TotalX * InvCount, TotalY * InvCount, TotalZ * InvCount)
end

function API:RandomVector3(RangeX, RangeY, RangeZ)
    if typeof(RangeX) == "table" then
        if RangeX.X and RangeX.Y and RangeX.Z then
            return Vector3_new(
                math_random(-RangeX.X, RangeX.X),
                math_random(-RangeX.Y, RangeX.Y),
                math_random(-RangeX.Z, RangeX.Z)
            )
        elseif RangeX[1] and RangeX[2] and RangeX[3] then
            return Vector3_new(
                math_random(-RangeX[1], RangeX[1]),
                math_random(-RangeX[2], RangeX[2]),
                math_random(-RangeX[3], RangeX[3])
            )
        end
    end
    
    RangeX = RangeX or 100
    RangeY = RangeY or RangeX
    RangeZ = RangeZ or RangeX
    
    return Vector3_new(
        math_random(-RangeX, RangeX),
        math_random(-RangeY, RangeY),
        math_random(-RangeZ, RangeZ)
    )
end

function API:RandomDirection()
    return Vector3_new(math_random() - 0.5, math_random() - 0.5, math_random() - 0.5).Unit
end

function API:FindCore(Name)
    return CoreGui:FindFirstChild(Name, true)
        or LocalPlayer.PlayerGui:FindFirstChild(Name, true)
        or (CoreGui.RobloxGui and CoreGui.RobloxGui:FindFirstChild(Name, true))
end

function API:LoadDictionaries()
    local Words_Data = self:LoadData("@EnglishDictionary/Words.json")
    if Words_Data then
        self.English_Dictionary = Words_Data
    else
        local Success, Data = pcall(function()
            return Game:HttpGet("https://raw.githubusercontent.com/words/an-array-of-english-words/master/index.json")
        end)

        if Success and Data then
            local Decoded = HttpService:JSONDecode(Data)
            self.English_Dictionary = {}
            for _, Word in ipairs(Decoded) do
                self.English_Dictionary[Word:lower()] = true
            end
            self:SaveData("@EnglishDictionary/Words.json", self.English_Dictionary)
        else
            self.English_Dictionary = {}
        end
    end

    local Names_Data = self:LoadData("@EnglishDictionary/Names.json")
    if Names_Data then
        self.Names_Dictionary = Names_Data
    else
        local Success, Data = pcall(function()
            return Game:HttpGet("https://raw.githubusercontent.com/smashew/NameDatabases/master/NamesDatabases/first%20names/all.txt")
        end)

        if Success and Data then
            self.Names_Dictionary = {}
            for Name in Data:gmatch("[^\r\n]+") do
                if Name ~= "" then
                    self.Names_Dictionary[Name:lower()] = true
                end
            end
            self:SaveData("@EnglishDictionary/Names.json", self.Names_Dictionary)
        else
            self.Names_Dictionary = {}
        end
    end

    return (self.English_Dictionary and self.Names_Dictionary)
end

function API:IsDictionary(Word)
    if not Word or Word == "" then return false end
    Word = Word:lower()

    if not self.English_Dictionary or not self.Names_Dictionary then
        self:LoadDictionaries()
    end

    return (self.English_Dictionary[Word] == true) or (self.Names_Dictionary[Word] == true)
end

function API:AutoCorrect(String)
    if not String or String == "" then return "" end

    local SplitWords = {}
    for Word in String:gmatch("%S+") do
        local CleanWord = Word:gsub("[%p]+$", "")
        local TrailingPunctuation = Word:match("[%p]+$") or ""
        table_insert(SplitWords, {word = CleanWord, punct = TrailingPunctuation, original = Word})
    end

    local ProcessedWords, NextWordCapitalized = {}, true

    local Titles = {
        "mr", "mrs", "ms", "miss", "mx", "dr", "doc", "doctor", "prof", "professor",
        "phd", "md", "dds", "dvm", "jd", "esq", "attorney", "lawyer", "judge",
        "justice", "chief", "head", "dean", "principal", "superintendent", "director",
        "chair", "chairman", "chairwoman", "chairperson", "president", "vice president",
        "ceo", "cfo", "coo", "cto", "executive", "manager", "supervisor", "coordinator",
        "administrator", "officer", "agent", "special agent", "detective", "inspector",
        "sergeant", "lieutenant", "captain", "major", "colonel", "general", "admiral",
        "commander", "lieutenant commander", "ensign", "petty officer", "seaman",
        "corporal", "sergeant major", "staff sergeant", "master sergeant", "warrant officer",
        "brigadier", "brigadier general", "major general", "lieutenant general",
        "general of the army", "fleet admiral", "rear admiral", "vice admiral",
        "private", "soldier", "cadet", "midshipman", "recruit", "veteran",
        "senator", "representative", "congressman", "congresswoman", "ambassador",
        "governor", "lieutenant governor", "mayor", "councilman", "councilwoman",
        "alderman", "minister", "prime minister", "chancellor", "secretary",
        "secretary of state", "treasurer", "attorney general", "solicitor general",
        "speaker", "majority leader", "minority leader", "whip", "chief of staff",
        "king", "queen", "prince", "princess", "duke", "duchess", "marquis", "marchioness",
        "earl", "countess", "viscount", "viscountess", "baron", "baroness", "sir", "dame",
        "lord", "lady", "master", "madam", "madame", "monsieur", "herr", "frau", "fräulein",
        "signor", "signora", "signorina", "don", "doña", "dom", "dona", "rajah", "ranee",
        "sultan", "sultana", "emir", "sheikh", "sheikha", "caliph", "pharaoh", "kaiser",
        "tsar", "tsarina", "emperor", "empress", "archduke", "archduchess", "grand duke",
        "pope", "cardinal", "archbishop", "bishop", "priest", "pastor", "minister",
        "reverend", "rabbi", "imam", "sheikh", "mufti", "ayatollah", "grand mufti",
        "monsignor", "deacon", "archdeacon", "canon", "vicar", "chaplain", "missionary",
        "evangelist", "apostle", "prophet", "guru", "swami", "lama", "dalai lama",
        "monk", "nun", "friar", "abbot", "abbess", "prior", "prioress", "elder",
        "nurse", "rn", "lpn", "np", "pa", "therapist", "psychologist", "psychiatrist",
        "counselor", "social worker", "paramedic", "emt", "surgeon", "anesthesiologist",
        "cardiologist", "neurologist", "pediatrician", "oncologist", "radiologist",
        "veterinarian", "vet", "chiropractor", "optometrist", "dentist", "orthodontist",
        "pharmacist", "pathologist", "urologist", "gynecologist",
        "teacher", "instructor", "lecturer", "assistant professor", "associate professor",
        "adjunct professor", "emeritus", "fellow", "scholar", "researcher", "scientist",
        "historian", "philosopher", "mathematician", "physicist", "chemist", "biologist",
        "astronomer", "geologist", "economist", "sociologist", "psychologist", "linguist",
        "esquire", "counsel", "barrister", "solicitor", "advocate", "prosecutor",
        "defense attorney", "public defender", "district attorney", "da", "clerk", "bailiff",
        "magistrate", "justice of the peace", "notary", "notary public", "paralegal",
        "boss", "foreman", "team lead", "project manager", "product manager",
        "program manager", "scrum master", "agile coach", "owner", "founder",
        "co-founder", "partner", "principal", "associate", "analyst", "specialist",
        "administrator", "consultant", "advisor", "strategist", "planner",
        "honorable", "hon", "the honorable", "excellency", "your excellency", "grace",
        "your grace", "highness", "your highness", "majesty", "your majesty", "eminence",
        "your eminence", "holiness", "your holiness", "beatitude", "your beatitude",
        "dad", "father", "mom", "mother", "grandpa", "grandmother", "grandma",
        "uncle", "aunt", "cousin", "nephew", "niece", "brother", "sister", "husband",
        "wife", "fiance", "fiancee", "partner", "significant other", "parent", "guardian",
        "coach", "trainer", "instructor", "guide", "mentor", "tutor", "advisor",
        "assistant", "aide", "deputy", "vice", "acting", "interim", "temporary",
        "honorary", "emeritus", "retired", "former", "late", "young", "little",
        "gentleman", "lady", "young lady", "young man", "ma'am", "mommy"
    }

    for Index, CurrentWord in ipairs(SplitWords) do
        local BaseWord = CurrentWord.word
        local LowerBaseWord, NeedsCapital = BaseWord:lower(), false
        local PreviousWord = Index > 1 and SplitWords[Index-1].word or ""
        local PreviousLower = PreviousWord:lower()

        if Index == 1 then
            NeedsCapital = true
        elseif NextWordCapitalized then
            NeedsCapital = true
        end

        if LowerBaseWord == "i" then
            NeedsCapital = true
        end

        if Index > 1 and not NeedsCapital then
            for _, TitleName in ipairs(Titles) do
                if PreviousLower == TitleName then
                    NeedsCapital = true
                    break
                end
            end
        end

        local IsTitleWord = false
        for _, TitleName in ipairs(Titles) do
            if LowerBaseWord == TitleName then
                IsTitleWord = true
                NeedsCapital = true
                break
            end
        end

        local IsCommonWord = self.English_Dictionary and self.English_Dictionary[LowerBaseWord] == true

        local IsName = false
        if not IsCommonWord then
            IsName = self:IsDictionary(BaseWord) and self.Names_Dictionary[LowerBaseWord] == true
        end

        if IsTitleWord or NeedsCapital then
            BaseWord = BaseWord:sub(1, 1):upper() .. BaseWord:sub(2):lower()
        elseif IsName then
            BaseWord = BaseWord:sub(1, 1):upper() .. BaseWord:sub(2):lower()
        else
            BaseWord = BaseWord:lower()
        end

        table_insert(ProcessedWords, BaseWord .. CurrentWord.punct)

        if CurrentWord.punct:match("[.!?]") then
            NextWordCapitalized = true
        else
            NextWordCapitalized = false
        end
    end

    local FinalText = table_concat(ProcessedWords, " ")
    FinalText = FinalText:gsub("%s+([%.,%?%!;:])", "%1")
    FinalText = FinalText:gsub("([%.,%?%!;:])(%w)", "%1 %2")

    if not FinalText:match("[%p]$") and FinalText:match("%w$") then
        FinalText = FinalText .. "."
    end

    return FinalText
end

function API:Reverseify(String)
    if not String or String == "" then return "" end
    
    local Words = {}
    for Word in String:gmatch("%S+") do
        table_insert(Words, Word)
    end
    
    local ReversedWords = {}
    for i = #Words, 1, -1 do
        local Word = Words[i]
        local ReversedWord = ""
        for j = #Word, 1, -1 do
            ReversedWord = ReversedWord .. Word:sub(j, j)
        end
        table_insert(ReversedWords, ReversedWord)
    end
    
    local Result = table_concat(ReversedWords, " ")
    
    return Result
end

function API:Nerdify(Text)
    if not Text or Text == "" then return "Erm, actually... ☝️🤓" end

    local Corrected = self:AutoCorrect(Text)
    
    Corrected = Corrected:gsub("%.$", "")
    
    local Words = {}
    for Word in Corrected:gmatch("%S+") do
        table_insert(Words, Word)
    end

    local Prefixes = {
        "Erm, actually, ",
        "Erm... Actually, ",
        "Well, ackshually, ",
        "Um, actually, ",
        "Erm, technically, ",
        "Well, technically speaking, ",
        "To be pedantic, ",
        "If we want to be precise, ",
        "I hate to be that guy, but ",
        "Well, if you want to get technical, ",
        "Actually, if you look at the facts, ",
        "Erm, excuse me, but ",
        "Well, according to my sources, ",
    }
    
    local Suffixes = {
        " ☝️🤓",
        " ☝️🤓 *adjusts glasses*",
        " ☝️🤓 *pushes up glasses*",
        " ☝️🤓 *snorts*",
        " ☝️🤓 *clears throat*",
        " ☝️🤓 *nods pedantically*",
        " ☝️🤓 hehe",
        " ☝️🤓 just saying",
        " ☝️🤓 fun fact",
        " ☝️🤓 the more you know",
    }
    
    local Prefix = ""
    if #Words > 4 then
        Prefix = Prefixes[math_random(1, #Prefixes)]
    elseif #Words > 2 then
        if math_random() < 0.5 then
            Prefix = Prefixes[math_random(1, #Prefixes)]
        end
    end

    if math_random() < 0.15 then
        Corrected = Corrected .. " hehe"
    end

    if math_random() < 0.05 then
        Prefix = "Erm, " .. Prefix:lower()
    end
    
    local Suffix = Suffixes[math_random(1, #Suffixes)]
    
    return Prefix .. Corrected:sub(1, 1):upper() .. Corrected:sub(2) .. Suffix
end

function API:Uwuify(Text)
    if not Text or Text == "" then return "uwu" end
    
    local Result = Text:lower()
    
    Result = Result:gsub("[rl]", "w")
    Result = Result:gsub("th", "d")
    Result = Result:gsub("you", "uwu")
    Result = Result:gsub("n([aeiou])", "ny%1")
    Result = Result:gsub("m([aeiou])", "my%1")
    Result = Result:gsub("ove", "uv")
    Result = Result:gsub("ck", "cc")
    
    local Words = {}
    for Word in Result:gmatch("%S+") do
        table_insert(Words, Word)
    end
    
    if #Words > 0 then
        local firstWord = Words[1]
        local stutterCount = math_random(1, 2)
        local stuttered = ""
        for i = 1, stutterCount do
            stuttered = stuttered .. firstWord:sub(1, 1) .. "-"
        end
        Words[1] = stuttered .. firstWord
    end
    
    Result = table_concat(Words, " ")
    
    local Suffixes = {" >w<", " uwu", " owo", " ^w^", " :3", "~", " Meow~"}
    Result = Result .. Suffixes[math_random(1, #Suffixes)]
    
    return Result
end

function API:GetTimeOfDay()
    local Hour = tonumber(os_date("%H"))
    if Hour >= 6 and Hour < 12 then
        return "Morning"
    elseif Hour >= 12 and Hour < 18 then
        return "Afternoon"
    elseif Hour >= 18 and Hour < 22 then
        return "Evening"
    else
        return "Night"
    end
end

function API:Trim(String)
    return string_match(String, "^%s*(.-)%s*$")
end

function API:GetRandomNumber(Min, Max)
    return math_random(Min, Max)
end

function API:Chance(Percent)
    return math_random(1, 100) <= Percent
end

function API:Percent(Current, Max)
    if Max <= 0 then return 0 end
    return (Current / Max) * 100
end

function API:IsBetween(Value, Min, Max)
    return Value >= Min and Value <= Max
end

function API:IsNumeric(String)
    return string_match(String, "^%d+$") ~= nil
end

function API:IsURL(String)
    return String:match("^https?://[%w-.]+%.[a-zA-Z]{2,}(/.*)?$") ~= nil
end

function API:IsEmail(String)
    return String:match("^[%w._-]+@[%w.-]+%.[a-zA-Z]{2,}$") ~= nil
end

function API:Try(Func, Default, ErrorHandler)
    if typeof(Func) ~= "function" then
        return false, nil
    end

    local Success, Result = pcall(Func)
    
    if Success then
        return true, Result, nil
    else
        local ErrMsg = tostring(Result)
        
        if typeof(ErrorHandler) == "function" then
            pcall(ErrorHandler, ErrMsg)
        end
        
        if Default ~= nil then
            return false, Default, ErrMsg
        end
        
        return false, nil, ErrMsg
    end
end

function API:TryMultiple(...)
    local Functions = {...}

    for i = 1, #Functions do
        local Func = Functions[i]
        if typeof(Func) == "function" then
            local Success, Result = pcall(Func)
            if Success then
                return true, Result, i
            end
        end
    end

    return false, nil
end

function API:ResolvePosition(...)
    local args = {...}
    local numArgs = #args
    
    if numArgs >= 3 and typeof(args[1]) == "number" and typeof(args[2]) == "number" and typeof(args[3]) == "number" then
        return Vector3_new(args[1], args[2], args[3])
    end

    if numArgs >= 2 and typeof(args[1]) == "number" and typeof(args[2]) == "number" then
        return Vector3_new(args[1], args[2], numArgs >= 3 and args[3] or 0)
    end

    local arg = args[1]
    
    local function ExtractNumbers(String)
        local Numbers = {}
        for Number in string_gmatch(String, "(-?%d+%.?%d*)") do
            table_insert(Numbers, tonumber(Number))
        end
        return Numbers
    end

    local function ConvertV3(x, y, z)
        if typeof(x) == "number" and typeof(y) == "number" then
            return Vector3_new(x, y, z or 0)
        end
        return nil
    end

    if arg == nil then
        return nil
    end

    local argType = typeof(arg)
    
    if argType == "Vector3" then
        return arg
    end
    
    if argType == "CFrame" then
        return arg.Position
    end
    
    if typeof(arg) == "number" then
        return Vector3_new(arg, 0, 0)
    end
    
    if argType == "Instance" then
        local function GetPosition(Instance)
            if not Instance then return nil end
        
            if Instance:IsA("BasePart") then
                return Instance.Position
            end

            if Instance:IsA("BackpackItem") or Instance:IsA("Tool") then
                local Handle = Instance:FindFirstChild("Handle")
                if Handle and Handle:IsA("BasePart") then
                    return Handle.Position
                end
                local BasePart = Instance:FindFirstChildWhichIsA("BasePart")
                if BasePart then
                    return BasePart.Position
                end
                local Pivot = pcall(Instance.GetPivot, Instance)
                if Pivot then return Pivot.Position end
            end
            
            if Instance:IsA("Model") then
                if Instance.PrimaryPart and Instance.PrimaryPart:IsA("BasePart") then
                    return Instance.PrimaryPart.Position
                end
                local Roots = Instance:FindFirstChild("HumanoidRootPart")
                if Roots and Roots:IsA("BasePart") then
                    return Roots.Position
                end
            end
            
            if Instance:IsA("Player") and Instance.Character then
                local Roots = Instance.Character:FindFirstChild("HumanoidRootPart")
                if Roots then
                    return Roots.Position
                end
                local Pivot = pcall(Instance.Character.GetPivot, Instance.Character)
                if Pivot then return Pivot.Position end
            end

            if Instance:IsA("Humanoid") and Instance.Parent then
                local Roots = Instance.Parent:FindFirstChild("HumanoidRootPart")
                if Roots then
                    return Roots.Position
                end
                local Pivot = pcall(Instance.Parent.GetPivot, Instance.Parent)
                if Pivot then return Pivot.Position end
            end

            if Instance.GetPivot then
                local Pivot = pcall(Instance.GetPivot, Instance)
                if Pivot and typeof(Pivot) == "CFrame" then
                    return Pivot.Position
                end
            end

            local BasePart = Instance:FindFirstChildWhichIsA("BasePart")
            if BasePart then
                return BasePart.Position
            end
            
            local function RecursivePart(inst)
                for _, Child in ipairs(inst:GetChildren()) do
                    if Child:IsA("BasePart") then
                        return Child.Position
                    end
                    local Found = RecursivePart(Child)
                    if Found then return Found end
                end
                return nil
            end

            return RecursivePart(Instance)
        end

        local Result = GetPosition(arg)
        if Result then return Result end
    end

    if typeof(arg) == "table" then
        for _, Vector in ipairs({"position", "Position", "pos", "Pos", "p", "vector", "Vector", "location", "Location"}) do
            if arg[Vector] and typeof(arg[Vector]) == "Vector3" then
                return arg[Vector]
            end
        end

        if arg.CFrame and typeof(arg.CFrame) == "CFrame" then
            return arg.CFrame.Position
        end

        local x, y, z = (arg.x or arg.X or arg[1] or 0), (arg.y or arg.Y or arg[2] or 0), (arg.z or arg.Z or arg[3] or 0)

        if typeof(x) == "number" and typeof(y) == "number" then
            return ConvertV3(x, y, z)
        end

        if #arg >= 3 then
            return ConvertV3(arg[1], arg[2], arg[3])
        end

        for _, Value in pairs(arg) do
            if typeof(Value) == "table" then
                local Nested = API:ResolvePosition(Value)
                if Nested then return Nested end
            end
        end
    end
    
    if typeof(arg) == "string" then
        local String = arg:gsub("%s+", " "):gsub(",", " "):gsub("%(", " "):gsub("%)", " ")

        local Patterns = {
            "(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)",
            "[Vv]ector3?%s*[%(%[]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)%s*[%)%]]",
            "[Cc]frame.*%s*[%(%[]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)",
            "(-?%d+%.?%d*)%s*[,]%s*(-?%d+%.?%d*)%s*[,]%s*(-?%d+%.?%d*)",
            "(-?%d+%.?%d*),(-?%d+%.?%d*),(-?%d+%.?%d*)",
        }
        
        for _, Pattern in ipairs(Patterns) do
            local x, y, z = String:match(Pattern)
            if x and y and z then
                return ConvertV3(tonumber(x), tonumber(y), tonumber(z))
            end
        end

        local Numbers = ExtractNumbers(String)
        if #Numbers >= 3 then
            return ConvertV3(Numbers[1], Numbers[2], Numbers[3])
        elseif #Numbers == 2 then
            return ConvertV3(Numbers[1], Numbers[2], 0)
        elseif #Numbers == 1 then
            return ConvertV3(Numbers[1], 0, 0)
        end
    end
    
    if argType == "UDim2" then
        return Vector3_new(arg.X.Offset, arg.Y.Offset, 0)
    end
    
    if argType == "UDim" then
        return Vector3_new(arg.Offset, 0, 0)
    end
    
    if argType == "Ray" then
        return arg.Origin
    end

    if typeof(arg) == "userdata" then
        local Props = {"Position", "position", "Location", "location", "Origin", "origin"}
        for _, Prop in ipairs(Props) do
            if arg[Prop] and typeof(arg[Prop]) == "Vector3" then
                return arg[Prop]
            end
        end
        
        if arg.CFrame and typeof(arg.CFrame) == "CFrame" then
            return arg.CFrame.Position
        end

        if arg.GetPivot then
            local pivot = pcall(arg.GetPivot, arg)
            if pivot and typeof(pivot) == "CFrame" then
                return pivot.Position
            end
        end
    end
     
    return nil
end

function API:Spoof(Instance, Property, Value)
    if not Instance or not Property then
        return false
    end

    local Required_Functions = {
        hookmetamethod = hookmetamethod,
        newcclosure = newcclosure,
        getrawmetatable = getrawmetatable,
    }

    local Missing = {}

    for Function, Result in pairs(Required_Functions) do
        if Result == nil then
            table_insert(Missing, Function)
        end
    end

    if #Missing > 0 then
        warn("[Spoof] Failed: Missing functions: " .. table_concat(Missing, ", "))
        return false
    end

    if not self._Spoofed then
        self._Spoofed = setmetatable({}, {__mode = "k"})
    end

    self._Spoofed = self._Spoofed or {}
    self._Spoofed[Instance] = self._Spoofed[Instance] or {}
    self._Spoofed[Instance][Property] = Value

    local Local = self

    if not self._Original_Hook then
        self._Original_Hook = hookmetamethod(Game, "__index", function(Origins, Key)
            return getrawmetatable(Game).__index(Origins, Key)
        end)
    end

    self._Hook = hookmetamethod(Game, "__index", newcclosure(function(Origins, Key)
        if Local._Spoofed and Local._Spoofed[Origins] and Local._Spoofed[Origins][Key] ~= nil then
            return Local._Spoofed[Origins][Key]
        end
        return Local._Original_Hook(Origins, Key)
    end))
    
    return true
end

function API:Unspoof(Instance, Property)
    if not Instance or not Property then
        return false
    end

    self._Spoofed = self._Spoofed or {}
    
    if self._Spoofed[Instance] and self._Spoofed[Instance][Property] ~= nil then
        self._Spoofed[Instance][Property] = nil

        if next(self._Spoofed[Instance]) == nil then
            self._Spoofed[Instance] = nil
        end
        
        return true
    end
    
    return false
end

function API:ClearSpoofs()
    self._Spoofed = self._Spoofed or {}
    
    for Instance, Properties in pairs(self._Spoofed) do
        for Property, _ in pairs(Properties) do
            Properties[Property] = nil
        end
        self._Spoofed[Instance] = nil
    end

    if self._Original_Hook then
        hookmetamethod(Game, "__index", self._Original_Hook)
        self._Original_Hook = nil
        self._Hook = nil
    end

    table_clear(self._Spoofed)

    return true
end

function API:Once(Name, Callback)
    if not Name then return nil end

    if not Callback then
        Callback = Name
        Name = tostring(Name)
    end

    self._OnceFlags = self._OnceFlags or {}

    if not self._OnceFlags[Name] then
        self._OnceFlags[Name] = true

        Callback()
        return true
    end

    return false
end

function API:Schedule(Cooldown, Function)
    task_spawn(function()
        if Cooldown then
            task_wait(Cooldown)
        end
        Function()
    end)
end

function API:GetPlayer()
    return LocalPlayer
end

function API:GetCharacter()
    return Character
end

function API:GetRoot()
    return Roots
end

function API:GetHumanoid()
    return Humanoid
end

function API:GetHead()
    local Char = self:GetCharacter()
    if not Char then return nil end
    return Char:FindFirstChild("Head") or Char:WaitForChild("Head", 5)
end

function API:ForceReset()
    local Hum = self:GetHumanoid()
    if Hum then
        Hum:ChangeState(15)
    end
end

function API:GetBackpack()
    local Plr = (LocalPlayer)
    if not Plr then return nil end
    
    return Plr:FindFirstChild("Backpack") or Plr:WaitForChild("Backpack")
end

function API:GetTeam()
    local Plr = (LocalPlayer)
    return Plr.Team
end

function API:IsAlive()
    local Hum = self:GetHumanoid()
    return Hum and Hum.Health > 0
end

function API:IsAFriend(Player)
    if not Player then return false end
    return Player:IsFriendsWith(LocalPlayer.UserId)
end

function API:GetPlaceId()
    return PlaceId
end

function API:GetJobId()
    return JobId
end

function API:GetGameId()
    return GameId
end

function API:Raknet_Desync(State)
    if typeof(raknet) ~= "function" then 
        return false 
    end

    self:ClearRaknet()

    if State then
        self.RaknetHooked = true

        local function Hooking(Packet)
            if Packet.PacketId == 0x1B then
                local Data = Packet.AsBuffer

                buffer.writeu32(Data, 1, 0xFFFFFFFF)
                Packet:SetData(Data)
            end
        end

        raknet.add_send_hook(Hooking)
    
        self.Used_Raknet = Hooking
    end
    
    return true
end

function API:ClearRaknet()
    if typeof(raknet) ~= "function" then 
        return 
    end

    if self.Used_Raknet then
        raknet.remove_send_hook(self.Used_Raknet)

        self.Used_Raknet, self.RaknetHooked = nil, nil
    end
end

function API:SmartTimer(Name, Delay)
    self.Smart_Timers = self.Smart_Timers or {}

    local Tick, Last = tick(), self.Smart_Timers[Name] or 0

    if Tick - Last >= Delay then
        self.Smart_Timers[Name] = Tick;
        return true;
    end

    return false;
end

function API:WaitUntil(Condition, Out)
    local Time = 0

    while not Condition() do
        task_wait(0.1)
        Time += 0.1

        if Out and Time >= Out then
            return false
        end
    end

    return true
end

function API:Resolve(Mode, Input, Key)
    if typeof(Input) == "string" then
        return {Input}
    end

    if typeof(Input) == "table" then
        local Result = {}
        local k, v = next, Input
        while k do
            if v == true then
                Result[#Result + 1] = k
            end
            k, v = next, Input, k
        end
        Input = Result
    end

    if Mode == "Priority" then
        return self:ResolvePriority(Input, Key, true)
    elseif Mode == "Priority2" then
        return self:ResolvePriority(Input, Key, false)
    elseif Mode == "Random" then
        return self:TableShuffle(Input)
    end
    
    return Input or {}
end

function API:ResolvePriority(Result, Key, NewestFirst)
    if not Key then
        return Result
    end
    
    self.Resolved_Tables = self.Resolved_Tables or {}
    local Resolved = self.Resolved_Tables[Key] or {}

    local Current = {}
    for i = 1, #Result do
        Current[Result[i]] = true
    end
    
    local NewRec, Seen, len = {}, {}, 0
    
    for i = 1, #Resolved do
        local Item = Resolved[i]
        if Current[Item] and not Seen[Item] then
            len = len + 1
            NewRec[len] = Item
            Seen[Item] = true
        end
    end
    
    for i = 1, #Result do
        local Item = Result[i]
        if not Seen[Item] then
            len = len + 1
            NewRec[len] = Item
        end
    end
    
    self.Resolved_Tables[Key] = NewRec
    
    if NewestFirst then
        return self:TableReverse(NewRec)
    else
        return NewRec
    end
end

function API:TableShuffle(T)
    if not T or #T <= 1 then
        return T
    end

    local Shuffled = {}
    for i = 1, #T do
        Shuffled[i] = T[i]
    end
    
    for i = #Shuffled, 2, -1 do
        local j = math_random(i)
        Shuffled[i], Shuffled[j] = Shuffled[j], Shuffled[i]
    end
    return Shuffled
end

function API:TableReverse(T)
    if not T or #T <= 1 then
        return T
    end
    
    local Reversed = {}
    local len = #T
    for i = 1, len do
        Reversed[i] = T[len - i + 1]
    end
    return Reversed
end

function API:TableIsEmpty(T)
    return next(T) == nil
end

function API:TableFind(T, Predicate)
    local k, v = next, T
    while k do
        if Predicate(v, k) then return v, k end
        k, v = next, T, k
    end
    return nil
end

function API:TableValues(T)
    local Values = {}
    local k, v = next, T
    while k do
        Values[#Values + 1] = v
        k, v = next, T, k
    end
    return Values
end

function API:TableKeys(T)
    local Keys = {}
    local k, v = next, T
    while k do
        Keys[#Keys + 1] = k
        k, v = next, T, k
    end
    return Keys
end

function API:TableHas(T, Value)
    for i = 1, #T do
        if T[i] == Value then return true end
    end
    return false
end

function API:TableFirst(T)
    return T[1]
end

function API:TableLast(T)
    return T[#T]
end

function API:TableLookup(T)
    local Lookup = {}
    for i = 1, #T do
        Lookup[T[i]] = true
    end
    return Lookup
end

function API:TableMerge(T1, T2)
    local Result = {}
    for i = 1, #T1 do Result[i] = T1[i] end
    for i = 1, #T2 do Result[#Result + 1] = T2[i] end
    return Result
end

function API:TableAdd(T, Value)
    for i = 1, #T do
        if T[i] == Value then return false end
    end
    T[#T + 1] = Value
    return true
end

function API:TableRemove(T, Value)
    for i = #T, 1, -1 do
        if T[i] == Value then
            table_remove(T, i)
            return true
        end
    end
    return false
end

function API:TableClear(T)
    for i = #T, 1, -1 do
        T[i] = nil
    end
end

function API:Tween(Target: BasePart?, Property: string, Goal: any,
                      Duration: number?, EasingStyle: Enum.EasingStyle?,
                      EasingDirection: Enum.EasingDirection?, Repeats: number?,
                      Reverse: boolean?, Delay: number?)
    Duration = Duration or 1
    EasingStyle = EasingStyle or Enum.EasingStyle.Linear
    EasingDirection = EasingDirection or Enum.EasingDirection.Out
    Repeats = Repeats or 0
    Reverse = Reverse or false
    Delay = Delay or 0

    local Char = self:GetCharacter()
    Target = Target or self:GetRoot()

    if not Target then return end
    local Info = TweenInfo.new(Duration, EasingStyle, EasingDirection, Repeats, Reverse, Delay)
    local Tween = TweenService:Create(Target, Info, {[Property] = Goal})
    Tween:Play()

    return Tween
end

function API:GetTools()
    local Tools = {}
    
    for _, tool in ipairs(self:GetBackpack():GetChildren()) do
        if tool:IsA("Tool") then
            table_insert(Tools, tool)
        end
    end
    
    local Char = self:GetCharacter()
    if Char then
        for _, tool in ipairs(Char:GetChildren()) do
            if tool:IsA("Tool") then
                table_insert(Tools, tool)
            end
        end
    end
    
    return Tools
end

function API:GetToolCount()
    return #self:GetTools()
end

function API:HasTool(Name)
    if not Name then
        return #self:GetTools() > 0
    end

    local Lower = string_lower(Name)
    for _, Tool in ipairs(self:GetTools()) do
        if string_lower(Tool.Name) == Lower then
            return true
        end
    end
    return false
end

function API:FindTool(Name, Exact)
    if not Name then
        return self:GetHeldTool()
    end
    
    local Lower = string_lower(Name)
    for _, Tool in ipairs(self:GetTools()) do
        local ToolName = string_lower(Tool.Name)
        
        if Exact then
            if ToolName == Lower then
                return Tool
            end
        else
            if ToolName:find(Lower, 1, true) then
                return Tool
            end
        end
    end
    
    return nil
end

function API:EquipTool(Name)
    if not Name then
        return true
    end
    
    local Tool = self:FindTool(Name)
    if not Tool then
        return false
    end

    local Character = self:GetCharacter()
    local Backpack = self:GetBackpack()
    if not Character or not Backpack then return false end

    local HeldTool = self:GetHeldTool()

    if HeldTool and HeldTool.Name == Name then
        return true
    end

    if HeldTool then
        HeldTool.Parent = Backpack
    end

    if Tool.Parent == Backpack then
        Tool.Parent = Character
        return true
    end

    return false
end

function API:UnequipTool(Name)
    if not Name then
        return self:UnequipHeldTool()
    end

    local Tool = self:FindTool(Name)
    if not Tool then
        return false
    end
    
    if Tool.Parent == self:GetCharacter() then
        Tool.Parent = self:GetBackpack()
        return true
    end
    
    return false
end

function API:UnequipHeldTool()
    local HeldTool = self:GetHeldTool()
    if not HeldTool then
        return false
    end
    
    if HeldTool.Parent == self:GetCharacter() then
        HeldTool.Parent = self:GetBackpack()
        return true
    end
    
    return false
end

function API:UseTool(Name)
    if not Name then
        return self:UseHeldTool()
    end
    
    local Tool = self:FindTool(Name)
    if not Tool then
        return false
    end

    local HeldTool = self:GetHeldTool()

    if HeldTool == Tool then
        if HeldTool.Enabled ~= false then
            HeldTool:Activate()
            return true
        end
        return false
    end

    self:EquipTool(Name)
    task_wait(0.12)

    HeldTool = self:GetHeldTool()

    if HeldTool == Tool and HeldTool.Enabled ~= false then
        HeldTool:Activate()
        return true
    end

    return false
end

function API:UseHeldTool()
    local HeldTool = self:GetHeldTool()
    if not HeldTool then
        return false
    end

    if HeldTool.Enabled ~= false then
        HeldTool:Activate()
        return true
    end

    return false
end

function API:GetHeldTool()
    local Char = self:GetCharacter()
    if Char then
        return Char:FindFirstChildWhichIsA("Tool")
    end
    return nil
end

function API:AddPriority(Name, Priority, Group, Condition, Action)
    self.Priorities = self.Priorities or {}

    table_insert(self.Priorities, {
        Name = Name,
        Priority = Priority,
        BasePriority = Priority,
        Group = Group or "Base",
        Condition = Condition,
        Action = Action,
        Flags = {}
    })

    table_sort(self.Priorities, function(a, b)
        return a.Priority > b.Priority
    end)
end

function API:SetCurrentTask(Name)
    local OldTask = self.CurrentTask
    self.CurrentTask = Name
    
    if self.OnTaskSwitch then
        self:OnTaskSwitch(OldTask, Name)
    end

    return OldTask
end

function API:GetCurrentTask()
    return self.CurrentTask
end

function API:OnTaskSwitch(OldTask, NewTask)
    if self.TaskSwitchCallbacks then
        for _, Callback in ipairs(self.TaskSwitchCallbacks) do
            Callback(OldTask, NewTask)
        end
    end
end

function API:RegisterSwitchCallback(Callback)
    self.TaskSwitchCallbacks = self.TaskSwitchCallbacks or {}
    table_insert(self.TaskSwitchCallbacks, Callback)
end

function API:ForceTask(Name)
    for _, Task in ipairs(self.Priorities or {}) do
        if Task.Name == Name then
            self.TaskOnce = Task

            local OldTask = self:SetCurrentTask(Task.Name)

            Task.Action()

            self.TaskOnce = nil
            return true
        end
    end
    return false
end

function API:ForceGroup(Group)
    self.ForcedGroup = Group
end

function API:ClearForcedGroup()
    self.ForcedGroup = nil
end

function API:GetTasks()
    if self.ForcedGroup then
        for _, Task in ipairs(self.Priorities) do
            if Task.Group == self.ForcedGroup and Task.Condition() then
                return Task
            end
        end
        return nil
    end

    for _, Task in ipairs(self.Priorities) do
        if Task.Condition() then
            return Task
        end
    end
    return nil
end

function API:GetTaskByGroup(Group)
    local Tasks = {}
    for _, Task in ipairs(self.Priorities or {}) do
        if Task.Group == Group then
            table_insert(Tasks, Task)
        end
    end
    return Tasks
end

function API:SetPriority(Name, NewPriority)
    for _, Task in ipairs(self.Priorities or {}) do
        if Task.Name == Name then
            Task.Priority = NewPriority

            table_sort(self.Priorities, function(a, b)
                return a.Priority > b.Priority
            end)
            return true
        end
    end
    return false
end

function API:ResetPriority(Name)
    for _, Task in ipairs(self.Priorities or {}) do
        if Task.Name == Name then
            Task.Priority = Task.BasePriority

            table_sort(self.Priorities, function(a, b)
                return a.Priority > b.Priority
            end)
            return true
        end
    end
    return false
end

function API:Task_Once(Name, Callback)
    local Selected = self.TaskOnce
    if not Selected then
        Callback()
        return
    end

    if not Selected.Flags[Name] then
        Selected.Flags[Name] = true
        Callback()
    end
end

function API:RunTasks()
    local Tasks = self:GetTasks()
    if Tasks then
        self.TaskOnce = Tasks

        local OldTask = self:SetCurrentTask(Tasks.Name)
        Tasks.Action()

        self.TaskOnce = nil
        return Tasks.Name
    end
    
    self:SetCurrentTask(nil)
    return nil
end

function API:RunTaskByGroup(Group)
    local Tasks = self:GetTaskByGroup(Group)

    for _, Task in ipairs(Tasks) do
        if Task.Condition() then
            self.TaskOnce = Task

            local oldTask = self:SetCurrentTask(Task.Name)
            Task.Action()

            self.TaskOnce = nil
            return Task.Name
        end
    end

    self:SetCurrentTask(nil)
    return nil
end

function API:InteractUI(Button, Method, Manual)
    Manual = Manual or false

    if not Button then
        GuiService.SelectedObject = nil
        return false
    end

    if Method == "Connection" then
        if not (GetConnections) then
            GuiService.SelectedObject = nil
            return self:InteractUI(Button, "KeyEvent", Manual)
        end

        local Success = pcall(function()
            if not Button.MouseButton1Click then
                GuiService.SelectedObject = nil
                return
            end

            local MouseButton1Click_Connection = GetConnections(Button.MouseButton1Click)

            if #MouseButton1Click_Connection == 0 then GuiService.SelectedObject = nil return end
            for _, v in MouseButton1Click_Connection do
                if Manual then
                    v.Function()
                else
                    v:Fire()
                end
            end
            GuiService.SelectedObject = nil
        end)

        if not Success then
            GuiService.SelectedObject = nil
        end
        return Success
    end

    if Method == "KeyEvent" then
        local Success = pcall(function()
            GuiService.SelectedObject = Button
            task_wait()

            if GuiService.SelectedObject ~= Button then
                GuiService.SelectedObject = nil
                return
            end

            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, Game)
            task_wait()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, Game)

            GuiService.SelectedObject = nil
        end)

        if not Success then
            GuiService.SelectedObject = nil
        end
        return Success
    end

    if Method == "Mouse" then
        local Success = pcall(function()
            if not Button.AbsolutePosition or not Button.AbsoluteSize then
                GuiService.SelectedObject = nil
                return
            end
            
            local Absolute_Position, Absolute_Size = Button.AbsolutePosition, Button.AbsoluteSize
            local Center_X = Absolute_Position.X + Absolute_Size.X / 2
            local Center_Y = Absolute_Position.Y + Absolute_Size.Y / 2

            VirtualInputManager:SendMouseButtonEvent(Center_X, Center_Y, 0, true, Game, 1)
            task_wait()
            VirtualInputManager:SendMouseButtonEvent(Center_X, Center_Y, 0, false, Game, 1)
            GuiService.SelectedObject = nil
        end)
        if not Success then
            GuiService.SelectedObject = nil
        end
        return Success
    end

    if Method == "Fallback" or Method == nil then
        for _, MethodType in ipairs({"Connection", "KeyEvent", "Mouse"}) do
            if self:InteractUI(Button, MethodType, Manual) then
                return true
            end
        end
        GuiService.SelectedObject = nil
        return false
    end
    
    GuiService.SelectedObject = nil
    return false
end

function API:Press(Key)
    VirtualInputManager:SendKeyEvent(true, Key, false, Game)
end

function API:Unpress(Key)
    VirtualInputManager:SendKeyEvent(false, Key, false, Game)
end

function API:Click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, Game, 0)
    task_wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, Game, 0)
end

function API:SetFpsCap(Fps)
    if typeof(setfpscap) == "function" then 
		setfpscap(Fps) 
	end
end

function API:AntiAFK()
    if global.AFK_Service then return end

    if (GetConnections) then
        for _, Con in pairs(GetConnections(LocalPlayer.Idled)) do
            if Con.Disable then Con:Disable();
            elseif Con.Disconnect then
                Con:Disconnect();
            end
        end
    else
        LocalPlayer.Idled:Connect(function()
            self:Press(Enum.KeyCode.F5)
            task_wait(0.05)
            self:Unpress(Enum.KeyCode.F5)
        end)
    end

    global.AFK_Service = true
end

function API:Sit(State)
    local Hum = self:GetHumanoid()
    if not Hum then return end
    
    self.IsSeating = State
    Hum.Sit = State
end

function API:StopSeating()
    if self.IsSeating and self:IsState(Enum.HumanoidStateType.Seated) then
        self:Sit(false)
    end
end

function API:SetTime(Amount)
    LightingService.ClockTime = Amount
end

function API:SetFOV(Num)
    CurrentCamera.FieldOfView = Num
end

function API:SetCameraType(Type)
    CurrentCamera.CameraType = Type
end

function API:SetGravity(Amount)
    Workspace.Gravity = Amount
end

function API:SetCameraOcclusion(Mode)
    local Plr = (LocalPlayer)
    if Plr then
        if Mode == "Invisicam" then
            Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        elseif Mode == "Zoom" then
            Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        else
            Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Off
        end
    end
end

function API:Zoom(Amount)
    local Plr = (LocalPlayer)
    if Plr then
        Plr.CameraMaxZoomDistance = Amount
    end
end

function API:ThirdPerson(Enabled)
    local Plr = (LocalPlayer)
    if Plr then
        Plr.CameraMode = Enabled and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
    end
end

function API:GetControlModule()
    if self.ControlModule then
        return self.ControlModule
    end
    
    local Scripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if not Scripts then return nil end
    
    local Module = PlayerScripts:FindFirstChild("PlayerModule")
    if not Module then return nil end
    
    local ControlModule = Module:FindFirstChild("ControlModule")
    if not ControlModule then return nil end

    self.ControlModule = require(ControlModule)
    return self.ControlModule
end

function API:PurchasePrompts(State)
    local Prompt = CoreGui:FindFirstChild("PurchasePromptApp")
    if Prompt then
        Prompt.Enabled = State
    end
end

function API:IsState(StateName)
    local Hum = self:GetHumanoid()
    if not Hum then return false end
    return Hum:GetState() == StateName
end

function API:SetSpeed(Amount)
    local Hum = self:GetHumanoid()
    if Hum then
        Hum.WalkSpeed = Amount
    end
end

function API:SetJumpPower(Amount)
    local Hum = self:GetHumanoid()
    if Hum then
        Hum.JumpPower = Amount
    end
end

function API:SetHipHeight(Amount)
    local Hum = self:GetHumanoid()
    if Hum then
        Hum.HipHeight = Amount
    end
end

function API:BypassWS(State, Speed)
    State = State or false
    Speed = Speed or 5
    
    self.WSData = self.WSData or {
        Active = false,
        Running = false,
        Speed = Speed,
    }
    
    local function CleanUP()
        self.WSData.Active = false
        self.WSData.Running = false
		self:_Disconnect("@TPWalk")
    end

    if not State then
        CleanUP()
        return false
    end
    
    if self.WSData.Active then
        return true
    end
    
    self.WSData.Active = true
    self.WSData.Running = true
    self.WSData.Speed = Speed
    
    local Connection = Heartbeat:Connect(function()
        if not self.WSData.Running then return end
        
        local Humanoid = self:GetHumanoid()
        if not Humanoid then return end
        
        local delta = Heartbeat:Wait()
        local moveDir = Humanoid.MoveDirection
        
        local Roots = self:GetRoot()
        if not Roots then return end
        
        if moveDir.Magnitude > 0 then
            Roots.CFrame = Roots.CFrame + (moveDir * self.WSData.Speed * delta * self.WSData.Speed)
        else
            Roots.CFrame = Roots.CFrame + (moveDir * delta * self.WSData.Speed)
        end
    end)

    self:_Connect("@TPWalk", Connection)
    return true
end

function API:SetBypassedWS(Speed)
    if not self.WSData or not self.WSData.Active then
        return false
    end
    
    self.WSData.Speed = Speed
    return true
end

function API:BypassJP(State, Amount)
    State = State or false
    Amount = Amount or 20
    
    self.JPData = self.JPData or {
        Active = false,
        Running = false,
        Amount = Amount,
    }
    
    local function CleanUP()
        self.JPData.Active = false
        self.JPData.Running = false
		self:_Disconnect("@TPJump")
    end
    
    if not State then
        CleanUP()
        return false
    end
    
    if self.JPData.Active then
        return true
    end
    
    self.JPData.Active = true
    self.JPData.Running = true
    self.JPData.Amount = Amount
    
    local Connection = Heartbeat:Connect(function()
        if not self.JPData.Running then return end
        
        local Humanoid = self:GetHumanoid()
        if not Humanoid then return end
        
        local Roots = self:GetRoot()
        if not Roots then return end
        
        if Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            Roots.CFrame = Roots.CFrame * CFrame_new(0, self.JPData.Amount, 0)
        end
    end)

    self:_Connect("@TPJump", Connection)
    return true
end

function API:SetBypassedJP(Amount)
    if not self.JPData or not self.JPData.Active then
        return false
    end
    
    self.JPData.Amount = Amount
    return true
end

function API:BringTools(Options)
    Options = Options or {}
    
    local Radius = Options.Radius or math_huge
    local Interval = Options.Interval or 0.5
    local BatchSize = Options.BatchSize or math_huge
    local Paths = Options.Paths or {workspace}

    if not Paths then
        Paths = {workspace}
    elseif typeof(Paths) ~= "table" then
        Paths = {Paths}
    end

    self:StopBringTools()

    self.BroughtTools, self.ToolsActive, Elapsed = self.BroughtTools or {}, true, 0
    
    local function Tools_Task()
        if not self.ToolsActive then return end
        
        local Humanoid = self:GetHumanoid()
        if not Humanoid then return end

        local Tools = {}

        for _, v in ipairs(Paths) do
            if v and v:IsA("Instance") then
                for _, v in ipairs(v:GetChildren()) do
                    if v:IsA("BackpackItem") and v:FindFirstChild("Handle") then
                        if not self.BroughtTools[v] then
                            local Distance = self:GetDistance(v)
                            if Distance <= Radius then
                                table_insert(Tools, v)
                            end
                        end
                    end
                end
            end
        end
        
        for i = 1, math_min(BatchSize, #Tools) do
            local v = Tools[i]
            if v and v.Parent then
                Humanoid:EquipTool(v)
                self.BroughtTools[v] = true
            end
        end
          
        for v, _ in pairs(self.BroughtTools) do
            if not v or not v.Parent then
                self.BroughtTools[v] = nil
            end
        end
    end

    self.Tools_Connection = Heartbeat:Connect(function(deltaTime)
        if not self.ToolsActive then return end

        Elapsed = Elapsed + deltaTime
        if Elapsed >= Interval then 
            Elapsed = 0
            Tools_Task()
        end
    end)
    
    self:_Connect("@BringTools", self.Tools_Connection)
    return true
end

function API:StopBringTools()
    if self.Tools_Connection then
        self:_Disconnect("@BringTools")

        self.Tools_Connection, self.ToolsActive = nil, false
        table_clear(self.BroughtTools)
    end
end

function API:AntiCollider(State)   
    if State then
        if self.AntiCollide then return true end
        self.AntiCollide = true
    
        local LPlayer = (LocalPlayer)
        if not LPlayer then 
            return false 
        end
        
        self.AntiColliderOrigin = {}
        
        local function DontCollide(Part)
            if not Part or not Part:IsA("BasePart") then return end
            
            if self.AntiColliderOrigin[Part] == nil then
                self.AntiColliderOrigin[Part] = Part.CanCollide
            end
            Part.CanCollide = false
        end

        local function HandleCharacter(Character)
            if not Character then return end
            
            for _, Part in pairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    DontCollide(Part)
                end
            end
            
            local Added_Connection = Character.DescendantAdded:Connect(function(inst)
                if inst:IsA("BasePart") then DontCollide(inst) end
            end)

            local Removed_Connection = Character.DescendantRemoving:Connect(function(inst)
                if inst:IsA("BasePart") and self.AntiColliderOrigin[inst] then
                    self.AntiColliderOrigin[inst] = nil
                end
            end)

            self:_Connect("@AntiCollider_Added: " .. tostring(Character), Added_Connection)
            self:_Connect("@AntiCollider_Removed: " .. tostring(Character), Removed_Connection)
        end

        for _, Plr in pairs(self:GetPlayers(true)) do
            if Plr ~= LPlayer and Plr.Character then
                HandleCharacter(Plr.Character)
            end
        end

        self:_Connect("@AntiCollider_Players", Players.PlayerAdded:Connect(function(Plr)
            if Plr ~= LPlayer and Plr.Character then
                HandleCharacter(Plr.Character)
            end
        end))

        self:_Connect("@AntiCollider", Heartbeat:Connect(function()
            if not self.AntiCollide then return end
            
            for Part, _ in pairs(self.AntiColliderOrigin) do
                if Part and Part.Parent and Part:IsA("BasePart") and Part.CanCollide ~= false then
                    Part.CanCollide = false
                end
            end
        end))
        
        return true
    else
        if not self.AntiCollide then return false end

        for Part, Original in pairs(self.AntiColliderOrigin or {}) do
            if Part and Part.Parent then
                pcall(function() Part.CanCollide = Original end)
            end
        end

        self:_Disconnect("@AntiCollider_Players")
        self:_Disconnect("@AntiCollider")

        for Name, _ in pairs(self._Signal or {}) do
            if typeof(Name) == "string" and (Name:match("@AntiCollider_Added: ") or Name:match("@AntiCollider_Removed: ")) then
                self:_Disconnect(Name)
            end
        end

        self.AntiCollide = nil
        self.AntiColliderOrigin = nil
        return true
    end
end

function API:AntiCFrameTeleport(State)
    if State then
        if self.AntiCFTP_Active then return true end

        self.AntiCFTP_Active = true
        self.AntiCFTP_Old = self:GetRoot() and self:GetRoot().CFrame

        local Root = self:GetRoot()
        if not Root then self.AntiCFTP_Active = false
            return false 
        end

        self:_Connect("@AntiCFTP", {
            Root.Changed:Connect(function(Property)
                if Property == "CFrame" and self.AntiCFTP_Active then
                    local Roots = self:GetRoot()
                    if Roots and self.AntiCFTP_Old then
                        Roots.CFrame = self.AntiCFTP_Old
                        task_wait()
                    end
                end
            end),

            Heartbeat:Connect(function()
                if self.AntiCFTP_Active then
                    local Roots = self:GetRoot()
                    if Roots then
                        self.AntiCFTP_Old = Roots.CFrame
                    end
                end
            end)
        })

        return true
    else
        self.AntiCFTP_Active = false
        self:_Disconnect("@AntiCFTP")
        self.AntiCFTP_Old = nil
        return true
    end
end

function API:Strengthen(State, Density)   
    Density = Density or 100
    Density = math_clamp(Density, 0.01, 100)
    
    local Character = self:GetCharacter()
    if not Character then 
        return false 
    end
    
    if not self.Strengthened then self.Strengthened = false end
    
    if State and self.Strengthened == true then return true end
    if not State and self.Strengthened == false then return true end

    local function PhysicalPropertiesV(Char, Dense, DensValue)
        local Parts = Char:GetDescendants()
        if Dense then
            for i = 1, #Parts do
                if Parts[i]:IsA("BasePart") then
                    pcall(function()
                        Parts[i].CustomPhysicalProperties = PhysicalProperties.new(DensValue, 0.3, 0.5)
                    end)
                end
            end
        else
            for i = 1, #Parts do
                if Parts[i]:IsA("BasePart") then
                    pcall(function()
                        Parts[i].CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end)
                end
            end
        end
    end

    if State then
        PhysicalPropertiesV(Character, true, Density)
        self.Strengthened = true
        self.StrengthenDensity = Density
        
        if self.StrengthenListener then
            self:_Disconnect("@StrengthListener")
            self.StrengthenListener = nil
        end

        self.StrengthenListener = LocalPlayer.CharacterAdded:Connect(function(NewChar)
            task_wait(0.5);
            PhysicalPropertiesV(NewChar, true, self.StrengthenDensity or Density)
        end)
        self:_Connect("@StrengthListener", self.StrengthenListener)
    else
        PhysicalPropertiesV(Character, false)
        self.Strengthened = false
        self.StrengthenDensity = nil

        if self.StrengthenListener then
            self:_Disconnect("@StrengthListener")
            self.StrengthenListener = nil
        end
    end

    return true
end

function API:FlightConfig(Config)
    if not self.FlightData then
        self.FlightData = {Active = false}
    end

    self.FlightData.SpeedMin = Config.SpeedMin or self.FlightData.SpeedMin or 10
    self.FlightData.SpeedMax = Config.SpeedMax or self.FlightData.SpeedMax or 500
    self.FlightData.SpeedStep = Config.SpeedStep or self.FlightData.SpeedStep or 1.5

    self.FlightData.SpeedControls = {
        Enabled = Config.SpeedControls and Config.SpeedControls.Enabled ~= nil and Config.SpeedControls.Enabled or true,
        IncreaseKey = Config.SpeedControls and Config.SpeedControls.IncreaseKey or Enum.KeyCode.Equals,
        DecreaseKey = Config.SpeedControls and Config.SpeedControls.DecreaseKey or Enum.KeyCode.Minus,
    }
    
    if self.FlightData.Active then
        self.FlightData.Speed = math_clamp(self.FlightData.Speed, 
            self.FlightData.SpeedMin, 
            self.FlightData.SpeedMax)
    end
    
    return true
end

function API:Flight(State, Speed)
    State = State or false
    
    self.FlightData = self.FlightData or {Active = false, Speed = 50, SpeedStep = 1.5, SpeedMin = 10, SpeedMax = 250}

    if not self.FlightData.SpeedControls then
        self.FlightData.SpeedControls = {Enabled = true, IncreaseKey = Enum.KeyCode.Equals, DecreaseKey = Enum.KeyCode.Minus}
    end

    local function CleanUP()
        self.FlightData.Active = false
        self:_Disconnect("@Flight")
    end
    
    if not State then
        CleanUP()
        return false
    end
    
    if self.FlightData.Active then
        return true
    end

    local Roots = self:GetRoot()

    if not Roots then
        return false
    end
    
    self.FlightData.Active = true
    
    if Speed then
        self.FlightData.Speed = math_clamp(Speed, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
    else
        self.FlightData.Speed = math_clamp(self.FlightData.Speed, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
    end
    
    local Strength = 1e9

    local BV = self:CreateInstance("BodyVelocity", { Name = self:RandomString(15),
        MaxForce = Vector3_new(Strength, Strength, Strength),
        Velocity = Vector3_zero,
        Parent = Roots
    })
    self:_Connect("@Flight", BV)

    local BG = self:CreateInstance("BodyGyro", { Name = self:RandomString(15),
        MaxTorque = Vector3_new(Strength, Strength, Strength),
        P = 3000,
        D = 500,
        CFrame = Roots.CFrame,
        Parent = Roots
    })
    self:_Connect("@Flight", BG)

    local Camera = CurrentCamera
    local ControlModule = self:IsMobile() and self:GetControlModule() or nil

    local Connection = RenderStepped:Connect(function()
        local Roots = self:GetRoot()
        if not self.FlightData.Active or not Roots or not Camera then 
            return 
        end
        
        if BV and BV.Parent ~= Roots then
            BV.Parent = Roots
        end
        if BG and BG.Parent ~= Roots then
            BG.Parent = Roots
        end
        
        local MoveDirection = Vector3_zero
    
        if ControlModule then
            local Direction = ControlModule:GetMoveVector()
            MoveDirection = (Camera.CFrame.RightVector * Direction.X) + (Camera.CFrame.LookVector * -Direction.Z)
    
            if MoveDirection.Magnitude > 0 then
                MoveDirection = MoveDirection.Unit * self.FlightData.Speed
            end
        else
            if IsKeyDown(UserInputService, Enum.KeyCode.W) then
                MoveDirection += Camera.CFrame.LookVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.S) then
                MoveDirection -= Camera.CFrame.LookVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.A) then
                MoveDirection -= Camera.CFrame.RightVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.D) then
                MoveDirection += Camera.CFrame.RightVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.Space) then
                MoveDirection += Camera.CFrame.UpVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) then
                MoveDirection -= Camera.CFrame.UpVector
            end
            
            if MoveDirection.Magnitude > 0 then
                MoveDirection = MoveDirection.Unit * self.FlightData.Speed
            end
        end

        if self.FlightData.SpeedControls and self.FlightData.SpeedControls.Enabled then
            if IsKeyDown(UserInputService, self.FlightData.SpeedControls.IncreaseKey) or IsKeyDown(UserInputService, Enum.KeyCode.KeypadPlus) then
                self.FlightData.Speed = math_clamp(self.FlightData.Speed + self.FlightData.SpeedStep, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
            elseif IsKeyDown(UserInputService, self.FlightData.SpeedControls.DecreaseKey) or IsKeyDown(UserInputService, Enum.KeyCode.KeypadMinus) then
                self.FlightData.Speed = math_clamp(self.FlightData.Speed - self.FlightData.SpeedStep, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
            end
        end
        
        BV.Velocity = MoveDirection
        BG.CFrame = Camera.CFrame
    end)

    self:_Connect("@Flight", Connection)
    return true
end

function API:SetFlightSpeed(Num)
    if not self.FlightData then
        return
    end

    self.FlightData.Speed = math_clamp(Num, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
end

function API:SetFlightMinSpeed(Num)
    if not self.FlightData then
        return false
    end
    if typeof(Num) ~= "number" or Num < 0 then
        return false
    end

    self.FlightData.SpeedMin = Num

    if self.FlightData.Speed < Num then
        self.FlightData.Speed = Num
    end
    return true
end

function API:SetFlightMaxSpeed(Num)
    if not self.FlightData then
        return false
    end
    if typeof(Num) ~= "number" or Num < 0 then
        return false
    end

    self.FlightData.SpeedMax = Num

    if self.FlightData.Speed > Num then
        self.FlightData.Speed = Num
    end
    return true
end

function API:SetFlightSpeedStep(Num)
    if not self.FlightData then
        return false
    end
    if typeof(Num) ~= "number" or Num <= 0 then
        return false
    end
    self.FlightData.SpeedStep = Num
    return true
end

function API:SetFlightSpeedControls(State)
    if not self.FlightData or not self.FlightData.SpeedControls then
        return
    end

    self.FlightData.SpeedControls.Enabled = State
end

function API:SetFlightIncreaseKey(KeyCode)
    if not self.FlightData or not self.FlightData.SpeedControls then
        return false
    end
    self.FlightData.SpeedControls.IncreaseKey = KeyCode
    return true
end

function API:SetFlightDecreaseKey(KeyCode)
    if not self.FlightData or not self.FlightData.SpeedControls then
        return false
    end
    self.FlightData.SpeedControls.DecreaseKey = KeyCode
    return true
end

function API:IsFlightActive()
    return self.FlightData and self.FlightData.Active or false
end

function API:GetFlightSpeed()
    return self.FlightData and self.FlightData.Speed or 0
end

function API:GetFlightMinSpeed()
    return self.FlightData and self.FlightData.SpeedMin or 0
end

function API:GetFlightMaxSpeed()
    return self.FlightData and self.FlightData.SpeedMax or 0
end

function API:GetFlightSpeedStep()
    return self.FlightData and self.FlightData.SpeedStep or 0
end

function API:InfiniteJump(State) 
    State = State or false

    self.JumpData = self.JumpData or { Active = false, Debounce = false }

    local function CleanUP()
        self.JumpData.Active = false
        self.JumpData.Debounce = false
		self:_Disconnect("@InfiniteJump")
    end

    if not State then
        CleanUP()
        return false
    end
    
    if self.JumpData.Active then
        return true
    end
    
    self.JumpData.Active = true
    
    local Connection = UserInputService.JumpRequest:Connect(function()
        if not self.JumpData.Debounce then
            self.JumpData.Debounce = true
            
            local Humanoid = self:GetHumanoid()

            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            
            task_wait(0.1)
            self.JumpData.Debounce = false
        end
    end)

    self:_Connect("@InfiniteJump", Connection)
    return true
end

function API:TouchFling(State)
    State = State or false
    
    self.FlingData = self.FlingData or { Active = false }

    local function CleanUP()
        self.FlingData.Active = false
		self:_Disconnect("@TouchFling")
    end
    
    if not State then
        CleanUP()
        return false
    end

    if self.FlingData.Active then
        return true
    end
    
    self.FlingData.Active = true
    local Movel = 0.1

    local Connection = Heartbeat:Connect(function()
        if not self.FlingData.Active then return end
        
        local Roots = self:GetRoot()
        if not Roots then return end
    
        local Vell = Roots.Velocity
        Roots.Velocity = Vell * 10000 + Vector3_new(0, 10000, 0)
        RenderStepped:Wait()
        Roots.Velocity = Vell
        Stepped:Wait()
        Roots.Velocity = Vell + Vector3_new(0, Movel, 0)
        
        Movel = -Movel
    end)

    self:_Connect("@TouchFling", Connection)
    return true
end

function API:FlingPlayer(Input)
    if not Input then return false end
    if self.Is_Flinging then return false end

    self.Is_Flinging = true
    local Target = nil

    local Success, Resolver1, Resolver2 = pcall(function()
        if typeof(Input) == "string" then
            Target = self:Search(Input)
        elseif typeof(Input) == "Instance" then
            Target = Input
        elseif typeof(Input) == "table" and (Input.Character or Input.Model) then
            Target = Input.Character or Input.Model or Input
        end

        if not Target then 
            return false
        end
	
		local LPlayer = (LocalPlayer)
		if Target == LPlayer or (typeof(Target) == "Instance" and Target == LPlayer.Character) then
		    return false
		end

        local Character, Humanoid, RootPart = self:GetCharacter(), self:GetHumanoid(), self:GetRoot()
        local Fling_Manager = { FlingOldPos = nil, lFlingOldPos = nil, cFlingOldPos = nil }

        local TChar = Target.Character
        if not TChar then return false end

        local THumanoid = TChar:FindFirstChild("Humanoid")
        local TRootPart = TChar:FindFirstChild("HumanoidRootPart")
        local THead = TChar:FindFirstChild("Head")
        local Acc = TChar:FindFirstChildOfClass("Accessory")
        local Handle = Acc and Acc:FindFirstChild("Handle")

        if not THumanoid then return false end
        
        local TargetPart = (TRootPart and THead and (TRootPart.Position - THead.Position).Magnitude > 5) and THead or TRootPart or THead or Handle
        if not TargetPart then return false end

        local function isAlreadyFlung(Part)
            return Part and Part.Velocity and Part.Velocity.Magnitude > 170
        end

        if isAlreadyFlung(TargetPart) then
		    return false
        end

        if not Fling_Manager.cFlingOldPos or RootPart.Velocity.Magnitude < 50 then
            Fling_Manager.cFlingOldPos = RootPart.CFrame
        end

        local OldCam_Subject = CurrentCamera.CameraSubject
        if THead then
            CurrentCamera.CameraSubject = THead
        elseif Handle then
            CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            CurrentCamera.CameraSubject = THumanoid
        end

        local OrgDestroyHeight = Workspace.FallenPartsDestroyHeight
        Workspace.FallenPartsDestroyHeight = 0/0

        local function FPos(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame_new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame_new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3_new(9e7, 9e7*10, 9e7)
            RootPart.RotVelocity = Vector3_new(9e8, 9e8, 9e8)
        end

        local function SFBasePart(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            local Is_Flunged = false
        
            repeat
                task_wait()
        
                if isAlreadyFlung(BasePart) then
                    Is_Flunged = true
                    break
                end
                
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 999999
                        FPos(BasePart, CFrame_new(0,1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame_Angles(math_rad(Angle),0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame_Angles(math_rad(Angle),0,0))
                        FPos(BasePart, CFrame_new(2.25,1.5,-2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame_Angles(math_rad(Angle),0,0))
                        FPos(BasePart, CFrame_new(-2.25,-1.5,2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame_Angles(math_rad(Angle),0,0))
                        FPos(BasePart, CFrame_new(0,1.5,0) + THumanoid.MoveDirection, CFrame_Angles(math_rad(Angle),0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,0) + THumanoid.MoveDirection, CFrame_Angles(math_rad(Angle),0,0))
                    else
                        FPos(BasePart, CFrame_new(0,1.5,THumanoid.WalkSpeed), CFrame_Angles(math_rad(90),0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,-THumanoid.WalkSpeed), CFrame_Angles(0,0,0))
                        FPos(BasePart, CFrame_new(0,1.5,THumanoid.WalkSpeed), CFrame_Angles(math_rad(90),0,0))
                        FPos(BasePart, CFrame_new(0,1.5,TRootPart.Velocity.Magnitude/1.25), CFrame_Angles(math_rad(90),0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,-TRootPart.Velocity.Magnitude/1.25), CFrame_Angles(0,0,0))
                        FPos(BasePart, CFrame_new(0,1.5,TRootPart.Velocity.Magnitude/1.25), CFrame_Angles(math_rad(90),0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,0), CFrame_Angles(math_rad(90),0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,0), CFrame_Angles(0,0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,0), CFrame_Angles(math_rad(-90),0,0))
                        FPos(BasePart, CFrame_new(0,-1.5,0), CFrame_Angles(0,0,0))
                    end
                else
                    break
                end
                
                if BasePart.Velocity.Magnitude > 500 then
                    Is_Flunged = true
                    break
                end
                
            until BasePart.Velocity.Magnitude > 500
               or BasePart.Parent ~= TChar
               or not Target.Parent
               or Target.Character ~= TChar
               or THumanoid.Sit
               or Humanoid.Health <= 0
               or tick() > Time + TimeToWait

            return Is_Flunged
        end
        
        local Fling_Velocity = self:CreateInstance("BodyVelocity", {
            Name = self:RandomString(15),
            Parent = RootPart,
            Velocity = Vector3_new(9e8, 9e8, 9e8),
            MaxForce = Vector3_new(9e9, 9e9, 9e9)
        })
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        local Is_Flunged = SFBasePart(TargetPart)
        
        Fling_Velocity:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

        if Character then
            local _Humanoid = Character:FindFirstChild("Humanoid")

            if _Humanoid then
                CurrentCamera.CameraSubject = _Humanoid
            end
        end
	
		if not CurrentCamera.CameraSubject or CurrentCamera.CameraSubject == nil then
            CurrentCamera.CameraSubject = OldCam_Subject	
		end

        if Fling_Manager.cFlingOldPos then
            for i = 1, 65 do
                task_wait()
                if RootPart and RootPart.Parent then
                    RootPart.CFrame = Fling_Manager.cFlingOldPos * CFrame_new(0, 0.5, 0)
                    Character:SetPrimaryPartCFrame(Fling_Manager.cFlingOldPos * CFrame_new(0, 0.5, 0))
                    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    for _, vel in pairs(Character:GetChildren()) do
                        if vel:IsA("BasePart") then 
                            vel.Velocity = Vector3_new()
                            vel.RotVelocity = Vector3_new()
                        end
                    end
                end
            end
        end
        
        Workspace.FallenPartsDestroyHeight = OrgDestroyHeight

        return Is_Flunged, Target.DisplayName
    end)

    self.Is_Flinging = false

    if Success then
        return Resolver1, Resolver2
    else
        return false, Resolver1
    end
end

function API:FlingNPC(Input)
    if not Input then return false end
    if self.Is_Flinging then return false end

    self.Is_Flinging = true
    local Target = nil

    local Success, Resolver1, Resolver2 = pcall(function()
        if typeof(Input) == "string" then
            if Input == "closestnpc" then
                local NPC, Model, Distance, Name = self:Search("closestnpc")
                if not NPC then
                    return false
                end
                Target = Model or NPC
            else
                Target = self:Search(Input)
            end
        elseif typeof(Input) == "Instance" then
            Target = Input
        elseif typeof(Input) == "table" and (Input.Character or Input.Model) then
            Target = Input.Character or Input.Model or Input
        end

        if not Target then 
            return false
        end

        local LPlayer = LocalPlayer
        if Target == LPlayer or (typeof(Target) == "Instance" and Target == LPlayer.Character) then
            return false
        end

        local NPC = self:GetNPC(Target)
        if not NPC then
            return false
        end

        local TChar, THumanoid, TRootPart = NPC.Model, NPC.Humanoid, NPC.Root or NPC.Any
        if not TRootPart then
            return false
        end

        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)

        for _, Part in ipairs(TChar:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.Velocity = Vector3_new(9e7, 9e7*10, 9e7)
                Part.RotVelocity = Vector3_new(9e8, 9e8, 9e8)
                Part.AssemblyLinearVelocity = Vector3_new(9e7, 9e7*10, 9e7)
                Part.AssemblyAngularVelocity = Vector3_new(9e8, 9e8, 9e8)
            end
        end

        local Fling_Velocity = self:CreateInstance("BodyVelocity", {
            Name = self:RandomString(15),
            Parent = TRootPart,
            Velocity = Vector3_new(9e8, 9e8, 9e8),
            MaxForce = Vector3_new(9e9, 9e9, 9e9)
        })

        task_wait(1)

        Fling_Velocity:Destroy()
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        THumanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)

        return true, Target.Name
    end)

    self.Is_Flinging = false

    if Success then
        return Resolver1, Resolver2
    else
        return false, Resolver1
    end
end

function API:Fling(Input)
    if not Input then return false end
    if self.Is_Flinging then return false end

    local Target, Targetted = Input, nil

    if typeof(Input) == "string" then
        if Input == "closestnpc" then
            local NPC, Model, Distance, Name = self:Search("closestnpc")
            if not NPC then
                return false
            end
            Target = Model or NPC
            Targetted = Name
        else
            Target = self:Search(Input)
            if not Target then
                return false
            end
        end
    end

    local IsNPC, _ = self:IsNPC(Target)
    
    if IsNPC then
        return self:FlingNPC(Target)
    else
        return self:FlingPlayer(Target)
    end
end

function API:XRay(State)
    if State then
        if self.XRayEnabled then return end

        self.XRayEnabled = true
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
                v.LocalTransparencyModifier = 0.5
            end
        end
    else
        if not self.XRayEnabled then return end
        
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        self.XRayEnabled = false
    end
end

function API:AntiFling()
    if self.FlingActive then return end

	self.FlingActive = true

    local Connection = Heartbeat:Connect(function()
        local Char = self:GetCharacter()
        if not Char then return end

        local Hum = Char:FindFirstChild("HumanoidRootPart")
        if not Hum then return end
        
        if not Hum:FindFirstChild("0x0x0x0x0") then
            local BV = self:CreateInstance("BodyVelocity", {
                Name = "0x0x0x0x0",
                Velocity = Vector3_zero,
                MaxForce = Vector3_new(40000, 40000, 40000),
                Parent = Hum
            })
            self:_Connect("@AntiFling", BV)
        end

        Hum.Velocity = Vector3_zero
        Hum.AssemblyLinearVelocity = Vector3_zero

        local AntiFling = Hum:FindFirstChild("0x0x0x0x0")
        if AntiFling then
            AntiFling.Velocity = Vector3_zero
        end
    end)

	self:_Connect("@AntiFling", Connection)
end

function API:StopFling()
    if not self.FlingActive then return end

    self.FlingActive = false
    self:_Disconnect("@AntiFling")
end

function API:Noclip(Duration)    
    self.NoclipActive = true
    self.NoclipTimeout = os_clock() + (Duration or 0.45)

    if not self.Origins then
        self.Origins = {}
    end

    if not self.NoclipConnection then
        self.NoclipConnection = Heartbeat:Connect(function()
            local Character = self:GetCharacter()

            if not Character or os_clock() >= self.NoclipTimeout then
                self:StopClip()
                return
            end

            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    if self.Origins[v] == nil then
                        self.Origins[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end)
    end
end

function API:StopClip()
    if self.NoclipConnection then
        self.NoclipConnection:Disconnect()
        self.NoclipConnection = nil
    end
    
    self.NoclipActive = false

    local Character = self:GetCharacter()
    if Character and self.Origins then
        for v, Original in pairs(self.Origins) do
            if v and v.Parent then
                v.CanCollide = Original
            end
        end
    end
    
    self.Origins = {}
    self.NoclipTimeout = nil
end

function API:Set3DRendering(State) 
    RunService:Set3dRenderingEnabled(not State) 
end

function API:RobloxFocused()
    return Window_Focused
end

function API:IsStudio()
    return RunService:IsStudio()
end

function API:GetScreenSize()
    return CurrentCamera and CurrentCamera.ViewportSize or Vector2_new(0, 0)
end

function API:GetMousePosition()
    return GetMouseLocation(UserInputService)
end

function API:GetMouse()
    return LocalPlayer:GetMouse()
end

function API:SetMouseIcon(Icon)
    local Plr = (LocalPlayer)
    Plr.MouseIcon = Icon
end

function API:MouseVisibility(State)
    UserInputService.MouseIconEnabled = not State
end

function API:IsKeyPressed(Key)
    return IsKeyDown(UserInputService, Key)
end

function API:IsShiftLocked()
    return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

function API:Chat(Message)
    if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Message, "All")
    else
        TextChatService.TextChannels.RBXGeneral:SendAsync(Message)
    end
end

function API:GetFriends()
    local LPlayer = (LocalPlayer)
    if not LPlayer then return {} end

    local UserId = LPlayer.UserId
    local Success, Response = pcall(function()
        return Game:HttpGet("https://friends.roblox.com/v1/users/" .. UserId .. "/friends")
    end)
    
    if not Success then return {} end
    
    local Data = HttpService:JSONDecode(Response)
    if not Data or not Data.data then return {} end
    
    local Friends = {}
    
    for _, Friend in pairs(Data.data) do
        local Success, Response = pcall(function()
            return Game:HttpGet("https://users.roblox.com/v1/users/" .. Friend.id)
        end)
        
        if Success then
            local UserData = HttpService:JSONDecode(Response)
            if UserData and UserData.name then
                table_insert(Friends, {UserId = Friend.id, Name = UserData.name, DisplayName = UserData.displayName or UserData.name})
            end
        end
        task_wait(0.1);
    end

    return Friends
end

function API:Raycast(Origin, Direction, Distance, IgnoreList, FilterType, IgnoreWater, Callback)
    local Origins = self:ResolvePosition(Origin)
    if not Origins then return nil end

    local Dir = Direction
    if typeof(Direction) ~= "Vector3" then
        Dir = self:ResolvePosition(Direction)
        if not Dir then return nil end
    end

    local Params = RaycastParamsNew()
    Params.FilterType = FilterType or Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = IgnoreList or {}
    Params.IgnoreWater = IgnoreWater or false
    
    local Result = WorkspaceRaycast(Workspace, Origins, Dir.Unit * (Distance or 1000), Params)

    if Callback and Result then
        Callback(Result)
    end

    return Result
end

function API:WorldToScreen(Position)
    local Camera = CurrentCamera
    if not Camera then return nil end
    local Vector, OnScreen = Camera:WorldToScreenPoint(self:ResolvePosition(Position))
    if OnScreen then
        return {X = Vector.X, Y = Vector.Y, Z = Vector.Z}, true
    end
    return nil, false
end

function API:GetScreenCenter()
    local Camera = CurrentCamera

    if not Camera then return nil end
    return Vector2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
end

function API:IsBehindWall(Target, Character)
    local Selected = Target
    if typeof(Target) == "Instance" and Target:IsA("Player") then
        Selected = Target.Character
    end

    if not Selected then return true end

    Character = Character or self:GetCharacter()
    if not Character then return true end

    local Head = self:GetHead()
    local Parts = Selected:FindFirstChild("Head") or Selected:FindFirstChild("HumanoidRootPart")

    if not Head or not Parts then return true end

    local Direction = (Parts.Position - Head.Position)
    local Distance = Direction.Magnitude

    local Result = self:Raycast(Head.Position, Direction, Distance, {Character, Selected})

    if Result and Result.Instance then
        local Hit = Result.Instance:FindFirstAncestorWhichIsA("Model")
        if Hit and Hit ~= Selected then
            return true
        end
    end
    
    return false
end

function API:IsTeamMate(Target)
    return self:GetTeam() == Target.Team
end

function API:GetEnemies()
    local Enemies = {}
    local MyTeam = self:GetTeam()
    
    for _, Player in ipairs(self:GetPlayers()) do
        if Player.Team ~= MyTeam then
            table_insert(Enemies, Player)
        end
    end
    
    return Enemies
end

function API:LookAt(Target, Part)
    local T = self:ResolvePosition(Target)
    local P = Part or self:GetRoot()
    
    if P and T then
        P.CFrame = CFrame_lookAt(P.Position, T)
    end
end

function API:CreateHighlight(Target, Options)
    if not Target then return nil end

    Options = Options or {}
    self.HighlightCache = self.HighlightCache or {}

    if self.HighlightCache[Target] then
        return self.HighlightCache[Target]
    end

    local Highlight = self:CreateInstance("Highlight", {
        Name = Options.Name or self:RandomString(15),
        Adornee = Target,
        Enabled = Options.Enabled ~= false,
        FillColor = Options.FillColor or Color3_fromRGB(255, 0, 0),
        OutlineColor = Options.OutlineColor or Color3_fromRGB(255, 255, 255),
        FillTransparency = Options.FillTransparency or 0.5,
        OutlineTransparency = Options.OutlineTransparency or 0,
        DepthMode = Options.DepthMode or Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = Options.Parent or Target
    })

    self.HighlightCache[Target] = Highlight
    local Preload = "@Highlight_" .. tostring(Target)

    local Connection = Target.AncestryChanged:Connect(function()
        if not Target:IsDescendantOf(Game) then
            self:RemoveHighlight(Target)
        end
    end)

    self:_Connect(Preload, Connection)
    return Highlight
end

function API:RemoveHighlight(Target)
    self.HighlightCache = self.HighlightCache or {}

    local Highlight = self.HighlightCache[Target]
    if not Highlight then return false end

    self:_Disconnect("@Highlight_" .. tostring(Target))

    if Highlight and Highlight.Destroy then
        Highlight:Destroy()
    end

    self.HighlightCache[Target] = nil
    return true
end

function API:ClearHighlights()
    self.HighlightCache = self.HighlightCache or {}

    for Target, Highlight in pairs(self.HighlightCache) do
        self:_Disconnect("@Highlight_" .. tostring(Target))

        if Highlight and Highlight.Destroy then
            pcall(function()
                Highlight:Destroy()
            end)
        end
    end

    table_clear(self.HighlightCache)
end

function API:GetPlayers(SelfIncluded)
    local List = {}

    for _, Plr in pairs(Players:GetPlayers()) do
        if SelfIncluded then
            table_insert(List, Plr)
        else
            if Plr ~= Players.LocalPlayer then
                table_insert(List, Plr)
            end
        end
    end

    return List
end

function API:SafeDestroy(Instance)
    if Instance then
        pcall(function()
            Instance:Destroy()
        end)
        return true
    end
    return false
end

function API:GetVelocity()
    local Root = self:GetRoot()
    if not Root then return Vector3_zero end

    return Root.Velocity
end

function API:GetTargetVelocity(Target)
    if not Target then return Vector3_zero end

    local Part = Target:IsA("BasePart") and Target or Target:FindFirstChildWhichIsA("BasePart")
    if Part then
        return Part.AssemblyLinearVelocity or Part.Velocity or Vector3_zero
    end
    
    return Vector3_zero
end

function API:Predict(Projectile, Target, Options)
    Options = Options or {}
    
    local Proj_Pos = self:ResolvePosition(Projectile)
    if not Proj_Pos then return math_huge end

    local Target_Pos = self:ResolvePosition(Target) or self:GetRoot().Position
    local Target_Vel = self:GetTargetVelocity(Target) or Vector3_zero
    local Proj_Vel = self:GetTargetVelocity(Projectile) or Vector3_zero

    local Compensation = Options.CompensatePing 
        and Target_Pos + (Target_Vel * (self:GetPing() / 1000))
        or Target_Pos

    local function Impact_Time(pos1, pos2, vel1, vel2)
        local Distance, Finalized_Logic = (pos1 - pos2).Magnitude, vel1 - vel2
        return Distance / Finalized_Logic.Magnitude
    end

    if Options.Directed and Proj_Vel and Proj_Vel.Magnitude > 0 then
        local Proj_Direction = Proj_Vel.Unit
        local To_Target, Threshold = (Compensation - Proj_Pos).Unit, Options.Dot or 0.95
        
        if Proj_Direction:Dot(To_Target) > (Threshold) then
            return Impact_Time(Proj_Pos, Compensation, Proj_Vel, Target_Vel)
        end
    end

    return Impact_Time(Proj_Pos, Compensation, Proj_Vel, Target_Vel)
end

function API:GetDistance(Target, UseSquared)
    local Roots = self:GetRoot()
    if not Roots or not Target then return math_huge end

    local Pos = self:ResolvePosition(Target)
    
    if not Pos then
        return math_huge
    end

    local Root = Roots.Position
    local dx, dy, dz = Root.X - Pos.X, Root.Y - Pos.Y, Root.Z - Pos.Z

    if UseSquared then
        return dx*dx + dy*dy + dz*dz
    end

    return math_sqrt(dx*dx + dy*dy + dz*dz)
end

function API:GetBoundingBox(Instance)
    if not Instance then return nil end

    local Parts = Instance:GetDescendants()
    local Min = Vector3_new(math_huge, math_huge, math_huge)
    local Max = Vector3_new(-math_huge, -math_huge, -math_huge)
    
    for _, Part in ipairs(Parts) do
        if Part:IsA("BasePart") then
            local Pos = Part.Position
            Min = Vector3_new(math_min(Min.X, Pos.X), math_min(Min.Y, Pos.Y), math_min(Min.Z, Pos.Z))
            Max = Vector3_new(math_max(Max.X, Pos.X), math_max(Max.Y, Pos.Y), math_max(Max.Z, Pos.Z))
        end
    end
    
    return Min, Max
end

function API:GetCenter(Instance)
    local Min, Max = self:GetBoundingBox(Instance)
    if not Min or not Max then return nil end
    return (Min + Max) / 2
end

function API:IsNPC(Model)
    if typeof(Model) ~= "Instance" or not Model:IsA("Model") then
        return false
    end

    local Support_1, Singular = pcall(function()
        return Players:GetPlayerFromCharacter(Model)
    end)

    if Support_1 and Singular then
        return false
    end

    local Support_2, Everyone = pcall(function()
        return Players:GetPlayers()
    end)

    if Support_2 and Everyone then
        for _, Every in ipairs(Everyone) do
            local Character = Every.Character
            if Character then
                if (Model == Character or Model:IsDescendantOf(Character) or Character:IsDescendantOf(Model)) then
                    return false
                end
            end
        end
    end

    local Humanoids = self:GetClasses(Model, "Humanoid", false)
    if #Humanoids == 0 then
        return false, nil
    end

    return true, Humanoids[1]
end

function API:IsAliveTarget(Character)
    Character = Character or self:GetCharacter()
    if not Character then return false end

    local Hum = Character:FindFirstChild("Humanoid")
    return Hum and Hum.Health > 0
end

function API:GetHealthPercent(Target)
    local Character = Target.Character or Target
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return 0 end

    return (Humanoid.Health / Humanoid.MaxHealth) * 100
end

function API:AntiVoid1(State)
    if State then
        if self.AntiVoid1_Active then return true end
        
        self.AntiVoid1_Active = true

        local Connection = RunService.RenderStepped:Connect(function()
            if not self.AntiVoid1_Active then return end

            local Roots = self:GetRoot()
            if Roots and Roots.Position.Y <= (Workspace.FallenPartsDestroyHeight or 0) + 25 then
                Roots.Velocity = Vector3_new(Roots.Velocity.X, Roots.Velocity.Y + 250, Roots.Velocity.Z)
            end
        end)

        self:_Connect("@AntiVoid", Connection)
        return true
    else
        self.AntiVoid1_Active = false
        self:_Disconnect("@AntiVoid")
        return true
    end
end

function API:AntiVoid2(State)
    if State then
        if not self.Fallen_Parts then
            self.Fallen_Parts = Workspace.FallenPartsDestroyHeight
        end
        Workspace.FallenPartsDestroyHeight = -9e9
        self.AntiVoid2_Active = true
        return true
    else
        if self.Fallen_Parts ~= nil then
            Workspace.FallenPartsDestroyHeight = self.Fallen_Parts
        end
        self.AntiVoid2_Active = false
        return true
    end
end

function API:Fakeout(Position, Duration)
    local Roots = self:GetRoot()

    if not Roots then
        return false
    end

    if self.Teleporting then
        return false
    end

    if typeof(Position) == "number" and Duration == nil then
        Duration = Position
        Position = nil
    end

    self.Teleporting = true

    local _Destination, _Delay = Position or CFrame_new(0, 67676767676767, 0), Duration or 1
    local _Location, _AntiVoid2 = Roots.CFrame, self.AntiVoid2_Active

    if not _AntiVoid2 then 
        self:AntiVoid2(true) 
    end

    Roots.CFrame = _Destination
    task_wait(_Delay)

    Roots.CFrame = _Location

    if not _AntiVoid2 then 
        self:AntiVoid2(false) 
    end

    self.Teleporting = false

    return true
end

function API:CalculateSpeed(Unit, DecimalPlaces)
    Unit = Unit or "KPH"
    DecimalPlaces = DecimalPlaces or 1
    local Velocity = self:GetVelocity()
    local StudsPS = Velocity.Magnitude

    local Result
    if Unit == "KPH" then
        Result = StudsPS * 1.008
    elseif Unit == "MPH" then
        Result = StudsPS * 0.626 
    elseif Unit == "MPS" then
        Result = StudsPS * 0.28
    elseif Unit == "Studs" then
        Result = StudsPS
    elseif Unit == "Mach" then
        Result = (StudsPS * 0.28) / 343
    elseif Unit == "Light" then
        Result = (StudsPS * 0.28) / 299792458  -- // Fraction of light speed
    else
        Result = StudsPS
    end
    
    local Multiplier = 10 ^ DecimalPlaces
    return math_floor(Result * Multiplier + 0.5) / Multiplier
end

function API:IsMoving(Character)
    Character = Character or self:GetCharacter()
    if not Character then return false end

    if not self:IsAliveTarget(Character) then return false end
    
    local Hum = Character:FindFirstChild("Humanoid")
    return Hum and Hum.MoveDirection.Magnitude > 0 or false
end

function API:GetClosestNPC(Radius)
    Radius = Radius or math_huge

    local Closest, ClosestModel, ClosestDistSquared = nil, nil, Radius * Radius
    local Models = self:GetClasses(Workspace, "Model", false)

    for i = 1, #Models do
        local Model = Models[i]
        local NPC_Data = self:GetNPC(Model)
        if NPC_Data then
            local NPC_Part = NPC_Data.Root or NPC_Data.Any
            if NPC_Part then
                local DistanceSquared = self:GetDistance(NPC_Part, true)
                if DistanceSquared < ClosestDistSquared then
                    ClosestDistSquared = DistanceSquared
                    ClosestModel = Model
                    Closest = NPC_Data
                end
            end
        end
    end

    if Closest then
        return Closest, ClosestModel, math_sqrt(ClosestDistSquared), ClosestModel.Name
    end
    return nil, nil, math_huge, nil
end

function API:GetClosestPlayer(Radius)
    Radius = Radius or math_huge
    local Closest = nil
    local ClosestDistSquared = Radius * Radius

    for _, v in ipairs(self:GetPlayers(false)) do
        if v.Character then
            local DistanceSquared = self:GetDistance(v.Character, true)
            if DistanceSquared < ClosestDistSquared then
                ClosestDistSquared = DistanceSquared
                Closest = v
            end
        end
    end

    if Closest then
        return Closest, math_sqrt(ClosestDistSquared)
    end
    return Closest, ClosestDistSquared
end

function API:GetFarthestPlayer(Radius)
    Radius = Radius or math_huge
    local Farthest, FarthestDistSquared = nil, 0

    for _, v in ipairs(self:GetPlayers(false)) do
        if v.Character then
            local DistanceSquared = self:GetDistance(v.Character, true)
            if DistanceSquared > FarthestDistSquared and DistanceSquared <= (Radius * Radius) then
                FarthestDistSquared = DistanceSquared
                Farthest = v
            end
        end
    end

    if Farthest then
        return Farthest, math_sqrt(FarthestDistSquared)
    end
    return nil, 0
end

function API:HasAccessory(Character, Accessories, MinMatches)
    if not Character then return false end
    MinMatches = MinMatches or 1

    local Count = 0
    for _, Accessory in ipairs(Character:GetChildren()) do
        if Accessory:IsA("Accessory") then
            local AccessoryNameLower = string_lower(Accessory.Name)
            for _, Name in ipairs(Accessories) do
                local NameLower = string_lower(Name)
                if AccessoryNameLower:find(NameLower) then
                    Count = Count + 1
                    if Count >= MinMatches then 
                        return true 
                    end
                end
            end
        end
    end
    return false
end

function API:Search(Input)
    if typeof(Input) ~= "string" then return nil end

    local InputLower = string_lower(Input)
    local Players = self:GetPlayers(true)
    local LocalPlayer = self:GetPlayer()
    
    if InputLower == "random" then
        return Players[math_random(1, #Players)]
    end

    if InputLower == "nearest" then
        local Closest, _ = self:GetClosestPlayer()
        return Closest
    end

    if InputLower == "farthest" then
        local Farthest, _ = self:GetFarthestPlayer()
        return Farthest
    end

    if InputLower == "closestnpc" then
        local Integration, NPCModel, Distance, Name = self:GetClosestNPC()
        if Integration then
            return Integration, NPCModel, Distance, Name
        else
            return nil, nil, nil, nil
        end
    end

    if InputLower == "bacons" then
        local Bacons = {}
        for _, Player in ipairs(Players) do
            if self:HasAccessory(Player.Character, {"Pal Hair", "Kate Hair"}, 1) then
                table_insert(Bacons, Player)
            end
        end
        if #Bacons > 0 then
            return Bacons[math_random(1, #Bacons)]
        end
        return nil
    end

    if InputLower == "furries" then
        local Furries = {}
        for _, Player in ipairs(Players) do
            if self:HasAccessory(Player.Character, {"Tail", "Ears", "Horns", "Antlers", "Collar", 
                "Chain", "Leash", "Bunny", "Wolf", "Fox", "Cat", "Dog", "Dragon", "Demon", "Kitsune", "Neko", "Kemono", "Feline", 
                "Canine", "Paws", "Claws", "Whiskers", "Muzzle", "Snout", "Beast", "Shark", "Creature", "Animal", "Pet", "Fluff",
                "Mane", "Feathers", "Wings", "Scales", "Fins", "Gills", "Hooves", "Paw", "Furry", "Anthro"
            }, 2) then
                table_insert(Furries, Player)
            end
        end
        if #Furries > 0 then
            return Furries[math_random(1, #Furries)]
        end
        return nil
    end

    if InputLower == "friends" then
        local Friends = {}
        for _, Player in ipairs(Players) do
            if Player ~= LocalPlayer and self:IsAFriend(Player) then
                table_insert(Friends, Player)
            end
        end
        if #Friends > 0 then
            return Friends[math_random(1, #Friends)]
        end
        return nil
    end

    if InputLower == "nonfriends" then
        local NonFriends = {}
        for _, Player in ipairs(Players) do
            if Player ~= LocalPlayer and not self:IsAFriend(Player) then
                table_insert(NonFriends, Player)
            end
        end
        if #NonFriends > 0 then
            return NonFriends[math_random(1, #NonFriends)]
        end
        return nil
    end

    local Matches = table_create(#Players)
    local idx = 0
    for i = 1, #Players do
        local Player = Players[i]
        local Lower_Name = string_lower(Player.Name)
        local Lower_Display = string_lower(Player.DisplayName)

        if Lower_Name == InputLower or Lower_Display == InputLower then
            return Player
        end

        if Lower_Name:find(InputLower, 1, true) or Lower_Display:find(InputLower, 1, true) then
            idx = idx + 1
            Matches[idx] = Player
        end
    end
    
    if idx > 0 then
        return Matches[1]
    end
    
    return nil
end

function API:GetNPC(Model)
    if not Model or not Model:IsA("Model") then
        return nil
    end

    local IsNPC, Humanoid = self:IsNPC(Model)
    if not IsNPC or not Humanoid then
        return nil
    end

    local Root = Model:FindFirstChild("HumanoidRootPart") or Model:FindFirstChild("Torso")

    local Any = Root or Model:FindFirstChild("RootPart") or Model:FindFirstChild("Root") or 
                Model:FindFirstChild("Head") or Model.PrimaryPart or 
                Model:FindFirstChildWhichIsA("BasePart")
    
    if not Any then
        return nil
    end

    local Status = {Model = Model, Humanoid = Humanoid, Root = Root, Any = Any, TeleportRules = nil}

    function Status:Override(Name, Func)
        local Original = self[Name]

        if typeof(Original) ~= "function" then
            return false
        end

        self[self:RandomString(15)] = Original
        self[Name] = Func
        return true
    end

    function Status:GetAttribute(Name)
        return self.Model:GetAttribute(Name)
    end

	function Status:GetState()
        return self.Humanoid:GetState()
	end

    function Status:IsState(Name)
        return self.Humanoid:GetState() == Name
	end

    function Status:IsAlive()
        return self.Humanoid.Health > 0
    end

	function Status:Kill()
        self.Humanoid.Health = 0
        return true
	end

    function Status:TearApart()
        self.Model:BreakJoints()
        return true
	end

    function Status:GetHealth()
        return self.Humanoid.Health
    end

    function Status:GetMaxHealth()
        return self.Humanoid.MaxHealth
    end

    function Status:SetHealth(Amount)
        self.Humanoid.Health = math_clamp(Amount, 0, self.Humanoid.MaxHealth)
        return self.Humanoid.Health
	end
	
	function Status:SetMaxHealth(Amount)
        self.Humanoid.MaxHealth = math_max(Amount, 0)
		if self.Humanoid.Health > self.Humanoid.MaxHealth then
			self.Humanoid.Health = self.Humanoid.MaxHealth
		end
		return self.Humanoid.MaxHealth
	end

    function Status:GetPosition()
        return (self.Root or self.Any).Position 
    end

    function Status:GetPivot()
        return self.Model:GetPivot()
    end

    function Status:Highlight(Options)
        return API:CreateHighlight(self.Model, Options)
    end

    function Status:RemoveHighlight()
        return API:RemoveHighlight(self.Model)
    end

    function Status:GetDistance()
        return API:GetDistance((self.Root or self.Any), true)
    end

    function Status:IsMoving()
        return self.Humanoid.MoveDirection.Magnitude > 0
    end

	function Status:SetWalkSpeed(Amount)
        self.Humanoid.WalkSpeed = math_max(Amount, 0)
		return self.Humanoid.WalkSpeed
	end

    function Status:SetJumpPower(Amount)
        self.Humanoid.JumpPower = math_max(Amount, 0)
        return self.Humanoid.JumpPower
	end

    function Status:GetTool()
        for _, v in ipairs(self.Model:GetChildren()) do
            if v:IsA("Tool") then
                return v
            end
        end
        return nil
    end

	function Status:Freeze(State)
        State = (State == nil and true) or State
        for _, v in ipairs(self.Model:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Anchored = State
			end
		end
		return State
	end

    function Status:Follow(Target)
        local Position = API:ResolvePosition(Target)
        if not Position then
            return false
        end
    
        self.Humanoid:MoveTo(Position)
        return true
	end

	function Status:Sit(State)
        if State == nil then
            State = true
		end
		self.Humanoid.Sit = State
		return State
	end

	function Status:SetCollidable(State)
        State = (State == nil and true) or State
        for _, v in ipairs(self.Model:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = State
			end
		end
		return true
	end

    function Status:GetAnimation()
        local Anim = self.Humanoid:FindFirstChildOfClass("Animator")
        if not Anim then return {} end

        local Data = {}

        for _, Track in ipairs(Anim:GetPlayingAnimationTracks()) do
            local Object = Track.Animation

            local Asset_Id = Object and Object.AnimationId and tonumber(Object.AnimationId:match("%d+"))
            local Asset_Info = Asset_Id and self:GetAssetInfo(Asset_Id)

            Data[#Data + 1] = {
                Name = Track.Name,
                Speed = Track.Speed,
                TimePosition = Track.TimePosition,
                AnimationId = Object and Object.AnimationId,
                
                AssetName = Asset_Info and Asset_Info.Name,
                Creator = Asset_Info and Asset_Info.Creator,
                Type = Asset_Info and Asset_Info.Type,
                Description = Asset_Info and Asset_Info.Description,
            }
        end

        return Data
    end

    function Status:Teleport(Offset)
        local Roots = API:GetRoot()
        if not Roots then return end

		Offset = Offset or Vector3_zero

		if self.CustomTeleport then
            return self.CustomTeleport(self, Roots)
        end

        if self.TeleportRules then
            for _, Rule in ipairs(self.TeleportRules) do
                if Rule.Condition(self) then
                    return Rule.Action(self, Roots)
                end
            end
        end

        Roots.CFrame = self.Root.CFrame + Offset
    end

    return Status
end

function API:Travel(Speed, ...)
    local args = {...}
    if #args < 1 then return end

    local Position = self:ResolvePosition(args[1])
    local LookAt = args[2] and self:ResolvePosition(args[2]) or nil

    local Roots = self:GetRoot();
    if not Roots then return end

    Roots.Velocity = Vector3_zero
    Roots.AssemblyLinearVelocity = Vector3_zero

    local Current = Roots.Position
    local Delta = Position - Current;
    local Distance = Delta.Magnitude
    
    if Distance < 0.05 then return end

    local Num = tonumber(Speed)
    if not Num or Num <= 0 then Num = math_huge end
    local dt = Heartbeat:Wait();

    local Step = math_min(Num * dt, Distance)
    local Direction = (Distance > 0 and Delta.Unit) or Vector3_zero
    local NewPos = Current + Direction * Step;                

    local cf = CFrame_lookAt(NewPos, LookAt or (NewPos + Direction));
    self:GetCharacter():PivotTo(cf);
end

function API:Spectate(Input)
    if self.Spectate_Active then
        self:StopSpectate()
    end

    if not CurrentCamera then
        return false
    end

    local Target = nil

    if typeof(Input) == "string" then
        if Input == "closestnpc" then
            local NPC, Model, Distance, Name = self:Search("closestnpc")
            if not NPC then
                return false
            end
            Target = Model or NPC
        else
            Target = self:Search(Input)
        end
    elseif typeof(Input) == "Instance" then
        Target = Input
    elseif typeof(Input) == "table" and Input.Character then
        Target = Input.Character or Input
    end

    if not Target then
        return false
    end

    local LocalPlayer = self:GetPlayer()
    if Target == LocalPlayer or (typeof(Target) == "Instance" and Target == LocalPlayer.Character) then
        return false
    end

    local Model = nil
    
    if typeof(Target) == "Instance" then
        if Target:IsA("Player") then
            Model = Target.Character
        elseif Target:IsA("Model") then
            Model = Target
        elseif Target:IsA("BasePart") then
            Model = Target.Parent
            while Model and not Model:IsA("Model") do
                Model = Model.Parent
            end
        end
    end

    if not Model or not Model:IsA("Model") then
        return false
    end

    self.Spectate_Target, self.Spectate_Active = Model, true

    local function Lookat_Camera(Model)
        if not Model or not Model.Parent then return false end
        if not CurrentCamera then return false end

        local Humanoid = Model:FindFirstChildOfClass("Humanoid")
        local Roots = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart or Model:FindFirstChildWhichIsA("BasePart")

        if Humanoid then
            CurrentCamera.CameraSubject = Humanoid
            CurrentCamera.CameraType = Enum.CameraType.Custom
            return true
        elseif Roots then
            CurrentCamera.CameraSubject = Roots
            CurrentCamera.CameraType = Enum.CameraType.Custom
            return true
        end
        return false
    end

    Lookat_Camera(Model)

    self.Spectate_AncestryConnection = Model.AncestryChanged:Connect(function()
        if not Model.Parent then
            self:StopSpectate()
        else
            task_spawn(function()
                task_wait(0.15)
                Lookat_Camera(Model)
            end)
        end
    end)

    self.Spectate_AddedConnection = Model.ChildAdded:Connect(function(v)
        if v:IsA("Humanoid") then
            task_spawn(function()
                task_wait(0.15)
                Lookat_Camera(Model)
            end)
        end
    end)

	self:_Connect("@Spectate_Added", self.Spectate_AddedConnection, "@Spectate_Ancestry", self.Spectate_AncestryConnection)
    return true
end

function API:StopSpectate()
    if not self.Spectate_Active then return end
	
	self:_Disconnect("@Spectate_Added", "@Spectate_Ancestry")

    if self.Spectate_AncestryConnection then
        self.Spectate_AncestryConnection:Disconnect()
        self.Spectate_AncestryConnection = nil
    end

    if self.Spectate_AddedConnection then
        self.Spectate_AddedConnection:Disconnect()
        self.Spectate_AddedConnection = nil
    end

	if Humanoid then
		CurrentCamera.CameraSubject = Humanoid
		CurrentCamera.CameraType = Enum.CameraType.Custom
	end

    self.Spectate_Target, self.Spectate_Active = nil, false    
    return true
end

function API:IsSpectating()
    return self.Spectate_Active or false
end

function API:GetSpectateTarget()
    return self.Spectate_Target
end

function API:Notify(Title, Description, Duration, Image)
    -- // Load Notification Library, All credits to lxte 🫶, I've forked it to add gethui suppport and boost runtime performance.
    local Framework = self:LoadData("@Notification.UI")

    if not Framework then
        local Success, Result = pcall(function()
            return Game:HttpGet("https://raw.githubusercontent.com/FlamesW/Notification/refs/heads/home/Framework.luau")
        end)
        
        if not Success then
            warn("[Notify]: Failed to download framework")
            return false
        end

        Framework = Result
        self:SaveData("@Notification.UI", Result)
    end
    
    local Success, Library = pcall(function()
        return loadstring(Framework)()
    end)

    if not Success then
        return false
    end

    if not self.Notification_Handler then
        self.Notification_Handler = Library:New({
            BackgroundColor = Color3_fromRGB(68, 71, 0),
            TitleColor = Color3_fromRGB(255, 255, 255),
            DescriptionColor = Color3_fromRGB(200, 200, 200),
            Mode = "Dark",
            VerticalPosition = "Top",
            HorizontalPosition = "Right",
        })
    end

    self.Notification_Handler:Create({
        Title = Title or "Notification",
        Description = Description or "",
        Duration = Duration or 3,
        Image = Image,
    })

    return true
end

function API:Load_ESP()
    if self.ESP_Injected then 
        return self.ESP_Library 
    end

    -- // Load MSpaintESP Library, Credits to mstudio45 and all its contributors for making this library 💕
    local Framework, File = ("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"), ("@ESP_Library.luau")

    local function Execute_External(Content)
        local Chunk, Err = loadstring(Content)

        if not Chunk then warn("[ESP]: Compile error:", Err)
            return nil
        end

        local Success, Result = pcall(Chunk)
        if not Success then warn("[ESP]: Runtime error:", Result)
            return nil
        end

        return Result
    end

    if is_file(File) then
        local Success, Content = pcall(read_file, File)

        if Success and Content then
            task_spawn(function()
                local Update = Game:HttpGet(Framework .. "?nocache=" .. tostring(os_clock()))

                if Update and Update ~= Content then
                    pcall(write_file, File, Update)
                end
            end)

            local Library = Execute_External(Content)
            if Library then self.ESP_Library, self.ESP_Injected = Library, true
                return Library
            end
        end
    end

    local Content = Game:HttpGet(Framework .. "?nocache=" .. tostring(os_clock()))
    pcall(write_file, File, Content)

    local Library = Execute_External(Content)
    if Library then self.ESP_Library, self.ESP_Injected = Library, true
        return Library
    end

    return nil
end

function API:ESP_Add(Settings)
    return self:Load_ESP():Add(Settings)
end

function API:ESP_Clear()
    return self:Load_ESP():Clear()
end

function API:ESP_Destroy()
    return self:Load_ESP():Destroy()
end

function API:ESP_SetGlobal(Settings)
    local ESP = self:Load_ESP()

    for Key, Value in pairs(Settings) do
        ESP.GlobalConfig[Key] = Value
    end
    return ESP.GlobalConfig
end

function API:ESP_GetGlobal()
    return self:Load_ESP().GlobalConfig
end

function API:ESP_EnableRainbow(State)
    local ESP = self:Load_ESP()

    ESP.GlobalConfig.Rainbow = State or false
    return ESP.GlobalConfig.Rainbow
end

function API:ESP_IgnoreCharacter(State)
    local ESP = self:Load_ESP()

    ESP.GlobalConfig.IgnoreCharacter = State or false
    return ESP.GlobalConfig.IgnoreCharacter
end

function API:ESP_ToggleComponent(Component, State)
    local ESP = self:Load_ESP()

    local Valid = {
        Billboards = true,
        Distance = true,
        Highlighters = true,
        Tracers = true,
        Arrows = true,
        Boxes2D = true,
        Boxes3D = true,
        Skeleton = true
    }
    if Valid[Component] then
        ESP.GlobalConfig[Component] = State ~= false
        return true
    end
    return false
end

function API:ESP_SetFont(Font)
    local ESP = self:Load_ESP()

    ESP.GlobalConfig.Font = Font
    return ESP.GlobalConfig.Font
end

function API:ESP_GetAll()
    return self:Load_ESP().ESP
end

function API:ESP_Remove(Ident)
    local ESP = self:Load_ESP()

    local Instance = ESP.ESP[Ident]
    if Instance and Instance.Destroy then
        Instance:Destroy()
        return true
    end
    return false
end

function API:ESP_Hide(Ident)
    local ESP = self:Load_ESP()

    local Instance = ESP.ESP[Ident]
    if Instance and Instance.Hide then
        Instance:Hide()
        return true
    end
    return false
end

function API:ESP_Show(Ident)
    local ESP = self:Load_ESP()

    local Instance = ESP.ESP[Ident]
    if Instance and Instance.Show then
        Instance:Show()
        return true
    end
    return false
end

function API:ESP_Toggle(Ident)
    local ESP = self:Load_ESP()

    local Instance = ESP.ESP[Ident]
    if Instance and Instance.ToggleVisibility then
        Instance:ToggleVisibility()
        return true
    end
    return false
end

function API:ESP_SetColor(Ident, Color, IncludeComponents)
    local ESP = self:Load_ESP()

    local Instance = ESP.ESP[Ident]
    if Instance and Instance.SetEveryColor then
        Instance:SetEveryColor(Color, IncludeComponents or false)
        return true
    end
    return false
end

function API:Unload_ESP()
    if self.ESP_Injected then
        if self.ESP_Library then
            if self.ESP_Library.Clear then 
                self.ESP_Library:Clear() 
            end

            if self.ESP_Library.Destroy then 
                self.ESP_Library:Destroy() 
            end
        end

        self.ESP_Library, self.ESP_Injected = nil, false
    end
end

function API:IsColor(Target, Colors)
    if Colors == "Nigger" then
        Colors = {["Really black"] = true,["Black"] = true,["Dark brown"] = true,["Reddish brown"] = true,
            ["Dark orange"] = true,["Earth orange"] = true,["Burnt Sienna"] = true,["Dirt brown"] = true,
            ["Medium brown"] = true,["CGA brown"] = true,["Pine Cone"] = true,["Dark taupe"] = true,
            ["Brown"] = true,["Rust"] = true,["Dark"] = true,["Brownish"] = true,
            ["Dark red"] = true,["Maroon"] = true,["Chocolate"] = true,["Coffee"] = true,
        };
    end

    if Target:IsA("Player") then
        Target = Target.Character or Target.CharacterAdded:Wait()
    end

    local BodyColors = Target and Target:FindFirstChild("Body Colors")
    if not BodyColors then
        return false
    end

    local HeadColor = BodyColors.HeadColor;
    local TorsoColor = BodyColors.TorsoColor;

    return Colors[HeadColor.Name] and Colors[TorsoColor.Name] or false
end

function API:LogGamepasses(State)
    if State == true then
        if self.LogConnection then return end

        if not self.LoggedGamepasses then self.LoggedGamepasses = {} end
        
        local function Capture(Type, Asset)
            local Data = {
                Signal = Type,
                ID = Asset,
                Time = os_date("%H:%M:%S")
            }
            table_insert(self.LoggedGamepasses, Data)
            print("Successfully Logged [" .. Type .. "]: " .. tostring(Asset))
            return Data
        end

        self:_Connect("@Gamepasses_Product", MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, id) Capture("Product", id) end))
        self:_Connect("@Gamepasses_Gamepass", MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, id) Capture("Gamepass", id) end))
        self:_Connect("@Gamepasses_Purchase", MarketplaceService.PromptPurchaseFinished:Connect(function(_, id) Capture("Purchase", id) end))
        self:_Connect("@Gamepasses_Bulk", MarketplaceService.PromptBulkPurchaseFinished:Connect(function(_, id) Capture("Bulk", id) end))

        self.LogConnection = true
        
    elseif State == false then
        self:ClearGamepasses()
    end
end

function API:GetGamepass(Type, Asset)
    pcall(function()
        if Type == "Product" then
            MarketplaceService:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, Asset, true)
        elseif Type == "Gamepass" then
            MarketplaceService:SignalPromptGamePassPurchaseFinished(LocalPlayer.UserId, Asset, true)
        elseif Type == "Purchase" then
            MarketplaceService:SignalPromptPurchaseFinished(LocalPlayer.UserId, Asset, true)
        elseif Type == "Bulk" then
            MarketplaceService:SignalPromptBulkPurchaseFinished(LocalPlayer.UserId, Asset, true)
        end
    end)
end

function API:ClearGamepasses()
    if self.LogConnection then
        self:_Disconnect("@Gamepasses_Product", "@Gamepasses_Gamepass", "@Gamepasses_Purchase", "@Gamepasses_Bulk")
        self.LogConnection = nil; table_clear(self.LoggedGamepasses)
    end
end

function API:SelectEverything(Dropdown, List) -- // @Obsidian Only
    if not globalEnv.Library then
        return
    end

    local CurrentValues = Dropdown.Value or {}
    local AddedValues, All = {}, true

    for _, Item in ipairs(List) do
        if not CurrentValues[Item] then
            All = false
            break
        end
    end

    local State = not All

    for _, Item in ipairs(List) do
        AddedValues[Item] = State;
    end
    Dropdown:SetValue(AddedValues);
    Library:Notify(State and "Selected" or "Unselected" .. " Everything!", 2);

    return State
end

function API:Rejoin()
    local Plr = (LocalPlayer)

    if #Players:GetPlayers() <= 1 then
        Plr:Kick("Rejoining...")
        task_wait(1);
        TeleportService:Teleport(PlaceId, Plr)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Plr)
    end
end

function API:RejoinRe()
    local Roots = self:GetRoot()
    local Saved_Data = {X = 0, Y = 0, Z = 0}

    if Roots then
        local Position = Roots.Position

        Saved_Data = {X = Position.X, Y = Position.Y, Z = Position.Z}
        self:SaveData("@RejoinRe.json", Saved_Data)
    end

    local TeleportScript = string_format([[
        repeat task.wait() until game:IsLoaded()

        local Player = game:GetService("Players").LocalPlayer
        repeat task.wait() until Player and Player.Character

        task.wait(0.5)
        
        local Roots = nil
        repeat 
            task.wait()
            Roots = Player.Character:FindFirstChild("HumanoidRootPart")
        until Roots

        local TargetPos = Vector3.new(%f, %f, %f)
        local StartTime, Timeout = os.clock(), 10

        repeat
            Roots.CFrame = CFrame.new(TargetPos)
            task.wait(0.5)

            local Distance = (Roots.Position - TargetPos).Magnitude
            
            if Distance <= 20 then
                break
            end

            if os.clock() - StartTime >= Timeout then
                warn("[RejoinRe]: Timeout reached, stopping teleport attempts")
                break
            end
        until false
    ]], Saved_Data.X, Saved_Data.Y, Saved_Data.Z)

    self:QueueOnTeleport("@RejoinRe", true, TeleportScript)
    self:Rejoin()

    return true
end

function API:ServerHop(Options)
    if self.ServerHopping then
        return false
    end

    self.ServerHopping = true

    Options = Options or {}

    local Mode = Options.Mode
    local MinPlayers = Options.MinPlayers
    local MaxPlayers = Options.MaxPlayers

    local MaxPing = Options.MaxPing
    local MaxRetries = Options.MaxRetries or 5
    local Timeout = Options.Timeout or 676767

    local RetryDelay = Options.RetryDelay or 2

    if Mode == nil and MinPlayers == nil and MaxPlayers == nil and MaxPing == nil then
        Mode = "high"
    end    

    local Attempts = 0

    local Serverhop = task_create(function()
        local MaxServerPlayers, Listener = 0, "https://solaraserverhop.ltseverydayyou.workers.dev"
        local Success, Data = pcall(function()
            return HttpService:JSONDecode(Game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(PlaceId) .. "/servers/Public?limit=1"))
        end)

        if Success and Data and Data.data and #Data.data > 0 then
            MaxServerPlayers = tonumber(Data.data[1].maxPlayers) or 67
        else
            MaxServerPlayers = Players.MaxPlayers or 67
        end

        if MinPlayers and MinPlayers > MaxServerPlayers then
            warn(string_format("[Serverhop]: MinPlayers (%s) exceeds server limit (%s)!", MinPlayers, MaxServerPlayers))
            self.ServerHopping = nil
            return false
        end
        if MaxPlayers and MaxPlayers > MaxServerPlayers then
            warn(string_format("[Serverhop]: MaxPlayers (%s) exceeds server limit (%s)!", MaxPlayers, MaxServerPlayers))
            self.ServerHopping = nil
            return false
        end
        if MinPlayers and MaxPlayers and MinPlayers > MaxPlayers then
            warn(string_format("[Serverhop]: MinPlayers (%s) > MaxPlayers (%s)!", MinPlayers, MaxPlayers))
            self.ServerHopping = nil
            return false
        end
        if MaxPing and MaxPing < 0 then
            warn("[Serverhop]: MaxPing cannot be negative!")
            self.ServerHopping = nil
            return false
        end

        local Best_Id, Best_Value, Best_Ping = nil, nil, nil
        local Cursor, PageCount = nil, 0
	
        local MaxPages = Mode == "ping" and 4 or 2
        local SortOrder = (Mode == "high" or Mode == "random") and "Desc" or "Asc"
        local Hosts = { "https://games.roproxy.com", "https://games.rotunnel.com", "https://games.roblox.com" }

        local function Fetch_Servers(Cursor)
            local Query = "?sortOrder=" .. SortOrder .. "&excludeFullGames=true&limit=100"
            if Cursor and Cursor ~= "" then
                Query = Query .. "&cursor=" .. HttpService:UrlEncode(Cursor)
            end
            
            for _, Host in ipairs(Hosts) do
                local Url = Host .. "/v1/games/" .. tostring(PlaceId) .. "/servers/Public" .. Query
                local Success, Body = pcall(function()
                    return Game:HttpGet(Url)
                end)
                
                if Success and Body and Body ~= "" then
                    local Success, Data = pcall(function()
                        return HttpService:JSONDecode(Body)
                    end)
                    
                    if Success and typeof(Data) == "table" and typeof(Data.data) == "table" then
                        return Data.data, Data.nextPageCursor
                    end
                end
            end

            local WorkerQuery = "placeId=" .. tostring(PlaceId)
            WorkerQuery = WorkerQuery .. "&sortOrder=" .. HttpService:UrlEncode(SortOrder) .. "&excludeFullGames=true"
            if Cursor and Cursor ~= "" then
                WorkerQuery = WorkerQuery .. "&cursor=" .. HttpService:UrlEncode(Cursor)
            end

            local WorkerUrl = Listener .. "/servers?" .. WorkerQuery
            local Success, Body = pcall(function()
                return Game:HttpGet(WorkerUrl)
            end)
            
            if Success and Body and Body ~= "" then
                local Success, Data = pcall(function()
                    return HttpService:JSONDecode(Body)
                end)
                
                if Success and typeof(Data) == "table" and typeof(Data.data) == "table" then
                    return Data.data, Data.nextPageCursor
                end
            end
            
            return nil, nil
        end

        for Attempt = 1, MaxRetries do
			Attempts = Attempt
            if not self.ServerHopping then
                return false
            end

            local ServerHopper, SearchCursor, SearchPageCount = {}, nil, 0
            Best_Id, Best_Value, Best_Ping = nil, nil, nil
            warn(string_format("[Serverhop]: Attempt %d/%d", Attempt, MaxRetries))
            
            while SearchPageCount < MaxPages do
                if not self.ServerHopping then
                    return false
                end
                
                SearchPageCount = SearchPageCount + 1
                local Data, NextCursor = Fetch_Servers(SearchCursor)
                
                if not Data then
                    break
                end
                
                for _, Server in ipairs(Data) do
                    if Server.id and Server.id ~= JobId then
                        local Players = tonumber(Server.playing)
                        local Max = tonumber(Server.maxPlayers)
                        local Ping = tonumber(Server.ping)
                        
                        if Players and Max and Players >= Max then
                            continue
                        end
                        
                        if Players and Max and Max > Players then
                            if MinPlayers and Players < MinPlayers then
                                continue
                            end
                            if MaxPlayers and Players > MaxPlayers then
                                continue
                            end
                            if MaxPing and Ping and Ping > MaxPing then
                                continue
                            end
                            
                            table_insert(ServerHopper, { id = Server.id, players = Players, ping = Ping })
                            
                            if Mode == "low" then
                                if not Best_Value or Players < Best_Value then
                                    Best_Value = Players
                                    Best_Id = Server.id
                                    Best_Ping = Ping
                                end
                            elseif Mode == "high" then
                                if not Best_Value or Players > Best_Value then
                                    Best_Value = Players
                                    Best_Id = Server.id
                                    Best_Ping = Ping
                                end
                            elseif Mode == "ping" then
                                if Ping and (not Best_Value or Ping < Best_Value) then
                                    Best_Value = Ping
                                    Best_Id = Server.id
                                    Best_Ping = Players
                                end
                            end
                        end
                    end
                end

                if Best_Id and Mode ~= "ping" and Mode ~= "random" then
                    break
                end

                if not NextCursor or NextCursor == "" then
                    break
                end

                SearchCursor = NextCursor
            end

			if Mode == "random" and #ServerHopper > 0 then
                local Random = ServerHopper[math_random(1, #ServerHopper)]
				Best_Id = Random.id Best_Value = Random.players Best_Ping = Random.ping
				warn(string_format("[Serverhop]: Random Server | Players: %s | Ping: %sms | ID: %s", tostring(Best_Value), tostring(Best_Ping or "?"), tostring(Best_Id)))
			elseif Mode == "low" and Best_Id then
				warn(string_format("[Serverhop]: Low Server | Players: %s | Ping: %sms | ID: %s", tostring(Best_Value), tostring(Best_Ping or "?"), tostring(Best_Id)))
			elseif Mode == "high" and Best_Id then
				warn(string_format("[Serverhop]: High Server | Players: %s | Ping: %sms | ID: %s", tostring(Best_Value), tostring(Best_Ping or "?"), tostring(Best_Id)))
			elseif Mode == "ping" and Best_Id then
				warn(string_format("[Serverhop]: Ping Server | Ping: %sms | Players: %s | ID: %s", tostring(Best_Ping or "?"), tostring(Best_Value), tostring(Best_Id)))
			end

            if Best_Id then
                TeleportService:TeleportToPlaceInstance(PlaceId, Best_Id, LocalPlayer)

                task_wait(4)
                warn("[Serverhop]: Teleport failed or server unavailable, retrying...")
            end

            if Attempt < MaxRetries then
                local WaitTime = RetryDelay
                warn(string_format("[Serverhop]: No server found or teleport failed, waiting %d seconds before retry %d...", WaitTime, Attempt + 1))

                for i = 1, WaitTime do
                    if not self.ServerHopping then
                        return false
                    end
                    task_wait(1)
                end
            end
        end

        self.ServerHopping = nil
        warn(string_format("[Serverhop]: Failed after %d attempts", MaxRetries))
		return false
    end)

    local Thread_Timeout = task_spawn(function()
        task_wait(Timeout)
        if self.ServerHopping then
            warn(string_format("[Serverhop]: Timeouted after %.1f seconds (attempts: %d/%d)", Timeout, Attempts, MaxRetries))
            self.ServerHopping = nil
            task_close(Serverhop)
        end
    end)

    local Success, Result1, Result2, Result3, Result4 = task_resume(Serverhop)

    if not Success then
        self.ServerHopping = nil
        return false
    end

    return Result1, Result2, Result3, Result4
end

function API:GetHWID(Method)
    Method = Method or "Roblox"

    if Method == "Executor" then
        local Success, Result = pcall(function()
            if typeof(gethwid) == "function" then
                return gethwid()
            end
            return nil
        end)

        if Success and Result then
            return Result
        end
        return nil
    elseif Method == "Roblox" then
        return RbxAnalyticsService:GetClientId()
    elseif Method == "IP" then
        local Success, Result = pcall(function()
            return Game:HttpGet("https://api.ipify.org")
        end)

        if Success and Result then
            return Result
        end
        return nil
    end
    
    return nil
end

function API:GetExecutor()
    local Success, Result = pcall(function()
        if typeof(identifyexecutor) == "function" then
            return identifyexecutor()
        end
    end)
    if Success and Result then
        return Result
    end

    Success, Result = pcall(function()
        if typeof(getexecutorname) == "function" then
            return getexecutorname()
        end
    end)
    if Success and Result then
        return Result
    end

    return "Unknown"
end

function API:Kick(Reason)
    Reason = Reason or "Disconnected by API";
    LocalPlayer:Kick(Reason);
end

function API:FireRemote(Remote, ...)
    local Event = ReplicatedStorage:FindFirstChild(Remote)
    if not Event then
        return false
    end

    if Event:IsA("RemoteEvent") then
        Event:FireServer(...)
        return true
    end
    
    if Event:IsA("RemoteFunction") then
        return Event:InvokeServer(...)
    end
    
    return false
end

function API:ListenRemote(Remote, Callback)
    local Event = ReplicatedStorage:FindFirstChild(Remote)
    if not Event then
        return false
    end
    
    if Event:IsA("RemoteEvent") then
        Event.OnClientEvent:Connect(Callback)
        return true
    end
    
    if Event:IsA("RemoteFunction") then
        Event.OnClientInvoke = Callback
        return true
    end
    
    return false
end

function API:Verify(Options)
    Options = Options or {}

    local LPlayer, List = (LocalPlayer), {}
    local RobloxId, ExecutorHwid = self:GetHWID("Roblox"), self:GetHWID("Executor")

    if not RobloxId and not ExecutorHwid then
        return false, nil, nil
    end

    if Options.Url then
        local Success, Content = pcall(function()
            return Game:HttpGet(Options.Url)
        end)
    
        if Success then
            local Matches = {}
            
            local Success, Decoded = pcall(function()
                return HttpService:JSONDecode(Content)
            end)

            if Success and typeof(Decoded) == "table" then
                local function Decode_Table(t)
                    for k, v in pairs(t) do
                        if typeof(v) == "string" then
                            table_insert(Matches, v)
                        elseif typeof(v) == "number" then
                            table_insert(Matches, tostring(v))
                        elseif typeof(v) == "table" then
                            Decode_Table(v)
                        end
                        if typeof(k) == "string" then
                            table_insert(Matches, k)
                        elseif typeof(k) == "number" then
                            table_insert(Matches, tostring(k))
                        end
                    end
                end
                Decode_Table(Decoded)
            end
            
            local function SplitByDelimiter(Text)
                local Results = {}
                for _, Delimiter in ipairs({",", ";", "|", "\t", "\n", "\r", "  "}) do
                    Text = string_gsub(Text, Delimiter, " ")
                end
                for Word in string_gmatch(Text, "[^%s]+") do
                    table_insert(Results, Word)
                end
                return Results
            end
            
            for Line in string_gmatch(Content, "[^\r\n]+") do
                Line = Line:gsub("^%s+", ""):gsub("%s+$", "")
                if Line ~= "" and not Line:match("^%s*%-%-") and not Line:match("^%s*#") and not Line:match("^%s*//") then
                    local Words = SplitByDelimiter(Line)
                    for _, Word in ipairs(Words) do
                        table_insert(Matches, Word)
                    end
                end
            end
            
            for _, Match in ipairs(Matches) do
                Match = Match:gsub("^%s+", ""):gsub("%s+$", "")
                Match = Match:gsub('"', "")
                Match = Match:gsub("'", "")
                Match = Match:gsub("[{}%[%]()]", "")
                
                if Match ~= "" then
                    table_insert(List, Match)
                end
            end
        else
            warn("[Auth]: Failed to load:", Options.Url)
        end
    end
    
    for _, Item in ipairs(Options.Hwids or {}) do
        if Item and Item ~= "" then
            table_insert(List, tostring(Item))
        end
    end
    
    local function Unique(Table)
        local Seen, Result = {}, {}

        for _, v in ipairs(Table) do
            if not Seen[v] then
                Seen[v] = true
                table_insert(Result, v)
            end
        end
        return Result
    end
    
    List = Unique(List)

    local Authenticated, Value = false, nil
    
    if RobloxId then
        for _, Item in ipairs(List) do
            if tostring(RobloxId):lower() == tostring(Item):lower() then
                Authenticated = true
                Value = RobloxId
                break
            end
        end
    end

    if not Authenticated and ExecutorHwid then
        for _, Item in ipairs(List) do
            if tostring(ExecutorHwid):lower() == tostring(Item):lower() then
                Authenticated = true
                Value = ExecutorHwid
                break
            end
        end
    end

    if not Authenticated then
        for _, Item in ipairs(List) do
            local String = tostring(Item):lower()

            if String == tostring(LPlayer.UserId) or String == LPlayer.Name:lower() then
                Authenticated = true
                Value = Item
                break
            end
        end
    end

    if Authenticated then
        return true, Type, Value
    end
    
    return false, nil, nil
end

function API:CreateBaseplate(Options)
    Options = Options or {}

    local Size = Options.Size or Vector3_new(10, 1, 10)
    local Color = Options.Color or Color3_fromRGB(170, 170, 170)
    local Transparency = Options.Transparency or 0
    local Material = Options.Material or Enum.Material.Plastic
    local Offset = Options.Offset or Vector3_new(0, -3.7245, 0)
    local Parent = Options.Parent or Workspace
    local CanCollide = Options.CanCollide ~= false
    local Anchored = Options.Anchored ~= false

    local Baseplate = self:CreateInstance("Part", {
        Name = Options.Name or self:RandomString(15),
        Size = Size,
        Color = Color,
        Transparency = Transparency,
        Material = Material,
        CanCollide = CanCollide,
        Anchored = Anchored,
        Parent = Parent
    })

    local function UpdatePosition()
        local Char = self:GetCharacter()
        if not Char then return end

        local Hum = Char:FindFirstChild("HumanoidRootPart")
        if Hum then
            Baseplate.CFrame = Hum.CFrame + Offset
        end
    end
    UpdatePosition()
    
    local Connection = nil
    
    local Usage = {
        Baseplate = Baseplate,
        
        SetSize = function(_, NewSize)
            Baseplate.Size = NewSize
            return Usage
        end,
        
        SetColor = function(_, NewColor)
            Baseplate.Color = NewColor
            return Usage
        end,
        
        SetTransparency = function(_, NewTrans)
            Baseplate.Transparency = NewTrans
            return Usage
        end,
        
        SetFollow = function(_, Followed)
            if Connection then
                self:_Disconnect(Connection)
                Connection = nil
            end

            if Followed then
                Connection = "@Baseplate_" .. self:RandomString(15)
                self:_Connect(Connection, RenderStepped:Connect(UpdatePosition))
            end
            return Usage
        end,
        
        SetOffset = function(_, NewOffset)
            Offset = NewOffset
            UpdatePosition()
            return Usage
        end,

        GetOffset = function(_)
            return Offset
        end,
        
        Destroy = function(_)
            if Connection then
                self:_Disconnect(Connection)
                Connection = nil
            end
            Baseplate:Destroy()
            return Usage
        end
    }

    self.CreatedBaseplates = self.CreatedBaseplates or {}
    table_insert(self.CreatedBaseplates, {Baseplate = Baseplate, Connection = Connection, Usage = Usage})
    
    return Usage
end

function API:ClearBaseplates()
    self.CreatedBaseplates = self.CreatedBaseplates or {}

    for _, Data in ipairs(self.CreatedBaseplates) do
        if Data.Baseplate then
            Data.Baseplate:Destroy()
        end

        if Data.Connection then
            self:_Disconnect(Data.Connection)
        end
    end

    table_clear(self.CreatedBaseplates)
end

function API:GetCountry(Locale)
    local locale = Locale or LocalizationService.SystemLocaleId or "en-us"

    local Countries = {
        ["en-us"] = {Code = "US", Country = "United States", Language = "English", Flag = "🇺🇸", LangCode = "en"},
        ["en-ca"] = {Code = "CA", Country = "Canada", Language = "English", Flag = "🇨🇦", LangCode = "en"},
        ["fr-ca"] = {Code = "CA", Country = "Canada", Language = "French", Flag = "🇨🇦", LangCode = "fr"},
        ["es-mx"] = {Code = "MX", Country = "Mexico", Language = "Spanish", Flag = "🇲🇽", LangCode = "es"},
        
        ["es-gt"] = {Code = "GT", Country = "Guatemala", Language = "Spanish", Flag = "🇬🇹", LangCode = "es"},
        ["es-hn"] = {Code = "HN", Country = "Honduras", Language = "Spanish", Flag = "🇭🇳", LangCode = "es"},
        ["es-sv"] = {Code = "SV", Country = "El Salvador", Language = "Spanish", Flag = "🇸🇻", LangCode = "es"},
        ["es-ni"] = {Code = "NI", Country = "Nicaragua", Language = "Spanish", Flag = "🇳🇮", LangCode = "es"},
        ["es-cr"] = {Code = "CR", Country = "Costa Rica", Language = "Spanish", Flag = "🇨🇷", LangCode = "es"},
        ["es-pa"] = {Code = "PA", Country = "Panama", Language = "Spanish", Flag = "🇵🇦", LangCode = "es"},
        ["es-do"] = {Code = "DO", Country = "Dominican Republic", Language = "Spanish", Flag = "🇩🇴", LangCode = "es"},
        ["es-cu"] = {Code = "CU", Country = "Cuba", Language = "Spanish", Flag = "🇨🇺", LangCode = "es"},
        ["fr-ht"] = {Code = "HT", Country = "Haiti", Language = "French", Flag = "🇭🇹", LangCode = "fr"},
        
        ["es-ar"] = {Code = "AR", Country = "Argentina", Language = "Spanish", Flag = "🇦🇷", LangCode = "es"},
        ["es-bo"] = {Code = "BO", Country = "Bolivia", Language = "Spanish", Flag = "🇧🇴", LangCode = "es"},
        ["es-cl"] = {Code = "CL", Country = "Chile", Language = "Spanish", Flag = "🇨🇱", LangCode = "es"},
        ["es-co"] = {Code = "CO", Country = "Colombia", Language = "Spanish", Flag = "🇨🇴", LangCode = "es"},
        ["es-ec"] = {Code = "EC", Country = "Ecuador", Language = "Spanish", Flag = "🇪🇨", LangCode = "es"},
        ["es-py"] = {Code = "PY", Country = "Paraguay", Language = "Spanish", Flag = "🇵🇾", LangCode = "es"},
        ["es-pe"] = {Code = "PE", Country = "Peru", Language = "Spanish", Flag = "🇵🇪", LangCode = "es"},
        ["es-uy"] = {Code = "UY", Country = "Uruguay", Language = "Spanish", Flag = "🇺🇾", LangCode = "es"},
        ["es-ve"] = {Code = "VE", Country = "Venezuela", Language = "Spanish", Flag = "🇻🇪", LangCode = "es"},
        ["pt-br"] = {Code = "BR", Country = "Brazil", Language = "Portuguese", Flag = "🇧🇷", LangCode = "pt"},
        ["nl-sr"] = {Code = "SR", Country = "Suriname", Language = "Dutch", Flag = "🇸🇷", LangCode = "nl"},
        ["en-gy"] = {Code = "GY", Country = "Guyana", Language = "English", Flag = "🇬🇾", LangCode = "en"},
        ["fr-gf"] = {Code = "GF", Country = "French Guiana", Language = "French", Flag = "🇬🇫", LangCode = "fr"},
        
        ["en-gb"] = {Code = "GB", Country = "United Kingdom", Language = "English", Flag = "🇬🇧", LangCode = "en"},
        ["en-ie"] = {Code = "IE", Country = "Ireland", Language = "English", Flag = "🇮🇪", LangCode = "en"},
        ["fr-fr"] = {Code = "FR", Country = "France", Language = "French", Flag = "🇫🇷", LangCode = "fr"},
        ["es-es"] = {Code = "ES", Country = "Spain", Language = "Spanish", Flag = "🇪🇸", LangCode = "es"},
        ["de-de"] = {Code = "DE", Country = "Germany", Language = "German", Flag = "🇩🇪", LangCode = "de"},
        ["it-it"] = {Code = "IT", Country = "Italy", Language = "Italian", Flag = "🇮🇹", LangCode = "it"},
        ["pt-pt"] = {Code = "PT", Country = "Portugal", Language = "Portuguese", Flag = "🇵🇹", LangCode = "pt"},
        ["nl-nl"] = {Code = "NL", Country = "Netherlands", Language = "Dutch", Flag = "🇳🇱", LangCode = "nl"},
        ["nl-be"] = {Code = "BE", Country = "Belgium", Language = "Dutch", Flag = "🇧🇪", LangCode = "nl"},
        ["fr-be"] = {Code = "BE", Country = "Belgium", Language = "French", Flag = "🇧🇪", LangCode = "fr"},
        ["de-be"] = {Code = "BE", Country = "Belgium", Language = "German", Flag = "🇧🇪", LangCode = "de"},
        ["pl-pl"] = {Code = "PL", Country = "Poland", Language = "Polish", Flag = "🇵🇱", LangCode = "pl"},
        ["ru-ru"] = {Code = "RU", Country = "Russia", Language = "Russian", Flag = "🇷🇺", LangCode = "ru"},
        ["tr-tr"] = {Code = "TR", Country = "Turkey", Language = "Turkish", Flag = "🇹🇷", LangCode = "tr"},
        ["sv-se"] = {Code = "SE", Country = "Sweden", Language = "Swedish", Flag = "🇸🇪", LangCode = "sv"},
        ["da-dk"] = {Code = "DK", Country = "Denmark", Language = "Danish", Flag = "🇩🇰", LangCode = "da"},
        ["no-no"] = {Code = "NO", Country = "Norway", Language = "Norwegian", Flag = "🇳🇴", LangCode = "no"},
        ["fi-fi"] = {Code = "FI", Country = "Finland", Language = "Finnish", Flag = "🇫🇮", LangCode = "fi"},
        ["el-gr"] = {Code = "GR", Country = "Greece", Language = "Greek", Flag = "🇬🇷", LangCode = "el"},
        ["cs-cz"] = {Code = "CZ", Country = "Czech Republic", Language = "Czech", Flag = "🇨🇿", LangCode = "cs"},
        ["hu-hu"] = {Code = "HU", Country = "Hungary", Language = "Hungarian", Flag = "🇭🇺", LangCode = "hu"},
        ["ro-ro"] = {Code = "RO", Country = "Romania", Language = "Romanian", Flag = "🇷🇴", LangCode = "ro"},
        ["uk-ua"] = {Code = "UA", Country = "Ukraine", Language = "Ukrainian", Flag = "🇺🇦", LangCode = "uk"},
        ["bg-bg"] = {Code = "BG", Country = "Bulgaria", Language = "Bulgarian", Flag = "🇧🇬", LangCode = "bg"},
        ["hr-hr"] = {Code = "HR", Country = "Croatia", Language = "Croatian", Flag = "🇭🇷", LangCode = "hr"},
        ["sk-sk"] = {Code = "SK", Country = "Slovakia", Language = "Slovak", Flag = "🇸🇰", LangCode = "sk"},
        ["sl-si"] = {Code = "SI", Country = "Slovenia", Language = "Slovenian", Flag = "🇸🇮", LangCode = "sl"},
        ["lt-lt"] = {Code = "LT", Country = "Lithuania", Language = "Lithuanian", Flag = "🇱🇹", LangCode = "lt"},
        ["lv-lv"] = {Code = "LV", Country = "Latvia", Language = "Latvian", Flag = "🇱🇻", LangCode = "lv"},
        ["et-ee"] = {Code = "EE", Country = "Estonia", Language = "Estonian", Flag = "🇪🇪", LangCode = "et"},
        ["is-is"] = {Code = "IS", Country = "Iceland", Language = "Icelandic", Flag = "🇮🇸", LangCode = "is"},
        ["mt-mt"] = {Code = "MT", Country = "Malta", Language = "Maltese", Flag = "🇲🇹", LangCode = "mt"},
        ["sq-al"] = {Code = "AL", Country = "Albania", Language = "Albanian", Flag = "🇦🇱", LangCode = "sq"},
        ["mk-mk"] = {Code = "MK", Country = "North Macedonia", Language = "Macedonian", Flag = "🇲🇰", LangCode = "mk"},
        ["bs-ba"] = {Code = "BA", Country = "Bosnia", Language = "Bosnian", Flag = "🇧🇦", LangCode = "bs"},
        ["sr-rs"] = {Code = "RS", Country = "Serbia", Language = "Serbian", Flag = "🇷🇸", LangCode = "sr"},
        ["me-me"] = {Code = "ME", Country = "Montenegro", Language = "Montenegrin", Flag = "🇲🇪", LangCode = "sr"},
        ["lb-lu"] = {Code = "LU", Country = "Luxembourg", Language = "Luxembourgish", Flag = "🇱🇺", LangCode = "lb"},
        ["de-li"] = {Code = "LI", Country = "Liechtenstein", Language = "German", Flag = "🇱🇮", LangCode = "de"},
        ["de-ch"] = {Code = "CH", Country = "Switzerland", Language = "German", Flag = "🇨🇭", LangCode = "de"},
        ["fr-ch"] = {Code = "CH", Country = "Switzerland", Language = "French", Flag = "🇨🇭", LangCode = "fr"},
        ["it-ch"] = {Code = "CH", Country = "Switzerland", Language = "Italian", Flag = "🇨🇭", LangCode = "it"},
        ["rm-ch"] = {Code = "CH", Country = "Switzerland", Language = "Romansh", Flag = "🇨🇭", LangCode = "rm"},
        ["at-de"] = {Code = "AT", Country = "Austria", Language = "German", Flag = "🇦🇹", LangCode = "de"},
        
        ["ja-jp"] = {Code = "JP", Country = "Japan", Language = "Japanese", Flag = "🇯🇵", LangCode = "ja"},
        ["zh-cn"] = {Code = "CN", Country = "China", Language = "Chinese Simplified", Flag = "🇨🇳", LangCode = "zh-cn"},
        ["zh-tw"] = {Code = "TW", Country = "Taiwan", Language = "Chinese Traditional", Flag = "🇹🇼", LangCode = "zh-tw"},
        ["zh-hk"] = {Code = "HK", Country = "Hong Kong", Language = "Chinese Traditional", Flag = "🇭🇰", LangCode = "zh-tw"},
        ["ko-kr"] = {Code = "KR", Country = "South Korea", Language = "Korean", Flag = "🇰🇷", LangCode = "ko"},
        ["hi-in"] = {Code = "IN", Country = "India", Language = "Hindi", Flag = "🇮🇳", LangCode = "hi"},
        ["en-in"] = {Code = "IN", Country = "India", Language = "English", Flag = "🇮🇳", LangCode = "en"},
        ["id-id"] = {Code = "ID", Country = "Indonesia", Language = "Indonesian", Flag = "🇮🇩", LangCode = "id"},
        ["th-th"] = {Code = "TH", Country = "Thailand", Language = "Thai", Flag = "🇹🇭", LangCode = "th"},
        ["vi-vn"] = {Code = "VN", Country = "Vietnam", Language = "Vietnamese", Flag = "🇻🇳", LangCode = "vi"},
        ["ms-my"] = {Code = "MY", Country = "Malaysia", Language = "Malay", Flag = "🇲🇾", LangCode = "ms"},
        ["en-my"] = {Code = "MY", Country = "Malaysia", Language = "English", Flag = "🇲🇾", LangCode = "en"},
        ["fil-ph"] = {Code = "PH", Country = "Philippines", Language = "Filipino", Flag = "🇵🇭", LangCode = "tl"},
        ["en-ph"] = {Code = "PH", Country = "Philippines", Language = "English", Flag = "🇵🇭", LangCode = "en"},
        ["bn-bd"] = {Code = "BD", Country = "Bangladesh", Language = "Bengali", Flag = "🇧🇩", LangCode = "bn"},
        ["ur-pk"] = {Code = "PK", Country = "Pakistan", Language = "Urdu", Flag = "🇵🇰", LangCode = "ur"},
        ["en-pk"] = {Code = "PK", Country = "Pakistan", Language = "English", Flag = "🇵🇰", LangCode = "en"},
        ["ar-sa"] = {Code = "SA", Country = "Saudi Arabia", Language = "Arabic", Flag = "🇸🇦", LangCode = "ar"},
        ["ar-ae"] = {Code = "AE", Country = "UAE", Language = "Arabic", Flag = "🇦🇪", LangCode = "ar"},
        ["ar-qa"] = {Code = "QA", Country = "Qatar", Language = "Arabic", Flag = "🇶🇦", LangCode = "ar"},
        ["ar-kw"] = {Code = "KW", Country = "Kuwait", Language = "Arabic", Flag = "🇰🇼", LangCode = "ar"},
        ["ar-bh"] = {Code = "BH", Country = "Bahrain", Language = "Arabic", Flag = "🇧🇭", LangCode = "ar"},
        ["ar-om"] = {Code = "OM", Country = "Oman", Language = "Arabic", Flag = "🇴🇲", LangCode = "ar"},
        ["ar-ye"] = {Code = "YE", Country = "Yemen", Language = "Arabic", Flag = "🇾🇪", LangCode = "ar"},
        ["ar-jo"] = {Code = "JO", Country = "Jordan", Language = "Arabic", Flag = "🇯🇴", LangCode = "ar"},
        ["ar-lb"] = {Code = "LB", Country = "Lebanon", Language = "Arabic", Flag = "🇱🇧", LangCode = "ar"},
        ["he-il"] = {Code = "IL", Country = "Israel", Language = "Hebrew", Flag = "🇮🇱", LangCode = "he"},
        ["fa-ir"] = {Code = "IR", Country = "Iran", Language = "Persian", Flag = "🇮🇷", LangCode = "fa"},
        ["ps-af"] = {Code = "AF", Country = "Afghanistan", Language = "Pashto", Flag = "🇦🇫", LangCode = "ps"},
        ["tk-tm"] = {Code = "TM", Country = "Turkmenistan", Language = "Turkmen", Flag = "🇹🇲", LangCode = "tk"},
        ["uz-uz"] = {Code = "UZ", Country = "Uzbekistan", Language = "Uzbek", Flag = "🇺🇿", LangCode = "uz"},
        ["kk-kz"] = {Code = "KZ", Country = "Kazakhstan", Language = "Kazakh", Flag = "🇰🇿", LangCode = "kk"},
        ["ky-kg"] = {Code = "KG", Country = "Kyrgyzstan", Language = "Kyrgyz", Flag = "🇰🇬", LangCode = "ky"},
        ["tg-tj"] = {Code = "TJ", Country = "Tajikistan", Language = "Tajik", Flag = "🇹🇯", LangCode = "tg"},
        ["mn-mn"] = {Code = "MN", Country = "Mongolia", Language = "Mongolian", Flag = "🇲🇳", LangCode = "mn"},
        ["lo-la"] = {Code = "LA", Country = "Laos", Language = "Lao", Flag = "🇱🇦", LangCode = "lo"},
        ["km-kh"] = {Code = "KH", Country = "Cambodia", Language = "Khmer", Flag = "🇰🇭", LangCode = "km"},
        ["my-mm"] = {Code = "MM", Country = "Myanmar", Language = "Burmese", Flag = "🇲🇲", LangCode = "my"},
        ["si-lk"] = {Code = "LK", Country = "Sri Lanka", Language = "Sinhala", Flag = "🇱🇰", LangCode = "si"},
        ["ta-lk"] = {Code = "LK", Country = "Sri Lanka", Language = "Tamil", Flag = "🇱🇰", LangCode = "ta"},
        ["ne-np"] = {Code = "NP", Country = "Nepal", Language = "Nepali", Flag = "🇳🇵", LangCode = "ne"},
        
        ["ar-eg"] = {Code = "EG", Country = "Egypt", Language = "Arabic", Flag = "🇪🇬", LangCode = "ar"},
        ["ar-ly"] = {Code = "LY", Country = "Libya", Language = "Arabic", Flag = "🇱🇾", LangCode = "ar"},
        ["ar-tn"] = {Code = "TN", Country = "Tunisia", Language = "Arabic", Flag = "🇹🇳", LangCode = "ar"},
        ["ar-dz"] = {Code = "DZ", Country = "Algeria", Language = "Arabic", Flag = "🇩🇿", LangCode = "ar"},
        ["ar-ma"] = {Code = "MA", Country = "Morocco", Language = "Arabic", Flag = "🇲🇦", LangCode = "ar"},
        ["ar-mr"] = {Code = "MR", Country = "Mauritania", Language = "Arabic", Flag = "🇲🇷", LangCode = "ar"},
        ["ar-sd"] = {Code = "SD", Country = "Sudan", Language = "Arabic", Flag = "🇸🇩", LangCode = "ar"},
        ["ar-iq"] = {Code = "IQ", Country = "Iraq", Language = "Arabic", Flag = "🇮🇶", LangCode = "ar"},
        ["ar-sy"] = {Code = "SY", Country = "Syria", Language = "Arabic", Flag = "🇸🇾", LangCode = "ar"},
        ["ar-ps"] = {Code = "PS", Country = "Palestine", Language = "Arabic", Flag = "🇵🇸", LangCode = "ar"},
        
        ["af-za"] = {Code = "ZA", Country = "South Africa", Language = "Afrikaans", Flag = "🇿🇦", LangCode = "af"},
        ["en-za"] = {Code = "ZA", Country = "South Africa", Language = "English", Flag = "🇿🇦", LangCode = "en"},
        ["zu-za"] = {Code = "ZA", Country = "South Africa", Language = "Zulu", Flag = "🇿🇦", LangCode = "zu"},
        ["xh-za"] = {Code = "ZA", Country = "South Africa", Language = "Xhosa", Flag = "🇿🇦", LangCode = "xh"},
        ["st-za"] = {Code = "ZA", Country = "South Africa", Language = "Sesotho", Flag = "🇿🇦", LangCode = "st"},
        ["tn-za"] = {Code = "ZA", Country = "South Africa", Language = "Tswana", Flag = "🇿🇦", LangCode = "tn"},
        ["ss-za"] = {Code = "ZA", Country = "South Africa", Language = "Swati", Flag = "🇿🇦", LangCode = "ss"},
        ["ts-za"] = {Code = "ZA", Country = "South Africa", Language = "Tsonga", Flag = "🇿🇦", LangCode = "ts"},
        ["ve-za"] = {Code = "ZA", Country = "South Africa", Language = "Venda", Flag = "🇿🇦", LangCode = "ve"},
        ["sw-ke"] = {Code = "KE", Country = "Kenya", Language = "Swahili", Flag = "🇰🇪", LangCode = "sw"},
        ["en-ke"] = {Code = "KE", Country = "Kenya", Language = "English", Flag = "🇰🇪", LangCode = "en"},
        ["am-et"] = {Code = "ET", Country = "Ethiopia", Language = "Amharic", Flag = "🇪🇹", LangCode = "am"},
        ["ha-ng"] = {Code = "NG", Country = "Nigeria", Language = "Hausa", Flag = "🇳🇬", LangCode = "ha"},
        ["yo-ng"] = {Code = "NG", Country = "Nigeria", Language = "Yoruba", Flag = "🇳🇬", LangCode = "yo"},
        ["ig-ng"] = {Code = "NG", Country = "Nigeria", Language = "Igbo", Flag = "🇳🇬", LangCode = "ig"},
        ["en-ng"] = {Code = "NG", Country = "Nigeria", Language = "English", Flag = "🇳🇬", LangCode = "en"},
        ["so-so"] = {Code = "SO", Country = "Somalia", Language = "Somali", Flag = "🇸🇴", LangCode = "so"},
        ["rw-rw"] = {Code = "RW", Country = "Rwanda", Language = "Kinyarwanda", Flag = "🇷🇼", LangCode = "rw"},
        ["rn-bi"] = {Code = "BI", Country = "Burundi", Language = "Kirundi", Flag = "🇧🇮", LangCode = "rn"},
        ["mg-mg"] = {Code = "MG", Country = "Madagascar", Language = "Malagasy", Flag = "🇲🇬", LangCode = "mg"},
        ["fr-mg"] = {Code = "MG", Country = "Madagascar", Language = "French", Flag = "🇲🇬", LangCode = "fr"},
        ["sn-zw"] = {Code = "ZW", Country = "Zimbabwe", Language = "Shona", Flag = "🇿🇼", LangCode = "sn"},
        ["en-zw"] = {Code = "ZW", Country = "Zimbabwe", Language = "English", Flag = "🇿🇼", LangCode = "en"},
        ["ny-mw"] = {Code = "MW", Country = "Malawi", Language = "Chichewa", Flag = "🇲🇼", LangCode = "ny"},
        ["en-mw"] = {Code = "MW", Country = "Malawi", Language = "English", Flag = "🇲🇼", LangCode = "en"},
        ["pt-mz"] = {Code = "MZ", Country = "Mozambique", Language = "Portuguese", Flag = "🇲🇿", LangCode = "pt"},
        ["ln-cd"] = {Code = "CD", Country = "DR Congo", Language = "Lingala", Flag = "🇨🇩", LangCode = "ln"},
        ["sw-cd"] = {Code = "CD", Country = "DR Congo", Language = "Swahili", Flag = "🇨🇩", LangCode = "sw"},
        ["fr-cd"] = {Code = "CD", Country = "DR Congo", Language = "French", Flag = "🇨🇩", LangCode = "fr"},
        ["fr-ci"] = {Code = "CI", Country = "Ivory Coast", Language = "French", Flag = "🇨🇮", LangCode = "fr"},
        ["fr-sn"] = {Code = "SN", Country = "Senegal", Language = "French", Flag = "🇸🇳", LangCode = "fr"},
        ["fr-cm"] = {Code = "CM", Country = "Cameroon", Language = "French", Flag = "🇨🇲", LangCode = "fr"},
        ["en-cm"] = {Code = "CM", Country = "Cameroon", Language = "English", Flag = "🇨🇲", LangCode = "en"},
        ["fr-bf"] = {Code = "BF", Country = "Burkina Faso", Language = "French", Flag = "🇧🇫", LangCode = "fr"},
        ["fr-ml"] = {Code = "ML", Country = "Mali", Language = "French", Flag = "🇲🇱", LangCode = "fr"},
        ["fr-ne"] = {Code = "NE", Country = "Niger", Language = "French", Flag = "🇳🇪", LangCode = "fr"},
        ["fr-tg"] = {Code = "TG", Country = "Togo", Language = "French", Flag = "🇹🇬", LangCode = "fr"},
        ["fr-bj"] = {Code = "BJ", Country = "Benin", Language = "French", Flag = "🇧🇯", LangCode = "fr"},
        ["fr-ga"] = {Code = "GA", Country = "Gabon", Language = "French", Flag = "🇬🇦", LangCode = "fr"},
        ["fr-cg"] = {Code = "CG", Country = "Congo", Language = "French", Flag = "🇨🇬", LangCode = "fr"},
        ["fr-gq"] = {Code = "GQ", Country = "Equatorial Guinea", Language = "French", Flag = "🇬🇶", LangCode = "fr"},
        ["es-gq"] = {Code = "GQ", Country = "Equatorial Guinea", Language = "Spanish", Flag = "🇬🇶", LangCode = "es"},
        ["pt-gw"] = {Code = "GW", Country = "Guinea-Bissau", Language = "Portuguese", Flag = "🇬🇼", LangCode = "pt"},
        ["pt-cv"] = {Code = "CV", Country = "Cape Verde", Language = "Portuguese", Flag = "🇨🇻", LangCode = "pt"},
        ["pt-st"] = {Code = "ST", Country = "Sao Tome", Language = "Portuguese", Flag = "🇸🇹", LangCode = "pt"},
        
        ["en-au"] = {Code = "AU", Country = "Australia", Language = "English", Flag = "🇦🇺", LangCode = "en"},
        ["en-nz"] = {Code = "NZ", Country = "New Zealand", Language = "English", Flag = "🇳🇿", LangCode = "en"},
        ["mi-nz"] = {Code = "NZ", Country = "New Zealand", Language = "Maori", Flag = "🇳🇿", LangCode = "mi"},
        ["en-pg"] = {Code = "PG", Country = "Papua New Guinea", Language = "English", Flag = "🇵🇬", LangCode = "en"},
        ["tpi-pg"] = {Code = "PG", Country = "Papua New Guinea", Language = "Tok Pisin", Flag = "🇵🇬", LangCode = "tpi"},
        ["en-fj"] = {Code = "FJ", Country = "Fiji", Language = "English", Flag = "🇫🇯", LangCode = "en"},
        ["fj-fj"] = {Code = "FJ", Country = "Fiji", Language = "Fijian", Flag = "🇫🇯", LangCode = "fj"},
        ["sm-ws"] = {Code = "WS", Country = "Samoa", Language = "Samoan", Flag = "🇼🇸", LangCode = "sm"},
        ["en-ws"] = {Code = "WS", Country = "Samoa", Language = "English", Flag = "🇼🇸", LangCode = "en"},
        ["to-to"] = {Code = "TO", Country = "Tonga", Language = "Tongan", Flag = "🇹🇴", LangCode = "to"},
        ["en-to"] = {Code = "TO", Country = "Tonga", Language = "English", Flag = "🇹🇴", LangCode = "en"},
        ["ty-py"] = {Code = "PF", Country = "French Polynesia", Language = "Tahitian", Flag = "🇵🇫", LangCode = "ty"},
        ["fr-pf"] = {Code = "PF", Country = "French Polynesia", Language = "French", Flag = "🇵🇫", LangCode = "fr"},
        ["en-sb"] = {Code = "SB", Country = "Solomon Islands", Language = "English", Flag = "🇸🇧", LangCode = "en"},
        ["bi-vu"] = {Code = "VU", Country = "Vanuatu", Language = "Bislama", Flag = "🇻🇺", LangCode = "bi"},
        ["en-vu"] = {Code = "VU", Country = "Vanuatu", Language = "English", Flag = "🇻🇺", LangCode = "en"},
        ["fr-vu"] = {Code = "VU", Country = "Vanuatu", Language = "French", Flag = "🇻🇺", LangCode = "fr"},
        ["na-nr"] = {Code = "NR", Country = "Nauru", Language = "Nauruan", Flag = "🇳🇷", LangCode = "na"},
        ["en-nr"] = {Code = "NR", Country = "Nauru", Language = "English", Flag = "🇳🇷", LangCode = "en"},
        ["mh-mh"] = {Code = "MH", Country = "Marshall Islands", Language = "Marshallese", Flag = "🇲🇭", LangCode = "mh"},
        ["en-mh"] = {Code = "MH", Country = "Marshall Islands", Language = "English", Flag = "🇲🇭", LangCode = "en"},
        ["ch-gu"] = {Code = "GU", Country = "Guam", Language = "Chamorro", Flag = "🇬🇺", LangCode = "ch"},
        ["en-gu"] = {Code = "GU", Country = "Guam", Language = "English", Flag = "🇬🇺", LangCode = "en"},
    }
    
    local Result = Countries[locale] or Countries[locale:sub(1,2)] or Countries["en-us"]

    return Result.Code, Result.Country, Result.Language, Result.Flag, locale, Result.LangCode
end

function API:GetLanguage(Input)
    if not Input then return nil end

    local Lowered = tostring(Input):lower()
    if Lowered == "home" then
        local Code, Country, Language, Flag, Locale, LangCode = self:GetCountry()
        return LangCode or "en"
    end

    local Languages = {
        auto = "Automatic", af = "Afrikaans", sq = "Albanian", ar = "Arabic",
        hy = "Armenian", az = "Azerbaijani", eu = "Basque", be = "Belarusian",
        bn = "Bengali", bs = "Bosnian", bg = "Bulgarian", ca = "Catalan",
        ceb = "Cebuano", ny = "Chichewa", ["zh-cn"] = "Chinese Simplified", 
        ["zh-tw"] = "Chinese Traditional", co = "Corsican", hr = "Croatian",
        cs = "Czech", da = "Danish", nl = "Dutch", en = "English",
        eo = "Esperanto", et = "Estonian", tl = "Filipino", fi = "Finnish",
        fr = "French", fy = "Frisian", gl = "Galician", ka = "Georgian",
        de = "German", el = "Greek", gu = "Gujarati", ht = "Haitian Creole",
        ha = "Hausa", haw = "Hawaiian", he = "Hebrew", hi = "Hindi",
        hmn = "Hmong", hu = "Hungarian", is = "Icelandic", ig = "Igbo",
        id = "Indonesian", ga = "Irish", it = "Italian", ja = "Japanese",
        jw = "Javanese", kn = "Kannada", kk = "Kazakh", km = "Khmer",
        ko = "Korean", ku = "Kurdish", ky = "Kyrgyz", lo = "Lao",
        la = "Latin", lv = "Latvian", lt = "Lithuanian", lb = "Luxembourgish",
        mk = "Macedonian", mg = "Malagasy", ms = "Malay", ml = "Malayalam",
        mt = "Maltese", mi = "Maori", mr = "Marathi", mn = "Mongolian",
        my = "Myanmar", ne = "Nepali", no = "Norwegian", ps = "Pashto",
        fa = "Persian", pl = "Polish", pt = "Portuguese", pa = "Punjabi",
        ro = "Romanian", ru = "Russian", sm = "Samoan", gd = "Scots Gaelic",
        sr = "Serbian", st = "Sesotho", sn = "Shona", sd = "Sindhi",
        si = "Sinhala", sk = "Slovak", sl = "Slovenian", so = "Somali",
        es = "Spanish", su = "Sundanese", sw = "Swahili", sv = "Swedish",
        tg = "Tajik", ta = "Tamil", te = "Telugu", th = "Thai",
        tr = "Turkish", uk = "Ukrainian", ur = "Urdu", uz = "Uzbek",
        vi = "Vietnamese", cy = "Welsh", xh = "Xhosa", yi = "Yiddish",
        yo = "Yoruba", zu = "Zulu"
    }
    
    if Languages[Lowered] then
        return Lowered
    end

    for Code, Name in pairs(Languages) do
        if Name:lower() == Lowered then
            return Code
        end
    end
    
    return nil
end

function API:Translate(Text, TargetLang, Source)
    if not Text or Text == "" then return nil end
    
    TargetLang = self:GetLanguage(TargetLang or "en")
    Source = self:GetLanguage(Source or "auto")
    
    if not TargetLang then TargetLang = "en" end
    if not Source then Source = "auto" end

    self.TranslateMemoryCache = self.TranslateMemoryCache or {}
    self.TranslateMemoryCache[TargetLang] = self.TranslateMemoryCache[TargetLang] or {}
    
    local CacheRoot = "@Translations/"
    local TargetPath = CacheRoot .. TargetLang .. "/"
    
    if not is_folder(CacheRoot) then make_folder(CacheRoot) end
    if not is_folder(TargetPath) then make_folder(TargetPath) end
    
    local Words = {}
    for Word in string_gmatch(Text, "[^%s]+") do
        local CleanWord = string_gsub(Word, "[%p%c]", "")
        if CleanWord ~= "" then
            table_insert(Words, {Original = Word, Clean = CleanWord})
        end
    end

    local TranslatedWords, UncachedWords, NeedsTranslation = {}, {}, false

    if Source ~= "auto" then
        self.TranslateMemoryCache[TargetLang][Source] = self.TranslateMemoryCache[TargetLang][Source] or {}
        local MemCache = self.TranslateMemoryCache[TargetLang][Source]

        local SourcePath = TargetPath .. Source .. "/"
        if not is_folder(SourcePath) then make_folder(SourcePath) end

        for Index, WordData in ipairs(Words) do
            local CachedTranslation = MemCache[WordData.Clean]

            if CachedTranslation then
                TranslatedWords[Index] = CachedTranslation
            else
                local CacheFile = SourcePath .. WordData.Clean .. ".json"

                local Cached = self:LoadData(CacheFile)
                if Cached and Cached.Translated then
                    MemCache[WordData.Clean] = Cached.Translated
                    TranslatedWords[Index] = Cached.Translated
                else
                    table_insert(UncachedWords, {Index = Index, Word = WordData.Original, Clean = WordData.Clean})
                    NeedsTranslation = true
                end
            end
        end
    else
        NeedsTranslation = true
    end
    
    if not NeedsTranslation and #UncachedWords == 0 then
        local Result = table_concat(TranslatedWords, " ")
        return Result, TargetLang, Text, Source
    end
    
    local TranslateAPI = ("https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s")
        :format(Source, TargetLang, HttpService:UrlEncode(Text))
    
    local RequestSuccess, Response = pcall(function()
        return Game:HttpGet(TranslateAPI)
    end)
    
    if not RequestSuccess or not Response then 
        return nil 
    end
    
    local DecodeSuccess, Data = pcall(function()
        return HttpService:JSONDecode(Response)
    end)
    
    if not DecodeSuccess or typeof(Data) ~= "table" then
        return nil
    end
    
    local TranslatedText = nil
    local OriginalText = nil
    
    if Data[1] and typeof(Data[1]) == "table" then
        local TranslatedParts = {}
        local OriginalParts = {}
        
        for i = 1, #Data[1] do
            if Data[1][i] and Data[1][i][1] then
                table_insert(TranslatedParts, Data[1][i][1])
            end
            if Data[1][i] and Data[1][i][0] then
                table_insert(OriginalParts, Data[1][i][0])
            end
        end
        
        if #OriginalParts == 0 and Data[1][1] and Data[1][1][2] then
            for i = 1, #Data[1] do
                if Data[1][i] and Data[1][i][2] then
                    table_insert(OriginalParts, Data[1][i][2])
                end
            end
        end
        
        if #TranslatedParts > 0 then
            TranslatedText = table_concat(TranslatedParts, "")
        end
        if #OriginalParts > 0 then
            OriginalText = table_concat(OriginalParts, "")
        else
            OriginalText = Text
        end
    end
    
    local DetectedSource = Data[3] or Source
    local TargetCode = TargetLang
    
    if not TranslatedText then
        return nil
    end
    
    if DetectedSource ~= "auto" then
        self.TranslateMemoryCache[TargetLang][DetectedSource] = self.TranslateMemoryCache[TargetLang][DetectedSource] or {}
        local MemCache = self.TranslateMemoryCache[TargetLang][DetectedSource]
        
        local SourcePath = TargetPath .. DetectedSource .. "/"
        if not is_folder(SourcePath) then make_folder(SourcePath) end
        
        local TranslatedWordList = {}
        for Word in string_gmatch(TranslatedText, "[^%s]+") do
            local CleanWord = string_gsub(Word, "[%p%c]", "")

            table_insert(TranslatedWordList, {Original = Word, Clean = CleanWord})
        end

        for Index, WordData in ipairs(Words) do
            if TranslatedWordList[Index] then
                MemCache[WordData.Clean] = TranslatedWordList[Index].Original

                local CacheFile = SourcePath .. WordData.Clean .. ".json"
                self:SaveData(CacheFile, {Original = WordData.Original, Translated = TranslatedWordList[Index].Original})
            end
        end
    end
    
    return TranslatedText, TargetCode, OriginalText, DetectedSource
end

-- // @Developer Tool Scripts
function API:Infinite_Yield()
    return self:LoadFile("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
end

function API:Cobalt_Spy()
    return self:Gitport("notpoiu", "cobalt", "latest", "Cobalt.luau")
end

function API:Katemine_Spy()
    return self:LoadFile("https://raw.githubusercontent.com/InfernusScripts/Ketamine/main/Ketamine.lua")
end

function API:Simple_Spy()
    return self:LoadFile("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua")
end

function API:Dex_Explorer()
    return self:LoadFile("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
end

function API:Audio_Logger()
    return self:LoadFile("https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua")
end

function API:Vulnerability_Test()
    return self:LoadFile("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/VulnTest.lua")
end

-- // @LoopManager Reborn V2
function API:CreateLM()
    if typeof(self.LM) ~= "table" then
        self.LM = {
            Stacks = {
                WhileLoop = {
                    Loops = {},
                    Connections = {}
                },
                HeavyLoop = {
                    Loops = {},
                    Connections = {}
                },
                Heartbeat = {
                    Loops = {},
                    Connection = nil
                },
                RenderStep = {
                    Loops = {},
                    Connection = nil
                },
                Stepped = {
                    Loops = {},
                    Connection = nil
                },
                BindToRenderStep = {
                    Loops = {},
                },
                Keybind = {
                    Loops = {},
                },
                Task = {
                    Loops = {},
                }
            },
            Debug = false, Unloaded = false,
        }
    end
end

function API:LogLM(Message, ...)
    if not self.LM or not self.LM.Debug then return end
    if not Message then return end
    warn("[@Loop Manager]: " .. string_format(Message, ...))
end

function API:AddService(Name, Signal)
    local Local = self
    Local:CreateLM()

    local Stack = Local.LM.Stacks[Name]
    if not Stack then return end
    if Stack.Connection then return end

    Stack.Connection = Signal:Connect(function(...)
        if Local.LM.Unloaded then return end

        for _, Data in pairs(Stack.Loops) do
            if Data.Running and not Data.Paused then
                task_spawn(Data.Callback, Local, ...)
            end
        end
    end)
end

function API:SmartLoop(WaitBoy, Callback, Name, WaitBefore, Destroyed)
    local Local = self
    Local:CreateLM()
    
    if typeof(WaitBoy) == "function" then
        local Function_1, Function_2, Function_3 = WaitBoy, Callback, Name
        WaitBoy = nil
        Callback = Function_1
        Name = Function_2
        WaitBefore = Function_3
    end

    if not Callback or typeof(Callback) ~= "function" then
        Local:LogLM("SmartLoop requires a callback function")
        return nil
    end

    local Wait, Name = WaitBoy or 0, Name or Local:RandomString(15)

    local function Decision_Optimization()
        local Count = 0
        for _, Data in pairs(Local.LM.Stacks.WhileLoop.Loops) do
            if Data.Wait == Wait and Data.Running then
                Count = Count + 1
            end
        end
        for _, Data in pairs(Local.LM.Stacks.HeavyLoop.Loops) do
            if Data.Wait == Wait and Data.Running then
                Count = Count + 1
            end
        end
        return Count + 1
    end

    local Decision = Decision_Optimization()

    if Decision >= 5 or (Wait < 0.05 and Decision >= 3) then
        Local:LogLM("Using HeavyLoop for '%s' (Wait: %s, %d+ loops)", Name, Wait, Decision)
        return Local:HeavyLoop(Wait, Callback, Name, WaitBefore, Destroyed)
    else
        Local:LogLM("Using WhileLoop for '%s' (Wait: %s)", Name, Wait)
        return Local:WhileLoop(Wait, Callback, Name, WaitBefore, Destroyed)
    end
end

function API:WhileLoop(WaitBoy, Callback, Name, WaitBefore, Destroyed)
    local Local = self
    Local:CreateLM()
    
    if typeof(WaitBoy) == "function" then
        local Function_1, Function_2, Function_3 = WaitBoy, Callback, Name
        WaitBoy = nil
        Callback = Function_1
        Name = Function_2
        WaitBefore = Function_3
    end

    if not Callback or typeof(Callback) ~= "function" then
        Local:LogLM("WhileLoop requires a callback function")
        return nil
    end

    local Wait, Name = WaitBoy or 0, Name or Local:RandomString(15)

    local Delay = 0 
    if WaitBefore == true then 
        Delay = Wait 
    elseif typeof(WaitBefore) == "number" then 
        Delay = WaitBefore 
    end

    local Data = {
        Type = "WhileLoop",
        Running = true,
        Paused = false,
        Thread = nil,
        Name = Name,
        Callback = Callback,
        Wait = Wait,
        WaitBefore = WaitBefore,
        Destroyed = Destroyed,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Paused WhileLoop '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Unpaused WhileLoop '%s'", Name)
        end,
        SetWait = function(s, New)
            if typeof(New) ~= "number" or New < 0 then
                Local:LogLM("Invalid wait time for '%s': %s", Name, tostring(New))
                return
            end
            s.Wait = New
            Local:LogLM("Set wait for '%s' to %s seconds", Name, New)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Killed WhileLoop '%s'", Name)
        end
    }

    Local.LM.Stacks.WhileLoop.Loops[Name] = Data

    Data.Thread = task_create(function()
        if Delay > 0 then
            task_wait(Delay)
        end

        while Data.Running do
            if Local.LM.Unloaded then return end

            if not Data.Paused then
                Data.Callback(Local)
                if Wait > 0 then
                    task_wait(Wait)
                end
            else
                task_wait()
            end
        end
    end)

    task_resume(Data.Thread)
    return Data
end

function API:HeavyLoop(WaitBoy, Callback, Name, WaitBefore, Destroyed)
    local Local = self
    Local:CreateLM()

    if typeof(WaitBoy) == "function" then
        local Function_1, Function_2, Function_3 = WaitBoy, Callback, Name
        WaitBoy = nil
        Callback = Function_1
        Name = Function_2
        WaitBefore = Function_3
    end

    if not Callback or typeof(Callback) ~= "function" then
        Local:LogLM("HeavyLoop requires a callback function")
        return nil
    end

    local Wait, Name, Waiting = WaitBoy or 0, Name or Local:RandomString(15), {}

    if not Local.LM.Stacks.HeavyLoop.Connections[Wait] then
        Local.LM.Stacks.HeavyLoop.Connections[Wait] = {Coroutines = {}, Running = true, Connection = nil, Wait = Wait, LastRun = nil}
        local Stack_Data = Local.LM.Stacks.HeavyLoop.Connections[Wait]
        
        Stack_Data.Connection = Heartbeat:Connect(function(Delta)
            if Local.LM.Unloaded then return end
            if not Stack_Data.Running then return end

            local Time, Running = os_clock(), false
            
            if Wait == 0 then
                Running = true
            elseif Stack_Data.LastRun == nil then
                Running = true
                Stack_Data.LastRun = Time
            elseif Time - Stack_Data.LastRun >= Stack_Data.Wait then
                Running = true
                Stack_Data.LastRun = Time
            end
            
            for Name, Data in pairs(Stack_Data.Coroutines) do
                if Data.Running and not Data.Paused then
                    local Floop = Waiting[Data.Coroutine]
                    if Floop then
                        Floop.Remaining = Floop.Remaining - Delta
                        if Floop.Remaining <= 0 then
                            Waiting[Data.Coroutine] = nil
                            Data.IsWaiting = false
                        end
                    end
                end
            end
            
            if Running then
                for Name, Data in pairs(Stack_Data.Coroutines) do
                    if Data.Running and not Data.Paused and not Data.IsWaiting then
                        if not Waiting[Data.Coroutine] then
                            task_resume(Data.Coroutine, Local, Delta)
                        end
                    end
                end
            end
        end)
    end

    local Stack_Data = Local.LM.Stacks.HeavyLoop.Connections[Wait]

    local function Cooldown(Seconds)
        local CO2 = task_running()
        Waiting[CO2] = {Remaining = Seconds}
        for Name, Data in pairs(Stack_Data.Coroutines) do
            if Data.Coroutine == CO2 then
                Data.IsWaiting = true
                break
            end
        end
        task_yield()
    end
    
    local Delay = 0 
    if WaitBefore == true then 
        Delay = Wait 
    elseif typeof(WaitBefore) == "number" then 
        Delay = WaitBefore 
    end

    local Source = task_create(function(self, Dt)
        if Delay > 0 then
            Cooldown(Delay)
        end
    
        while Stack_Data.Running do
            Callback(self, Dt, Cooldown)
            task_yield()
        end
    end)

    local Data = {
        Type = "HeavyLoop",
        Running = true,
        Paused = false,
        IsWaiting = false,
        Coroutine = Source,
        Name = Name,
        Callback = Callback,
        Wait = Wait,
        WaitBefore = WaitBefore,
        Destroyed = Destroyed,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Paused HeavyLoop '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Unpaused HeavyLoop '%s'", Name)
        end,
        SetWait = function(s, New)
            if typeof(New) ~= "number" or New < 0 then
                Local:LogLM("Invalid wait time for '%s': %s", Name, tostring(New))
                return
            end
            Stack_Data.Wait = New
            s.Wait = New
            Local:LogLM("Set wait for '%s' to %s seconds", Name, New)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Killed HeavyLoop '%s'", Name)
        end
    }

    Stack_Data.Coroutines[Name] = Data
    if WaitBefore then task_resume(Source, Local, 0) end

    return Data
end

function API:Heartbeat(Callback, Name)
    local Local = self
    Local:CreateLM()

    if typeof(Callback) ~= "function" then
        Local:LogLM("Heartbeat requires a callback function")
        return nil
    end

    local Name = Name or Local:RandomString(15)
    Local.AddService(Local, "Heartbeat", Heartbeat)

    local Data = {
        Type = "Heartbeat",
        Running = true,
        Paused = false,
        Name = Name,
        Callback = Callback,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Paused Heartbeat '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Unpaused Heartbeat '%s'", Name)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Killed Heartbeat '%s'", Name)
        end
    }

    Local.LM.Stacks.Heartbeat.Loops[Name] = Data
    return Data
end

function API:RenderStep(Callback, Name)
    local Local = self
    Local:CreateLM()

    if typeof(Callback) ~= "function" then
        Local:LogLM("RenderStep requires a callback function")
        return nil
    end

    local Name = Name or Local:RandomString(15)
    Local.AddService(Local, "RenderStep", RenderStepped)

    local Data = {
        Type = "RenderStep",
        Running = true,
        Paused = false,
        Name = Name,
        Callback = Callback,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Paused RenderStep '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Unpaused RenderStep '%s'", Name)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Killed RenderStep '%s'", Name)
        end
    }

    Local.LM.Stacks.RenderStep.Loops[Name] = Data
    return Data
end

function API:Stepped(Callback, Name)
    local Local = self
    Local:CreateLM()

    if typeof(Callback) ~= "function" then
        Local:LogLM("Stepped requires a callback function")
        return nil
    end

    local Name = Name or Local:RandomString(15)
    Local.AddService(Local, "Stepped", Stepped)

    local Data = {
        Type = "Stepped",
        Running = true,
        Paused = false,
        Name = Name,
        Callback = Callback,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Paused Stepped '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Unpaused Stepped '%s'", Name)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Killed Stepped '%s'", Name)
        end
    }

    Local.LM.Stacks.Stepped.Loops[Name] = Data
    return Data
end

function API:BindRender(Callback, Name, Priority)
    local Local = self
    Local:CreateLM()

    if typeof(Callback) ~= "function" then
        Local:LogLM("BindRender requires a callback function")
        return nil
    end

    local Name = Name or self:RandomString(15)

    local Data = {
        Type = "BindToRenderStep",
        Running = true,
        Paused = false,
        Name = Name,
        Callback = Callback,
        Priority = Priority or Enum.RenderPriority.Last.Value,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Paused BindToRenderStep '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Unpaused BindToRenderStep '%s'", Name)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Killed BindToRenderStep '%s'", Name)
        end
    }

    local Func = function(Dt)
        if Local.LM.Unloaded or not Data.Running or Data.Paused then 
            return 
        end
        Data.Callback(Local, Dt)
    end

    BindToRenderStep(Name, Priority or Enum.RenderPriority.Last.Value, Func)
    Data.Func = Func

    Local.LM.Stacks.BindToRenderStep.Loops[Name] = Data
    return Data
end

function API:BindKeybind(Key, Callback, BindName)
    local Local = self
    Local:CreateLM()

    if not Key then
        Local:LogLM("BindKeybind requires a Key parameter")
        return nil
    end

    if typeof(Callback) ~= "function" then
        Local:LogLM("BindKeybind requires a callback function")
        return nil
    end

    local Name = BindName or Local:RandomString(15)

    local Data = {
        Type = "Keybind",
        Running = true,
        Paused = false,
        Name = Name,
        Key = Key,
        Callback = Callback,
        Connection = nil,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Paused Keybind '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Unpaused Keybind '%s'", Name)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Killed Keybind '%s'", Name)
        end
    }

    local Func = function(Input, Processed)
        if Processed or Local.LM.Unloaded or not Data.Running or Data.Paused then 
            return 
        end
        if Input.KeyCode == Key or Input.UserInputType == Key then
            Data.Callback(Local, Input)
        end
    end

    Data.Connection = InputBegan:Connect(Func)
    Local.LM.Stacks.Keybind.Loops[Name] = Data
    return Data
end

function API:SetKeybind(Name, NewKey)
    local Local = self

    local Data = Local.LM and Local.LM.Stacks.Keybind.Loops[Name]
    if not Data or Data.Type ~= "Keybind" then
        Local:LogLM("SetKeybind Could not find '%s' or its not a keybind", Name)
        return false
    end

    if not NewKey then
        Local:LogLM("SetKeybind requires a 'NewKey' parameter")
        return false
    end

    Local:LogLM("Updating keybind '%s' from %s to %s", Name, tostring(Data.Key), tostring(NewKey))

    if Data.Connection then
        Data.Connection:Disconnect()
    end

    Data.Key = NewKey

    local Func = function(Input, Processed)
        if Processed or Local.LM.Unloaded or not Data.Running or Data.Paused then 
            return 
        end
        if Input.KeyCode == NewKey or Input.UserInputType == NewKey then
            Data.Callback(Local, Input)
        end
    end

    Data.Connection = InputBegan:Connect(Func)
    return true
end

function API:AddTask(Signal, Callback, Name)
    local Local = self
    Local:CreateLM()

    if Local.LM.Stacks.Task.Loops[Name] then
        return Local.LM.Stacks.Task.Loops[Name]
    end

    local Name = Name or self:RandomString(15)

    local Data = {
        Type = "Task",
        Running = true,
        Paused = false,
        Name = Name,
        Signal = Signal,
        Callback = Callback,
        Connection = nil,
        Pause = function(s) 
            s.Paused = true 
            Local:LogLM("Task '%s' paused", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            Local:LogLM("Task '%s' unpaused", Name)
        end,
        Kill = function(s) 
            Local:ForceStop(Name)
            Local:LogLM("Task '%s' killed", Name)
        end
    }

    Data.Connection = Signal:Connect(function(...)
        if Data.Running and not Data.Paused and not Local.LM.Unloaded then
            Data.Callback(Local, ...)
        end
    end)

    Local.LM.Stacks.Task.Loops[Name] = Data
    return Data
end

function API:ForceStop(Name)
    local Found, Local = false, self

    if Local.LM and Local.LM.Stacks and Local.LM.Stacks.HeavyLoop and Local.LM.Stacks.HeavyLoop.Connections then
        for Wait, Stack_Data in pairs(Local.LM.Stacks.HeavyLoop.Connections) do
            if Stack_Data.Coroutines and Stack_Data.Coroutines[Name] then
                local Data = Stack_Data.Coroutines[Name]
                
                if Data.Coroutine then
                    pcall(task_cancel, Data.Coroutine)
                end
                
                if Data.Destroyed then
                    pcall(Data.Destroyed, Local)
                end
                
                Data.Running = false
                Stack_Data.Coroutines[Name] = nil

                if Local.LM.Stacks.HeavyLoop.Loops then
                    Local.LM.Stacks.HeavyLoop.Loops[Name] = nil
                end

                if not next(Stack_Data.Coroutines) then
                    if Stack_Data.Connection then
                        pcall(Stack_Data.Connection.Disconnect, Stack_Data.Connection)
                    end
                    Local.LM.Stacks.HeavyLoop.Connections[Wait] = nil
                end
                
                Found = true
                Local:LogLM("Disconnected '%s' (HeavyLoop)", Name)
                break
            end
        end
    end

    if not Found then
        for StackName, Stack in pairs(Local.LM.Stacks) do
            if Stack.Loops and Stack.Loops[Name] then
                local Data = Stack.Loops[Name]

                if Data.Type == "WhileLoop" and Data.Thread then
                    pcall(task_cancel, Data.Thread)
                elseif Data.Type == "BindToRenderStep" and Data.Func then
                    pcall(UnbindFromRenderStep, Name)
                elseif Data.Type == "Keybind" and Data.Connection then
                    pcall(Data.Connection.Disconnect, Data.Connection)
                elseif Data.Type == "Task" and Data.Connection then
                    pcall(Data.Connection.Disconnect, Data.Connection)
                end

                if Data.Destroyed then
                    pcall(Data.Destroyed, Local)
                end

                Data.Running, Stack.Loops[Name], Found = false, nil, true
                Local:LogLM("Disconnected '%s' (%s)", Name, Data.Type)
                break
            end
        end
    end

    if not Found then
        Local:LogLM("Could not find '%s'", Name)
    end

    return Found
end

function API:SetWait(Name, New)
    local Local = self
    Local:CreateLM()

    for StackName, Stack in pairs(Local.LM.Stacks) do
        if Stack.Loops and Stack.Loops[Name] then
            local Data = Stack.Loops[Name]
            if Data.SetWait then
                return Data:SetWait(New)
            end
        end
    end

    Local:LogLM("Could not find '%s'", Name)
    return false
end

function API:GetState(Name)
    local Local = self

    for StackName, Stack in pairs(Local.LM.Stacks) do
        if Stack.Loops and Stack.Loops[Name] then
            local Data = Stack.Loops[Name]
            if not Data.Running then return false end
            if Data.Paused then return false end
            return true
        end
    end
    return false
end

function API:ToggleLM(State)
    if typeof(State) == "boolean" then
        self.LM.Unloaded = State
    end
end

function API:Unload_LM()
    if not self.LM then return end

    self.LM.Unloaded = true
    task_wait()

    for StackName, Stack in pairs(self.LM.Stacks or {}) do
        if Stack.Loops then
            local Count = 0
            for Name, _ in pairs(Stack.Loops) do
                pcall(function() self:ForceStop(Name) end)
                Count = Count + 1
            end
            if Count > 0 then
                pcall(function() self:LogLM("Unloaded %d %ss", Count, StackName) end)
            end
        end
    end

    for StackName, Stack in pairs(self.LM.Stacks or {}) do
        if Stack.Connection then
            pcall(function() 
                if Stack.Connection.Disconnect then
                    Stack.Connection:Disconnect() 
                end
            end)
            Stack.Connection = nil
        end
        
        if Stack.Connections then
            for _, Data in pairs(Stack.Connections) do
                if Data and Data.Connection then
                    pcall(function()
                        if Data.Connection.Disconnect then
                            Data.Connection:Disconnect()
                        end
                    end)
                    Data.Connection = nil
                end
            end
            table_clear(Stack.Connections)
        end
    end

    table_clear(self.LM)
    self.LM = nil
end

function API:AddFeature(Group, Name, Options) -- // @Obsidian only
    API[Name] = Options.Default or false

    local Disabled, Recrusive, Toggle, LoopData, Object = false, false, nil, nil, {}
    local IsLoading = true

    Toggle = Group:AddToggle(Name, {
        Text = Options.Text or "Toggle",
        Tooltip = Options.Tooltip or nil,
        DisabledTooltip = Options.DisabledTooltip or nil,
        Default = Options.Default or false,
        Disabled = Options.Disabled or false,
        Visible = Options.Visible or true,
        Risky = Options.Risky or false,
        Callback = function(Value)
            if Recrusive then return end

            Recrusive = true
            API[Name] = Value
            
            if Value then
                if Options.OnEnable then 
                    Options.OnEnable(API, Object)
                end
            else
                if Options.OnDisable then 
                    Options.OnDisable(API, Object)
                end
            end
    
            if Options.Callback then
                if not IsLoading or Options.CallOnLaunch or (IsLoading and Options.Default and Options.CallOnLaunch ~= false) then
                    Options.Callback(API, Object, Value)
                end
            end
            
            Recrusive = false
        end,
        Changed = Options.Changed or function() end
    })

    function Object:SetText(Text)
        if Toggle and Toggle.SetText then
            Toggle:SetText(Text)
        end
        return self
    end

    function Object:SetVisible(Visible)
        if Toggle and Toggle.SetVisible then
            Toggle:SetVisible(Visible)
        end
        return self
    end

    function Object:OnChanged(Func)
        if Toggle and Toggle.OnChanged then
            Toggle:OnChanged(Func)
        end
        return self
    end

    function Object:GET()
        return API[Name]
    end

    if Options.ColorPickers then
        for _, ColorPickerOptions in ipairs(Options.ColorPickers) do            
            Toggle:AddColorPicker(ColorPickerOptions.Idx or "ColorPicker", {
                Default = ColorPickerOptions.Default or Color3.new(1, 1, 1),
                Title = ColorPickerOptions.Title or "Color Picker",
                Transparency = ColorPickerOptions.Transparency,
                Resizable = ColorPickerOptions.Resizable or false,
                Callback = function(Value)
                    if ColorPickerOptions.OnColor then
                        ColorPickerOptions.OnColor(Value, API, Object)
                    end
                end,
                Changed = ColorPickerOptions.OnChanged or function() end
            })
        end
    end

    if Options.KeyPickers then
        for _, KeyPickerOptions in ipairs(Options.KeyPickers) do
            Toggle:AddKeyPicker(KeyPickerOptions.Idx or "KeyPicker", {
                Text = KeyPickerOptions.Text or "Keybind",
                Default = KeyPickerOptions.Default or Enum.KeyCode.None,
                DefaultModifiers = KeyPickerOptions.DefaultModifiers or {},
                Mode = KeyPickerOptions.Mode or "Toggle",
                SyncToggleState = KeyPickerOptions.SyncToggleState or false,
                WaitForCallback = KeyPickerOptions.WaitForCallback or false,
                Modes = KeyPickerOptions.Modes or { "Always", "Toggle", "Hold" },
                NoUI = KeyPickerOptions.NoUI or false,
                Blacklisted = KeyPickerOptions.Blacklisted or {},
                Whitelisted = KeyPickerOptions.Whitelisted or {},
                BlacklistedModifiers = KeyPickerOptions.BlacklistedModifiers or {},
                WhitelistedModifiers = KeyPickerOptions.WhitelistedModifiers or {},
                Callback = function(Value)
                    if KeyPickerOptions.OnKey then
                        KeyPickerOptions.OnKey(Value, API, Object)
                    end
                    if KeyPickerOptions.Callback then
                        KeyPickerOptions.Callback(Value)
                    end
                    if KeyPickerOptions.Mode == "Toggle" and Toggle then
                        local NewValue = not API[Name]
                        if Recrusive then return end
                        Recrusive = true
                        API[Name] = NewValue
                        if Toggle.SetValue then
                            Toggle:SetValue(NewValue)
                        end
                        if NewValue then
                            if Options.OnEnable then Options.OnEnable(API, Object) end
                        else
                            if Options.OnDisable then Options.OnDisable(API, Object) end
                        end
                        Recrusive = false
                    end
                end,
                ChangedCallback = KeyPickerOptions.ChangedCallback or KeyPickerOptions.OnChanged or function() end,
                Changed = KeyPickerOptions.OnChanged or KeyPickerOptions.Changed or function() end,
                Clicked = KeyPickerOptions.OnClick or KeyPickerOptions.Clicked or function() end,
            })
        end
    end

    local Engine = Options.Engine or "WhileLoop"

    local function Create_Callback(Self, DeltaTime, Cooldown)
        if Options.LoopCallback then
            Options.LoopCallback(API, Object, DeltaTime, Cooldown)
        end
    end

    if Engine == "HeavyLoop" then
        LoopData = self:HeavyLoop(
            Options.Interval or 0.15,
            Create_Callback,
            Name,
            Options.WaitBefore or false,
            function()
                if Options.OnDestroy then Options.OnDestroy(API, Object) end
                if Toggle and Toggle.Destroy then
                    Toggle:Destroy()
                end
            end
        )
    elseif Engine == "SmartLoop" then
        LoopData = self:SmartLoop(
            Options.Interval or 0.15,
            Create_Callback,
            Name,
            Options.WaitBefore or false,
            function()
                if Options.OnDestroy then Options.OnDestroy(API, Object) end
                if Toggle and Toggle.Destroy then
                    Toggle:Destroy()
                end
            end
        )
    elseif Engine == "WhileLoop" then
        LoopData = self:WhileLoop(
            Options.Interval or 0.15,
            Create_Callback,
            Name,
            Options.WaitBefore or false,
            function()
                if Options.OnDestroy then Options.OnDestroy(API, Object) end
                if Toggle and Toggle.Destroy then
                    Toggle:Destroy()
                end
            end
        )
    end
    
    if LoopData and LoopData.Unpause and LoopData.Paused then
        LoopData:Unpause()
    end
    
    if Options.Default then
        if Toggle and Toggle.SetValue then
            Toggle:SetValue(true)
        end
    else
        if Toggle and Toggle.SetValue then
            Toggle:SetValue(false)
        end
    end

    IsLoading = false

    Object.Toggle = Toggle
    Object.Loop = LoopData
    
    function Object:SetValue(Value)
        if Disabled then 
            return self 
        end
        if Recrusive then return self end

        Recrusive = true
        API[Name] = Value
        if Toggle and Toggle.SetValue then
            Toggle:SetValue(Value)
        end
        if Value then
            if Options.OnEnable then Options.OnEnable(API, Object) end
        else
            if Options.OnDisable then Options.OnDisable(API, Object) end
        end
        Recrusive = false
        return self
    end

    function Object:Lock()
        Disabled = true
        if Toggle and Toggle.SetDisabled then
            Toggle:SetDisabled(true)
        end
        if Options.OnLock then Options.OnLock(API, Object) end
        return self
    end

    function Object:Unlock()
        Disabled = false
        if Toggle and Toggle.SetDisabled then
            Toggle:SetDisabled(false)
        end
        if Options.OnUnlock then Options.OnUnlock(API, Object) end
        return self
    end

    function Object:IsLocked()
        return Disabled
    end

    function Object:SetInterval(Interval)
        if Disabled then return self end
        if LoopData and LoopData.SetWait then
            LoopData:SetWait(Interval)
        end
        if Options.OnIntervalChange then Options.OnIntervalChange(Interval) end
        return self
    end

    function Object:Pause()
        if Disabled then return self end
        if LoopData and LoopData.Pause then
            LoopData:Pause()
        end
        if Options.OnPause then Options.OnPause(API, Object) end
        return self
    end

    function Object:Unpause()
        if Disabled then return self end
        if LoopData and LoopData.Unpause then
            LoopData:Unpause()
        end
        if Options.OnUnpause then Options.OnUnpause(API, Object) end
        return self
    end

    function Object:Kill()
        if LoopData and LoopData.Kill then
            LoopData:Kill()
        end
        if Toggle and Toggle.Destroy then
            Toggle:Destroy()
        end
        return self
    end

    function Object:Destroy()
        self:Kill()
        return self
    end

    function Object:Reset()
        self:Unlock()
        self:SetEnabled(Options.Default)
        self:SetInterval(Options.Interval or 0.15)
        if LoopData and LoopData.Unpause then
            LoopData:Unpause()
        end
        return self
    end
    
    return Object
end

function API:OnUnload(Callback)
    self._UnloadedFM = Callback
end

function API:Unload()
    if self._UnloadingFM then return end

    self._UnloadingFM = true
    warn("[@Functions.luau]: Unloaded")

    if self._UnloadedFM then
        pcall(self._UnloadedFM)
    end

    -- // @Obsidian Unload
    local Obsidian = globalEnv.Library

    if Obsidian then
        pcall(Obsidian.Unload, Obsidian)
    end

    -- // @Unload Functions
    self:_Disconnect("@Engine.luau")

    self:Unload_LM()
    self:Unload_ESP()

    self:XRay(false)
    self:Flight(false, nil)
    self:BypassWS(false, nil)
    self:Strengthen(false, nil)
    self:TouchFling(false)
    self:BypassJP(false, nil)
    self:AntiCFrameTeleport(false)
    self:Set3DRendering(false)
    self:InfiniteJump(false)
    self:AntiCollider(false)
    self:AntiVoid2(false)
    self:AntiVoid1(false)
    self:SetQueue(false)

    self:StopClip()
    self:StopFling()
    self:StopFps()
    self:StopSeating()
    self:StopSpectate()
    self:StopBringTools()

    self:ClearHighlights()
    self:ClearBaseplates()
    self:ClearWebSockets()
    self:ClearGamepasses()
    self:ClearDrawingsV()
    self:ClearDrawings()
    self:ClearSounds()
    self:ClearRaknet()
    self:ClearSpoofs()

    self:_ExitFM()
    globalEnv._IsLoadedFM = nil

    task_wait(0.25)
    globalEnv._Clean(global.FunctionManager_Engine, nil)

    global.FunctionManager_Engine = nil
    Build_Engine, Window_Focused, Class = nil, nil, nil
    LocalPlayer, Character, Roots, Humanoid, CurrentCamera = nil, nil, nil, nil, nil

    globalEnv._Clean(API, nil); globalEnv._Clean(self, nil); globalEnv._Clean = nil
end

function API:Merge(...)
    for _, Modules in ipairs({...}) do
        for Method, Func in pairs(Modules) do
            if typeof(Func) == "function" then
                if self.Functionable and self.Functionable[Method] then
                    continue;
                end

                if self[Method] == nil then
                    self[Method] = function(_, ...)
                        return Func(self, ...)
                    end
                end
            end
        end
    end
    return self
end

function API.Launch(Class)
    Class = Class or {}
    Class.Functionable = {}

    -- // @Services
    local Services = {
        Workspace = Workspace,
        Players = Players,
        LocalPlayer = LocalPlayer,
        Character = Character,
        Roots = Roots,
        Humanoid = Humanoid,
        RunService = RunService,
        TweenService = TweenService,
        MarketplaceService = MarketplaceService,
        HttpService = HttpService,
        TeleportService = TeleportService,
        RbxAnalyticsService = RbxAnalyticsService,
        VirtualInputManager = VirtualInputManager,
        LocalizationService = LocalizationService,
        ReplicatedStorage = ReplicatedStorage,
        TextChatService = TextChatService,
        UserInputService = UserInputService,
        SoundService = SoundService,
        StarterGuiService = StarterGuiService,
        Performance = Performance,
        LightingService = LightingService,
        CurrentCamera = CurrentCamera,
        GuiService = GuiService,
        CoreGui = CoreGui
    }
    
    for Instance, Service in pairs(Services) do
        Class[Instance] = (Service)
    end
    
    global.FunctionManager_Engine = Class

    -- // @Metatable Support
    if type(setmetatable) == "function" then
        setmetatable(Class, { __index = API })
    else
        -- // Fallback for shitty environments without setmetatable
        for Instance, Service in pairs(API) do
            if type(Service) == "function" then
                Class[Instance] = function(_, ...) 
                    return Service(API, ...)
                end
            end
        end
    end

    return Class
end

local Functions = 0
for _, v in pairs(API) do
    if typeof(v) == "function" then Functions = Functions + 1 end
end

local EndTime = os_clock()
warn(string_format("[@Functions.luau] Loaded in %.3f ms, Build: %s, Functions: %d | By: %s", (EndTime - Runtime) * 1000, Project.Build, Functions, Project.Author))

return API
