local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Jem script",
    LoadingTitle = "Loading UI...",
    LoadingSubtitle = "by Deishi",
    ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "MyUIConfig" },
    KeySystem = false
})

local TabMain = Window:CreateTab("Main", 4483362458)

TabMain:CreateParagraph({
    Title = "ข้อมูลสคริปต์",
    Content = [[
คนเขียนสคริปต์ (Deishi)
เจ้าของสคริปต์ (Jem)
ฟังก์ชั่นครบ
]]
})

getgenv().TeleportHeight = 6

TabMain:CreateSlider({
    Name = "ปรับค่า(Distance Config)",
    Range = {1, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 6,
    Flag = "TPHeight",
    Callback = function(v)
        getgenv().TeleportHeight = v
    end
})

local function autoFarm(mode)
    local plr = game.Players.LocalPlayer
    local function startLoop(char)
        local hrp = char:WaitForChild("HumanoidRootPart")
        task.spawn(function()
            while getgenv()[mode] do
                local folder = workspace:FindFirstChild("SpawnedEnemies")
                if folder then
                    for _,enemy in ipairs(folder:GetChildren()) do
                        if enemy:FindFirstChild("HumanoidRootPart") then
                            if mode == "AutoTPAbove" then
                                hrp.CFrame = enemy.HumanoidRootPart.CFrame *
                                    CFrame.new(0, getgenv().TeleportHeight or 5, 0) *
                                    CFrame.Angles(math.rad(-90),0,0)
                            elseif mode == "AutoTPBack" then
                                local backOffset = -enemy.HumanoidRootPart.CFrame.LookVector * (getgenv().TeleportHeight or 5)
                                local targetPos = enemy.HumanoidRootPart.Position
                                hrp.CFrame = CFrame.lookAt(targetPos + backOffset, targetPos)
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    end

    if plr.Character then startLoop(plr.Character) end
    plr.CharacterAdded:Connect(function(char) startLoop(char) end)
end

TabMain:CreateToggle({
    Name = "ออโต้ฟาม(ABOVE MODE)",
    CurrentValue = false,
    Flag = "AutoTPAbove",
    Callback = function(v)
        getgenv().AutoTPAbove = v
        if v then
            if not getgenv().TeleportHeight then getgenv().TeleportHeight = 5 end
            autoFarm("AutoTPAbove")
        end
    end
})

TabMain:CreateToggle({
    Name = "ออโต้ฟาม(BACK MODE)",
    CurrentValue = false,
    Flag = "AutoTPBack",
    Callback = function(v)
        getgenv().AutoTPBack = v
        if v then
            if not getgenv().TeleportHeight then getgenv().TeleportHeight = 5 end
            autoFarm("AutoTPBack")
        end
    end
})

local bringToggle = TabMain:CreateToggle({
    Name = "ออโต้ฟาม(BRING MODE)",
    CurrentValue = false,
    Flag = "AutoBringWarp",
    Callback = function(v)
        getgenv().AutoBringWarp = v
        if v then
            task.spawn(function()
                local plr = game.Players.LocalPlayer
                local char = plr.Character or plr.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                plr.CharacterAdded:Connect(function(c)
                    char = c
                    hrp = char:WaitForChild("HumanoidRootPart")
                end)
                local targetCFrame = CFrame.new(-371.22, 22.63, 182.34, 0.05,0,0.99,0,1,0,-0.99,0,0.05)
                while getgenv().AutoBringWarp do
                    hrp.CFrame = targetCFrame
                    local folder = workspace:FindFirstChild("SpawnedEnemies")
                    if folder then
                        for _, obj in ipairs(folder:GetChildren()) do
                            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                                obj.HumanoidRootPart.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector*3)
                            elseif obj:IsA("BasePart") then
                                obj.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector*3)
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

local TabVis = Window:CreateTab("Visual", 4483362458)

TabVis:CreateToggle({
    Name = "ลบเงาเพิ่มแสง(no shadow)",
    CurrentValue = false,
    Flag = "ClearSkyBright",
    Callback = function(v)
        getgenv().ClearSkyBright = v
        if v then
            task.spawn(function()
                local lighting = game:GetService("Lighting")
                while getgenv().ClearSkyBright do
                    for _, child in ipairs(lighting:GetChildren()) do
                        if child:IsA("Sky") or child:IsA("Atmosphere") then child:Destroy() end
                    end
                    lighting.GlobalShadows = false
                    lighting.Brightness = 5
                    lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
                    task.wait(1)
                end
            end)
        end
    end
})

TabVis:CreateToggle({
    Name = "แก้แลค(Boost fps)",
    CurrentValue = false,
    Flag = "BoostFPS",
    Callback = function(v)
        getgenv().BoostFPS = v
        if v then
            task.spawn(function()
                local lighting = game:GetService("Lighting")
                local workspace = game:GetService("Workspace")
                while getgenv().BoostFPS do
                    for _, obj in ipairs(lighting:GetChildren()) do
                        if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("BlurEffect") then
                            obj:Destroy()
                        end
                    end
                    lighting.GlobalShadows = false
                    lighting.FogEnd = 1e10
                    lighting.Brightness = 5
                    lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)

                    for _, part in ipairs(workspace:GetDescendants()) do
                        if part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("Part") then
                            part.Material = Enum.Material.Plastic
                        elseif part:IsA("Texture") or part:IsA("Decal") then
                            part:Destroy()
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})