-- // @FunctionManager.luau
(getgenv().FunctionManager_Engine or {Disconnect = function() end}):Disconnect();

local cloneref = (cloneref or clonereference or function(instance: any)
    return instance;
end)

-- // @Performance.vars
local type, typeof, pcall, tick, warn, print, loadstring, setmetatable =
    type, typeof, pcall, tick, warn, print, loadstring, setmetatable

local math_floor, math_random, math_clamp, math_min, math_sqrt, math_huge =
    math.floor, math.random, math.clamp, math.min, math.sqrt, math.huge

local string_format, string_sub, string_match, string_gsub, string_gmatch, string_lower =
    string.format, string.sub, string.match, string.gsub, string.gmatch, string.lower

local table_insert, table_clear, table_sort, table_create, table_concat =
    table.insert, table.clear, table.sort, table.create, table.concat

local task_wait, task_spawn, task_cancel = task.wait, task.spawn, task.cancel
local os_clock, os_time, os_date = os.clock, os.time, os.date
local pairs, ipairs = pairs, ipairs

local Vector3_new, Vector2_new, Vector3_zero, Color3_fromRGB, Color3_fromHSV, CFrame_lookAt, CFrame_new, Instance_new =
    Vector3.new, Vector2.new, Vector3.zero, Color3.fromRGB, Color3.fromHSV, CFrame.lookAt, CFrame.new, Instance.new

-- // @API.module
local API = {}
API.__index = API

local LoadTime = os_clock()

-- // @Variables
local game = game
local workspace = workspace
local Project = {Name = "Function Manager", Build = "@1.53", Author = "♡ FlamesW", Language = "luau", File = "Module.luau"}
local Players: Players = cloneref(game:GetService("Players"));
local LocalPlayer: Player = Players.LocalPlayer;
local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local Roots = Character:WaitForChild("HumanoidRootPart");
local Humanoid = Character:WaitForChild("Humanoid");
local RunService: RunService = game:GetService("RunService");
local TweenService: TweenService = cloneref(game:GetService("TweenService"));
local MarketplaceService: MarketplaceService = game:GetService("MarketplaceService");
local HttpService: HttpService = cloneref(game:GetService("HttpService"));
local TeleportService: TeleportService = cloneref(game:GetService("TeleportService"));
local RbxAnalyticsService: RbxAnalyticsService = cloneref(game:GetService("RbxAnalyticsService"));
local VirtualInputManager: VirtualInputManager = Instance_new("VirtualInputManager");
local RequestService = (http and http.request) or request or http_request or (syn and syn.request)
local GetConnections: GetConnections = getconnections or get_signal_cons;
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"));
local SoundService: SoundService = cloneref(game:GetService("SoundService"));
local StarterGuiService: StarterGuiService = cloneref(game:GetService("StarterGui"));
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"));
local LightingService: LightingService = cloneref(game:GetService("Lighting"));
local CurrentCamera: CurrentCamera = workspace.CurrentCamera;

-- // @Caches
local HttpGet = HttpService.HttpGet;
local HttpJSONDecode = HttpService.JSONDecode;
local gameHttpGet = game.HttpGet;

local RenderStepped = RunService.RenderStepped;
local Heartbeat = RunService.Heartbeat;
local Stepped = RunService.Stepped;
local InputBegan = UserInputService.InputBegan;
local BindToRenderStep = RunService.BindToRenderStep;
local UnbindFromRenderStep = RunService.UnbindFromRenderStep;

local IsKeyDown = UserInputService.IsKeyDown;
local GetMouseLocation = UserInputService.GetMouseLocation;
local GetPlatform = UserInputService.GetPlatform;

local WorkspaceRaycast = workspace.Raycast;
local RaycastParamsNew = RaycastParams.new;

local GamePlaceId = game.PlaceId;
local GameJobId = game.JobId;

local AssetTypes = {
    [1] = "Image", [2] = "TShirt", [3] = "Audio", [4] = "Mesh", [5] = "Lua",
    [8] = "Hat", [9] = "Place", [10] = "Model", [11] = "Shirt", [12] = "Pants",
    [13] = "Decal", [17] = "Head", [18] = "Face", [19] = "Gear", [21] = "Badge",
    [24] = "Animation", [27] = "Torso", [28] = "RightArm", [29] = "LeftArm",
    [30] = "LeftLeg", [31] = "RightLeg", [32] = "Package", [34] = "GamePass",
    [38] = "Plugin", [41] = "MeshPart", [42] = "Video", [43] = "Tool"
}

