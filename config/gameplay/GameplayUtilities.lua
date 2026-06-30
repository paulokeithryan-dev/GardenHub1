-- =====================================================================
-- GAMEPLAY UTILITIES - Various gameplay enhancement features
-- =====================================================================

local GameplayUtilities = {}

function GameplayUtilities.startFullBrightLoop(config, lighting, originalSettings)
    task.spawn(function()
        while task.wait(1) do
            if config.FullBright then
                pcall(function()
                    lighting.Ambient = Color3.fromRGB(255, 255, 255)
                    lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
                    lighting.Brightness = 2
                end)
            else
                pcall(function()
                    lighting.Ambient = originalSettings.Ambient
                    lighting.ColorShift_Top = originalSettings.ColorShift_Top
                    lighting.Brightness = originalSettings.Brightness
                end)
            end
        end
    end)
end

function GameplayUtilities.startInfiniteZoomLoop(config, localPlayer)
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                if localPlayer then
                    localPlayer.CameraMaxZoomDistance = config.InfiniteZoom and 9e9 or 400
                end
            end)
        end
    end)
end

function GameplayUtilities.startAntiFlingLoop(config, players, localPlayer)
    task.spawn(function()
        while task.wait(0.1) do
            if config.AntiFling then
                pcall(function()
                    for _, player in ipairs(players:GetPlayers()) do
                        if player ~= localPlayer and player.Character then
                            for _, part in ipairs(player.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                    part.Velocity = Vector3.zero
                                    part.RotVelocity = Vector3.zero
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

function GameplayUtilities.startLessKnockbackLoop(config, localPlayer)
    task.spawn(function()
        while task.wait(0.05) do
            if config.LessKnockback and localPlayer.Character then
                pcall(function()
                    for _, child in ipairs(localPlayer.Character:GetDescendants()) do
                        if child:IsA("BodyVelocity") or child:IsA("LinearVelocity") or child:IsA("BodyForce") then
                            child:Destroy()
                        end
                    end
                    local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root and root.Velocity.Magnitude > 65 then
                        root.Velocity = root.Velocity.Unit * 15
                    end
                end)
            end
        end
    end)
end

function GameplayUtilities.startInstantPromptLoop(config, workspace)
    task.spawn(function()
        while task.wait(0.5) do
            if config.InstantPrompt then
                pcall(function()
                    for _, prompt in ipairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            prompt.HoldDuration = 0
                        end
                    end
                end)
            end
        end
    end)
    
    workspace.DescendantAdded:Connect(function(descendant)
        if config.InstantPrompt and descendant:IsA("ProximityPrompt") then
            pcall(function() descendant.HoldDuration = 0 end)
        end
    end)
end

function GameplayUtilities.startBypassGameplayPausedLoop(config, localPlayer, guiService)
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                guiService:SetGameplayPausedNotificationEnabled(not config.BypassGameplayPaused)
                if config.BypassGameplayPaused then
                    local pGui = localPlayer:FindFirstChildOfClass("PlayerGui")
                    if pGui then
                        for _, node in ipairs(pGui:GetDescendants()) do
                            if node:IsA("TextLabel") and (string.find(node.Text:lower(), "gameplay paused") or string.find(node.Text:lower(), "pausing")) then
                                local rootWindow = node.Parent
                                if rootWindow and rootWindow:IsA("Frame") then
                                    rootWindow.Visible = false
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

function GameplayUtilities.startProtectionLoop(config, localPlayer, players)
    task.spawn(function()
        while task.wait(0.02) do 
            if config.ProtectionEnabled then
                local character = localPlayer.Character
                local shovel = character and character:FindFirstChild("Shovel")
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if shovel and rootPart then
                    local playerNearby = false
                    for _, player in ipairs(players:GetPlayers()) do
                        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                            if dist <= (config.ProtectionRadius + 5) then
                                playerNearby = true
                                break
                            end
                        end
                    end
                    if playerNearby then
                        -- Fire shovel strikes here
                        -- This would call hunting system's executeDualActionStrike
                    end
                end
            end
        end
    end)
end

function GameplayUtilities.startSkipLoadingScreenLoop(config, localPlayer, workspace)
    task.spawn(function()
        while task.wait(0.2) do
            if config.SkipLoadingScreen then
                pcall(function()
                    local camera = workspace.CurrentCamera
                    if camera and camera.CameraType == Enum.CameraType.Scriptable then
                        local isTrapped = false
                        local searchRoot = workspace:FindFirstChild("Gardens")
                        if searchRoot then
                            for _, item in ipairs(searchRoot:GetDescendants()) do
                                if (item.Name == "LoadingScreenCam" or item.Name == "LoadingCam") and item:IsA("BasePart") then
                                    if (camera.CFrame.Position - item.Position).Magnitude < 10 then
                                        isTrapped = true
                                        break
                                    end
                                end
                            end
                        end
                        if isTrapped then
                            camera.CameraType = Enum.CameraType.Custom
                            local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hum then camera.CameraSubject = hum end
                        end
                    end

                    local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
                    if playerGui then
                        for _, element in ipairs(playerGui:GetChildren()) do
                            if element:IsA("ScreenGui") and element.Enabled then
                                local nameLower = string.lower(element.Name)
                                if string.find(nameLower, "loading") or string.find(nameLower, "intro") or string.find(nameLower, "transition") then
                                    element.Enabled = false
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

return GameplayUtilities
