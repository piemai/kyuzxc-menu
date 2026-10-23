--// Kyuzxc Simple Mod Menu (iPad Edition + Resizable, Responsive Violet Sidebar & Fully Working Functions)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local uiParent = (gethui and gethui()) or CoreGui

-- Linisin ang lumang UI kung naka-load na
if uiParent:FindFirstChild("KyuzxcModMenu") then
    uiParent.KyuzxcModMenu:Destroy()
end
if uiParent:FindFirstChild("KyuzxcVisualsGui") then
    uiParent.KyuzxcVisualsGui:Destroy()
end
if uiParent:FindFirstChild("KyuzxcMobileAimBtn") then
    uiParent.KyuzxcMobileAimBtn:Destroy()
end

--// Notification Helper
local function notify(msg)
    print("[Kyuzxc] " .. msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kyuzxc Menu",
            Text = msg,
            Duration = 3
        })
    end)
end

--// Feature States
local showteam = true
local showenemy = true
local espenabled = true
local boxenabled = true
local skeletonenabled = true
local tracerenabled = true
local showdist = true
local maxEspDistance = 300
local noclipped = false
local infjumpenabled = false
local speedenabled = false
local customWalkSpeed = 50
local jumppowerenabled = false
local customJumpPower = 100
local gravityenabled = false
local customGravity = 80
local flyenabled = false
local customFlySpeed = 60
local godmodeenabled = false
local spinbotenabled = false
local spinSpeed = 35
local antiafkenabled = true
local hitboxenabled = false
local hitboxSize = 12
local fovcircleenabled = false
local fovradius = 120
local aimbotenabled = false
local aimbotactive = false
local targetPartOption = "Head"
local aimbotSmoothing = 0.3
local selectedTargetPlayer = nil

-- New Extended States
local panicEnabled = false
local healthBarEnabled = true
local chamsEnabled = false
local offscreenArrowsEnabled = false
local autoClickerEnabled = false
local autoClickerInterval = 0.1
local antiVoidEnabled = false
local viewmodelFovValue = 70
local silentAimEnabled = false
local triggerBotEnabled = false

--// POV, Camera & Extra Visual States
local povenabled = false
local cameraFovValue = 90
local povOffsetX = 0
local povOffsetY = 0
local povOffsetZ = 0
local unlockZoomEnabled = false
local customMaxZoom = 500
local shiftlockEnabled = false
local spectateEnabled = false
local fullbrightEnabled = false
local crosshairEnabled = false

-- Backup Default Lighting & Camera Values
local defaultLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}
local defaultMaxZoom = player.CameraMaxZoomDistance
local defaultGravity = workspace.Gravity
local sliderResetCallbacks = {}

--// ESP Colors & Violet Theme
local teamColor = Color3.fromRGB(0, 255, 120)   -- Green (Team)
local enemyColor = Color3.fromRGB(255, 75, 75)  -- Red (Enemy)
local accentColor = Color3.fromRGB(165, 95, 255) -- Violet Accent

--// Anti-AFK Connection
player.Idled:Connect(function()
    if antiafkenabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end
end)

--// Upgraded God Mode Helper (Anti-Killbrick / CanTouch Bypass + Dead State Protection)
local function setGodModeState(char, enabled)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, not enabled)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not enabled)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not enabled)
            if enabled and humanoid.Health > 0 then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanTouch = not enabled
        end
    end
end

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.3)
    if godmodeenabled then
        setGodModeState(newChar, true)
    end
end)

--// Reset Hitboxes Helper
local function resetEnemyHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end)
            end
        end
    end
end

--// Floating Draggable Mobile Aimbot Toggle Button
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "KyuzxcMobileAimBtn"
mobileGui.ResetOnSpawn = false
mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
mobileGui.Parent = uiParent

local aimToggleButton = Instance.new("TextButton")
aimToggleButton.Size = UDim2.new(0, 75, 0, 75)
aimToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
aimToggleButton.Position = UDim2.new(0.5, 0, 0.85, 0)
aimToggleButton.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
aimToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
aimToggleButton.Text = "AIM: OFF"
aimToggleButton.Font = Enum.Font.GothamBold
aimToggleButton.TextSize = 11
aimToggleButton.Active = true
aimToggleButton.Visible = false
aimToggleButton.Parent = mobileGui

local aimBtnCorner = Instance.new("UICorner")
aimBtnCorner.CornerRadius = UDim.new(1, 0)
aimBtnCorner.Parent = aimToggleButton

local aimBtnStroke = Instance.new("UIStroke")
aimBtnStroke.Color = Color3.fromRGB(255, 75, 75)
aimBtnStroke.Thickness = 2
aimBtnStroke.Parent = aimToggleButton

--// Custom Smooth Draggable Logic for Touch/Mouse
local dragging, dragStart, startPos

aimToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = aimToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        aimToggleButton.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

local clickTimer = 0
aimToggleButton.MouseButton1Down:Connect(function()
    clickTimer = tick()
end)

aimToggleButton.MouseButton1Up:Connect(function()
    if tick() - clickTimer < 0.2 then
        aimbotactive = not aimbotactive
        if aimbotactive then
            aimToggleButton.BackgroundColor3 = Color3.fromRGB(93, 205, 151)
            aimToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            aimBtnStroke.Color = accentColor
            aimToggleButton.Text = "AIM: ON"
            notify("Mobile Aimbot Enabled")
        else
            aimToggleButton.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
            aimToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
            aimBtnStroke.Color = Color3.fromRGB(255, 75, 75)
            aimToggleButton.Text = "AIM: OFF"
            notify("Mobile Aimbot Disabled")
        end
    end
end)

--// Teleport Logic
local function teleportToTarget()
    local myChar = player.Character
    if selectedTargetPlayer and selectedTargetPlayer.Character and selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = selectedTargetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            notify("Teleported to " .. selectedTargetPlayer.Name)
        else
            notify("Your character is not spawned.")
        end
    else
        notify("No target selected or player left.")
    end
end

--// FPS Booster Helper
local function applyFpsBoost()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChildOfClass("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    notify("FPS Boost applied! Shadows & particles reduced.")
end

--// Server Hop Helper
local function serverHop()
    notify("Searching for another server...")
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and result and result.data then
        for _, srv in ipairs(result.data) do
            if type(srv) == "table" and srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, player)
                return
            end
        end
    end
    notify("No available server found right now.")
end

--// Library Framework (Resizable & Responsive Sidebar Edition)
local Library = {
    Windows = {}
}

function Library:CreateWindow(title)
    local window = {
        Title = title,
        Categories = {}
    }
    
    function window:CreateCategory(catName)
        local category = {
            Name = catName,
            Tabs = {}
        }
        
        function category:CreateTab(name, config, callback)
            table.insert(category.Tabs, {
                Name = name,
                State = config and config.enabled or false,
                Callback = callback,
                IsButton = config and config.isButton or false,
                IsScrollingDropdown = config and config.isScrollingDropdown or false,
                IsSpeedInput = config and config.isSpeedInput or false,
                IsFovInput = config and config.isFovInput or false,
                IsMaxDistInput = config and config.isMaxDistInput or false,
                IsPartDropdown = config and config.isPartDropdown or false,
                IsSmoothDropdown = config and config.isSmoothDropdown or false,
                IsSlider = config and config.isSlider or false,
                Min = config and config.min or 0,
                Max = config and config.max or 100,
                Default = config and config.default or 50,
                Step = config and config.step or 1,
                ResetGroup = config and config.resetGroup or nil
            })
        end
        
        table.insert(window.Categories, category)
        return category
    end
    
    table.insert(Library.Windows, window)
    return window
