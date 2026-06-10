-- // @Loading caches
local Game, os_clock, loadstring, tostring, task_spawn = game, os.clock, loadstring, tostring, task.spawn
local write_file, read_file, is_file, make_folder, is_folder = writefile, readfile, isfile, makefolder, isfolder

local Assets = {
    ["Module.luau"] = "https://github.com/FlamesW/FunctionManager/releases/latest/download/Module.luau",
  -- // Add in more modules~
}

local function Load_File(luau, State)
    local Source = Assets[luau]
    if (Source == nil) then
        return Game:Shutdown()
    end

    if State == true then
        local Content = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
        return loadstring(Content)()
    end

    if not is_folder("@File_Caches") then 
        make_folder("@File_Caches") 
    end
    
    local File = "@File_Caches/" .. luau

    if is_file(File) then
        local Success, Content = pcall(read_file, File)
        if Success and Content then
            if luau == "Module.luau" then
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
                    pcall(write_file, File, FreshContent)

                    warn("Module updated -> @" .. Latest_Version)
                    return loadstring(FreshContent)()
                else
                    return loadstring(Content)()
                end
            else
                task_spawn(function()
                    local Client_Check = Game:HttpGet(Source .. "?nocache=" .. tostring(os_clock()))
                    if Client_Check ~= Content then
                        pcall(write_file, File, Client_Check)
                        warn(luau .. " got updated!")
                    end
                end)
                return loadstring(Content)()
            end
        end
    end

    local Content = Game:HttpGet(Source .. "?nocache=" .. tostring(os.clock()))
    pcall(write_file, File, Content)

    return loadstring(Content)()
end

-- // @Module.Luau
local Function_Manager = Load_File("Module.luau", false)
local Script = Function_Manager.Launch({})

-- // Functions here~

-- // LoadFile("Smt123", true) --> Forces download 
-- // LoadFile("Smt666", false) --> Redownloads when updated (Only runs in the background)
-- // Conclusion: The script is for one time will not fetch the updated file at runtime due to no version diff checks, so the best it can do is run the update in the background.
