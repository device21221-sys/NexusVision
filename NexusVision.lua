local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NightFallScript/Custom-Lib/refs/heads/main/UtopiaModifedSource.lua"))()

local Window = Library:Window({
    Name = "N E X U S V I S I O N",
    GradientTitle = {
        Enabled = true,
        Start = Color3.fromRGB(0, 0, 0),
        Middle = Color3.fromRGB(61, 0, 0),
        End = Color3.fromRGB(184, 0, 0),
        Speed = 0.4
    }
})

local Watermark = Library:Watermark("NexusVision.lua | Apocalypse Rising 2 | V2.1a         ", {"75293934575475", Color3.fromRGB()})
local KeybindList = Library:KeybindList()

--Watermark:SetVisibility(false)
--KeybindList:SetVisibility(false)
local VisualsTab = Window:Page({Name = "Visuals", Columns = 2  })
local CombatTab = Window:Page({Name = "Combat", Columns = 2  })
local RageTab = Window:Page({Name = "Rage", Columns = 2  })
local MiscTab = Window:Page({Name = "Misc", Columns = 2  })
local SettingsTab = Window:Page({Name = "Settings", Columns = 2 })
-- ==================== GLOBAL SERVICES ====================
local MiscSection = MiscTab:Section({Name = "Misc", Side = 1 })
local SelectedAction = nil

-- Dropdown для вибору дії
local Dropdown = MiscSection:Dropdown({
    Name = "Select you action",
    Flag = "Dropdown",
    Items = { "Bring Loot To Inventory", "Bring Loot To Ground", "Open All Containers" },
    Multi = false,
    Default = nil,
    Callback = function(Value)
        SelectedAction = Value
        print("Selected action:", Value)
    end
})

-- Toggle замість кнопки Load
local Toggle = MiscSection:Toggle({
    name = "Load action",
    Flag = "LootActionToggle",
    Callback = function(state)
        if not state then return end  -- спрацьовує тільки при увімкненні

        if not SelectedAction then
            warn("No action selected in dropdown.")
            return
        end

        local success, Framework = pcall(function()
            return require(game:GetService("ReplicatedFirst").Framework)
        end)
        if not success then
            warn("Cannot access Framework")
            return
        end

        local function bringToInventory()
            for i, v in pairs(getgc(true)) do
                pcall(function()
                    if type(v) == "table" then
                        local id = rawget(v, "Id")
                        if id ~= nil and rawget(v, "ClassName") == "Interactable" and tostring(rawget(v, "Adornee")) == "Model" then
                            local newid = string.sub(id, 37)
                            Framework.Libraries.Network:Send("Client Interacted", id, false, newid)
                        end
                    end
                end)
            end
        end

        local function bringToGround()
            for i, v in pairs(getgc(true)) do
                pcall(function()
                    if type(v) == "table" then
                        local id = rawget(v, "Id")
                        if id ~= nil and rawget(v, "ClassName") == "Interactable" and tostring(rawget(v, "Adornee")) == "Model" then
                            local newid = string.sub(id, 37)
                            Framework.Libraries.Network:Send("Client Interacted", id, false, newid)
                            Framework.Libraries.Network:Send("Inventory Drop Item", newid)
                        end
                    end
                end)
            end
        end

        local function openAllContainers()
            for i, v in pairs(getgc(true)) do
                pcall(function()
                    if type(v) == "table" then
                        local id = rawget(v, "Id")
                        if id ~= nil and rawget(v, "ClassName") == "Entity" and rawget(v, "Type") == "Loot Group" then
                            local newid = string.sub(id, 37)
                            Framework.Libraries.Network:Send("Client Interacted", id)
                            Framework.Libraries.Network:Send("Inventory Drop Item", newid)
                        end
                    end
                end)
            end
        end

        -- Виконання обраної дії
        if SelectedAction == "Bring Loot To Inventory" then
            bringToInventory()
        elseif SelectedAction == "Bring Loot To Ground" then
            bringToGround()
        elseif SelectedAction == "Open All Containers" then
            openAllContainers()
        else
            warn("Unknown action:", SelectedAction)
        end
    end
})

local MiscSection = MiscTab:Section({Name = "Anti Zombie", Side = 1 })
-- 🔍 Автопошук папки зомбі
local zombiesFolder
for _, obj in ipairs(workspace:GetChildren()) do
    if obj:IsA("Folder") and obj.Name:lower():find("zombie") then
        zombiesFolder = obj
        warn("", obj.Name)
        break
    end
end

if not zombiesFolder then
    warn("❌")
    return
end

-- 🧊 Freeze System
local isFreezeEnabled = true

local function freezeZombie(zombie)
    local humanoid = zombie:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetAttribute("DefaultWalkSpeed", humanoid.WalkSpeed)
        humanoid:SetAttribute("DefaultJumpPower", humanoid.JumpPower)
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
    for _, part in ipairs(zombie:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
end

local function unfreezeZombie(zombie)
    local humanoid = zombie:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = humanoid:GetAttribute("DefaultWalkSpeed") or 16
        humanoid.JumpPower = humanoid:GetAttribute("DefaultJumpPower") or 50
    end
    for _, part in ipairs(zombie:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
end

local Toggle = MiscSection:Toggle({
    name = "Freeze Zombies",
    flag = "FreezeZombie",
    callback = function(enabled)
        isFreezeEnabled = enabled
        for _, zombie in pairs(zombiesFolder:GetChildren()) do
            if zombie:IsA("Model") then
                if isFreezeEnabled then
                    freezeZombie(zombie)
                else
                    unfreezeZombie(zombie)
                end
            end
        end
    end
})

-- 🌀 Zombie Circle
local zombieCircleEnabled = false
local zombieCircleDistance = 10
local zombieCircleSpeed = 5

local function makeZombiesCircle()
    task.spawn(function()
        while zombieCircleEnabled do
            local localPlayer = game:GetService("Players").LocalPlayer
            local rootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

            if rootPart then
                local count = #zombiesFolder:GetChildren()
                local angleStep = math.pi * 2 / math.max(count, 1)

                for i, zombie in ipairs(zombiesFolder:GetChildren()) do
                    local root = zombie:FindFirstChild("HumanoidRootPart")
                    if root then
                        local angle = tick() * zombieCircleSpeed + (i * angleStep)
                        local offset = Vector3.new(
                            math.cos(angle) * zombieCircleDistance,
                            0,
                            math.sin(angle) * zombieCircleDistance
                        )
                        root.CFrame = CFrame.new(rootPart.Position + offset)
                    end
                end
            end

            task.wait()
        end
    end)
end

local Toggle = MiscSection:Toggle({
    name = "Zombie Circle",
    flag = "ZombieCircle",
    callback = function(enabled)
        zombieCircleEnabled = enabled
        if enabled then
            makeZombiesCircle()
        end
    end
})

local Slider = MiscSection:Slider({
    name = "Zombie Circle Distance",
    flag = "ZombieCircleDistance",
    min = 5,
    max = 50,
    value = 10,
    float = 1,
    callback = function(value)
        zombieCircleDistance = value
    end
})

local Slider = MiscSection:Slider({
    name = "Zombie Circle Speed",
    flag = "ZombieCircleSpeed",
    min = 1,
    max = 20,
    value = 5,
    float = 1,
    callback = function(value)
        zombieCircleSpeed = value
    end
})

task.spawn(function()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local terrain = workspace:FindFirstChild("Terrain")

-- ==================== MOVEMENT / CHARACTER ====================
local movementFlags = {
    walkingSpeed = 16,
    runningSpeed = 20,
    walkEnabled = false,
    runEnabled = false,
    isRunning = false,
    noSprintPenalty = false,
    antiDebuffEnabled = false,
    noRagdollEnabled = false,
    infJumpEnabled = false,
    infJumpPower = 50,
    noFallEnabled = false,
    noFallSpeed = 0,
}
local MovmentSection = RageTab:Section({Name = "Movement", Side = 1 })

-- Walk / Run
local Toggle = MovmentSection:Toggle({
    name = "Walking Speed",
    flag = "WalkingSpeedToggle",
    callback = function(state)
        movementFlags.walkEnabled = state
    end
})
local Slider = MovmentSection:Slider({
    name = "Walking Speed",
    flag = "WalkingSpeedSlider",
    min = 16,
    max = 21,
    value = 16,
    float = 1,
    callback = function(val)
        movementFlags.walkingSpeed = val
    end
})
local Toggle = MovmentSection:Toggle({
    name = "Running Speed",
    flag = "RunningSpeedToggle",
    callback = function(state)
        movementFlags.runEnabled = state
    end
})
local Slider = MovmentSection:Slider({
    name = "Running Speed",
    flag = "RunningSpeedSlider",
    min = 20,
    max = 30,
    value = 20,
    float = 1,
    callback = function(val)
        movementFlags.runningSpeed = val
    end
})

local MovemenSection = RageTab:Section({Name = "Character", Side = 1})

-- Character Toggles
local Toggle = MovemenSection:Toggle({
    name = "No Sprint Penalty",
    flag = "NoSprintPenaltyToggle",
    callback = function(state)
        movementFlags.noSprintPenalty = state
    end
})
local Toggle = MovemenSection:Toggle({
    name = "Anti Debuff",
    flag = "AntiDebuffToggle",
    callback = function(state)
        movementFlags.antiDebuffEnabled = state
    end
})
local Toggle = MovemenSection:Toggle({
    name = "No Ragdoll",
    flag = "NoRagdollToggle",
    callback = function(state)
        movementFlags.noRagdollEnabled = state
    end
})
local Toggle = MovemenSection:Toggle({
    name = "Inf Jump",
    flag = "InfJumpToggle",
    callback = function(state)
        movementFlags.infJumpEnabled = state
    end
})
local Slider = MovemenSection:Slider({
    name = "Inf Jump Power",
    flag = "InfJumpSlider",
    min = 10,
    max = 100,
    value = 50,
    float = 1,
    callback = function(val)
        movementFlags.infJumpPower = val
    end
})
local Toggle = MovemenSection:Toggle({
    name = "No Fall Speed",
    flag = "NoFallToggle",
    callback = function(state)
        movementFlags.noFallEnabled = state
    end
})
local Slider = MovemenSection:Slider({
    name = "No Fall Speed Power",
    flag = "NoFallSlider",
    min = 0,
    max = 50,
    value = 0,
    float = 1,
    callback = function(val)
        movementFlags.noFallSpeed = val
    end
})

-- Inputs
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        movementFlags.isRunning = true
    elseif input.KeyCode == Enum.KeyCode.Space and movementFlags.infJumpEnabled then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, movementFlags.infJumpPower, hrp.Velocity.Z)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        movementFlags.isRunning = false
    end
end)

-- Movement loop
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- Walk / Run
    if movementFlags.runEnabled and movementFlags.isRunning then
        hum.WalkSpeed = movementFlags.runningSpeed
    elseif movementFlags.walkEnabled then
        hum.WalkSpeed = movementFlags.walkingSpeed
    end

    -- No Fall
    if movementFlags.noFallEnabled then
        local vel = hrp.Velocity
        if vel.Y < -movementFlags.noFallSpeed then
            hrp.Velocity = Vector3.new(vel.X, -movementFlags.noFallSpeed, vel.Z)
        end
    end

    -- No Ragdoll
    if movementFlags.noRagdollEnabled and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    -- No Sprint Penalty
    if movementFlags.noSprintPenalty then
        hum.WalkSpeed = math.max(hum.WalkSpeed, movementFlags.runningSpeed)
    end

    -- Anti Debuff
    if movementFlags.antiDebuffEnabled then
        for _, child in ipairs(hum:GetChildren()) do
            if (child:IsA("BoolValue") or child:IsA("NumberValue")) and (child.Name:lower():find("debuff") or child.Name:lower():find("slow")) then
                child:Destroy()
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.2)
    hum.WalkSpeed = movementFlags.walkEnabled and movementFlags.walkingSpeed or movementFlags.runningSpeed