end

function Library:Load()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KyuzxcModMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = uiParent
    
    for _, win in ipairs(self.Windows) do
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 440, 0, 360)
        mainFrame.Position = UDim2.new(0.5, -220, 0.3, -180)
        mainFrame.BackgroundColor3 = Color3.fromRGB(17, 14, 27)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 12)
        mainCorner.Parent = mainFrame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = accentColor
        stroke.Thickness = 1.5
        stroke.Transparency = 0.3
        stroke.Parent = mainFrame

        --// Header
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 42)
        header.BackgroundColor3 = Color3.fromRGB(27, 21, 42)
        header.BorderSizePixel = 0
        header.Parent = mainFrame

        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 12)
        headerCorner.Parent = header

        local titleBar = Instance.new("TextLabel")
        titleBar.Size = UDim2.new(1, -70, 1, 0)
        titleBar.BackgroundTransparency = 1
        titleBar.TextColor3 = Color3.fromRGB(205, 170, 255)
        titleBar.Font = Enum.Font.GothamBold
        titleBar.TextSize = 13
        titleBar.TextXAlignment = Enum.TextXAlignment.Left
        titleBar.Position = UDim2.new(0, 14, 0, 0)
        titleBar.Text = "  " .. string.upper(win.Title)
        titleBar.Parent = header
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 26, 0, 26)
        closeBtn.Position = UDim2.new(1, -32, 0, 8)
        closeBtn.BackgroundColor3 = Color3.fromRGB(210, 75, 100)
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Text = "×"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.Parent = header
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            screenGui:Destroy()
            if uiParent:FindFirstChild("KyuzxcVisualsGui") then
                uiParent.KyuzxcVisualsGui:Destroy()
            end
            if uiParent:FindFirstChild("KyuzxcMobileAimBtn") then
                uiParent.KyuzxcMobileAimBtn:Destroy()
            end
            notify("Menu closed and unloaded.")
        end)
        
        local minBtn = Instance.new("TextButton")
        minBtn.Size = UDim2.new(0, 26, 0, 26)
        minBtn.Position = UDim2.new(1, -64, 0, 8)
        minBtn.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
        minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minBtn.Text = "-"
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 14
        minBtn.Parent = header
        
        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 6)
        minCorner.Parent = minBtn

        --// Sidebar Navigation (Kaliwa - Responsive Size)
        local sidebar = Instance.new("ScrollingFrame")
        sidebar.Size = UDim2.new(0, 120, 1, -54)
        sidebar.Position = UDim2.new(0, 8, 0, 48)
        sidebar.BackgroundColor3 = Color3.fromRGB(27, 21, 42)
        sidebar.BorderSizePixel = 0
        sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
        sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sidebar.ScrollBarThickness = 2
        sidebar.ScrollBarImageColor3 = accentColor
        sidebar.Parent = mainFrame

        local sideCorner = Instance.new("UICorner")
        sideCorner.CornerRadius = UDim.new(0, 8)
        sideCorner.Parent = sidebar

        local sideLayout = Instance.new("UIListLayout")
        sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sideLayout.Padding = UDim.new(0, 6)
        sideLayout.Parent = sidebar

        local sidePadding = Instance.new("UIPadding")
        sidePadding.PaddingTop = UDim.new(0, 6)
        sidePadding.PaddingLeft = UDim.new(0, 6)
        sidePadding.PaddingRight = UDim.new(0, 6)
        sidePadding.Parent = sidebar
        
        --// Content Container (Kanan - Responsive)
        local contentContainer = Instance.new("ScrollingFrame")
        contentContainer.Size = UDim2.new(1, -140, 1, -54)
        contentContainer.Position = UDim2.new(0, 134, 0, 48)
        contentContainer.BackgroundTransparency = 1
        contentContainer.BorderSizePixel = 0
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
        contentContainer.ScrollBarThickness = 3
        contentContainer.ScrollBarImageColor3 = accentColor
        contentContainer.Parent = mainFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.Parent = contentContainer

        --// Resize Grip (Pang-resize ng Menu sa iPad/PC)
        local resizeGrip = Instance.new("TextButton")
        resizeGrip.Name = "ResizeGrip"
        resizeGrip.Size = UDim2.fromOffset(20, 20)
        resizeGrip.Position = UDim2.new(1, -20, 1, -20)
        resizeGrip.BackgroundColor3 = accentColor
        resizeGrip.Text = "↘"
        resizeGrip.TextColor3 = Color3.fromRGB(255, 255, 255)
        resizeGrip.Font = Enum.Font.GothamBold
        resizeGrip.TextSize = 12
        resizeGrip.BorderSizePixel = 0
        resizeGrip.ZIndex = 10
        resizeGrip.Parent = mainFrame

        local gripCorner = Instance.new("UICorner")
        gripCorner.CornerRadius = UDim.new(0, 6)
        gripCorner.Parent = resizeGrip

        local resizing, resizeStart, sizeStart = false, nil, nil
        resizeGrip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStart = input.Position
                sizeStart = mainFrame.AbsoluteSize
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then resizing = false end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStart
                local minW, minH = 360, 280
                local maxW, maxH = 700, 600
                mainFrame.Size = UDim2.fromOffset(
                    math.clamp(sizeStart.X + delta.X, minW, maxW),
                    math.clamp(sizeStart.Y + delta.Y, minH, maxH)
                )
            end
        end)
        
        local categoryFrames = {}
        local categoryButtons = {}
        
        for _, cat in ipairs(win.Categories) do
            local cBtn = Instance.new("TextButton")
            cBtn.Size = UDim2.new(1, 0, 0, 32)
            cBtn.BackgroundColor3 = Color3.fromRGB(49, 41, 63)
            cBtn.TextColor3 = Color3.fromRGB(170, 158, 190)
            cBtn.Text = cat.Name
            cBtn.Font = Enum.Font.GothamBold
            cBtn.TextSize = 11
            cBtn.Parent = sidebar
            
            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 6)
            cCorner.Parent = cBtn
            
            local itemHolder = Instance.new("Frame")
            itemHolder.Size = UDim2.new(1, 0, 0, 0)
            itemHolder.BackgroundTransparency = 1
            itemHolder.Visible = false
            itemHolder.AutomaticSize = Enum.AutomaticSize.Y
            itemHolder.Parent = contentContainer
            
            local itemLayout = Instance.new("UIListLayout")
            itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            itemLayout.Padding = UDim.new(0, 6)
            itemLayout.Parent = itemHolder
            
            for idx, tab in ipairs(cat.Tabs) do
                if tab.IsSlider then
                    local sliderContainer = Instance.new("Frame")
                    sliderContainer.LayoutOrder = idx * 2
                    sliderContainer.Size = UDim2.new(1, 0, 0, 50)
                    sliderContainer.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
                    sliderContainer.BorderSizePixel = 0
                    sliderContainer.Parent = itemHolder

                    local sCorner = Instance.new("UICorner")
                    sCorner.CornerRadius = UDim.new(0, 6)
                    sCorner.Parent = sliderContainer

                    local sLabel = Instance.new("TextLabel")
                    sLabel.Size = UDim2.new(1, -80, 0, 22)
                    sLabel.Position = UDim2.new(0, 10, 0, 4)
                    sLabel.BackgroundTransparency = 1
                    sLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
                    sLabel.Font = Enum.Font.GothamBold
                    sLabel.TextSize = 11
                    sLabel.TextXAlignment = Enum.TextXAlignment.Left
                    sLabel.Text = tab.Name
                    sLabel.Parent = sliderContainer

                    local valBox = Instance.new("TextBox")
                    valBox.Size = UDim2.new(0, 58, 0, 20)
                    valBox.Position = UDim2.new(1, -66, 0, 5)
                    valBox.BackgroundColor3 = Color3.fromRGB(17, 14, 27)
                    valBox.TextColor3 = accentColor
                    valBox.Font = Enum.Font.GothamBold
                    valBox.TextSize = 11
                    valBox.Text = tostring(tab.Default)
                    valBox.Parent = sliderContainer

                    local vCorner = Instance.new("UICorner")
                    vCorner.CornerRadius = UDim.new(0, 4)
                    vCorner.Parent = valBox

                    local track = Instance.new("Frame")
                    track.Size = UDim2.new(1, -20, 0, 8)
                    track.Position = UDim2.new(0, 10, 0, 32)
                    track.BackgroundColor3 = Color3.fromRGB(22, 17, 34)
                    track.BorderSizePixel = 0
                    track.Parent = sliderContainer

                    local tCorner = Instance.new("UICorner")
                    tCorner.CornerRadius = UDim.new(1, 0)
                    tCorner.Parent = track

                    local fill = Instance.new("Frame")
                    local initAlpha = math.clamp((tab.Default - tab.Min) / (tab.Max - tab.Min), 0, 1)
                    fill.Size = UDim2.new(initAlpha, 0, 1, 0)
                    fill.BackgroundColor3 = accentColor
                    fill.BorderSizePixel = 0
                    fill.Parent = track

                    local fCorner = Instance.new("UICorner")
                    fCorner.CornerRadius = UDim.new(1, 0)
                    fCorner.Parent = fill

                    local currentVal = tab.Default
                    local function setSliderValue(val)
                        local snapped = math.floor((val / tab.Step) + 0.5) * tab.Step
                        snapped = tonumber(string.format("%.2f", math.clamp(snapped, tab.Min, tab.Max)))
                        currentVal = snapped
                        local alpha = math.clamp((snapped - tab.Min) / (tab.Max - tab.Min), 0, 1)
                        fill.Size = UDim2.new(alpha, 0, 1, 0)
                        valBox.Text = tostring(snapped)
                        if tab.Callback then
                            tab.Callback(snapped)
                        end
                    end

                    if tab.ResetGroup == "POV" then
                        table.insert(sliderResetCallbacks, function()
                            setSliderValue(tab.Default)
                        end)
                    end

                    local sliding = false
                    local function updateFromInput(input)
                        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        local rawVal = tab.Min + (tab.Max - tab.Min) * relX
                        setSliderValue(rawVal)
                    end

                    track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = true
                            updateFromInput(input)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            updateFromInput(input)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = false
                        end
                    end)

                    valBox.FocusLost:Connect(function()
                        local num = tonumber(valBox.Text)
                        if num then
                            setSliderValue(num)
                        else
                            valBox.Text = tostring(currentVal)
                        end
                    end)
                else
                    local togButton = Instance.new("TextButton")
                    togButton.LayoutOrder = idx * 2
                    togButton.Size = UDim2.new(1, 0, 0, 34)
                    
                    if tab.IsButton then
                        togButton.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
                        togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        togButton.Text = tab.Name
                    elseif tab.IsSpeedInput or tab.IsFovInput or tab.IsMaxDistInput then
                        togButton.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
                        togButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        if tab.IsSpeedInput then
                            togButton.Text = "  Speed Value:"
                        elseif tab.IsFovInput then
                            togButton.Text = "  FOV Radius:"
                        else
                            togButton.Text = "  Max ESP Dist:"
                        end
                        togButton.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local textBox = Instance.new("TextBox")
                        textBox.Size = UDim2.new(0, 75, 0, 24)
                        textBox.Position = UDim2.new(1, -80, 0.5, -12)
                        textBox.BackgroundColor3 = Color3.fromRGB(17, 14, 27)
                        textBox.TextColor3 = accentColor
                        if tab.IsSpeedInput then
                            textBox.Text = tostring(customWalkSpeed)
                        elseif tab.IsFovInput then
                            textBox.Text = tostring(fovradius)
                        else
                            textBox.Text = tostring(maxEspDistance)
                        end
                        textBox.Font = Enum.Font.GothamBold
                        textBox.TextSize = 11
                        textBox.Parent = togButton
                        
                        local boxCorner = Instance.new("UICorner")
                        boxCorner.CornerRadius = UDim.new(0, 4)
                        boxCorner.Parent = textBox
                        
                        textBox.FocusLost:Connect(function()
                            local num = tonumber(textBox.Text)
                            if num then
                                if tab.IsSpeedInput then
                                    customWalkSpeed = num
                                    notify("WalkSpeed set to: " .. num)
                                elseif tab.IsFovInput then
                                    fovradius = num
                                    notify("FOV Radius set to: " .. num)
                                else
                                    maxEspDistance = num
                                    notify("Max ESP Distance set to: " .. num)
                                end
                                textBox.Text = tostring(num)
                            else
                                if tab.IsSpeedInput then
                                    textBox.Text = tostring(customWalkSpeed)
                                elseif tab.IsFovInput then
                                    textBox.Text = tostring(fovradius)
                                else
                                    textBox.Text = tostring(maxEspDistance)
                                end
                            end
                        end)
                    elseif tab.IsPartDropdown then
                        togButton.BackgroundColor3 = Color3.fromRGB(90, 40, 150)
                        togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        togButton.Text = "Aim Part: " .. targetPartOption .. " ▼"
                        
                        local partFrame = Instance.new("Frame")
                        partFrame.LayoutOrder = (idx * 2) + 1
                        partFrame.Size = UDim2.new(1, 0, 0, 96)
                        partFrame.BackgroundColor3 = Color3.fromRGB(27, 21, 42)
                        partFrame.BorderSizePixel = 0
                        partFrame.Visible = false
                        partFrame.Parent = itemHolder
                        
                        local partCorner = Instance.new("UICorner")
                        partCorner.CornerRadius = UDim.new(0, 6)
                        partCorner.Parent = partFrame

                        local partLayout = Instance.new("UIListLayout")
                        partLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        partLayout.Padding = UDim.new(0, 4)
                        partLayout.Parent = partFrame

                        local parts = {"Head", "UpperTorso", "HumanoidRootPart"}
                        for _, ptName in ipairs(parts) do
                            local pBtn = Instance.new("TextButton")
                            pBtn.Size = UDim2.new(1, 0, 0, 28)
                            pBtn.BackgroundColor3 = (targetPartOption == ptName) and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                            pBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
                            pBtn.Text = "Target: " .. ptName
                            pBtn.Font = Enum.Font.GothamBold
                            pBtn.TextSize = 11
                            pBtn.Parent = partFrame
                            
                            local pCorner = Instance.new("UICorner")
                            pCorner.CornerRadius = UDim.new(0, 4)
                            pCorner.Parent = pBtn
                            
                            pBtn.MouseButton1Click:Connect(function()
                                targetPartOption = ptName
                                togButton.Text = "Aim Part: " .. ptName .. " ▼"
                                notify("Aimbot Part set to: " .. ptName)
                                partFrame.Visible = false
                            end)
                        end

                        togButton.MouseButton1Click:Connect(function()
                            partFrame.Visible = not partFrame.Visible
                        end)
                    elseif tab.IsSmoothDropdown then
                        togButton.BackgroundColor3 = Color3.fromRGB(110, 50, 180)
                        togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        togButton.Text = "Aim Mode: Medium ▼"
                        
                        local smoothFrame = Instance.new("Frame")
                        smoothFrame.LayoutOrder = (idx * 2) + 1
                        smoothFrame.Size = UDim2.new(1, 0, 0, 128)
                        smoothFrame.BackgroundColor3 = Color3.fromRGB(27, 21, 42)
                        smoothFrame.BorderSizePixel = 0
                        smoothFrame.Visible = false
                        smoothFrame.Parent = itemHolder
                        
                        local smoothCorner = Instance.new("UICorner")
                        smoothCorner.CornerRadius = UDim.new(0, 6)
                        smoothCorner.Parent = smoothFrame

                        local smoothLayout = Instance.new("UIListLayout")
                        smoothLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        smoothLayout.Padding = UDim.new(0, 4)
                        smoothLayout.Parent = smoothFrame

                        local modes = {
                            {Name = "Hard (Instant)", Val = 0},
                            {Name = "Medium (Balanced)", Val = 0.3},
                            {Name = "Low (Smooth)", Val = 0.6}
                        }
                        for _, mode in ipairs(modes) do
                            local mBtn = Instance.new("TextButton")
                            mBtn.Size = UDim2.new(1, 0, 0, 28)
                            mBtn.BackgroundColor3 = (aimbotSmoothing == mode.Val) and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                            mBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
                            mBtn.Text = mode.Name
                            mBtn.Font = Enum.Font.GothamBold
                            mBtn.TextSize = 11
                            mBtn.Parent = smoothFrame
                            
                            local mCorner = Instance.new("UICorner")
                            mCorner.CornerRadius = UDim.new(0, 4)
                            mCorner.Parent = mBtn
                            
                            mBtn.MouseButton1Click:Connect(function()
                                aimbotSmoothing = mode.Val
                                togButton.Text = "Aim Mode: " .. mode.Name .. " ▼"
                                notify("Aimbot Mode: " .. mode.Name)
                                smoothFrame.Visible = false
                            end)
                        end

                        togButton.MouseButton1Click:Connect(function()
                            smoothFrame.Visible = not smoothFrame.Visible
                        end)
                    elseif tab.IsScrollingDropdown then
                        togButton.BackgroundColor3 = Color3.fromRGB(80, 40, 160)
                        togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        togButton.Text = "Target: [Select Player] ▼"
                        
                        local dropFrame = Instance.new("ScrollingFrame")
                        dropFrame.LayoutOrder = (idx * 2) + 1
                        dropFrame.Size = UDim2.new(1, 0, 0, 180)
                        dropFrame.BackgroundColor3 = Color3.fromRGB(27, 21, 42)
                        dropFrame.BorderSizePixel = 0
                        dropFrame.Visible = true
                        dropFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                        dropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        dropFrame.ScrollBarThickness = 3
                        dropFrame.ScrollBarImageColor3 = accentColor
                        dropFrame.Parent = itemHolder
                        
                        local dropCorner = Instance.new("UICorner")
                        dropCorner.CornerRadius = UDim.new(0, 6)
                        dropCorner.Parent = dropFrame

                        local dropLayout = Instance.new("UIListLayout")
                        dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        dropLayout.Padding = UDim.new(0, 4)
                        dropLayout.Parent = dropFrame
                        
                        local function refreshPlayerList()
                            for _, child in ipairs(dropFrame:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child:Destroy()
                                end
                            end
                            
                            local refreshBtn = Instance.new("TextButton")
                            refreshBtn.Size = UDim2.new(1, 0, 0, 28)
                            refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 180)
                            refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            refreshBtn.Text = "↻ Refresh Player List"
                            refreshBtn.Font = Enum.Font.GothamBold
                            refreshBtn.TextSize = 11
                            refreshBtn.Parent = dropFrame
                            
                            local refCorner = Instance.new("UICorner")
                            refCorner.CornerRadius = UDim.new(0, 4)
                            refCorner.Parent = refreshBtn
                            
                            refreshBtn.MouseButton1Click:Connect(function()
                                refreshPlayerList()
                                notify("Player list refreshed!")
                            end)
                            
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= player then
                                    local pBtn = Instance.new("TextButton")
                                    pBtn.Size = UDim2.new(1, 0, 0, 28)
                                    pBtn.BackgroundColor3 = (selectedTargetPlayer == p) and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                                    pBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
                                    pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                                    pBtn.Font = Enum.Font.GothamBold
                                    pBtn.TextSize = 11
                                    pBtn.Parent = dropFrame
                                    
                                    local pCorner = Instance.new("UICorner")
                                    pCorner.CornerRadius = UDim.new(0, 4)
                                    pCorner.Parent = pBtn
                                    
                                    pBtn.MouseButton1Click:Connect(function()
                                        selectedTargetPlayer = p
                                        togButton.Text = "Target: " .. p.Name .. " ▼"
                                        refreshPlayerList()
                                        notify("Target selected: " .. p.Name)
                                    end)
                                end
                            end
                        end
                        
                        refreshPlayerList()
                        Players.PlayerAdded:Connect(refreshPlayerList)
                        Players.PlayerRemoving:Connect(function(leavingPlayer)
                            if selectedTargetPlayer == leavingPlayer then
                                selectedTargetPlayer = nil
                                togButton.Text = "Target: [Select Player] ▼"
                            end
                            refreshPlayerList()
                        end)
                        
                        togButton.MouseButton1Click:Connect(function()
                            dropFrame.Visible = not dropFrame.Visible
                            if dropFrame.Visible then
                                refreshPlayerList()
                            end
                        end)
                    else
                        togButton.BackgroundColor3 = tab.State and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                        togButton.TextColor3 = tab.State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
                        togButton.Text = "  " .. tab.Name .. " : " .. (tab.State and "ON" or "OFF")
                        togButton.TextXAlignment = Enum.TextXAlignment.Left
                    end
                    
                    if not tab.IsSpeedInput and not tab.IsFovInput and not tab.IsMaxDistInput and not tab.IsScrollingDropdown and not tab.IsPartDropdown and not tab.IsSmoothDropdown and not tab.IsButton then
                        local pad = Instance.new("UIPadding")
                        pad.PaddingLeft = UDim.new(0, 6)
                        pad.Parent = togButton
                    end

                    if not tab.IsSpeedInput and not tab.IsFovInput and not tab.IsMaxDistInput then
                        togButton.Font = Enum.Font.GothamBold
                        togButton.TextSize = 11
                    end
                    togButton.Parent = itemHolder
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = togButton
                    
                    local currentState = tab.State
                    if not tab.IsButton and not tab.IsScrollingDropdown and not tab.IsPartDropdown and not tab.IsSmoothDropdown and not tab.IsSpeedInput and not tab.IsFovInput and not tab.IsMaxDistInput then
                        togButton.MouseButton1Click:Connect(function()
                            currentState = not currentState
                            togButton.Text = "  " .. tab.Name .. " : " .. (currentState and "ON" or "OFF")
                            togButton.BackgroundColor3 = currentState and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                            togButton.TextColor3 = currentState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
                            if tab.Callback then tab.Callback(currentState) end
                        end)
                    elseif tab.IsButton then
                        togButton.MouseButton1Click:Connect(function()
                            if tab.Callback then tab.Callback() end
                        end)
                    end
                end
            end
            
            table.insert(categoryFrames, itemHolder)
            table.insert(categoryButtons, cBtn)
            
            cBtn.MouseButton1Click:Connect(function()
                for _, holder in ipairs(categoryFrames) do holder.Visible = false end
                for _, btn in ipairs(categoryButtons) do 
                    btn.BackgroundColor3 = Color3.fromRGB(49, 41, 63)
                    btn.TextColor3 = Color3.fromRGB(170, 158, 190)
                end
                itemHolder.Visible = true
                cBtn.BackgroundColor3 = accentColor
                cBtn.TextColor3 = Color3.fromRGB(245, 240, 255)
            end)
        end
        
        if categoryFrames[1] then
            categoryFrames[1].Visible = true
            categoryButtons[1].BackgroundColor3 = accentColor
            categoryButtons[1].TextColor3 = Color3.fromRGB(245, 240, 255)
        end
        
        --// Minimize Logic
        local minimized = false
        local previousSize = mainFrame.Size
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                previousSize = mainFrame.Size
                sidebar.Visible = false
                contentContainer.Visible = false
                resizeGrip.Visible = false
                mainFrame.Size = UDim2.new(0, previousSize.X.Offset, 0, 42)
                minBtn.Text = "+"
            else
                mainFrame.Size = previousSize
                sidebar.Visible = true
                contentContainer.Visible = true
                resizeGrip.Visible = true
                minBtn.Text = "-"
            end
        end)
    end
