-- Roblox Fly Script for Mobile & PC
-- UI สวยงาม รองรับการบินความเร็วสูงบนมือถือ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ตั้งค่าเริ่มต้น
local isFlying = false
local flySpeed = 100 -- ค่าความเร็วในการบิน (ปรับเพิ่ม/ลดได้)
local bodyVelocity = nil
local bodyGyro = nil

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGuiMobile"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (UI Container)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 160, 0, 110)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- สามารถลาก UI ไปมาบนหน้าจอมือถือได้
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 170, 255)
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "FLY SYSTEM"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Toggle Fly Button
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.85, 0, 0, 35)
flyButton.Position = UDim2.new(0.075, 0, 0.32, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
flyButton.Text = "FLY: OFF"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 14
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = flyButton

-- Speed Up Button
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.85, 0, 0, 25)
speedButton.Position = UDim2.new(0.075, 0, 0.70, 0)
speedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedButton.Text = "Speed: " .. flySpeed
speedButton.TextColor3 = Color3.fromRGB(200, 200, 200)
speedButton.TextSize = 12
speedButton.Font = Enum.Font.Gotham
speedButton.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedButton

-- ฟังก์ชันการบิน
local function startFlying()
    isFlying = true
    flyButton.Text = "FLY: ON"
    flyButton.BackgroundColor3 = Color3.fromRGB(40, 200, 100)
    
    local camera = workspace.CurrentCamera
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = RootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.CFrame = RootPart.CFrame
    bodyGyro.Parent = RootPart
    
    -- ทำงานทุกเฟรมเพื่ออัปเดตทิศทางตามกล้อง
    RunService:BindToRenderStep("FlyUpdate", Enum.RenderPriority.Camera.Value, function()
        if not isFlying or not Character or not RootPart then return end
        
        local moveVector = Humanoid.MoveDirection
        bodyGyro.CFrame = camera.CFrame
        
        if moveVector.Magnitude > 0 then
            -- บินไปตามทิศทางที่ผู้เล่นบังคับจอยสติ๊ก + ทิศทางของกล้อง
            bodyVelocity.Velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveVector.X, 0, -moveVector.Z)) * flySpeed
        else
            bodyVelocity.Velocity = Vector3.zero
        end
    end)
end

local function stopFlying()
    isFlying = false
    flyButton.Text = "FLY: OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    RunService:UnbindFromRenderStep("FlyUpdate")
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

-- Event Listeners
flyButton.MouseButton1Click:Connect(function()
    if isFlying then
        stopFlying()
    else
        startFlying()
    end
end)

speedButton.MouseButton1Click:Connect(function()
    if flySpeed == 100 then
        flySpeed = 200
    elseif flySpeed == 200 then
        flySpeed = 350
    else
        flySpeed = 100
    end
    speedButton.Text = "Speed: " .. flySpeed
end)

-- รีเซ็ตค่าเมื่อตัวละครเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    if isFlying then stopFlying() end
end)
