-- // @FunctionManager.luau
local global = shared or (getgenv and getgenv()) or _G;
(global.FunctionManager_Engine or {Unload = function() end}):Unload();

local cloneref: (Instance) -> Instance = (cloneref or clonereference or function(instance: Instance)
    return instance
end)

-- // @Performance.vars
local Game = game -- // Boom 🤯💥

local type, typeof, pcall, tick, warn, print, next,  loadstring, setmetatable =
    type, typeof, pcall, tick, warn, print, next, loadstring, setmetatable

local math_floor, math_random, math_clamp, math_max, math_min, math_sqrt, math_huge =
    math.floor, math.random, math.clamp, math.max, math.min, math.sqrt, math.huge

local string_format, string_sub, string_match, string_gsub, string_gmatch, string_lower =
    string.format, string.sub, string.match, string.gsub, string.gmatch, string.lower

local table_insert, table_clear, table_sort, table_create, table_concat =
    table.insert, table.clear, table.sort, table.create, table.concat

local task_wait, task_spawn, task_cancel = task.wait, task.spawn, task.cancel
local os_clock, os_time, os_date = os.clock, os.time, os.date
local pairs, ipairs = pairs, ipairs

local Vector3_new, Vector2_new, Vector3_zero, Color3_fromRGB, Color3_fromHSV, CFrame_lookAt, CFrame_new, Instance_new =
    Vector3.new, Vector2.new, Vector3.zero, Color3.fromRGB, Color3.fromHSV, CFrame.lookAt, CFrame.new, Instance.new

local write_file, read_file, is_file, make_folder, is_folder, del_folder, del_file, list_files =
    writefile, readfile, isfile, makefolder, isfolder, delfolder, delfile, listfiles

local clonefunction: (Function) -> Function = (clonefunction or copyfunction or function(func: Function)
    return func
end)

if typeof(clonefunction) == "function" then
    local isfolder_dummy, isfile_dummy, listfiles_dummy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_dummy(tostring(math_random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        local globalEnv = getgenv and getgenv() or _G

        globalEnv.isfolder = function(Folder)
            local Success, Data = pcall(isfolder_dummy, Folder)
            return Success and Data or false
        end

        globalEnv.isfile = function(File)
            local Success, Data = pcall(isfile_dummy, File)
            return Success and Data or false
        end

        globalEnv.listfiles = function(Folder)
            local Success, Data = pcall(listfiles_dummy, Folder)
            return Success and Data or {}
        end

		is_folder, is_file, list_files = globalEnv.isfolder, globalEnv.isfile, globalEnv.listfiles
    end
end

-- // @API.module
local API = {} 
API.__index = API

local LoadTime = os.clock()

-- // @Variables
local Workspace, Cache = workspace, Game.GetService;
local Project = {Name = "Function Manager", Build = "@1.75", Author = "FlamesW",Language = "luau", File = "Module.luau"}
local Players: Players? = cloneref(Cache(Game, "Players"));
local LocalPlayer: Player? = Players.LocalPlayer;
local Character: Model? = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
if not Character then Character = LocalPlayer.CharacterAdded:Wait(); end
local Roots: BasePart? = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 0.1);
local Humanoid: Humanoid? = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 0.1);
local RunService: RunService? = Cache(Game, "RunService");
local TweenService: TweenService? = cloneref(Cache(Game, "TweenService"));
local MarketplaceService: MarketplaceService? = Cache(Game, "MarketplaceService");
local HttpService: HttpService? = cloneref(Cache(Game, "HttpService"));
local TeleportService: TeleportService? = Cache(Game, "TeleportService");
local RbxAnalyticsService: RbxAnalyticsService? = cloneref(Cache(Game, "RbxAnalyticsService"));
local VirtualInputManager: VirtualInputManager? = Instance_new("VirtualInputManager");
local RequestService = (http and http.request) or request or http_request or (syn and syn.request);
local GetConnections: GetConnections? = getconnections or get_signal_cons;
local UserInputService: UserInputService? = cloneref(Cache(Game, "UserInputService"));
local SoundService: SoundService? = cloneref(Cache(Game, "SoundService"));
local StarterGuiService: StarterGuiService? = cloneref(Cache(Game, "StarterGui"));
local CoreGui: CoreGui? = cloneref(Cache(Game, "CoreGui"));
local Performance: Performance? = Cache(Game, "Stats");
local LightingService: LightingService? = Cache(Game, "Lighting");
local CurrentCamera: Camera? = Workspace.CurrentCamera;
global.FunctionManager_Engine = API

-- // @Caches.vars
local Http_Get = HttpService.HttpGet;
local Http_JSONDecode = HttpService.JSONDecode;
local Game_HttpGet = Game.HttpGet;
local Get_Asset = getcustomasset or getsynasset;

local RenderStepped = RunService.RenderStepped;
local Heartbeat = RunService.Heartbeat;
local Stepped = RunService.Stepped;
local InputBegan = UserInputService.InputBegan;
local BindToRenderStep = RunService.BindToRenderStep;
local UnbindFromRenderStep = RunService.UnbindFromRenderStep;

local IsKeyDown = UserInputService.IsKeyDown;
local GetMouseLocation = UserInputService.GetMouseLocation;
local GetPlatform = UserInputService.GetPlatform;

local WorkspaceRaycast = Workspace.Raycast;
local RaycastParamsNew = RaycastParams.new;

local PlaceId, JobId, GameId  = Game.PlaceId, Game.JobId, Game.GameId;

local AssetTypes = {
    [1] = "Image", [2] = "TShirt", [3] = "Audio", [4] = "Mesh", [5] = "Lua",
    [8] = "Hat", [9] = "Place", [10] = "Model", [11] = "Shirt", [12] = "Pants",
    [13] = "Decal", [17] = "Head", [18] = "Face", [19] = "Gear", [21] = "Badge",
    [24] = "Animation", [27] = "Torso", [28] = "RightArm", [29] = "LeftArm",
    [30] = "LeftLeg", [31] = "RightLeg", [32] = "Package", [34] = "GamePass",
    [38] = "Plugin", [41] = "MeshPart", [42] = "Video", [43] = "Tool"
}

