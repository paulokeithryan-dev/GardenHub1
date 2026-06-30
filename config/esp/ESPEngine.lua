-- =====================================================================
-- ESP ENGINE - Visual rendering for pets
-- =====================================================================

local ESPEngine = {}
ESPEngine.__index = ESPEngine

function ESPEngine.new(config, database, rarityColors)
    local self = setmetatable({}, ESPEngine)
    
    self.Config = config
    self.Database = database
    self.RarityHexColors = rarityColors
    self.ActiveESP = {}
    self.ESPCache = { Pets = {}, Rarities = {}, Sizes = {} }
    
    return self
end

function ESPEngine:updateCache(cacheType, commaStr)
    self.ESPCache[cacheType] = {}
    if commaStr and commaStr ~= "None" and commaStr ~= "Select Options" and commaStr ~= "" then
        for token in string.gmatch(commaStr, "[^,%s]+") do
            local cleanToken = string.lower(string.gsub(token, "%s+", ""))
            self.ESPCache[cacheType][cleanToken] = true
        end
    end
end

function ESPEngine:clearAllESP()
    for model, elements in pairs(self.ActiveESP) do
        for _, obj in ipairs(elements) do
            pcall(function() obj:Destroy() end)
        end
    end
    table.clear(self.ActiveESP)
end

function ESPEngine:renderESPForModel(petModel)
    if not self.Config.ESPEnabled then return end
    if not petModel:FindFirstChild("RootPart") then return end
    if self.ActiveESP[petModel] then return end
    
    local petName = petModel:GetAttribute("PetName") or petModel.Name
    local cleanName = string.gsub(petName, "%s+", "")
    
    if next(self.ESPCache.Pets) then
        if not self.ESPCache.Pets[string.lower(cleanName)] and not self.ESPCache.Pets[string.lower(string.gsub(petName, "%s+", ""))] then 
            return 
        end
    end
    
    local petRarity = "Unknown"
    for _, item in ipairs(self.Database) do
        local targetKey = item[2]
        if not item[3] then targetKey = item[1] end
        if string.gsub(targetKey, "%s+", "") == cleanName then
            petRarity = string.match(item[2] or item[3] or "", "^%a+") or "Unknown"
            break
        end
    end
    
    if next(self.ESPCache.Rarities) then
        if not self.ESPCache.Rarities[string.lower(petRarity)] then 
            return 
        end
    end
    
    local rawSize = petModel:GetAttribute("PetSize") or petModel:GetAttribute("Size") or "Normal"
    if next(self.ESPCache.Sizes) then
        if not self.ESPCache.Sizes[string.lower(tostring(rawSize))] then 
            return 
        end
    end
    
    local chosenHex = self.RarityHexColors[petRarity] or "#FFFFFF"
    local trackedElements = {}
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 160, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.Adornee = petModel.RootPart
    billboard.Parent = petModel.RootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.RichText = true
    textLabel.Text = string.format("<font color=\"%s\">%s</font> <font color=\"%s\">[%s]</font>", "#FFFFFF", petName, chosenHex, petRarity)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 12
    textLabel.TextStrokeTransparency = 0.4
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = billboard
    
    table.insert(trackedElements, billboard)
    self.ActiveESP[petModel] = trackedElements
end

function ESPEngine:startRenderLoop(workspace)
    task.spawn(function()
        while task.wait(0.4) do
            if self.Config.ESPEnabled then
                local mapFolder = workspace:FindFirstChild("Map")
                local wildFolder = mapFolder and mapFolder:FindFirstChild("WildPetSpawns")
                if wildFolder then
                    for cachedModel, instances in pairs(self.ActiveESP) do
                        if not cachedModel:IsDescendantOf(wildFolder) or not cachedModel:FindFirstChild("RootPart") then
                            for _, obj in ipairs(instances) do pcall(function() obj:Destroy() end) end
                            self.ActiveESP[cachedModel] = nil
                        end
                    end
                    for _, petModel in ipairs(wildFolder:GetChildren()) do
                        self:renderESPForModel(petModel)
                    end
                end
            else
                if next(self.ActiveESP) ~= nil then self:clearAllESP() end
            end
        end
    end)
end

return ESPEngine
