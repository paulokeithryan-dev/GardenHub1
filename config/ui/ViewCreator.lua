-- =====================================================================
-- VIEW CREATOR - UI component creation (toggles, inputs, dropdowns, etc)
-- =====================================================================

local ViewCreator = {}

local ToggleRegistry = {}
ViewCreator.ToggleRegistry = ToggleRegistry

function ViewCreator.SetupCanvas(titleName, viewContainer)
    local ViewFrame = Instance.new("Frame")
    ViewFrame.Size = UDim2.new(1, 0, 1, 0)
    ViewFrame.BackgroundTransparency = 1
    ViewFrame.Visible = false
    ViewFrame.Parent = viewContainer
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -40, 0, 32)
    HeaderTitle.Position = UDim2.new(0, 0, 0, 5)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = titleName
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.TextSize = 22
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = ViewFrame
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, -45)
    Scroll.Position = UDim2.new(0, 0, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 70)
    Scroll.Active = true 
    Scroll.Parent = ViewFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.Parent = Scroll
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
    end)
    
    return ViewFrame, Scroll
end

function ViewCreator.AddSectionHeader(scrollTarget, text)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, -8, 0, 24)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = scrollTarget
    
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, 0, 1, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = "— [ " .. text .. " ] —"
    HeaderLabel.TextColor3 = Color3.fromRGB(180, 75, 75)
    HeaderLabel.TextSize = 12
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = SectionFrame
end

function ViewCreator.AddToggleCard(scrollTarget, labelText, checkState, onClickEvent, registryKey)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -8, 0, 42)
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    Card.BorderSizePixel = 0
    Card.Active = true 
    Card.Parent = scrollTarget
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(0.7, 0, 1, 0)
    CardTitle.Position = UDim2.new(0, 12, 0, 0)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = labelText
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
    CardTitle.TextSize = 13
    CardTitle.Font = Enum.Font.GothamMedium
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card
    
    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Size = UDim2.new(0, 42, 0, 20)
    ToggleFrame.Position = UDim2.new(1, -54, 0.5, -10)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
    ToggleFrame.Text = ""
    ToggleFrame.Parent = Card
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleFrame
    
    local SliderDot = Instance.new("Frame")
    SliderDot.Size = UDim2.new(0, 14, 0, 14)
    SliderDot.Position = UDim2.new(0, 3, 0.5, -7)
    SliderDot.BackgroundColor3 = Color3.fromRGB(150, 150, 155)
    SliderDot.BorderSizePixel = 0
    SliderDot.Parent = ToggleFrame
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = SliderDot
    
    local currentState = checkState
    local function updateVisuals(enabled)
        currentState = enabled
        if enabled then
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
            SliderDot.Position = UDim2.new(1, -17, 0.5, -7)
            SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
            SliderDot.Position = UDim2.new(0, 3, 0.5, -7)
            SliderDot.BackgroundColor3 = Color3.fromRGB(150, 150, 155)
        end
    end
    
    if registryKey then ToggleRegistry[registryKey] = updateVisuals end
    updateVisuals(currentState)
    
    ToggleFrame.MouseButton1Click:Connect(function()
        currentState = not currentState
        updateVisuals(currentState)
        onClickEvent(currentState)
    end)
end

function ViewCreator.AddActionCard(scrollTarget, labelText, buttonText, onClickEvent)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -8, 0, 42)
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    Card.BorderSizePixel = 0
    Card.Active = true 
    Card.Parent = scrollTarget
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(0.6, 0, 1, 0)
    CardTitle.Position = UDim2.new(0, 12, 0, 0)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = labelText
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
    CardTitle.TextSize = 13
    CardTitle.Font = Enum.Font.GothamMedium
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card
    
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 70, 0, 24)
    ActionBtn.Position = UDim2.new(1, -82, 0.5, -12)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
    ActionBtn.Text = buttonText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.TextSize = 10
    ActionBtn.Parent = Card
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ActionBtn
    
    ActionBtn.MouseButton1Click:Connect(onClickEvent)
end

function ViewCreator.AddInputCard(scrollTarget, labelText, defaultText, onTextChange, registryKey)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -8, 0, 42)
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    Card.BorderSizePixel = 0
    Card.Active = true 
    Card.Parent = scrollTarget
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(0.5, 0, 1, 0)
    CardTitle.Position = UDim2.new(0, 12, 0, 0)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = labelText
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
    CardTitle.TextSize = 13
    CardTitle.Font = Enum.Font.GothamMedium
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.42, 0, 0, 26)
    TextBox.Position = UDim2.new(1, -192, 0.5, -13)
    TextBox.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
    TextBox.Text = defaultText or ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderText = "..."
    TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 105)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 12
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = Card
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = TextBox
    
    local function updateVisuals(txt)
        TextBox.Text = tostring(txt)
    end
    if registryKey then ToggleRegistry[registryKey] = updateVisuals end
    
    TextBox.FocusLost:Connect(function() onTextChange(TextBox.Text) end)