getgenv().FunctionManager_Engine = LocalPlayer.CharacterAdded:Connect(function(Running)
    Character, Roots, Humanoid = Running, Running:WaitForChild("HumanoidRootPart"), Running:WaitForChild("Humanoid");
    CurrentCamera = workspace.CurrentCamera;
end)

local Internal = function(packet)
    if packet.PacketId == 0x1B then
        local data = packet.AsBuffer
        buffer.writeu32(data, 1, 0xFFFFFFFF)
        packet:SetData(data)
    end
end

function API:Flags()
    local Tables = {
        "AssetCache", "HighlightCache", "RecencyStores", 
        "HistoryParts", "Origins", "Timers", "Priorities", "ActiveConnections", 
        "CreatedBaseplates", "Sounds", "ActiveTasks", "LoggedGamepasses"
    }

    for _, Name in ipairs(Tables) do
        self[Name] = {}
    end

    self.Stacks = {
        While = {}, Heartbeat = {Connection = nil, Functions = {}, Active = true},
        RenderStep = {Connection = nil, Functions = {}, Active = true},
        Stepped = {Connection = nil, Functions = {}, Active = true},
    }

    -- @Booleans / States
    self.XRayActive = false
    self.FlingActive = false
    self.Clip = true
    self.Unloaded = false

    -- @Objects / Data
    self.FlightData = nil
    self.FlingLoop = nil
    self.Noclipping = nil
    self.EndPoint = nil
    self.TaskOnce = nil
    self.Websocket = nil
    self.LogConnection = nil

    self.ActiveTasks = self.ActiveTasks or {}
    self.ActiveConnections = self.ActiveConnections or {}
end

-- // @Functions.module
function API:CreateInstance(ClassName, Properties)
    local InstanceObj = Instance_new(ClassName)

    if Properties then
        for Property, Value in pairs(Properties) do
            InstanceObj[Property] = Value
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
            Data.Connection:Disconnect()
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
        Data.Connection = Data.Instance.Ended:Connect(function()
            Options.OnEnded(Data.Instance)
            Data.Connection = nil
        end)
    end

    return Data.Instance
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
    
    for _, Data in pairs(self.Sounds) do
        if type(Data) == "table" and Data.Instance then
            pcall(function()
                Data.Instance:Stop()
                Data.Instance:Destroy()
            end)
        end
    end
    
    self.Sounds = nil
end

function API:LoadCustomAsset(Asset, Url)
    if not isfile(Asset) then
        local Succ, Cont = pcall(function()
            return gameHttpGet(Url, true)
        end)

        if Succ then 
            writefile(Asset, Cont) 
        else 
            return Url 
        end
    end

    if getcustomasset then
        return getcustomasset(Asset)
    else
        return isfile(Asset) and "rbxasset://" .. Asset or Url
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

function API:Request(url)
    if RequestService then
        return RequestService({Url = url, Method = "GET"}).Body
    else
        return HttpGet(url, true)
    end
end

function API:LoadFile(Url)
    local Success, Result = pcall(function()
        return loadstring(gameHttpGet(Url .. "?nocache=" .. tostring(os_clock())))()
    end)

    return Success and Result or nil
end

function API:GetWebSocket()
    return (pcall(function() return WebSocket end) and WebSocket) or nil
end

