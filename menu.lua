--// Kyuzxc Simple Mod Menu (Full Script + Fixed Exunys Style ESP + Team/Enemy Toggle)
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

--// Notification Helper
local function notify(msg)
    print("[delta] " .. msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kyuzxc Menu",
            Text = msg,
            Duration = 4
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
local noclipped = true
local infjumpenabled = true
local speedenabled = false
local customWalkSpeed = 50
local flyenabled = false
local godmodeenabled = false
local selectedTargetPlayer = nil

--// ESP Colors
local teamColor = Color3.fromRGB(0, 255, 0)   -- Green (Team)
local enemyColor = Color3.fromRGB(255, 0, 0)  -- Red (Enemy)

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
                IsSpeedInput = config and config.isSpeedInput or false
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
        mainFrame.Size = UDim2.new(0, 260, 0, 420)
        mainFrame.Position = UDim2.new(0.5, -130, 0.3, -210)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 128)
        mainFrame.BorderSizePixel = 2
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        local titleBar = Instance.new("TextLabel")
        titleBar.Size = UDim2.new(1, -60, 0, 35)
        titleBar.BackgroundTransparency = 1
        titleBar.TextColor3 = Color3.fromRGB(0, 255, 128)
        titleBar.Font = Enum.Font.GothamBold
        titleBar.TextSize = 13
        titleBar.TextXAlignment = Enum.TextXAlignment.Left
        titleBar.Position = UDim2.new(0, 10, 0, 0)
        titleBar.Text = "  " .. win.Title
        titleBar.Parent = mainFrame
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -28, 0, 6)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Text = "X"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 11
        closeBtn.Parent = mainFrame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            screenGui:Destroy()
            if uiParent:FindFirstChild("KyuzxcVisualsGui") then
                uiParent.KyuzxcVisualsGui:Destroy()
            end
            notify("Menu closed and unloaded.")
        end)
        
        local minBtn = Instance.new("TextButton")
        minBtn.Size = UDim2.new(0, 24, 0, 24)
        minBtn.Position = UDim2.new(1, -56, 0, 6)
        minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minBtn.Text = "-"
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 13
        minBtn.Parent = mainFrame
        
        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 4)
        minCorner.Parent = minBtn
        
        local catBar = Instance.new("Frame")
        catBar.Size = UDim2.new(1, -20, 0, 28)
        catBar.Position = UDim2.new(0, 10, 0, 38)
        catBar.BackgroundTransparency = 1
        catBar.Parent = mainFrame
        
        local catLayout = Instance.new("UIListLayout")
        catLayout.FillDirection = Enum.FillDirection.Horizontal
        catLayout.SortOrder = Enum.SortOrder.LayoutOrder
        catLayout.Padding = UDim.new(0, 6)
        catLayout.Parent = catBar
        
        local contentContainer = Instance.new("ScrollingFrame")
        contentContainer.Size = UDim2.new(1, -20, 1, -80)
        contentContainer.Position = UDim2.new(0, 10, 0, 72)
        contentContainer.BackgroundTransparency = 1
        contentContainer.BorderSizePixel = 0
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
        contentContainer.ScrollBarThickness = 3
        contentContainer.Parent = mainFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.Parent = contentContainer
        
        local categoryFrames = {}
        local categoryButtons = {}
        
        for _, cat in ipairs(win.Categories) do
            local cBtn = Instance.new("TextButton")
            cBtn.Size = UDim2.new(0.5, -3, 1, 0)
            cBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            cBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            cBtn.Text = cat.Name
            cBtn.Font = Enum.Font.GothamBold
            cBtn.TextSize = 11
            cBtn.Parent = catBar
            
            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 4)
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
            
            for _, tab in ipairs(cat.Tabs) do
                local togButton = Instance.new("TextButton")
                togButton.Size = UDim2.new(1, 0, 0, 32)
                
                if tab.IsButton then
                    togButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    togButton.Text = tab.Name
                elseif tab.IsSpeedInput then
                    togButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                    togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    togButton.Text = "Speed Value:"
                    togButton.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local padding = Instance.new("UIPadding")
                    padding.PaddingLeft = UDim.new(0, 10)
                    padding.Parent = togButton
                    
                    local textBox = Instance.new("TextBox")
                    textBox.Size = UDim2.new(0, 70, 0, 24)
                    textBox.Position = UDim2.new(1, -75, 0.5, -12)
                    textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    textBox.TextColor3 = Color3.fromRGB(0, 255, 128)
                    textBox.Text = tostring(customWalkSpeed)
                    textBox.Font = Enum.Font.GothamBold
                    textBox.TextSize = 11
                    textBox.Parent = togButton
                    
                    local boxCorner = Instance.new("UICorner")
                    boxCorner.CornerRadius = UDim.new(0, 4)
                    boxCorner.Parent = textBox
                    
                    textBox.FocusLost:Connect(function()
                        local num = tonumber(textBox.Text)
                        if num then
                            customWalkSpeed = num
                            textBox.Text = tostring(customWalkSpeed)
                            notify("WalkSpeed set to: " .. num)
                        else
                            textBox.Text = tostring(customWalkSpeed)
                        end
                    end)
                elseif tab.IsScrollingDropdown then
                    togButton.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
                    togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    togButton.Text = "Target: [Select Player]"
                    
                    local dropFrame = Instance.new("ScrollingFrame")
                    dropFrame.Size = UDim2.new(1, 0, 0, 140)
                    dropFrame.Position = UDim2.new(0, 0, 1, 4)
                    dropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    dropFrame.BorderColor3 = Color3.fromRGB(150, 50, 255)
                    dropFrame.BorderSizePixel = 1
                    dropFrame.Visible = false
                    dropFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                    dropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    dropFrame.ZIndex = 10
                    dropFrame.Parent = togButton
                    
                    local dropLayout = Instance.new("UIListLayout")
                    dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    dropLayout.Parent = dropFrame
                    
                    local function refreshPlayerList()
                        for _, child in ipairs(dropFrame:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        
                        local refreshBtn = Instance.new("TextButton")
                        refreshBtn.Size = UDim2.new(1, 0, 0, 30)
                        refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
                        refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        refreshBtn.Text = " Refresh Player List"
                        refreshBtn.Font = Enum.Font.GothamBold
                        refreshBtn.TextSize = 11
                        refreshBtn.ZIndex = 11
                        refreshBtn.Parent = dropFrame
                        
                        refreshBtn.MouseButton1Click:Connect(function()
                            refreshPlayerList()
                            notify("Player list refreshed successfully!")
                        end)
                        
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player then
                                local pBtn = Instance.new("TextButton")
                                pBtn.Size = UDim2.new(1, 0, 0, 30)
                                pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                                pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                pBtn.Text = p.Name
                                pBtn.Font = Enum.Font.GothamBold
                                pBtn.TextSize = 11
                                pBtn.ZIndex = 11
                                pBtn.Parent = dropFrame
                                
                                pBtn.MouseButton1Click:Connect(function()
                                    selectedTargetPlayer = p
                                    togButton.Text = "Target: " .. p.Name
                                    dropFrame.Visible = false
                                    notify("Target selected: " .. p.Name)
                                end)
                            end
                        end
                    end
                    
                    Players.PlayerAdded:Connect(refreshPlayerList)
                    Players.PlayerRemoving:Connect(refreshPlayerList)
                    
                    togButton.MouseButton1Click:Connect(function()
                        dropFrame.Visible = not dropFrame.Visible
                        if dropFrame.Visible then 
                            refreshPlayerList() 
                        end
                    end)
                else
                    togButton.BackgroundColor3 = tab.State and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(45, 45, 55)
                    togButton.TextColor3 = tab.State and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
                    togButton.Text = tab.Name .. ": " .. (tab.State and "ON" or "OFF")
                end
                
                if not tab.IsSpeedInput then
                    togButton.Font = Enum.Font.GothamBold
                    togButton.TextSize = 12
                end
                togButton.Parent = itemHolder
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 6)
                corner.Parent = togButton
                
                local currentState = tab.State
                if not tab.IsButton and not tab.IsScrollingDropdown and not tab.IsSpeedInput then
                    togButton.MouseButton1Click:Connect(function()
                        currentState = not currentState
                        togButton.Text = tab.Name .. ": " .. (currentState and "ON" or "OFF")
                        togButton.BackgroundColor3 = currentState and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(45, 45, 55)
                        togButton.TextColor3 = currentState and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
                        if tab.Callback then tab.Callback(currentState) end
                    end)
                elseif tab.IsButton then
                    togButton.MouseButton1Click:Connect(function()
                        if tab.Callback then tab.Callback() end
                    end)
                end
            end
            
            table.insert(categoryFrames, itemHolder)
            table.insert(categoryButtons, cBtn)
            
            cBtn.MouseButton1Click:Connect(function()
                for _, holder in ipairs(categoryFrames) do holder.Visible = false end
                for _, btn in ipairs(categoryButtons) do 
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                itemHolder.Visible = true
                cBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
                cBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            end)
        end
        
        if categoryFrames[1] then
            categoryFrames[1].Visible = true
            categoryButtons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 128)
            categoryButtons[1].TextColor3 = Color3.fromRGB(0, 0, 0)
        end
        
        local minimized = false
        local elementsToHide = {catBar, contentContainer}
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            for _, el in ipairs(elementsToHide) do
                el.Visible = not minimized
            end
            mainFrame.Size = minimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 420)
            minBtn.Text = minimized and "+" or "-"
        end)
    end
