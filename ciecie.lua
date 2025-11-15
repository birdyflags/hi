-- Cielberm UI Library - Redesigned
-- Modern Roblox Lua UI Library with Animated Sidebar & Beautiful Notifications
-- Version 2.0

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Cielberm = {}
Cielberm.__index = Cielberm

-- Default Theme Colors
local Theme = {
    Primary = Color3.fromRGB(180, 160, 255), -- Soft Lavender
    Secondary = Color3.fromRGB(140, 120, 220),
    Background = Color3.fromRGB(25, 25, 35),
    BackgroundTransparent = 0.8, -- 20% transparent
    Surface = Color3.fromRGB(35, 35, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 220),
    Success = Color3.fromRGB(100, 230, 150),
    Warning = Color3.fromRGB(255, 200, 100),
    Error = Color3.fromRGB(255, 120, 120),
    Info = Color3.fromRGB(100, 180, 255),
}

-- Lucide Icons (SVG-style Unicode representations)
local Icons = {
    Home = "🏠",
    Settings = "⚙️",
    User = "👤",
    Bell = "🔔",
    Search = "🔍",
    Plus = "➕",
    Minus = "➖",
    Check = "✓",
    X = "✕",
    Menu = "☰",
    ChevronRight = "›",
    ChevronLeft = "‹",
}

-- Animation Presets
local AnimationPresets = {
    Fast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

-- Create Blur Effect
local function CreateBlur(parent, intensity)
    local blur = Instance.new("BlurEffect")
    blur.Size = intensity or 20
    blur.Parent = parent
    return blur
end

-- Create Gradient
local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1 or Theme.Primary, color2 or Theme.Secondary)
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

-- Create Corner
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

-- Tween Function
local function Tween(object, properties, tweenInfo)
    local tween = TweenService:Create(object, tweenInfo or AnimationPresets.Medium, properties)
    tween:Play()
    return tween
end

