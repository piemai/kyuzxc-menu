--// Kyuzxc Simple Mod Menu (iPad Edition + Fully Fixed Callbacks for Inf Jump & Speed)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
local showteam = false
local showenemy = false
local espenabled = false
local boxenabled = false
local skeletonenabled = false
local tracerenabled = false
local showdist = false
local noclipped = false
local infjumpenabled = false
local speedenabled = false
local customWalkSpeed = 50
local flyenabled = false
local godmodeenabled = false
local fovcircleenabled = false
local fovradius = 120
local aimbotenabled = false
local aimbotactive = false
local targetPartOption = "Head"
local aimbotSmoothing = 0.3
local selectedTargetPlayer = nil

--// ESP Colors & Theme
local teamColor = Color3.fromRGB(0, 255, 120)  -- Green (Team)
local enemyColor = Color3.fromRGB(255, 75, 75) -- Red (Enemy)
local accentColor = Color3.fromRGB(0, 255, 128)

--// Floating Draggable Mobile Aimbot Toggle Button (Center Default)
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "KyuzxcMobileAimBtn"
mobileGui.ResetOnSpawn = false
mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
mobileGui.Parent = uiParent

local aimToggleButton = Instance.new("TextButton")
aimToggleButton.Size = UDim2.new(0, 75, 0, 75)
aimToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
aimToggleButton.Position = UDim2.new(0.5, 0, 0.85, 0)
aimToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
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
            aimToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
            aimToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            aimBtnStroke.Color = Color3.fromRGB(0, 255, 128)
            aimToggleButton.Text = "AIM: ON"
            notify("Mobile Aimbot Enabled")
        else
            aimToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
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

--// Library Framework
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
                IsPartDropdown = config and config.isPartDropdown or false,
                IsSmoothDropdown = config and config.isSmoothDropdown or false
            })
        end
        
        table.insert(window.Categories, category)
        return category
    end
    
    table.insert(Library.Windows, window)
    return window
end

