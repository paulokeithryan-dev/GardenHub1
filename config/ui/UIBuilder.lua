-- =====================================================================
-- UI BUILDER - Core UI component creation
-- =====================================================================

local UIBuilder = {}
UIBuilder.__index = UIBuilder

function UIBuilder.new()
    local self = setmetatable({}, UIBuilder)
    
    local targetParent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    if targetParent:FindFirstChild("SleekPremiumUI") then targetParent.SleekPremiumUI:Destroy() end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SleekPremiumUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = targetParent
    
    self.MainWindow = Instance.new("Frame")
    self.MainWindow.Size = UDim2.new(0, 580, 0, 380)
    self.MainWindow.Position = UDim2.new(0.5, -290, 0.5, -190)
    self.MainWindow.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    self.MainWindow.BorderSizePixel = 0
    self.MainWindow.Active = true
    self.MainWindow.Parent = self.ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = self.MainWindow
    
    self.DragBar = Instance.new("Frame")
    self.DragBar.Name = "DragHeader"
    self.DragBar.Size = UDim2.new(1, 0, 0, 35)
    self.DragBar.BackgroundTransparency = 1
    self.DragBar.Parent = self.MainWindow

    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 150, 1, 0)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.MainWindow
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = self.Sidebar
    
    local SidebarFix = Instance.new("Frame")
    SidebarFix.Size = UDim2.new(0, 20, 1, 0)
    SidebarFix.Position = UDim2.new(1, -20, 0, 0)
    SidebarFix.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    SidebarFix.BorderSizePixel = 0
    SidebarFix.Parent = self.Sidebar
    
    self.ViewContainer = Instance.new("Frame")
    self.ViewContainer.Size = UDim2.new(1, -170, 1, -20)
    self.ViewContainer.Position = UDim2.new(0, 160, 0, 10)
    self.ViewContainer.BackgroundTransparency = 1
    self.ViewContainer.Parent = self.MainWindow
    
    self:setupDragSystem()
    self:setupMinimizeButton()
    
    return self
end

function UIBuilder:setupDragSystem()
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput, dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        self.MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    self.DragBar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if UserInputService:GetFocusedTextBox() then return end
            dragging = true
            dragStart = input.Position
            startPos = self.MainWindow.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.DragBar.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
end

function UIBuilder:setupMinimizeButton()
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    MinimizeBtn.Position = UDim2.new(1, -34, 0, 8)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 205)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 12
    MinimizeBtn.ZIndex = 100
    MinimizeBtn.Parent = self.MainWindow

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinimizeBtn

    local RestoreBtn = Instance.new("TextButton")
    RestoreBtn.Size = UDim2.new(0, 85, 0, 30)
    RestoreBtn.Position = UDim2.new(0, 15, 0, 15)
    RestoreBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    RestoreBtn.Text = "Open UI"
    RestoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RestoreBtn.Font = Enum.Font.GothamMedium
    RestoreBtn.TextSize = 12
    RestoreBtn.Visible = false
    RestoreBtn.ZIndex = 100000 
    RestoreBtn.Parent = self.ScreenGui

    local RestoreCorner = Instance.new("UICorner")
    RestoreCorner.CornerRadius = UDim.new(0, 6)
    RestoreCorner.Parent = RestoreBtn

    local RestoreStroke = Instance.new("UIStroke")
    RestoreStroke.Color = Color3.fromRGB(45, 45, 48)
    RestoreStroke.Thickness = 1
    RestoreStroke.Parent = RestoreBtn

    MinimizeBtn.MouseButton1Click:Connect(function()
        self.MainWindow.Visible = false
        RestoreBtn.Visible = true
    end)

    RestoreBtn.MouseButton1Click:Connect(function()
        self.MainWindow.Visible = true
        RestoreBtn.Visible = false
    end)
end

return UIBuilder