-- Create Main Window
function Cielberm.new(config)
    local self = setmetatable({}, Cielberm)
    
    config = config or {}
    self.Title = config.Title or "Cielberm UI"
    self.SidebarWidth = config.SidebarWidth or 220
    self.MinimizedWidth = 60
    self.IsMinimized = false
    self.Tabs = {}
    self.CurrentTab = nil
    self.Notifications = {}
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CielbermUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Create Blur Background
    local blurFrame = Instance.new("Frame")
    blurFrame.Name = "BlurBackground"
    blurFrame.Size = UDim2.new(1, 0, 1, 0)
    blurFrame.Position = UDim2.new(0, 0, 0, 0)
    blurFrame.BackgroundColor3 = Theme.Background
    blurFrame.BackgroundTransparency = Theme.BackgroundTransparent
    blurFrame.BorderSizePixel = 0
    blurFrame.Parent = self.ScreenGui
    
    -- Add blur to game camera
    local camera = workspace.CurrentCamera
    CreateBlur(camera, 15)
    
    -- Create Main Container
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.85, 0, 0.85, 0)
    mainContainer.Position = UDim2.new(0.075, 0, 0.075, 0)
    mainContainer.BackgroundColor3 = Theme.Surface
    mainContainer.BackgroundTransparency = 0.1
    mainContainer.BorderSizePixel = 0
    mainContainer.Parent = blurFrame
    CreateCorner(mainContainer, 20)
    
    -- Add gradient to main container
    CreateGradient(mainContainer, Theme.Primary, Theme.Background, 135)
    
    -- Create Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, self.SidebarWidth, 1, 0)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 0)
    self.Sidebar.BackgroundColor3 = Theme.Background
    self.Sidebar.BackgroundTransparency = 0.2
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.ClipsDescendants = true
    self.Sidebar.Parent = mainContainer
    CreateCorner(self.Sidebar, 20)
    
    -- Sidebar Header
    local sidebarHeader = Instance.new("Frame")
    sidebarHeader.Name = "Header"
    sidebarHeader.Size = UDim2.new(1, 0, 0, 70)
    sidebarHeader.BackgroundColor3 = Theme.Surface
    sidebarHeader.BackgroundTransparency = 0.3
    sidebarHeader.BorderSizePixel = 0
    sidebarHeader.Parent = self.Sidebar
    
    -- Title Label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 20
    self.TitleLabel.TextColor3 = Theme.Text
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = sidebarHeader
    
    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 40, 0, 40)
    toggleButton.Position = UDim2.new(1, -55, 0.5, -20)
    toggleButton.BackgroundColor3 = Theme.Primary
    toggleButton.Text = Icons.ChevronLeft
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 24
    toggleButton.TextColor3 = Theme.Text
    toggleButton.Parent = sidebarHeader
    CreateCorner(toggleButton, 10)
    
    -- Toggle Button Click
    toggleButton.MouseButton1Click:Connect(function()
        self:ToggleSidebar()
    end)
    
    -- Tabs Container
    self.TabsContainer = Instance.new("ScrollingFrame")
    self.TabsContainer.Name = "TabsContainer"
    self.TabsContainer.Size = UDim2.new(1, 0, 1, -70)
    self.TabsContainer.Position = UDim2.new(0, 0, 0, 70)
    self.TabsContainer.BackgroundTransparency = 1
    self.TabsContainer.BorderSizePixel = 0
    self.TabsContainer.ScrollBarThickness = 4
    self.TabsContainer.ScrollBarImageColor3 = Theme.Primary
    self.TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabsContainer.Parent = self.Sidebar
    
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 8)
    tabsLayout.Parent = self.TabsContainer
    
    local tabsPadding = Instance.new("UIPadding")
    tabsPadding.PaddingTop = UDim.new(0, 15)
    tabsPadding.PaddingBottom = UDim.new(0, 15)
    tabsPadding.PaddingLeft = UDim.new(0, 10)
    tabsPadding.PaddingRight = UDim.new(0, 10)
    tabsPadding.Parent = self.TabsContainer
    
    -- Content Container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -self.SidebarWidth, 1, 0)
    self.ContentContainer.Position = UDim2.new(0, self.SidebarWidth, 0, 0)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = mainContainer
    
    -- Notification Container
    self.NotificationContainer = Instance.new("Frame")
    self.NotificationContainer.Name = "NotificationContainer"
    self.NotificationContainer.Size = UDim2.new(0, 350, 1, -40)
    self.NotificationContainer.Position = UDim2.new(1, -370, 0, 20)
    self.NotificationContainer.BackgroundTransparency = 1
    self.NotificationContainer.BorderSizePixel = 0
    self.NotificationContainer.Parent = self.ScreenGui
    
    local notifLayout = Instance.new("UIListLayout")
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Padding = UDim.new(0, 10)
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.Parent = self.NotificationContainer
    
    return self
end

-- Toggle Sidebar
function Cielberm:ToggleSidebar()
    self.IsMinimized = not self.IsMinimized
    local targetWidth = self.IsMinimized and self.MinimizedWidth or self.SidebarWidth
    
    Tween(self.Sidebar, {Size = UDim2.new(0, targetWidth, 1, 0)}, AnimationPresets.Spring)
    Tween(self.ContentContainer, {
        Size = UDim2.new(1, -targetWidth, 1, 0),
        Position = UDim2.new(0, targetWidth, 0, 0)
    }, AnimationPresets.Spring)
    
    -- Animate title opacity
    Tween(self.TitleLabel, {
        TextTransparency = self.IsMinimized and 1 or 0
    }, AnimationPresets.Fast)
end