function API:ConnectSocket(Url)
    local WebSocketLib = self:GetWebSocket()
    
    if not WebSocketLib then
        warn("WebSocket is not available on this executor")
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
        
        Connection.OnMessage:Connect(function(message)
            if self.Websocket and self.Websocket.Handlers then
                for _, handler in ipairs(self.Websocket.Handlers) do
                    pcall(handler, message)
                end
            end
        end)
        
        Connection.OnClose:Connect(function()
            if self.Websocket then
                self.Websocket.Connected = false
                if self.Websocket.OnDisconnect then
                    pcall(self.Websocket.OnDisconnect)
                end
            end
        end)
        
        if Connection.OnError then
            Connection.OnError:Connect(function(Err)
                if self.Websocket and self.Websocket.OnError then
                    pcall(self.Websocket.OnError, Err)
                end
            end)
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
                if not isfolder(path) then makefolder(path) end
            end
        end
        
        local Success, Remote = pcall(function()
            return API:Request(RemoteUrl .. "?v=" .. os_time())
        end)
        if not Success then return warn("Failed: " .. RemoteUrl) end
        
        local StoredContent = Remote
        local Truncated = false
        if #Remote > MaxSize then
            StoredContent = Remote:sub(1, MaxSize)
            Truncated = true
        end
        
        local Exists = isfile(FilePath)
        local Old = Exists and readfile(FilePath) or nil
        local Changed = Exists and Old ~= StoredContent
        
        writefile(FilePath, StoredContent)
        
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
    if typeof(arg) == "number" and args[2] and args[3] then
        return Vector3_new(arg, args[2], args[3])
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
            local root =
                arg.PrimaryPart or
                arg:FindFirstChild("HumanoidRootPart") or
                arg:FindFirstChildWhichIsA("BasePart")
            if root then
                return root.Position
            end
        end
    end
    if typeof(arg) == "table" and arg.x and arg.y and arg.z then
        return Vector3_new(arg.x, arg.y, arg.z)
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

function API:Raknet_Desync(State)
    if not raknet then 
        warn("[Raknet] Not supported on this executor")
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
    VirtualInputManager:SendKeyEvent(true, Key, false, game)
end

function API:Unpress(Key)
    VirtualInputManager:SendKeyEvent(false, Key, false, game)
end

function API:Click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task_wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

function API:AntiAFK()
    if getgenv().AFK_Service then return end

    if GetConnections then
        for _, Con in pairs(GetConnections(LocalPlayer.Idled)) do
            if Con.Disable then Con:Disable();
            elseif Con.Disconnect then
                Con:Disconnect();
            end
        end
    else
        LocalPlayer.Idled:Connect(function()
            self:Press(Enum.KeyCode.Thumbstick1)
            task_wait(0.05)
            self:Unpress(Enum.KeyCode.Thumbstick1)
        end)
    end

    getgenv().AFK_Service = true
end

function API:SetFOV(Num)
    CurrentCamera.FieldOfView = Num
end

function API:SetCameraType(Type)
    CurrentCamera.CameraType = Type
end

function API:SetGravity(Amount)
    workspace.Gravity = Amount
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

function API:SetTime(Amount)
    LightingService.ClockTime = Amount
end

function API:Flight(State, Speed)
    State = State or false
    Speed = Speed or 50

    self.FlightData = self.FlightData or 
    {Active = false, Speed = Speed, Connections = {}, BodyVelocity = nil, BodyGyro = nil, SpeedStep = 1.5, SpeedMin = 10, SpeedMax = 250}

    local function CleanUP()
        self.FlightData.Active = false
        
        if self.FlightData.BodyVelocity then
            self.FlightData.BodyVelocity:Destroy()
        end
        if self.FlightData.BodyGyro then
            self.FlightData.BodyGyro:Destroy()
        end
        
        for _, Connection in ipairs(self.FlightData.Connections) do
            pcall(function() Connection:Disconnect() end)
        end
        table_clear(self.FlightData.Connections)
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
    self.FlightData.Speed = Speed
    
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
        
        local moveDirection = Vector3_zero
        
        if IsKeyDown(UserInputService, Enum.KeyCode.W) then
            moveDirection += Camera.CFrame.LookVector
        end
        if IsKeyDown(UserInputService, Enum.KeyCode.S) then
            moveDirection -= Camera.CFrame.LookVector
        end
        if IsKeyDown(UserInputService, Enum.KeyCode.A) then
            moveDirection -= Camera.CFrame.RightVector
        end
        if IsKeyDown(UserInputService, Enum.KeyCode.D) then
            moveDirection += Camera.CFrame.RightVector
        end
        
        if IsKeyDown(UserInputService, Enum.KeyCode.Space) then
            moveDirection += Camera.CFrame.UpVector
        end
        if IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) then
            moveDirection -= Camera.CFrame.UpVector
        end

        if IsKeyDown(UserInputService, Enum.KeyCode.Equals) then
            self.FlightData.Speed = math_clamp(self.FlightData.Speed + self.FlightData.SpeedStep, 
                self.FlightData.SpeedMin, self.FlightData.SpeedMax)
        elseif IsKeyDown(UserInputService, Enum.KeyCode.Minus) then
            self.FlightData.Speed = math_clamp(self.FlightData.Speed - self.FlightData.SpeedStep, 
                self.FlightData.SpeedMin, self.FlightData.SpeedMax)
        end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * self.FlightData.Speed
        end
        
        if self.FlightData.BodyVelocity then
            self.FlightData.BodyVelocity.Velocity = moveDirection
        end
        
        if self.FlightData.BodyGyro then
            self.FlightData.BodyGyro.CFrame = Camera.CFrame
        end
    end)

    table_insert(self.FlightData.Connections, Connection)
    
    return true
