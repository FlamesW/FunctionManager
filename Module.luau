-- // FunctionManager.luau
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

--> Prevents Runtime Duplicates, Use :Unload();
-- if FunctionManager_Engine then warn("Function Manager.luau is already running") return end

local API = {}
API.__index = API

local LoadTime = os.clock()

-- // Variables
local game = game
local workspace = workspace
local Project = {Name = "Function Manager", Build = "@1.30", Author = "♡ FlamesW", Language = "luau", File = "Module.luau"}
local Players: Players = cloneref(game:GetService("Players"));
local LocalPlayer: Player = Players.LocalPlayer;
local Character: Model = LocalPlayer.Character
local RunService: RunService = game:GetService("RunService");
local TweenService: TweenService = cloneref(game:GetService("TweenService"));
local MarketplaceService: MarketplaceService = game:GetService("MarketplaceService");
local HttpService: HttpService = cloneref(game:GetService("HttpService"));
local TeleportService: TeleportService = cloneref(game:GetService("TeleportService"));
local RbxAnalyticsService: RbxAnalyticsService = cloneref(game:GetService("RbxAnalyticsService"));
local VirtualInputManager: VirtualInputManager = Instance.new("VirtualInputManager");
local RequestService = http and http.request or request or http_request or syn and syn.request;
local GetConnections: GetConnections = getconnections or get_signal_cons;
local UserInputService: UsedInputService = cloneref(game:GetService("UserInputService"));
local SoundService: SoundService = cloneref(game:GetService("SoundService"));
local StarterGuiService: StarterGuiService = cloneref(game:GetService("StarterGui"));
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"));
local LightingService: LightingService = cloneref(game:GetService("Lighting"));

function API:Flags()
    self.AssetCache={}self.HighlightCache={}self.RecencyStores={}self.HistoryParts={}self.Origins={}self.Timers={}self.Stuffs={}self.ActiveConnections={}self.CreatedBaseplates = {}
    self.SoundRegistry={}self.ActiveTasks={}self.XRayActive=false;self.FlingActive=false;self.Clip=true;self.Unloaded=false;self.FlightData=nil;self.FlingLoop=nil;self.Noclipping=nil;self.EndPoint=nil
end

-- // Functions
function API:SafeCall(Func, ...)
    if not (Func and typeof(Func) == "function") then return end

    local Success, err = xpcall(Func, debug.traceback, ...)
    if not Success then
        task.defer(error, err)
        print("[Loop Manager] Error in callback:", err)
    end
    return Success
end

function API:CreateInstance(ClassName, Properties)
    local InstanceObj = Instance.new(ClassName)

    if Properties then
        for Property, Value in pairs(Properties) do
            pcall(function()
                InstanceObj[Property] = Value
            end)
        end
    end

    return InstanceObj
end

function API:Sound(Id, Options)
    Options = Options or {}
    self.SoundRegistry = self.SoundRegistry or {}

    local SoundId = Id
    if type(Id) == "number" or (type(Id) == "string" and Id:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(Id)
    end
    
    local SoundInstance = self.SoundRegistry[SoundId]
    if not SoundInstance then
        SoundInstance = self:CreateInstance("Sound", {
            SoundId = SoundId,
            Parent = SoundService
        })
        self.SoundRegistry[SoundId] = SoundInstance
    end
    
    if SoundInstance.Playing then
        SoundInstance:Stop()
    end
    
    SoundInstance.TimePosition = 0
    SoundInstance.Volume = Options.Volume or 1
    SoundInstance.Looped = Options.Looped or false
    SoundInstance:Play()
    
    return SoundInstance
end

function API:Preload(...)
    self.SoundRegistry = self.SoundRegistry or {}

    for _, Id in ipairs({...}) do
        local SoundId = Id
        if type(Id) == "number" or (type(Id) == "string" and Id:match("^%d+$")) then
            SoundId = "rbxassetid://" .. tostring(Id)
        end

        if not self.SoundRegistry[SoundId] then
            local SoundInstance = self:CreateInstance("Sound", {
                SoundId = SoundId,
                Volume = 0,
                Parent = SoundService
            })
            SoundInstance:Play()
            task.wait(0.05)
            SoundInstance:Stop()
            self.SoundRegistry[SoundId] = SoundInstance
        end
    end
end

function API:LoadCustomAsset(Asset, Url)
    if not isfile(Asset) then
        local Succ, Cont = pcall(function()
            return game:HttpGet(Url, true)
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

    local Success, Info = pcall(function()
        return MarketplaceService:GetProductInfo(Id)
    end)

    if not Success or not Info then
        return nil
    end

    local AssetTypes = {
        [1] = "Image",
        [2] = "TShirt",
        [3] = "Audio",
        [4] = "Mesh",
        [5] = "Lua",
        [8] = "Hat",
        [9] = "Place",
        [10] = "Model",
        [11] = "Shirt",
        [12] = "Pants",
        [13] = "Decal",
        [17] = "Head",
        [18] = "Face",
        [19] = "Gear",
        [21] = "Badge",
        [24] = "Animation",
        [27] = "Torso",
        [28] = "RightArm",
        [29] = "LeftArm",
        [30] = "LeftLeg",
        [31] = "RightLeg",
        [32] = "Package",
        [34] = "GamePass",
        [38] = "Plugin",
        [41] = "MeshPart",
        [42] = "Video",
        [43] = "Tool"
    }

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
    return UserInputService:GetPlatform()
end

function API:ToPlace(Place)
    TeleportService:Teleport(Place)
end

function API:Time()
    return os.date("%H:%M:%S")
end

function API:Date()
    return os.date("%Y/%m/%d")
end

function API:Request(url)
    if RequestService then
        return RequestService({Url = url, Method = "GET"}).Body
    else
        return HttpService:HttpGet(url, true)
    end
end

function API:LoadFile(Url)
    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(Url .. "?nocache=" .. tostring(os.clock())))()
    end)

    return Success and Result or nil