end

local Window = Library:CreateWindow("kyuzxc simple mod menu [ipad]")

--// Category 1: Movement
local catMovement = Window:CreateCategory("Movement")
catMovement:CreateTab("god mode (anti-touch)", {enabled = false}, function(tog) 
    godmodeenabled = tog
    if player.Character then
        setGodModeState(player.Character, tog)
    end
    notify("God Mode (Anti-Killbrick): " .. (tog and "ON" or "OFF"))
end)
catMovement:CreateTab("noclip", {enabled = false}, function(tog) 
    noclipped = tog 
    if not tog and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)
catMovement:CreateTab("inf jump", {enabled = false}, function(tog) 
    infjumpenabled = tog 
end) 
catMovement:CreateTab("speed hack", {enabled = false}, function(tog) 
    speedenabled = tog 
    if not tog and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end)
catMovement:CreateTab("speed value", {isSpeedInput = true})
catMovement:CreateTab("jump power hack", {enabled = false}, function(tog)
    jumppowerenabled = tog
    if not tog and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = 50 end
    end
end)
catMovement:CreateTab("jump power", {isSlider = true, min = 50, max = 300, default = 100, step = 5}, function(val)
    customJumpPower = val
end)
catMovement:CreateTab("low gravity", {enabled = false}, function(tog)
    gravityenabled = tog
    if not tog then
        workspace.Gravity = defaultGravity
    end
end)
catMovement:CreateTab("gravity value", {isSlider = true, min = 10, max = 196, default = 80, step = 2}, function(val)
    customGravity = val
end)
catMovement:CreateTab("fly (ipad + pc)", {enabled = false}, function(tog) 
    flyenabled = tog 
end)
catMovement:CreateTab("fly speed", {isSlider = true, min = 20, max = 250, default = 60, step = 5}, function(val)
    customFlySpeed = val
end)
catMovement:CreateTab("anti-void protection", {enabled = false}, function(tog)
    antiVoidEnabled = tog
    notify("Anti-Void Protection: " .. (tog and "ON" or "OFF"))
end)