end

function API:SetFlightSpeed(Speed)
    if not self.FlightData or not self.FlightData.Active then
        return false
    end

    Speed = math_clamp(Speed, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
    self.FlightData.Speed = Speed

    return true
end

function API:XRay(State)
    self.HistoryParts = self.HistoryParts or {}
    
    if State then
        if self.XRayActive then return end

        for _, p in ipairs(workspace:GetDescendants()) do
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
    self.FlingLoop = Heartbeat:Connect(function()
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
end

function API:StopFling()
    if not self.FlingActive then return end

    self.FlingActive = false
    
    if self.FlingLoop then
        self.FlingLoop:Disconnect()
        self.FlingLoop = nil
    end

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

function API:Noclip(Duration) -- // Noclip that must be used in loops at least faster than 0.45 seconds
    Duration = Duration or 0.45

    if self.Noclipping then
        self.Noclipping:Disconnect()
        self.Noclipping = nil
    end

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

    self.Noclipping = Stepped:Connect(NoclipLoop)
end

function API:StopClip()
    if self.Noclipping then
        self.Noclipping:Disconnect()
        self.Noclipping = nil
    end

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
    
    local Data = HttpJSONDecode(Response)
    if not Data or not Data.data then return {} end
    
    local Friends = {}
    
    for _, Friend in pairs(Data.data) do
        local Success, Response = pcall(function()
            return HttpGet("https://users.roblox.com/v1/users/" .. Friend.id)
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
    
    local Result = WorkspaceRaycast(workspace, Origins, Dir.Unit * (Distance or 1000), Params)

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

    Target.AncestryChanged:Connect(function()
        if not Target:IsDescendantOf(game) then
            self:RemoveHighlight(Target)
        end
    end)

    return Highlight
end

function API:RemoveHighlight(Target)
    self.HighlightCache = self.HighlightCache or {}

    local Highlight = self.HighlightCache[Target]
    if not Highlight then return false end

    if Highlight and Highlight.Destroy then
        Highlight:Destroy()
    end

    self.HighlightCache[Target] = nil
    return true
end

function API:ClearHighlights()
    self.HighlightCache = self.HighlightCache or {}

    for Target, Highlight in pairs(self.HighlightCache) do
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
    if not Model or not Model:IsA("Model") then
        return false
    end

    if Players:GetPlayerFromCharacter(Model) then
        return false
    end

    local Humanoid = Model:FindFirstChildOfClass("Humanoid")
    local RootPart = Model:FindFirstChild("HumanoidRootPart")

    return Humanoid ~= nil and RootPart ~= nil
end

function API:IsMobAlive(Model)
    if not Model or not Model:IsA("Model") then
        return false
    end

    local Hum = Model:FindFirstChildOfClass("Humanoid")
    if not Hum then
        return false
    end

    return Hum.Health > 0
end

function API:GetClosestPlayer(Radius)
    Radius = Radius or math_huge
    local Closest = nil
    local ClosestDistSquared = Radius * Radius

    for _, v in ipairs(self:GetPlayers(false)) do
        if v.Character then
            local DistanceSquared = self:GetDistance(v.Character, true)  -- Use squared distance
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

    function Status:NewTP()
        local Roots = API:GetRoot()
        if not Roots then return end

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

        self.Model:PivotTo(CFrame_new(self.Root.Position))
    end

    return Status
end

function API:FakeTP(Speed, ...)
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

    local Num = tonumber(Speed) or math_huge
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
        
        local function capture(Type, Asset)
            local Data = {
                Signal = Type,
                ID = Asset,
                Time = os_date("%H:%M:%S")
            }
            table_insert(self.LoggedGamepasses, Data)
            print("Successfully Logged [" .. Type .. "]: " .. tostring(Asset))
            return Data
        end
        
        self.LogConnection = {
            MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, id) capture("Product", id) end),
            MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, id) capture("Gamepass", id) end),
            MarketplaceService.PromptPurchaseFinished:Connect(function(_, id) capture("Purchase", id) end),
            MarketplaceService.PromptBulkPurchaseFinished:Connect(function(_, id) capture("Bulk", id) end)
        }
        
    elseif State == false then
        if self.LogConnection then
            for _, Connection in ipairs(self.LogConnection) do
                Connection:Disconnect()
            end
            self.LogConnection = nil
        end
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
    if not self.LogConnection then return end
    
    for _, Connection in ipairs(self.LogConnection) do
        pcall(function() Connection:Disconnect() end)
    end
    
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
        TeleportService:Teleport(GamePlaceId, Plr)
    else
        TeleportService:TeleportToPlaceInstance(GamePlaceId, GameJobId, Plr)
    end
