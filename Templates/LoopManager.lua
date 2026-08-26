if typeof(_IsLoadedFM) == "function" and _IsLoadedFM() then
    warn("@Function Manager.luau is already running")
    return
end

local Class = loadstring(game:HttpGet("https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"))()

local API = Class.Launch({
    Loop_Example = true
})

API:WhileLoop(0.35, function(self)
    if self.Loop_Example then
        print("wowwee")
    end
end, "Loop")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()

local Window = Library:CreateWindow()
local Main = Window:AddTab("Main", "user")

local GroupBox = Main:AddLeftGroupbox("Groupbox", "boxes")

GroupBox:AddToggle("Loop_Example_CFG", {
    Text = "Loop Toggle",
    Default = API.Loop_Example,
    Callback = function(Value)
        API.Loop_Example = Value
    end
})

GroupBox:AddButton("Unload", function()
    Library:Unload()
    API:Unload()
end)
