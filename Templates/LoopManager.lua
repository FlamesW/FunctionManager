-- // @Obsidian Example
if typeof(_IsLoadedFM) == "function" and _IsLoadedFM() then
    warn("@Function Manager.luau is already running")
    return
end

local Game, os_clock, loadstring, tostring, match, warn = game, os.clock, loadstring, tostring, match, warn
local write_file, read_file, is_file, make_folder, is_folder = writefile, readfile, isfile, makefolder, isfolder

local function Load_Module()
    local Source = "https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"
    local Repo = "https://raw.githubusercontent.com/FlamesW/FunctionManager"

    if not is_folder("@File_Caches") then
        make_folder("@File_Caches")
    end

    local File = "@File_Caches/Module.luau"

    local function Execute(Content)
        local Chunk, Error = loadstring(Content)

        if not Chunk then
            warn("[FunctionManager]: Failed to compile module:\n" .. tostring(Error))
        end

        local Success, Result = pcall(Chunk)

        if not Success then
            warn("[FunctionManager]: Failed to execute module:\n" .. tostring(Result))
        end

        return Result
    end

    if is_file(File) then
        local Content = read_file(File)

        if Content then
            local Current_Version = Content:match('Build%s*=%s*"@([%d%.]+)"')
            local Latest_Version

            local Success, Response = pcall(function()
                return Game:HttpGet(Repo .. "/home/%40Version.cfg?nocache=" .. tostring(os_clock()))
            end)

            if Success and Response then
                Latest_Version = Response:match("@([%d%.]+)")
            end

            if Latest_Version and Current_Version and Latest_Version ~= Current_Version then
                local FreshContent = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
                pcall(write_file, File, FreshContent)

                return Execute(FreshContent)
            end

            return Execute(Content)
        end
    end

    local Content = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))

    pcall(write_file, File, Content)
    return Execute(Content)
end

-- // @Module.Luau
local Function_Manager = Load_Module()

local API = Function_Manager.Launch({
    Loop_Example = true
})

local Obsidian = API:Load_Obsidian()
local Library = Obsidian.Library

-- // Create Window
local Window = Library:CreateWindow()
local Main = Window:AddTab("Main", "user")

local GroupBox = Main:AddLeftGroupbox("Groupbox", "boxes")

local Feature = API:AddFeature(GroupBox, "Loop_Example", {
    Default = true,
    CallOnLaunch = false,
    Text = "Loop Toggle",
    Interval = 0.35,
    Engine = "WhileLoop",
    Callback = function(self, Object, Value)
        print("State:", Value)
        self:Flight(Value)
    end,
    LoopCallback = function(self, State, Delta, Cooldown)
        if self:SmartTimer("1Second_Timer", 1) then
            print("yeah")
        end

        if State:GET() then
            warn("Loop running!")
        end
    end
})

GroupBox:AddButton("Randomize Text", function()
    Feature:SetText(API:RandomString(15))
end)

GroupBox:AddButton("Toggle Loop", function()
    Feature:SetValue(not Feature:GET())
end)

GroupBox:AddButton("Pause Loop", function()
    Feature:Pause()
end)

GroupBox:AddButton("Resume Loop", function()
    Feature:Unpause()
end)

GroupBox:AddButton("Set Interval to 0.1s", function()
    Feature:SetInterval(0.1)
end)

GroupBox:AddButton("Set Interval to 1s", function()
    Feature:SetInterval(1)
end)

GroupBox:AddButton("Lock Feature", function()
    Feature:Lock()
end)

GroupBox:AddButton("Unlock Feature", function()
    Feature:Unlock()
end)

GroupBox:AddButton("Reset Feature", function()
    Feature:Reset()
end)

GroupBox:AddButton("Kill Feature", function()
    Feature:Kill()
end)

GroupBox:AddButton("Unload", function()
    API:Unload()
end)