--// Category 2: Visuals
local catVisuals = Window:CreateCategory("Visuals")
catVisuals:CreateTab("esp team (green)", {enabled = true}, function(tog) showteam = tog end)
catVisuals:CreateTab("esp enemy (red)", {enabled = true}, function(tog) showenemy = tog end)
catVisuals:CreateTab("esp names", {enabled = true}, function(tog) espenabled = tog end)
catVisuals:CreateTab("esp boxes", {enabled = true}, function(tog) boxenabled = tog end)
catVisuals:CreateTab("esp health bar", {enabled = true}, function(tog) healthBarEnabled = tog end)
catVisuals:CreateTab("esp skeleton", {enabled = true}, function(tog) skeletonenabled = tog end)
catVisuals:CreateTab("esp tracers", {enabled = true}, function(tog) tracerenabled = tog end)
catVisuals:CreateTab("off-screen arrows", {enabled = false}, function(tog) offscreenArrowsEnabled = tog end)
catVisuals:CreateTab("distance tags", {enabled = true}, function(tog) showdist = tog end)
catVisuals:CreateTab("max esp distance", {isMaxDistInput = true})
catVisuals:CreateTab("chams / material glow", {enabled = false}, function(tog)
    chamsEnabled = tog
    notify("Chams Glow: " .. (tog and "ON" or "OFF"))
end)
catVisuals:CreateTab("center crosshair", {enabled = false}, function(tog) crosshairEnabled = tog end)
catVisuals:CreateTab("fullbright (no fog)", {enabled = false}, function(tog)
    fullbrightEnabled = tog
    if not tog then
        Lighting.Brightness = defaultLighting.Brightness
        Lighting.ClockTime = defaultLighting.ClockTime
        Lighting.FogEnd = defaultLighting.FogEnd
        Lighting.GlobalShadows = defaultLighting.GlobalShadows
        Lighting.Ambient = defaultLighting.Ambient
    end
end)
catVisuals:CreateTab("fps booster (anti-lag)", {isButton = true}, function()
    applyFpsBoost()
end)