end)

-- ==================== ANTI AIM ====================
local AntiAimSection = RageTab:Section({Name = "Anti Aim", Side = 2})

local antiAimFlags = {enabled = false, spinSpeed = 5, permaSpin = false}
local Toggle = AntiAimSection:Toggle({
    name = "Enable Anti-Aim",
    flag = "antiAim",
    callback = function(state) antiAimFlags.enabled = state end
})
local Toggle = AntiAimSection:Toggle({
    name = "Perma Spin",
    flag = "permaSpin",
    callback = function(state) antiAimFlags.permaSpin = state end
})
local Slider = AntiAimSection:Slider({
    name = "Spin Speed",
    flag = "spinSpeed",
    min = 1,
    max = 20,
    value = 5,
    callback = function(val) antiAimFlags.spinSpeed = val end
})

local angle = 0
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and antiAimFlags.enabled then
        angle += math.rad(antiAimFlags.spinSpeed)
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, angle, 0)
    end
end)
end)

local CombatSection = CombatTab:Section({Name = "Gun Mods", Side = 2 })
task.spawn(function()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Firearm = nil
task.spawn(function()
    setthreadidentity(2)
    Firearm = require(ReplicatedStorage.Client.Abstracts.ItemInitializers.Firearm)
end)

repeat task.wait() until Firearm

local Framework = require(ReplicatedFirst:WaitForChild("Framework"))
Framework:WaitForLoaded()

local Animators = Framework.Classes.Animators
local Firearms = Framework.Classes.Firearm

local AnimatedReload = getupvalue(Firearm, 7)

setupvalue(Firearm, 7, function(...)
    if Window.Flags["AR2/InstantReload"] then
        local Args = {...}
        for Index = 0, Args[3].LoopCount do
            Args[4]("Commit", "Load")
        end
        Args[4]("Commit", "End")
        return true
    end

    return AnimatedReload(...)
end)

local Toggle = CombatSection:Toggle({
    Name = "Instant Reload",
    Flag = "AR2/InstantReload",
    Callback = function(state)
    end
})

local Toggle = CombatSection:Toggle({
    Name = "Unlock Firemodes",
    Flag = "AR2/UnlockFiremodes",
    Callback = function(state)
        if not state then return end

        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()

        repeat task.wait() until Character:FindFirstChild("Actions") and Character.Actions:FindFirstChild("ToolAction")

        local OldToolAction
        OldToolAction = hookfunction(Character.Actions.ToolAction, newcclosure(function(Self, ...)
            if not Self.EquippedItem then 
                return OldToolAction(Self, ...) 
            end

            local FireModes = Self.EquippedItem.FireModes
            if not FireModes then 
                return OldToolAction(Self, ...) 
            end

            for _, Mode in ipairs({"Semi", "Semiautomatic", "Automatic", "Burst"}) do
                if not table.find(FireModes, Mode) then
                    setreadonly(FireModes, false)
                    table.insert(FireModes, Mode)
                    setreadonly(FireModes, true)
                end
            end

            return OldToolAction(Self, ...)
        end))
    end
})

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FrameworkModule = require(ReplicatedFirst:WaitForChild("Framework"))
FrameworkModule:WaitForLoaded()

local Interface = FrameworkModule.Libraries.Interface
local Network = FrameworkModule.Libraries.Network
local Bullets = FrameworkModule.Libraries.Bullets

local GetSpreadAngle = getupvalue(Bullets.Fire, 1)
local originalFire = Bullets.Fire

local noSpreadEnabled = false
local spreadScale = 0

local Toggle = CombatSection:Toggle({
    Name = "No Spread",
    Flag = "No Spread",
    Callback = function(state)
        noSpreadEnabled = state
    end
})

local Slider = CombatSection:Slider({
    Name = "Spread Amount",
    Flag = "SpreadAmount",
    Min = 0,
    Max = 100,
    Default = 0,
    Decimals = 1,
    Callback = function(value)
        spreadScale = value / 100
    end
})

setupvalue(Bullets.Fire, 1, function(Character, CCamera, Weapon, ...)
    if noSpreadEnabled then
        local OldMoveState = Character.MoveState
        local OldZooming = Character.Zooming
        local OldFirstPerson = CCamera.FirstPerson

        Character.MoveState = "Walking"
        Character.Zooming = true
        CCamera.FirstPerson = true

        local ReturnArgs = {GetSpreadAngle(Character, CCamera, Weapon, ...)}

        Character.MoveState = OldMoveState
        Character.Zooming = OldZooming
        CCamera.FirstPerson = OldFirstPerson

        return unpack(ReturnArgs)
    end

    return GetSpreadAngle(Character, CCamera, Weapon, ...)
end)

local ReplicatedFirst = cloneref(game:GetService("ReplicatedFirst"))
local Bullets = require(ReplicatedFirst:WaitForChild("Framework")).Libraries.Bullets

local GetFireImpulse = getupvalue(Bullets.Fire, 6)


local noRecoilEnabled = false
local recoilScale = 0.1


setupvalue(Bullets.Fire, 6, function(...)
    local impulse = {GetFireImpulse(...)}

    if noRecoilEnabled then
        for i = 1, #impulse do
            impulse[i] = impulse[i] * recoilScale
        end
    end

    return unpack(impulse)
end)

local Toggle = CombatSection:Toggle({
    Name = "No Recoil",
    Flag = "No Recoil",
    Callback = function(state)
        noRecoilEnabled = state
    end
})

local Slider = CombatSection:Slider({
    Name = "Recoil Control",
    Flag = "Recoil",
    Min = 0,
    Max = 100,
    Default = 0,
    Decimals = 1,
    Callback = function(value)
        recoilScale = value / 100
    end
})

end)

