-- =====================================================================
-- SERVER HOPPER - Public room rotation engine
-- =====================================================================

local ServerHopper = {}
ServerHopper.__index = ServerHopper

function ServerHopper.new(services)
    local self = setmetatable({}, ServerHopper)
    
    self.Services = services
    
    return self
end

function ServerHopper:rotateServerInstance()
    print("[PET_FINDER]: Transitioning room states. Sifting global server index arrays...")
    
    local apiURL = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(self.Services.PLACE_ID))
    local fetchSuccess, serverData = pcall(function()
        return self.Services.HttpService:JSONDecode(game:HttpGet(apiURL))
    end)
    
    if fetchSuccess and serverData and serverData.data then
        local serverList = serverData.data
        local priorityServers = {}
        local backupServers = {}
        local maxPlayerLimit = 2 -- Should be from config
        
        for _, server in pairs(serverList) do
            if server.id and server.id ~= game.JobId and server.playing then
                if server.playing >= 1 and server.playing <= maxPlayerLimit then
                    table.insert(priorityServers, server)
                elseif server.playing < server.maxPlayers then
                    table.insert(backupServers, server)
                end
            end
        end
        
        math.randomseed(os.time())
        for i = #priorityServers, 2, -1 do
            local j = math.random(i)
            priorityServers[i], priorityServers[j] = priorityServers[j], priorityServers[i]
        end
        
        for _, server in pairs(priorityServers) do
            print(string.format("[PET_FINDER]: Targeting sniper paradise instance (%d players) ID: %s", server.playing, tostring(server.id)))
            task.wait(0.5)
            local teleportSuccess, teleportErr = pcall(function()
                self.Services.TeleportService:TeleportToPlaceInstance(self.Services.PLACE_ID, server.id, self.Services.LocalPlayer)
            end)
            if teleportSuccess then return end
        end
        
        print("[PET_FINDER]: No immediate low-player targets available. Shifting to backup index array...")
        for i = #backupServers, 2, -1 do
            local j = math.random(i)
            backupServers[i], backupServers[j] = backupServers[j], backupServers[i]
        end
        
        for _, server in pairs(backupServers) do
            task.wait(0.5)
            local teleportSuccess, teleportErr = pcall(function()
                self.Services.TeleportService:TeleportToPlaceInstance(self.Services.PLACE_ID, server.id, self.Services.LocalPlayer)
            end)
            if teleportSuccess then return end
        end
    end
    
    print("[PET_FINDER]: Public query directory exhausted. Deploying baseline safety hop...")
    pcall(function()
        self.Services.TeleportService:Teleport(self.Services.PLACE_ID, self.Services.LocalPlayer)
    end)
end

return ServerHopper