-- Add Tab
function Cielberm:AddTab(config)
    config = config or {}
    local tabName = config.Name or "Tab"
    local tabIcon = config.Icon or Icons.Home
    
    local tab = {}
    tab.Name = tabName
    tab.Icon = tabIcon
    
    -- Create Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName
    tabButton.Size = UDim2.new(1, -10, 0, 45)
    tabButton.BackgroundColor3 = Theme.Surface
    tabButton.BackgroundTransparency = 0.5
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabsContainer
    CreateCorner(tabButton, 10)
    
    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = tabIcon
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 20
    iconLabel.TextColor3 = Theme.TextSecondary
    iconLabel.Parent = tabButton
    
    -- Text Label
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -60, 1, 0)
    textLabel.Position = UDim2.new(0, 50, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = tabName
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 15
    textLabel.TextColor3 = Theme.TextSecondary
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = tabButton
    
    -- Create Tab Content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = tabName .. "Content"
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 6
    tabContent.ScrollBarImageColor3 = Theme.Primary
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Visible = false
    tabContent.Parent = self.ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = tabContent
    
    -- Auto-resize canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    tab.Button = tabButton
    tab.Content = tabContent
    tab.Icon = iconLabel
    tab.Text = textLabel
    
    -- Tab Click Handler
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Hover Effects
    tabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tabButton, {BackgroundTransparency = 0.3}, AnimationPresets.Fast)
            Tween(iconLabel, {TextColor3 = Theme.Text}, AnimationPresets.Fast)
            Tween(textLabel, {TextColor3 = Theme.Text}, AnimationPresets.Fast)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tabButton, {BackgroundTransparency = 0.5}, AnimationPresets.Fast)
            Tween(iconLabel, {TextColor3 = Theme.TextSecondary}, AnimationPresets.Fast)
            Tween(textLabel, {TextColor3 = Theme.TextSecondary}, AnimationPresets.Fast)
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Auto-resize canvas
    self.TabsContainer.CanvasSize = UDim2.new(0, 0, 0, self.TabsContainer.UIListLayout.AbsoluteContentSize.Y + 30)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

-- Select Tab
function Cielberm:SelectTab(tab)
    -- Deselect all tabs
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        Tween(t.Button, {BackgroundTransparency = 0.5}, AnimationPresets.Fast)
        Tween(t.Icon, {TextColor3 = Theme.TextSecondary}, AnimationPresets.Fast)
        Tween(t.Text, {TextColor3 = Theme.TextSecondary}, AnimationPresets.Fast)
    end
    
    -- Select target tab
    self.CurrentTab = tab
    tab.Content.Visible = true
    Tween(tab.Button, {
        BackgroundTransparency = 0.1,
        BackgroundColor3 = Theme.Primary
    }, AnimationPresets.Spring)
    Tween(tab.Icon, {TextColor3 = Theme.Text}, AnimationPresets.Fast)
    Tween(tab.Text, {TextColor3 = Theme.Text}, AnimationPresets.Fast)
    
    -- Scale animation
    tab.Button.Size = UDim2.new(1, -10, 0, 45)
    Tween(tab.Button, {Size = UDim2.new(1, -5, 0, 48)}, AnimationPresets.Bounce)
end

-- Create Notification
function Cielberm:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 5
    local notifType = config.Type or "Info" -- Info, Success, Warning, Error
    
    -- Determine color based on type
    local typeColor = Theme.Info
    local typeIcon = Icons.Bell
    
    if notifType == "Success" then
        typeColor = Theme.Success
        typeIcon = Icons.Check
    elseif notifType == "Warning" then
        typeColor = Theme.Warning
        typeIcon = Icons.Bell
    elseif notifType == "Error" then
        typeColor = Theme.Error
        typeIcon = Icons.X
    end
    
    -- Create Notification Frame
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Theme.Surface
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = self.NotificationContainer
    CreateCorner(notif, 12)
    
    -- Add gradient
    CreateGradient(notif, typeColor, Theme.Background, 90)
    
    -- Add glow effect
    local stroke = Instance.new("UIStroke")
    stroke.Color = typeColor
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = notif
    
    -- Content Container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -20)
    content.Position = UDim2.new(0, 10, 0, 10)
    content.BackgroundTransparency = 1
    content.Parent = notif
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 5, 0, 5)
    icon.BackgroundTransparency = 1
    icon.Text = typeIcon
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 20
    icon.TextColor3 = typeColor
    icon.Parent = content
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 45, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = content
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -50, 0, 35)
    messageLabel.Position = UDim2.new(0, 45, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.TextColor3 = Theme.TextSecondary
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = content
    
    -- Calculate notification height
    local textHeight = math.max(70, messageLabel.TextBounds.Y + 45)
    
    -- Animate in
    Tween(notif, {Size = UDim2.new(1, 0, 0, textHeight)}, AnimationPresets.Spring)
    
    -- Rotate icon
    local rotation = 0
    local rotationTween = TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 360})
    rotationTween:Play()
    
    -- Auto dismiss
    task.delay(duration, function()
        if notif and notif.Parent then
            Tween(notif, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            }, AnimationPresets.Fast)
            
            Tween(stroke, {Transparency = 1}, AnimationPresets.Fast)
            
            task.wait(0.3)
            notif:Destroy()
        end
    end)
    
    return notif
