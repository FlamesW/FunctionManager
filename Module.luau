-- // Made by Mommy Flames
local API = {}
API.__index = API

local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

-- // Variables
local Players: Players = cloneref(game:GetService("Players"))
local LocalPlayer: Player = Players.LocalPlayer
local MarketplaceService: MarketplaceService = game:GetService("MarketplaceService")
local HttpService: HttpService = cloneref(game:GetService("HttpService"));
local TeleportService: TeleportService = cloneref(game:GetService("TeleportService"))

-- // Functions
local AssetCache, HighlightCache, RecencyStores = {} {}, {}, {}

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
        local Char = self:GetCharacter();
        if not Char then return end;
   
        local Hum = Char:FindFirstChild("HumanoidRootPart");
        if not Hum then return end;
  
        if not Hum:FindFirstChild("0x0x0x0x0") then
            local AntiFling = Instance.new("BodyVelocity");
            AntiFling.Name = "0x0x0x0x0";
            AntiFling.Velocity = Vector3.new(0, 0, 0);
            AntiFling.MaxForce = Vector3.new(40000, 40000, 40000);
            AntiFling.Parent = Hum;
        end
     
        Hum.Velocity = Vector3.new(0, 0, 0);
 
        local AntiFling = Hum:FindFirstChild("0x0x0x0x0");
        if AntiFling then
            AntiFling.Velocity = Vector3.new(0, 0, 0);
        end
    end)
end

function API:StopFling()
    if not self.FlingActive then
        return
    end

    self.FlingActive = false
    if self.FlingLoop then
        self.FlingLoop:Disconnect();
        self.FlingLoop = nil;
    end

    local Char = self:GetCharacter();
    if Char then
        local Hum = Char:FindFirstChild("HumanoidRootPart");
        if Hum then
            local AntiFling = Hum:FindFirstChild("0x0x0x0x0");
            if AntiFling then
                AntiFling:Destroy();
            end
        end
    end
end

function API:Noclip()
    self.EndPoint = tick() + 0.45

    if not self.Noclipping then
        self.Clip = false
        self.Origins = {}

        local function NoclipLoop()
            if self.Clip == false and self:GetCharacter() ~= nil then
                for _, v in pairs(self:GetCharacter():GetDescendants()) do
                    if v:IsA("BasePart") then
                        if self.Origins[v] == nil then
                            self.Origins[v] = v.CanCollide
                        end
                        if v.CanCollide == true then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end

        self.Noclipping = RunService.Stepped:Connect(NoclipLoop)

        local function CheckTimeout()
            if self.EndPoint and tick() >= self.EndPoint then
                self:StopClip()
            end
        end
        self.TimeoutConnection = RunService.Heartbeat:Connect(CheckTimeout)
    end
end

function API:StopClip()
    self.EndPoint = nil

    if self.Noclipping then
        self.Noclipping:Disconnect()
        self.Noclipping = nil
    end
    if self.TimeoutConnection then
        self.TimeoutConnection:Disconnect()
        self.TimeoutConnection = nil
    end

    self.Clip = true

    if self:GetCharacter() ~= nil then
        for _, v in pairs(self:GetCharacter():GetDescendants()) do
            if v:IsA("BasePart") and self.Origins[v] ~= nil then
                v.CanCollide = self.Origins[v]
            end
        end
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
        Name = Options.Name or "Highlight",
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

    local Humanoid = model:FindFirstChildOfClass("Humanoid")
    local RootPart = model:FindFirstChild("HumanoidRootPart")

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
        if typeof(v) == "function" and k ~= "__index" and k ~= "wrap" and k ~= "Help" and k ~= "OverrideFunction" and k ~= "SelectEverything" then
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

function API:OverrideFunction(Name, Function)
    if typeof(self[Name]) ~= "function" then
        warn("Function does not exist:", Name)
        return false
    end

    self["[Overide Function] - " .. Name] = self[Name]
    self[Name] = Function

    return true
end

function API.Launch(Class)
    return setmetatable(Class, API);
end
return API
