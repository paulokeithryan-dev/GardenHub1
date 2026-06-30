-- =====================================================================
-- SERVICE MANAGER - Handles all Roblox services
-- =====================================================================

local Services = {}

function Services.initialize()
    local self = {
        TweenService = game:GetService("TweenService"),
        Players = game:GetService("Players"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
        Lighting = game:GetService("Lighting"),
        HttpService = game:GetService("HttpService"),
        GuiService = game:GetService("GuiService"),
        PathfindingService = game:GetService("PathfindingService"),
        TeleportService = game:GetService("TeleportService"),
        UserInputService = game:GetService("UserInputService"),
        
        LocalPlayer = game:GetService("Players").LocalPlayer,
        PLACE_ID = game.PlaceId,
        
        OriginalLightingSettings = {
            Ambient = game:GetService("Lighting").Ambient,
            ColorShift_Top = game:GetService("Lighting").ColorShift_Top,
            Brightness = game:GetService("Lighting").Brightness
        }
    }
    
    -- Setup teleport error handler
    self.TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == self.LocalPlayer then
            warn("[ALERT]: Teleport authorization failed: " .. tostring(errorMessage) .. ". Routing emergency fallback hop...")
            task.wait(1.5)
            pcall(function()
                self.TeleportService:Teleport(self.PLACE_ID, self.LocalPlayer)
            end)
        end
    end)
    
    return self
end

return Services
