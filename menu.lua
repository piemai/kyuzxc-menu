-- Kyuzxc Studio Development Menu
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Intended for your own Roblox experience in Studio.
-- All feature toggles start OFF. This is not an executor script.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    DefaultWalkSpeed = 16,
    MaxWalkSpeed = 100,
    MaxDebugDistance = 150,
    DefaultSize = Vector2.new(560, 430),
    MinSize = Vector2.new(340, 300),
}

local THEME = {
    Background = Color3.fromRGB(17, 14, 27),
    Panel = Color3.fromRGB(27, 21, 42),
    Panel2 = Color3.fromRGB(38, 29, 57),
    Accent = Color3.fromRGB(165, 95, 255),
    AccentLight = Color3.fromRGB(205, 170, 255),
    Text = Color3.fromRGB(245, 240, 255),
    Muted = Color3.fromRGB(170, 158, 190),
    Off = Color3.fromRGB(49, 41, 63),
    Danger = Color3.fromRGB(210, 75, 100),
    Good = Color3.fromRGB(93, 205, 151),
}

local state = {
    noclip = false,
    infiniteJump = false,
    speed = false,
    fly = false,
    debugVisuals = false,
    maxDistance = CONFIG.MaxDebugDistance,
    walkSpeed = 32,
}

local oldGui = playerGui:FindFirstChild("KyuzxcStudioMenu")
if oldGui then oldGui:Destroy() end

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kyuzxc Studio Menu",
            Text = message,
            Duration = 3,
        })
    end)
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local gui = make("ScreenGui", {
    Name = "KyuzxcStudioMenu",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(CONFIG.DefaultSize.X, CONFIG.DefaultSize.Y),
    Position = UDim2.new(0.5, -CONFIG.DefaultSize.X / 2, 0.5, -CONFIG.DefaultSize.Y / 2),
    BackgroundColor3 = THEME.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, main)
make("UIStroke", {Color = THEME.Accent, Transparency = 0.25, Thickness = 1.5}, main)

local scaleConstraint = make("UISizeConstraint", {
    MinSize = CONFIG.MinSize,
    MaxSize = Vector2.new(900, 760),
}, main)

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, header)
make("Frame", {
    Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0,
}, header)

local title = make("TextLabel", {
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -120, 1, 0),
    BackgroundTransparency = 1,
    Text = "KYUZX C  /  STUDIO TOOLS",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = THEME.AccentLight,
}, header)

local function styleButton(button, color)
    button.AutoButtonColor = true
    button.BackgroundColor3 = color or THEME.Panel2
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = THEME.Text
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, button)
end

local minimizeButton = make("TextButton", {
    Name = "Minimize",
    Size = UDim2.fromOffset(30, 28),
    Position = UDim2.new(1, -72, 0, 10),
    Text = "−",
}, header)
styleButton(minimizeButton, THEME.Panel2)

local closeButton = make("TextButton", {
    Name = "Close",
    Size = UDim2.fromOffset(30, 28),
    Position = UDim2.new(1, -36, 0, 10),
    Text = "×",
}, header)
styleButton(closeButton, THEME.Danger)

local nav = make("Frame", {
    Name = "Navigation",
    Position = UDim2.fromOffset(12, 58),
    Size = UDim2.new(0, 112, 1, -70),
    BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 9)}, nav)
local navLayout = make("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, nav)
make("UIPadding", {
    PaddingTop = UDim.new(0, 9),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
}, nav)

local content = make("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.new(0, 136, 0, 58),
    Size = UDim2.new(1, -148, 1, -70),
    BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.Accent,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 9)}, content)
make("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
}, content)
local contentLayout = make("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local pages, navButtons = {}, {}
local activePage = nil

local function createPage(name)
    local page = make("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible = false,
    }, content)
    make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    pages[name] = page

    local navButton = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        Text = name,
        LayoutOrder = #navButtons + 1,
    }, nav)
    styleButton(navButton, THEME.Off)
    navButtons[name] = navButton
    navButton.Activated:Connect(function()
        for pageName, frame in pairs(pages) do
            frame.Visible = pageName == name
            navButtons[pageName].BackgroundColor3 = pageName == name and THEME.Accent or THEME.Off
        end
        activePage = name
    end)
    if not activePage then
        activePage = name
        page.Visible = true
        navButton.BackgroundColor3 = THEME.Accent
    end
    return page
end

local function sectionLabel(parent, text)
    return make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = THEME.AccentLight,
    }, parent)
end

local function addToggle(parent, label, initial, callback)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "   " .. label .. "     [OFF]",
    }, parent)
    styleButton(button, THEME.Off)
    local enabled = false -- force all toggles OFF on execution
    local function render()
        button.Text = "   " .. label .. "     [" .. (enabled and "ON" or "OFF") .. "]"
        button.BackgroundColor3 = enabled and THEME.Accent or THEME.Off
    end
    render()
    button.Activated:Connect(function()
        enabled = not enabled
        render()
        callback(enabled)
    end)
    return function(forceOff)
        enabled = false
        render()
        callback(false)
    end
