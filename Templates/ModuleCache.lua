-- // @Cache loading engine
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

local Function_Manager = Load_Module()
local Script = Function_Manager.Launch({})

-- // Functions here~

-- // Speed Comparisons:
-- Cached: 0.1ms
-- Outdated: 0.7ms
