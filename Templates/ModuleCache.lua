-- // @Cache loading engine
local Game, os_clock, loadstring = game, os.clock, loadstring

local function Load_Module()
    local Source = "https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau"
    
    if not isfolder("@File_Caches") then 
        makefolder("@File_Caches") 
    end
    
    local File = "@File_Caches/Module.luau"

    if isfile(File) then
        local Content = readfile(File)
        if Content then
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
                pcall(writefile, File, FreshContent)
                return loadstring(FreshContent)()
            else
                return loadstring(Content)()
            end
        end
    end

    local Content = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
    pcall(writefile, File, Content)

    return loadstring(Content)()
end

local Function_Manager = Load_Module()
local Script = Function_Manager.Launch({})

-- // Functions here~

-- // Speed Comparisons:
-- Cached: 0.1ms
-- Outdated: 0.7ms
