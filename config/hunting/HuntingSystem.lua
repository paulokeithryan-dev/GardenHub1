-- =====================================================================
-- HUNTING SYSTEM - Pet hunting core logic
-- =====================================================================

local HuntingSystem = {}
HuntingSystem.__index = HuntingSystem

function HuntingSystem.new(services, config)
    local self = setmetatable({}, HuntingSystem)
    
    self.Services = services
    self.Config = config
    self.activeTween = nil
    
    return self
end

function HuntingSystem:smoothFlyTo(targetCFrame, speedOverride)
    local character = self.Services.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not self.Config.PetHuntEnabled then return end
    
    if self.activeTween then pcall(function() self.activeTween:Cancel() end) end
    
    local speed = speedOverride or self.Config.TweenSpeed
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local flight = self.Services.TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    
    self.activeTween = flight
    flight:Play()
    flight.Completed:Wait()
    self.activeTween = nil
end

function HuntingSystem:executeDualActionStrike(shovel)
    local camera = workspace.CurrentCamera
    if camera then
        local safeX = 20
        local safeY = 220 
        self.Services.VirtualInputManager:SendMouseButtonEvent(safeX, safeY, 0, true, game, 0)
        self.Services.VirtualInputManager:SendMouseButtonEvent(safeX, safeY, 0, false, game, 0)
    end
    
    if shovel then
        shovel:Activate() 
        for _, obj in ipairs(shovel:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
                obj:FireServer() 
                obj:FireServer() 
            end
        end
    end
end

function HuntingSystem:executeInterceptionManeuver(thiefRoot, petRoot)
    local character = self.Services.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid or not self.Config.PetHuntEnabled then return end
    
    print("[TACTICAL]: Thief detected! Overriding velocity matrix to Max Combat Speed.")
    
    local shovel = character:FindFirstChild("Shovel") or self.Services.LocalPlayer.Backpack:FindFirstChild("Shovel")
    if shovel and shovel.Parent == self.Services.LocalPlayer.Backpack then
        humanoid:EquipTool(shovel)
        task.wait(0.02) 
    end
    
    local strikePosition = thiefRoot.CFrame * CFrame.new(0, 0, 1.2)
    self:smoothFlyTo(strikePosition, self.Config.CombatDashSpeed)
    
    if shovel and self.Config.PetHuntEnabled then
        for i = 1, 10 do
            self:executeDualActionStrike(shovel)
            task.wait() 
        end
    end
    
    if self.Config.PetHuntEnabled then
        local returnPosition = petRoot.CFrame * CFrame.new(0, self.Config.FlyHeight, 0)
        self:smoothFlyTo(returnPosition, self.Config.CombatDashSpeed)
    end
end

function HuntingSystem:deployPurchaseInterception(activeTarget, rootPart)
    if not fireproximityprompt then return end
    
    if activeTarget then
        for _, obj in ipairs(activeTarget:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj)
            end
        end
    end
    
    local gardens = workspace:FindFirstChild("Gardens")
    if gardens then
        for _, obj in ipairs(gardens:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                if obj:FindFirstAncestor("Signs") or string.find(obj.Name:lower(), "mailbox") or string.find(obj.Name:lower(), "sign") then
                    continue 
                end
                
                local parentPart = obj.Parent
                if parentPart and parentPart:IsA("BasePart") then
                    local distance = (parentPart.Position - rootPart.Position).Magnitude
                    if distance <= 20 then
                        fireproximityprompt(obj)
                    end
                end
            end
        end
    end
end

function HuntingSystem:startHuntingLoop(espEngine, serverHopper)
    task.spawn(function()
        local lastPromptCheck = 0
        local lastGardenClean = 0
        local isProcessingHopLifecycle = false
        
        local lastPathCompute = 0
        local walkWaypoints = {}
        local currentWPIndex = 1
        
        while task.wait(0.1) do
            if self.Config.PetHuntEnabled and not isProcessingHopLifecycle then
                local character = self.Services.LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                
                local mapFolder = workspace:FindFirstChild("Map")
                local wildFolder = mapFolder and mapFolder:FindFirstChild("WildPetSpawns")
                
                if rootPart and wildFolder and humanoid then
                    local activeTarget = nil
                    local scanAttempts = self.Config.ServerHopEnabled and 6 or 1
                    
                    for attempt = 1, scanAttempts do
                        for _, petModel in ipairs(wildFolder:GetChildren()) do
                            local attributeName = petModel:GetAttribute("PetName")
                            if attributeName then
                                local internalKey = string.gsub(attributeName, "%s+", "")
                                if (self.Config.TargetPets[attributeName] or self.Config.TargetPets[internalKey]) and petModel:FindFirstChild("RootPart") then
                                    activeTarget = petModel
                                    break
                                end
                            end
                        end
                        if activeTarget or not self.Config.ServerHopEnabled then break end
                        task.wait(0.5)
                    end
                    
                    if activeTarget then
                        self:executeHuntSequence(activeTarget, rootPart, humanoid, wildFolder, lastPromptCheck, isProcessingHopLifecycle, serverHopper)
                    elseif self.Config.ServerHopEnabled then
                        isProcessingHopLifecycle = true
                        print("[PET_FINDER]: Zero target signatures detected across map boundaries during this session cycle.")
                        serverHopper:rotateServerInstance()
                        isProcessingHopLifecycle = false
                    end
                end
            end
        end
    end)
end

function HuntingSystem:executeHuntSequence(activeTarget, rootPart, humanoid, wildFolder, lastPromptCheck, isProcessingHopLifecycle, serverHopper)
    local petRoot = activeTarget.RootPart
    local petName = activeTarget:GetAttribute("PetName") or activeTarget.Name
    print("[HUNTER]: Safe navigation tracking locked onto " .. tostring(petName))
    
    local character = self.Services.LocalPlayer.Character
    local shovel = character:FindFirstChild("Shovel") or self.Services.LocalPlayer.Backpack:FindFirstChild("Shovel")
    if shovel and shovel.Parent == self.Services.LocalPlayer.Backpack then
        humanoid:EquipTool(shovel)
        task.wait(0.1) 
    end
    
    local capturedSuccessfully = false
    
    while self.Config.PetHuntEnabled and activeTarget and activeTarget:IsDescendantOf(wildFolder) and petRoot do
        local closestThief = nil
        if self.Config.ProtectionEnabled then
            for _, player in ipairs(self.Services.Players:GetPlayers()) do
                if player ~= self.Services.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local playerRoot = player.Character.HumanoidRootPart
                    local distanceToPet = (playerRoot.Position - petRoot.Position).Magnitude
                    if distanceToPet <= self.Config.ProtectionRadius then
                        closestThief = playerRoot
                        break
                    end
                end
            end
        end
        
        if closestThief then
            self:executeInterceptionManeuver(closestThief, petRoot)
        else
            self:handleTeleportMode(rootPart, petRoot)
            
            if shovel and shovel.Parent == self.Services.LocalPlayer.Backpack then
                humanoid:EquipTool(shovel)
            end
        end
        
        if os.clock() - lastPromptCheck > 0.05 then
            lastPromptCheck = os.clock()
            self:deployPurchaseInterception(activeTarget, rootPart)
        end
        capturedSuccessfully = true
        task.wait()
    end
    
    self:deployPurchaseInterception(nil, rootPart)
    print("[HUNTER]: Target tracking concluded.")
    
    if capturedSuccessfully and self.Config.ServerHopEnabled and self.Config.PetHuntEnabled then
        isProcessingHopLifecycle = true
        print("[PET_FINDER]: Target signature captured! Enforcing 40-second static cooldown before initiating room rotation...")
        task.wait(40)
        if self.Config.PetHuntEnabled then serverHopper:rotateServerInstance() end
        isProcessingHopLifecycle = false
    end
end

function HuntingSystem:handleTeleportMode(rootPart, petRoot)
    if self.Config.TeleportMode == "Teleport" then
        rootPart.CFrame = petRoot.CFrame * CFrame.new(0, self.Config.FlyHeight, 0)
        
    elseif self.Config.TeleportMode == "Tween" then
        local dist = (rootPart.Position - (petRoot.Position + Vector3.new(0, self.Config.FlyHeight, 0))).Magnitude
        if dist > 5 then
            self:smoothFlyTo(petRoot.CFrame * CFrame.new(0, self.Config.FlyHeight, 0), self.Config.TweenSpeed)
        else
            rootPart.CFrame = petRoot.CFrame * CFrame.new(0, self.Config.FlyHeight, 0)
        end
    end
end

function HuntingSystem:stopCurrentTween()
    if self.activeTween then
        pcall(function() self.activeTween:Cancel() end)
        self.activeTween = nil
    end
end

return HuntingSystem