end

function ViewCreator.AddSingleDropdownCard(scrollTarget, labelText, defaultText, optionsList, onSelect, registryKey)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -8, 0, 42)
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    Card.BorderSizePixel = 0
    Card.Active = true 
    Card.Parent = scrollTarget
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(0.5, 0, 1, 0)
    CardTitle.Position = UDim2.new(0, 12, 0, 0)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = labelText
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
    CardTitle.TextSize = 13
    CardTitle.Font = Enum.Font.GothamMedium
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0.42, 0, 0, 26)
    DropdownBtn.Position = UDim2.new(1, -192, 0.5, -13)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
    DropdownBtn.Text = defaultText or "Select Option"
    DropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.TextSize = 12
    DropdownBtn.TextTruncate = Enum.TextTruncate.AtEnd
    DropdownBtn.Parent = Card
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = DropdownBtn
    
    local DropdownList = Instance.new("ScrollingFrame")
    DropdownList.Size = UDim2.new(0, 180, 0, 120)
    DropdownList.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    DropdownList.BorderSizePixel = 0
    DropdownList.ScrollBarThickness = 4
    DropdownList.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 75)
    DropdownList.Visible = false
    DropdownList.ZIndex = 5000
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList
    
    local ListStroke = Instance.new("UIStroke")
    ListStroke.Color = Color3.fromRGB(48, 48, 54)
    ListStroke.Thickness = 1
    ListStroke.Parent = DropdownList

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.Parent = DropdownList
    
    task.spawn(function()
        local screenGui = scrollTarget:FindFirstAncestorOfClass("ScreenGui")
        while not screenGui do
            task.wait(0.1)
            screenGui = scrollTarget:FindFirstAncestorOfClass("ScreenGui")
        end
        DropdownList.Parent = screenGui
    end)
    
    local isOpen = false
    local function toggleDropdown()
        isOpen = not isOpen
        if isOpen then
            DropdownList.Position = UDim2.new(0, DropdownBtn.AbsolutePosition.X, 0, DropdownBtn.AbsolutePosition.Y + DropdownBtn.AbsoluteSize.Y + 3)
            DropdownList.Size = UDim2.new(0, DropdownBtn.AbsoluteSize.X, 0, math.min(#optionsList * 26 + 4, 150))
            DropdownList.Visible = true
        else
            DropdownList.Visible = false
        end
    end
    
    DropdownBtn.MouseButton1Click:Connect(toggleDropdown)
    DropdownBtn:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if isOpen then
            DropdownList.Position = UDim2.new(0, DropdownBtn.AbsolutePosition.X, 0, DropdownBtn.AbsolutePosition.Y + DropdownBtn.AbsoluteSize.Y + 3)
        end
    end)
    
    local currentSelection = defaultText
    local optionVisualUpdaters = {}
    
    local function updateMainButtonText()
        DropdownBtn.Text = currentSelection or "Select Option"
        onSelect(currentSelection)
    end
    
    local function externalUpdateHandler(val)
        currentSelection = val
        for _, updater in pairs(optionVisualUpdaters) do updater() end
        DropdownBtn.Text = currentSelection or "Select Option"
    end
    
    if registryKey then ToggleRegistry[registryKey] = externalUpdateHandler end
    
    for i, option in ipairs(optionsList) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 26)
        OptBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        OptBtn.BorderSizePixel = 0
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 12
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.LayoutOrder = i
        OptBtn.ZIndex = 5001
        OptBtn.Parent = DropdownList
        
        optionVisualUpdaters[option] = function()
            if currentSelection == option then
                OptBtn.Text = "  ✓  " .. option
                OptBtn.TextColor3 = Color3.fromRGB(100, 255, 150)
            else
                OptBtn.Text = "      " .. option
                OptBtn.TextColor3 = Color3.fromRGB(190, 190, 195)
            end
        end
        optionVisualUpdaters[option]()
        
        OptBtn.MouseEnter:Connect(function() OptBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 44) end)
        OptBtn.MouseLeave:Connect(function() OptBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32) end)
        
        OptBtn.MouseButton1Click:Connect(function()
            currentSelection = option
            for _, updater in pairs(optionVisualUpdaters) do updater() end
            updateMainButtonText()
            toggleDropdown()
        end)
    end
    updateMainButtonText()
end

return ViewCreator