local VisualsSection = VisualsTab:Section({Name = "Player Esp", Side = 1 })
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flags = {}
local settings = {
    maxHPVisibility = 100,
    boxType = "Boxes",       -- Boxes / Corners
    boxRender = "Dynamic",   -- Dynamic / Static
    metric = "Meters",       -- Meters / Studs
    useDisplayName = true
}

-- === ESP TOGGLES ===
local Toggle = VisualsSection:Toggle({
    Name = "Enable ESP",
    Default = false,
    Flag = "enable esp",
    callback = function(state) flags["enable esp"] = state end
})

local Toggle = VisualsSection:Toggle({
    Name = "Box",
    Default = false,
    Flag = "box",
    callback = function(state) flags["box"] = state end
})
Toggle:Colorpicker({
    Name = "Box Color",
    Flag = "color box",
    Color = Color3.new(1,1,1),
    callback = function(color) flags["color box"] = color end
})

-- Health bar
local Toggle = VisualsSection:Toggle({
    Name = "Health Bar",
    Default = false,
    Flag = "box bar",
    callback = function(state) flags["box bar"] = state end
})
Toggle:Colorpicker({
    Name = "Full Health Color",
    Flag = "color hp full",
    Color = Color3.fromRGB(0,255,0),
    callback = function(color) flags["color hp full"] = color end
})
Toggle:Colorpicker({
    Name = "Low Health Color",
    Flag = "color hp low",
    Color = Color3.fromRGB(255,0,0),
    callback = function(color) flags["color hp low"] = color end
})

-- Name
local Toggle = VisualsSection:Toggle({
    Name = "Show Name",
    Default = false,
    Flag = "box name",
    callback = function(state) flags["box name"] = state end
})

-- Distance
local Toggle = VisualsSection:Toggle({
    Name = "Distance",
    Default = false,
    Flag = "box discr",
    callback = function(state) flags["box discr"] = state end
})
Toggle:Colorpicker({
    Name = "Distance Color",
    Flag = "distance",
    Color = Color3.new(1,1,1),
    callback = function(color) flags["distance"] = color end
})

-- Equipped Item
local Toggle = VisualsSection:Toggle({
    Name = "Equipped Item",
    Default = false,
    Flag = "box item",
    callback = function(state) flags["box item"] = state end
})
Toggle:Colorpicker({
    Name = "Item Color",
    Flag = "color item",
    Color = Color3.new(1,1,1),
    callback = function(color) flags["color item"] = color end
})

-- Health Number
local Toggle = VisualsSection:Toggle({
    Name = "Health Number",
    Default = false,
    Flag = "box number hear",
    callback = function(state) flags["box number hear"] = state end
})

-- Tracer
local Toggle = VisualsSection:Toggle({
    Name = "Tracer",
    Default = false,
    Flag = "tbox",
    callback = function(state) flags["tbox"] = state end
})
Toggle:Colorpicker({
    Name = "Tracer Color",
    Flag = "color tracer",
    Color = Color3.new(1,1,1),
    callback = function(color) flags["color tracer"] = color end
})

-- Distance check slider
local Slider = VisualsSection:Slider({
    Name = "Distance Check",
    Flag = "dis chek",
    Min = 1000,
    Max = 10000,
    value = 5000,
    Decimals = 1,
    callback = function(val) flags["dis chek"] = val end
})

-- === SETTINGS SECTION ===
local SettingsSection = VisualsTab:Section({Name = "ESP Settings", Side = 1})

SettingsSection:Slider({
    Name = "Max HP Visibility",
    Flag = "max hp visibility",
    Min = 0,
    Max = 100,
    value = 100,
    callback = function(val)
        settings.maxHPVisibility = val
    end
})

SettingsSection:Dropdown({
    Name = "Box Type",
    Flag = "box type",
    Default = "Boxes",
    items = {"Boxes","Corners"},
    callback = function(val)
        settings.boxType = val
    end
})

SettingsSection:Dropdown({
    Name = "Box Render",
    Flag = "box render",
    Default = "Static",
    items = {"Dynamic","Static"},
    callback = function(val)
        settings.boxRender = val
    end
})

SettingsSection:Dropdown({
    Name = "Metric",
    Flag = "metric",
    Default = "Studs",
    items = {"Meters","Studs"},
    callback = function(val)
        settings.metric = val
    end
})

SettingsSection:Toggle({
    Name = "Use Display Name",
    Default = false,
    Flag = "use display name",
    callback = function(state)
        settings.useDisplayName = state
    end
})

-- === CREATE ESP OBJECT ===
local function CreateESP()
    local esp = {}

    esp.BoxOutline = Drawing.new("Square")
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Color = Color3.new(0,0,0)
    esp.BoxOutline.Thickness = 2

    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Color3.new(1,1,1)
    esp.Box.Thickness = 1

    esp.CornerLines = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        table.insert(esp.CornerLines, line)
    end

    esp.HealthBarOutline = Drawing.new("Line")
    esp.HealthBarOutline.Visible = false
    esp.HealthBarOutline.Color = Color3.new(0,0,0)
    esp.HealthBarOutline.Thickness = 4

    esp.HealthBar = Drawing.new("Line")
    esp.HealthBar.Visible = false
    esp.HealthBar.Thickness = 2

    esp.NameText = Drawing.new("Text")
    esp.NameText.Visible = false
    esp.NameText.Outline = true
    esp.NameText.Center = true
    esp.NameText.Size = 14
    esp.NameText.Font = 1 

    esp.DistanceText = Drawing.new("Text")
    esp.DistanceText.Visible = false
    esp.DistanceText.Outline = true
    esp.DistanceText.Center = true
    esp.DistanceText.Size = 13
    esp.DistanceText.Font = 1

    esp.HealthPercentText = Drawing.new("Text")
    esp.HealthPercentText.Visible = false
    esp.HealthPercentText.Outline = true
    esp.HealthPercentText.Center = true
    esp.HealthPercentText.Size = 13
    esp.HealthPercentText.Font = 1

    esp.TracerLine = Drawing.new("Line")
    esp.TracerLine.Visible = false
    esp.TracerLine.Thickness = 1

    esp.ItemText = Drawing.new("Text")
    esp.ItemText.Visible = false
    esp.ItemText.Outline = true
    esp.ItemText.Center = true
    esp.ItemText.Size = 13
    esp.ItemText.Font = 1

    return esp
end

-- === ESP HANDLERS ===
local ESPTable = {}

local function RemoveESP(player)
    if ESPTable[player] then
        for _, v in pairs(ESPTable[player]) do
            if typeof(v) == "table" then
                for _, line in ipairs(v) do pcall(line.Remove, line) end
            else
                pcall(v.Remove, v)
            end
        end
        ESPTable[player] = nil
    end
end

local function AddESP(player)
    if player ~= LocalPlayer and not ESPTable[player] then
        ESPTable[player] = CreateESP()
    end
end

