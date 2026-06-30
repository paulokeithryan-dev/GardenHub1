-- =====================================================================
-- SIDEBAR - Navigation and tab management
-- =====================================================================

local Sidebar = {}
Sidebar.__index = Sidebar

function Sidebar.new(sidebarFrame)
    local self = setmetatable({}, Sidebar)
    self.Buttons = {}
    self.Tabs = {}
    
    local SearchBox = Instance.new("Frame")
    SearchBox.Size = UDim2.new(1, -16, 0, 32)
    SearchBox.Position = UDim2.new(0, 8, 0, 12)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = sidebarFrame
    
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox
    
    local SearchText = Instance.new("TextLabel")
    SearchText.Size = UDim2.new(1, -10, 1, 0)
    SearchText.Position = UDim2.new(0, 10, 0, 0)
    SearchText.BackgroundTransparency = 1
    SearchText.Text = "🔍 Search"
    SearchText.TextColor3 = Color3.fromRGB(110, 110, 115)
    SearchText.TextSize = 12
    SearchText.Font = Enum.Font.Gotham
    SearchText.TextXAlignment = Enum.TextXAlignment.Left
    SearchText.Parent = SearchBox
    
    local ListContainer = Instance.new("Frame")
    ListContainer.Size = UDim2.new(1, 0, 1, -60)
    ListContainer.Position = UDim2.new(0, 0, 0, 55)
    ListContainer.BackgroundTransparency = 1
    ListContainer.Parent = sidebarFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 4)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListContainer
    
    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingLeft = UDim.new(0, 8)
    ListPadding.PaddingRight = UDim.new(0, 8)
    ListPadding.Parent = ListContainer
    
    self.Container = ListContainer
    return self
end

function Sidebar:RegisterTab(tabName, iconText, associatedViewFrame)
    local order = #self.Buttons + 1
    self.Tabs[tabName] = associatedViewFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    Btn.Text = "    " .. iconText .. "  " .. tabName
    Btn.TextColor3 = Color3.fromRGB(160, 160, 165)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = order
    Btn.Parent = self.Container
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    local ActiveStrip = Instance.new("Frame")
    ActiveStrip.Name = "ActiveStrip"
    ActiveStrip.Size = UDim2.new(0, 3, 0, 16)
    ActiveStrip.Position = UDim2.new(0, 6, 0.5, -8)
    ActiveStrip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ActiveStrip.BorderSizePixel = 0
    ActiveStrip.Visible = false
    ActiveStrip.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        for name, view in pairs(self.Tabs) do view.Visible = (name == tabName) end
        for _, otherBtn in pairs(self.Buttons) do
            otherBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
            otherBtn.TextColor3 = Color3.fromRGB(160, 160, 165)
            local strip = otherBtn:FindFirstChild("ActiveStrip")
            if strip then strip.Visible = false end
        end
        Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActiveStrip.Visible = true
    end)
    
    table.insert(self.Buttons, Btn)
    
    if order == 1 then
        associatedViewFrame.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActiveStrip.Visible = true
    else
        associatedViewFrame.Visible = false
    end
end

return Sidebar
