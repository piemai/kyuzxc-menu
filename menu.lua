local ScreenGui = Instance.new("ScreenGui")
local TextButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
TextButton.Parent = ScreenGui
TextButton.Size = UDim2.new(0, 200, 0, 50)
TextButton.Position = UDim2.new(0.5, -100, 0.5, -25)
TextButton.Text = "TEST BUTTON - LUBOS NA GUMAGANA"
TextButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)

print("Test GUI executed!")