for _, p in ipairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- === MAIN RENDER LOOP ===
RunService.RenderStepped:Connect(function()
    if not flags["enable esp"] then
        for _, esp in pairs(ESPTable) do
            for _, v in pairs(esp) do
                if typeof(v) == "table" then
                    for _, l in ipairs(v) do l.Visible = false end
                else
                    v.Visible = false
                end
            end
        end
        return
    end

    local camPos = Camera.CFrame.Position
    local maxDistance = flags["dis chek"] or 10000
    local viewSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewSize.X/2, viewSize.Y)

    for player, esp in pairs(ESPTable) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local distance = (camPos - hrp.Position).Magnitude

            if not onScreen or distance > maxDistance then
                for _, v in pairs(esp) do
                    if typeof(v) == "table" then
                        for _, l in ipairs(v) do l.Visible = false end
                    else
                        v.Visible = false
                    end
                end
                continue
            end

            local boxWidth, boxHeight = 40, 60
            if settings.boxRender == "Dynamic" then
                local scale = math.clamp(100 / distance, 0, 300)
                boxWidth, boxHeight = 40*scale, 60*scale
            end

            local xPos, yPos = pos.X - boxWidth/2, pos.Y - boxHeight/2

            local boxEnabled    = flags["box"]
            local barEnabled    = flags["box bar"]
            local nameEnabled   = flags["box name"]
            local discrEnabled  = flags["box discr"]
            local numberEnabled = flags["box number hear"]
            local itemEnabled   = flags["box item"]

            local boxColor      = flags["color box"] or Color3.new(1,1,1)
            local tracerColor   = flags["color tracer"] or Color3.new(1,1,1)
            local discrColor    = flags["distance"] or Color3.new(1,1,1)
            local itemColor     = flags["color item"] or Color3.new(1,1,1)

            -- Box Type handling
            if boxEnabled then
                if settings.boxType == "Boxes" then
                    -- Main Box
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(xPos, yPos)
                    esp.Box.Color = boxColor
                    esp.Box.Visible = true

                    esp.BoxOutline.Size = esp.Box.Size
                    esp.BoxOutline.Position = esp.Box.Position
                    esp.BoxOutline.Visible = true

                    -- Hide corner lines
                    for _, l in ipairs(esp.CornerLines) do l.Visible = false end
                elseif settings.boxType == "Corners" then
                    -- Hide main box
                    esp.Box.Visible, esp.BoxOutline.Visible = false, false

                    -- Draw corner lines
                    local cornerLen = boxWidth*0.25
                    local lines = esp.CornerLines
                    local cx, cy, w, h = xPos, yPos, boxWidth, boxHeight
                    local corners = {
                        {cx, cy, cx+cornerLen, cy},
                        {cx, cy, cx, cy+cornerLen},
                        {cx+w, cy, cx+w-cornerLen, cy},
                        {cx+w, cy, cx+w, cy+cornerLen},
                        {cx, cy+h, cx+cornerLen, cy+h},
                        {cx, cy+h, cx, cy+h-cornerLen},
                        {cx+w, cy+h, cx+w-cornerLen, cy+h},
                        {cx+w, cy+h, cx+w, cy+h-cornerLen}
                    }
                    for i, c in ipairs(corners) do
                        local line = lines[i]
                        line.From = Vector2.new(c[1], c[2])
                        line.To = Vector2.new(c[3], c[4])
                        line.Color = boxColor
                        line.Visible = true
                    end
                end
            else
                esp.Box.Visible, esp.BoxOutline.Visible = false, false
                for _, l in ipairs(esp.CornerLines) do l.Visible = false end
            end

            -- Tracer
            if flags["tbox"] then
                esp.TracerLine.From = screenCenter
                esp.TracerLine.To = Vector2.new(pos.X,pos.Y)
                esp.TracerLine.Color = tracerColor
                esp.TracerLine.Visible = true
            else
                esp.TracerLine.Visible = false
            end

            -- Health bar + number
            local healthPercent
            if barEnabled or numberEnabled then
                healthPercent = math.clamp(hum.Health/hum.MaxHealth,0,1)
            end

            if barEnabled then
                local barHeight = boxHeight*healthPercent
                local barX = xPos-3
                local barY1 = yPos+boxHeight
                local barY2 = barY1-barHeight
                local lowColor = flags["color hp low"] or Color3.fromRGB(255,0,0)
                local fullColor = flags["color hp full"] or Color3.fromRGB(0,255,0)
                local r = lowColor.R + (fullColor.R-lowColor.R)*healthPercent
                local g = lowColor.G + (fullColor.G-lowColor.G)*healthPercent
                local b = lowColor.B + (fullColor.B-lowColor.B)*healthPercent
                local hpColor = Color3.new(r,g,b)

                esp.HealthBar.From = Vector2.new(barX,barY1)
                esp.HealthBar.To = Vector2.new(barX,barY2)
                esp.HealthBar.Color = hpColor
                esp.HealthBar.Visible = true

                esp.HealthBarOutline.From = Vector2.new(barX,yPos)
                esp.HealthBarOutline.To = Vector2.new(barX,yPos+boxHeight)
                esp.HealthBarOutline.Visible = true

                if numberEnabled then
                    esp.HealthPercentText.Text = string.format("%.0f%%",healthPercent*100)
                    esp.HealthPercentText.Position = Vector2.new(barX-15,(barY1+barY2)/2)
                    esp.HealthPercentText.Color = hpColor
                    esp.HealthPercentText.Visible = true
                else
                    esp.HealthPercentText.Visible = false
                end
            else
                esp.HealthBar.Visible, esp.HealthBarOutline.Visible, esp.HealthPercentText.Visible = false,false,false
            end

            -- Name
            if flags["box name"] then
                esp.NameText.Text = settings.useDisplayName and player.DisplayName or player.Name
                esp.NameText.Position = Vector2.new(pos.X, yPos-20)
                esp.NameText.Color = boxColor
                esp.NameText.Visible = true
            else
                esp.NameText.Visible = false
            end

            -- Distance
            if flags["box discr"] then
                local distText = settings.metric == "Meters" and string.format("%.0fm",distance) or string.format("%.0fs",distance)
                esp.DistanceText.Text = distText
                esp.DistanceText.Position = Vector2.new(pos.X, yPos+boxHeight+5)
                esp.DistanceText.Color = discrColor
                esp.DistanceText.Visible = true
            else
                esp.DistanceText.Visible = false
            end

            -- Equipped Item
            if flags["box item"] then
                local itemName = "Hands"
                if char:FindFirstChild("Equipped") then
                    local item = char.Equipped:FindFirstChildOfClass("Model")
                    if item then itemName = item.Name end
                end
                esp.ItemText.Text = "["..itemName.."]"
                esp.ItemText.Position = Vector2.new(pos.X, yPos+boxHeight+20)
                esp.ItemText.Color = itemColor
                esp.ItemText.Visible = true
            else
                esp.ItemText.Visible = false
            end

        else
            for _, v in pairs(esp) do
                if typeof(v) == "table" then
                    for _, l in ipairs(v) do l.Visible = false end
                else
                    v.Visible = false
                end
            end
        end
    end
end)

local VisualsSection = VisualsTab:Section({Name = "Corpse Esp", Side = 1 })
local corpsesFolder = workspace:WaitForChild("Corpses")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local corpseESPEnabled = false
local showNames = false
local showDistance = false
local maxDistance = 10000

local corpseHighlightColor = Color3.fromRGB(255, 0, 0)
local corpseNameColor = Color3.fromRGB(255, 150, 0)
local corpseDistanceColor = Color3.fromRGB(255, 255, 255)

local fontSize = 11  -- як у Weapon ESP
local fontType = Enum.Font.Code

-- Функції
local function isIgnoredCorpse(model)
    return model.Name:lower():find("infected") ~= nil
end

local function removeESP(model)
    local highlight = model:FindFirstChild("CorpseHighlight")
    if highlight then highlight:Destroy() end
    local espGui = model:FindFirstChild("CorpseESP")
    if espGui then espGui:Destroy() end
end

local function createHighlight(model)
    if isIgnoredCorpse(model) then return end
    if not model:FindFirstChild("CorpseHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "CorpseHighlight"
        highlight.FillColor = corpseHighlightColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = model
        highlight.Parent = model
    end
end

local function createBillboard(model)
    if isIgnoredCorpse(model) then return end
    local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end
    removeESP(model)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CorpseESP"
    billboard.Adornee = primary
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local nameLabel
    if showNames then
        nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "CorpseName"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextSize = fontSize + 1
        nameLabel.TextColor3 = corpseNameColor
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Font = fontType
        nameLabel.Text = model.Name .. "'s Corpse"
        nameLabel.Parent = billboard
    end

    local distanceLabel
    if showDistance then
        distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "CorpseDistance"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 16)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextSize = fontSize
        distanceLabel.TextColor3 = corpseDistanceColor
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.Font = fontType
        distanceLabel.Text = "..."
        distanceLabel.Parent = billboard
    end
end

-- Оновлення ESP для всіх трупів
local function updateCorpseESP()
    for _, corpse in pairs(corpsesFolder:GetChildren()) do
        if corpse:IsA("Model") and not isIgnoredCorpse(corpse) then
            if corpseESPEnabled then
                createHighlight(corpse)
                if showNames or showDistance then
                    createBillboard(corpse)
                else
                    removeESP(corpse)
                end
            else
                removeESP(corpse)
            end
        else
            removeESP(corpse)
        end
    end
end

-- Автоматичне застосування ESP до нових трупів
corpsesFolder.ChildAdded:Connect(function(child)
    if corpseESPEnabled and child:IsA("Model") and not isIgnoredCorpse(child) then
        createHighlight(child)
        if showNames or showDistance then
            createBillboard(child)
        end
    end
end)

