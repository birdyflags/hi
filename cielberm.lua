-- Cielberm UI Library
-- A modern, feature-rich UI library for Roblox.
-- Author: AI Model
-- Version: 1.0

local cielberm = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    Colors = {
        Main = Color3.fromRGB(167, 139, 250), -- Soft Lavender
        Dark = Color3.fromRGB(30, 30, 40),
        Darkest = Color3.fromRGB(20, 20, 30),
        Light = Color3.fromRGB(220, 220, 230),
        Accent = Color3.fromRGB(139, 92, 246), -- A bit more purple
        Hover = Color3.fromRGB(147, 129, 255),
        Inactive = Color3.fromRGB(80, 80, 90),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68)
    },
    Icons = {
        -- You can expand this with your own uploaded Lucide icons (as rbxassetid://...)
        Home = "rbxassetid://7734058118",
        Settings = "rbxassetid://7734060370",
        User = "rbxassetid://7734058113",
        Palette = "rbxassetid://7734062749",
        Zap = "rbxassetid://7734058132",
        Box = "rbxassetid://7734058158",
        List = "rbxassetid://7734060439",
        Keyboard = "rbxassetid://7734060173",
        Type = "rbxassetid://7734059819",
        Minus = "rbxassetid://7734059896"
    }
}

-- Utility Functions
local function Create(Class, Properties)
    local Object = Instance.new(Class)
    for Property, Value in pairs(Properties) do
        Object[Property] = Value
    end
    return Object
end

local function MakeDraggable(GUI, Object)
    local Dragging = false
    local DragStart = nil
    local StartPosition = nil

    Object.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = GUI.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            local NewPos = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            TweenService:Create(GUI, TweenInfo.new(0.15), {Position = NewPos}):Play()
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end

