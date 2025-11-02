local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Jem script",
    LoadingTitle = "Loading UI...",
    LoadingSubtitle = "by Deishi",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "MyUIConfig"
    },
    KeySystem = false,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Enter Key 1234",
        Note = "No key required",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = "1234"
    }
})

local TabMain = Window:CreateTab("Main", 4483362458)

TabMain:CreateParagraph({
    Title = "ข้อมูลสคริปต์",
    Content = [[
คนเขียนสคริปต์ (Deishi)
เจ้าของสคริปต์ (Jem)
↓
!!!ฟังชั่นครบ มั้ง
ใช้ก็ระวังบางที่สคริปต์ไม่ติดนะคับ!!!
]]
})

getgenv().TeleportHeight = 6
getgenv().AutoTP = false

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

local UIS = game:GetService("UserInputService")

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

    if plr.Character then
        startLoop(plr.Character)
    end

    plr.CharacterAdded:Connect(function(char)
        startLoop(char)
    end)
end

TabMain:CreateToggle({
    Name = "ออโต้ฟาม(ABOVE MODE)",
    CurrentValue = false,
    Flag = "AutoTPAbove",
    Callback = function(v)
        getgenv().AutoTPAbove = v
        if v then
            if not getgenv().TeleportHeight then
                getgenv().TeleportHeight = 5
            end
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
            if not getgenv().TeleportHeight then
                getgenv().TeleportHeight = 5
            end
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

                local targetCFrame = CFrame.new(
                    -371.222748, 22.6332397, 182.345093,
                    0.0549744181, -5.33845146e-09, 0.998487771,
                    -1.10184317e-09, 1, 5.4072018e-09,
                    -0.998487771, -1.39743472e-09, 0.0549744181
                )

                while getgenv().AutoBringWarp do
                    hrp.CFrame = targetCFrame

                    local folder = workspace:FindFirstChild("SpawnedEnemies")
                    if folder then
                        for _, obj in ipairs(folder:GetChildren()) do
                            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                                local enemyHRP = obj.HumanoidRootPart
                                local offset = hrp.CFrame.LookVector * 3
                                enemyHRP.CFrame = CFrame.new(hrp.Position + offset)
                            elseif obj:IsA("BasePart") then
                                local offset = hrp.CFrame.LookVector * 3
                                obj.CFrame = CFrame.new(hrp.Position + offset)
                            end
                        end
                    end

                    task.wait(0.05)
                end
            end)
        end
    end
})

local TabMap = Window:CreateTab("Map", 4483362458)

TabMain:CreateParagraph({
    Title = "ข้อมูลสคริปต์",
    Content = [[
    เลือก ออโต้ โหวตแมพตรงนี้ได้เลยอย่าเปิด2อันพร้อมกันไม่งั้นจะบัค
]]
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Belimir"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Belimir",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Slime Cave"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Slime Cave",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Bandit Hideout"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Bandit Hideout",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Mushroom Forest"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Mushroom Forest",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Courtyard"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Courtyard",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Overgrown Cavern"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Overgrown Cavern",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Lyseria Desert"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Lyseria Desert",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Frozen Lake"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Frozen Lake",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Skycloud Islands"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Skycloud Islands",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

getgenv().AutoVote = false

local function spamVote()
    task.spawn(function()
        while getgenv().AutoVote do
            pcall(function()
                local args = {"Alstigar Darkswamp"}
                game:GetService("ReplicatedStorage")
                    :WaitForChild("WDOReplicatedStorage")
                    :WaitForChild("Events")
                    :WaitForChild("mapVote")
                    :FireServer(unpack(args))
            end)
            task.wait(0.1)
        end
    end)
end

TabMap:CreateToggle({
    Name = "Alstigar Darkswamp",
    CurrentValue = false,
    Flag = "AutoVoteMap",
    Callback = function(state)
        getgenv().AutoVote = state
        if state then
            spamVote()
        end
    end
})

local TabMini = Window:CreateTab("Mini function", 4483362458)

getgenv().BlockEnemyDamage = false
local mt = getrawmetatable(game)
local oldNamecall
local hooked = false

local function enableHook()
    if hooked then return end
    oldNamecall = mt.__namecall
    setreadonly(mt,false)
    mt.__namecall = newcclosure(function(self,...)
        local method = getnamecallmethod()
        if method == "FireServer" and typeof(self) == "Instance" and self.Name == "enemyDamage" then
            return nil
        end
        return oldNamecall(self,...)
    end)
    setreadonly(mt,true)
    hooked = true
end

local function disableHook()
    if not hooked then return end
    setreadonly(mt,false)
    mt.__namecall = oldNamecall
    setreadonly(mt,true)
    hooked = false
end

TabMini:CreateToggle({
    Name = "อมตะ(GODMODE)",
    CurrentValue = false,
    Flag = "BlockEnemyDamage",
    Callback = function(v)
        getgenv().BlockEnemyDamage = v
        if v then
            enableHook()
            task.spawn(function()
                while getgenv().BlockEnemyDamage do
                    for _,r in ipairs(game:GetDescendants()) do
                        if r:IsA("RemoteEvent") and r.Name == "enemyDamage" then
                            r.FireServer = r.FireServer
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            disableHook()
        end
    end
})
    
getgenv().AutoSetAFK = false

TabMini:CreateToggle({
    Name = "กันหลุด(ANTI AFK)",
    CurrentValue = false,
    Flag = "AutoSetAFK",
    Callback = function(v)
        getgenv().AutoSetAFK = v
        if v then
            task.spawn(function()
                local event = game:GetService("ReplicatedStorage"):WaitForChild("WDOReplicatedStorage"):WaitForChild("Events"):WaitForChild("setAFK")
                while getgenv().AutoSetAFK do
                    pcall(function()
                        local args = {false}
                        event:FireServer(unpack(args))
                    end)
                    task.wait(0.5)
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