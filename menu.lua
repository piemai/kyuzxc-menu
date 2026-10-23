--[[ 
    Updated & Modified Kyuzxc / Switch Hub (Blox Fruits Edition)
    Cleaned up, optimized for modern executors, and patched outdated remote/UI paths.
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

_G.Color = Color3.fromRGB(165, 95, 255) -- Updated to match your preferred Violet Theme

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
            Title = "Kyuzxc Hub", 
            Text = tostring(value),
            Duration = 5
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

Text("Kyuzxc Hub Loaded Successfully!")