--// Category 3: Combat (Aimbot, Hitbox & FOV)
local catCombat = Window:CreateCategory("Combat")
catCombat:CreateTab("aimbot button", {enabled = false}, function(tog) 
    aimbotenabled = tog 
    aimToggleButton.Visible = tog
    if not tog then
        aimbotactive = false
        aimToggleButton.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
        aimToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
        aimBtnStroke.Color = Color3.fromRGB(255, 75, 75)
        aimToggleButton.Text = "AIM: OFF"
    end
end)
catCombat:CreateTab("aim part", {isPartDropdown = true})
catCombat:CreateTab("aim smoothness", {isSmoothDropdown = true})
catCombat:CreateTab("silent aim", {enabled = false}, function(tog)
    silentAimEnabled = tog
    notify("Silent Aim: " .. (tog and "ON" or "OFF"))
end)
catCombat:CreateTab("triggerbot", {enabled = false}, function(tog)
    triggerBotEnabled = tog
    notify("Triggerbot: " .. (tog and "ON" or "OFF"))
end)
catCombat:CreateTab("fov circle", {enabled = false}, function(tog) fovcircleenabled = tog end)
catCombat:CreateTab("fov value", {isFovInput = true})
catCombat:CreateTab("hitbox expander", {enabled = false}, function(tog)
    hitboxenabled = tog
    if not tog then
        resetEnemyHitboxes()
    end
end)
catCombat:CreateTab("hitbox size", {isSlider = true, min = 2, max = 35, default = 12, step = 1}, function(val)
    hitboxSize = val
end)

