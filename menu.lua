--// Kyuzxc Blox Fruits Custom Mobile Menu (Delta iOS Optimized)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Linisin ang lumang UI kung naka-load na
if playerGui:FindFirstChild("KyuzxcBloxFruitsLite") then
    playerGui.KyuzxcBloxFruitsLite:Destroy()
end

--// Notification Helper
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kyuzxc Blox Fruits",
            Text = msg,
            Duration = 3
        })
    end)
end

--// Feature States
local autoFarmEnabled = false
local autoClickerEnabled = false
local fruitEspEnabled = false
local chestEspEnabled = false
local walkOnWaterEnabled = false

--// Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KyuzxcBloxFruitsLite"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = playerGui

--// Main Frame (Modern Violet Theme)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 300)
mainFrame.Position = UDim2.new(0.5, -180, 0.3, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(17, 14, 27)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(165, 95, 255)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

--// Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(27, 21, 42)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(205, 170, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.Text = "KYUZXC BLOX FRUITS [LITE]"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 6)
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
    notify("Menu Unloaded.")
end)

--// Content Container
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -50)
content.Position = UDim2.new(0, 8, 0, 42)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollBarThickness = 3
content.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = content

--// Helper function to create toggles
local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.Text = "  " .. name .. " : OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(93, 205, 151)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = "  " .. name .. " : ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(38, 29, 57)
            btn.TextColor3 = Color3.fromRGB(180, 180, 190)
            btn.Text = "  " .. name .. " : OFF"
        }
        callback(active)
    end)
end

--// Add Features to Menu
createToggle("Auto Farm Nearest Mob", function(state)
    autoFarmEnabled = state
    notify("Auto Farm: " .. tostring(state))
end)

createToggle("Auto-Clicker / Fast Attack", function(state)
    autoClickerEnabled = state
    notify("Auto-Clicker: " .. tostring(state))
end)

createToggle("Fruit ESP (Gold)", function(state)
    fruitEspEnabled = state
    notify("Fruit ESP: " .. tostring(state))
end)

createToggle("Chest ESP (Blue)", function(state)
    chestEspEnabled = state
    notify("Chest ESP: " .. tostring(state))
end)

createToggle("Walk On Water", function(state)
    walkOnWaterEnabled = state
    notify("Walk on Water: " .. tostring(state))
end)

--// Main Execution Loop
RunService.Stepped:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- Auto-Clicker simulation
    if autoClickerEnabled then
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end

    -- Walk on Water logic
    if walkOnWaterEnabled and hrp then
        pcall(function()
            for _, part in ipairs(Workspace:GetPartsInPart(hrp)) do
                local name = string.lower(part.Name)
                if string.find(name, "water") or string.find(name, "sea") or part.Material == Enum.Material.Water then
                    part.CanCollide = true
                end
            end
        end)
    end

    -- Auto Farm nearest mob logic
    if autoFarmEnabled and hrp then
        pcall(function()
            local closestMob = nil
            local minDist = math.huge
            if Workspace:FindFirstChild("Enemies") then
                for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
                    local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                    local mobHum = mob:FindFirstChildOfClass("Humanoid")
                    if mobHrp and mobHum and mobHum.Health > 0 then
                        local dist = (hrp.Position - mobHrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closestMob = mobHrp
                        end
                    end
                end
            end
            if closestMob then
                hrp.CFrame = closestMob.CFrame + Vector3.new(0, 4, 3)
            end
        end)
    end
end)

notify("Kyuzxc Blox Fruits Lite Loaded!")