end

function API:StringToRGB(String)
    if not String then return nil end
    
    local R = tonumber(string.match(String, "(%d+)[%s]*,[%s]*%d+[%s]*,[%s]*%d+"))
    local G = tonumber(string.match(String, "%d+[%s]*,[%s]*(%d+)[%s]*,[%s]*%d+"))
    local B = tonumber(string.match(String, "%d+[%s]*,[%s]*%d+[%s]*,[%s]*(%d+)"))
    
    if R and G and B then
        return Color3.fromRGB(R, G, B)
    end
    
    return nil
end

function API:RGBToString(Rgb)
    return math.floor(Rgb.R * 255) .. ", " .. math.floor(Rgb.G * 255) .. ", " .. math.floor(Rgb.B * 255)
end

function API:HexToRGB(Hex)
    Hex = Hex:gsub("#", "")
    local R = tonumber(Hex:sub(1, 2), 16)
    local G = tonumber(Hex:sub(3, 4), 16)
    local B = tonumber(Hex:sub(5, 6), 16)
    return Color3.fromRGB(R, G, B)
end

function API:RGBToHex(Rgb)
    local R = math.floor(Rgb.R * 255)
    local G = math.floor(Rgb.G * 255)
    local B = math.floor(Rgb.B * 255)
    return string.format("#%02X%02X%02X", R, G, B)
end

function API:HSVToRGB(H, S, V)
    return Color3.fromHSV(H, S, V)
end

function API:RGBToHSV(Rgb)
    return Rgb.R, Rgb.G, Rgb.B
end