-- Централізований RenderStepped для трупів
RunService.RenderStepped:Connect(function()
    if not corpseESPEnabled then return end
    local camPos = Camera.CFrame.Position
    for _, corpse in pairs(corpsesFolder:GetChildren()) do
        if corpse:IsA("Model") and not isIgnoredCorpse(corpse) then
            local primary = corpse.PrimaryPart or corpse:FindFirstChildWhichIsA("BasePart")
            if primary then
                local distance = (camPos - primary.Position).Magnitude
                local inRange = distance <= maxDistance
                local transparency = 0
                local fadeStart = maxDistance * 0.9
                if distance >= maxDistance then
                    transparency = 1
                elseif distance >= fadeStart then
                    transparency = (distance - fadeStart) / (maxDistance * 0.1)
                end

                local espGui = corpse:FindFirstChild("CorpseESP")
                if espGui then
                    local nameLabel = espGui:FindFirstChild("CorpseName")
                    local distanceLabel = espGui:FindFirstChild("CorpseDistance")
                    if nameLabel then
                        nameLabel.Visible = showNames and inRange
                        nameLabel.TextTransparency = transparency
                        nameLabel.TextStrokeTransparency = 0.5 + transparency / 2
                    end
                    if distanceLabel then
                        distanceLabel.Visible = showDistance and inRange
                        distanceLabel.TextTransparency = transparency
                        distanceLabel.TextStrokeTransparency = 0.5 + transparency / 2
                        if inRange then
                            distanceLabel.Text = "[" .. tostring(math.floor(distance)) .. "м]"
                        end
                    end
                end

                local hl = corpse:FindFirstChild("CorpseHighlight")
                if hl then
                    hl.FillTransparency = 0.5 + transparency / 2
                    hl.OutlineTransparency = transparency
                end
            end
        end
    end
end)

-- GUI інтеграція
local Toggle = VisualsSection:Toggle({
    Name = "Enable", 
    Default = false,
    flag = "corpse_esp", 
    Risky = false,
    Tooltip = "Enable Corpse ESP",
    callback = function(state)
        corpseESPEnabled = state
        updateCorpseESP()
    end
})

local Toggle = VisualsSection:Toggle({
    Name = "Name",  
    Default = false,
    flag = "namec",  
    Risky = false,
    callback = function(state)
        showNames = state
        updateCorpseESP()
    end
})
Toggle:Colorpicker({
    Name = "Colorpicker",
    flag = "namecolor",  
    color = corpseNameColor,
    callback = function(color)
        corpseNameColor = color
        for _, corpse in pairs(corpsesFolder:GetChildren()) do
            local espGui = corpse:FindFirstChild("CorpseESP")
            if espGui then
                local label = espGui:FindFirstChild("CorpseName")
                if label then label.TextColor3 = color end
            end
        end
    end
})

local Toggle = VisualsSection:Toggle({
    Name = "Distance",  
    Default = false,
    flag = "distancec",
    Risky = false,
    callback = function(state)
        showDistance = state
        updateCorpseESP()
    end
})
Toggle:Colorpicker({
    name = "Colorpicker",
    flag = "colordistance",  
    color = corpseDistanceColor,
    callback = function(color)
        corpseDistanceColor = color
        for _, corpse in pairs(corpsesFolder:GetChildren()) do
            local espGui = corpse:FindFirstChild("CorpseESP")
            if espGui then
                local label = espGui:FindFirstChild("CorpseDistance")
                if label then label.TextColor3 = color end
            end
        end
    end
})

local Slider = VisualsSection:Slider({
    name = "Distance Check", 
    flag = "distancecheck",  
    min = 1000, 
    max = 10000, 
    value = maxDistance, 
    decimals = 1, 
    callback = function(val)
        maxDistance = val
    end
})

local VisualsSection = VisualsTab:Section({Name = "Vehicle Esp", Side = 1 })
local vehiclesFolder = workspace:WaitForChild("Vehicles")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local vehicleESPEnabled = false
local showNames = false
local showDistance = false
local maxDistance = 10000

local vehicleNameColor = Color3.fromRGB(0, 91, 255)
local vehicleDistanceColor = Color3.fromRGB(255, 255, 255)

local fontSize = 12
local fontType = Enum.Font.Code

local espVehicles = {} -- Локальна таблиця для Vehicle ESP

-- Видалення ESP для конкретної машини
local function removeESP(model)
    local espGui = model:FindFirstChild("VehicleESP_GUI")
    if espGui then espGui:Destroy() end
    espVehicles[model] = nil
end

-- Створення Billboard ESP для машини
local function createBillboard(model)
    local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end
    removeESP(model)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VehicleESP_GUI"
    billboard.Adornee = primary
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local nameLabel
    if showNames then
        nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "VehicleNameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextSize = fontSize
        nameLabel.TextColor3 = vehicleNameColor
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Font = fontType
        nameLabel.Text = model.Name
        nameLabel.Parent = billboard
    end

    local distanceLabel
    if showDistance then
        distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "VehicleDistanceLabel"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 16)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextSize = fontSize
        distanceLabel.TextColor3 = vehicleDistanceColor
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.Font = fontType
        distanceLabel.Text = "[...]"
        distanceLabel.Parent = billboard
    end

    espVehicles[model] = {
        model = model,
        primary = primary,
        billboard = billboard,
        nameLabel = nameLabel,
        distanceLabel = distanceLabel
    }
end

-- Оновлення Vehicle ESP
local function updateVehicleESP()
    for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
        if vehicle:IsA("Model") then
            if vehicleESPEnabled and (showNames or showDistance) then
                createBillboard(vehicle)
            else
                removeESP(vehicle)
            end
        end
    end
end

-- Автоматичне застосування ESP до нових машин
vehiclesFolder.ChildAdded:Connect(function(child)
    if vehicleESPEnabled and child:IsA("Model") then
        if showNames or showDistance then
            createBillboard(child)
        end
    end
end)

-- Централізований RenderStepped для всіх машин
RunService.RenderStepped:Connect(function()
    if not vehicleESPEnabled then return end
    local camPos = Camera.CFrame.Position
    for _, data in pairs(espVehicles) do
        local model = data.model
        local primary = data.primary
        if model and model.Parent and primary and primary.Parent then
            local distance = (camPos - primary.Position).Magnitude
            local inRange = distance <= maxDistance
            local transparency = 0
            local fadeStart = maxDistance * 0.9
            if distance >= maxDistance then
                transparency = 1
            elseif distance >= fadeStart then
                transparency = (distance - fadeStart) / (maxDistance * 0.1)
            end

            if data.nameLabel then
                data.nameLabel.Visible = showNames and inRange
                data.nameLabel.TextTransparency = transparency
                data.nameLabel.TextStrokeTransparency = 0.5 + transparency / 2
            end
            if data.distanceLabel then
                data.distanceLabel.Visible = showDistance and inRange
                data.distanceLabel.TextTransparency = transparency
                data.distanceLabel.TextStrokeTransparency = 0.5 + transparency / 2
                if inRange then
                    data.distanceLabel.Text = "[" .. tostring(math.floor(distance)) .. "м]"
                end
            end
        else
            removeESP(model)
        end
    end
end)

-- GUI інтеграція
local Toggle = VisualsSection:Toggle({
    name = "Enable Vehicle ESP",
    Default = false,
    flag = "EnableVehicleESP",
    Risky = false,
    callback = function(state)
        vehicleESPEnabled = state
        updateVehicleESP()
    end
})

local Toggle = VisualsSection:Toggle({
    name = "Names",
    Default = false,
    flag = "VehicleShowNames",
    Risky = false,
    callback = function(state)
        showNames = state
        updateVehicleESP()
    end
})
Toggle:Colorpicker({
    name = "Colorpicker",
    flag = "VehicleNameColor",
    color = vehicleNameColor,
    callback = function(color)
        vehicleNameColor = color
        for _, data in pairs(espVehicles) do
            if data.nameLabel then data.nameLabel.TextColor3 = color end
        end
    end
})

local Toggle = VisualsSection:Toggle({
    name = "Distance",
    Default = false,
    flag = "VehicleShowDistance",
    Risky = false,
    callback = function(state)
        showDistance = state
        updateVehicleESP()
    end
})
Toggle:Colorpicker({
    name = "Colorpicker",
    flag = "VehicleDistanceColor",
    color = vehicleDistanceColor,
    callback = function(color)
        vehicleDistanceColor = color
        for _, data in pairs(espVehicles) do
            if data.distanceLabel then data.distanceLabel.TextColor3 = color end
        end
    end
})

local Slider = VisualsSection:Slider({
    name = "Distance Check",
    flag = "VehicleDistanceCheck",
    min = 1000,
    max = 10000,
    value = maxDistance,
    decimals = 1,
    callback = function(val)
        maxDistance = val
    end
})

local VisualsSection = VisualsTab:Section({Name = "Zombie Esp", Side = 1 })
local zombiesFolder = workspace:WaitForChild("Zombies")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local zombieESPEnabled = false
local showNames = false
local showDistance = false
local maxDistance = 10000

local zombieNameColor = Color3.fromRGB(0, 255, 0)
local zombieDistanceColor = Color3.fromRGB(255, 255, 255)

local fontSize = 12
local fontType = Enum.Font.Code