end

local function addInput(parent, label, defaultValue, callback)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = THEME.Off,
        BorderSizePixel = 0,
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, row)
    make("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -112, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = THEME.Text,
    }, row)
    local box = make("TextBox", {
        Position = UDim2.new(1, -96, 0.5, -13),
        Size = UDim2.fromOffset(84, 26),
        BackgroundColor3 = THEME.Background,
        TextColor3 = THEME.AccentLight,
        Text = tostring(defaultValue),
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(0, 5)}, box)
    box.FocusLost:Connect(function()
        local number = tonumber(box.Text)
        if number then
            callback(number)
            box.Text = tostring(number)
        else
            box.Text = tostring(defaultValue)
        end
    end)
end

local movementPage = createPage("Movement")
sectionLabel(movementPage, "MOVEMENT CONTROLS")
local visualsPage = createPage("Visuals")
sectionLabel(visualsPage, "STUDIO DEBUG VISUALS")
local settingsPage = createPage("Settings")
sectionLabel(settingsPage, "CONFIGURATION")

-- Character movement helpers are local development controls.
local function getCharacterParts()
    local character = localPlayer.Character
    if not character then return nil end
    return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local originalCollision = {}
local function setNoclip(enabled)
    local character = localPlayer.Character
    if not character then return end
    if enabled then
        table.clear(originalCollision)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCollision[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    else
        for part, canCollide in pairs(originalCollision) do
            if part and part.Parent then part.CanCollide = canCollide end
        end
        table.clear(originalCollision)
    end
end

addToggle(movementPage, "Noclip (local test)", false, function(on)
    state.noclip = on
    setNoclip(on)
end)
addToggle(movementPage, "Infinite Jump (local test)", false, function(on)
    state.infiniteJump = on
end)
addToggle(movementPage, "Custom WalkSpeed", false, function(on)
    state.speed = on
    local _, humanoid = getCharacterParts()
    if humanoid then humanoid.WalkSpeed = on and state.walkSpeed or CONFIG.DefaultWalkSpeed end
end)
addInput(movementPage, "WalkSpeed value", state.walkSpeed, function(value)
    state.walkSpeed = math.clamp(value, 1, CONFIG.MaxWalkSpeed)
    if state.speed then
        local _, humanoid = getCharacterParts()
        if humanoid then humanoid.WalkSpeed = state.walkSpeed end
    end
end)

local function createDebugVisual(player)
    if player == localPlayer then return end
    local character = player.Character
    if not character then return end
    local highlight = character:FindFirstChild("KyuzxcStudioHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "KyuzxcStudioHighlight"
        highlight.FillColor = THEME.Accent
        highlight.OutlineColor = THEME.AccentLight
        highlight.FillTransparency = 0.82
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Enabled = false
        highlight.Parent = character
    end
    local head = character:FindFirstChild("Head")
    if head and not head:FindFirstChild("KyuzxcDebugTag") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "KyuzxcDebugTag"
        billboard.Size = UDim2.fromOffset(160, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = false
        billboard.Enabled = false
        billboard.Parent = head
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = THEME.AccentLight
        label.TextStrokeTransparency = 0.35
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Parent = billboard
    end
end

local function cleanupDebugVisual(player)
    local character = player.Character
    if not character then return end
    local highlight = character:FindFirstChild("KyuzxcStudioHighlight")
    if highlight then highlight.Enabled = false end
    local head = character:FindFirstChild("Head")
    local tag = head and head:FindFirstChild("KyuzxcDebugTag")
    if tag then tag.Enabled = false end
end

local function setDebugVisuals(enabled)
    state.debugVisuals = enabled
    if not enabled then
        for _, p in ipairs(Players:GetPlayers()) do cleanupDebugVisual(p) end
    else
        for _, p in ipairs(Players:GetPlayers()) do createDebugVisual(p) end
    end
end

addToggle(visualsPage, "Player debug highlights", false, setDebugVisuals)
addInput(visualsPage, "Max distance (studs)", state.maxDistance, function(value)
    state.maxDistance = math.clamp(value, 25, 2000)
end)
make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundTransparency = 1,
    TextWrapped = true,
    Text = "Studio-safe debug view: occluded highlights and labels only. Visuals are disabled by default and limited by distance.",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = THEME.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, visualsPage)

addToggle(settingsPage, "Show execution notifications", false, function(on)
    state.notifications = on
end)
make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundTransparency = 1,
    TextWrapped = true,
    Text = "All feature toggles initialize OFF. Use only in your own Roblox Studio experience.",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = THEME.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, settingsPage)

-- Draggable header (mouse and touch)
local dragging, dragStart, startPosition, activeDragInput
header.Active = true
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        activeDragInput = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

-- Resize grip
local resizeGrip = make("TextButton", {
    Name = "ResizeGrip",
    Size = UDim2.fromOffset(22, 22),
    Position = UDim2.new(1, -22, 1, -22),
    BackgroundColor3 = THEME.Accent,
    Text = "↘",
    TextColor3 = THEME.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    BorderSizePixel = 0,
    ZIndex = 10,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, resizeGrip)
local resizing, resizeStart, sizeStart = false, nil, nil
resizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        sizeStart = main.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then resizing = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        local camera = workspace.CurrentCamera
        local maxX = camera and math.min(900, camera.ViewportSize.X - 20) or 900
        local maxY = camera and math.min(760, camera.ViewportSize.Y - 20) or 760
        main.Size = UDim2.fromOffset(
            math.clamp(sizeStart.X + delta.X, CONFIG.MinSize.X, maxX),
            math.clamp(sizeStart.Y + delta.Y, CONFIG.MinSize.Y, maxY)
        )
    end
end)

local minimized = false
local previousSize = main.Size
minimizeButton.Activated:Connect(function()
    minimized = not minimized
    if minimized then
        previousSize = main.Size
        nav.Visible = false
        content.Visible = false
        resizeGrip.Visible = false
        main.Size = UDim2.new(previousSize.X.Scale, previousSize.X.Offset, 0, 48)
        minimizeButton.Text = "+"
    else
        main.Size = previousSize
        nav.Visible = true
        content.Visible = true
        resizeGrip.Visible = true
        minimizeButton.Text = "−"
    end
end)

closeButton.Activated:Connect(function()
    setDebugVisuals(false)
    setNoclip(false)
    gui:Destroy()
end)

-- Reapply state safely after respawn.
localPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if state.speed then
        local _, humanoid = getCharacterParts()
        if humanoid then humanoid.WalkSpeed = state.walkSpeed end
    end
    if state.noclip then setNoclip(true) end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.25)
        if state.debugVisuals then createDebugVisual(p) end
    end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer then
        p.CharacterAdded:Connect(function()
            task.wait(0.25)
            if state.debugVisuals then createDebugVisual(p) end
        end)
    end