end

function API:ServerHop(MinPlayers, MaxPing)
    local Plr = self:GetPlayer()

    local Success, Result = pcall(function()
        return HttpJSONDecode(gameHttpGet("https://games.roblox.com/v1/games/" ..GamePlaceId .."/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if not Success or not Result then
        warn("[ServerHop]: Failed to fetch servers")
        return
    end

    for _, Server in next, Result.data do
        if Server.id and Server.playing < Server.maxPlayers and Server.playing > (MinPlayers or 0) and (not MaxPing or Server.ping <= MaxPing) then
            TeleportService:TeleportToPlaceInstance(GamePlaceId, Server.id, Plr)
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
            return gameHttpGet(Options.Url)
        end)
    
        if Success then
            local allMatches = {}
            
            local success, decoded = pcall(function()
                return HttpJSONDecode(Content)
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
    local Parent = Options.Parent or workspace
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
    
    local API = {
        Baseplate = Baseplate,
        
        SetSize = function(_, NewSize)
            Baseplate.Size = NewSize
            return API
        end,
        
        SetColor = function(_, NewColor)
            Baseplate.Color = NewColor
            return API
        end,
        
        SetTransparency = function(_, NewTrans)
            Baseplate.Transparency = NewTrans
            return API
        end,
        
        SetFollow = function(_, Followed)
            if Connection then
                Connection:Disconnect()
                Connection = nil
            end
            
            if Followed then
                Connection = self:RenderStep(UpdatePosition, self:RandomString(15))
            end
            return API
        end,
        
        SetOffset = function(_, NewOffset)
            Offset = NewOffset
            UpdatePosition()
            return API
        end,

        GetOffset = function(_)
            return Offset
        end,
        
        Destroy = function(_)
            if Connection then
                Connection:Disconnect()
            end
            Baseplate:Destroy()
            return API
        end
    }

    self.CreatedBaseplates = self.CreatedBaseplates or {}
    table_insert(self.CreatedBaseplates, {
        Baseplate = Baseplate,
        Connection = Connection,
        API = API
    })
    
    return API
end

function API:ClearBaseplates()
    self.CreatedBaseplates = self.CreatedBaseplates or {}

    for _, Data in ipairs(self.CreatedBaseplates) do
        pcall(function()
            if Data.Baseplate then
                Data.Baseplate:Destroy()
            end
            if Data.Connection then
                Data.Connection:Disconnect()
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

-- // >Loop Manager, Build: @1.42 | by Mommy Flames
function API:CreateStacks()
    if type(self.Stacks) ~= "table" or type(self.Stacks.While) ~= "table" then
        self.Stacks = {
            While = {}, Heartbeat = {Connection = nil, Functions = {}, Active = true},
            RenderStep = {Connection = nil, Functions = {}, Active = true},
            Stepped = {Connection = nil, Functions = {}, Active = true},
        }
    end
end

local function AddService(self, Name, ServiceSignal)
    local Stack = self.Stacks[Name]
    if Stack.Connection then return end

    Stack.Connection = ServiceSignal:Connect(function(...)
        if self.Unloaded then 
            if Stack.Connection then
                Stack.Connection:Disconnect()
                Stack.Connection = nil
            end
            return 
        end

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
            Thread = nil
        }
        self.Stacks.While[Wait] = Stack_Data

        Stack_Data.Thread = task_spawn(function()
            while Stack_Data.Running and not Local.Unloaded do
                local dt = task_wait(Wait)

                for _, Data in pairs(Stack_Data.Functions) do
                    if Data.Running and not Data.Paused then
                        task_spawn(Data.Callback, Local, dt)
                    end
                end
            end
        end)
    end

    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,

        Pause = function(s) s.Paused = true end,
        Unpause = function(s) s.Paused = false end,
        
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
            if Data.Running and not Local.Unloaded then
                Stack_Data.Functions[Name] = Data
            end
        end)
    else
        Stack_Data.Functions[Name] = Data
        task_spawn(Callback, Local)
    end

    return Data
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
        if self.Unloaded or not Data.Running or Data.Paused then 
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
        if Processed or self.Unloaded or not Data.Running or Data.Paused then 
            return 
        end
        if Input.KeyCode == Key or Input.UserInputType == Key then
            Callback(Input)
        end
    end

    Data.Connection = InputBegan:Connect(Func)
    Data.Callback = Callback
    
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = Data
    
    return Data
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
            if Data.Running and not Data.Paused and not Local.Unloaded then
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

function API:Toggle(State)
    if typeof(State) == "boolean" then
        self.Unloaded = State
    end
end

function API:OverrideFunction(Name, Function)
    if typeof(self[Name]) ~= "function" then
        return false
    end

    self[self:RandomString(15)] = self[Name]
    self[Name] = Function

    return true
end

function API:Unload()
    -- // @Unload.module~
    (getgenv().FunctionManager_Engine or {Disconnect = function() end}):Disconnect();
    self.Unloaded = true

    if self.Stacks then
        for Wait, Stack in pairs(self.Stacks.While) do
            if Stack and Stack.Thread then
                task_cancel(Stack.Thread)
            end
            if Stack and Stack.Functions then
                Stack.Functions = nil
            end
        end
        self.Stacks.While = nil
        
        local function CleanStack(StackName)
            local Stack = self.Stacks[StackName]
            if Stack then
                if Stack.Connection then
                    Stack.Connection:Disconnect()
                    Stack.Connection = nil
                end
                Stack.Functions = nil
            end
        end
        
        CleanStack("Heartbeat")
        CleanStack("RenderStep")
        CleanStack("Stepped")
        
        self.Stacks = nil
    end

    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveTasks = self.ActiveTasks or {}

    for Instance, Entry in pairs(self.ActiveConnections) do
        if Entry and Entry.Type == "BindToRenderStep" then
            pcall(function() 
                UnbindFromRenderStep(Entry.Name or Instance)
            end)
        end
        self:ForceStop(Instance)
    end
    
    for Instance, _ in pairs(self.ActiveTasks) do
        self:StopTask(Instance)
    end

    self:XRay(false);
    self:Flight(false, nil);
    self:StopClip();
    self:StopFling();

    self:ClearHighlights();
    self:ClearBaseplates();
    self:ClearWebSockets();
    self:ClearGamepasses();

    self:ClearSounds();
    self:ClearRaknet();

    getgenv().FunctionManager_Engine = nil
    for Instance in pairs(API) do
        API[Instance] = nil -- // 💀
    end
    setmetatable(API, nil)
    warn("[Functions.luau]: Unloaded")
end

function API:Help()
    warn("=====[ FUNCTIONS ]=====")
    local List = {}

    for k, v in pairs(API) do
        if typeof(v) == "function" and k ~= "__index" and k ~= "wrap" and k ~= "Help" and k ~= "Req" and k ~= "OverrideFunction" and k ~= "Merge" and k ~= "Launch" and k ~= "SelectEverything" then
            table_insert(List, k)
        end
    end

    table_sort(List)
    for _, k in ipairs(List) do
        print("• " .. k)
    end

    warn("=======================")
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
    
    -- // Services
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

    API.Flags(Class)
    return setmetatable(Class, API)
end

local Functions = 0
for _, v in pairs(API) do
    if type(v) == "function" then Functions = Functions + 1 end
end

local EndTime = os_clock()
warn(string_format("[Functions.luau] Loaded in %.3f ms, Build: %s, Functions: %d | By: %s", (EndTime - LoadTime) * 1000, Project.Build, Functions, Project.Author))

return API
