-- =====================================================================
-- UTILITIES MODULE - Shared helper functions
-- =====================================================================

local Utilities = {}

function Utilities.saveConfig(fileName, config, httpService)
    local success, encoded = pcall(function()
        return httpService:JSONEncode(config)
    end)
    
    if success and writefile then
        writefile(fileName, encoded)
        print("[CONFIG]: Data safely written to local storage matrix.")
    else
        warn("[CONFIG]: Local execution hardware blocked data serialization write sequence.")
    end
end

function Utilities.loadConfig(fileName, config, httpService)
    if isfile and isfile(fileName) and readfile then
        local fileContents = readfile(fileName)
        local decodeSuccess, decodedTable = pcall(function()
            return httpService:JSONDecode(fileContents)
        end)
        
        if decodeSuccess and type(decodedTable) == "table" then
            for key, value in pairs(decodedTable) do
                if type(value) == "table" and type(config[key]) == "table" then
                    for subKey, subValue in pairs(value) do
                        config[key][subKey] = subValue
                    end
                else
                    config[key] = value
                end
            end
            
            print("[CONFIG]: Setup configuration loaded and applied successfully.")
            return true
        end
    end
    return false
end

function Utilities.isMyGarden(garden, localPlayer)
    if garden.Name == localPlayer.Name or string.find(garden.Name, tostring(localPlayer.UserId)) then
        return true
    end
    if garden:GetAttribute("Owner") == localPlayer.Name or garden:GetAttribute("Owner") == localPlayer.UserId or garden:GetAttribute("OwnerID") == localPlayer.UserId then
        return true
    end
    for _, child in ipairs(garden:GetDescendants()) do
        if child:IsA("ValueBase") and (child.Value == localPlayer or child.Value == localPlayer.Name or tostring(child.Value) == tostring(localPlayer.UserId)) then
            return true
        end
        if child:IsA("TextLabel") and (string.find(child.Text, localPlayer.Name) or (localPlayer.DisplayName and string.find(child.Text, localPlayer.DisplayName))) then
            return true
        end
    end
    return false
end

function Utilities.removeOtherGardens(workspace, localPlayer)
    local gardensFolder = workspace:FindFirstChild("Gardens")
    if gardensFolder then
        for _, garden in ipairs(gardensFolder:GetChildren()) do
            if not Utilities.isMyGarden(garden, localPlayer) then
                pcall(function() garden:Destroy() end)
            end
        end
    end
end

function Utilities.applyAggressiveLagReduction(workspace, lighting)
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.EnvironmentBlurIntensity = 0
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
    end)
    
    for _, obj in ipairs(lighting:GetChildren()) do
        pcall(function()
            if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("Clouds") then
                obj:Destroy()
            end
        end)
    end
    
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            terrain.WaterWaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterDetail = Enum.WaterDetail.Low
        end)
    end
    
    local descendants = workspace:GetDescendants()
    for i, instance in ipairs(descendants) do
        if i % 1000 == 0 then task.wait() end 
        pcall(function()
            if instance:IsA("ParticleEmitter") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Fire") then
                instance.Enabled = false
                instance:Destroy()
            elseif instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("SurfaceAppearance") or instance:IsA("MaterialVariant") then
                instance:Destroy()
            elseif instance:IsA("BasePart") then
                instance.CastShadow = false
                instance.Material = Enum.Material.SmoothPlastic
                instance.Reflectance = 0
                if instance:IsA("MeshPart") then
                    pcall(function() instance.RenderFidelity = Enum.RenderFidelity.Performance end)
                end
            end
        end)
    end
    
    pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalThrottle.Enabled end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end

return Utilities