end

Players.PlayerRemoving:Connect(function(p)
    cleanupDebugVisual(p)
end)

UserInputService.JumpRequest:Connect(function()
    if state.infiniteJump then
        local _, humanoid = getCharacterParts()
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if state.noclip then
        local character = localPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    if state.speed then
        local _, humanoid = getCharacterParts()
        if humanoid and humanoid.WalkSpeed ~= state.walkSpeed then humanoid.WalkSpeed = state.walkSpeed end
    end
end)

RunService.RenderStepped:Connect(function()
    if not state.debugVisuals then return end
    local camera = workspace.CurrentCamera
    local _, _, myRoot = getCharacterParts()
    if not camera or not myRoot then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            createDebugVisual(p)
            local character = p.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local highlight = character and character:FindFirstChild("KyuzxcStudioHighlight")
            local head = character and character:FindFirstChild("Head")
            local tag = head and head:FindFirstChild("KyuzxcDebugTag")
            local distance = root and (root.Position - myRoot.Position).Magnitude or math.huge
            local _, onScreen = root and camera:WorldToViewportPoint(root.Position) or Vector3.zero, false
            if root then
                local projected = camera:WorldToViewportPoint(root.Position)
                onScreen = projected.Z > 0 and projected.X >= 0 and projected.X <= camera.ViewportSize.X
                    and projected.Y >= 0 and projected.Y <= camera.ViewportSize.Y
            end
            local visible = root ~= nil and humanoid ~= nil and humanoid.Health > 0
                and distance <= state.maxDistance and onScreen
            if highlight then highlight.Enabled = visible end
            if tag then
                tag.Enabled = visible
                local label = tag:FindFirstChildOfClass("TextLabel")
                if label then label.Text = p.DisplayName .. "  •  " .. math.floor(distance) .. " studs" end
            end
            if not visible then cleanupDebugVisual(p) end
        end
    end
end)

-- Keep the menu within the visible viewport when the device changes orientation.
local function fitToViewport()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local width = math.clamp(main.AbsoluteSize.X, CONFIG.MinSize.X, math.max(CONFIG.MinSize.X, viewport.X - 20))
    local height = math.clamp(main.AbsoluteSize.Y, CONFIG.MinSize.Y, math.max(CONFIG.MinSize.Y, viewport.Y - 20))
    main.Size = UDim2.fromOffset(width, height)
    local x = math.clamp(main.AbsolutePosition.X, 10, math.max(10, viewport.X - width - 10))
    local y = math.clamp(main.AbsolutePosition.Y, 10, math.max(10, viewport.Y - height - 10))
    main.Position = UDim2.fromOffset(x, y)
end
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToViewport)
end

notify("Kyuzxc Studio Menu loaded. All feature toggles are OFF.")
