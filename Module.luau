-- // Made by Mommy Flames
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local API = {}
API.__index = API

-- // Variables
local Players: Players = cloneref(game:GetService("Players"));
local LocalPlayer: Player = Players.LocalPlayer
local RunService = game:GetService("RunService");
local TweenService = cloneref(game:GetService("TweenService"));
local MarketplaceService: MarketplaceService = game:GetService("MarketplaceService");
local HttpService: HttpService = cloneref(game:GetService("HttpService"));
local TeleportService: TeleportService = cloneref(game:GetService("TeleportService"));
local RbxAnalyticsService: RbxAnalyticsService = cloneref(game:GetService("RbxAnalyticsService"));

-- // Functions
local AssetCache, HighlightCache, RecencyStores = {}, {}, {}, {}

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

function API:Req(url)
    local Make_Request = http and http.request or request or http_request or syn and syn.request
    if Make_Request then
        return Make_Request({Url = url, Method = "GET"}).Body
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

function API:GetAssetInfo(Id)
    local Cached = AssetCache[Id]
    if Cached then
        return Cached
    end

    local Success, Info = pcall(function()
        return MarketplaceService:GetProductInfo(Id)
    end)

    if not Success or not Info then
        return nil
    end

    local Result = {
        Name = Info.Name,
        Creator = Info.Creator and Info.Creator.Name,
        Type = Info.AssetTypeId,
        Description = Info.Description
    }

    AssetCache[id] = Result

    return Result
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
        return self:Req(Github .. "?nocache=" .. os.clock())
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

    if Commits[Version] then
        return Commits[Version]
    else
        warn("Version " .. Version .. " not found. Only " .. #Commits .. " commits available.")
        return nil
    end
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
    local Plr = self:GetPlayer()
    return Plr.Character or Plr.CharacterAdded:Wait()
end

function API:GetRoot()
    local Char = self:GetCharacter()
    return Char:WaitForChild("HumanoidRootPart", 5)
end

function API:GetHumanoid()
    local Char = self:GetCharacter()
    return Char:FindFirstChildOfClass("Humanoid")
end

function API:IsAlive()
    local Hum = self:GetHumanoid()
    return Hum and Hum.Health > 0
end

function API:SmartTimer(Name, Delay)
    self._Timers = self._Timers or {}

    local CT = tick()
    local Last = self._Timers[Name] or 0;

    if CT - Last >= Delay then
        self._Timers[Name] = CT;
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

        local Recency = RecencyStores[Key] or {}

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

        RecencyStores[Key] = NewRec;

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
                local AntiFling = Instance.new("BodyVelocity")
                AntiFling.Name = "0x0x0x0x0"
                AntiFling.Velocity = Vector3.new(0, 0, 0)
                AntiFling.MaxForce = Vector3.new(40000, 40000, 40000)
                AntiFling.Parent = Hum
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

function API:CreateHighlight(Target, Options)
    if not Target then return nil end

    Options = Options or {}

    if HighlightCache[Target] then
        return HighlightCache[Target]
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

    HighlightCache[Target] = Highlight

    Target.AncestryChanged:Connect(function()
        if not Target:IsDescendantOf(game) then
            self:RemoveHighlight(Target)
        end
    end)

    return Highlight
end

function API:RemoveHighlight(Target)
    local Highlight = HighlightCache[Target]
    if not Highlight then return false end

    if Highlight and Highlight.Destroy then
        Highlight:Destroy()
    end

    HighlightCache[Target] = nil
    return true
end

function API:ClearHighlights()
    for Target, Highlight in pairs(HighlightCache) do
        if Highlight and Highlight.Destroy then
            pcall(function()
                Highlight:Destroy()
            end)
        end
    end

    table.clear(HighlightCache)
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
            warn("Function does not exist:", Name)
            return false
        end

        self["[Overide Function] - " .. Name] = Original
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

    local Position = self:ResolvePosition(args[1])
    local LookAt = self:ResolvePosition(args[2])

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

    local cf = CFrame.lookAt(NewPos,LookAt or (NewPos + Direction));
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

function API:Help()
    warn("=====[ FUNCTIONS ]=====")
    local List = {}

    for k, v in pairs(API) do
        if typeof(v) == "function" and k ~= "__index" and k ~= "wrap" and k ~= "Help" and k ~= "OverrideFunction" and k ~= "Merge" and k ~= "Launch" and k ~= "SelectEverything" then
            table.insert(List, k)
        end
    end

    table.sort(List)
    for _, k in ipairs(List) do
        print("• " .. k)
    end

    warn("=======================")
end

function API:Rejoin()
    local Plr = self:GetPlayer()
    TeleportService:Teleport(game.PlaceId, Plr)
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
    local OnFail = Options.OnFail or "Kick"
    local OnSuccess = Options.OnSuccess
    local FailCallback = Options.FailCallback
    local Success = Options.SuccessCallback
    local AllowedUsers, AllowedHWIDs = {}, {}
    
    local Auth = nil
    local Methods = Options.Method or {"Roblox"}
    if type(Methods) ~= "table" then
        Methods = {Methods}
    end
    
    for _, method in ipairs(Methods) do
        if method == "Executor" or method == "Roblox" then
            local hwid = self:GetHWID(method)
            if hwid then
                Auth = hwid
                break
            end
        elseif method == "IP" then
            self:Kick("[Auth]: IP method is not allowed.")
            return false, nil, nil
        else
            self:Kick("[Auth]: Invalid method '" .. tostring(method))
            return false, nil, nil
        end
    end
    
    if not Auth then
        self:Kick("[Auth]: Failed to get Hwid from any method! Tried: " .. table.concat(Methods, ", "))
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
                    if match:match("%-") or #match > 20 or match:match("^[Hh][Ww][Ii][Dd]:") then
                        local hwid = match:gsub("^[Hh][Ww][Ii][Dd]:", "")
                        table.insert(AllowedHWIDs, hwid)
                    else
                        if tonumber(match) then
                            table.insert(AllowedUsers, tonumber(match))
                        else
                            table.insert(AllowedUsers, match)
                        end
                    end
                end
            end
        else
            warn("[Auth]: Failed to load:", Options.Url)
        end
    end
    
    for _, user in ipairs(Options.AllowedUsers or {}) do
        table.insert(AllowedUsers, user)
    end
    for _, hwid in ipairs(Options.AllowedHwids or {}) do
        table.insert(AllowedHWIDs, hwid)
    end
    
    local function unique(t)
        local seen = {}
        local result = {}
        for _, v in ipairs(t) do
            if not seen[tostring(v)] then
                seen[tostring(v)] = true
                table.insert(result, v)
            end
        end
        return result
    end
    
    AllowedUsers = unique(AllowedUsers)
    AllowedHWIDs = unique(AllowedHWIDs)
    
    local IsWhitelisted = false
    local Type, Value = nil, nil
    
    for _, Hwid in ipairs(AllowedHWIDs) do
        if Auth and tostring(Auth):lower() == tostring(Hwid):lower() then
            IsWhitelisted = true
            Type = "HWID"
            Value = Hwid
            break
        end
    end
    
    if not IsWhitelisted then
        for _, AllowedUser in ipairs(AllowedUsers) do
            local AllowedStr = tostring(AllowedUser):lower()
            if AllowedStr == tostring(LPlayer.UserId) or AllowedStr == LPlayer.Name:lower() then
                IsWhitelisted = true
                Type = "User"
                Value = AllowedUser
                break
            end
        end
    end
    
    if IsWhitelisted then
        if Success or OnSuccess then
            local Callback = Success or OnSuccess
            if type(Callback) == "function" then
                pcall(function()
                    Callback(Type, Value, Auth)
                end)
            end
        end
        return true, Type, Value
    end

    if OnFail == "Kick" then
        self:Kick(Options.KickMessage or "[Auth]: Nothing is defined")
    elseif OnFail == "Callback" then
        if FailCallback and type(FailCallback) == "function" then
            pcall(function()
                FailCallback(Auth, LPlayer.Name, LPlayer.UserId)
            end)
        else
            self:Kick("[Auth]: Nothing is defined")
        end
    elseif OnFail == "Return" then
        return false, nil, nil
    else
        self:Kick("[Auth]: Nothing is defined")
    end
    
    return false, nil, nil
end

function API:OverrideFunction(Name, Function)
    if typeof(self[Name]) ~= "function" then
        warn("Function does not exist:", Name)
        return false
    end

    self["[Overide Function] - " .. Name] = self[Name]
    self[Name] = Function

    return true
end

function API:Merge(Module)
    for MethodName, MethodFunc in pairs(Module) do
        if typeof(MethodFunc) == "function" then
            self[MethodName] = function(_, ...)
                return MethodFunc(self, ...)
            end
        end
    end

    return self
end

function API.Launch(Class)
    return setmetatable(Class, API);
end

return API
