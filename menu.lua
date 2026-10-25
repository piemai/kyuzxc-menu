--// Kyuzxc MM2 Mod Menu (iPad Edition + Resizable, Responsive Sidebar)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local uiParent = (gethui and gethui()) or CoreGui

-- Linisin ang lumang UI kung naka-load na
if uiParent:FindFirstChild("KyuzxcMM2Menu") then
    uiParent.KyuzxcMM2Menu:Destroy()
end

--// Notification Helper
local function notify(msg)
    print("[Kyuzxc MM2] " .. msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kyuzxc MM2",
            Text = msg,
            Duration = 3
        })
    end)
end

--// Feature States
local roleEspEnabled = true
local gunEspEnabled = true
local accentColor = Color3.fromRGB(165, 95, 255) -- Violet Accent

--// Library Framework (Gaya ng working menu mo)
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
                IsButton = config and config.isButton or false
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
    screenGui.Name = "KyuzxcMM2Menu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = uiParent
    
    for _, win in ipairs(self.Windows) do
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 440, 0, 320)
        mainFrame.Position = UDim2.new(0.5, -220, 0.3, -160)
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
            notify("MM2 Menu closed and unloaded.")
        end)
        
        --// Sidebar Navigation
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
        
        --// Content Container
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
                local togButton = Instance.new("TextButton")
                togButton.LayoutOrder = idx * 2
                togButton.Size = UDim2.new(1, 0, 0, 34)
                
                if tab.IsButton then
                    togButton.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
                    togButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    togButton.Text = tab.Name
                else
                    togButton.BackgroundColor3 = tab.State and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                    togButton.TextColor3 = tab.State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
                    togButton.Text = "  " .. tab.Name .. " : " .. (tab.State and "ON" or "OFF")
                    togButton.TextXAlignment = Enum.TextXAlignment.Left
                end
                
                if not tab.IsButton then
                    local pad = Instance.new("UIPadding")
                    pad.PaddingLeft = UDim.new(0, 6)
                    pad.Parent = togButton
                end

                togButton.Font = Enum.Font.GothamBold
                togButton.TextSize = 11
                togButton.Parent = itemHolder
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 6)
                corner.Parent = togButton
                
                local currentState = tab.State
                if not tab.IsButton then
                    togButton.MouseButton1Click:Connect(function()
                        currentState = not currentState
                        togButton.Text = "  " .. tab.Name .. " : " .. (currentState and "ON" or "OFF")
                        togButton.BackgroundColor3 = currentState and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                        togButton.TextColor3 = currentState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
                        if tab.Callback then tab.Callback(currentState) end
                    end)
                else
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
    end
end

local Window = Library:CreateWindow("kyuzxc mm2 menu [ipad]")

--// Category 1: Visuals
local catVisuals = Window:CreateCategory("Visuals")
catVisuals:CreateTab("role esp", {enabled = true}, function(tog) 
    roleEspEnabled = tog 
    notify("Role ESP: " .. (tog and "ON" or "OFF"))
end)
catVisuals:CreateTab("gun drop esp", {enabled = true}, function(tog) 
    gunEspEnabled = tog 
    notify("Gun Drop ESP: " .. (tog and "ON" or "OFF"))
end)

--// Category 2: Teleport
local catTeleport = Window:CreateCategory("Teleport")
catTeleport:CreateTab("teleport to gun", {isButton = true}, function()
    local found = false
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" and obj:IsA("BasePart") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                notify("Naka-teleport sa nahulog na baril!")
                found = true
                break
            end
        end
    end
    if not found then
        notify("Walang nakitang nahulog na baril.")
    end
end)

Library:Load()
notify("Kyuzxc MM2 Menu loaded successfully!")

--// ESP Loop
RunService.RenderStepped:Connect(function()
    if roleEspEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local char = p.Character
                local head = char:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("MM2RoleTag")
                    if not tag then
                        tag = Instance.new("BillboardGui", head)
                        tag.Name = "MM2RoleTag"
                        tag.Size = UDim2.new(0, 140, 0, 45)
                        tag.StudsOffset = Vector3.new(0, 2.8, 0)
                        tag.AlwaysOnTop = true
                        
                        local label = Instance.new("TextLabel", tag)
                        label.Name = "Label"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 0.5
                        label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                        label.TextScaled = true
                        label.Font = Enum.Font.GothamBold
                        label.TextStrokeTransparency = 0.3
                        
                        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 4)
                    end
                    
                    local label = tag:FindFirstChild("Label")
                    if label then
                        local role = "Innocent"
                        local color = Color3.fromRGB(0, 255, 100)
                        
                        if p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
                            role = "MURDERER"
                            color = Color3.fromRGB(255, 50, 50)
                        elseif p.Backpack:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then
                            role = "SHERIFF"
                            color = Color3.fromRGB(50, 150, 255)
                        end
                        
                        tag.Enabled = true
                        label.Text = p.DisplayName .. "\n[" .. role .. "]"
                        label.TextColor3 = color
                    end
                end
            end
        end
    end

    if gunEspEnabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                local billboard = obj:FindFirstChild("GunTag")
                if not billboard then
                    billboard = Instance.new("BillboardGui", obj)
                    billboard.Name = "GunTag"
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    
                    local txt = Instance.new("TextLabel", billboard)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 0.5
                    txt.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    txt.TextColor3 = Color3.fromRGB(255, 255, 0)
                    txt.Text = "[ DROPPED GUN ]"
                    txt.TextScaled = true
                    txt.Font = Enum.Font.GothamBold
                    Instance.new("UICorner", txt).CornerRadius = UDim.new(0, 4)
                end
            end
        end
    end
end)