local espZombies = {} -- Локальна таблиця для Zombie ESP

-- Видалення ESP для конкретного зомбі
local function removeESP(model)
    local espGui = model:FindFirstChild("ZombieESP_GUI")
    if espGui then espGui:Destroy() end
    espZombies[model] = nil
end

-- Створення Billboard ESP для зомбі
local function createBillboard(model)
    local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end
    removeESP(model)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ZombieESP_GUI"
    billboard.Adornee = primary
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local nameLabel
    if showNames then
        nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "ZombieNameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextSize = fontSize
        nameLabel.TextColor3 = zombieNameColor
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Font = fontType
        nameLabel.Text = model.Name
        nameLabel.Parent = billboard
    end

    local distanceLabel
    if showDistance then
        distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "ZombieDistanceLabel"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 16)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextSize = fontSize
        distanceLabel.TextColor3 = zombieDistanceColor
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.Font = fontType
        distanceLabel.Text = "[...]"
        distanceLabel.Parent = billboard
    end

    espZombies[model] = {
        model = model,
        primary = primary,
        billboard = billboard,
        nameLabel = nameLabel,
        distanceLabel = distanceLabel
    }
end

-- Оновлення Zombie ESP
local function updateZombieESP()
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") then
            if zombieESPEnabled and (showNames or showDistance) then
                createBillboard(zombie)
            else
                removeESP(zombie)
            end
        end
    end
end

-- Автоматичне застосування ESP до нових зомбі
zombiesFolder.ChildAdded:Connect(function(child)
    if zombieESPEnabled and child:IsA("Model") then
        if showNames or showDistance then
            createBillboard(child)
        end
    end
end)

-- Централізований RenderStepped для всіх зомбі
RunService.RenderStepped:Connect(function()
    if not zombieESPEnabled then return end
    local camPos = Camera.CFrame.Position
    for _, data in pairs(espZombies) do
        local model = data.model
        local primary = data.primary
        if model and model.Parent and primary and primary.Parent then
            local distance = (camPos - primary.Position).Magnitude
            local inRange = distance <= maxDistance
            local transparency = 0
            local fadeStart = maxDistance * 0.9
            if distance >= maxDistance then
                transparency = 1
            elseif distance >= fadeStart then
                transparency = (distance - fadeStart) / (maxDistance * 0.1)
            end

            if data.nameLabel then
                data.nameLabel.Visible = showNames and inRange
                data.nameLabel.TextTransparency = transparency
                data.nameLabel.TextStrokeTransparency = 0.5 + transparency / 2
            end
            if data.distanceLabel then
                data.distanceLabel.Visible = showDistance and inRange
                data.distanceLabel.TextTransparency = transparency
                data.distanceLabel.TextStrokeTransparency = 0.5 + transparency / 2
                if inRange then
                    data.distanceLabel.Text = "[" .. tostring(math.floor(distance)) .. "м]"
                end
            end
        else
            removeESP(model)
        end
    end
end)

-- GUI інтеграція
local Toggle = VisualsSection:Toggle({
    name = "Enable",
    Default = false,
    flag = "EnableZombieESP",
    Risky = false,
    callback = function(state)
        zombieESPEnabled = state
        updateZombieESP()
    end
})

local Toggle = VisualsSection:Toggle({
    name = "Names",
    Default = false,
    flag = "ZombieShowNames",
    Risky = false,
    callback = function(state)
        showNames = state
        updateZombieESP()
    end
})
Toggle:Colorpicker({
    name = "Colorpicker",
    flag = "ZombieNameColor",
    color = zombieNameColor,
    callback = function(color)
        zombieNameColor = color
        for _, data in pairs(espZombies) do
            if data.nameLabel then data.nameLabel.TextColor3 = color end
        end
    end
})

local Toggle = VisualsSection:Toggle({
    name = "Distance",
    Default = false,
    flag = "ZombieShowDistance",
    Risky = false,
    callback = function(state)
        showDistance = state
        updateZombieESP()
    end
})
Toggle:Colorpicker({
    name = "Colorpicker",
    flag = "ZombieDistanceColor",
    color = zombieDistanceColor,
    callback = function(color)
        zombieDistanceColor = color
        for _, data in pairs(espZombies) do
            if data.distanceLabel then data.distanceLabel.TextColor3 = color end
        end
    end
})

local Slider = VisualsSection:Slider({
    name = "Distance Check",
    flag = "ZombieDistanceCheck",
    min = 1000,
    max = 10000,
    value = maxDistance,
    decimals = 1,
    callback = function(val)
        maxDistance = val
    end
})

local VisualsSection = VisualsTab:Section({Name = "Lighting", Side = 2 })
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local noFogConnection

local Toggle = VisualsSection:Toggle({
    name = "No Fog",
    Default = false,
    flag = "NoFog",
    state = false,
    callback = function(state)
        if state then
            if noFogConnection then
                noFogConnection:Disconnect()
                noFogConnection = nil
            end

            noFogConnection = RunService.RenderStepped:Connect(function()
                Lighting.FogStart = 1e6
                Lighting.FogEnd = 1e6

                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then
                    atmosphere.Density = 0
                    atmosphere.Haze = 0
                    atmosphere.Glare = 0
                    atmosphere.Offset = 0
                end
            end)
        else
            if noFogConnection then
                noFogConnection:Disconnect()
                noFogConnection = nil
            end
            Lighting.FogStart = 0
            Lighting.FogEnd = 1000
        end
    end
})

local Lighting = game:GetService("Lighting")

local Toggle = VisualsSection:Toggle({
    name = "No Shadows",
    Default = false,
    flag = "NoShadows",
    Risky = false,
    callback = function(state)
        Lighting.GlobalShadows = not state
    end
})

local Lighting = game:GetService("Lighting")

local AmbientEnabled = false
local AmbientColor = Color3.fromRGB(198, 92, 92)

local function UpdateAmbient()
    if AmbientEnabled then
        RunService:BindToRenderStep("CustomAmbient", 1, function()
            Lighting.Ambient = AmbientColor
        end)
    else
        RunService:UnbindFromRenderStep("CustomAmbient")
        Lighting.Ambient = Color3.new(1,1,1)
    end
end

local Toggle = VisualsSection:Toggle({
    name = "Custom World Ambient",
    Default = false,
    flag = "ambient",
    callback = function(state)
        AmbientEnabled = state
        UpdateAmbient()
    end
})
Toggle:Colorpicker({
    name = "Ambient Color",

    flag = "ambient color",
    color = AmbientColor,
    callback = function(color)
        AmbientColor = color
        if AmbientEnabled then
            Lighting.Ambient = AmbientColor
        end
    end
})

local Lighting = game:GetService("Lighting")

local TechnologyEnabled = false
local SelectedTechnology = "Voxel"

local Toggle = VisualsSection:Toggle({
    name = "Custom Technology",
    Default = false,
    flag = "Visuals/TechnologyEnabled",
    state = false,
    callback = function(state)
        TechnologyEnabled = state
        if state then
            pcall(function()
                Lighting.Technology = Enum.Technology[SelectedTechnology]
            end)
        else
            pcall(function()
                Lighting.Technology = Enum.Technology.Future
            end)
        end
    end
})

local MultiDropdown = VisualsSection:Dropdown({
    name = "Technology Mode",
    flag = "Visuals/Technology",
    Default = "Voxel",
    items = {"Voxel", "ShadowMap", "Legacy", "Compatibility", "Future"},
    callback = function(val)
        SelectedTechnology = val
        if TechnologyEnabled then
            pcall(function()
                Lighting.Technology = Enum.Technology[val]
            end)
        end
    end
})

local Lighting = game:GetService("Lighting")


local timeConnection
local customTime = 12

local Toggle = VisualsSection:Toggle({
    name = "Custom Time",
    Default = false,
    flag = "CustomTime",
    state = false,
    callback = function(state)
        if state then
            if timeConnection then
                timeConnection:Disconnect()
                timeConnection = nil
            end
            timeConnection = Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
                Lighting.ClockTime = customTime
            end)
        else
            if timeConnection then
                timeConnection:Disconnect()
                timeConnection = nil
            end
        end
    end
})

local Slider = VisualsSection:Slider({
    name = "Custom Time",
    flag = "CustomTimeValue",
    value = 12,
    min = 0,
    max = 24,
    decimals = 1,
    callback = function(val)
        customTime = val
    end
})

local Lighting = game:GetService("Lighting")

local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not cc then
    cc = Instance.new("ColorCorrectionEffect")
    cc.Parent = Lighting
end

local customSaturation = 1
local satEnabled = false