-- // @Signal.luau
function API:_Connect(Name: string, Connection: Signal)
    self._Signal = self._Signal or {} self._Signal[Name] = self._Signal[Name] or {} self._Signal[Name][#self._Signal[Name] + 1] = Connection return Connection;
end

function API:_Disconnect(Name: string): ()
    local Connections = self._Signal and self._Signal[Name] if Connections then for i = 1, #Connections do pcall(Connections[i].Disconnect, Connections[i]) end self._Signal[Name] = nil end;
end

-- // @Engine.luau
API:_Connect("@Engine.luau", LocalPlayer.CharacterAdded:Connect(function(Running)
    Character, Roots, Humanoid = Running, Running:WaitForChild("HumanoidRootPart"), Running:WaitForChild("Humanoid")
    CurrentCamera = Workspace.CurrentCamera
end))

local Internal = function(packet)
    if packet.PacketId == 0x1B then
        local data = packet.AsBuffer
        buffer.writeu32(data, 1, 0xFFFFFFFF)
        packet:SetData(data)
    end
end

-- // @Functions.module
function API:CreateInstance(ClassName: string, Properties: { [string]: any }?)
    local InstanceObj = Instance_new(ClassName)

    if Properties then
        local k, v = next(Properties)
        while k do
            InstanceObj[k] = v
            k, v = next(Properties, k)
        end
    end
    return InstanceObj
end

function API:PlaySound(Id, Options)
    Options = Options or {}
    self.Sounds = self.Sounds or {}

    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    
    if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end
    
    local Data = self.Sounds[SoundId]
    if not Data then
        local SoundInstance = self:CreateInstance("Sound", {
            Name = self:RandomString(15),
            SoundId = SoundId,
            Parent = SoundService
        })
        Data = {Instance = SoundInstance}
        self.Sounds[SoundId] = Data
    end
    
    if not Options.Stack then
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

    if Options.OnEnded then
        local Manager = "@Sound_" .. self:RandomString(15)
        local Connection = Data.Instance.Ended:Connect(function()
            Options.OnEnded(Data.Instance)
            self:_Disconnect(Manager)

            if Data then
                Data.Connection = nil
            end
        end)

        self:_Connect(Manager, Connection)
        Data.Connection = Manager
    end

    return Data.Instance
end

function API:IsSoundPlaying(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    if type(SoundId) == "number" then
        SoundId = "rbxassetid://" .. SoundId
    end
    
    local Data = self.Sounds[SoundId]
    return Data and Data.Instance and Data.Instance.Playing or false
end

function API:PauseSound(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    if type(SoundId) == "number" then
        SoundId = "rbxassetid://" .. SoundId
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
    if type(SoundId) == "number" then
        SoundId = "rbxassetid://" .. SoundId
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
        
        if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
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

    if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
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
        
        if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
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
        if type(Data) == "table" and Data.Instance then
            if Data.Connection then
                self:_Disconnect(Data.Connection)
            end

            pcall(function()
                Data.Instance:Stop()
                Data.Instance:Destroy()
            end)
        end
    end
    
    self.Sounds = nil
end

function API:LoadCustomAsset(Asset, Url)
    if not is_file(Asset) then
        local Success, Content = pcall(function()
            return Game_HttpGet(Url)
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

    local Cached = self.AssetCache[Id]
    if Cached then
        return Cached
    end
    
    local Success, Info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, Id)

    if not Success or not Info then
        return nil
    end
    
    local Result = {
        Id = Id,
        Name = Info.Name,
        Creator = Info.Creator and Info.Creator.Name,
        CreatorId = Info.Creator and Info.Creator.Id,
        TypeId = Info.AssetTypeId,
        TypeName = AssetTypes[Info.AssetTypeId] or "Unknown",
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

function API:GetDescendants(Instance, ClassName)
    local Descendants = Instance:GetDescendants()
    local Results = table_create(#Descendants)
    local Count = 0

    for i = 1, #Descendants do
        if Descendants[i].ClassName == ClassName then
            Count = Count + 1
            Results[Count] = Descendants[i]
        end
    end

    return Results, Count
end

function API:GetChildren(Instance, ClassName)
    local Children = Instance:GetChildren()
    local Results = table_create(#Children)
    local Count = 0
    
    for i = 1, #Children do
        if Children[i].ClassName == ClassName then
            Count = Count + 1
            Results[Count] = Children[i]
        end
    end
    
    return Results, Count
end

function API:GetDevice()
    return GetPlatform(UserInputService)
end

function API:ToPlace(Place)
    TeleportService:Teleport(Place)
end

function API:Time()
    return os_date("%H:%M:%S")
end

function API:Date()
    return os_date("%Y/%m/%d")
end

function API:GetPing()
    local Ping = Performance.Network.ServerStatsItem["Data Ping"]:GetValue()
    return tonumber(string.format("%.2f", Ping))
end

function API:GetFps()
    if not self.FpsCounter then
        local Frames = tick()
        self.CurrentFPS = 0

        self.FpsCounter = RenderStepped:Connect(function()
            local tick = tick()
            self.CurrentFPS = 1 / (tick - Frames)
            Frames = tick
        end)

        self:_Connect("@Fps", self.FpsCounter)
    end

    return self.CurrentFPS or 0
end

function API:StopFps()
    self:_Disconnect("@Fps")
    self.FpsCounter = nil
    self.CurrentFPS = 0
end

function API:Request(url)
    if RequestService then
        return RequestService({Url = url, Method = "GET"}).Body
    else
        return Http_Get(url, true)
    end
end

function API:LoadFile(Url)
    local Success, Result = pcall(function()
        return loadstring(Game_HttpGet(Url .. "?nocache=" .. tostring(os_clock())))()
    end)

    return Success and Result or nil
end

function API:GetWebSocket()
    return (pcall(function() return WebSocket end) and WebSocket) or nil
end

function API:ConnectSocket(Url)
    local WebSocketLib = self:GetWebSocket()
    
    if not WebSocketLib then
        return false, "WebSocket not available"
    end
    
    if self.Websocket and self.Websocket.Connected then
        return true, "Already connected"
    end
    
    local Success, Connection = pcall(function()
        return WebSocketLib.connect(Url)
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
        
        return true, "Connected"
    end

    return false, "Connection failed: " .. tostring(Success)
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
        return false, "Not connected"
    end
    
    local Success, Err = pcall(function()
        self.Websocket.Connection:Send(Message)
    end)
    
    if Success then
        return true, "Message sent"
    else
        return false, "Send failed: " .. tostring(Err)
    end
end

function API:DisconnectSocket()
    if not self.Websocket or not self.Websocket.Connection then
        return false, "Not connected"
    end

    local Success, Err = pcall(function()
        self.Websocket.Connection:Close()
        self.Websocket.Connected = false
        self.Websocket = nil
    end)
    
    if Success then
        return true, "Disconnected"
    else
        return false, "Disconnect failed: " .. tostring(Err)
    end
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

    self:_Disconnect("@WebSocket_Message")
    self:_Disconnect("@WebSocket_Close")
    self:_Disconnect("@WebSocket_Error")

    if self.Websocket.Connection then
        pcall(function()
            self.Websocket.Connection:Close()
        end)
    end

    self.Websocket = nil
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
    local t = table_create(Length)
    
    for i = 1, Length do
        local RandomIndex = math_random(1, #Characters)
        t[i] = string_sub(Characters, RandomIndex, RandomIndex)
    end
    
    return table_concat(t)
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
    
    print(string_format("[SpeedTest] %d iterations: %.2f ms total (avg: %.3f ms)", 
        Iterations, TotalMs, Result.Average))
    
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

function API:LogCommit(Repo, Branch, Version) -- // Github Only
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
        return self:Request(Github .. "?nocache=" .. os_clock())
    end)

    if not Success then warn("Failed to fetch commit logs~") return nil end

    local Commits = {}
    local StartPoint = 1

    while true do
        local Entry = Response:match("<entry>(.-)</entry>", StartPoint)
        if not Entry then break end

        local author = StripString(Entry:match("<name>(.-)</name>"))
        local message = StripString(Entry:match("<title>(.-)</title>"))
        local updated = Entry:match("<updated>(.-)</updated>")
        local fullSha = StripString(Entry:match("<id>.-[Cc]ommit/(.-)</id>"))
        local sha = fullSha and fullSha:sub(1, 7) or "Unknown"

        if updated and fullSha then
            local commitTime = DateTime.fromIsoDate(updated)
            local now = DateTime.now()
            local timeAgo = self:HowLong(now.UnixTimestamp - commitTime.UnixTimestamp)

            table_insert(Commits, {
                Author = author,
                Message = message,
                Sha = sha,
                FullSha = fullSha,
                TimeAgo = timeAgo,
                Timestamp = commitTime,
                RawDate = updated,
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

function API:IsMobile()
    local Plat = self:GetDevice()
    return Plat == Enum.Platform.IOS or Plat == Enum.Platform.Android
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
            return self:Request(RemoteUrl .. "?v=" .. os_time())
        end)
        if not Success then return warn("Failed: " .. RemoteUrl) end
        
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

function API:AbbreviateNumber(Number)
    local Abbrev = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "De" }

    for i = #Abbrev, 1, -1 do
        local Value = 10 ^ (i * 3)
        if Number >= Value then
            return string_format("%.1f%s", Number / Value, Abbrev[i])
        end
    end

    return tostring(Number)
end

function API:Chance(Percent)
    return math_random(1, 100) <= Percent
end

function API:ResolvePosition(...)
    local args = {...}
    local arg = args[1]
    
    if #args >= 3 and type(args[1]) == "number" and type(args[2]) == "number" and type(args[3]) == "number" then
        return Vector3_new(args[1], args[2], args[3])
    end
    
    if type(arg) == "number" then
        return nil
    end
    
    if arg == nil then
        return nil
    end
    
    if typeof(arg) == "Vector3" then
        return arg
    end
    
    if typeof(arg) == "CFrame" then
        return arg.Position
    end
    
    if typeof(arg) == "Instance" then
        if arg:IsA("BasePart") then
            return arg.Position
        end
        if arg:IsA("Model") then
            local root = arg.PrimaryPart or 
                        arg:FindFirstChild("HumanoidRootPart") or 
                        arg:FindFirstChildWhichIsA("BasePart")
            if root then return root.Position end
        end
        if arg:IsA("Player") and arg.Character then
            local root = arg.Character:FindFirstChild("HumanoidRootPart")
            if root then return root.Position end
        end
        if arg:IsA("Humanoid") and arg.Parent then
            local root = arg.Parent:FindFirstChild("HumanoidRootPart")
            if root then return root.Position end
        end
        if arg:IsA("Tool") and arg.Parent and arg.Parent:IsA("Model") then
            local root = arg.Parent:FindFirstChild("HumanoidRootPart")
            if root then return root.Position end
        end
        if arg.PrimaryPart then
            return arg.PrimaryPart.Position
        end
        local anyPart = arg:FindFirstChildWhichIsA("BasePart")
        if anyPart then
            return anyPart.Position
        end
    end
    
    if type(arg) == "table" then
        if arg.x and arg.y and arg.z then
            return Vector3_new(arg.x, arg.y, arg.z)
        end
        if arg.X and arg.Y and arg.Z then
            return Vector3_new(arg.X, arg.Y, arg.Z)
        end
        if #arg >= 3 then
            return Vector3_new(arg[1], arg[2], arg[3])
        end
        if arg.position and typeof(arg.position) == "Vector3" then
            return arg.position
        end
        if arg.Pos and typeof(arg.Pos) == "Vector3" then
            return arg.Pos
        end
        if arg.p and typeof(arg.p) == "Vector3" then
            return arg.p
        end
    end
    
    if type(arg) == "string" then
        local x,y,z = arg:match("(%d+)[, ]+(%d+)[, ]+(%d+)")
        if x and y and z then
            return Vector3_new(tonumber(x), tonumber(y), tonumber(z))
        end
        x,y,z = arg:match("(%d+)%s+(%d+)%s+(%d+)")
        if x and y and z then
            return Vector3_new(tonumber(x), tonumber(y), tonumber(z))
        end
        x,y,z = arg:match("(-?%d+)[, ]+(-?%d+)[, ]+(-?%d+)")
        if x and y and z then
            return Vector3_new(tonumber(x), tonumber(y), tonumber(z))
        end
        if arg:match("Vector3") then
            local nums = {}
            for num in arg:gmatch("(%d+%.?%d*)") do
                table.insert(nums, tonumber(num))
            end
            if #nums >= 3 then
                return Vector3_new(nums[1], nums[2], nums[3])
            end
        end
    end
    
    if typeof(arg) == "UDim2" then
        return Vector3_new(arg.X.Offset, arg.Y.Offset, 0)
    end
    
    if typeof(arg) == "UDim" then
        return Vector3_new(arg.Offset, 0, 0)
    end
    
    if typeof(arg) == "Region3" then
        return (arg.CFrame.Position + arg.Size / 2)
    end
    
    if typeof(arg) == "Ray" then
        return arg.Origin
    end
    
    if type(arg) == "userdata" and arg.Position and typeof(arg.Position) == "Vector3" then
        return arg.Position
    end
    
    if type(arg) == "userdata" and arg.CFrame and typeof(arg.CFrame) == "CFrame" then
        return arg.CFrame.Position
    end
    
    return nil
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
    local Plr = self:GetPlayer()
    if not Plr then return nil end
    
    return Plr:FindFirstChild("Backpack") or Plr:WaitForChild("Backpack")
end

function API:GetTeam()
    local Plr = self:GetPlayer()
    return Plr.Team
end

function API:IsAlive()
    local Hum = self:GetHumanoid()
    return Hum and Hum.Health > 0
end

function API:IsAFriend(Player)
    if not Player then return false end
    return Player:IsFriendsWith(self:GetPlayer().UserId)
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
    if not raknet then 
        return false 
    end

    if State then
        raknet.add_send_hook(Internal)
    else
        raknet.remove_send_hook(Internal)
    end
    return true
end

function API:ClearRaknet()
    if raknet then
        pcall(function() raknet.remove_send_hook(Internal) end)
    end
end

function API:SmartTimer(Name, Delay)
    self.Timers = self.Timers or {}

    local CT = tick()
    local Last = self.Timers[Name] or 0;

    if CT - Last >= Delay then
        self.Timers[Name] = CT;
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
    local Result = {}
    self.RecencyStores = self.RecencyStores or {}

    if typeof(Input) == "string" then
        return {Input}
    end

    if typeof(Input) == "table" then
        for k, v in pairs(Input) do
            if v == true then
                table_insert(Result, k);
            end
        end
    end

    if Mode == "Priority" then
        if not Key then
            return Result;
        end

        local Recency = self.RecencyStores[Key] or {}

        local Current = {}
        for _, Item in ipairs(Result) do
            Current[Item] = true
        end

        local NewRec = {}
        local __Seen = {}
        for _, Item in ipairs(Recency) do
            if Current[Item] and not __Seen[Item] then
                table_insert(NewRec, Item);
                __Seen[Item] = true;
            end
        end

        for _, Item in ipairs(Result) do
            if not __Seen[Item] then
                table_insert(NewRec, Item);
            end
        end

        self.RecencyStores[Key] = NewRec;

        local Prioritized = {}
        for i = #NewRec, 1, -1 do
            table_insert(Prioritized, NewRec[i]);
        end

        return Prioritized;

    elseif Mode == "Default" then
        return Result;

    elseif Mode == "Random" then
        local Shuffle = {}
        for _, v in ipairs(Result) do
            table_insert(Shuffle, v)
        end
        for i = #Shuffle, 2, -1 do
            local j = math_random(i)
            Shuffle[i], Shuffle[j] = Shuffle[j], Shuffle[i]
        end
        return Shuffle
    end

    return Result
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

function API:FindTool(Name)
    local Lower = string_lower(Name)
    for _, Tool in ipairs(self:GetTools()) do
        if string_lower(Tool.Name) == Lower then
            return Tool
        end
    end
    return nil
end

function API:EquipTool(Name)
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

function API:UseTool(Name)
    local Tool = self:FindTool(Name)
    if not Tool then
        return false
    end

    local HeldTool = self:GetHeldTool()

    if HeldTool ~= Tool then
        self:EquipTool(Name)
        task_wait(0.1)
    end

    HeldTool = self:GetHeldTool()

    if HeldTool == Tool then
        HeldTool:Activate()
        return true
    end

    return false
end

function API:UseHeldTool()
    local HeldTool = self:GetHeldTool()
    if not HeldTool then return false end

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

function API:AddPriority(Name, Priority, Condition, Action)
    self.Priorities = self.Priorities or {}

    table_insert(self.Priorities, {
        Name = Name,
        Priority = Priority,
        Condition = Condition,
        Action = Action,
        Flags = {}
    })
    
    table_sort(self.Priorities, function(a, b)
        return a.Priority > b.Priority
    end)
end

function API:GetTasks()
    for _, Task in ipairs(self.Priorities) do
        if Task.Condition() then
            return Task
        end
    end
    return nil
end

function API:Once(Name, Callback)
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
    local Task = self:GetTasks()
    if Task then
        self.TaskOnce = Task

        Task.Action()

        self.TaskOnce = nil
        return Task.name
    end
    return nil
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

function API:AntiAFK()
    if global.AFK_Service then return end

    if GetConnections then
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
    local Plr = self:GetPlayer()
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
    local Plr = self:GetPlayer()
    if Plr then
        Plr.CameraMinZoomDistance = Amount
        Plr.CameraMaxZoomDistance = Amount
    end
end

function API:ThirdPerson(Enabled)
    local Plr = self:GetPlayer()
    if Plr then
        Plr.CameraMode = Enabled and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
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

function API:SetTime(Amount)
    LightingService.ClockTime = Amount
end

function API:FlightConfig(Config)
    if not self.FlightData then
        self.FlightData = {Active = false}
    end
    
    self.FlightData.SpeedMin = Config.SpeedMin or self.FlightData.SpeedMin or 10
    self.FlightData.SpeedMax = Config.SpeedMax or self.FlightData.SpeedMax or 250
    self.FlightData.SpeedStep = Config.SpeedStep or self.FlightData.SpeedStep or 1.5
    
    if self.FlightData.Active then
        self.FlightData.Speed = math_clamp(self.FlightData.Speed, 
            self.FlightData.SpeedMin, 
            self.FlightData.SpeedMax)
    end
    
    return true
end

function API:Flight(State, Speed)
    State = State or false
    Speed = Speed or 50

    self.FlightData = self.FlightData or 
    {Active = false, Speed = Speed, BodyVelocity = nil, BodyGyro = nil, SpeedStep = 1.5, SpeedMin = 10, SpeedMax = 250}

    local function CleanUP()
        self.FlightData.Active = false
        
        if self.FlightData.BodyVelocity then
            self.FlightData.BodyVelocity:Destroy()
        end
        if self.FlightData.BodyGyro then
            self.FlightData.BodyGyro:Destroy()
        end

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
    self.FlightData.Speed = math_clamp(Speed, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
    
    local BV = self:CreateInstance("BodyVelocity", {
        Name = "00x00x00x00x00",
        MaxForce = Vector3_new(1e5, 1e5, 1e5),
        Velocity = Vector3_zero,
        Parent = Roots
    })
    self.FlightData.BodyVelocity = BV
    
    local BG = self:CreateInstance("BodyGyro", {
        Name = "11x11x11x11x11",
        MaxTorque = Vector3_new(1e5, 1e5, 1e5),
        P = 3000,
        D = 500,
        CFrame = Roots.CFrame,
        Parent = Roots
    })
    self.FlightData.BodyGyro = BG
    
    local Camera = CurrentCamera
    local ControlModule = self:IsMobile() and self:GetControlModule() or nil

    local Connection = RenderStepped:Connect(function()
        local Roots = self:GetRoot()
        if not self.FlightData.Active or not Roots or not Camera then 
            return 
        end
        
        if self.FlightData.BodyVelocity and self.FlightData.BodyVelocity.Parent ~= Roots then
            self.FlightData.BodyVelocity.Parent = Roots
        end
        if self.FlightData.BodyGyro and self.FlightData.BodyGyro.Parent ~= Roots then
            self.FlightData.BodyGyro.Parent = Roots
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

        if IsKeyDown(UserInputService, Enum.KeyCode.Equals) then
            self.FlightData.Speed = math_clamp(self.FlightData.Speed + self.FlightData.SpeedStep, 
                self.FlightData.SpeedMin, self.FlightData.SpeedMax)
        elseif IsKeyDown(UserInputService, Enum.KeyCode.Minus) then
            self.FlightData.Speed = math_clamp(self.FlightData.Speed - self.FlightData.SpeedStep, 
                self.FlightData.SpeedMin, self.FlightData.SpeedMax)
        end
        
        if self.FlightData.BodyVelocity then
            self.FlightData.BodyVelocity.Velocity = MoveDirection
        end
        
        if self.FlightData.BodyGyro then
            self.FlightData.BodyGyro.CFrame = Camera.CFrame
        end
    end)

    self:_Connect("@Flight", Connection)
    return true
end

function API:InfiniteJump(State)
    State = State or false

    self.JumpData = self.JumpData or {
        Active = false,
        Debounce = false,
    }
    
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
    
    self.FlingData = self.FlingData or {
        Active = false,
        Running = false,
    }
    
    local function CleanUP()
        self.FlingData.Active = false
        self.FlingData.Running = false
        
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
    self.FlingData.Running = true

    local movel = 0.1

    local Connection = Heartbeat:Connect(function()
        if not self.FlingData.Running then return end
        
        local Roots = self:GetRoot()
        if not Roots then return end
    
        local vel = Roots.Velocity
        Roots.Velocity = vel * 10000 + Vector3_new(0, 10000, 0)
        RenderStepped:Wait()
        Roots.Velocity = vel
        Stepped:Wait()
        Roots.Velocity = vel + Vector3_new(0, movel, 0)
        
        movel = -movel
    end)

    self:_Connect("@TouchFling", Connection)
    return true
end

function API:XRay(State)
    self.HistoryParts = self.HistoryParts or {}
    
    if State then
        if self.XRayActive then return end

        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and not p.Parent:FindFirstChildWhichIsA("Humanoid") and not p.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
                local Flag = false
    
                for _, v in ipairs(self:GetPlayers(true)) do
                    if v.Character and p:IsDescendantOf(v.Character) then
                        Flag = true
                        break
                    end
                end
                
                if not Flag then
                    self.HistoryParts[p] = p.LocalTransparencyModifier
                    p.LocalTransparencyModifier = 0.5
                end
            end
        end

        self.XRayActive = true
    else
        for p, modifier in pairs(self.HistoryParts) do
            if p and p.Parent then
                pcall(function() p.LocalTransparencyModifier = modifier end)
            end
        end

        self.HistoryParts = {}
        self.XRayActive = false
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
            self:CreateInstance("BodyVelocity", {
                Name = "0x0x0x0x0",
                Velocity = Vector3_zero,
                MaxForce = Vector3_new(40000, 40000, 40000),
                Parent = Hum
            })
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

    local Char = self:GetCharacter()
    if Char then
        local Hum = Char:FindFirstChild("HumanoidRootPart")
        if Hum then
            local AntiFling = Hum:FindFirstChild("0x0x0x0x0")
            if AntiFling then
                AntiFling:Destroy()
            end
        end
    end
end

function API:Noclip(Duration)
    Duration = Duration or 0.45

    self:_Disconnect("@Noclip")
    self:StopClip()

    self.Clip = false
    self.EndPoint = tick() + Duration
    
    if not self.Origins then
        self.Origins = {}
    end

    local function NoclipLoop()
        if tick() >= self.EndPoint then
            self:StopClip()
            return
        end
        
        if self.Clip == false and self:GetCharacter() ~= nil then
            for _, v in pairs(self:GetCharacter():GetDescendants()) do
                if v:IsA("BasePart") then
                    if self.Origins[v] == nil then
                        self.Origins[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end
    end

    self:_Connect("@Noclip", Stepped:Connect(NoclipLoop))
end

function API:StopClip()
    self:_Disconnect("@Noclip")
    
    self.Clip = true
    self.EndPoint = nil
    
    local Character = self:GetCharacter()
    if Character and self.Origins then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") and self.Origins[v] ~= nil then
                v.CanCollide = self.Origins[v]
            end
        end
    end
    
    self.Origins = {}
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
    return self:GetPlayer():GetMouse()
end

function API:SetMouseIcon(Icon)
    local Plr = self:GetPlayer()
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

function API:GetFriends()
    local LocalPlayer = self:GetPlayer()
    if not LocalPlayer then return {} end

    local UserId = LocalPlayer.UserId
    local Success, Response = pcall(function()
        return HttpGet("https://friends.roblox.com/v1/users/" .. UserId .. "/friends")
    end)
    
    if not Success then return {} end
    
    local Data = Http_JSONDecode(Response)
    if not Data or not Data.data then return {} end
    
    local Friends = {}
    
    for _, Friend in pairs(Data.data) do
        local Success, Response = pcall(function()
            return Http_Get("https://users.roblox.com/v1/users/" .. Friend.id)
        end)
        
        if Success then
            local UserData = HttpJSONDecode(Response)
            if UserData and UserData.name then
                table_insert(Friends, {
                    UserId = Friend.id,
                    Name = UserData.name,
                    DisplayName = UserData.displayName or UserData.name
                })
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
    if type(Direction) ~= "Vector3" then
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
    local CCamera = CurrentCamera
    if not CCamera then return nil end
    local Vector, OnScreen = CCamera:WorldToScreenPoint(self:ResolvePosition(Position))
    return {X = Vector.X, Y = Vector.Y, Z = Vector.Z, OnScreen = OnScreen}
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

function API:GetDistance(Target, UseSquared)
    local Roots = self:GetRoot()
    if not Roots or not Target then return math_huge end

    local Part
    local targetType = typeof(Target)
    
    if targetType == "Instance" then
        if Target:IsA("Model") then
            Part = Target.HumanoidRootPart or Target:FindFirstChildWhichIsA("BasePart")
        elseif Target:IsA("BasePart") then
            Part = Target
        end
    elseif targetType == "Vector3" then
        local rootPos = Roots.Position
        local dx = rootPos.X - Target.X
        local dy = rootPos.Y - Target.Y
        local dz = rootPos.Z - Target.Z
        return UseSquared and (dx*dx + dy*dy + dz*dz) or math_sqrt(dx*dx + dy*dy + dz*dz)
    end

    if not Part then return math_huge end
    
    local rootPos = Roots.Position
    local partPos = Part.Position
    local dx = rootPos.X - partPos.X
    local dy = rootPos.Y - partPos.Y
    local dz = rootPos.Z - partPos.Z
    
    if UseSquared then
        return dx*dx + dy*dy + dz*dz
    end
    
    return math_sqrt(dx*dx + dy*dy + dz*dz)
end

function API:IsNPC(Model)
    if not Model or not Model:IsA("Model") then return false end
    
    if Players:GetPlayerFromCharacter(Model) then return false end
    
    local Humanoid = Model:FindFirstChildOfClass("Humanoid")
    local RootPart = Model:FindFirstChild("HumanoidRootPart")
    
    return Humanoid ~= nil and RootPart ~= nil
end

function API:Alive(Character)
    Character = Character or self:GetCharacter()
    if not Character then return false end
    
    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    return Humanoid and Humanoid.Health > 0
end

function API:IsNPCAlive(Model)
    if not Model or not Model:IsA("Model") then
        return false
    end

    local Hum = Model:FindFirstChildOfClass("Humanoid")
    if not Hum then
        return false
    end

    return Hum.Health > 0
end

function API:GetClosestNPC(Radius)
    Radius = Radius or math_huge
    local Closest = nil
    local ClosestDistSquared = Radius * Radius

    local Models, _ = self:GetDescendants(Workspace, "Model")
    
    for i = 1, #Models do
        local model = Models[i]
        if self:IsNPC(model) then
            local DistanceSquared = self:GetDistance(model, true)
            if DistanceSquared < ClosestDistSquared then
                ClosestDistSquared = DistanceSquared
                Closest = model
            end
        end
    end
    
    if Closest then
        return self:GetNPC(Closest), math_sqrt(ClosestDistSquared)
    end
    return nil, ClosestDistSquared
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
    if type(Input) ~= "string" then return nil end

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
        local Closest, _ = self:GetClosestNPC()
        return Closest
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

    for _, Player in ipairs(Players) do
        local nameLower = string_lower(Player.Name)
        local displayLower = string_lower(Player.DisplayName)

        if nameLower == InputLower or displayLower == InputLower or nameLower:find(InputLower) or displayLower:find(InputLower) then
            return Player
        end
    end
    
    return nil
end

function API:GetNPC(Model)
    if not Model or not Model:IsA("Model") then
        return nil
    end

    local Hum = Model:FindFirstChildOfClass("Humanoid")
    local Roots = Model:FindFirstChild("HumanoidRootPart")

    if not Hum or not Roots then return nil end

    local Status = {
        Model = Model,
        Humanoid = Hum,
        Root = Roots,
        TeleportRules = nil,

        Attributes = Model:GetAttributes()
    }

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

    function Status:IsAlive()
        return self.Humanoid.Health > 0
    end

    function Status:GetHealth()
        return self.Humanoid.Health
    end

    function Status:GetMaxHealth()
        return self.Humanoid.MaxHealth
    end

    function Status:GetPosition()
        return self.Root.Position
    end

    function Status:GetPivot()
        return self.Model:GetPivot()
    end

    function Status:GetDistance()
        return API:GetDistance(self.Model)
    end

    function Status:IsMoving()
        return self.Humanoid.MoveDirection.Magnitude > 0
    end

    function Status:GetTool()
        for _, v in ipairs(self.Model:GetChildren()) do
            if v:IsA("Tool") then
                return v
            end
        end
        return nil
    end

    function Status:GetAnimation()
        local Anim = self.Humanoid:FindFirstChildOfClass("Animator")
        if not Anim then return {} end

        local Data = {}

        for _, track in ipairs(Anim:GetPlayingAnimationTracks()) do
            local AnimObj = track.Animation
            local AssetId = AnimObj and AnimObj.AnimationId and tonumber(AnimObj.AnimationId:match("%d+"))
            local AssetInfo = AssetId and self:GetAssetInfo(AssetId)

            Data[#Data + 1] = {
                Name = track.Name,
                Speed = track.Speed,
                TimePosition = track.TimePosition,
                AnimationId = AnimObj and AnimObj.AnimationId,
                
                AssetName = AssetInfo and AssetInfo.Name,
                Creator = AssetInfo and AssetInfo.Creator,
                Type = AssetInfo and AssetInfo.Type,
                Description = AssetInfo and AssetInfo.Description,
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
            for _, rule in ipairs(self.TeleportRules) do
                if rule.Condition(self) then
                    return rule.Action(self, Roots)
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
    self:_Disconnect("@Gamepasses_Product")
    self:_Disconnect("@Gamepasses_Gamepass")
    self:_Disconnect("@Gamepasses_Purchase")
    self:_Disconnect("@Gamepasses_Bulk")
    
    self.LogConnection = nil
    self.LoggedGamepasses = nil
end

function API:SelectEverything(Dropdown, List) -- // Obsidian Only
    if not getgenv().Library then
        return
    end

    local CurrentValues = Dropdown.Value or {}
    local AddedValues = {}
    local All = true;

    for _, Item in ipairs(List) do
        if not CurrentValues[Item] then
            All = false;
            break
        end
    end

    local State = not All
    for _, item in ipairs(List) do
        AddedValues[Item] = State;
    end
    
    Dropdown:SetValue(AddedValues);
    Library:Notify(State and "Selected" or "Unselected" .. " Everything!", 2);

    return State
end

function API:Rejoin()
    local Plr = self:GetPlayer()

    if #Players:GetPlayers() <= 1 then
        Plr:Kick("Rejoining...")
        task_wait(1);
        TeleportService:Teleport(PlaceId, Plr)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Plr)
    end
end

function API:ServerHop(MinPlayers, MaxPing)
    local Plr = self:GetPlayer()

    local Success, Result = pcall(function()
        return HttpJSONDecode(gameHttpGet("https://games.roblox.com/v1/games/" ..PlaceId .."/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if not Success or not Result then
        warn("[ServerHop]: Failed to fetch servers")
        return
    end

    for _, Server in next, Result.data do
        if Server.id and Server.playing < Server.maxPlayers and Server.playing > (MinPlayers or 0) and (not MaxPing or Server.ping <= MaxPing) then
            TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, Plr)
            return
        end
    end

    warn("[ServerHop]: No suitable server found, try Rejoin()")
end

function API:GetHWID(Method)
    Method = Method or "Roblox"
    
    if Method == "Executor" then
        local Success, HWID = pcall(function()
            if type(gethwid) == "function" then
                return gethwid()
            end
            return nil
        end)
        
        if Success and HWID then
            return HWID
        end
        return nil
    elseif Method == "Roblox" then
        return RbxAnalyticsService:GetClientId()
    elseif Method == "IP" then
        local Success, IP = pcall(function()
            return gameHttpGet("https://api.ipify.org")
        end)

        if Success and IP then
            return IP
        end
        return nil
    end
    
    return nil
end

function API:Kick(Reason)
    Reason = Reason or "Disconnected by API";
    self:GetPlayer():Kick(Reason);
end

function API:Verify(Options)
    Options = Options or {}
    
    local LPlayer = self:GetPlayer()
    local AllowedList = {}
    
    local RobloxId = self:GetHWID("Roblox")
    local ExecutorHwid = self:GetHWID("Executor")

    if not RobloxId and not ExecutorHwid then
        return false, nil, nil
    end

    if Options.Url then
        local Success, Content = pcall(function()
            return Game_HttpGet(Options.Url)
        end)
    
        if Success then
            local allMatches = {}
            
            local success, decoded = pcall(function()
                return Http_JSONDecode(Content)
            end)
            
            if success and type(decoded) == "table" then
                local function extractFromTable(t)
                    for k, v in pairs(t) do
                        if type(v) == "string" then
                            table_insert(allMatches, v)
                        elseif type(v) == "number" then
                            table_insert(allMatches, tostring(v))
                        elseif type(v) == "table" then
                            extractFromTable(v)
                        end
                        if type(k) == "string" then
                            table_insert(allMatches, k)
                        elseif type(k) == "number" then
                            table_insert(allMatches, tostring(k))
                        end
                    end
                end
                extractFromTable(decoded)
            end
            
            local function splitByAnyDelimiter(text)
                local results = {}
                local delimiters = {",", ";", "|", "\t", "\n", "\r", "  "}
                for _, delim in ipairs(delimiters) do
                    text = string_gsub(text, delim, " ")
                end
                for word in string_gmatch(text, "[^%s]+") do
                    table_insert(results, word)
                end
                return results
            end
            
            for line in string_gmatch(Content, "[^\r\n]+") do
                line = line:gsub("^%s+", ""):gsub("%s+$", "")
                if line ~= "" and not line:match("^%s*%-%-") and not line:match("^%s*#") and not line:match("^%s*//") then
                    local words = splitByAnyDelimiter(line)
                    for _, word in ipairs(words) do
                        table_insert(allMatches, word)
                    end
                end
            end
            
            for _, match in ipairs(allMatches) do
                match = match:gsub("^%s+", ""):gsub("%s+$", "")
                match = match:gsub('"', "")
                match = match:gsub("'", "")
                match = match:gsub("[{}%[%]()]", "")
                
                if match ~= "" then
                    table_insert(AllowedList, match)
                end
            end
        else
            warn("[Auth]: Failed to load:", Options.Url)
        end
    end
    
    for _, item in ipairs(Options.Hwids or {}) do
        if item and item ~= "" then
            table_insert(AllowedList, tostring(item))
        end
    end
    
    local function unique(t)
        local seen = {}
        local result = {}
        for _, v in ipairs(t) do
            if not seen[v] then
                seen[v] = true
                table_insert(result, v)
            end
        end
        return result
    end
    
    AllowedList = unique(AllowedList)
    
    local IsWhitelisted = false
    local Type, Value = nil, nil
    
    if RobloxId then
        for _, item in ipairs(AllowedList) do
            if tostring(RobloxId):lower() == tostring(item):lower() then
                IsWhitelisted = true
                Type = "Roblox HWID"
                Value = RobloxId
                break
            end
        end
    end
    
    if not IsWhitelisted and ExecutorHwid then
        for _, item in ipairs(AllowedList) do
            if tostring(ExecutorHwid):lower() == tostring(item):lower() then
                IsWhitelisted = true
                Type = "Executor HWID"
                Value = ExecutorHwid
                break
            end
        end
    end
    
    if not IsWhitelisted then
        for _, item in ipairs(AllowedList) do
            local itemStr = tostring(item):lower()
            if itemStr == tostring(LPlayer.UserId) or itemStr == LPlayer.Name:lower() then
                IsWhitelisted = true
                Type = "User"
                Value = item
                break
            end
        end
    end
    
    if IsWhitelisted then
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
    table_insert(self.CreatedBaseplates, {
        Baseplate = Baseplate,
        Connection = Connection,
        Usage = Usage
    })
    
    return Usage
end

function API:ClearBaseplates()
    self.CreatedBaseplates = self.CreatedBaseplates or {}

    for _, Data in ipairs(self.CreatedBaseplates) do
        pcall(function()
            if Data.Baseplate then
                Data.Baseplate:Destroy()
            end
            if Data.Connection then
                self:_Disconnect(Data.Connection)
            end
        end)
    end

    self.CreatedBaseplates = {}
end

-- // Developer Tool Scripts
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

-- // @Loop Manager.module, Build: 1.43
function API:CreateStacks()
    if type(self.Stacks) ~= "table" or type(self.Stacks.While) ~= "table" then
        self.Stacks = {
            While = {}, Heartbeat = {Connection = nil, Functions = {}, Active = true},
            RenderStep = {Connection = nil, Functions = {}, Active = true},
            Stepped = {Connection = nil, Functions = {}, Active = true},
        }
    end
end

local function AddService(self, Name, Signal)
    local Stack = self.Stacks[Name]
    if Stack.Connection then return end

    Stack.Connection = Signal:Connect(function(...)
        if self.UnloadedLM then return end

        local Funcs = Stack.Functions
        for Name, Data in pairs(Funcs) do
            if Data.Running and not Data.Paused then
                task_spawn(Data.Callback, self, ...)
            end
        end
    end)
end

function API:WhileLoop(WaitBoy, Callback, Name, WaitBefore)
    self:CreateStacks()

    local Wait = WaitBoy or 0
    local Name = Name or self:RandomString(15)
    local Local = self

    local Stack_Data = self.Stacks.While[Wait]
    if not Stack_Data then
        Stack_Data = {
            Functions = {},
            Running = true,
            Thread = nil,
            Wait = Wait
        }
        self.Stacks.While[Wait] = Stack_Data

        Stack_Data.Thread = task_spawn(function()
            while Stack_Data.Running do
                if Local.UnloadedLM then
                    task_wait()
                else
                    local dt = task_wait(Stack_Data.Wait)
                    for _, Data in pairs(Stack_Data.Functions) do
                        if Data.Running and not Data.Paused then
                            task_spawn(Data.Callback, Local, dt)
                        end
                    end
                end
            end
        end)
    end

    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,
        Name = Name,

        Pause = function(s) s.Paused = true end,
        Unpause = function(s) s.Paused = false end,

        SetWait = function(s, New)
            if Stack_Data then
                Stack_Data.Wait = New
            end
        end,

        Kill = function(s) 
            s.Running = false
            if Stack_Data.Functions then
                Stack_Data.Functions[Name] = nil
            end
            if Stack_Data.Functions and not next(Stack_Data.Functions) then
                Stack_Data.Running = false
                pcall(task_cancel, Stack_Data.Thread)
                if self.Stacks and self.Stacks.While then
                    self.Stacks.While[Wait] = nil
                end
            end
        end
    }

    if WaitBefore then
        task_spawn(function()
            task_wait(Wait)
            if Data.Running then
                Stack_Data.Functions[Name] = Data
            end
        end)
    else
        Stack_Data.Functions[Name] = Data
        if not self.UnloadedLM then
            task_spawn(Callback, Local)
        end
    end

    return Data
end

function API:SetWait(Name, New)
    if not self.Stacks or not self.Stacks.While then
        return false
    end
    
    for Wait, Stack in pairs(self.Stacks.While) do
        if Stack.Functions and Stack.Functions[Name] then
            Stack.Wait = New
            return true
        end
    end
    
    return false
end

function API:RenderStep(Callback, Name)
    self:CreateStacks()
    
    local Name = Name or self:RandomString(15)
    AddService(self, "RenderStep", RenderStepped)

    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,

        Pause = function(s) s.Paused = true end,
        Unpause = function(s) s.Paused = false end,

        Kill = function(s) 
            s.Running = false
            if self.Stacks.RenderStep.Functions then
                self.Stacks.RenderStep.Functions[Name] = nil
            end
        end
    }
    
    self.Stacks.RenderStep.Functions[Name] = Data
    return Data
end

function API:Heartbeat(Callback, Name)
    self:CreateStacks()
    
    local Name = Name or self:RandomString(15)
    AddService(self, "Heartbeat", Heartbeat)
    
    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,

        Pause = function(s) s.Paused = true end,
        Unpause = function(s) s.Paused = false end,

        Kill = function(s) 
            s.Running = false
            if self.Stacks.Heartbeat.Functions then
                self.Stacks.Heartbeat.Functions[Name] = nil
            end
        end
    }
    
    self.Stacks.Heartbeat.Functions[Name] = Data
    return Data
end

function API:Stepped(Callback, Name)
    self:CreateStacks()
    
    local Name = Name or self:RandomString(15)
    AddService(self, "Stepped", Stepped)
    
    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,

        Pause = function(s) s.Paused = true end,
        Unpause = function(s) s.Paused = false end,

        Kill = function(s) 
            s.Running = false
            if self.Stacks.Stepped.Functions then
                self.Stacks.Stepped.Functions[Name] = nil
            end
        end
    }
    
    self.Stacks.Stepped.Functions[Name] = Data
    return Data
end

function API:BindRender(Callback, Name, Priority)
    self:CreateStacks()
    
    local Name = Name or self:RandomString(15)
    
    local Data = {
        Type = "BindToRenderStep",
        Name = Name,
        Running = true,
        Paused = false,

        Pause = function(s) s.Paused = true end,
        Unpause = function(s) s.Paused = false end,

        Kill = function(s) 
            s.Running = false
            pcall(function() 
                UnbindFromRenderStep(s.Name or Name)
            end)
            if self.ActiveConnections then
                self.ActiveConnections[Name] = nil
            end
        end
    }

    local Func = function(dt)
        if self.UnloadedLM or not Data.Running or Data.Paused then 
            return 
        end
        Callback(self, dt)
    end

    BindToRenderStep(Name, Priority or Enum.RenderPriority.Last.Value, Func)
    Data.Func = Func
    
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = Data
    
    return Data
end

function API:BindKeybind(Key, Callback, BindName)
    self:CreateStacks()
    
    local Name = BindName or self:RandomString(15)

    local Data = {
        Type = "Keybind",
        Name = Name,
        Key = Key,
        Running = true,
        Paused = false,
        
        Pause = function(s) s.Paused = true end,
        Unpause = function(s) s.Paused = false end,
        
        Kill = function(s) 
            s.Running = false
            if s.Connection then
                s.Connection:Disconnect()
            end
            if self.ActiveConnections then
                self.ActiveConnections[Name] = nil
            end
        end
    }

    local Func = function(Input, Processed)
        if Processed or self.UnloadedLM or not Data.Running or Data.Paused then 
            return 
        end
        
        if Input.KeyCode == Key or Input.UserInputType == Key then
            Callback(self, Input)
        end
    end

    Data.Connection = InputBegan:Connect(Func)
    Data.Callback = Callback
    Data.InternalFunc = Func
    
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = Data
   
    return Data
end

function API:SetKeybind(Name, NewKey)
    local Entry = self.ActiveConnections and self.ActiveConnections[Name]
    if not Entry or Entry.Type ~= "Keybind" then
        return false, "Invalid keybind"
    end

    if Entry.Connection then
        Entry.Connection:Disconnect()
    end

    Entry.Key = NewKey

    local Func = function(Input, Processed)
        if Processed or self.UnloadedLM or not Entry.Running or Entry.Paused then 
            return 
        end
        if Input.KeyCode == NewKey or Input.UserInputType == NewKey then
            Entry.Callback(self, Input)
        end
    end

    Entry.Connection = InputBegan:Connect(Func)
    Entry.InternalFunc = Func

    return true
end

function API:ForceStop(Name)
    local Entry = self.ActiveConnections and self.ActiveConnections[Name]
    if Entry then
        Entry.Running = false
        
        if Entry.Type == "BindToRenderStep" then
            pcall(function() 
                UnbindFromRenderStep(Entry.Name or Name)
            end)
        elseif Entry.Connection then
            Entry.Connection:Disconnect()
        end
        
        self.ActiveConnections[Name] = nil
        return true
    end
    
    if self.Stacks then
        for Wait, Stack in pairs(self.Stacks.While) do
            if Stack.Functions and Stack.Functions[Name] then
                Stack.Functions[Name] = nil
                return true
            end
        end
        
        if self.Stacks.Heartbeat.Functions and self.Stacks.Heartbeat.Functions[Name] then
            self.Stacks.Heartbeat.Functions[Name] = nil
            return true
        end
        
        if self.Stacks.RenderStep.Functions and self.Stacks.RenderStep.Functions[Name] then
            self.Stacks.RenderStep.Functions[Name] = nil
            return true
        end
        
        if self.Stacks.Stepped.Functions and self.Stacks.Stepped.Functions[Name] then
            self.Stacks.Stepped.Functions[Name] = nil
            return true
        end
    end
    
    return false
end

function API:GetState(Name)
    local Entry = (self.ActiveConnections and self.ActiveConnections[Name]) or (self.ActiveTasks and self.ActiveTasks[Name])
    if Entry then
        if not Entry.Running then return false end
        if Entry.Paused then return "Paused" end
        return true
    end

    if self.Stacks then
        for Wait, Stack in pairs(self.Stacks.While) do
            local Data = Stack.Functions and Stack.Functions[Name]
            if Data then
                if not Data.Running then return false end
                if Data.Paused then return "Paused" end
                return true
            end
        end

        local Data = self.Stacks.Heartbeat.Functions and self.Stacks.Heartbeat.Functions[Name]
        if Data then
            if not Data.Running then return false end
            if Data.Paused then return "Paused" end
            return true
        end
        
        Data = self.Stacks.RenderStep.Functions and self.Stacks.RenderStep.Functions[Name]
        if Data then
            if not Data.Running then return false end
            if Data.Paused then return "Paused" end
            return true
        end
        
        Data = self.Stacks.Stepped.Functions and self.Stacks.Stepped.Functions[Name]
        if Data then
            if not Data.Running then return false end
            if Data.Paused then return "Paused" end
            return true
        end
    end
    
    return nil
end

function API:AddTask(Signal, Callback, Name)
    self.ActiveTasks = self.ActiveTasks or {}
    local Name = Name or self:RandomString(15)
    local Local = self

    if self.ActiveTasks[Name] then
        return self.ActiveTasks[Name]
    end

    local Data = {
        Signal = Signal, 
        Callback = Callback, 
        Connection = nil, 
        Running = true,
        Paused = false,
        Type = "Task"
    }

    Data.Pause = function(S) S.Paused = true end
    Data.Unpause = function(S) S.Paused = false end
    Data.Kill = function(S) Local:StopTask(Name) end

    local function wrapper()
        Data.Connection = Signal:Connect(function(...)
            if Data.Running and not Data.Paused and not Local.UnloadedLM then
                Callback(Local, ...)
            end
        end)
    end

    wrapper()
    Data.Reconnect = wrapper
    self.ActiveTasks[Name] = Data

    return Data
end

function API:StopTask(Name)
    local Data = self.ActiveTasks and self.ActiveTasks[Name]
    if Data then
        Data.Running = false
        if Data.Connection then
            Data.Connection:Disconnect()
            Data.Connection = nil
        end
        self.ActiveTasks[Name] = nil
    end
end

function API:RestartTask(Name)
    local Data = self.ActiveTasks and self.ActiveTasks[Name]
    if Data then
        if Data.Running then 
            Data.Connection:Disconnect() 
        end
        
        Data.Running = true
        Data.Paused = false
        Data.Reconnect()
    end
end

function API:UnloadLM()
    self.UnloadedLM = true

    if self.ActiveConnections then
        for Instance, _ in pairs(self.ActiveConnections) do
            self:ForceStop(Instance)
        end
    end

    if self.ActiveTasks then
        for Instance, _ in pairs(self.ActiveTasks) do
            self:StopTask(Instance)
        end
    end

    if self.Stacks then
        for _, Stack in pairs(self.Stacks.While) do
            if Stack.Functions then
                for Instance, _ in pairs(Stack.Functions) do
                    self:ForceStop(Instance)
                end
            end
        end
        
        if self.Stacks.Heartbeat and self.Stacks.Heartbeat.Functions then
            for Instance, _ in pairs(self.Stacks.Heartbeat.Functions) do
                self:ForceStop(Instance)
            end
        end
        
        if self.Stacks.RenderStep and self.Stacks.RenderStep.Functions then
            for Instance, _ in pairs(self.Stacks.RenderStep.Functions) do
                self:ForceStop(Instance)
            end
        end
        
        if self.Stacks.Stepped and self.Stacks.Stepped.Functions then
            for Instance, _ in pairs(self.Stacks.Stepped.Functions) do
                self:ForceStop(Instance)
            end
        end
    end
end

function API:ToggleLM(State)
    if typeof(State) == "boolean" then
        self.UnloadedLM = State
    end
end

function API:OverrideFunction(Name, Func)
    if typeof(self[Name]) ~= "function" then
        return false
    end

    self[self:RandomString(15)] = self[Name]
    self[Name] = Func

    return true
end

function API:Unload()
    -- // @Unload.module~
    self:_Disconnect("@Engine.luau")
    self:UnloadLM();

    self:XRay(false);
    self:Flight(false, nil);
    self:BypassWS(false, nil);
    self:TouchFling(false);
    self:BypassJP(false, nil);
    self:InfiniteJump(false);

    self:StopClip();
    self:StopFling();
    self:StopFps();

    self:ClearHighlights();
    self:ClearBaseplates();
    self:ClearWebSockets();
    self:ClearGamepasses();
    self:ClearSounds();
    self:ClearRaknet();

    global.FunctionManager_Engine = nil
    task_wait(0.1); -- // 6️⃣7️⃣🫴🤯🤯💥💥

    for Instance in pairs(API) do
        API[Instance] = nil -- // 💀
    end
    setmetatable(API, nil)
    warn("[Functions.luau]: Unloaded")
end

function API:Merge(...) -- // Merges with one another module 😉
    for _, Modules in ipairs({...}) do
        for Method, Func in pairs(Modules) do
            if typeof(Func) == "function" then
                if self.Core and self.Core[Method] then
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
    Class.Core = {}

    -- // @Services
    Class.Players = Players
    Class.LocalPlayer = LocalPlayer
    Class.Character = Character
    Class.RunService = RunService
    Class.TweenService = TweenService
    Class.MarketplaceService = MarketplaceService
    Class.HttpService = HttpService
    Class.TeleportService = TeleportService
    Class.RbxAnalyticsService = RbxAnalyticsService
    Class.VirtualInputManager = VirtualInputManager
    Class.UserInputService = UserInputService
    Class.SoundService = SoundService
    Class.StarterGuiService = StarterGuiService
    Class.LightingService = LightingService
    Class.RequestService = RequestService
    Class.GetConnections = GetConnections
    Class.CurrentCamera = CurrentCamera
    Class.CoreGui = CoreGui

	global.FunctionManager_Engine = Class
    return setmetatable(Class, {__index = API})
end

local Functions = 0
for _, v in pairs(API) do
    if type(v) == "function" then Functions = Functions + 1 end
end

local EndTime = os_clock()
warn(string_format("[Functions.luau] Loaded in %.3f ms, Build: %s, Functions: %d | By: %s", (EndTime - LoadTime) * 1000, Project.Build, Functions, Project.Author))

return API