end

local Window = Library:CreateWindow("kyuzxc simple mod menu")

local cat1 = Window:CreateCategory("Movement & Combat")
cat1:CreateTab("noclip", {enabled = true}, function(tog) 
    noclipped = tog 
    if not tog and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)
cat1:CreateTab("inf jump", {enabled = true}, function(tog) infjumpenabled = tog end) 
cat1:CreateTab("speed hack", {enabled = false}, function(tog) speedenabled = tog end)
cat1:CreateTab("speed value", {isSpeedInput = true})
cat1:CreateTab("fly", {enabled = false}, function(tog) flyenabled = tog end)
cat1:CreateTab("god mode", {enabled = false}, function(tog) godmodeenabled = tog end)

local cat2 = Window:CreateCategory("Visuals & Teleport")
cat2:CreateTab("esp team (green)", {enabled = true}, function(tog) showteam = tog end)
cat2:CreateTab("esp enemy (red)", {enabled = true}, function(tog) showenemy = tog end)
cat2:CreateTab("esp names", {enabled = true}, function(tog) espenabled = tog end)
cat2:CreateTab("esp boxes", {enabled = true}, function(tog) boxenabled = tog end)
cat2:CreateTab("esp skeleton", {enabled = true}, function(tog) skeletonenabled = tog end)
cat2:CreateTab("esp tracers", {enabled = true}, function(tog) tracerenabled = tog end)
cat2:CreateTab("distance tags", {enabled = true}, function(tog) showdist = tog end)
cat2:CreateTab("select player", {isScrollingDropdown = true})
cat2:CreateTab("teleport to target", {isButton = true}, function() teleportToTarget() end)

