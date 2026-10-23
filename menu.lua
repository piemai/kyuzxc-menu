--[[ 
    Kyuzxc / Switch Hub (Blox Fruits Edition + Delta iOS Optimized UI)
    Pinagsama ang malawak na Blox Fruits farming/quest features at ang modernong Resizable/Responsive Violet Library mula sa menuV2.
]]

if not game:IsLoaded() then 
    repeat game.Loaded:Wait() until game:IsLoaded() 
end

pcall(function()
    if game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam") then
        if game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Visible == true then
            for _, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Pirates.Frame.ViewportFrame.TextButton.MouseButton1Click)) do
                v.Function()
            end
        end
    end
end)

if _G.Fast_Delay == nil then
	_G.Fast_Delay = 0.3
end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

-- World Checks
local placeId = game.PlaceId
local Old_World = (placeId == 2753915549)
local New_World = (placeId == 4442272183)
local Three_World = (placeId == 7449423635)

_G.Color = Color3.fromRGB(165, 95, 255) -- Violet Theme Accent

_G.Setting_table = {
    Auto_Farm = false,
    FastAttack = true,
	Auto_Buso = true,
	Auto_Ken = true,
	Show_Damage = true,
	NoClip = true,
	Save_Member = true,
	Melee_A = true,
	Defense_A = true,
	SkillZ = true,
	Rejoin = true,
	Anti_AFK = true,
	K_MAX = 50,
	Chest_Lock = 50,
	Delay_C = 15
}

function Text(value)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Switch Hub (Kyuzxc)", 
            Text = tostring(value),
            Duration = 5
        })
    end)
end

function Com()
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Switch Hub (Kyuzxc)", 
            Text = "✅ Complete",
            Duration = 3
        })
    end)
end

function EquipWeapon(ToolName)
    local player = game.Players.LocalPlayer
    if player.Backpack:FindFirstChild(ToolName) then
        local tool = player.Backpack:FindFirstChild(ToolName)
        task.wait(0.2)
        player.Character.Humanoid:EquipTool(tool)
    end
end

function TP(destinationCFrame)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local distance = (destinationCFrame.Position - hrp.Position).Magnitude
        local speed = 300
        if distance > 1000 then speed = 250 end
        
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = destinationCFrame})
        tween:Play()
    end
end

-- Delta iOS Optimized UI Library Framework
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Linisin ang lumang GUI kung meron man
if playerGui:FindFirstChild("KyuzxcBloxFruitsMenu") then
    playerGui.KyuzxcBloxFruitsMenu:Destroy()
end

local Library = { Windows = {} }

function Library:CreateWindow(title)
    local window = { Title = title, Categories = {} }
    function window:CreateCategory(catName)
        local category = { Name = catName, Tabs = {} }
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
    screenGui.Name = "KyuzxcBloxFruitsMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = playerGui
    
    for _, win in ipairs(self.Windows) do
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 480, 0, 360)
        mainFrame.Position = UDim2.new(0.5, -240, 0.3, -180)
        mainFrame.BackgroundColor3 = Color3.fromRGB(17, 14, 27)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 12)
        mainCorner.Parent = mainFrame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = _G.Color
        stroke.Thickness = 1.5
        stroke.Transparency = 0.3
        stroke.Parent = mainFrame

        -- Header
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
            Text("Menu closed and unloaded.")
        end)

        -- Sidebar Navigation
        local sidebar = Instance.new("ScrollingFrame")
        sidebar.Size = UDim2.new(0, 130, 1, -54)
        sidebar.Position = UDim2.new(0, 8, 0, 48)
        sidebar.BackgroundColor3 = Color3.fromRGB(27, 21, 42)
        sidebar.BorderSizePixel = 0
        sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
        sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sidebar.ScrollBarThickness = 2
        sidebar.ScrollBarImageColor3 = _G.Color
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
        
        -- Content Container
        local contentContainer = Instance.new("ScrollingFrame")
        contentContainer.Size = UDim2.new(1, -150, 1, -54)
        contentContainer.Position = UDim2.new(0, 144, 0, 48)
        contentContainer.BackgroundTransparency = 1
        contentContainer.BorderSizePixel = 0
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
        contentContainer.ScrollBarThickness = 3
        contentContainer.ScrollBarImageColor3 = _G.Color
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
                togButton.BackgroundColor3 = tab.State and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                togButton.TextColor3 = tab.State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
                togButton.Text = "  " .. tab.Name .. " : " .. (tab.State and "ON" or "OFF")
                togButton.TextXAlignment = Enum.TextXAlignment.Left
                togButton.Font = Enum.Font.GothamBold
                togButton.TextSize = 11
                togButton.Parent = itemHolder
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 6)
                corner.Parent = togButton
                
                local pad = Instance.new("UIPadding")
                pad.PaddingLeft = UDim.new(0, 6)
                pad.Parent = togButton
                
                local currentState = tab.State
                togButton.MouseButton1Click:Connect(function()
                    currentState = not currentState
                    togButton.Text = "  " .. tab.Name .. " : " .. (currentState and "ON" or "OFF")
                    togButton.BackgroundColor3 = currentState and Color3.fromRGB(93, 205, 151) or Color3.fromRGB(38, 29, 57)
                    togButton.TextColor3 = currentState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
                    if tab.Callback then tab.Callback(currentState) end
                end)
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
                cBtn.BackgroundColor3 = _G.Color
                cBtn.TextColor3 = Color3.fromRGB(245, 240, 255)
            end)
        end
        
        if categoryFrames[1] then
            categoryFrames[1].Visible = true
            categoryButtons[1].BackgroundColor3 = _G.Color
            categoryButtons[1].TextColor3 = Color3.fromRGB(245, 240, 255)
        end
    end
end

-- Window Initialization
local Window = Library:CreateWindow("Switch Hub [Blox Fruits]")
local General_Tab = Window:CreateCategory("General")
local Quest_Tab = Window:CreateCategory("Quest & Item")

General_Tab:CreateTab("Auto Farm", {enabled = false}, function(vu)
	Auto_Farm = vu
	_G.Setting_table.AutoFarm = vu
end)

General_Tab:CreateTab("Fast Attack", {enabled = true}, function(vu)
	_G.Setting_table.FastAttack = vu
end)

Quest_Tab:CreateTab("Auto Second World", {enabled = false}, function(vu)
	Auto_New_A = vu
end)

Library:Load()
Text("Switch Hub Menu Loaded Successfully!")