-- Main Library Functions
function cielberm:CreateWindow(Options)
    Options = Options or {}
    local Title = Options.Title or "Cielberm UI"
    local Logo = Options.Logo or nil
    local Size = Options.Size or UDim2.new(0, 550, 0, 400)
    local CornerSize = 12

    local ScreenGui = Create("ScreenGui", {
        Name = "CielbermUI",
        Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Config.Colors.Darkest,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2),
        Size = Size,
        BackgroundTransparency = 0.2 -- 20% transparency
    })
    Create("UICorner", { CornerRadius = UDim.new(0, CornerSize), Parent = MainFrame })
    Create("UIStroke", { Color = Config.Colors.Main, Thickness = 1, Transparency = 0.5, Parent = MainFrame })
    
    -- Blur Effect
    local Blur = Create("Frame", {
        Name = "Blur",
        Parent = MainFrame,
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, CornerSize), Parent = Blur })
    local BlurEffect = Create("BlurEffect", { Parent = Blur, Size = 15, Enabled = true })

    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = Config.Colors.Main,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, CornerSize), Parent = TitleBar })
    
    local TitleBarPadding = Create("UIPadding", { Parent = TitleBar, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local LogoHolder = Create("ImageLabel", {
        Name = "Logo",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Image = Logo or "rbxassetid://7734058118",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(0, 0, 0.5, -12)
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Logo and 35 or 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = Title,
        TextColor3 = Config.Colors.Light,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.Gotham,
        Text = "×",
        TextColor3 = Config.Colors.Light,
        TextSize = 20
    })
    
    local Content = Create("Frame", {
        Name = "Content",
        Parent = MainFrame,
        BackgroundColor3 = Config.Colors.Darkest,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -35)
    })

    local Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",
        Parent = Content,
        BackgroundColor3 = Config.Colors.Dark,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Colors.Main
    })
    Create("UIListLayout", { Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
    Create("UIPadding", { Parent = Sidebar, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = Content,
        BackgroundColor3 = Config.Colors.Darkest,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 1, 0)
    })

    MakeDraggable(MainFrame, TitleBar)
    CloseButton.MouseEnter:Connect(function() TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Config.Colors.Error}):Play() end)
    CloseButton.MouseLeave:Connect(function() TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Config.Colors.Light}):Play() end)
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Window = {
        Gui = ScreenGui,
        MainFrame = MainFrame,
        Sidebar = Sidebar,
        TabContainer = TabContainer,
        Tabs = {},
        SelectedTab = nil
    }

    function Window:CreateTab(Options)
        Options = Options or {}
        local Title = Options.Title or "New Tab"
        local Icon = Options.Icon and Config.Icons[Options.Icon] or nil

        local TabButton = Create("TextButton", {
            Name = Title,
            Parent = self.Sidebar,
            BackgroundColor3 = Config.Colors.Inactive,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = "  " .. Title,
            TextColor3 = Config.Colors.Light,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabButton })
        if Icon then
            TabButton.Text = "      " .. Title
            Create("ImageLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Image = Icon,
                ImageTransparency = 0.2,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 8, 0.5, -8)
            })
        end

        local TabPage = Create("ScrollingFrame", {
            Name = Title,
            Parent = self.TabContainer,
            BackgroundColor3 = Config.Colors.Darkest,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Config.Colors.Main
        })
        Create("UIListLayout", { Parent = TabPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
        Create("UIPadding", { Parent = TabPage, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })

        local Tab = {
            Button = TabButton,
            Page = TabPage,
            Window = self,
            Elements = {}
        }

        function Tab:Select()
            if self.Window.SelectedTab then
                self.Window.SelectedTab.Page.Visible = false
                TweenService:Create(self.Window.SelectedTab.Button, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.Inactive}):Play()
            end
            self.Page.Visible = true
            TweenService:Create(self.Button, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.Main}):Play()
            self.Window.SelectedTab = self
        end

        TabButton.MouseButton1Click:Connect(function() Tab:Select() end)
        TabButton.MouseEnter:Connect(function() if self.Window.SelectedTab ~= Tab then TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Hover}):Play() end end)
        TabButton.MouseLeave:Connect(function() if self.Window.SelectedTab ~= Tab then TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Inactive}):Play() end end)

        -- Component Creation Functions
        function Tab:AddButton(Options)
            Options = Options or {}
            local Title = Options.Title or "Button"
            local Callback = Options.Callback or function() end
            
            local Button = Create("TextButton", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Main,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.GothamSemibold,
                Text = Title,
                TextColor3 = Config.Colors.Light,
                TextSize = 13
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Button })
            
            Button.MouseButton1Click:Connect(Callback)
            Button.MouseEnter:Connect(function() TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Hover}):Play() end)
            Button.MouseLeave:Connect(function() TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Main}):Play() end)
            table.insert(self.Elements, Button)
            return Button
        end

        function Tab:AddToggle(Options)
            Options = Options or {}
            local Title = Options.Title or "Toggle"
            local Default = Options.Default or false
            local Callback = Options.Callback or function() end

            local Toggle = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Toggle })
            
            local Label = Create("TextLabel", {
                Parent = Toggle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title,
                TextColor3 = Config.Colors.Light,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ToggleButton = Create("TextButton", {
                Parent = Toggle,
                BackgroundColor3 = Config.Colors.Inactive,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -40, 0.5, -10),
                Size = UDim2.new(0, 35, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = "",
                TextSize = 14
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = ToggleButton })
            
            local ToggleInner = Create("Frame", {
                Parent = ToggleButton,
                BackgroundColor3 = Config.Colors.Light,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 2, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ToggleInner })

            local state = Default
            local function update()
                if state then
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Main}):Play()
                    TweenService:Create(ToggleInner, TweenInfo.new(0.2), {Position = UDim2.new(0, 21, 0.5, -6)}):Play()
                else
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Inactive}):Play()
                    TweenService:Create(ToggleInner, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6)}):Play()
                end
                Callback(state)
            end
            update()
            ToggleButton.MouseButton1Click:Connect(function() state = not state; update() end)
            table.insert(self.Elements, Toggle)
            return {Set = function(v) state = v; update() end, Get = function() return state end}
        end

        function Tab:AddSlider(Options)
            Options = Options or {}
            local Title = Options.Title or "Slider"
            local Min = Options.Min or 0
            local Max = Options.Max or 100
            local Default = Options.Default or 50
            local Callback = Options.Callback or function() end

            local Slider = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Slider })
            
            local Label = Create("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 0.5, 0),
                Font = Enum.Font.Gotham,
                Text = Title,
                TextColor3 = Config.Colors.Light,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 0),
                Size = UDim2.new(0, 40, 0.5, 0),
                Font = Enum.Font.Gotham,
                Text = tostring(Default),
                TextColor3 = Config.Colors.Main,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBar = Create("Frame", {
                Parent = Slider,
                BackgroundColor3 = Config.Colors.Inactive,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 1, -20),
                Size = UDim2.new(1, -20, 0, 8)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SliderBar })

            local SliderFill = Create("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Config.Colors.Main,
                BorderSizePixel = 0,
                Size = UDim2.fromScale((Default - Min) / (Max - Min), 1)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SliderFill })

            local SliderButton = Create("TextButton", {
                Parent = SliderBar,
                BackgroundColor3 = Config.Colors.Light,
                BorderSizePixel = 0,
                Position = UDim2.fromScale((Default - Min) / (Max - Min), 0),
                Size = UDim2.new(0, 16, 0, 16),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale((Default - Min) / (Max - Min), 0.5),
                Font = Enum.Font.SourceSans,
                Text = ""
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = SliderButton })
            
            local dragging = false
            local function update(input)
                local scale = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local value = math.floor(Min + (Max - Min) * scale)
                SliderFill:TweenSize(UDim2.fromScale(scale, 1), "Out", "Quad", 0.1, true)
                SliderButton:TweenPosition(UDim2.fromScale(scale, 0.5), "Out", "Quad", 0.1, true)
                ValueLabel.Text = tostring(value)
                Callback(value)
            end

            SliderButton.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            
            table.insert(self.Elements, Slider)
        end
        
        function Tab:AddDropdown(Options)
            Options = Options or {}
            local Title = Options.Title or "Dropdown"
            local List = Options.List or {"Option 1", "Option 2"}
            local Callback = Options.Callback or function() end
            local Default = Options.Default or List[1]

            local Dropdown = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Dropdown })
            
            local DropdownButton = Create("TextButton", {
                Parent = Dropdown,
                BackgroundColor3 = Config.Colors.Main,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "  " .. Title .. ": " .. Default,
                TextColor3 = Config.Colors.Light,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = DropdownButton })
            
            local isOpen = false
            local selected = Default
            
            local OptionContainer = Create("Frame", {
                Parent = Dropdown,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, #List * 25),
                Visible = false,
                ZIndex = 3
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = OptionContainer })
            Create("UIStroke", { Color = Config.Colors.Main, Thickness = 1, Parent = OptionContainer })
            Create("UIListLayout", { Parent = OptionContainer, SortOrder = Enum.SortOrder.LayoutOrder })

            for i, option in ipairs(List) do
                local OptionButton = Create("TextButton", {
                    Parent = OptionContainer,
                    BackgroundColor3 = Config.Colors.Dark,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. option,
                    TextColor3 = Config.Colors.Light,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = i,
                    ZIndex = 3
                })
                OptionButton.MouseButton1Click:Connect(function()
                    selected = option
                    DropdownButton.Text = "  " .. Title .. ": " .. selected
                    isOpen = false
                    OptionContainer.Visible = false
                    TweenService:Create(Dropdown, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                    Callback(selected)
                end)
                OptionButton.MouseEnter:Connect(function() TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Config.Colors.Main}):Play() end)
                OptionButton.MouseLeave:Connect(function() TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Config.Colors.Dark}):Play() end)
            end

            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                OptionContainer.Visible = isOpen
                if isOpen then
                    TweenService:Create(Dropdown, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30 + (#List * 25))}):Play()
                else
                    TweenService:Create(Dropdown, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                end
            end)
            
            table.insert(self.Elements, Dropdown)
        end

        function Tab:AddColorPicker(Options)
            Options = Options or {}
            local Title = Options.Title or "Color Picker"
            local Default = Options.Default or Color3.new(1, 1, 1)
            local Callback = Options.Callback or function() end
            
            local Picker = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Picker })
            
            local Label = Create("TextLabel", {
                Parent = Picker,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title,
                TextColor3 = Config.Colors.Light,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ColorPreview = Create("Frame", {
                Parent = Picker,
                BackgroundColor3 = Default,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -40, 0.5, -10),
                Size = UDim2.new(0, 30, 0, 20)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ColorPreview })
            Create("UIStroke", { Color = Config.Colors.Inactive, Parent = ColorPreview })

            local PickerPopup = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Darkest,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, -100, 0, 40),
                Size = UDim2.new(0, 200, 0, 180),
                Visible = false,
                ZIndex = 10
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = PickerPopup })
            Create("UIStroke", { Color = Config.Colors.Main, Parent = PickerPopup })
            
            local HueSlider = Create("Frame", {
                Parent = PickerPopup,
                BackgroundColor3 = Color3.new(1,0,0), -- Placeholder
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(0, 20, 0, 160)
            })
            local HueGradient = Create("UIGradient", {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                },
                Parent = HueSlider
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = HueSlider })
            
            local SatValSquare = Create("Frame", {
                Parent = PickerPopup,
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 40, 0, 10),
                Size = UDim2.new(0, 150, 0, 150)
            })
            local SatValGradient = Create("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))},
                Rotation = 90,
                Parent = SatValSquare
            })
            local BlackGradient = Create("Frame", {
                Parent = SatValSquare,
                BackgroundColor3 = Color3.new(0,0,0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0)
            })
            local BlackGradientObj = Create("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))},
                Parent = BlackGradient
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SatValSquare })

            local h, s, v = Color3.toHSV(Default)
            local function updateColor()
                local color = Color3.fromHSV(h, s, v)
                ColorPreview.BackgroundColor3 = color
                SatValGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 0, 1))}
                Callback(color)
            end
            updateColor()

            local open = false
            ColorPreview.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    open = not open
                    PickerPopup.Visible = open
                end
            end)

            local function closePopup()
                if open then
                    open = false
                    PickerPopup.Visible = false
                end
            end
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not (PickerPopup:IsDescendantOf(input.Target) or ColorPreview:IsDescendantOf(input.Target)) then
                    closePopup()
                end
            end)

            -- Hue Slider Logic
            local hueDragging = false
            HueSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end end)
            UserInputService.InputChanged:Connect(function(input)
                if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local y = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                    h = 1 - y
                    updateColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end end)

            -- Sat/Val Square Logic
            local satValDragging = false
            SatValSquare.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then satValDragging = true end end)
            UserInputService.InputChanged:Connect(function(input)
                if satValDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    s = math.clamp((input.Position.X - SatValSquare.AbsolutePosition.X) / SatValSquare.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - SatValSquare.AbsolutePosition.Y) / SatValSquare.AbsoluteSize.Y, 0, 1)
                    updateColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then satValDragging = false end end)

            table.insert(self.Elements, Picker)
        end

        function Tab:AddTextbox(Options)
            Options = Options or {}
            local Title = Options.Title or "Textbox"
            local Placeholder = Options.Placeholder or "Enter text..."
            local Callback = Options.Callback or function() end
            
            local Textbox = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Textbox })
            
            local Label = Create("TextLabel", {
                Parent = Textbox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.5, -10, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title,
                TextColor3 = Config.Colors.Light,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Box = Create("TextBox", {
                Parent = Textbox,
                BackgroundColor3 = Config.Colors.Darkest,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 5, 0.5, -10),
                Size = UDim2.new(0.5, -15, 0, 20),
                Font = Enum.Font.Gotham,
                PlaceholderText = Placeholder,
                Text = "",
                TextColor3 = Config.Colors.Light,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Center
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box })
            Create("UIStroke", { Color = Config.Colors.Inactive, Parent = Box })
            
            Box.FocusLost:Connect(function(enterPressed)
                Callback(Box.Text)
            end)
            
            table.insert(self.Elements, Textbox)
        end

        function Tab:AddKeybind(Options)
            Options = Options or {}
            local Title = Options.Title or "Keybind"
            local Default = Options.Default or Enum.KeyCode.Unknown
            local Callback = Options.Callback or function() end

            local Keybind = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Keybind })
            
            local Label = Create("TextLabel", {
                Parent = Keybind,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title,
                TextColor3 = Config.Colors.Light,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local KeyButton = Create("TextButton", {
                Parent = Keybind,
                BackgroundColor3 = Config.Colors.Main,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -90, 0.5, -10),
                Size = UDim2.new(0, 80, 0, 20),
                Font = Enum.Font.GothamSemibold,
                Text = Default.Name,
                TextColor3 = Config.Colors.Light,
                TextSize = 12
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = KeyButton })

            local bindedKey = Default
            local waitingForKey = false
            
            KeyButton.MouseButton1Click:Connect(function()
                waitingForKey = true
                KeyButton.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                    bindedKey = input.KeyCode
                    KeyButton.Text = bindedKey.Name
                    waitingForKey = false
                    Callback(bindedKey)
                end
            end)

            table.insert(self.Elements, Keybind)
            return {Set = function(key) bindedKey = key; KeyButton.Text = key.Name; Callback(bindedKey) end, Get = function() return bindedKey end}
        end

        function Tab:AddLabel(Options)
            Options = Options or {}
            local Text = Options.Text or "Label"
            
            local Label = Create("TextLabel", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamSemibold,
                Text = "  " .. Text,
                TextColor3 = Config.Colors.Main,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Label })
            table.insert(self.Elements, Label)
            return {Set = function(text) Label.Text = "  " .. text end}
        end

        function Tab:AddSeparator()
            local Separator = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Config.Colors.Inactive,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 1),
                Position = UDim2.new(0, 10, 0, 0)
            })
            table.insert(self.Elements, Separator)
        end

        table.insert(self.Window.Tabs, Tab)
        if #self.Window.Tabs == 1 then
            Tab:Select()
        end
        return Tab
    end

    return Window
end

return cielberm