Library:Load()
notify("kyuzxc simple mod menu loaded")

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

--// True 2D Bounding Box, Skeleton & Center Tracer ESP (Exunys Style Math)
local espCache = {}
local visualGui = Instance.new("ScreenGui")
visualGui.Name = "KyuzxcVisualsGui"
visualGui.ResetOnSpawn = false
visualGui.IgnoreGuiInset = true
visualGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
visualGui.Parent = uiParent

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

local function isPlayerTeammate(p)
    if p.Team ~= nil and player.Team ~= nil and not p.Neutral and not player.Neutral then
        return p.Team == player.Team
    end
    return false
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

    -- Check kung kakampi o kalaban at kung naka-enable ang toggle nila
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
        -- Tracers
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

        -- 2D Boxes (Exunys Exact Reference Formula)
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
                cache.BoxTop.Rotation = 0

                cache.BoxBottom.Size = UDim2.new(0, boxSizeX, 0, 1.5)
                cache.BoxBottom.Position = UDim2.new(0, centerX, 0, centerY + (boxSizeY / 2))
                cache.BoxBottom.Rotation = 0

                cache.BoxLeft.Size = UDim2.new(0, 1.5, 0, boxSizeY)
                cache.BoxLeft.Position = UDim2.new(0, centerX - (boxSizeX / 2), 0, centerY)
                cache.BoxLeft.Rotation = 0

                cache.BoxRight.Size = UDim2.new(0, 1.5, 0, boxSizeY)
                cache.BoxRight.Position = UDim2.new(0, centerX + (boxSizeX / 2), 0, centerY)
                cache.BoxRight.Rotation = 0
            end
        end

        -- Skeleton
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
        if cache.TracerFrame then cache.TracerFrame.Visible = false end
        if cache.BoxTop then cache.BoxTop.Visible = false end
        if cache.BoxBottom then cache.BoxBottom.Visible = false end
        if cache.BoxLeft then cache.BoxLeft.Visible = false end
        if cache.BoxRight then cache.BoxRight.Visible = false end
        if cache.SkeletonLines then
            for _, line in pairs(cache.SkeletonLines) do line.Visible = false end
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            updatePlayerESP(p)
        end
    end
end)