-- // @Obsidian Example
if typeof(_IsLoadedFM) == "function" and _IsLoadedFM() then
    warn("@Function Manager.luau is already running")
    return
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))()

local API = Class.Launch({
    Loop_Example = true
})

local Window = Library:CreateWindow()
local Main = Window:AddTab("Main", "user")

local GroupBox = Main:AddLeftGroupbox("Groupbox", "boxes")

API:AddFeature(GroupBox, "Loop_Example", {
    Default = false,
    Text = "Loop Toggle",
    Interval = 0.35,
    Callback = function(self, Object, Value)
        print("State:", Value)
    end,
    LoopCallback = function(self, State, Delta, Cooldown)
        if State:GET() then
            warn("Loop running!")
            -- // Your loop logic here
        end
    end
})

GroupBox:AddButton("Unload", function()
    API:Unload()
end)
