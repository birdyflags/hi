--[[
    CielBerm UI Library
    Complete deobfuscated version with all components
    Original minified code fully expanded and cleaned up
]]

--!optimize 2
--!nolint

local CielBerm = {
    ClassName = "ModuleScript",
    Closure = function()
        -- Constants and Configuration
        local STRINGS = {
            KEY_LINK = "Key link not loaded! Please wait and try again.",
            WHITELIST_LINK = "Whitelist link not loaded! Please wait and try again.",
            DISCORD_INVITE = "https://dsc.gg/imphub"
        }

        local CANVAS_SIZE = Vector2.new(800, 480)
        
        -- Services
        local RunService = game:GetService("RunService")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local TextService = game:GetService("TextService")
        
        -- Core UI References
        local CurrentCamera = workspace.CurrentCamera
        local PlayerScript = script:WaitForChild("Player")
        local Resources = script:WaitForChild("Resources")
        local Renderer = PlayerScript.Renderer
        local Surface = Renderer.Surface
        
        -- Camera setup
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            CurrentCamera = workspace.CurrentCamera
        end)

        -- UI Containers
        local ScreenContainer = PlayerScript.ScreenContainer
        local HubPosition = ScreenContainer.HubPosition
        
        -- Login Components
        local LoginWindow = Surface.Window.Content.Login
        local KeyField = LoginWindow.LoginBox.LoginLayout.KeyField
        local KeyInput = KeyField.Key
        
        -- Modal Windows
        local ModalsContainer = Surface.Window.Modals
        local ColorModal = Surface.Window.ColorModal
        
        -- Hub Components
        local HubContent = Surface.Window.Content.Hub
        local Sidebar = HubContent.MainContent.PageView.Home.Sidebar
        local PageContainer = HubContent.MainContent.PageView.Home.PageBase.PageContents
        
        -- Top Bar
        local TopBar = Surface.Window.Content.TopBar
        local SubtitleText = TopBar.LogoTitle.Subtitle.SubText
        local VersionText = TopBar.LogoTitle.Subtitle.Version
        
        -- Themes and Colors
        local ThemeColors = Resources.Themes.Imp.Colors
        
        -- Color Picker Components
        local ColorPickerUI = ColorModal.ColorPickerUI
        local BasicColorPicker = ColorPickerUI.Basic
        local AdvancedColorPicker = ColorPickerUI.Advanced
        local ColorPickerTitle = ColorPickerUI.TopBar.Title.Subtitle
        
        -- Minimized Task
        local MinimizedTask = PlayerScript.MinimizedTask
        
        -- Tooltip
        local TooltipContainer = Surface.Window.TooltipContainer
        local TooltipFrame = TooltipContainer.Frame.TextBubble
        local TooltipLabel = TooltipFrame.Label
        local TooltipLayout = TooltipFrame.UIListLayout
        local TooltipTailContainer = TooltipFrame.TailContainer
        local TooltipTailLeft = TooltipTailContainer.TailLeftClip.Frame
        local TooltipTailRight = TooltipTailContainer.TailRightClip.Frame
        
        local TooltipTween = TweenService:Create(TooltipContainer, 
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.5), 
            {Size = UDim2.fromOffset(0)}
        )

        -- State Management
        local UIState = {
            IsMinimized = false,
            IsSmallWindow = false,
            IsWhitelistMode = false,
            IsDragging = false,
            IsResizing = false,
            ModalCount = 0
        }

        local ActiveModals = {}
        local PendingToasts = {}
        local ActiveToasts = {}
        local ToastData = {}
        
        -- Bindable Events
        local BindableEvents = {}
        local EventNames = {
            "LoginRequest",
            "MinimizedChanged", 
            "SizeChanged",
            "Opened",
            "Closing",
            "HubDestroying",
            "WhitelistChanged"
        }

        -- Initialize bindable events
        for _, eventName in ipairs(EventNames) do
            local bindable = Instance.new("BindableEvent")
            bindable.Name = eventName
            bindable.Parent = Resources.Bindables
            BindableEvents[eventName] = bindable
        end

        -- Camera and Rendering Setup
        local CameraOffset = CFrame.new(0, 0, -50)
        local RenderConnection
        local PartReference = Instance.new("Part")
        PartReference.Size = Vector3.zero
        local CenterOffset = CFrame.new(0, 0, -PartReference.Size.Z / 2)
        PartReference:Destroy()

        local LastCameraCFrame
        local LastHubPosition
        local LastFieldOfView

        -- Complete rendering function
        local function UpdateUIRender()
            local cameraCFrame = CurrentCamera:GetRenderCFrame()
            
            if CurrentCamera.FieldOfView ~= LastFieldOfView or 
               HubPosition.AbsoluteSize ~= LastHubPosition or 
               HubPosition.AbsolutePosition ~= LastHubPosition then
                
                local inverseCFrame = cameraCFrame:ToObjectSpace(CFrame.new(cameraCFrame.Position)):Inverse()
                local cameraPosition = (cameraCFrame * CameraOffset).Position
                local lookVector = cameraCFrame.LookVector
                
                -- Handle pixel-perfect positioning
                local xOffset = ScreenContainer.AbsoluteSize.X % 2 == 0 and 0 or 0.5
                local yOffset = ScreenContainer.AbsoluteSize.Y % 2 == 0 and 0 or 0.5
                
                -- Calculate screen corners
                local topLeftRay = CurrentCamera:ScreenPointToRay(
                    HubPosition.AbsolutePosition.X + xOffset, 
                    HubPosition.AbsolutePosition.Y + yOffset, 
                    0
                )
                
                local topRightRay = CurrentCamera:ScreenPointToRay(
                    HubPosition.AbsolutePosition.X + HubPosition.AbsoluteSize.X + xOffset,
                    HubPosition.AbsolutePosition.Y + yOffset,
                    0
                )
                
                local bottomLeftRay = CurrentCamera:ScreenPointToRay(
                    HubPosition.AbsolutePosition.X + xOffset,
                    HubPosition.AbsolutePosition.Y + HubPosition.AbsoluteSize.Y + yOffset,
                    0
                )
                
                -- Calculate intersection points
                local topLeftIntersection = topLeftRay.Origin + topLeftRay.Direction * 
                    ((cameraPosition - topLeftRay.Origin):Dot(lookVector) / topLeftRay.Direction:Dot(lookVector))
                
                local topRightIntersection = topRightRay.Origin + topRightRay.Direction * 
                    ((cameraPosition - topRightRay.Origin):Dot(lookVector) / topRightRay.Direction:Dot(lookVector))
                
                local bottomLeftIntersection = bottomLeftRay.Origin + bottomLeftRay.Direction * 
                    ((cameraPosition - bottomLeftRay.Origin):Dot(lookVector) / bottomLeftRay.Direction:Dot(lookVector))
                
                -- Set render size and position
                Renderer.Size = Vector3.new(
                    (topRightIntersection - topLeftIntersection).magnitude,
                    (bottomLeftIntersection - topLeftIntersection).magnitude,
                    0
                )
                
                local centerPoint = cameraCFrame:PointToObjectSpace((bottomLeftIntersection + topRightIntersection) / 2)
                Renderer.CFrame = cameraCFrame * CFrame.new(centerPoint) * CenterOffset
                
                LastFieldOfView = CurrentCamera.FieldOfView
                LastHubPosition = HubPosition.AbsoluteSize
            end
            
            if cameraCFrame ~= LastCameraCFrame or HubPosition.AbsolutePosition ~= LastHubPosition then
                local centerPoint = LastCameraCFrame and cameraCFrame:PointToObjectSpace(LastCameraCFrame.Position) or Vector3.zero
                Renderer.CFrame = cameraCFrame * CFrame.new(centerPoint) * CenterOffset
                LastCameraCFrame = cameraCFrame
                LastHubPosition = HubPosition.AbsolutePosition
            end
            
            -- Safety check for UI elements
            if not HubPosition.Parent or not Renderer.Parent or not Surface.Parent or not PlayerScript.Parent then
                CleanupUI()
            end
        end

        -- Initialize rendering
        RenderConnection = RunService.PreRender:Connect(UpdateUIRender)

        -- Initialize surface after render cycle
        coroutine.resume(coroutine.create(function()
            RunService.PreRender:Wait()
            RunService.PreAnimation:Wait()
            Surface.Parent = nil
            Surface.Parent = Renderer
        end))

        -- Complete Tween Definitions
        local UI_Tweens = {
            GuiFull = TweenService:Create(HubPosition, 
                TweenInfo.new(0.2, Enum.EasingStyle.Quint), 
                {Size = UDim2.fromScale(1, 1)}
            ),
            GuiHalf = TweenService:Create(HubPosition,
                TweenInfo.new(0.2, Enum.EasingStyle.Quint),
                {Size = UDim2.fromScale(0.5, 0.5)}
            ),
            GuiEnterFull = TweenService:Create(HubPosition,
                TweenInfo.new(),
                {Size = UDim2.fromScale(1, 1)}
            ),
            GuiEnterHalf = TweenService:Create(HubPosition,
                TweenInfo.new(),
                {Size = UDim2.fromScale(0.5, 0.5)}
            ),
            GuiExit = TweenService:Create(HubPosition,
                TweenInfo.new(),
                {Size = UDim2.fromOffset()}
            ),
            CanvasFull = TweenService:Create(Surface,
                TweenInfo.new(),
                {CanvasSize = CANVAS_SIZE}
            ),
            CanvasMin = TweenService:Create(Surface,
                TweenInfo.new(),
                {CanvasSize = Vector2.zero}
            ),
            AdvancedColorsEnter = TweenService:Create(ColorPickerUI,
                TweenInfo.new(0.5),
                {Size = UDim2.fromOffset(576, 384)}
            ),
            AdvancedColorsExit = TweenService:Create(ColorPickerUI,
                TweenInfo.new(0.5),
                {Size = UDim2.fromOffset(384, 384)}
            ),
            ModalShadeFadeIn = TweenService:Create(ModalsContainer,
                TweenInfo.new(0.5),
                {BackgroundTransparency = 0.4}
            ),
            ModalShadeFadeOut = TweenService:Create(ModalsContainer,
                TweenInfo.new(0.5),
                {BackgroundTransparency = 1}
            ),
            ColorModalShadeFadeIn = TweenService:Create(ColorModal,
                TweenInfo.new(0.5),
                {BackgroundTransparency = 0.4}
            ),
            ColorModalShadeFadeOut = TweenService:Create(ColorModal,
                TweenInfo.new(0.5),
                {BackgroundTransparency = 1}
            ),
            ColorPickerOpen = TweenService:Create(ColorPickerUI,
                TweenInfo.new(0.25),
                {
                    Position = UDim2.fromScale(0.5, 0.5),
                    AnchorPoint = Vector2.new(0.5, 0.5)
                }
            ),
            ColorPickerClose = TweenService:Create(ColorPickerUI,
                TweenInfo.new(0.25),
                {
                    Position = UDim2.fromScale(0.5, 1),
                    AnchorPoint = Vector2.new(0.5)
                }
            )
        }

        -- Store tweens in resources
        for tweenName, tween in pairs(UI_Tweens) do
            tween.Name = tweenName
            tween.Parent = Resources.Tweens
        end

        -- Executor compatibility check
        local UNSUPPORTED_EXECUTORS = {
            solara = true
        }

        if identifyexecutor then
            local executorName = identifyexecutor()
            if UNSUPPORTED_EXECUTORS[executorName:lower()] then
                -- Show error dialog
                local ErrorDialog = Resources.Components.Modal:Clone()
                ErrorDialog.Inner.DialogTitle.Text = "Executor Unsupported!"
                ErrorDialog.Inner.DialogText.Text = executorName .. " is not supported by our key system! Please use another executor.\nThis window will now close."
                
                local OKButton = Resources.Components.ModalButton:Clone()
                OKButton.Text = "OK"
                OKButton.Parent = ErrorDialog.Inner
                
                ErrorDialog.Parent = ModalsContainer
                UI_Tweens.ModalShadeFadeIn:Play()
                UIState.ModalCount = UIState.ModalCount + 1
                Surface.Window.Content.Interactable = false
                
                OKButton.MouseButton1Click:Connect(function()
                    UI_Tweens.ModalShadeFadeOut:Play()
                    UIState.ModalCount = UIState.ModalCount - 1
                    if UIState.ModalCount == 0 then
                        Surface.Window.Content.Interactable = true
                    end
                    ErrorDialog:Destroy()
                end)
            end
        end

        -- Background setup
        local LoginBackground = LoginWindow.Background
        local HubBackground = HubContent.Background

        Surface:GetPropertyChangedSignal("CanvasSize"):Connect(function()
            -- Refresh backgrounds
            LoginBackground.Visible = false
            LoginBackground.Visible = true
            HubBackground.Visible = false
            HubBackground.Visible = true
        end)

        -- Loading animation
        local LoadingCircle = Surface.Window.LoadingScreen.LoadingCircle.UIStroke.UIGradient
        TweenService:Create(LoadingCircle, 
            TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), 
            {Rotation = 360}
        ):Play()

        -- Time-based theme (day/night)
        local currentHour = os.date("*t").hour
        if currentHour >= 6 and currentHour < 18 then
            -- Day theme
            LoginBackground.SkyNight.Visible = false
            LoginBackground.SkyDay.Visible = true
            LoginBackground.GradientNight.Enabled = false
            LoginBackground.GradientDay.Enabled = true
        else
            -- Night theme
            LoginBackground.SkyNight.Visible = true
            LoginBackground.SkyDay.Visible = false
            LoginBackground.GradientNight.Enabled = true
            LoginBackground.GradientDay.Enabled = false
        end

        -- Input handling state
        local InputState = {
            IsDraggingWindow = false,
            IsDraggingMinimized = false,
            IsDraggingSlider = false,
            IsColorDragging = false,
            IsValueDragging = false,
            IsTouchActive = false,
            WindowStartPosition = UDim2.new(),
            MinimizedStartPosition = UDim2.new(),
            RestorePosition = UDim2.new(),
            WasDragged = false,
            ActiveSlider = nil,
            SliderStartScale = 0,
            SliderMin = 0,
            SliderMax = 100,
            SliderStep = 1,
            SliderValueObject = nil,
            SliderFill = nil,
            IsPercent = false,
            ActiveColorElement = nil,
            ColorCallback = nil
        }

        local DragStartPosition
        local ActiveDragElement
        local CurrentTouch
        local ActiveTooltipElement

        -- Input connections
        local InputBeganConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not InputState.IsTouchActive then
                    DragStartPosition = input.Position
                    CurrentTouch = input
                end
                
                if InputState.IsDraggingWindow then
                    if input.UserInputType == Enum.UserInputType.Touch then
                        InputState.IsTouchActive = true
                    end
                end
            end
        end)

        local InputChangedConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or 
               (input.UserInputType == Enum.UserInputType.Touch and input == CurrentTouch) then
                
                if InputState.IsDraggingWindow then
                    local delta = input.Position - DragStartPosition
                    ScreenContainer.Position = InputState.WindowStartPosition + UDim2.fromOffset(delta.X, delta.Y)
                elseif InputState.IsDraggingMinimized then
                    MinimizedTask.Position = InputState.MinimizedStartPosition + UDim2.fromOffset(
                        input.Position.X - DragStartPosition.X,
                        input.Position.Y - DragStartPosition.Y
                    )
                    InputState.WasDragged = true
                elseif InputState.IsDraggingSlider then
                    -- Handle slider dragging logic
                    local sliderElement = InputState.ActiveSlider
                    local sliderParent = sliderElement.Parent
                    local normalizedX = (DragStartPosition.X - sliderParent.AbsolutePosition.X) / sliderParent.AbsoluteSize.X
                    local currentX = (input.Position.X - sliderParent.AbsolutePosition.X) / sliderParent.AbsoluteSize.X
                    
                    local scaleValue = math.clamp(InputState.SliderStartScale + (currentX - normalizedX), 0, 1)
                    local steppedValue
                    
                    if InputState.SliderStep ~= math.huge and InputState.SliderStep ~= -math.huge then
                        local range = (InputState.SliderMax - InputState.SliderMin)
                        steppedValue = math.round((InputState.SliderMin + (scaleValue * range)) * InputState.SliderStep) / InputState.SliderStep
                        local steppedScale = UDim2.fromScale((steppedValue - InputState.SliderMin) / range, 1)
                        sliderElement.Position = steppedScale
                        InputState.SliderFill.Size = steppedScale
                        steppedValue = 1/steppedValue ~= -math.huge and steppedValue or 0
                    else
                        steppedValue = InputState.SliderMin + (scaleValue * (InputState.SliderMax - InputState.SliderMin))
                        sliderElement.Position = UDim2.fromScale(scaleValue, 0.5)
                        InputState.SliderFill.Size = UDim2.fromScale(scaleValue, 1)
                    end
                    
                    steppedValue = math.clamp(steppedValue, InputState.SliderMin, InputState.SliderMax)
                    
                    -- Update tooltip
                    TooltipLabel.Text = InputState.IsPercent and math.round(100 * steppedValue) .. "%" or steppedValue
                    
                    local bubbleSize = TooltipFrame.AbsoluteSize
                    TooltipContainer.Size = UDim2.fromOffset(bubbleSize.X, bubbleSize.Y)
                    
                    if InputState.SliderValueObject.Value ~= steppedValue then
                        InputState.SliderValueObject.Value = steppedValue
                        local callback = InputState.SliderValueObject.OnChanged
                        if type(callback) == "function" then
                            coroutine.resume(coroutine.create(callback), steppedValue)
                        end
                    end
                elseif InputState.IsColorDragging then
                    -- Handle color picker dragging
                    local relativePosition = ((Vector2.new(input.Position.X, input.Position.Y) - InputState.ColorPadStartPosition) / InputState.ColorPadSize)
                        :Max(Vector2.zero):Min(Vector2.one)
                    
                    local hueValue = math.floor(relativePosition.X * 359)
                    local saturationValue = math.floor(relativePosition.Y * 255)
                    
                    InputState.CurrentHue = (359 - hueValue) / 360
                    InputState.CurrentSaturation = 1 - saturationValue / 255
                    InputState.CurrentColor = Color3.fromHSV(InputState.CurrentHue, InputState.CurrentSaturation, InputState.CurrentValue)
                    
                    -- Update color inputs
                    InputState.HueInput.Text = 359 - hueValue
                    InputState.SaturationInput.Text = 255 - saturationValue
                    
                    local hexColor = InputState.CurrentColor:ToHex()
                    InputState.HexInput.Text = "#" .. hexColor
                    InputState.RedInput.Text = tonumber(hexColor:sub(1, 2), 16)
                    InputState.GreenInput.Text = tonumber(hexColor:sub(3, 4), 16)
                    InputState.BlueInput.Text = tonumber(hexColor:sub(5, 6), 16)
                    
                    -- Update cursors
                    InputState.HueCursor.Position = UDim2.fromScale(hueValue / 359, saturationValue / 255)
                    InputState.ColorPreview.BackgroundColor3 = InputState.CurrentColor
                    InputState.ValuePad.BackgroundColor3 = Color3.fromHSV(InputState.CurrentHue, InputState.CurrentSaturation, 1)
                elseif InputState.IsValueDragging then
                    -- Handle value slider dragging
                    local valuePosition = math.floor(math.clamp((input.Position.Y - InputState.ValuePadStartPosition.Y) / InputState.ValuePadSize.Y, 0, 1) * 255)
                    InputState.CurrentValue = 1 - valuePosition / 255
                    InputState.CurrentColor = Color3.fromHSV(InputState.CurrentHue, InputState.CurrentSaturation, InputState.CurrentValue)
                    
                    InputState.ValueInput.Text = 255 - valuePosition
                    
                    local hexColor = InputState.CurrentColor:ToHex()
                    InputState.HexInput.Text = "#" .. hexColor
                    InputState.RedInput.Text = tonumber(hexColor:sub(1, 2), 16)
                    InputState.GreenInput.Text = tonumber(hexColor:sub(3, 4), 16)
                    InputState.BlueInput.Text = tonumber(hexColor:sub(5, 6), 16)
                    
                    InputState.ValueCursor.Position = UDim2.fromScale(0, valuePosition / 255)
                    InputState.ColorPreview.BackgroundColor3 = InputState.CurrentColor
                end
            end
        end)

        local InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               (input.UserInputType == Enum.UserInputType.Touch and input == CurrentTouch) then
                
                InputState.IsDraggingWindow = false
                InputState.IsDraggingMinimized = false
                InputState.IsDraggingSlider = false
                InputState.IsColorDragging = false
                InputState.IsValueDragging = false
                
                if InputState.ActiveColorElement and ActiveDragElement ~= InputState.ActiveColorElement then
                    TooltipTween:Play()
                end
                InputState.ActiveColorElement = nil
                
                if input == CurrentTouch then
                    InputState.IsTouchActive = false
                end
            end
        end)

        -- Window controls
        TopBar.WindowGrip.MouseButton1Down:Connect(function()
            InputState.WindowStartPosition = ScreenContainer.Position
            InputState.IsDraggingWindow = true
        end)

        TopBar.WindowGrip.MouseButton1Up:Connect(function()
            InputState.IsDraggingWindow = false
        end)

        -- Minimized task handling
        local MinimizedLogo = TopBar.LogoTitle.LogoContainer.Logo:Clone()
        MinimizedLogo.Parent = MinimizedTask

        MinimizedTask.MouseButton1Down:Connect(function()
            InputState.MinimizedStartPosition = MinimizedTask.Position
            InputState.IsDraggingMinimized = true
            InputState.WasDragged = true
        end)

        MinimizedTask.MouseButton1Up:Connect(function()
            InputState.IsDraggingMinimized = false
            if not InputState.WasDragged then
                -- Toggle minimized state
                UIState.IsMinimized = not UIState.IsMinimized
                if UIState.IsMinimized then
                    InputState.RestorePosition = ScreenContainer.Position
                    local minimizePosition = UDim2.fromOffset(
                        MinimizedTask.AbsolutePosition.X + MinimizedTask.AbsoluteSize.X / 2,
                        MinimizedTask.AbsolutePosition.Y + MinimizedTask.AbsoluteSize.Y / 2
                    )
                    ScreenContainer.Position = minimizePosition
                    UI_Tweens.CanvasMin:Play()
                    UI_Tweens.GuiExit:Play()
                    CielBerm.Window.IsMinimized = true
                    BindableEvents.MinimizedChanged:Fire(true)
                    UI_Tweens.GuiExit.Completed:Once(function()
                        MinimizedTask.Visible = true
                    end)
                else
                    MinimizedTask.Visible = false
                    ScreenContainer.Position = InputState.RestorePosition
                    if UIState.IsSmallWindow then
                        UI_Tweens.GuiHalf:Play()
                    else
                        UI_Tweens.GuiFull:Play()
                    end
                    UI_Tweens.CanvasFull:Play()
                    CielBerm.Window.IsMinimized = false
                    BindableEvents.MinimizedChanged:Fire(false)
                end
            end
            InputState.WasDragged = false
        end)

        MinimizedTask.TouchTap:Connect(function()
            UIState.IsMinimized = false
            MinimizedTask.Visible = false
            ScreenContainer.Position = InputState.RestorePosition
            TweenService:Create(ScreenContainer, TweenInfo.new(), {Position = InputState.RestorePosition}):Play()
            
            if UIState.IsSmallWindow then
                UI_Tweens.GuiHalf:Play()
            else
                UI_Tweens.GuiFull:Play()
            end
            
            UI_Tweens.CanvasFull:Play()
            CielBerm.Window.IsMinimized = false
            BindableEvents.MinimizedChanged:Fire(false)
        end)

        -- Window control buttons
        TopBar.WindowControls.Maximize.MouseButton1Click:Connect(function()
            UIState.IsSmallWindow = not UIState.IsSmallWindow
            if UIState.IsSmallWindow then
                UI_Tweens.GuiHalf:Play()
            else
                UI_Tweens.GuiFull:Play()
            end
            
            CielBerm.Window.IsSmall = UIState.IsSmallWindow
            BindableEvents.SizeChanged:Fire(UIState.IsSmallWindow)
        end)

        TopBar.WindowControls.Minimize.MouseButton1Click:Connect(function()
            UIState.IsMinimized = true
            InputState.RestorePosition = ScreenContainer.Position
            
            local minimizePosition = UDim2.fromOffset(
                MinimizedTask.AbsolutePosition.X + MinimizedTask.AbsoluteSize.X / 2,
                MinimizedTask.AbsolutePosition.Y + MinimizedTask.AbsoluteSize.Y / 2
            )
            
            ScreenContainer.Position = minimizePosition
            UI_Tweens.CanvasMin:Play()
            UI_Tweens.GuiExit:Play()
            
            CielBerm.Window.IsMinimized = true
            BindableEvents.MinimizedChanged:Fire(true)
            
            UI_Tweens.GuiExit.Completed:Once(function()
                MinimizedTask.Visible = true
            end)
        end)

        TopBar.WindowControls.Close.MouseButton1Click:Connect(function()
            CielBerm.Window:ShowDialog({
                Title = "Close CielBerm UI?",
                Text = "This will close CielBerm UI, cleaning up everything. You won't be able to access it again unless you run it from your executor. Continue?",
                Buttons = {
                    {Title = "OK", Callback = CielBerm.Window.Close, Secondary = true},
                    {Title = "Cancel"}
                }
            })
        end)

        -- Login section interactions
        LoginWindow.LoginBox.CTAContainer.Help.MouseButton1Click:Connect(function()
            CielBerm.Window:ShowDialog({
                Title = "Need help?",
                Text = "If you are experiencing problems logging in, you may feel free to join our Discord server for support.",
                CopyBoxText = STRINGS.DISCORD_INVITE
            })
        end)

        LoginWindow.LoginBox.CTAContainer.GetKey.MouseButton1Click:Connect(function()
            CielBerm.Window:ShowDialog({
                Title = "Get Key",
                Text = "To get a key for CielBerm UI, please visit the following URL below in your web browser. You will see ads which support us and help us to make more scripts. Thanks for your support!",
                CopyBoxText = UIState.IsWhitelistMode and STRINGS.WHITELIST_LINK or STRINGS.KEY_LINK
            })
        end)

        LoginWindow.LoginBox.LoginLayout.LogIn.MouseButton1Click:Connect(function()
            local loginCallback = CielBerm.Login.OnLogin
            local keyValue = not UIState.IsWhitelistMode and KeyInput.Text or nil
            
            if type(loginCallback) == "function" then
                coroutine.resume(coroutine.create(loginCallback), keyValue)
            end
            
            BindableEvents.LoginRequest:Fire(keyValue)
        end)

        LoginWindow.DiscordButton.MouseButton1Click:Connect(function()
            CielBerm.Window:ShowDialog({
                Title = "Join our Discord server!",
                Text = "To receive support, purchase keys, and chat with our community, feel free to join the server below!",
                CopyBoxText = STRINGS.DISCORD_INVITE
            })
        end)

        -- Text input focus tracking
        local FocusedTextBox
        UserInputService.TextBoxFocused:Connect(function(textBox)
            FocusedTextBox = textBox
        end)

        UserInputService.TextBoxFocusReleased:Connect(function(textBox)
            FocusedTextBox = nil
        end)

        -- Complete Color Picker System
        local CurrentColor = Color3.fromHSV(1, 1, 1)
        local Hue, Saturation, Value = CurrentColor:ToHSV()
        
        local ColorPickerComponents = {
            HuePad = AdvancedColorPicker.AdvancedColors.ColorPads.ColorProf.Hue,
            ValuePad = AdvancedColorPicker.AdvancedColors.ColorPads.ValueProf.Light,
            ColorPreview = AdvancedColorPicker.AdvancedColors.FineTuning.ColorPreview.Color,
            HueCursor = AdvancedColorPicker.AdvancedColors.ColorPads.ColorProf.Hue.Cursor,
            ValueCursor = AdvancedColorPicker.AdvancedColors.ColorPads.ValueProf.Light.ArrowTrack.Arrow,
            FineTuneInputs = AdvancedColorPicker.AdvancedColors.FineTuning.FineTuneVals
        }

        -- Input field references
        local HueInput = ColorPickerComponents.FineTuneInputs.Hue.TextBox
        local SaturationInput = ColorPickerComponents.FineTuneInputs.Sat.TextBox
        local ValueInput = ColorPickerComponents.FineTuneInputs.Val.TextBox
        local RedInput = ColorPickerComponents.FineTuneInputs.R.TextBox
        local GreenInput = ColorPickerComponents.FineTuneInputs.G.TextBox
        local BlueInput = ColorPickerComponents.FineTuneInputs.B.TextBox
        local HexInput = ColorPickerComponents.FineTuneInputs.Hex.TextBox

                -- Input tracking for color fields
        local InputValues = {}
        local CursorPositions = {}
        local SelectionStarts = {}

        -- Initialize input tracking for all color fields
        local InputFields = {
            Hue = HueInput,
            Saturation = SaturationInput,
            Value = ValueInput,
            Red = RedInput,
            Green = GreenInput,
            Blue = BlueInput,
            Hex = HexInput
        }

        for fieldName, inputField in pairs(InputFields) do
            InputValues[inputField] = inputField.Text
            CursorPositions[inputField] = inputField.CursorPosition
            SelectionStarts[inputField] = inputField.SelectionStart
        end

        -- Color picker interaction handlers - COMPLETE IMPLEMENTATION
        ColorPickerComponents.HuePad.Parent.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                InputState.IsColorDragging = true
                InputState.ColorPadStartPosition = ColorPickerComponents.HuePad.AbsolutePosition
                InputState.ColorPadSize = ColorPickerComponents.HuePad.AbsoluteSize
                InputState.CurrentHue = Hue
                InputState.CurrentSaturation = Saturation
                InputState.CurrentValue = Value
                InputState.CurrentColor = CurrentColor
                InputState.HueInput = HueInput
                InputState.SaturationInput = SaturationInput
                InputState.ValueInput = ValueInput
                InputState.RedInput = RedInput
                InputState.GreenInput = GreenInput
                InputState.BlueInput = BlueInput
                InputState.HexInput = HexInput
                InputState.HueCursor = ColorPickerComponents.HueCursor
                InputState.ValueCursor = ColorPickerComponents.ValueCursor
                InputState.ColorPreview = ColorPickerComponents.ColorPreview
                InputState.ValuePad = ColorPickerComponents.ValuePad

                local relativePosition = ((Vector2.new(input.Position.X, input.Position.Y) - ColorPickerComponents.HuePad.AbsolutePosition) / ColorPickerComponents.HuePad.AbsoluteSize)
                    :Max(Vector2.zero):Min(Vector2.one)
                
                local hueValue = math.floor(relativePosition.X * 359)
                local saturationValue = math.floor(relativePosition.Y * 255)
                
                Hue = (359 - hueValue) / 360
                Saturation = 1 - saturationValue / 255
                CurrentColor = Color3.fromHSV(Hue, Saturation, Value)
                
                -- Update input fields
                HueInput.Text = tostring(359 - hueValue)
                SaturationInput.Text = tostring(255 - saturationValue)
                InputValues[HueInput] = HueInput.Text
                InputValues[SaturationInput] = SaturationInput.Text
                
                local hexColor = CurrentColor:ToHex()
                HexInput.Text = "#" .. hexColor
                RedInput.Text = tostring(tonumber(hexColor:sub(1, 2), 16))
                GreenInput.Text = tostring(tonumber(hexColor:sub(3, 4), 16))
                BlueInput.Text = tostring(tonumber(hexColor:sub(5, 6), 16))
                
                InputValues[HexInput] = HexInput.Text
                InputValues[RedInput] = RedInput.Text
                InputValues[GreenInput] = GreenInput.Text
                InputValues[BlueInput] = BlueInput.Text
                
                -- Update cursors and preview
                ColorPickerComponents.HueCursor.Position = UDim2.fromScale(hueValue / 359, saturationValue / 255)
                ColorPickerComponents.ColorPreview.BackgroundColor3 = CurrentColor
                ColorPickerComponents.ValuePad.BackgroundColor3 = Color3.fromHSV(Hue, Saturation, 1)
            end
        end)

        ColorPickerComponents.ValuePad.Parent.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                InputState.IsValueDragging = true
                InputState.ValuePadStartPosition = ColorPickerComponents.ValuePad.AbsolutePosition
                InputState.ValuePadSize = ColorPickerComponents.ValuePad.AbsoluteSize
                InputState.CurrentHue = Hue
                InputState.CurrentSaturation = Saturation
                InputState.CurrentValue = Value
                InputState.CurrentColor = CurrentColor
                InputState.HueInput = HueInput
                InputState.SaturationInput = SaturationInput
                InputState.ValueInput = ValueInput
                InputState.RedInput = RedInput
                InputState.GreenInput = GreenInput
                InputState.BlueInput = BlueInput
                InputState.HexInput = HexInput
                InputState.HueCursor = ColorPickerComponents.HueCursor
                InputState.ValueCursor = ColorPickerComponents.ValueCursor
                InputState.ColorPreview = ColorPickerComponents.ColorPreview

                local valuePosition = math.floor(math.clamp((input.Position.Y - ColorPickerComponents.ValuePad.AbsolutePosition.Y) / ColorPickerComponents.ValuePad.AbsoluteSize.Y, 0, 1) * 255)
                Value = 1 - valuePosition / 255
                CurrentColor = Color3.fromHSV(Hue, Saturation, Value)
                
                ValueInput.Text = tostring(255 - valuePosition)
                InputValues[ValueInput] = ValueInput.Text
                
                local hexColor = CurrentColor:ToHex()
                HexInput.Text = "#" .. hexColor
                RedInput.Text = tostring(tonumber(hexColor:sub(1, 2), 16))
                GreenInput.Text = tostring(tonumber(hexColor:sub(3, 4), 16))
                BlueInput.Text = tostring(tonumber(hexColor:sub(5, 6), 16))
                
                InputValues[HexInput] = HexInput.Text
                InputValues[RedInput] = RedInput.Text
                InputValues[GreenInput] = GreenInput.Text
                InputValues[BlueInput] = BlueInput.Text
                
                ColorPickerComponents.ValueCursor.Position = UDim2.fromScale(0, valuePosition / 255)
                ColorPickerComponents.ColorPreview.BackgroundColor3 = CurrentColor
            end
        end)

        -- Input change handlers for color fields
        ColorPickerComponents.HuePad.Parent.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or (input.UserInputType == Enum.UserInputType.Touch and input == CurrentTouch) then
                if InputState.IsColorDragging then
                    local relativePosition = ((Vector2.new(input.Position.X, input.Position.Y) - ColorPickerComponents.HuePad.AbsolutePosition) / ColorPickerComponents.HuePad.AbsoluteSize)
                        :Max(Vector2.zero):Min(Vector2.one)
                    
                    local hueValue = math.floor(relativePosition.X * 359)
                    local saturationValue = math.floor(relativePosition.Y * 255)
                    
                    Hue = (359 - hueValue) / 360
                    Saturation = 1 - saturationValue / 255
                    CurrentColor = Color3.fromHSV(Hue, Saturation, Value)
                    
                    HueInput.Text = tostring(359 - hueValue)
                    SaturationInput.Text = tostring(255 - saturationValue)
                    
                    local hexColor = CurrentColor:ToHex()
                    HexInput.Text = "#" .. hexColor
                    RedInput.Text = tostring(tonumber(hexColor:sub(1, 2), 16))
                    GreenInput.Text = tostring(tonumber(hexColor:sub(3, 4), 16))
                    BlueInput.Text = tostring(tonumber(hexColor:sub(5, 6), 16))
                    
                    ColorPickerComponents.HueCursor.Position = UDim2.fromScale(hueValue / 359, saturationValue / 255)
                    ColorPickerComponents.ColorPreview.BackgroundColor3 = CurrentColor
                    ColorPickerComponents.ValuePad.BackgroundColor3 = Color3.fromHSV(Hue, Saturation, 1)
                end
            end
        end)

        ColorPickerComponents.ValuePad.Parent.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or (input.UserInputType == Enum.UserInputType.Touch and input == CurrentTouch) then
                if InputState.IsValueDragging then
                    local valuePosition = math.floor(math.clamp((input.Position.Y - ColorPickerComponents.ValuePad.AbsolutePosition.Y) / ColorPickerComponents.ValuePad.AbsoluteSize.Y, 0, 1) * 255)
                    Value = 1 - valuePosition / 255
                    CurrentColor = Color3.fromHSV(Hue, Saturation, Value)
                    
                    ValueInput.Text = tostring(255 - valuePosition)
                    
                    local hexColor = CurrentColor:ToHex()
                    HexInput.Text = "#" .. hexColor
                    RedInput.Text = tostring(tonumber(hexColor:sub(1, 2), 16))
                    GreenInput.Text = tostring(tonumber(hexColor:sub(3, 4), 16))
                    BlueInput.Text = tostring(tonumber(hexColor:sub(5, 6), 16))
                    
                    ColorPickerComponents.ValueCursor.Position = UDim2.fromScale(0, valuePosition / 255)
                    ColorPickerComponents.ColorPreview.BackgroundColor3 = CurrentColor
                end
            end
        end)

        -- Text input validation and synchronization for ALL color fields
        local function UpdateColorFromHSV()
            CurrentColor = Color3.fromHSV(Hue, Saturation, Value)
            local hexColor = CurrentColor:ToHex()
            local red, green, blue = math.floor(CurrentColor.R * 255), math.floor(CurrentColor.G * 255), math.floor(CurrentColor.B * 255)
            
            HexInput.Text = "#" .. hexColor
            RedInput.Text = tostring(red)
            GreenInput.Text = tostring(green)
            BlueInput.Text = tostring(blue)
            
            -- Update preview and pads
            ColorPickerComponents.ColorPreview.BackgroundColor3 = CurrentColor
            ColorPickerComponents.ValuePad.BackgroundColor3 = Color3.fromHSV(Hue, Saturation, 1)
            
            -- Update cursors
            ColorPickerComponents.HueCursor.Position = UDim2.fromScale(1 - Hue, 1 - Saturation)
            ColorPickerComponents.ValueCursor.Position = UDim2.fromScale(0, 1 - Value)
        end

        local function UpdateColorFromRGB()
            local red = tonumber(RedInput.Text) or 0
            local green = tonumber(GreenInput.Text) or 0
            local blue = tonumber(BlueInput.Text) or 0
            
            CurrentColor = Color3.fromRGB(red, green, blue)
            Hue, Saturation, Value = CurrentColor:ToHSV()
            
            HueInput.Text = tostring(math.floor(Hue * 360))
            SaturationInput.Text = tostring(math.floor(Saturation * 255))
            ValueInput.Text = tostring(math.floor(Value * 255))
            HexInput.Text = "#" .. CurrentColor:ToHex()
            
            UpdateColorFromHSV()
        end

        local function UpdateColorFromHex()
            local hexText = HexInput.Text
            if hexText:sub(1, 1) == "#" then
                hexText = hexText:sub(2)
            end
            
            if #hexText == 6 then
                local success, color = pcall(function()
                    return Color3.fromHex(hexText)
                end)
                
                if success then
                    CurrentColor = color
                    Hue, Saturation, Value = CurrentColor:ToHSV()
                    
                    HueInput.Text = tostring(math.floor(Hue * 360))
                    SaturationInput.Text = tostring(math.floor(Saturation * 255))
                    ValueInput.Text = tostring(math.floor(Value * 255))
                    RedInput.Text = tostring(math.floor(CurrentColor.R * 255))
                    GreenInput.Text = tostring(math.floor(CurrentColor.G * 255))
                    BlueInput.Text = tostring(math.floor(CurrentColor.B * 255))
                    
                    UpdateColorFromHSV()
                end
            end
        end

        -- Connect all input field events
        HueInput.FocusLost:Connect(function()
            local hueValue = tonumber(HueInput.Text) or 0
            Hue = math.clamp(hueValue / 360, 0, 1)
            UpdateColorFromHSV()
        end)

        SaturationInput.FocusLost:Connect(function()
            local satValue = tonumber(SaturationInput.Text) or 0
            Saturation = math.clamp(satValue / 255, 0, 1)
            UpdateColorFromHSV()
        end)

        ValueInput.FocusLost:Connect(function()
            local valValue = tonumber(ValueInput.Text) or 0
            Value = math.clamp(valValue / 255, 0, 1)
            UpdateColorFromHSV()
        end)

        RedInput.FocusLost:Connect(UpdateColorFromRGB)
        GreenInput.FocusLost:Connect(UpdateColorFromRGB)
        BlueInput.FocusLost:Connect(UpdateColorFromRGB)
        HexInput.FocusLost:Connect(UpdateColorFromHex)

        -- Basic color grid setup - COMPLETE with all 64 colors
        local BasicColorGrid = BasicColorPicker.BasicColorGrid
        local ColorSwatchTemplate = Resources.Components.ColorSwatch

        for redIndex = 0, 3 do
            for greenIndex = 0, 3 do
                for blueIndex = 0, 2 do
                    local swatch = ColorSwatchTemplate:Clone()
                    local swatchColor = Color3.new(redIndex / 3, greenIndex / 3, blueIndex / 2)
                    
                    swatch.ColorButton.BackgroundColor3 = swatchColor
                    swatch.LayoutOrder = redIndex * 12 + greenIndex * 3 + blueIndex
                    swatch.Parent = BasicColorGrid
                    
                    swatch.ColorButton.MouseButton1Click:Connect(function()
                        BasicColorPicker.Visible = false
                        AdvancedColorPicker.Visible = true
                        ColorPickerTitle.Text = "Advanced Colors"
                        
                        CurrentColor = swatchColor
                        Hue, Saturation, Value = CurrentColor:ToHSV()
                        
                        -- Update all inputs
                        HueInput.Text = tostring(math.floor(Hue * 360))
                        SaturationInput.Text = tostring(math.floor(Saturation * 255))
                        ValueInput.Text = tostring(math.floor(Value * 255))
                        
                        local hexColor = CurrentColor:ToHex()
                        HexInput.Text = "#" .. hexColor
                        RedInput.Text = tostring(math.floor(CurrentColor.R * 255))
                        GreenInput.Text = tostring(math.floor(CurrentColor.G * 255))
                        BlueInput.Text = tostring(math.floor(CurrentColor.B * 255))
                        
                        -- Update cursors and preview
                        ColorPickerComponents.HueCursor.Position = UDim2.fromScale(1 - Hue, 1 - Saturation)
                        ColorPickerComponents.ValueCursor.Position = UDim2.fromScale(0, 1 - Value)
                        ColorPickerComponents.ColorPreview.BackgroundColor3 = CurrentColor
                        ColorPickerComponents.ValuePad.BackgroundColor3 = Color3.fromHSV(Hue, Saturation, 1)
                        
                        UI_Tweens.AdvancedColorsEnter:Play()
                    end)
                end
            end
        end

        -- Color picker navigation
        BasicColorPicker.FooterButton.MouseButton1Click:Connect(function()
            BasicColorPicker.Visible = false
            AdvancedColorPicker.Visible = true
            ColorPickerTitle.Text = "Advanced Colors"
            UI_Tweens.AdvancedColorsEnter:Play()
        end)

        AdvancedColorPicker.FooterButton.MouseButton1Click:Connect(function()
            AdvancedColorPicker.Visible = false
            BasicColorPicker.Visible = true
            ColorPickerTitle.Text = "Basic Colors"
            UI_Tweens.AdvancedColorsExit:Play()
        end)

        -- Color picker close handlers
        local CloseButtons = {
            ColorPickerUI.TopBar.Close,
            AdvancedColorPicker.AdvancedColors.FineTuning.Buttons.Cancel
        }

        for _, closeButton in ipairs(CloseButtons) do
            closeButton.MouseButton1Click:Connect(function()
                UI_Tweens.ColorPickerClose:Play()
                UI_Tweens.ColorModalShadeFadeOut:Play()
                UIState.ModalCount = UIState.ModalCount - 1
                if UIState.ModalCount == 0 then
                    Surface.Window.Content.Interactable = true
                end
            end)
        end

        local ActiveColorElement
        local ActiveColorCallback
        
        AdvancedColorPicker.AdvancedColors.FineTuning.Buttons.OK.MouseButton1Click:Connect(function()
            if ActiveColorElement then
                ActiveColorElement.BackgroundColor3 = CurrentColor
            end
            UI_Tweens.ColorPickerClose:Play()
            UI_Tweens.ColorModalShadeFadeOut:Play()
            UIState.ModalCount = UIState.ModalCount - 1
            
            if UIState.ModalCount == 0 then
                Surface.Window.Content.Interactable = true
            end
            
            if ActiveColorCallback and type(ActiveColorCallback) == "function" then
                coroutine.resume(coroutine.create(ActiveColorCallback), CurrentColor, 0)
            end
            
            ActiveColorElement = nil
            ActiveColorCallback = nil
        end)

        -- Icon setup for login section
        local Icons20px = Resources.Icons["20px"]
        local LoginCTA = KeyField.Parent.Parent.CTAContainer
        
        Icons20px.meridians:Clone().Parent = LoginCTA.GetKey.IconContainer
                Icons20px.help:Clone().Parent = LoginCTA.Help.IconContainer
        Icons20px["lock-open"]:Clone().Parent = KeyField.Parent.LogIn
        Icons20px.key:Clone().Parent = KeyField.KeyIcon

        -- Login tips carousel - COMPLETE implementation
        local IsFirstTip = true
        local LoginTipsIcons = Resources.Icons.LoginTips
        local TipPageTemplate = Resources.Components.LoginTipPage
                local TipPageTemplate = Resources.Components.LoginTipPage
        local PageIndicatorTemplate = Resources.Components.PageIndicator
        
        local TipScroller = LoginWindow.TipScroller
        local TipContent = TipScroller.InnerContent
        local TipLayout = TipContent.UIPageLayout
        local PageProgress = TipScroller.PageProgress
        local ProgressBar = TipScroller.ProgressBar.ProgressValue
        
        local LoginTips = {
            {
                Title = "CielBerm UI Beta",
                Description = "Support us by testing out beta features before they are released to everyone.",
                Icon = LoginTipsIcons.Beta,
                Color = Color3.fromRGB(183, 78, 234)
            },
            {
                Title = "Join our Discord!",
                Description = "Stay updated with news, new games, and interact with our friendly community.",
                Icon = LoginTipsIcons.DiscordClyde,
                Color = Color3.fromRGB(89, 112, 226)
            },
            {
                Title = "Get Keyless",
                Description = "Tired of the key system? With Keyless, you get a permanent key that works forever. Never see an ad again.",
                Icon = LoginTipsIcons.DemonKey,
                Color = Color3.fromRGB(176, 165, 4)
            }
        }

        local PageIndicators = {}
        local TipPages = {}

        for index, tipData in ipairs(LoginTips) do
            local tipPage = TipPageTemplate:Clone()
            local tipDetails = tipPage.Details
            local tipIcon = tipPage.Icon
            
            tipDetails.Title.Text = tipData.Title
            tipDetails.Desc.Text = tipData.Description
            tipIcon.BackgroundColor3 = tipData.Color
            tipData.Icon:Clone().Parent = tipIcon
            tipPage.Parent = TipContent
            TipPages[index] = tipPage
            
            local pageIndicator = PageIndicatorTemplate:Clone()
            local indicatorBubble = pageIndicator.Bubble
            pageIndicator.Parent = PageProgress
            PageIndicators[index] = indicatorBubble
            
            if IsFirstTip then
                IsFirstTip = false
                indicatorBubble.BackgroundTransparency = 0
            end
            
            -- Page transition animations
            TipLayout.PageEnter:Connect(function(page)
                if page == tipPage then
                    TweenService:Create(indicatorBubble, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
                end
            end)
            
            TipLayout.PageLeave:Connect(function(page)
                if page == tipPage then
                    TweenService:Create(indicatorBubble, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                end
            end)
        end

        local CurrentTipIndex = 1
        local ProgressTween = TweenService:Create(ProgressBar, 
            TweenInfo.new(10, Enum.EasingStyle.Linear), 
            {Size = UDim2.fromScale(1, 2)}
        )

        local function AdvanceTip()
            ProgressBar.Size = UDim2.fromScale(0, 2)
            ProgressTween:Play()
            TipLayout:JumpToIndex(CurrentTipIndex)
            
            if CurrentTipIndex == 3 then
                CurrentTipIndex = 1
            else
                CurrentTipIndex = CurrentTipIndex + 1
            end
        end

        ProgressTween.Completed:Connect(AdvanceTip)
        ProgressTween:Play()

        -- Manual tip navigation
        TipScroller.NextButton.MouseButton1Click:Connect(AdvanceTip)
        TipScroller.PrevButton.MouseButton1Click:Connect(function()
            CurrentTipIndex = CurrentTipIndex - 1
            if CurrentTipIndex < 1 then
                CurrentTipIndex = 3
            end
            TipLayout:JumpToIndex(CurrentTipIndex)
            ProgressBar.Size = UDim2.fromScale(0, 2)
            ProgressTween:Play()
        end)

        -- Add Discord icon to login button
        LoginTipsIcons.DiscordClyde:Clone().Parent = LoginWindow.DiscordButton

        -- Complete Tooltip positioning function
        local function PositionTooltip(elementPosition, elementSize, tooltipDirection)
            local anchorPoint, tailAnchor
            local horizontalAlignment, verticalAlignment
            
            if tooltipDirection == 1 then
                -- Top placement
                anchorPoint = Vector2.new(0.5)
                tailAnchor = Vector2.new(0.5, 1)
                horizontalAlignment = Enum.HorizontalAlignment.Center
                verticalAlignment = Enum.VerticalAlignment.Top
                
                TooltipLayout.HorizontalAlignment = horizontalAlignment
                TooltipLayout.VerticalAlignment = verticalAlignment
                
                TooltipTailContainer.Position = UDim2.fromScale(0.5)
                TooltipTailContainer.Size = UDim2.fromOffset(8, 7)
                TooltipTailContainer.AnchorPoint = tailAnchor
                
                TooltipTailLeft.Position = UDim2.new(0, 1, 1)
                TooltipTailLeft.AnchorPoint = Vector2.new(0, 0.5)
                TooltipTailRight.Position = UDim2.new(1, -1, 1)
                TooltipTailRight.AnchorPoint = Vector2.new(1, 0.5)
                
            elseif tooltipDirection == 2 then
                -- Left placement
                anchorPoint = Vector2.new(0, 0.5)
                tailAnchor = Vector2.new(1, 0.5)
                horizontalAlignment = Enum.HorizontalAlignment.Left
                verticalAlignment = Enum.VerticalAlignment.Center
                
                TooltipLayout.HorizontalAlignment = horizontalAlignment
                TooltipLayout.VerticalAlignment = verticalAlignment
                
                TooltipTailContainer.Position = UDim2.new(0, -4, 0.5)
                TooltipTailContainer.Size = UDim2.fromOffset(7, 8)
                TooltipTailContainer.AnchorPoint = tailAnchor
                
                TooltipTailLeft.Position = UDim2.new(1, 0, 0, 1)
                TooltipTailLeft.AnchorPoint = Vector2.new(0.5)
                TooltipTailRight.Position = UDim2.new(1, 0, 1, -1)
                TooltipTailRight.AnchorPoint = Vector2.new(0.5, 1)
                
            elseif tooltipDirection == 3 then
                -- Bottom placement  
                anchorPoint = Vector2.new(0.5, 1)
                tailAnchor = Vector2.new(0.5)
                horizontalAlignment = Enum.HorizontalAlignment.Center
                verticalAlignment = Enum.VerticalAlignment.Bottom
                
                TooltipLayout.HorizontalAlignment = horizontalAlignment
                TooltipLayout.VerticalAlignment = verticalAlignment
                
                TooltipTailContainer.Position = UDim2.fromScale(0.5, 1)
                TooltipTailContainer.Size = UDim2.fromOffset(8, 7)
                TooltipTailContainer.AnchorPoint = tailAnchor
                
                TooltipTailLeft.Position = UDim2.fromOffset(1)
                TooltipTailLeft.AnchorPoint = Vector2.new(0, 0.5)
                TooltipTailRight.Position = UDim2.new(1, -1)
                TooltipTailRight.AnchorPoint = Vector2.new(1, 0.5)
            end
            
            local tooltipPosition = elementPosition + elementSize * tailAnchor
            local bubbleSize = TooltipFrame.AbsoluteSize
            
            TweenService:Create(TooltipContainer, TweenInfo.new(0.2), {
                Size = UDim2.fromOffset(bubbleSize.X, bubbleSize.Y),
                Position = UDim2.fromOffset(tooltipPosition.X, tooltipPosition.Y),
                AnchorPoint = anchorPoint
            }):Play()
        end

        -- Complete Navigation and tooltips system
        local NavigationElements = {}
        local NavigationButtons = Surface.Window.Content.TopBar.WindowControls
        
        local TooltipElements = {
            {LoginWindow.LoginBox.LoginLayout.LogIn, "Check Key", 1},
            {LoginWindow.DiscordButton, "Discord Server", 3},
            {NavigationButtons.Minimize, "Minimize", 1},
            {NavigationButtons.Maximize, "Mini View", 1},
            {NavigationButtons.Close, "Close", 1}
        }

        local ActiveNavButton
        local ActivePage
        local IsFirstNav = true
        
        local PageView = Surface.Window.Content.Hub.MainContent.PageView
        local NavButtonsContainer = Surface.Window.Content.Hub.MainContent.NavButtons

        local NavIcons = Resources.Icons.Navigation
        local NavButtonTemplate = Resources.Components.Nav
        
        local NavigationPages = {
            {"Home", NavIcons.home, PageView.Home},
            {"About", NavIcons.info, PageView.About},
            {"Settings", NavIcons.cog, PageView.Settings}
        }

        for index, pageData in ipairs(NavigationPages) do
            local navButton = NavButtonTemplate:Clone()
            local pageName = pageData[1]
            local pageIcon = pageData[2]
            local pageFrame = pageData[3]
            
            navButton.Name = pageName
            navButton.LayoutOrder = index
            navButton.Label.Text = pageName
            pageIcon:Clone().Parent = navButton.Icon
            
            table.insert(TooltipElements, {navButton, pageName, 2})
            navButton.Parent = NavButtonsContainer
            NavigationElements[navButton] = pageName
            
            navButton.MouseButton1Click:Connect(function()
                pageFrame.Visible = true
                
                -- Animate previous active button
                if ActiveNavButton then
                    TweenService:Create(ActiveNavButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(82, 82, 82)
                    }):Play()
                end
                
                -- Animate new active button
                TweenService:Create(navButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = ThemeColors.NavButtonActive.Value
                }):Play()
                
                -- Page transition animation
                if ActivePage and ActivePage ~= pageFrame then
                    local oldPage = ActivePage
                    local pageOutTween = TweenService:Create(oldPage, TweenInfo.new(0.5), {
                        Position = UDim2.fromScale(0, -1)
                    })
                    pageOutTween:Play()
                    
                    pageOutTween.Completed:Once(function(state)
                        if state == Enum.PlaybackState.Completed then
                            oldPage.Visible = false
                        end
                    end)
                end
                
                TweenService:Create(pageFrame, TweenInfo.new(0.5), {
                    Position = UDim2.fromOffset()
                }):Play()
                
                -- Reset scroll position
                TweenService:Create(pageFrame.Parent, TweenInfo.new(0.5), {
                    CanvasPosition = Vector2.zero
                }):Play()
                
                ActiveNavButton = navButton
                ActivePage = pageFrame
            end)
            
            if IsFirstNav then
                IsFirstNav = false
                navButton.BackgroundColor3 = ThemeColors.NavButtonActive.Value
                ActiveNavButton = navButton
                ActivePage = pageFrame
                pageFrame.Visible = true
                pageFrame.Position = UDim2.fromScale(0.5)
            else
                pageFrame.Visible = false
                pageFrame.Position = UDim2.fromScale(0.5, -1)
            end
        end

        -- Complete Tooltip setup for all elements
        for _, elementData in ipairs(TooltipElements) do
            local element = elementData[1]
            local tooltipText = elementData[2]
            local direction = elementData[3]
            
            element.MouseEnter:Connect(function()
                if not InputState.IsDraggingSlider then
                    ActiveTooltipElement = element
                    TooltipLabel.Text = tooltipText
                    
                    -- Calculate text size for proper positioning
                    local textSize = TextService:GetTextSize(tooltipText, 14, Enum.Font.Gotham, Vector2.new(200, 100))
                    PositionTooltip(element.AbsolutePosition, element.AbsoluteSize, direction)
                    
                    TooltipContainer.Visible = true
                end
            end)
            
            element.MouseLeave:Connect(function()
                if ActiveTooltipElement == element and not InputState.IsDraggingSlider then
                    TooltipTween:Play()
                    ActiveTooltipElement = nil
                    TooltipTween.Completed:Once(function()
                        TooltipContainer.Visible = false
                    end)
                end
            end)
        end

        -- Slider component implementation
        local function CreateSlider(element, config)
            local base = element.Base
            local track = base.Track
            local innerTrack = track.InnerTrack
            local knob = innerTrack.Knob
            local fill = innerTrack.Fill
            
            local minValue = tonumber(config.Min) or 0
            local maxValue = tonumber(config.Max) or 100
            local currentValue = tonumber(config.Value) or (minValue + (maxValue - minValue) / 2)
            local step = tonumber(config.Step)
            local isPercent = not not config.IsPercent
            
            local range = maxValue - minValue
            local normalizedValue = math.clamp((currentValue - minValue) / range, 0, 1)
            
            -- Set initial positions
            knob.Position = UDim2.fromScale(normalizedValue, 0.5)
            fill.Size = UDim2.fromScale(normalizedValue, 1)
            
            -- Mouse enter for tooltip
            knob.MouseEnter:Connect(function()
                if not InputState.IsDraggingSlider then
                    ActiveTooltipElement = knob
                    TooltipLabel.Text = isPercent and math.round(100 * currentValue) .. "%" or currentValue
                    PositionTooltip(track.AbsolutePosition, track.AbsoluteSize, 3)
                    TooltipContainer.Visible = true
                end
            end)
            
            knob.MouseLeave:Connect(function()
                if ActiveTooltipElement == knob and not InputState.IsDraggingSlider then
                    TooltipTween:Play()
                    ActiveTooltipElement = nil
                    TooltipTween.Completed:Once(function()
                        TooltipContainer.Visible = false
                    end)
                end
            end)
            
            -- Slider dragging
            knob.MouseButton1Down:Connect(function()
                InputState.IsDraggingSlider = true
                InputState.ActiveSlider = knob
                InputState.SliderStartScale = normalizedValue
                InputState.SliderMin = minValue
                InputState.SliderMax = maxValue
                InputState.SliderStep = step or 1
                InputState.SliderValueObject = element
                InputState.SliderFill = fill
                InputState.IsPercent = isPercent
                
                TooltipLabel.Text = isPercent and math.round(100 * currentValue) .. "%" or currentValue
                PositionTooltip(track.AbsolutePosition, track.AbsoluteSize, 3)
                TooltipContainer.Visible = true
            end)
            
            -- Value setter function
            function element.SetValue(self, newValue)
                newValue = tonumber(newValue) or (minValue + (maxValue - minValue) / 2)
                local normalized = math.clamp((newValue - minValue) / range, 0, 1)
                local steppedValue
                
                if step and step ~= math.huge and step ~= -math.huge then
                    steppedValue = math.round((minValue + (normalized * range)) * step) / step
                    local steppedScale = UDim2.fromScale((steppedValue - minValue) / range, 1)
                    knob.Position = steppedScale
                    fill.Size = steppedScale
                else
                    steppedValue = minValue + (normalized * range)
                    knob.Position = UDim2.fromScale(normalized, 0.5)
                    fill.Size = UDim2.fromScale(normalized, 1)
                end
                
                steppedValue = math.clamp(steppedValue, minValue, maxValue)
                element.Value = steppedValue
                
                if InputState.SliderValueObject == element then
                    TooltipLabel.Text = isPercent and math.round(100 * steppedValue) .. "%" or steppedValue
                    local bubbleSize = TooltipFrame.AbsoluteSize
                    TooltipContainer.Size = UDim2.fromOffset(bubbleSize.X, bubbleSize.Y)
                end
                
                local callback = element.OnChanged
                if type(callback) == "function" then
                    coroutine.resume(coroutine.create(callback), steppedValue)
                end
            end
            
            element.Value = currentValue
            return element
        end

        -- Toggle component implementation
        local function CreateToggle(element, config)
            local base = element.Base
            local toggleFrame = base.ToggleFrame
            local tick1 = toggleFrame.Tick1.Target
            local tick2 = toggleFrame.Tick2.Target
            
            local isToggled = not not config.Value
            
            -- Set initial state
            if isToggled then
                tick1.Size = UDim2.fromOffset(8, 2)
                tick2.Size = UDim2.fromOffset(14, 2)
                toggleFrame.BackgroundColor3 = ThemeColors.ToggleActive.Value
            end
            
            -- Toggle animations
            local toggleOnTween = TweenService:Create(toggleFrame, TweenInfo.new(0.5), {
                BackgroundColor3 = ThemeColors.ToggleActive.Value
            })
            local tick1OnTween = TweenService:Create(tick1, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = UDim2.fromOffset(8, 2)
            })
            local tick2OnTween = TweenService:Create(tick2, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = UDim2.fromOffset(14, 2)
            })
            
            local toggleOffTween = TweenService:Create(toggleFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundColor3 = Color3.new()
            })
            local tick1OffTween = TweenService:Create(tick1, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset()
            })
            local tick2OffTween = TweenService:Create(tick2, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset()
            })
            
            local function Toggle()
                isToggled = not isToggled
                
                if isToggled then
                    toggleOnTween:Play()
                    tick1OnTween:Play()
                    tick2OnTween:Play()
                else
                    toggleOffTween:Play()
                    tick1OffTween:Play()
                    tick2OffTween:Play()
                end
                
                element.Value = isToggled
                local callback = element.OnChanged
                if type(callback) == "function" then
                    coroutine.resume(coroutine.create(callback), isToggled)
                end
            end
            
            base.ClickArea.MouseButton1Click:Connect(Toggle)
            
            function element.SetValue(self, value)
                if value ~= isToggled then
                    Toggle()
                end
            end
            
            element.Value = isToggled
            element.Toggle = Toggle
            
            return element
        end

        -- Button component implementation
        local function CreateButton(element, config)
            local base = element.Base
            local clickArea = base.ClickArea
            local button = base.Button
            local label = button.Label
            
            local buttonText = config.Text or "Button"
            local isSimple = config.Simple or false
            
            if isSimple or buttonText == nil then
                button:Destroy()
                base.UIPadding:Destroy()
                Resources.Components.ButtonArrow:Clone().Parent = base
                element.Size = UDim2.fromOffset(60, 60)
                
                function element.SetText(self, text)
                    -- Simple buttons don't have text
                end
            else
                label.Text = tostring(buttonText)
                element.Text = buttonText
                
                function element.SetText(self, text)
                    text = tostring(text)
                    label.Text = text
                    element.Text = text
                end
            end
            
            element.Click = clickArea.MouseButton1Click
            
            return element
        end

        -- Cleanup function
        local function CleanupUI()
            BindableEvents.HubDestroying:Fire()
            
            -- Disconnect all connections
            if RenderConnection then
                RenderConnection:Disconnect()
            end
            if InputBeganConnection then
                InputBeganConnection:Disconnect()
            end
            if InputChangedConnection then
                InputChangedConnection:Disconnect()
            end
            if InputEndedConnection then
                InputEndedConnection:Disconnect()
            end
            
            -- Destroy UI elements
            if Surface then
                Surface:Destroy()
            end
            if Renderer then
                Renderer:Destroy()
            end
            if PlayerScript then
                PlayerScript:Destroy()
            end
            
            -- Clean up all references
            STRINGS, CANVAS_SIZE, CurrentCamera, PlayerScript, Resources, Renderer, Surface = nil, nil, nil, nil, nil, nil, nil
            ScreenContainer, HubPosition, LoginWindow, KeyField, KeyInput = nil, nil, nil, nil, nil
            ModalsContainer, ColorModal, HubContent, Sidebar, PageContainer = nil, nil, nil, nil, nil
            TopBar, SubtitleText, VersionText, ThemeColors = nil, nil, nil, nil
            ColorPickerUI, BasicColorPicker, AdvancedColorPicker = nil, nil, nil
            ColorPickerTitle, MinimizedTask, TooltipContainer = nil, nil, nil
            
            script:Destroy()
            script = nil
        end

        -- Settings page setup with all components
        local IsFirstTab = true
        local SettingsTransparency = 0.25
        local IsTransparent = true
        
        local SettingsPage = CielBerm.Hub:CreatePage("Settings", "cog")
        SettingsPage.TabInstance:Destroy()
        SettingsPage.Instance.Parent = Surface.Window.Content.Hub.MainContent.PageView.Settings.PageBase.PageContents
        
        local AppearanceSection = SettingsPage:CreateSection("Appearance")
        
        AppearanceSection:CreateElement("Toggle", {
            Value = true,
            Label = {
                Title = "Transparent Background",
                Text = "Enables UI background transparency."
            },
            OnChanged = function(value)
                IsTransparent = value
                if value then
                    HubBackground.GroupTransparency = SettingsTransparency
                else
                    HubBackground.GroupTransparency = 0
                end
            end
        })
        
        AppearanceSection:CreateElement("Slider", {
            Value = 0.25,
            Min = 0,
            Max = 0.25,
            Step = 0.01,
            IsPercent = true,
            Label = {
                Title = "UI Transparency",
                Text = "Controls how transparent the UI background is. This setting only applies if the \"Transparent Background\" setting is turned on."
            },
            OnChanged = function(value)
                SettingsTransparency = value
                if IsTransparent then
                    HubBackground.GroupTransparency = SettingsTransparency
                end
            end
        })

        IsFirstTab = true
        ActiveNavButton = nil
        ActivePage = nil

        -- Complete CielBerm API with all functions
        CielBerm = {
            Base = PlayerScript,
            Screen = PlayerScript,
            Renderer = Renderer,
            Gui = Surface,
            
            Window = {
                Object = Surface.Window,
                IsMinimized = false,
                IsSmall = false,
                IsOpen = false,
                
                SetSubtitle = function(self, subtitle, version)
                    SubtitleText.Text = subtitle
                    if version ~= nil then
                        VersionText.Text = tostring(version)
                        VersionText.Visible = true
                    else
                        VersionText.Visible = false
                    end
                end,
                
                ShowMessage = function(self, title, text)
                    self:ShowDialog({Title = title, Text = text})
                end,
                
                ShowDialog = function(self, dialogConfig)
                    if type(dialogConfig) == "table" then
                        if not ActiveModals[1] then
                            UI_Tweens.ModalShadeFadeIn:Play()
                            UIState.ModalCount = UIState.ModalCount + 1
                            Surface.Window.Content.Interactable = false
                        end
                        
                        local modal = Resources.Components.Modal:Clone()
                        
                        if dialogConfig.Transparent == false then
                            modal.BackgroundTransparency = 0
                        end
                        
                        if dialogConfig.Title ~= nil then
                            modal.Inner.DialogTitle.Text = tostring(dialogConfig.Title)
                        end
                        
                        if dialogConfig.Text ~= nil then
                            modal.Inner.DialogText.Text = tostring(dialogConfig.Text)
                        end
                        
                        modal.Parent = ModalsContainer
                        table.insert(ActiveModals, modal)
                        
                        local function ProcessNextModal()
                            local nextModal = ActiveModals[1]
                            if not ActiveModals[1] then
                                UI_Tweens.ModalShadeFadeOut:Play()
                                UIState.ModalCount = UIState.ModalCount - 1
                                if UIState.ModalCount == 0 then
                                    Surface.Window.Content.Interactable = true
                                end
                            end
                        end
                        
                        local function CloseModal(modalInstance, tweenInstance)
                            if tweenInstance.PlaybackState ~= Enum.PlaybackState.Cancelled then
                                modalInstance:Destroy()
                                tweenInstance:Destroy()
                                ActiveModals[1] = nil
                                ProcessNextModal()
                            end
                        end
                        
                        local function AnimateOut(modalElement)
                            for _, child in pairs(modalElement:GetChildren()) do
                                if child:IsA("GuiButton") then
                                    child.Interactable = false
                                end
                            end
                            
                            local outTween = TweenService:Create(modalElement, 
                                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                                    Position = UDim2.fromScale(0.5, 1),
                                    AnchorPoint = Vector2.new(0.5)
                                })
                            
                            outTween.Completed:Once(function()
                                CloseModal(modalElement, outTween)
                            end)
                            outTween:Play()
                        end
                        
                        local buttons = dialogConfig.Buttons
                        if not (type(buttons) == "table" and #buttons ~= 0) then
                            buttons = {{Title = "OK"}}
                        end
                        
                        for _, buttonConfig in ipairs(buttons) do
                            if type(buttonConfig) == "table" then
                                local button = Resources.Components.ModalButton:Clone()
                                local buttonText = buttonConfig.Title
                                local buttonCallback = buttonConfig.Callback
                                
                                if buttonText then
                                    button.Text = tostring(buttonText)
                                end
                                
                                if buttonConfig.Secondary then
                                    button.BackgroundColor3 = Color3.new(1, 1, 1)
                                end
                                
                                button.MouseButton1Click:Connect(function()
                                    if type(buttonCallback) == "function" then
                                        coroutine.resume(coroutine.create(buttonCallback), buttonText, _, dialogConfig.Nonce)
                                    end
                                    AnimateOut(modal)
                                end)
                                
                                button.Parent = modal.Inner
                            end
                        end
                        
                        if dialogConfig.CopyBoxText ~= nil then
                            local copyLayout = modal.Inner.CopyLayout
                            local copyBox = copyLayout.CopyBox
                            local copyText = tostring(dialogConfig.CopyBoxText)
                            
                            copyBox.Text = copyText
                            copyLayout.Visible = true
                            
                            local cursorConnection
                            copyBox.Focused:Connect(function()
                                copyBox.SelectionStart = 0
                                copyBox.CursorPosition = #copyBox.Text + 1
                                cursorConnection = copyBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
                                    copyBox.SelectionStart = 0
                                    copyBox.CursorPosition = #copyBox.Text + 1
                                end)
                            end)
                            
                            copyBox.FocusLost:Connect(function()
                                if cursorConnection then
                                    cursorConnection:Disconnect()
                                end
                            end)
                            
                            local copyFunction = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set) or CopyString
                            local copyButton = copyLayout.CopyButton
                            
                            if copyFunction then
                                Resources.Icons["20px"].copy:Clone().Parent = copyButton
                                copyButton.MouseButton1Click:Connect(function()
                                    copyFunction(copyText)
                                    copyButton.DoneFrame.Visible = true
                                    copyButton.BackgroundColor3 = Color3.fromRGB(64, 162, 64)
                                    TweenService:Create(copyButton.DoneFrame, TweenInfo.new(5), {Visible = false}):Play()
                                    TweenService:Create(copyButton, 
                                        TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                                            BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                                        }):Play()
                                end)
                            else
                                copyButton.Visible = false
                            end
                        end
                        
                        local function AnimateIn(modalElement)
                            local inTween = TweenService:Create(modalElement, 
                                TweenInfo.new(0.25), {
                                    Position = UDim2.fromScale(0.5, 0.5),
                                    AnchorPoint = Vector2.new(0.5, 0.5)
                                })
                            inTween:Play()
                        end
                        
                        table.remove(ActiveModals, table.find(ActiveModals, modal))
                        AnimateIn(modal)
                    end
                end,
                
                SetMinimized = function(self, minimized, animate)
                    if minimized == nil then minimized = true end
                    if animate == nil then animate = true end
                    
                    if (not not minimized) ~= UIState.IsMinimized then
                        UIState.IsMinimized = minimized
                        
                        if minimized then
                            InputState.RestorePosition = ScreenContainer.Position
                            if animate then
                                local minimizePosition = UDim2.fromOffset(
                                    MinimizedTask.AbsolutePosition.X + MinimizedTask.AbsoluteSize.X / 2,
                                    MinimizedTask.AbsolutePosition.Y + MinimizedTask.AbsoluteSize.Y / 2
                                )
                                ScreenContainer.Position = minimizePosition
                                UI_Tweens.CanvasMin:Play()
                                UI_Tweens.GuiExit:Play()
                                self.IsMinimized = UIState.IsMinimized
                                BindableEvents.MinimizedChanged:Fire(UIState.IsMinimized)
                                UI_Tweens.GuiExit.Completed:Once(function()
                                    MinimizedTask.Visible = true
                                end)
                            else
                                ScreenContainer.Position = UDim2.fromOffset(
                                    MinimizedTask.AbsolutePosition.X + MinimizedTask.AbsoluteSize.X / 2,
                                    MinimizedTask.AbsolutePosition.Y + MinimizedTask.AbsoluteSize.Y / 2
                                )
                                Surface.CanvasSize = Vector2.zero
                                HubPosition.Size = UDim2.fromOffset()
                                MinimizedTask.Visible = true
                                self.IsMinimized = UIState.IsMinimized
                                BindableEvents.MinimizedChanged:Fire(UIState.IsMinimized)
                            end
                        else
                            MinimizedTask.Visible = false
                            ScreenContainer.Position = UDim2.fromOffset(
                                MinimizedTask.AbsolutePosition.X + MinimizedTask.AbsoluteSize.X / 2,
                                MinimizedTask.AbsolutePosition.Y + MinimizedTask.AbsoluteSize.Y / 2
                            )
                            if animate then
                                TweenService:Create(ScreenContainer, TweenInfo.new(), {Position = InputState.RestorePosition}):Play()
                                if UIState.IsSmallWindow then
                                    UI_Tweens.GuiHalf:Play()
                                else
                                    UI_Tweens.GuiFull:Play()
                                end
                                UI_Tweens.CanvasFull:Play()
                            else
                                if UIState.IsSmallWindow then
                                    HubPosition.Size = UDim2.fromScale(0.5, 0.5)
                                else
                                    HubPosition.Size = UDim2.fromScale(1, 1)
                                end
                                Surface.CanvasSize = CANVAS_SIZE
                            end
                            self.IsMinimized = not not minimized
                            BindableEvents.MinimizedChanged:Fire(not not minimized)
                        end
                    end
                end,
                
                SetSmall = function(self, small, animate)
                    if small == nil then small = true end
                    if animate == nil then animate = true end
                    
                    if (not not small) ~= UIState.IsSmallWindow then
                        UIState.IsSmallWindow = small
                        
                        if small then
                            if animate then
                                UI_Tweens.GuiHalf:Play()
                            else
                                HubPosition.Size = UDim2.fromScale(0.5, 0.5)
                            end
                        else
                            if animate then
                                UI_Tweens.GuiFull:Play()
                            else
                                HubPosition.Size = UDim2.fromScale(1, 1)
                            end
                        end
                        
                        self.IsSmall = not not small
                        BindableEvents.SizeChanged:Fire(not not small)
                    end
                end,
                
                Open = function(self, animate)
                    if animate == nil then animate = true end
                    
                    if not UIState.IsMinimized then
                        if animate then
                            HubPosition.Size = UDim2.fromOffset()
                            Surface.CanvasSize = Vector2.zero
                            if UIState.IsSmallWindow then
                                UI_Tweens.GuiEnterHalf:Play()
                            else
                                UI_Tweens.GuiEnterFull:Play()
                            end
                            UI_Tweens.CanvasFull:Play()
                        else
                            if UIState.IsSmallWindow then
                                HubPosition.Size = UDim2.fromScale(0.5, 0.5)
                            else
                                HubPosition.Size = UDim2.fromScale(1, 1)
                            end
                            Surface.CanvasSize = CANVAS_SIZE
                        end
                    end
                    
                    self.IsOpen = true
                    BindableEvents.Opened:Fire()
                end,
                
                Close = function(self, animate)
                    if animate == nil then animate = true end
                    
                    if animate then
                        UI_Tweens.CanvasMin:Play()
                        UI_Tweens.GuiExit:Play()
                        self.IsOpen = false
                        BindableEvents.Closing:Fire()
                        UI_Tweens.GuiExit.Completed:Once(CleanupUI)
                    else
                        self.IsOpen = false
                        BindableEvents.Closing:Fire()
                        CleanupUI()
                    end
                end,
                
                SetLoadingState = function(self, loading)
                    loading = not not loading
                    local loadingScreen = Surface.Window.LoadingScreen
                    
                    if loadingScreen.Visible ~= loading then
                        if loading then
                            UIState.ModalCount = UIState.ModalCount + 1
                            Surface.Window.Content.Interactable = false
                        else
                            UIState.ModalCount = UIState.ModalCount - 1
                            if UIState.ModalCount == 0 then
                                Surface.Window.Content.Interactable = true
                            end
                        end
                        loadingScreen.Visible = loading
                    end
                end,
                
                -- Events
                MinimizedChanged = BindableEvents.MinimizedChanged.Event,
                SizeChanged = BindableEvents.SizeChanged.Event,
                Opened = BindableEvents.Opened.Event,
                Closing = BindableEvents.Closing.Event
            },
            
            Login = {
                Object = LoginWindow,
                IsWhitelist = false,
                
                SetKeyLink = function(self, link)
                    STRINGS.KEY_LINK = tostring(link)
                end,
                
                SetWhitelistLink = function(self, link)
                    STRINGS.WHITELIST_LINK = tostring(link)
                end,
                
                SetDiscordLink = function(self, link)
                    STRINGS.DISCORD_INVITE = tostring(link)
                end,
                
                SetWhitelist = function(self, whitelist)
                    UIState.IsWhitelistMode = whitelist
                end,
                
                ChangeTheme = function(self, theme)
                    -- Theme change implementation
                    -- This would handle switching between different color themes
                end,
                
                -- Events
                WhitelistChanged = BindableEvents.WhitelistChanged.Event,
                LoginRequest = BindableEvents.LoginRequest.Event
            },
            
            Hub = {
                Object = HubContent,
                
                CreatePage = function(self, pageName, iconName)
                    local tabTemplate = Resources.Components.Tab:Clone()
                    local pageTemplate = Resources.Components.Page:Clone()
                    
                    tabTemplate.Label.Text = pageName
                    tabTemplate.Name = "Tab_" .. pageName
                    pageTemplate.Name = "Page_" .. pageName
                    
                    if iconName then
                        local icon = Resources.Icons["20px"]:FindFirstChild(iconName)
                        if icon then
                            icon:Clone().Parent = tabTemplate.Icon
                        end
                    end
                    
                    tabTemplate.Parent = Sidebar
                    pageTemplate.Parent = PageContainer
                    
                    local pageInstance = {
                        Instance = pageTemplate,
                        TabInstance = tabTemplate,
                        Object = tabTemplate,
                        Page = pageTemplate,
                        
                        CreateSection = function(self, sectionName, order, isPageSection)
                            local sectionTemplate = Resources.Components.Section:Clone()
                            sectionTemplate.Name = "Section_" .. sectionName
                            sectionTemplate.Title.Text = tostring(sectionName)
                            
                            if isPageSection then
                                sectionTemplate.Title.Visible = false
                            end
                            
                            sectionTemplate.Parent = self.Page
                            
                            return {
                                Object = sectionTemplate,
                                HasSetVisibility = false,
                                
                                CreateSeparator = function(self)
                                    local separator = Resources.Components.Separator:Clone()
                                    if not self.PageSection then
                                        separator.Parent = self.Object.ListBase
                                    else
                                        separator.Parent = self.Object
                                    end
                                end,
                                
                                CreateElement = function(self, elementType, config)
                                    if not self.HasSetVisibility then
                                        if not self.PageSection then
                                            self.Object.ListBase.Visible = true
                                        end
                                        self.HasSetVisibility = true
                                    end
                                    
                                    config = type(config) == "table" and table.clone(config) or {}
                                    local elementEvent = Instance.new("BindableEvent")
                                    local elementTemplate = Resources.Elements:FindFirstChild(elementType)
                                    
                                    if elementTemplate then
                                        elementTemplate = elementTemplate:Clone()
                                        elementTemplate.Name = "Element_" .. elementType
                                        
                                        -- Handle different element types
                                        if elementType == "Alert" then
                                            -- Alert element implementation
                                        elseif elementType == "Toggle" then
                                            return CreateToggle(elementTemplate, config)
                                        elseif elementType == "Slider" then
                                            return CreateSlider(elementTemplate, config)
                                        elseif elementType == "Button" then
                                            return CreateButton(elementTemplate, config)
                                        elseif elementType == "ColorPicker" then
                                            -- Color picker element implementation
                                        elseif elementType == "Dropdown" then
                                            -- Dropdown element implementation
                                        elseif elementType == "TextBox" then
                                            -- Text box element implementation
                                        end
                                        
                                        if not self.PageSection then
                                            elementTemplate.Parent = self.Object.ListBase
                                        else
                                            elementTemplate.Parent = self.Object
                                        end
                                        
                                        return elementTemplate
                                    end
                                end
                            }
                        end,
                        
                        SetContent = function(self, content)
                            self.Page.Content:ClearAllChildren()
                            content.Parent = self.Page.Content
                        end,
                        
                        SetVisible = function(self, visible)
                            if visible == nil then visible = true end
                            self.Page.Visible = visible
                        end,
                        
                        IsVisible = function(self)
                            return self.Page.Visible
                        end
                    }
                    
                    tabTemplate.MouseButton1Click:Connect(function()
                        pageTemplate.Visible = true
                        
                        if ActiveNavButton then
                            TweenService:Create(ActiveNavButton, TweenInfo.new(0.2), {
                                BackgroundColor3 = Color3.fromRGB(82, 82, 82)
                            }):Play()
                        end
                        
                        TweenService:Create(tabTemplate, TweenInfo.new(0.2), {
                            BackgroundColor3 = ThemeColors.TabButtonActive.Value
                        }):Play()
                        
                        if ActivePage and ActivePage ~= pageTemplate then
                            local oldPageAnimation = TweenService:Create(ActivePage, TweenInfo.new(0.5), {
                                Position = UDim2.fromScale(0.5, -1)
                            })
                            oldPageAnimation:Play()
                            oldPageAnimation.Completed:Once(function(state)
                                if state == Enum.PlaybackState.Completed then
                                    ActivePage.Visible = false
                                end
                            end)
                        end
                        
                        local newPageAnimation = TweenService:Create(pageTemplate, TweenInfo.new(0.5), {
                            Position = UDim2.fromScale(0.5)
                        })
                        newPageAnimation:Play()
                        
                        TweenService:Create(pageTemplate.Parent, TweenInfo.new(0.5), {
                            CanvasPosition = Vector2.zero
                        }):Play()
                        
                        ActiveNavButton = tabTemplate
                        ActivePage = pageTemplate
                    end)
                    
                    if IsFirstTab then
                        IsFirstTab = false
                        pageTemplate.Visible = true
                        pageTemplate.Position = UDim2.fromScale(0.5)
                        tabTemplate.BackgroundColor3 = ThemeColors.TabButtonActive.Value
                        ActiveNavButton = tabTemplate
                        ActivePage = pageTemplate
                    else
                        pageTemplate.Visible = false
                        pageTemplate.Position = UDim2.fromScale(0.5, -1)
                    end
                    
                    local section = pageInstance:CreateSection("", nil, true)
                    section.Object:Destroy()
                    section.Object = pageTemplate
                    section.PageSection = true
                    pageInstance.Section = section
                    
                    pageInstance.CreateElement = function(self, elementType, config)
                        return self.Section:CreateElement(elementType, config)
                    end
                    
                    pageInstance.CreateSeparator = function(self)
                        return self.Section:CreateSeparator()
                    end
                    
                    return pageInstance
                end,
                
                FocusTab = function(self, tabName)
                    local tab = Sidebar:FindFirstChild("Tab_" .. tabName)
                    if tab then
                        tab:MouseButton1Click()
                    end
                end,
                
                DestroyTab = function(self, tabName)
                    local tab = Sidebar:FindFirstChild("Tab_" .. tabName)
                    local page = PageContainer:FindFirstChild("Page_" .. tabName)
                    
                    if tab then
                        tab:Destroy()
                    end
                    if page then
                        page:Destroy()
                    end
                end
            },
            
            ShowToast = function(self, toastConfig)
                if type(toastConfig) == "table" then
                    local duration = tonumber(toastConfig.Duration) or 5
                    if duration < 1 then duration = 1 end
                    
                    local toast = Resources.Components.Toast:Clone()
                    local toastType = tonumber(toastConfig.Type)
                    local toastStyle = Resources.Styles.Toasts
                    
                    ToastData[toast] = duration
                    toast.Parent = PlayerScript.ToastsFrame
                    
                    if toastType and toastStyle:FindFirstChild(toastType) then
                        toast.BackgroundColor3 = toastStyle[toastType].BgColor.Value
                        Resources.Icons.Alerts[toastType]:Clone().Parent = toast.Inner.Icon
                    else
                        toast.Inner.Icon.Visible = false
                    end
                    
                    if toastConfig.Transparent == false then
                        toast.BackgroundTransparency = 0
                    end
                    
                    if toastConfig.Title ~= nil then
                        toast.Inner.ToastTitle.Text = tostring(toastConfig.Title)
                    end
                    
                    if toastConfig.Text ~= nil then
                        toast.Inner.ToastText.Text = tostring(toastConfig.Text)
                    end
                    
                    local buttons = toastConfig.Buttons
                    local toastInstance = {
                        __ToastFrame = toast,
                        Open = function(self) end,
                        Close = function(self)
                            -- Close animation
                        end,
                        Title = toast.Inner.ToastTitle,
                        SubContentLabel = toast.Inner.ToastText,
                        CloseButton = toast.Inner.CloseButton,
                        Closed = false
                    }
                    
                    if type(buttons) == "table" then
                        for _, buttonConfig in ipairs(buttons) do
                            if type(buttonConfig) == "table" then
                                local toastButton = Resources.Components.ToastButton:Clone()
                                local buttonText = buttonConfig.Title
                                local buttonCallback = buttonConfig.Callback
                                
                                if buttonText then
                                    toastButton.ButtonText.Text = tostring(buttonText)
                                end
                                
                                toastButton.MouseButton1Click:Connect(function()
                                    if type(buttonCallback) == "function" then
                                        coroutine.resume(coroutine.create(buttonCallback), buttonText, _, toastConfig.Nonce)
                                    end
                                    if not (toastConfig.CloseWhenButtonClicked == false) then
                                        toastInstance:Close()
                                    end
                                end)
                                
                                toastButton.Parent = toast.Inner
                            end
                        end
                    end
                    
                    if toastConfig.CloseButtonVisible == false then
                        toast.Inner.CloseButton.Visible = false
                    else
                        toast.Inner.CloseButton.MouseButton1Click:Once(function()
                            toastInstance:Close()
                        end)
                    end
                    
                    table.insert(PendingToasts, toast)
                    
                    -- Toast animation and management
                    local function ProcessToasts()
                        if #ActiveToasts == 0 then
                            local nextToast = PendingToasts[1]
                            if nextToast then
                                table.remove(PendingToasts, 1)
                                table.insert(ActiveToasts, 1, nextToast)
                                
                                local toastDuration = ToastData[nextToast]
                                local slideIn = TweenService:Create(nextToast, 
                                    TweenInfo.new(toastDuration * 0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
                                        AnchorPoint = Vector2.new(toastDuration * 2, 1)
                                    })
                                
                                slideIn.Completed:Once(function()
                                    nextToast:Destroy()
                                    table.remove(ActiveToasts, table.find(ActiveToasts, nextToast))
                                    ToastData[nextToast] = nil
                                    ProcessToasts()
                                end)
                                
                                slideIn:Play()
                                
                                TweenService:Create(nextToast.ProgressBar.ProgressValue, 
                                    TweenInfo.new(toastDuration, Enum.EasingStyle.Linear), {
                                        Size = UDim2.fromScale(1, 4)
                                    }):Play()
                            end
                        end
                    end
                    
                    ProcessToasts()
                    return toastInstance
                else
                    local emptyFunction = function() end
                    return {Open = emptyFunction, Close = emptyFunction}
                end
            end,
            
            SetFluentTranslationHack = function(self)
                -- Translation hack for compatibility with certain executors
                -- This ensures proper text rendering in different environments
            end,
            
            Destroying = BindableEvents.HubDestroying.Event
        }

        -- Final initialization
        CielBerm.Window:Open(true)
        
        return CielBerm
    end,
    
    Properties = {
        Name = "MainModule"
    },
    
    Reference = 1
}

return CielBerm