local Toggle = VisualsSection:Toggle({
    name = "Custom Saturation",
    Default = false,
    flag = "CustomSaturation",
    state = false,
    callback = function(state)
        satEnabled = state
        if satEnabled then
            cc.Saturation = customSaturation
            cc.Enabled = true
        else
            cc.Enabled = false
        end
    end
})

local Slider = VisualsSection:Slider({
    name = "Saturation",
    flag = "SaturationValue",
    value = 1,
    min = 0,
    max = 3,
    decimals = 0.1,
    callback = function(val)
        customSaturation = val
        if satEnabled then
            cc.Saturation = customSaturation
        end
    end
})

local VisualsSection = VisualsTab:Section({Name = "Clouds Modifications", Side = 2 })
local clouds = workspace:FindFirstChildOfClass("Clouds") or workspace.Terrain:FindFirstChildOfClass("Clouds")
flags = flags or {}

local cloudColor = clouds and clouds.Color or Color3.fromRGB(255, 255, 255)
local cloudCover = clouds and clouds.Cover or 0.5
local cloudDensity = clouds and clouds.Density or 0.5
local cloudsEnabled = clouds and clouds.Enabled or true
flags.ModifyClouds = false 

local Toggle = VisualsSection:Toggle({
    name = "Enable Clouds",
    Default = false,
    flag = "EnableClouds",
    state = cloudsEnabled,
    callback = function(state)
        cloudsEnabled = state
    end
})
Toggle:Colorpicker({ 
    Name = "Colorpicker",
    flag = "CloudsColor",
    color = cloudColor,
    callback = function(col)
        cloudColor = col
    end
})


local Toggle = VisualsSection:Toggle({
    name = "Modify Clouds",
    Default = false,
    flag = "ModifyClouds",
    state = false,
    callback = function(state)
        flags.ModifyClouds = state
    end
})


local Slider = VisualsSection:Slider({
    name = "Clouds Cover",
    flag = "CloudsCover",
    min = 0,
    max = 1,
    float = 0.1,
    value = cloudCover,
    callback = function(val)
        cloudCover = val
    end
})

local Slider = VisualsSection:Slider({
    name = "CloudsDensity",
    flag = "CloudsDensity",
    min = 0,
    max = 1,
    float = 0.1,
    value = cloudDensity,
    callback = function(val)
        cloudDensity = val
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if clouds and flags.ModifyClouds then
        clouds.Enabled = cloudsEnabled
        clouds.Color = cloudColor
        clouds.Cover = cloudCover
        clouds.Density = cloudDensity
    end
end)

local VisualsSection = VisualsTab:Section({Name = "Custom Sky Box", Side = 2 })
local Lighting = game:GetService("Lighting")
flags = flags or {}

local function ClearSkybox()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
end

local function SetSkybox(name)
    ClearSkybox()

    local sky = Instance.new("Sky")
    sky.Name = name

    if name == "Galaxy" then
        sky.SkyboxBk = "http://www.roblox.com/asset/?id=149397692"
        sky.SkyboxDn = "http://www.roblox.com/asset/?id=149397686"
        sky.SkyboxFt = "http://www.roblox.com/asset/?id=149397697"
        sky.SkyboxLf = "http://www.roblox.com/asset/?id=149397684"
        sky.SkyboxRt = "http://www.roblox.com/asset/?id=149397688"
        sky.SkyboxUp = "http://www.roblox.com/asset/?id=149397702"
    elseif name == "Galaxy 2" then
        sky.SkyboxBk = "http://www.roblox.com/asset/?id=155441936"
        sky.SkyboxDn = "http://www.roblox.com/asset/?id=155441802"
        sky.SkyboxFt = "http://www.roblox.com/asset/?id=155441818"
        sky.SkyboxLf = "http://www.roblox.com/asset/?id=155441777"
        sky.SkyboxRt = "http://www.roblox.com/asset/?id=155441874"
        sky.SkyboxUp = "http://www.roblox.com/asset/?id=155441905"
    elseif name == "Galaxy 3" then
        sky.SkyboxBk = "rbxassetid://135908594667929"
        sky.SkyboxDn = "rbxassetid://139584143501514"
        sky.SkyboxFt = "rbxassetid://92947876187368"
        sky.SkyboxLf = "rbxassetid://72493016739936"
        sky.SkyboxRt = "rbxassetid://81731245279712"
        sky.SkyboxUp = "rbxassetid://88174897344210"
    elseif name == "Saturne" then
        sky.SkyboxBk = "rbxassetid://1898724755"
        sky.SkyboxDn = "rbxassetid://1898727189"
        sky.SkyboxFt = "rbxassetid://1898722814"
        sky.SkyboxLf = "rbxassetid://1898729298"
        sky.SkyboxRt = "rbxassetid://1898741025"
        sky.SkyboxUp = "rbxassetid://1898736761"
    elseif name == "Neptune" then
        sky.SkyboxBk = "rbxassetid://218955819"
        sky.SkyboxDn = "rbxassetid://218953419"
        sky.SkyboxFt = "rbxassetid://218954524"
        sky.SkyboxLf = "rbxassetid://218958493"
        sky.SkyboxRt = "rbxassetid://218957134"
        sky.SkyboxUp = "rbxassetid://218950090"
    elseif name == "Redshift" then
        sky.SkyboxBk = "rbxassetid://401664839"
        sky.SkyboxDn = "rbxassetid://401664862"
        sky.SkyboxFt = "rbxassetid://401664960"
        sky.SkyboxLf = "rbxassetid://401664881"
        sky.SkyboxRt = "rbxassetid://401664901"
        sky.SkyboxUp = "rbxassetid://401664936"
    elseif name == "Pink Daylights" then
        sky.SkyboxBk = "rbxassetid://11555017034"
        sky.SkyboxDn = "rbxassetid://11555013415"
        sky.SkyboxFt = "rbxassetid://11555010145"
        sky.SkyboxLf = "rbxassetid://11555006545"
        sky.SkyboxRt = "rbxassetid://11555000712"
        sky.SkyboxUp = "rbxassetid://11554996247"
    elseif name == "Purple Night" then
        sky.SkyboxBk = "rbxassetid://17279854976"
        sky.SkyboxDn = "rbxassetid://17279856318"
        sky.SkyboxFt = "rbxassetid://17279858447"
        sky.SkyboxLf = "rbxassetid://17279860360"
        sky.SkyboxRt = "rbxassetid://17279862234"
        sky.SkyboxUp = "rbxassetid://17279864507"
    elseif name == "Gray Night" then
        sky.SkyboxBk = "rbxassetid://1618912481"
        sky.SkyboxDn = "rbxassetid://1618913943"
        sky.SkyboxFt = "rbxassetid://1618913244"
        sky.SkyboxLf = "rbxassetid://1618912849"
        sky.SkyboxRt = "rbxassetid://1618911568"
        sky.SkyboxUp = "rbxassetid://1618913654"
    elseif name == "Anime Sky" then
        sky.SkyboxBk = "rbxassetid://18351376859"
        sky.SkyboxDn = "rbxassetid://18351374919"
        sky.SkyboxFt = "rbxassetid://18351376800"
        sky.SkyboxLf = "rbxassetid://18351376469"
        sky.SkyboxRt = "rbxassetid://18351376457"
        sky.SkyboxUp = "rbxassetid://18351377189"
    else
        warn("" .. tostring(name))
        return
    end

    sky.Parent = Lighting
end

flags.CustomSkyEnabled = false
flags.SelectedSky = "Galaxy"

local Toggle = VisualsSection:Toggle({
    name = "Custom Sky",
    Default = false,
    flag = "CustomSky",
    state = false,
    callback = function(state)
        flags.CustomSkyEnabled = state
        if flags.CustomSkyEnabled then
            SetSkybox(flags.SelectedSky)
        else
            ClearSkybox()
        end
    end
})

local MultiDropdown = VisualsSection:Dropdown({
    name = "Skybox Selector",
    flag = "SkyboxChoice",
    value = "Galaxy",
    items = {
        "Galaxy", "Galaxy 2", "Galaxy 3", "Saturne", "Neptune",
        "Redshift", "Pink Daylights", "Purple Night", "Gray Night", "Anime Sky"
    },
    callback = function(selected)
        flags.SelectedSky = selected
        if flags.CustomSkyEnabled then
            SetSkybox(flags.SelectedSky)
        end
    end
})

local VisualsSection = VisualsTab:Section({Name = "Gun Chams", Side = 2 })
local gunChamsEnabled = false
local chamColor = Color3.fromRGB(250, 250, 250)
local chamMaterial = Enum.Material.Plastic

local originalProperties = {} -- тут зберігатимемо оригінальні кольори та матеріали

local function ApplyGunChams(tool)
    if not tool then return end
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            -- зберігаємо оригінальні властивості
            if not originalProperties[obj] then
                originalProperties[obj] = {Color = obj.Color, Material = obj.Material}
            end
            obj.Material = chamMaterial
            obj.Color = chamColor
        end
    end
end

local function RemoveGunChams(tool)
    if not tool then return end
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            if originalProperties[obj] then
                obj.Color = originalProperties[obj].Color
                obj.Material = originalProperties[obj].Material
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character then
        local equipped = LocalPlayer.Character:FindFirstChild("Equipped")
        if equipped then
            if gunChamsEnabled then
                ApplyGunChams(equipped)
            else
                RemoveGunChams(equipped)
            end
        end
    end
end)