end

-- Add Button
function Cielberm:AddButton(tab, config)
    config = config or {}
    local buttonText = config.Text or "Button"
    local callback = config.Callback or function() end
    
    local button = Instance.new("TextButton")
    button.Name = buttonText
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = Theme.Primary
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = buttonText
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.TextColor3 = Theme.Text
    button.AutoButtonColor = false
    button.Parent = tab.Content
    CreateCorner(button, 10)
    
    -- Gradient
    CreateGradient(button, Theme.Primary, Theme.Secondary, 45)
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        -- Scale animation
        Tween(button, {Size = UDim2.new(1, -20, 0, 38)}, AnimationPresets.Fast)
        task.wait(0.1)
        Tween(button, {Size = UDim2.new(1, -20, 0, 40)}, AnimationPresets.Bounce)
        
        callback()
    end)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundTransparency = 0}, AnimationPresets.Fast)
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundTransparency = 0.2}, AnimationPresets.Fast)
    end)
    
    return button
end

-- Add Toggle
function Cielberm:AddToggle(tab, config)
    config = config or {}
    local toggleText = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = toggleText
    toggleFrame.Size = UDim2.new(1, -20, 0, 40)
    toggleFrame.BackgroundColor3 = Theme.Surface
    toggleFrame.BackgroundTransparency = 0.3
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = tab.Content
    CreateCorner(toggleFrame, 10)
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = toggleText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 50, 0, 26)
    toggleButton.Position = UDim2.new(1, -60, 0.5, -13)
    toggleButton.BackgroundColor3 = default and Theme.Primary or Theme.Background
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = toggleFrame
    CreateCorner(toggleButton, 13)
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    indicator.BackgroundColor3 = Theme.Text
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleButton
    CreateCorner(indicator, 10)
    
    local isToggled = default
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        Tween(toggleButton, {
            BackgroundColor3 = isToggled and Theme.Primary or Theme.Background
        }, AnimationPresets.Medium)
        
        Tween(indicator, {
            Position = isToggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }, AnimationPresets.Spring)
        
        callback(isToggled)
    end)
    
    return toggleFrame
end

-- Add Slider
function Cielberm:AddSlider(tab, config)
    config = config or {}
    local sliderText = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = sliderText
    sliderFrame.Size = UDim2.new(1, -20, 0, 60)
    sliderFrame.BackgroundColor3 = Theme.Surface
    sliderFrame.BackgroundTransparency = 0.3
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = tab.Content
    CreateCorner(sliderFrame, 10)
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 0, 25)
    label.Position = UDim2.new(0, 15, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = sliderText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.3, -15, 0, 25)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = Theme.Primary
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "Bar"
    sliderBar.Size = UDim2.new(1, -30, 0, 6)
    sliderBar.Position = UDim2.new(0, 15, 1, -18)
    sliderBar.BackgroundColor3 = Theme.Background
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = sliderFrame
    CreateCorner(sliderBar, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    CreateCorner(sliderFill, 3)
    CreateGradient(sliderFill, Theme.Primary, Theme.Secondary, 90)
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        
        Tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, AnimationPresets.Fast)
        valueLabel.Text = tostring(value)
        
        callback(value)
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return sliderFrame
end

-- Add Label
function Cielberm:AddLabel(tab, config)
    config = config or {}
    local text = config.Text or "Label"
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.TextSecondary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = tab.Content
    
    return label
end

-- Destroy UI
function Cielberm:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return Cielberm