--// Category 4: Customizable POV & Camera
local catPOV = Window:CreateCategory("POV & Cam")
catPOV:CreateTab("custom pov & fov", {enabled = false}, function(tog)
    povenabled = tog
    if not tog then
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = 70
        end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.CameraOffset = Vector3.zero
        end
    end
end)
catPOV:CreateTab("camera fov (angle)", {isSlider = true, min = 40, max = 120, default = 90, step = 1, resetGroup = "POV"}, function(val)
    cameraFovValue = val
end)
catPOV:CreateTab("pov shoulder (x)", {isSlider = true, min = -10, max = 10, default = 0, step = 0.5, resetGroup = "POV"}, function(val)
    povOffsetX = val
end)
catPOV:CreateTab("pov height (y)", {isSlider = true, min = -10, max = 10, default = 0, step = 0.5, resetGroup = "POV"}, function(val)
    povOffsetY = val
end)
catPOV:CreateTab("pov distance (z)", {isSlider = true, min = -15, max = 15, default = 0, step = 0.5, resetGroup = "POV"}, function(val)
    povOffsetZ = val
end)
catPOV:CreateTab("unlock max zoom", {enabled = false}, function(tog)
    unlockZoomEnabled = tog
    if not tog then
        player.CameraMaxZoomDistance = defaultMaxZoom
    end
end)
catPOV:CreateTab("ipad shift-lock", {enabled = false}, function(tog)
    shiftlockEnabled = tog
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not tog then
        hum.AutoRotate = true
    end
end)
catPOV:CreateTab("reset pov defaults", {isButton = true}, function()
    for _, resetFn in ipairs(sliderResetCallbacks) do
        resetFn()
    end
    if not povenabled and workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = 70
    end
    notify("POV sliders reset to default!")
end)

--// Category 5: Teleport & Target
local catTeleport = Window:CreateCategory("Teleport")
catTeleport:CreateTab("select player", {isScrollingDropdown = true})
catTeleport:CreateTab("teleport to target [T]", {isButton = true}, function() teleportToTarget() end)
catTeleport:CreateTab("spectate target", {enabled = false}, function(tog)
    spectateEnabled = tog
    if not tog and player.Character then
        local myHum = player.Character:FindFirstChildOfClass("Humanoid")
        if myHum and workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = myHum
        end
    end
end)

--// Category 6: Misc & Server
local catMisc = Window:CreateCategory("Misc")
catMisc:CreateTab("spinbot (anti-hit)", {enabled = false}, function(tog)
    spinbotenabled = tog
end)
catMisc:CreateTab("spin speed", {isSlider = true, min = 10, max = 100, default = 35, step = 5}, function(val)
    spinSpeed = val
end)
catMisc:CreateTab("auto-clicker loop", {enabled = false}, function(tog)
    autoClickerEnabled = tog
    notify("Auto-Clicker: " .. (tog and "ON" or "OFF"))
end)
catMisc:CreateTab("anti-afk (no idle kick)", {enabled = true}, function(tog)
    antiafkenabled = tog
end)
catMisc:CreateTab("panic button [Delete]", {enabled = false}, function(tog)
    panicEnabled = tog
    notify("Panic Mode: " .. (tog and "ON (Hiding UI & Functions)" or "OFF"))
end)
catMisc:CreateTab("rejoin current server", {isButton = true}, function()
    notify("Rejoining current server...")
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)
catMisc:CreateTab("server hop (new server)", {isButton = true}, function()
    serverHop()
end)

Library:Load()
notify("kyuzxc menu v2.8 (Fixed Toggle) loaded successfully!")

UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.Delete then
        panicEnabled = not panicEnabled
        if panicEnabled then
            if uiParent:FindFirstChild("KyuzxcModMenu") then uiParent.KyuzxcModMenu.Enabled = false end
            if uiParent:FindFirstChild("KyuzxcVisualsGui") then uiParent.KyuzxcVisualsGui.Enabled = false end
            if uiParent:FindFirstChild("KyuzxcMobileAimBtn") then uiParent.KyuzxcMobileAimBtn.Enabled = false end
            notify("PANIC ACTIVATED: Menu and visuals hidden!")
        else
            if uiParent:FindFirstChild("KyuzxcModMenu") then uiParent.KyuzxcModMenu.Enabled = true end
            if uiParent:FindFirstChild("KyuzxcVisualsGui") then uiParent.KyuzxcVisualsGui.Enabled = true end
            if uiParent:FindFirstChild("KyuzxcMobileAimBtn") then uiParent.KyuzxcMobileAimBtn.Enabled = true end
            notify("PANIC DEACTIVATED: Restored UI.")
        end
        return
    end

    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        teleportToTarget()
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infjumpenabled then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

local function isPlayerTeammate(p)
    if p.Team ~= nil and player.Team ~= nil and not p.Neutral and not player.Neutral then
        return p.Team == player.Team
    end
    return false
end