function API:Rainbowify(Speed)
    Speed = Speed or 1
    local Time = tick() * Speed
    return Color3.fromHSV(Time % 1, 1, 1)
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
    Length = Length or 10
    local Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local Result = ""
    
    for i = 1, Length do
        local RandomIndex = math.random(1, #Characters)
        Result = Result .. string.sub(Characters, RandomIndex, RandomIndex)
    end
    
    return Result
end

function API:SpeedTest(Func, Iterations, ...)
    Iterations = Iterations or 100
    local args = {...}
    
    local Start = os.clock()
    for i = 1, Iterations do
        pcall(function() Func(unpack(args)) end)
    end
    local TotalMs = (os.clock() - Start) * 1000
    
    local Result = {
        Total = TotalMs,
        Average = TotalMs / Iterations,
        Iterations = Iterations
    }
    
    print(string.format("[SpeedTest] %d iterations: %.2f ms total (avg: %.3f ms)", 
        Iterations, TotalMs, Result.Average))
    
    return Result
end

function API:HowLong(Ago)
    if Ago < 60 then
        return "Just now"
    elseif Ago >= 31536000 then
        local y = math.floor(Ago / 31536000)
        return y .. " year" .. (y == 1 and "" or "s") .. " ago"
    elseif Ago >= 2592000 then
        local m = math.floor(Ago / 2592000)
        return m .. " month" .. (m == 1 and "" or "s") .. " ago"
    elseif Ago >= 604800 then
        local w = math.floor(Ago / 604800)
        return w .. " week" .. (w == 1 and "" or "s") .. " ago"
    elseif Ago >= 86400 then
        local d = math.floor(Ago / 86400)
        return d .. " day" .. (d == 1 and "" or "s") .. " ago"
    elseif Ago >= 3600 then
        local h = math.floor(Ago / 3600)
        return h .. " hour" .. (h == 1 and "" or "s") .. " ago"
     else
        local min = math.floor(Ago / 60)
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
        warn("Invalid GitHub URL")
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
        return self:Request(Github .. "?nocache=" .. os.clock())
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

            table.insert(Commits, {
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
    task.spawn(function()
        Options = Options or {}
        local MaxSize = Options.MaxSize or math.huge
        
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
            return API:Request(RemoteUrl .. "?v=" .. os.time())
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

function API:Chance(Percent)
    return math.random(1, 100) <= Percent
end

function API:ResolvePosition(...)
    local args = {...}
    local arg = args[1]
    if typeof(arg) == "number" and args[2] and args[3] then
        return Vector3.new(arg, args[2], args[3])
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
        return Vector3.new(arg.x, arg.y, arg.z)
    end
    return nil
end

function API:GetPlayer()
    return LocalPlayer
end

function API:GetCharacter()
    return Character or LocalPlayer.CharacterAdded:Wait()
end

function API:GetRoot()
    local Char = self:GetCharacter()
    return Char and Char:WaitForChild("HumanoidRootPart", 5)
end

function API:GetHumanoid()
    local Char = self:GetCharacter()
    return Char and Char:FindFirstChildOfClass("Humanoid")
end

function API:GetHead()
    local Char = Character or LocalPlayer.CharacterAdded:Wait()
    return Char and (Char:FindFirstChild("Head") or Char:WaitForChild("Head", 5))
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
        task.wait(0.1)
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
                table.insert(Result, k);
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
                table.insert(NewRec, Item);
                __Seen[Item] = true;
            end
        end

        for _, Item in ipairs(Result) do
            if not __Seen[Item] then
                table.insert(NewRec, Item);
            end
        end

        self.RecencyStores[Key] = NewRec;

        local Prioritized = {}
        for i = #NewRec, 1, -1 do
            table.insert(Prioritized, NewRec[i]);
        end

        return Prioritized;

    elseif Mode == "Default" then
        return Result;

    elseif Mode == "Random" then
        local Shuffle = {}
        for _, v in ipairs(Result) do
            table.insert(Shuffle, v)
        end
        for i = #Shuffle, 2, -1 do
            local j = math.random(i)
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
            table.insert(Tools, tool)
        end
    end
    
    local Char = self:GetCharacter()
    if Char then
        for _, tool in ipairs(Char:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(Tools, tool)
            end
        end
    end
    
    return Tools
end

function API:GetToolCount()
    return #self:GetTools()
end

function API:FindTool(Name)
    for _, tool in ipairs(self:GetTools()) do
        if tool.Name:lower() == Name:lower() then
            return tool
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
        task.wait(0.1)
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
    table.insert(self.Stuffs, {
        name = Name,
        priority = Priority,
        condition = Condition,
        action = Action
    })
    
    table.sort(self.Stuffs, function(a, b)
        return a.priority > b.priority
    end)
end

function API:GetPriority()
    for _, task in ipairs(self.Stuffs) do
        if task.condition() then
            return task
        end
    end
    return nil
end

function API:RunPriorities()
    local Task = self:GetPriority()
    if Task then
        Task.action()
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
    task.wait(0.1)
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
            task.wait(0.05)
            self:Unpress(Enum.KeyCode.Thumbstick1)
        end)
    end

    getgenv().AFK_Service = true
end

function API:SetFOV(Num)
    workspace.CurrentCamera.FieldOfView = Num
end

function API:SetCameraType(Type)
    workspace.CurrentCamera.CameraType = Type
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
    {Active = false, Speed = Speed,Connections = {}, BodyVelocity = nil, BodyGyro = nil, SpeedStep = 1.5, SpeedMin = 10, SpeedMax = 250}

    local function CleanUP()
        self.FlightData.Active = false
        
        local Roots = self:GetRoot()
        if Roots then
            if self.FlightData.BodyVelocity then
                self.FlightData.BodyVelocity:Destroy()
            end
            if self.FlightData.BodyGyro then
                self.FlightData.BodyGyro:Destroy()
            end
        end
        
        for _, conn in ipairs(self.FlightData.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(self.FlightData.Connections)
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
        MaxForce = Vector3.new(1e5, 1e5, 1e5),
        Velocity = Vector3.zero,
        Parent = Roots
    })
    self.FlightData.BodyVelocity = BV
    
    local BG = self:CreateInstance("BodyGyro", {
        Name = "11x11x11x11x11",
        MaxTorque = Vector3.new(1e5, 1e5, 1e5),
        P = 3000,
        D = 500,
        CFrame = Roots.CFrame,
        Parent = Roots
    })
    self.FlightData.BodyGyro = BG
    
    local Camera = workspace.CurrentCamera
    
    local Connection = RunService.RenderStepped:Connect(function()
        if not self.FlightData.Active or not Roots or not Camera then 
            return 
        end
        
        local moveDirection = Vector3.zero
        
        if self:IsKeyPressed(Enum.KeyCode.W) then
            moveDirection += Camera.CFrame.LookVector
        end
        if self:IsKeyPressed(Enum.KeyCode.S) then
            moveDirection -= Camera.CFrame.LookVector
        end
        if self:IsKeyPressed(Enum.KeyCode.A) then
            moveDirection -= Camera.CFrame.RightVector
        end
        if self:IsKeyPressed(Enum.KeyCode.D) then
            moveDirection += Camera.CFrame.RightVector
        end
        
        if self:IsKeyPressed(Enum.KeyCode.Space) then
            moveDirection += Camera.CFrame.UpVector
        end
        if self:IsKeyPressed(Enum.KeyCode.LeftControl) then
            moveDirection -= Camera.CFrame.UpVector
        end
        
        if self:IsKeyPressed(Enum.KeyCode.Equals) then
            self.FlightData.Speed = math.clamp(self.FlightData.Speed + self.FlightData.SpeedStep, 
                self.FlightData.SpeedMin, self.FlightData.SpeedMax)
        elseif self:IsKeyPressed(Enum.KeyCode.Minus) then
            self.FlightData.Speed = math.clamp(self.FlightData.Speed - self.FlightData.SpeedStep, 
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

    table.insert(self.FlightData.Connections, Connection)

    local NewConnection = self:GetPlayer().CharacterAdded:Connect(function()
        task.wait(1)
        if self.FlightData.Active then
            if self.FlightData.BodyVelocity then
                self.FlightData.BodyVelocity:Destroy()
            end
            if self.FlightData.BodyGyro then
                self.FlightData.BodyGyro:Destroy()
            end
            
            local New = self:GetRoot()
            if New then
                self.FlightData.BodyVelocity = self:CreateInstance("BodyVelocity", {
                    Name = "00x00x00x00x00",
                    MaxForce = Vector3.new(1e5, 1e5, 1e5),
                    Velocity = Vector3.zero,
                    Parent = New
                })
                
                self.FlightData.BodyGyro = self:CreateInstance("BodyGyro", {
                    Name = "11x11x11x11x11",
                    MaxTorque = Vector3.new(1e5, 1e5, 1e5),
                    P = 3000,
                    D = 500,
                    CFrame = New.CFrame,
                    Parent = New
                })

                Roots = New
            end
        end
    end)

    table.insert(self.FlightData.Connections, NewConnection)
    return true
end

function API:SetFlightSpeed(Speed)
    if not self.FlightData or not self.FlightData.Active then
        return false
    end

    Speed = math.clamp(Speed, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
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
        if not self.XRayActive then return end

        for p, modifier in pairs(self.HistoryParts) do
            if p and p.Parent then
                p.LocalTransparencyModifier = modifier
            end
        end

        self.HistoryParts = {}
        self.XRayActive = false
    end
end

function API:AntiFling()
    if self.FlingActive then
        return
    end

    self.FlingActive = true
    self.FlingLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            local Char = self:GetCharacter()
            if not Char then return end
            
            local Hum = Char:FindFirstChild("HumanoidRootPart")
            if not Hum then return end
            
            if not Hum:FindFirstChild("0x0x0x0x0") then
                local AntiFling = self:CreateInstance("BodyVelocity", {
                    Name = "0x0x0x0x0",
                    Velocity = Vector3.new(0, 0, 0),
                    MaxForce = Vector3.new(40000, 40000, 40000),
                    Parent = Hum
                })
            end

            Hum.Velocity = Vector3.new(0, 0, 0)
            Hum.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            local AntiFling = Hum:FindFirstChild("0x0x0x0x0")
            if AntiFling then
                AntiFling.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end)
end

function API:StopFling()
    if not self.FlingActive then
        return
    end

    self.FlingActive = false
    
    if self.FlingLoop then
        pcall(function()
            self.FlingLoop:Disconnect()
        end)
        self.FlingLoop = nil
    end

    local Char = self:GetCharacter()
    if Char then
        local Hum = Char:FindFirstChild("HumanoidRootPart")
        if Hum then
            local AntiFling = Hum:FindFirstChild("0x0x0x0x0")
            if AntiFling then
                pcall(function()
                    AntiFling:Destroy()
                end)
            end
        end
    end
end

function API:Noclip(Duration) -- // Noclip that must be used in loops at least faster than 0.45 seconds
    Duration = Duration or 0.45

    if self.Noclipping then
        pcall(function()
            self.Noclipping:Disconnect()
        end)
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
            pcall(function()
                for _, v in pairs(self:GetCharacter():GetDescendants()) do
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

    self.Noclipping = RunService.Stepped:Connect(NoclipLoop)
end

function API:StopClip()
    if self.Noclipping then
        pcall(function()
            self.Noclipping:Disconnect()
        end)
        self.Noclipping = nil
    end
    
    self.Clip = true
    self.EndPoint = nil
    
    if self:GetCharacter() then
        pcall(function()
            for _, v in pairs(self:GetCharacter():GetDescendants()) do
                if v:IsA("BasePart") and self.Origins[v] ~= nil then
                    v.CanCollide = self.Origins[v]
                end
            end
        end)
    end
    
    self.Origins = {}
end

function API:IsStudio()
    return RunService:IsStudio()
end

function API:GetScreenSize()
    return workspace.CurrentCamera.ViewportSize
end

function API:GetMousePosition()
    return UserInputService:GetMouseLocation()
end

function API:SetMouseIcon(Icon)
    local Plr = self:GetPlayer()
    Plr.MouseIcon = Icon
end

function API:MouseVisibillity(State)
    UserInputService.MouseIconEnabled = not State
end

function API:IsKeyPressed(Key)
    return UserInputService:IsKeyDown(Key)
end

function API:IsShiftLocked()
    return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

function API:GetFriends()
    local LocalPlayer = self:GetPlayer()
    if not LocalPlayer then return {} end

    local UserId = LocalPlayer.UserId
    local Success, Response = pcall(function()
        return HttpService:HttpGet("https://friends.roblox.com/v1/users/" .. UserId .. "/friends")
    end)
    
    if not Success then return {} end
    
    local Data = HttpService:JSONDecode(Response)
    if not Data or not Data.data then return {} end
    
    local Friends = {}
    
    for _, Friend in pairs(Data.data) do
        local Success, Response = pcall(function()
            return HttpService:HttpGet("https://users.roblox.com/v1/users/" .. Friend.id)
        end)
        
        if Success then
            local UserData = HttpService:JSONDecode(Response)
            if UserData and UserData.name then
                table.insert(Friends, {
                    UserId = Friend.id,
                    Name = UserData.name,
                    DisplayName = UserData.displayName or UserData.name
                })
            end
        end
        task.wait(0.1);
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

    local RaycastParams = RaycastParams
    local EnumFilterType = Enum.RaycastFilterType
    
    local Params = RaycastParams.new()
    Params.FilterType = FilterType or EnumFilterType.Blacklist
    Params.FilterDescendantsInstances = IgnoreList or {}
    Params.IgnoreWater = IgnoreWater or false
    
    local Result = workspace:Raycast(Origins, Dir.Unit * (Distance or 1000), Params)

    if Callback and Result then
        Callback(Result)
    end

    return Result
end

function API:WorldToScreen(Position)
    local Vector, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(self:ResolvePosition(Position))
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

function API:IsVisible(Target, Character)
    return not self:IsBehindWall(Target, Character)
end

function API:IsTeamMate(Target)
    return self:GetTeam() == Target.Team
end

function API:GetEnemies()
    local Enemies = {}
    local MyTeam = self:GetTeam()
    
    for _, Player in ipairs(self:GetPlayers()) do
        if Player.Team ~= MyTeam then
            table.insert(Enemies, Player)
        end
    end
    
    return Enemies
end

function API:LookAt(Target, Part)
    local T = self:ResolvePosition(Target)
    local P = Part or self:GetRoot()
    
    if P and T then
        P.CFrame = CFrame.lookAt(P.Position, T)
    end
end

-- // @Aimbot.luau
function API:Aimbot(Options)
    Options = Options or {}

    local LocalPlayer = game.Players.LocalPlayer
    
    local Settings = {
        Enabled = false,
        FOVRadius = Options.FOVRadius or 200,
        StickyRadius = Options.StickyRadius or 300,
        RenderDistance = Options.RenderDistance or 1000,
        Smoothness = Options.Smoothness or 0.3,
        CheckTeam = Options.CheckTeam ~= false,
        RequireVisible = Options.RequireVisible or true,
        TargetPart = Options.TargetPart or "Head",
        AimMethod = Options.AimMethod or "Camera",

        Flags = {
            PreferLowHealth = false,
            PreferDistance = false,
            StickyAim = false,
        },
        
        OnTargetLocked = Options.OnTargetLocked,
        OnTargetLost = Options.OnTargetLost,
        OnWallDetected = Options.OnWallDetected,
        OnAim = Options.OnAim,
    }

    local function GetLocalCharacter()
        return LocalPlayer.Character
    end
    
    local function IsAliveAndWell()
        local char = GetLocalCharacter()
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0
    end
    
    Settings.ValidateTarget = Options.ValidateTarget or function(player, targetChar)
        if not targetChar or not targetChar.Parent then return false end
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return false end
        if Settings.CheckTeam then
            local myTeam = LocalPlayer.Team
            local theirTeam = player.Team
            if myTeam and theirTeam and myTeam == theirTeam then return false end
        end
        return true
    end

    Settings.CheckVisibility = Options.CheckVisibility or function(targetChar)
        if not Settings.RequireVisible then return true end
        if not targetChar or not targetChar.Parent then return false end
        return not self:IsBehindWall(targetChar)
    end
    
    Settings.ScoreTarget = Options.ScoreTarget or function(target, targetChar, mousePos, camera)
        local targetPart = targetChar:FindFirstChild(Settings.TargetPart) or targetChar:FindFirstChild("Head")
        if not targetPart then return math.huge end
        
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then return math.huge end
        
        local dx = screenPos.X - mousePos.X
        local dy = screenPos.Y - mousePos.Y
        local distanceToMouse = dx * dx + dy * dy
        local dist = self:GetDistance(targetChar)
        
        local score = distanceToMouse + (dist / 50)
        
        if Settings.Flags.PreferLowHealth then
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
                score = score + ((humanoid.Health / humanoid.MaxHealth) * 100)
            end
        end
        
        if Settings.Flags.PreferDistance then
            score = score + (dist / 10)
        end
        
        return score
    end

    Settings.FilterTarget = Options.FilterTarget or function(player, targetChar)
        if not targetChar or not targetChar.Parent then return false end
        if self:GetDistance(targetChar) > Settings.RenderDistance then return false end
        if not Settings.CheckVisibility(targetChar) then return false end
        return true
    end
    
    Settings.GetAimPosition = Options.GetAimPosition or function(targetChar)
        if not targetChar or not targetChar.Parent then return nil end
        return targetChar:FindFirstChild(Settings.TargetPart) or targetChar:FindFirstChild("Head")
    end

    Settings.ExecuteAim = Options.ExecuteAim or function(targetPos, camera)
        local method = Settings.AimMethod
        
        if method == "Camera" then
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
            camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Smoothness)
        elseif method == "CFrame" then
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
        elseif method == "Mouse" then
            local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local mousemoverel = mousemoverel or (syn and syn.mousemoverel) or (input and input.mouse_move)
                if mousemoverel then
                    local currentPos = self:GetMousePosition()
                    mousemoverel((screenPos.X - currentPos.X) * Settings.Smoothness, (screenPos.Y - currentPos.Y) * Settings.Smoothness)
                end
            end
        elseif method == "Slient" then
            -- // Coming Soon~
        end
    end

    local CurrentTarget = nil
    local AimbotConnection = nil
    local CacheValidTargets = {}
    
    local function GetValidTargets()
        table.clear(CacheValidTargets)
        
        if not IsAliveAndWell() then return CacheValidTargets end

        local players = self:GetPlayers(false)

        for i = 1, #players do
            local player = players[i]
            local targetChar = player.Character
            if targetChar and targetChar.Parent then
                if Settings.FilterTarget(player, targetChar) and Settings.ValidateTarget(player, targetChar) then
                    table.insert(CacheValidTargets, player)
                end
            end
        end
        
        return CacheValidTargets
    end

    local function GetCursorDistanceToTarget(targetChar, camera, mousePos)
        if not targetChar or not targetChar.Parent then return nil end
        
        local aimPart = Settings.GetAimPosition(targetChar)
        if not aimPart then return nil end
        
        local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then return nil end
        
        local dx = screenPos.X - mousePos.X
        local dy = screenPos.Y - mousePos.Y
        return math.sqrt(dx * dx + dy * dy)
    end
    
    local function AimbotLoop()
        if not Settings.Enabled then return end
        
        if not IsAliveAndWell() then
            if CurrentTarget then
                CurrentTarget = nil
                if Settings.OnTargetLost then Settings.OnTargetLost() end
            end
            return
        end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local mousePos = self:GetMousePosition()
        
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character.Parent then
            local targetChar = CurrentTarget.Character
            
            if Settings.FilterTarget(CurrentTarget, targetChar) and Settings.ValidateTarget(CurrentTarget, targetChar) then
                local cursorDist = GetCursorDistanceToTarget(targetChar, camera, mousePos)

                if cursorDist then
                    if Settings.Flags.StickyAim and cursorDist > Settings.StickyRadius then
                        CurrentTarget = nil
                        if Settings.OnTargetLost then Settings.OnTargetLost() end
                    else
                        local aimPart = Settings.GetAimPosition(targetChar)
                        if aimPart then
                            if Settings.OnAim then
                                local result = Settings.OnAim(aimPart.Position, camera, CurrentTarget)
                                Settings.ExecuteAim(result or aimPart.Position, camera)
                            else
                                Settings.ExecuteAim(aimPart.Position, camera)
                            end
                        end
                        return
                    end
                else
                    CurrentTarget = nil
                    if Settings.OnTargetLost then Settings.OnTargetLost() end
                end
            else
                CurrentTarget = nil
                if Settings.OnTargetLost then Settings.OnTargetLost() end
            end
        end
        
        local validTargets = GetValidTargets()
        if #validTargets > 0 then
            local bestTarget = nil
            local bestScore = math.huge
            
            for i = 1, #validTargets do
                local target = validTargets[i]
                local targetChar = target.Character
                if targetChar then
                    local score = Settings.ScoreTarget(target, targetChar, mousePos, camera)
                    if score < bestScore then
                        bestScore = score
                        bestTarget = target
                    end
                end
            end
            
            if bestTarget then
                CurrentTarget = bestTarget
                if Settings.OnTargetLocked then Settings.OnTargetLocked(CurrentTarget) end
                
                local aimPart = Settings.GetAimPosition(CurrentTarget.Character)
                if aimPart then
                    Settings.ExecuteAim(aimPart.Position, camera)
                end
            end
        end
    end
    
    local AimbotAPI = {
        SetEnabled = function(enabled)
            Settings.Enabled = enabled
            if not enabled and CurrentTarget then
                CurrentTarget = nil
                if Settings.OnTargetLost then Settings.OnTargetLost() end
            end
            return AimbotAPI
        end,
        
        IsEnabled = function() return Settings.Enabled end,
        GetTarget = function() return CurrentTarget end,
        
        UpdateSettings = function(NewSettings)
            for k, v in pairs(NewSettings) do
                if Settings[k] ~= nil then
                    Settings[k] = v
                end
            end
            return AimbotAPI
        end,
        
        OverrideFunction = function(Func, New)
            if Settings[Func] ~= nil then
                Settings[Func] = New
            end
            return AimbotAPI
        end,
        
        SetFlag = function(Flag, value)
            if Settings.Flags[Flag] ~= nil then
                Settings.Flags[Flag] = value
            end
            return AimbotAPI
        end,
        
        GetFlag = function(Flag)
            return Settings.Flags[Flag]
        end,
        
        SetStickyRadius = function(Radius)
            Settings.StickyRadius = Radius
            return AimbotAPI
        end,
        
        ForceTarget = function(player)
            if player and player.Character and player.Character.Parent then
                CurrentTarget = player
                if Settings.OnTargetLocked then Settings.OnTargetLocked(CurrentTarget) end
            end
            return AimbotAPI
        end,
        
        ClearTarget = function()
            CurrentTarget = nil
            if Settings.OnTargetLost then Settings.OnTargetLost() end
            return AimbotAPI
        end,
        
        SetAimMethod = function(method)
            local validMethods = {Camera = true, Mouse = true, CFrame = true, MouseAbs = true, Silent = true}
            if validMethods[method] then
                Settings.AimMethod = method
            end
            return AimbotAPI
        end,
        
        SetRenderDistance = function(distance)
            Settings.RenderDistance = distance
            return AimbotAPI
        end,
        
        SetSmoothness = function(smoothness)
            Settings.Smoothness = smoothness
            return AimbotAPI
        end,
        
        SetFOV = function(fov)
            Settings.FOVRadius = fov
            return AimbotAPI
        end,
        
        Start = function()
            if AimbotConnection then return AimbotAPI end
            Settings.Enabled = true
            AimbotConnection = self:RenderStep(AimbotLoop, "Aimbot.Luau")
            return AimbotAPI
        end,
        
        Stop = function()
            Settings.Enabled = false
            if AimbotConnection then
                self:ForceStop("Aimbot.Luau")
                AimbotConnection = nil
            end
            CurrentTarget = nil
            return AimbotAPI
        end,
        
        GetSettings = function() return Settings end
    }

    if Options.AutoStart then
        AimbotAPI:Start()
    end
    
    return AimbotAPI
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
        FillColor = Options.FillColor or Color3.fromRGB(255, 0, 0),
        OutlineColor = Options.OutlineColor or Color3.fromRGB(255, 255, 255),
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

    table.clear(self.HighlightCache)
end

function API:GetPlayers(SelfIncluded)
    local List = {}

    for _, Plr in pairs(Players:GetPlayers()) do
        if SelfIncluded then
            table.insert(List, Plr)
        else
            if Plr ~= Players.LocalPlayer then
                table.insert(List, Plr)
            end
        end
    end

    return List
end

function API:GetDistance(Target)
    local Roots = self:GetRoot()
    if not Roots or not Target then return math.huge end

    local Part
    if typeof(Target) == "Instance" then
        if Target:IsA("Model") then
            Part = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChildWhichIsA("BasePart")
        elseif Target:IsA("BasePart") then
            Part = Target
        end
    end

    if not Part then return math.huge end
    return (Roots.Position - Part.Position).Magnitude
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
    Radius = Radius or math.huge
    local Closest = nil
    local ClosestDist = Radius

    for _, v in ipairs(self:GetPlayers(false)) do
        if v.Character then
            local Distance = self:GetDistance(v.Character)
            if Distance < ClosestDist then
                ClosestDist = Distance
                Closest = v
            end
        end
    end
    
    return Closest, ClosestDist
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

        self[self:RandomString(8)] = Original
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

        self.Model:PivotTo(CFrame.new(self.Root.Position))
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

    Roots.Velocity = Vector3.zero
    Roots.AssemblyLinearVelocity = Vector3.zero

    local Current = Roots.Position
    local Delta = Position - Current;

    local Distance = Delta.Magnitude
    
    if Distance < 0.05 then return end

    local Num = tonumber(Speed) or math.huge
    local dt = RunService.Heartbeat:Wait();

    local Step = math.min(Num * dt, Distance)
    local Direction = (Distance > 0 and Delta.Unit) or Vector3.zero
    local NewPos = Current + Direction * Step;                

    local cf = CFrame.lookAt(NewPos, LookAt or (NewPos + Direction));
    self:GetCharacter():PivotTo(cf);
end

function API:IsColor(Target, __Colors)
    if __Colors == "Nigger" then
        __Colors = {["Really black"] = true,["Black"] = true,["Dark brown"] = true,["Reddish brown"] = true,
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

    return __Colors[HeadColor.Name] and __Colors[TorsoColor.Name] or false
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
        task.wait(1);
        TeleportService:Teleport(game.PlaceId, Plr)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Plr)
    end
end

function API:ServerHop(MinPlayers, MaxPing)
    local Plr = self:GetPlayer()

    local Success, Result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" ..game.PlaceId .."/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if not Success or not Result then
        warn("[ServerHop]: Failed to fetch servers")
        return
    end

    for _, Server in next, Result.data do
        if Server.id and Server.playing < Server.maxPlayers and Server.playing > (MinPlayers or 0) and (not MaxPing or Server.ping <= MaxPing) then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, Plr)
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
        local RbxAnalytics = game:GetService("RbxAnalyticsService")
        return RbxAnalytics:GetClientId()
    elseif Method == "IP" then
        local Success, IP = pcall(function()
            return game:HttpGet("https://api.ipify.org")
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
            return game:HttpGet(Options.Url)
        end)
    
        if Success then
            local allMatches = {}
            
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(Content)
            end)
            
            if success and type(decoded) == "table" then
                local function extractFromTable(t)
                    for k, v in pairs(t) do
                        if type(v) == "string" then
                            table.insert(allMatches, v)
                        elseif type(v) == "number" then
                            table.insert(allMatches, tostring(v))
                        elseif type(v) == "table" then
                            extractFromTable(v)
                        end
                        if type(k) == "string" then
                            table.insert(allMatches, k)
                        elseif type(k) == "number" then
                            table.insert(allMatches, tostring(k))
                        end
                    end
                end
                extractFromTable(decoded)
            end
            
            local function splitByAnyDelimiter(text)
                local results = {}
                local delimiters = {",", ";", "|", "\t", "\n", "\r", "  "}
                for _, delim in ipairs(delimiters) do
                    text = string.gsub(text, delim, " ")
                end
                for word in string.gmatch(text, "[^%s]+") do
                    table.insert(results, word)
                end
                return results
            end
            
            for line in string.gmatch(Content, "[^\r\n]+") do
                line = line:gsub("^%s+", ""):gsub("%s+$", "")
                if line ~= "" and not line:match("^%s*%-%-") and not line:match("^%s*#") and not line:match("^%s*//") then
                    local words = splitByAnyDelimiter(line)
                    for _, word in ipairs(words) do
                        table.insert(allMatches, word)
                    end
                end
            end
            
            for _, match in ipairs(allMatches) do
                match = match:gsub("^%s+", ""):gsub("%s+$", "")
                match = match:gsub('"', "")
                match = match:gsub("'", "")
                match = match:gsub("[{}%[%]()]", "")
                
                if match ~= "" then
                    table.insert(AllowedList, match)
                end
            end
        else
            warn("[Auth]: Failed to load:", Options.Url)
        end
    end
    
    for _, item in ipairs(Options.Hwids or {}) do
        if item and item ~= "" then
            table.insert(AllowedList, tostring(item))
        end
    end
    
    local function unique(t)
        local seen = {}
        local result = {}
        for _, v in ipairs(t) do
            if not seen[v] then
                seen[v] = true
                table.insert(result, v)
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

    local Size = Options.Size or Vector3.new(10, 1, 10)
    local Color = Options.Color or Color3.fromRGB(170, 170, 170)
    local Transparency = Options.Transparency or 0
    local Material = Options.Material or Enum.Material.Plastic
    local Offset = Options.Offset or Vector3.new(0, -3.7245, 0)
    local Parent = Options.Parent or workspace
    local CanCollide = Options.CanCollide ~= false
    local Anchored = Options.Anchored ~= false

    local Baseplate = self:CreateInstance("Part", {
        Name = Options.Name or self:RandomString(8),
        Size = Size,
        Color = Color,
        Transparency = Transparency,
        Material = Material,
        CanCollide = CanCollide,
        Anchored = Anchored,
        Parent = Parent
    })
    
    local function UpdatePosition()
        local HumanoidRoot = Character:WaitForChild("HumanoidRootPart")
        Baseplate.CFrame = HumanoidRoot.CFrame + Offset
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
                Connection = self:RenderStep(UpdatePosition, self:RandomString(8))
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
    table.insert(self.CreatedBaseplates, {
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

-- // >Loop Manager, Build: @1.25 | by Mommy Flames
function API:WhileLoop(WaitBoy, Callback, Name, WaitBefore)
    Wait = WaitBoy or 0
    Name = Name or self:RandomString(8)

    local thread
    local func = function()
        if WaitBefore and Wait then
            task.wait(Wait)
        end

        while task.wait(Wait) do
            if self.Unloaded then break end
            self:SafeCall(Callback, self)
        end
    end

    thread = task.spawn(func)
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = {
        Type = "thread",
        Thread = thread,
        Func = func,
        Running = true
    }

    return thread
end

function API:RenderStep(Callback, Name)
    Name = Name or self:RandomString(8)
    
    local func = function(dt)
        if self.Unloaded then return end
        self:SafeCall(Callback, self, dt)
    end

    local conn = RunService.RenderStepped:Connect(func)
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = {
        Type = "RBXScriptConnection",
        Connection = conn,
        Service = "RenderStepped",
        Func = func,
        Running = true
    }

    return conn
end

function API:BindRender(Callback, Name, Priority)
    Name = Name or self:RandomString(8)

    local func = function(dt)
        if self.Unloaded then return end
        self:SafeCall(Callback, self, dt)
    end

    RunService:BindToRenderStep(Name, Priority or Enum.RenderPriority.Last.Value, func)
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = {
        Type = "BindToRenderStep",
        Name = Name,
        Func = func,
        Running = true
    }

    return {Type = "BindToRenderStep", Name = Name}
end

function API:Stepped(Callback, Name)
    Name = Name or self:RandomString(8)

    local func = function(time, dt) 
        self:SafeCall(Callback, self, time, dt) 
    end

    local conn = RunService.Stepped:Connect(func)
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = {
        Type = "RBXScriptConnection", 
        Connection = conn, 
        Service = "Stepped", 
        Func = func, 
        Running = true
    }
    return conn
end

function API:Heartbeat(Callback, Name)
    Name = Name or self:RandomString(8)
    
    local func = function(dt) 
        self:SafeCall(Callback, self, dt) 
    end

    local conn = RunService.Heartbeat:Connect(func)
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = {
        Type = "RBXScriptConnection", 
        Connection = conn, 
        Service = "Heartbeat", 
        Func = func, 
        Running = true
    }
    return conn
end

function API:BindKeybind(Key, Callback, BindName)
    local Connection
    Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Key or input.UserInputType == Key then
            Callback(input)
        end
    end)
    
    self.ActiveConnections = self.ActiveConnections or {}
    local Name = BindName or self:RandomString(8)
    
    self.ActiveConnections[Name] = {
        Type = "RBXScriptConnection",
        Service = "InputBegan",
        Connection = Connection,
        Running = true,
        Key = Key,
        Func = Callback
    }

    return Connection, Name
end

function API:SetKeybind(Name, NewKey)
    local Entry = self.ActiveConnections and self.ActiveConnections[Name]
    if not Entry then
        return false
    end
    
    if Entry.Type ~= "RBXScriptConnection" or Entry.Service ~= "InputBegan" then
        return false
    end
    
    local Running = Entry.Running

    if Running then
        self:ForceStop(Name)
    end
    
    Entry.Key = NewKey
    
    if Running then
        self:ForceStart(Name)
    end
    
    return true
end

function API:ForceStop(Name)
    local Entry = self.ActiveConnections and self.ActiveConnections[Name]
    if not Entry then
        return false
    end

    if Entry.Running == false then
        return true
    end

    if Entry.Type == "thread" then
        if Entry.Thread and coroutine.status(Entry.Thread) ~= "dead" then
            task.cancel(Entry.Thread)
        end
    elseif Entry.Type == "RBXScriptConnection" then
        if Entry.Connection and Entry.Connection.Connected then
            Entry.Connection:Disconnect()
        end
    elseif Entry.Type == "BindToRenderStep" then
        pcall(function()
            RunService:UnbindFromRenderStep(Entry.Name or Name)
        end)
    end

    Entry.Running = false
    return true
end

function API:ForceStart(Name)
    local Entry = self.ActiveConnections and self.ActiveConnections[Name]
    if not Entry then
        return nil
    end

    if Entry.Running then
        self:ForceStop(Name)
    end

    if Entry.Type == "thread" then
        local thread = task.spawn(Entry.Func)
        Entry.Thread = thread
        Entry.Running = true
        return thread

    elseif Entry.Type == "RBXScriptConnection" then
        local conn
        if Entry.Service == "RenderStepped" then
            conn = RunService.RenderStepped:Connect(Entry.Func)
        elseif Entry.Service == "Heartbeat" then
            conn = RunService.Heartbeat:Connect(Entry.Func)
        elseif Entry.Service == "Stepped" then
            conn = RunService.Stepped:Connect(Entry.Func)
        elseif Entry.Service == "InputBegan" then
            conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Entry.Key or input.UserInputType == Entry.Key then
                    Entry.Func(input)
                end
            end)
        end
        Entry.Connection = conn
        Entry.Running = true
        return conn

    elseif Entry.Type == "BindToRenderStep" then
        RunService:BindToRenderStep(Entry.Name or Name, Enum.RenderPriority.Last.Value, Entry.Func)
        Entry.Running = true
        return Entry
    end
end

function API:GetState(Name)
    local Floop = self.ActiveConnections and self.ActiveConnections[Name]
    if Floop then
        if Floop.Running == false then return false end
        if Floop.Type == "thread" then
            return coroutine.status(Floop.Thread) ~= "dead"
        elseif Floop.Type == "RBXScriptConnection" then
            return Floop.Connection and Floop.Connection.Connected
        end
        return Floop.Running == true
    end

    local Task = self.ActiveTasks and self.ActiveTasks[Name]
    if Task then
        return Task.Running == true
    end
    
    return nil
end

function API:AddTask(Signal, Callback, Name)
    self.ActiveTasks = self.ActiveTasks or {}

    if self.ActiveTasks[Name] then
        return self.ActiveTasks[Name]
    end

    local Data = {Signal = Signal, Callback = Callback, Connection = nil, Running = true}

    local function wrapper()
        Data.Connection = Signal:Connect(function(...)
            if Data.Running and not self.Unloaded then
                self:SafeCall(Callback, self, ...)
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
        if not Data.Running then return end
        Data.Running = false
        if Data.Connection then
            Data.Connection:Disconnect()
            Data.Connection = nil
        end
    end
end

function API:RestartTask(Name)
    local Data = self.ActiveTasks and self.ActiveTasks[Name]
    if Data then
        if Data.Running then return end
        Data.Running = true
        if not Data.Connection then
            Data.Reconnect()
        end
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

    self[self:RandomString(8)] = self[Name]
    self[Name] = Function

    return true
end

function API:Unload()
    getgenv().FunctionManager_Engine = nil
    self.Unloaded = true

    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveTasks = self.ActiveTasks or {}

    for Instance, _ in pairs(self.ActiveConnections) do
        self:ForceStop(Instance)
    end
    for Instance, _ in pairs(self.ActiveTasks) do
        self:StopTask(Instance)
    end

    if self.FlightData then
        if self.FlightData.BodyVelocity then
            pcall(function() self.FlightData.BodyVelocity:Destroy() end)
        end
        if self.FlightData.BodyGyro then
            pcall(function() self.FlightData.BodyGyro:Destroy() end)
        end
        for _, conn in ipairs(self.FlightData.Connections or {}) do
            pcall(function() conn:Disconnect() end)
        end
        self.FlightData = nil
    end

    if self.XRayActive then self:XRay(false) end
    self:StopClip()
    self:StopFling()
    self:ClearHighlights()
    self:ClearBaseplates()

    self:Flags()
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
            table.insert(List, k)
        end
    end

    table.sort(List)
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

    for Instance, Value in pairs(API) do
        if Instance ~= "__index" then Class[Instance] = value
            if type(Value) == "function" then
                Class.Core[Value] = true
            end
        end
    end

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
    Class.CoreGui = CoreGui

    API.Flags(Class)
    return setmetatable(Class, API)
end

getgenv().FunctionManager_Engine = true --> @Watermark

local Functions = 0
for _, v in pairs(API) do
    if type(v) == "function" then Functions = Functions + 1 end
end

local EndTime = os.clock()
warn(string.format("[Functions.luau] Loaded in %.3f ms, Build: %s, Functions: %d | By: %s", (EndTime - LoadTime) * 1000, Project.Build, Functions, Project.Author))

return API
