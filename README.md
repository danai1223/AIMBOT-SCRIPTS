local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- สร้างหน้าต่าง Fluent
local Window = Fluent:CreateWindow({
    Title = "XNightWave",
    SubTitle = "Mobile + PC Supported",
    TabWidth = 140,
    Size = UDim2.fromOffset(560, 460),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- สร้างแท็บ
local Tabs = {
    Main = Window:AddTab({ Title = "🏠 Main" }),
    Aimbot = Window:AddTab({ Title = "🎯 Aimbot" }),
    ESP = Window:AddTab({ Title = "🔍 ESP" }),
    Character = Window:AddTab({ Title = "🧍🏿‍♂️ Character" }),
    Settings = Window:AddTab({ Title = "⚙️ Setting" }),
}

-- ข้อมูลพื้นฐาน
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Main Tab - ปุ่มและ UI ครบชุด
Tabs.Main:AddParagraph({
    Title = "📌 XNightWave Menu",
    Content = "เมนูนี้รองรับ Mobile + PC พร้อม ESP / Aimbot และอื่นๆ"
})

-- ===================
-- Aimbot + FOV Circle
-- ===================
local AimbotEnabled = false
local FOVSize = 120
local FOVColor = Color3.fromRGB(0, 255, 0)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = FOVColor
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

local function UpdateFOVCircle()
    FOVCircle.Radius = FOVSize
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end
RunService.RenderStepped:Connect(UpdateFOVCircle)

-- กำหนดตำแหน่งล็อคเริ่มต้น (หัว)
local LockPartName = "Head"

-- Dropdown เลือกล็อคจุด
local Dropdown = Tabs.Aimbot:AddDropdown("TestDropdown", {
    Title = "📋 เลือกล็อค",
    Values = {"หัว", "ลำตัว", "ขา"},
    Multi = false,
    Default = 1
})

Dropdown:OnChanged(function(selected)
    if selected == "หัว" then
        LockPartName = "Head"
    elseif selected == "ลำตัว" then
        LockPartName = "HumanoidRootPart"
    elseif selected == "ขา" then
        LockPartName = "LeftFoot"
    end
    Fluent:Notify({
        Title = "Aimbot Lock",
        Content = "ล็อคที่: "..selected,
        Duration = 2
    })
end)

Tabs.Aimbot:AddToggle("AimbotToggle", {
    Title = "🎯 เปิด/ปิด Aimbot",
    Default = false
}):OnChanged(function(val)
    AimbotEnabled = val
    FOVCircle.Visible = val
    Fluent:Notify({
        Title = "Aimbot",
        Content = val and "เปิดใช้งาน" or "ปิดแล้ว",
        Duration = 3
    })
end)

Tabs.Aimbot:AddSlider("FOVSlider", {
    Title = "🔵 ขนาด FOV",
    Description = "ปรับขนาดวง FOV Aimbot",
    Default = 120,
    Min = 50,
    Max = 300,
    Rounding = 0
}):OnChanged(function(val)
    FOVSize = val
end)

-- Colorpicker เปลี่ยนสี FOV Circle
local Colorpicker = Tabs.Aimbot:AddColorpicker("FOVColorpicker", {
    Title = "🎨 เลือกสี FOV Circle",
    Default = FOVColor,
})
Colorpicker:OnChanged(function()
    FOVColor = Colorpicker.Value
    FOVCircle.Color = FOVColor
end)

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local closest, minDist = nil, math.huge
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild(LockPartName) then
            local part = targetPlayer.Character[LockPartName]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            local screenPos = Vector2.new(pos.X, pos.Y)
            local dist2D = (screenPos - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude

            if onScreen and dist2D <= FOVSize then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {player.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local dir = (part.Position - Camera.CFrame.Position)
                local raycastResult = workspace:Raycast(Camera.CFrame.Position, dir, rayParams)
                if raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(targetPlayer.Character) then
                    local dist3D = dir.Magnitude
                    if dist3D < minDist then
                        minDist = dist3D
                        closest = part
                    end
                end
            end
        end
    end
    if closest then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
    end
end)

-- =========
-- ESP System
-- =========
local ESPEnabled = { Box = false, Health = false, Tracer = false }
local ESPDrawings = {}

local function ClearESP()
    for _, drawing in pairs(ESPDrawings) do
        pcall(function()
            drawing.Visible = false
            drawing:Remove()
        end)
    end
    ESPDrawings = {}
end

Tabs.ESP:AddToggle("BoxESP", { Title = "◼️Box ESP", Default = false })
:OnChanged(function(val) ESPEnabled.Box = val end)

Tabs.ESP:AddToggle("HealthESP", { Title = "❤️ Health ESP", Default = false })
:OnChanged(function(val) ESPEnabled.Health = val end)

Tabs.ESP:AddToggle("TracerESP", { Title = "📍 Tracer ESP", Default = false })
:OnChanged(function(val) ESPEnabled.Tracer = val end)

RunService.RenderStepped:Connect(function()
    ClearESP()
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = targetPlayer.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                if ESPEnabled.Box then
                    local box = Drawing.new("Square")
                    box.Size = Vector2.new(60, 80)
                    box.Position = Vector2.new(pos.X - 30, pos.Y - 40)
                    box.Color = Color3.fromRGB(0, 255, 0)
                    box.Thickness = 2
                    box.Visible = true
                    table.insert(ESPDrawings, box)
                end
                if ESPEnabled.Health then
                    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local hp = math.floor(humanoid.Health)
                        local text = Drawing.new("Text")
                        text.Text = "HP: "..hp
                        text.Position = Vector2.new(pos.X, pos.Y - 50)
                        text.Color = Color3.fromRGB(255, 0, 0)
                        text.Size = 15
                        text.Center = true
                        text.Outline = true
                        text.Visible = true
                        table.insert(ESPDrawings, text)
                    end
                end
                if ESPEnabled.Tracer then
                    local line = Drawing.new("Line")
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Color = Color3.fromRGB(255, 255, 0)
                    line.Thickness = 1
                    line.Visible = true
                    table.insert(ESPDrawings, line)
                end
            end
        end
    end
end)

-- =========
-- Character System (เพิ่ม วิ่งไว, บิน, ทะลุ)
-- =========

-- ตัวแปรเก็บสถานะ
local CharacterSpeedEnabled = false
local FlyEnabled = false
local NoClipEnabled = false

local RunSpeedNormal = 16
local RunSpeedFast = 50
local FlySpeed = 50

local BodyVelocity
local BodyGyro

-- ฟังก์ชันเปิด-ปิดวิ่งไว
Tabs.Character:AddToggle("SpeedToggle", {
    Title = "🏃 วิ่งไว",
    Default = false,
}):OnChanged(function(val)
    CharacterSpeedEnabled = val
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = val and RunSpeedFast or RunSpeedNormal
    end
    Fluent:Notify({
        Title = "Speed",
        Content = val and "วิ่งไวเปิดแล้ว" or "วิ่งไวปิดแล้ว",
        Duration = 2
    })
end)

Tabs.Character:AddSlider("Speedwalk", {
    Title = "ปรับความไว",
    Description = "ปรับความไววิ่ง",
    Default = 50,
    Min = 16,
    Max = 300,
    Rounding = 0
}):OnChanged(function(val)
    RunSpeedFast = val
    if CharacterSpeedEnabled then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = RunSpeedFast
        end
    end
end)

-- ฟังก์ชัน Fly
local function Fly(on)
    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if on then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        BodyVelocity.Parent = humanoidRootPart

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        BodyGyro.P = 1e4
        BodyGyro.Parent = humanoidRootPart

        humanoid.PlatformStand = true

        local function onInput(input, gameProcessed)
            if gameProcessed then return end
            if not FlyEnabled then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W then
                    BodyVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * FlySpeed
                elseif input.KeyCode == Enum.KeyCode.S then
                    BodyVelocity.Velocity = -workspace.CurrentCamera.CFrame.LookVector * FlySpeed
                elseif input.KeyCode == Enum.KeyCode.A then
                    BodyVelocity.Velocity = -workspace.CurrentCamera.CFrame.RightVector * FlySpeed
                elseif input.KeyCode == Enum.KeyCode.D then
                    BodyVelocity.Velocity = workspace.CurrentCamera.CFrame.RightVector * FlySpeed
                elseif input.KeyCode == Enum.KeyCode.Space then
                    BodyVelocity.Velocity = Vector3.new(0, FlySpeed, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftControl then
                    BodyVelocity.Velocity = Vector3.new(0, -FlySpeed, 0)
                end
            end
        end

        local function onInputEnd(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W or
                   input.KeyCode == Enum.KeyCode.S or
                   input.KeyCode == Enum.KeyCode.A or
                   input.KeyCode == Enum.KeyCode.D or
                   input.KeyCode == Enum.KeyCode.Space or
                   input.KeyCode == Enum.KeyCode.LeftControl then
                    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end

        UserInputService.InputBegan:Connect(onInput)
        UserInputService.InputEnded:Connect(onInputEnd)

    else
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
        if BodyGyro then
            BodyGyro:Destroy()
            BodyGyro = nil
        end
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

Tabs.Character:AddToggle("FlyToggle", {
    Title = "🦅 บิน (Fly)",
    Default = false,
}):OnChanged(function(val)
    FlyEnabled = val
    Fly(val)
    Fluent:Notify({
        Title = "Fly",
        Content = val and "บินเปิดแล้ว" or "บินปิดแล้ว",
        Duration = 2
    })
end)

-- ฟังก์ชัน NoClip
local NoClipConnection

local function SetNoClip(on)
    if on then
        NoClipConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if not character then return end
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        -- ให้กลับมา CanCollide = true
        local character = player.Character
        if not character then return end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

Tabs.Character:AddToggle("NoClipToggle", {
    Title = "🚶 ทะลุ (NoClip)",
    Default = false,
}):OnChanged(function(val)
    NoClipEnabled = val
    SetNoClip(val)
    Fluent:Notify({
        Title = "NoClip",
        Content = val and "ทะลุเปิดแล้ว" or "ทะลุปิดแล้ว",
        Duration = 2
    })
end)

-- =======================
-- SaveManager & Interface
-- =======================
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("XNightWave")
SaveManager:SetFolder("XNightWave/CurrentGame")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- แจ้งโหลดเสร็จ
Fluent:Notify({
    Title = "XNightWave",
    Content = "โหลดเมนูและสคริปต์สำเร็จ",
    Duration = 4
})

Window:SelectTab(1)

-- ปุ่ม Toggle เมนูบนหน้าจอ (Mobile + PC)
local VirtualInputManager = game:GetService("VirtualInputManager")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FluentToggleButtonGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 110, 0, 40)
toggleButton.Position = UDim2.new(0, 15, 0, 15)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Text = "XNightWave"
toggleButton.Parent = screenGui
toggleButton.ZIndex = 9999
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", toggleButton).Color = Color3.fromRGB(0, 0, 0)

toggleButton.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end)