-- GUI
local Toggle = VisualsSection:Toggle({
    name = "Equiped Item Chams",
    Default = false,
    flag = "Visuals/GunChams",
    state = false,
    callback = function(state)
        gunChamsEnabled = state
    end
})
Toggle:Colorpicker({ 
    Name = "Colorpicker",
    Default = Color3.fromRGB(250, 250, 250),
    Flag = "Visuals/GunChamsColor",
    callback = function(color)
        chamColor = color
    end
})

local MultiDropdown = VisualsSection:Dropdown({
    name = "Material",
    flag = "Visuals/GunChamsMaterial",
    items = {"ForceField", "Plastic", "SmoothPlastic", "Glass", "Neon"},
    Default = "Plastic",
    callback = function(val)
        if val == "Default" then
            chamMaterial = Enum.Material.Plastic
        elseif val == "ForceField" then
            chamMaterial = Enum.Material.ForceField
        elseif val == "Plastic" then
            chamMaterial = Enum.Material.Plastic
        elseif val == "SmoothPlastic" then
            chamMaterial = Enum.Material.SmoothPlastic
        elseif val == "Glass" then
            chamMaterial = Enum.Material.Glass
        elseif val == "Neon" then
            chamMaterial = Enum.Material.Neon
        end
    end
})

local CreditsSection = SettingsTab:Section({  Name = "Credits", Side = 1 })

local Listbox = CreditsSection:Listbox({
    Name = "Credits",
    Flag = "List",
    Items = { "Device21 - Functions", "Device21 - Menu Customization", "Lajza - Functions", "Roo1 - Functions"},
    Multi = false,
})

local ThemesSection = SettingsTab:Section({ Name = "Settings", Side = 1 })

do
    for Index, Value in Library.Theme do 
        Library.ThemeColorpickers[Index] = ThemesSection:Label(Index, "Left"):Colorpicker({
            Name = Index,
            Flag = "Theme" .. Index,
            Default = Value,
            Callback = function(Value)
                Library.Theme[Index] = Value
                Library:ChangeTheme(Index, Value)
            end
        })
    end

    ThemesSection:Dropdown({Name = "Themes list", Items = {"Default", "Bitchbot", "Onetap", "Aqua"}, Default = "Default", Callback = function(Value)
        local ThemeData = Library.Themes[Value]

        if not ThemeData then 
            return
        end

        for Index, Value in Library.Theme do 
            Library.Theme[Index] = ThemeData[Index]
            Library:ChangeTheme(Index, ThemeData[Index])

            Library.ThemeColorpickers[Index]:Set(ThemeData[Index])
        end

        task.wait(0.3)

        Library:Thread(function() -- i do this because sometimes the themes dont update
            for Index, Value in Library.Theme do 
                Library.Theme[Index] = Library.Flags["Theme"..Index].Color
                Library:ChangeTheme(Index, Library.Flags["Theme"..Index].Color)
            end    
        end)
    end})

    local ThemeName
    local SelectedTheme 

    local ThemesListbox = ThemesSection:Listbox({
        Name = "Themes List",
        Flag = "Themes List",
        Items = { },
        Multi = false,
        Default = nil,
        Callback = function(Value)
            SelectedTheme = Value
        end
    })

    ThemesSection:Textbox({
        Name = "Name",
        Flag = "Theme Name",
        Default = "",
        Placeholder = ". . .",
        Callback = function(Value)
            ThemeName = Value
        end
    })

    ThemesSection:Button({
        Name = "Save Theme",
        Callback = function()
            if ThemeName == "" then 
                return
            end

            if not isfile(Library.Folders.Themes .. "/" .. ThemeName .. ".json") then
                writefile(Library.Folders.Themes .. "/" .. ThemeName .. ".json", Library:GetTheme())

                Library:RefreshThemeList(ThemesListbox)
            else
                Library:Notification("Theme '" .. ThemeName .. ".json' already exists", 3, Color3.fromRGB(255, 0, 0))
                return
            end
        end
    }):SubButton({
        Name = "Load Theme",
        Callback = function()
            if SelectedTheme then
                Library:LoadTheme(readfile(Library.Folders.Themes .. "/" .. SelectedTheme))
            end
        end
    })

    ThemesSection:Button({
        Name = "Refresh Themes",
        Callback = function()
            Library:RefreshThemeList(ThemesListbox)
        end
    })

    Library:RefreshThemeList(ThemesListbox)
end

local ConfigsSection = SettingsTab:Section({  Name = "Configs", Side = 2 })

do 
    local ConfigName 
    local SelectedConfig 

    local ConfigsListbox = ConfigsSection:Listbox({
        Name = "Configs list",
        Flag = "Configs List",
        Items = { },
        Multi = false,
        Default = nil,
        Callback = function(Value)
            SelectedConfig = Value
        end
    })

    ConfigsSection:Textbox({
        Name = "Name",
        Flag = "Config Name",
        Default = "",
        Placeholder = ". . .",
        Callback = function(Value)
            ConfigName = Value
        end
    })

    ConfigsSection:Button({
        Name = "Load Config",
        Callback = function()
            if SelectedConfig then
                Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. SelectedConfig))
            end

            Library:Thread(function()
                task.wait(0.1)

                for Index, Value in Library.Theme do 
                    Library.Theme[Index] = Library.Flags["Theme"..Index].Color
                    Library:ChangeTheme(Index, Library.Flags["Theme"..Index].Color)
                end    
            end)
        end
    }):SubButton({
        Name = "Save Config",
        Callback = function()
            if SelectedConfig then
                Library:SaveConfig(SelectedConfig)
            end
        end
    })

    ConfigsSection:Button({
        Name = "Create Config",
        Callback = function()
            if ConfigName == "" then 
                return
            end

            if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
                writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())

                Library:RefreshConfigsList(ConfigsListbox)
            else
                Library:Notification("Config '" .. ConfigName .. ".json' already exists", 3, Color3.fromRGB(255, 0, 0))
                return
            end
        end
    }):SubButton({
        Name = "Delete Config",
        Callback = function()
            if SelectedConfig then
                Library:DeleteConfig(SelectedConfig)

                Library:RefreshConfigsList(ConfigsListbox)
            end
        end
    })

    ConfigsSection:Button({
        Name = "Refresh Configs",
        Callback = function()
            Library:RefreshConfigsList(ConfigsListbox)
        end
    })

    Library:RefreshConfigsList(ConfigsListbox)

    ConfigsSection:Label("Menu Keybind", "Left"):Keybind({Name = "Menu Keybind", Flag = "Menu Keybind", Default = Enum.KeyCode.RightControl, Mode = "Toggle", Callback = function(Value)
        Library.MenuKeybind = Library.Flags["Menu Keybind"].Key
    end})

    ConfigsSection:Toggle({Name = "Watermark", Flag = "Watermark", Default = false, Callback = function(Value)
        Watermark:SetVisibility(Value)
    end})

    ConfigsSection:Toggle({Name = "Keybind List", Flag = "Keybind List", Default = false, Callback = function(Value)
        KeybindList:SetVisibility(Value)
    end})

    ConfigsSection:Dropdown({Name = "Style", Flag = "Tweening Style", Default = "Exponential", Items = {"Linear", "Sine", "Quad", "Cubic", "Quart", "Quint", "Exponential", "Circular", "Back", "Elastic", "Bounce"}, Callback = function(Value)
        Library.Tween.Style = Enum.EasingStyle[Value]
    end})

    ConfigsSection:Dropdown({Name = "Direction", Flag = "Tweening Direction", Default = "Out", Items = {"In", "Out", "InOut"}, Callback = function(Value)
        Library.Tween.Direction = Enum.EasingDirection[Value]
    end})

    ConfigsSection:Slider({Name = "Tweening Time", Min = 0, Max = 5, Default = 0.25, Decimals = 0.01, Flag = "Tweening Time", Callback = function(Value)
        Library.Tween.Time = Value
    end})

    ConfigsSection:Button({Name = "Notification test", Callback = function()
        Library:Notification("This is a notification This is a notification This is a notification This is a notification", 5, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
    end})

    ConfigsSection:Button({Name = "Unload library", Callback = function()
        Library:Unload()
    end})
    
end