-- Auto-Clicker Background Loop (Fixed Panic & Stable State)
task.spawn(function()
    while true do
        task.wait(autoClickerInterval)
        if not panicEnabled and autoClickerEnabled then
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if panicEnabled then return end

    if gravityenabled then
        workspace.Gravity = customGravity
    end

    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        -- Anti-Void Check
        if antiVoidEnabled and hrp and hrp.Position.Y < -50 then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 100, 0)
            notify("Anti-Void triggered: Saved from falling!")
        end
        
        if noclipped then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        if godmodeenabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanTouch then
                    part.CanTouch = false
                end
            end
        end
        
        if humanoid then
            if speedenabled then
                humanoid.WalkSpeed = customWalkSpeed
            end

            if jumppowerenabled then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = customJumpPower
            end
            
            if godmodeenabled then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                if humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end
        
        if hrp then
            if spinbotenabled and not flyenabled then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end

            local bv = hrp:FindFirstChild("KyuzxcFlyBodyVelocity")
            local bg = hrp:FindFirstChild("KyuzxcFlyBodyGyro")
            
            if flyenabled then
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "KyuzxcFlyBodyVelocity"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = hrp
                end
                if not bg then
                    bg = Instance.new("BodyGyro")
                    bg.Name = "KyuzxcFlyBodyGyro"
                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bg.CFrame = Camera.CFrame
                    bg.Parent = hrp
                end
                
                bg.CFrame = Camera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                
                if moveDir.Magnitude == 0 and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    local camRight = Camera.CFrame.RightVector
                    local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                    local flatForward = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
                    local forwardDot = humanoid.MoveDirection:Dot(flatForward)
                    local rightDot = humanoid.MoveDirection:Dot(flatRight)
                    moveDir = (Camera.CFrame.LookVector * forwardDot) + (Camera.CFrame.RightVector * rightDot)
                end
                
                bv.Velocity = moveDir * customFlySpeed
            else
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        end
    end

    --// Hitbox Expander & Chams Loop
    if hitboxenabled or chamsEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and not isPlayerTeammate(p) and p.Character then
                local enemyHrp = p.Character:FindFirstChild("HumanoidRootPart")
                local enemyHum = p.Character:FindFirstChildOfClass("Humanoid")
                if enemyHrp and enemyHum and enemyHum.Health > 0 then
                    pcall(function()
                        if hitboxenabled then
                            enemyHrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            enemyHrp.Transparency = 0.65
                            enemyHrp.Color = accentColor
                            enemyHrp.Material = Enum.Material.Neon
                            enemyHrp.CanCollide = false
                        end
                        if chamsEnabled then
                            for _, part in ipairs(p.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Material = Enum.Material.Neon
                                    part.Color = enemyColor
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end)

--// Visuals: Round FOV Circle, Crosshair, Mobile Aimbot & ESP Drawing
local visualGui = Instance.new("ScreenGui")
visualGui.Name = "KyuzxcVisualsGui"
visualGui.ResetOnSpawn = false
visualGui.IgnoreGuiInset = true
visualGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
visualGui.Parent = uiParent

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = visualGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.5
fovStroke.Parent = fovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovAspect = Instance.new("UIAspectRatioConstraint")
fovAspect.AspectRatio = 1
fovAspect.Parent = fovCircle

--// Center Crosshair Overlay
local crosshairHolder = Instance.new("Frame")
crosshairHolder.Name = "CrosshairHolder"
crosshairHolder.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairHolder.Position = UDim2.fromScale(0.5, 0.5)
crosshairHolder.Size = UDim2.fromOffset(24, 24)
crosshairHolder.BackgroundTransparency = 1
crosshairHolder.Visible = false
crosshairHolder.Parent = visualGui

local chHorizontal = Instance.new("Frame")
chHorizontal.AnchorPoint = Vector2.new(0.5, 0.5)
chHorizontal.Position = UDim2.fromScale(0.5, 0.5)
chHorizontal.Size = UDim2.fromOffset(18, 2)
chHorizontal.BackgroundColor3 = accentColor
chHorizontal.BorderSizePixel = 0
chHorizontal.Parent = crosshairHolder

local chVertical = Instance.new("Frame")
chVertical.AnchorPoint = Vector2.new(0.5, 0.5)
chVertical.Position = UDim2.fromScale(0.5, 0.5)
chVertical.Size = UDim2.fromOffset(2, 18)
chVertical.BackgroundColor3 = accentColor
chVertical.BorderSizePixel = 0
chVertical.Parent = crosshairHolder

local chDot = Instance.new("Frame")
chDot.AnchorPoint = Vector2.new(0.5, 0.5)
chDot.Position = UDim2.fromScale(0.5, 0.5)
chDot.Size = UDim2.fromOffset(4, 4)
chDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
chDot.BorderSizePixel = 0
chDot.Parent = crosshairHolder

local function getClosestPlayerInFOV()
    local closestTarget = nil
    local shortestDist = fovradius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not isPlayerTeammate(p) then
            local char = p.Character
            local targetPart = char and char:FindFirstChild(targetPartOption)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if screenDist < shortestDist then
                        shortestDist = screenDist
                        closestTarget = targetPart
                    end
                end
            end
        end
    end
    return closestTarget
end

local espCache = {}

local function removeESP(p)
    if espCache[p] then
        pcall(function() 
            if espCache[p].Billboard then espCache[p].Billboard:Destroy() end
            if espCache[p].TracerFrame then espCache[p].TracerFrame:Destroy() end
            if espCache[p].BoxTop then espCache[p].BoxTop:Destroy() end
            if espCache[p].BoxBottom then espCache[p].BoxBottom:Destroy() end
            if espCache[p].BoxLeft then espCache[p].BoxLeft:Destroy() end
            if espCache[p].BoxRight then espCache[p].BoxRight:Destroy() end
            if espCache[p].HealthBarBg then espCache[p].HealthBarBg:Destroy() end
            if espCache[p].HealthBarFill then espCache[p].HealthBarFill:Destroy() end
            if espCache[p].SkeletonHolder then espCache[p].SkeletonHolder:Destroy() end
        end)
        espCache[p] = nil
    end
end

local function hideESP(cache)
    if not cache then return end
    if cache.Billboard then cache.Billboard.Enabled = false end
    if cache.TracerFrame then cache.TracerFrame.Visible = false end
    if cache.BoxTop then cache.BoxTop.Visible = false end
    if cache.BoxBottom then cache.BoxBottom.Visible = false end
    if cache.BoxLeft then cache.BoxLeft.Visible = false end
    if cache.BoxRight then cache.BoxRight.Visible = false end
    if cache.HealthBarBg then cache.HealthBarBg.Visible = false end
    if cache.HealthBarFill then cache.HealthBarFill.Visible = false end
    if cache.SkeletonLines then
        for _, line in pairs(cache.SkeletonLines) do
            line.Visible = false
        end
    end
end

Players.PlayerRemoving:Connect(removeESP)

local function createLine()
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = enemyColor
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = visualGui
    return line
end

local function updatePlayerESP(p)
    if p == player then return end
    local char = p.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local head = char and char:FindFirstChild("Head")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not char or not head or not hrp or not humanoid or humanoid.Health <= 0 then
        removeESP(p)
        return
    end

    local localChar = player.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if localHrp then
        local dist = (localHrp.Position - hrp.Position).Magnitude
        if dist > maxEspDistance then
            if espCache[p] then
                hideESP(espCache[p])
            end
            return
        end
    else
        if espCache[p] then
            hideESP(espCache[p])
        end
        return
    end
    
    if not espCache[p] then
        espCache[p] = {}
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "KyuzxcNameTag"
        billboard.Size = UDim2.new(0, 160, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3.2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = enemyColor
        textLabel.TextStrokeTransparency = 0
        textLabel.TextSize = 13
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboard
        
        espCache[p].Billboard = billboard
        espCache[p].TextLabel = textLabel
        espCache[p].TracerFrame = createLine()
        espCache[p].BoxTop = createLine()
        espCache[p].BoxBottom = createLine()
        espCache[p].BoxLeft = createLine()
        espCache[p].BoxRight = createLine()

        local hbBg = Instance.new("Frame")
        hbBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        hbBg.BorderSizePixel = 0
        hbBg.Visible = false
        hbBg.Parent = visualGui

        local hbFill = Instance.new("Frame")
        hbFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        hbFill.BorderSizePixel = 0
        hbFill.Visible = false
        hbFill.Parent = visualGui

        espCache[p].HealthBarBg = hbBg
        espCache[p].HealthBarFill = hbFill

        local skFolder = Instance.new("Folder")
        skFolder.Name = "SkeletonFolder"
        skFolder.Parent = visualGui
        espCache[p].SkeletonHolder = skFolder

        espCache[p].SkeletonLines = {
            Head_Neck = createLine(),
            Torso_LHand = createLine(),
            Torso_RHand = createLine(),
            Torso_LFoot = createLine(),
            Torso_RFoot = createLine()
        }
        for _, line in pairs(espCache[p].SkeletonLines) do line.Parent = skFolder end
    end
    
    local cache = espCache[p]
    local isTeammate = isPlayerTeammate(p)
    if (isTeammate and not showteam) or (not isTeammate and not showenemy) then
        hideESP(cache)
        return
    end

    local activeColor = isTeammate and teamColor or enemyColor
    
    if cache.Billboard and cache.TextLabel then
        cache.Billboard.Enabled = espenabled
        cache.TextLabel.TextColor3 = activeColor
        if espenabled then
            local distStr = ""
            if localHrp and showdist then
                local dist = math.floor((localHrp.Position - hrp.Position).Magnitude)
                distStr = " [" .. dist .. "m]"
            end
            cache.TextLabel.Text = p.Name .. distStr
        end
    end

    Camera = workspace.CurrentCamera
    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    
    if onScreen then
        if cache.TracerFrame then
            cache.TracerFrame.Visible = tracerenabled
            cache.TracerFrame.BackgroundColor3 = activeColor
            if tracerenabled then
                local screenBottomCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                local targetPos = Vector2.new(hrpPos.X, hrpPos.Y)
                local distance = (targetPos - screenBottomCenter).Magnitude
                
                cache.TracerFrame.Size = UDim2.new(0, distance, 0, 1.5)
                cache.TracerFrame.Position = UDim2.new(0, (screenBottomCenter.X + targetPos.X) / 2, 0, (screenBottomCenter.Y + targetPos.Y) / 2)
                cache.TracerFrame.Rotation = math.deg(math.atan2(targetPos.Y - screenBottomCenter.Y, targetPos.X - screenBottomCenter.X))
            end
        end

        if cache.BoxTop and cache.BoxBottom and cache.BoxLeft and cache.BoxRight then
            cache.BoxTop.Visible = boxenabled
            cache.BoxBottom.Visible = boxenabled
            cache.BoxLeft.Visible = boxenabled
            cache.BoxRight.Visible = boxenabled

            cache.BoxTop.BackgroundColor3 = activeColor
            cache.BoxBottom.BackgroundColor3 = activeColor
            cache.BoxLeft.BackgroundColor3 = activeColor
            cache.BoxRight.BackgroundColor3 = activeColor
            
            if boxenabled then
                local Victim_Head = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local Victim_Legs = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local boxSizeX = 2000 / hrpPos.Z
                local boxSizeY = math.abs(Victim_Legs.Y - Victim_Head.Y)
                local centerX = hrpPos.X
                local centerY = hrpPos.Y

                cache.BoxTop.Size = UDim2.new(0, boxSizeX, 0, 1.5)
                cache.BoxTop.Position = UDim2.new(0, centerX, 0, centerY - (boxSizeY / 2))

                cache.BoxBottom.Size = UDim2.new(0, boxSizeX, 0, 1.5)
                cache.BoxBottom.Position = UDim2.new(0, centerX, 0, centerY + (boxSizeY / 2))

                cache.BoxLeft.Size = UDim2.new(0, 1.5, 0, boxSizeY)
                cache.BoxLeft.Position = UDim2.new(0, centerX - (boxSizeX / 2), 0, centerY)

                cache.BoxRight.Size = UDim2.new(0, 1.5, 0, boxSizeY)
                cache.BoxRight.Position = UDim2.new(0, centerX + (boxSizeX / 2), 0, centerY)

                -- Health Bar rendering
                if cache.HealthBarBg and cache.HealthBarFill then
                    cache.HealthBarBg.Visible = healthBarEnabled
                    cache.HealthBarFill.Visible = healthBarEnabled
                    if healthBarEnabled then
                        local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barH = boxSizeY
                        local barW = 3
                        local barX = centerX - (boxSizeX / 2) - 6
                        local barY = centerY

                        cache.HealthBarBg.Size = UDim2.new(0, barW, 0, barH)
                        cache.HealthBarBg.Position = UDim2.new(0, barX, 0, barY)

                        local fillH = barH * hpPercent
                        cache.HealthBarFill.Size = UDim2.new(0, barW, 0, fillH)
                        cache.HealthBarFill.Position = UDim2.new(0, barX, 0, barY + (barH / 2) - (fillH / 2))
                    end
                end
            else
                if cache.HealthBarBg then cache.HealthBarBg.Visible = false end
                if cache.HealthBarFill then cache.HealthBarFill.Visible = false end
            end
        end

        local skel = cache.SkeletonLines
        if skel then
            local torsoPart = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            local leftHandPart = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
            local rightHandPart = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
            local leftFootPart = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
            local rightFootPart = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")

            if skeletonenabled and head and torsoPart then
                local headV, hValid = Camera:WorldToViewportPoint(head.Position)
                local torsoV, tValid = Camera:WorldToViewportPoint(torsoPart.Position)
                
                if hValid and tValid then
                    local p1, p2 = Vector2.new(headV.X, headV.Y), Vector2.new(torsoV.X, torsoV.Y)
                    local dist = (p2 - p1).Magnitude
                    skel.Head_Neck.BackgroundColor3 = activeColor
                    skel.Head_Neck.Size = UDim2.new(0, dist, 0, 1.5)
                    skel.Head_Neck.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
                    skel.Head_Neck.Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
                    skel.Head_Neck.Visible = true
                else
                    skel.Head_Neck.Visible = false
                end

                local function drawBone(boneKey, part)
                    if part and tValid then
                        local partV, pValid = Camera:WorldToViewportPoint(part.Position)
                        if pValid then
                            local p1, p2 = Vector2.new(torsoV.X, torsoV.Y), Vector2.new(partV.X, partV.Y)
                            local dist = (p2 - p1).Magnitude
                            skel[boneKey].BackgroundColor3 = activeColor
                            skel[boneKey].Size = UDim2.new(0, dist, 0, 1.5)
                            skel[boneKey].Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
                            skel[boneKey].Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
                            skel[boneKey].Visible = true
                            return
                        end
                    end
                    skel[boneKey].Visible = false
                end

                drawBone("Torso_LHand", leftHandPart)
                drawBone("Torso_RHand", rightHandPart)
                drawBone("Torso_LFoot", leftFootPart)
                drawBone("Torso_RFoot", rightFootPart)
            else
                for _, line in pairs(skel) do line.Visible = false end
            end
        end
    else
        hideESP(cache)
    end
end

RunService.RenderStepped:Connect(function()
    if panicEnabled then return end

    Camera = workspace.CurrentCamera
    local myChar = player.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    --// 1. Custom POV & Camera Offset Enforcement
    if povenabled then
        if Camera and Camera.FieldOfView ~= cameraFovValue then
            Camera.FieldOfView = cameraFovValue
        end
        if myHum then
            myHum.CameraOffset = Vector3.new(povOffsetX, povOffsetY, povOffsetZ)
        end
    end

    if unlockZoomEnabled then
        player.CameraMaxZoomDistance = customMaxZoom
        player.CameraMinZoomDistance = 0.5
    end

    --// 2. iPad Shift-Lock (Character faces Camera horizontal direction)
    if shiftlockEnabled and myHum and myHrp and Camera then
        myHum.AutoRotate = false
        local lookVec = Camera.CFrame.LookVector
        local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z)
        if flatLook.Magnitude > 0.001 then
            myHrp.CFrame = CFrame.new(myHrp.Position, myHrp.Position + flatLook)
        end
    end

    --// 3. Spectate Selected Target
    if spectateEnabled and Camera then
        if selectedTargetPlayer and selectedTargetPlayer.Character then
            local targetHum = selectedTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetHum then
                Camera.CameraSubject = targetHum
            end
        elseif myHum then
            Camera.CameraSubject = myHum
        end
    end

    --// 4. Fullbright Enforcement
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    end

    --// 5. Crosshair & FOV Circle Updates
    crosshairHolder.Visible = crosshairEnabled
    fovCircle.Visible = fovcircleenabled
    if fovcircleenabled and Camera then
        fovCircle.Size = UDim2.new(0, fovradius * 2, 0, fovradius * 2)
        fovCircle.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2)
    end

    --// 6. Aimbot & Triggerbot Update
    if aimbotenabled and aimbotactive and Camera then
        local targetPart = getClosestPlayerInFOV()
        if targetPart then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPart.Position)
            if aimbotSmoothing <= 0 then
                Camera.CFrame = targetCFrame
            else
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 - aimbotSmoothing)
            end
        end
    end

    if triggerBotEnabled and Camera then
        local mousePos = UserInputService:GetMouseLocation()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and not isPlayerTeammate(p) and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < 20 then
                            pcall(function()
                                VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
                                task.wait(0.05)
                                VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                            end)
                        end
                    end
                end
            end
        end
    end

    --// 7. Player ESP Update
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            updatePlayerESP(p)
        end
    end
end)