function Library:Load()
    local TweenService = game:GetService("TweenService")
    local palette = {
        bg = Color3.fromRGB(16, 12, 29), panel = Color3.fromRGB(25, 19, 43),
        surface = Color3.fromRGB(36, 27, 57), hover = Color3.fromRGB(49, 36, 76),
        accent = Color3.fromRGB(155, 99, 255), accent2 = Color3.fromRGB(107, 65, 203),
        text = Color3.fromRGB(245, 240, 255), muted = Color3.fromRGB(174, 159, 201),
        off = Color3.fromRGB(80, 70, 104)
    }
    accentColor = palette.accent
    local function make(class, properties, parent)
        local object = Instance.new(class)
        for key, value in pairs(properties) do object[key] = value end
        object.Parent = parent
        return object
    end
    local function round(object, radius)
        make("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
    end
    local function tween(object, properties)
        TweenService:Create(object, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
    end
    local screenGui = make("ScreenGui", {
        Name = "KyuzxcModMenu", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    }, uiParent)
    for _, win in ipairs(self.Windows) do
        local viewport = workspace.CurrentCamera.ViewportSize
        local mobile = viewport.X < 650
        local width = math.min(mobile and 355 or 475, math.max(260, viewport.X - 24))
        local height = math.min(mobile and 480 or 550, math.max(250, viewport.Y - 36))
        local expandedHeight = height
        local main = make("Frame", {
            Name = "MainWindow", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width, height),
            BackgroundColor3 = palette.bg, BorderSizePixel = 0, Active = true,
            ClipsDescendants = true
        }, screenGui)
        round(main, 16)
        make("UIStroke", {Color = palette.accent2, Thickness = 1.3, Transparency = 0.25}, main)
        local header = make("Frame", {
            Name = "Header", Size = UDim2.new(1, 0, 0, 68),
            BackgroundColor3 = palette.panel, BorderSizePixel = 0, Active = true
        }, main)
        local stripe = make("Frame", {
            Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = palette.accent,
            BorderSizePixel = 0
        }, header)
        make("UIGradient", {Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, palette.accent),
            ColorSequenceKeypoint.new(1, palette.accent2)
        })}, stripe)
        local title = make("TextLabel", {
            Position = UDim2.fromOffset(17, 13), Size = UDim2.new(1, -105, 0, 24),
            BackgroundTransparency = 1, Text = "KYUZXC  /  MENU", Font = Enum.Font.GothamBold,
            TextSize = 17, TextColor3 = palette.text, TextXAlignment = Enum.TextXAlignment.Left
        }, header)
        make("TextLabel", {
            Position = UDim2.fromOffset(18, 37), Size = UDim2.new(1, -110, 0, 18),
            BackgroundTransparency = 1, Text = "VIOLET EDITION  •  " .. (mobile and "MOBILE" or "DESKTOP"),
            Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = palette.muted,
            TextXAlignment = Enum.TextXAlignment.Left
        }, header)
        local function headerButton(text, offset, color)
            local b = make("TextButton", {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, offset, 0, 18),
                Size = UDim2.fromOffset(30, 30), BackgroundColor3 = color,
                Text = text, Font = Enum.Font.GothamBold, TextSize = 17,
                TextColor3 = palette.text, AutoButtonColor = false
            }, header)
            round(b, 9)
            return b
        end
        local close = headerButton("×", -12, Color3.fromRGB(100, 42, 83))
        local minimize = headerButton("−", -48, palette.surface)
        local categories = make("ScrollingFrame", {
            Position = UDim2.fromOffset(12, 78), Size = UDim2.new(1, -24, 0, 40),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.X, AutomaticCanvasSize = Enum.AutomaticSize.X,
            CanvasSize = UDim2.new(), ClipsDescendants = true
        }, main)
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 7), VerticalAlignment = Enum.VerticalAlignment.Center
        }, categories)
        local content = make("ScrollingFrame", {
            Position = UDim2.fromOffset(12, 126), Size = UDim2.new(1, -24, 1, -140),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
            ScrollBarImageColor3 = palette.accent, AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y
        }, main)
        make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}, content)
        local buttons, pages = {}, {}
        local function row(name, order)
            local item = make("Frame", {
                Name = name, LayoutOrder = order, Size = UDim2.new(1, -5, 0, 48),
                BackgroundColor3 = palette.panel, BorderSizePixel = 0
            }, content)
            round(item, 10)
            make("UIStroke", {Color = palette.surface, Thickness = 1, Transparency = 0.35}, item)
            return item
        end
        local function label(parent, text, rightSpace)
            return make("TextLabel", {
                Position = UDim2.fromOffset(13, 0), Size = UDim2.new(1, -(rightSpace or 20), 1, 0),
                BackgroundTransparency = 1, Text = text, TextColor3 = palette.text,
                Font = Enum.Font.GothamMedium, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd
            }, parent)
        end
        local function selectCategory(index)
            for i, page in ipairs(pages) do
                page.Visible = i == index
                tween(buttons[i], {BackgroundColor3 = i == index and palette.accent2 or palette.surface,
                    TextColor3 = i == index and palette.text or palette.muted})
            end
            content.CanvasPosition = Vector2.new(0, 0)
        end
        -- Every category owns its rows; the active category is the only visible page.
        for categoryIndex, cat in ipairs(win.Categories) do
            local categoryButton = make("TextButton", {
                Name = cat.Name, Size = UDim2.fromOffset(math.max(90, #cat.Name * 8 + 27), 34),
                BackgroundColor3 = palette.surface, Text = cat.Name,
                Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = palette.muted, AutoButtonColor = false
            }, categories)
            round(categoryButton, 9)
            buttons[categoryIndex] = categoryButton
            local page = make("Frame", {
                Name = cat.Name .. "Page", Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                Visible = false, LayoutOrder = categoryIndex
            }, content)
            make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}, page)
            pages[categoryIndex] = page
            categoryButton.MouseButton1Click:Connect(function() selectCategory(categoryIndex) end)
            for index, tab in ipairs(cat.Tabs) do
                local item = row(tab.Name, index * 2)
                item.Parent = page
                if tab.IsButton then
                    local action = make("TextButton", {
                        Size = UDim2.new(1, -12, 1, -10), Position = UDim2.fromOffset(6, 5),
                        BackgroundColor3 = palette.accent2, Text = tab.Name .. "  →",
                        Font = Enum.Font.GothamBold, TextSize = 12,
                        TextColor3 = palette.text, AutoButtonColor = false
                    }, item)
                    round(action, 8)
                    action.MouseButton1Click:Connect(function()
                        tween(action, {BackgroundColor3 = palette.accent})
                        task.delay(0.2, function() if action.Parent then tween(action, {BackgroundColor3 = palette.accent2}) end end)
                        if tab.Callback then tab.Callback() end
                    end)
                elseif tab.IsSpeedInput or tab.IsFovInput then
                    label(item, tab.IsSpeedInput and "Speed value" or "FOV radius", 110)
                    local input = make("TextBox", {
                        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                        Size = UDim2.fromOffset(82, 30), BackgroundColor3 = palette.surface,
                        Text = tostring(tab.IsSpeedInput and customWalkSpeed or fovradius),
                        TextColor3 = palette.text, Font = Enum.Font.GothamBold,
                        TextSize = 12, ClearTextOnFocus = false
                    }, item)
                    round(input, 7)
                    input.FocusLost:Connect(function()
                        local value = tonumber(input.Text)
                        if value and value == value then
                            value = math.clamp(value, 1, 1000)
                            if tab.IsSpeedInput then customWalkSpeed = value else fovradius = value end
                        end
                        input.Text = tostring(tab.IsSpeedInput and customWalkSpeed or fovradius)
                    end)
                elseif tab.IsScrollingDropdown or tab.IsPartDropdown or tab.IsSmoothDropdown then
                    local trigger = make("TextButton", {
                        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
                        BackgroundTransparency = 1, TextColor3 = palette.text,
                        Text = tab.Name .. "  ▾", TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.GothamMedium, TextSize = 12
                    }, item)
                    local list = make("ScrollingFrame", {
                        LayoutOrder = index * 2 + 1, Size = UDim2.new(1, -5, 0, 0),
                        BackgroundColor3 = palette.panel, BorderSizePixel = 0,
                        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 3, ScrollBarImageColor3 = palette.accent,
                        Visible = false
                    }, page)
                    round(list, 10)
                    make("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
                        PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 8)}, list)
                    make("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, list)
                    local function option(text, callback)
                        local b = make("TextButton", {
                            Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = palette.surface,
                            Text = text, TextColor3 = palette.text,
                            Font = Enum.Font.GothamMedium, TextSize = 11, AutoButtonColor = false
                        }, list)
                        round(b, 7)
                        b.MouseButton1Click:Connect(function()
                            callback()
                            list.Visible = false
                            list.Size = UDim2.new(1, -5, 0, 0)
                        end)
                    end
                    local function refresh()
                        for _, child in ipairs(list:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        if tab.IsPartDropdown then
                            for _, part in ipairs({"Head", "UpperTorso", "HumanoidRootPart"}) do
                                option(part, function() targetPartOption = part; trigger.Text = "Aim part: " .. part .. "  ▾" end)
                            end
                        elseif tab.IsSmoothDropdown then
                            for _, mode in ipairs({{name="Hard (Instant)", value=0},
                                {name="Medium (Balanced)", value=0.3}, {name="Low (Smooth)", value=0.6}}) do
                                option(mode.name, function() aimbotSmoothing = mode.value; trigger.Text = "Aim mode: " .. mode.name .. "  ▾" end)
                            end
                        else
                            option("↻  Refresh players", function() task.defer(refresh) end)
                            for _, other in ipairs(Players:GetPlayers()) do
                                if other ~= player then
                                    option(other.DisplayName .. "  (@" .. other.Name .. ")", function()
                                        selectedTargetPlayer = other
                                        trigger.Text = "Target: " .. other.Name .. "  ▾"
                                    end)
                                end
                            end
                        end
                    end
                    trigger.MouseButton1Click:Connect(function()
                        local open = not list.Visible
                        if open then refresh() end
                        list.Visible = open
                        list.Size = UDim2.new(1, -5, 0, open and (tab.IsScrollingDropdown and 175 or 125) or 0)
                    end)
                else
                    label(item, tab.Name, 94)
                    local track = make("TextButton", {
                        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -13, 0.5, 0),
                        Size = UDim2.fromOffset(49, 25), BackgroundColor3 = tab.State and palette.accent2 or palette.off,
                        Text = "", AutoButtonColor = false
                    }, item)
                    round(track, 13)
                    local dot = make("Frame", {
                        Size = UDim2.fromOffset(19, 19), Position = UDim2.fromOffset(tab.State and 27 or 3, 3),
                        BackgroundColor3 = palette.text, BorderSizePixel = 0
                    }, track)
                    round(dot, 10)
                    local state = tab.State
                    track.MouseButton1Click:Connect(function()
                        state = not state
                        tab.State = state
                        tween(track, {BackgroundColor3 = state and palette.accent2 or palette.off})
                        tween(dot, {Position = UDim2.fromOffset(state and 27 or 3, 3)})
                        if tab.Callback then tab.Callback(state) end
                    end)
                end
            end
        end
        if #pages > 0 then selectCategory(1) end
        local minimized = false
        minimize.MouseButton1Click:Connect(function()
            minimized = not minimized
            categories.Visible = not minimized
            content.Visible = not minimized
            minimize.Text = minimized and "+" or "−"
            tween(main, {Size = UDim2.fromOffset(width, minimized and 68 or expandedHeight)})
        end)
        close.MouseButton1Click:Connect(function()
            screenGui:Destroy()
            local visuals = uiParent:FindFirstChild("KyuzxcVisualsGui")
            if visuals then visuals:Destroy() end
            local aim = uiParent:FindFirstChild("KyuzxcMobileAimBtn")
            if aim then aim:Destroy() end
            notify("Menu closed.")
        end)
        -- Reliable drag support for mouse and touch; drag from the header area.
        local dragging, dragStart, initialPosition = false, nil, nil
        header.Active = true
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                initialPosition = main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                local viewport = workspace.CurrentCamera.ViewportSize
                local x = math.clamp(initialPosition.X.Offset + delta.X, -width / 2, viewport.X - width / 2)
                local y = math.clamp(initialPosition.Y.Offset + delta.Y, 0, viewport.Y - 68)
                main.Position = UDim2.new(initialPosition.X.Scale, x, initialPosition.Y.Scale, y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        local function resize()
            local size = workspace.CurrentCamera.ViewportSize
            width = math.min(size.X < 650 and 355 or 475, math.max(260, size.X - 24))
            expandedHeight = math.min(size.X < 650 and 480 or 550, math.max(250, size.Y - 36))
            main.Size = UDim2.fromOffset(width, minimized and 68 or expandedHeight)
        end
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    end
end

local Window = Library:CreateWindow("kyuzxc simple mod menu [ipad]")

--// Category 1: Movement
local catMovement = Window:CreateCategory("Movement")
catMovement:CreateTab("noclip", {enabled = false}, function(tog) 
    noclipped = tog 
    if not tog and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)
catMovement:CreateTab("inf jump", {enabled = false}, function(tog) infjumpenabled = tog end) 
catMovement:CreateTab("speed hack", {enabled = false}, function(tog) 
    speedenabled = tog 
    if not tog and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end)
catMovement:CreateTab("speed value", {isSpeedInput = true})
catMovement:CreateTab("fly", {enabled = false}, function(tog) flyenabled = tog end)
catMovement:CreateTab("god mode", {enabled = false}, function(tog) godmodeenabled = tog end)

--// Category 2: Visuals
local catVisuals = Window:CreateCategory("Visuals")
catVisuals:CreateTab("esp team (green)", {enabled = false}, function(tog) showteam = tog end)
catVisuals:CreateTab("esp enemy (red)", {enabled = false}, function(tog) showenemy = tog end)
catVisuals:CreateTab("esp names", {enabled = false}, function(tog) espenabled = tog end)
catVisuals:CreateTab("esp boxes", {enabled = false}, function(tog) boxenabled = tog end)
catVisuals:CreateTab("esp skeleton", {enabled = false}, function(tog) skeletonenabled = tog end)
catVisuals:CreateTab("esp tracers", {enabled = false}, function(tog) tracerenabled = tog end)
catVisuals:CreateTab("distance tags", {enabled = false}, function(tog) showdist = tog end)

--// Category 3: Combat (Aimbot & FOV)
local catCombat = Window:CreateCategory("Combat")
catCombat:CreateTab("aimbot button", {enabled = false}, function(tog) 
    aimbotenabled = tog 
    aimToggleButton.Visible = tog
    if not tog then
        aimbotactive = false
        aimToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        aimToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
        aimBtnStroke.Color = Color3.fromRGB(255, 75, 75)
        aimToggleButton.Text = "AIM: OFF"
    end
end)
catCombat:CreateTab("aim part", {isPartDropdown = true})
catCombat:CreateTab("aim smoothness", {isSmoothDropdown = true})
catCombat:CreateTab("fov circle", {enabled = false}, function(tog) fovcircleenabled = tog end)
catCombat:CreateTab("fov value", {isFovInput = true})

--// Category 4: Teleport
local catTeleport = Window:CreateCategory("Teleport")
catTeleport:CreateTab("select player", {isScrollingDropdown = true})
catTeleport:CreateTab("teleport to target [T]", {isButton = true}, function() teleportToTarget() end)

Library:Load()
notify("kyuzxc menu loaded successfully!")

UserInputService.InputBegan:Connect(function(input, gp)
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

RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        if noclipped then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if speedenabled then
                humanoid.WalkSpeed = customWalkSpeed
            elseif humanoid.WalkSpeed == customWalkSpeed and not speedenabled then
                humanoid.WalkSpeed = 16
            end
            
            if godmodeenabled then
                humanoid.Health = humanoid.MaxHealth
            end
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and flyenabled then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 1, hrp.Velocity.Z)
        end
    end
end)

--// Visuals: Round FOV Circle & Mobile Aimbot & ESP Drawing
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

local function isPlayerTeammate(p)
    if p.Team ~= nil and player.Team ~= nil and not p.Neutral and not player.Neutral then
        return p.Team == player.Team
    end
    return false
end

--// Aimbot Target Finder Logic
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
            local localChar = player.Character
            local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
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

                drawBone("Torstate_LHand", leftHandPart)
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
    fovCircle.Visible = fovcircleenabled
    if fovcircleenabled then
        fovCircle.Size = UDim2.new(0, fovradius * 2, 0, fovradius * 2)
        fovCircle.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2)
    end

    if aimbotenabled and aimbotactive then
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

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            updatePlayerESP(p)
        end
    end
end)
