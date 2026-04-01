-- Services
local UserInputService = game:GetService("UserInputService");

-- UI
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

local Window = Modal:CreateWindow({
    Title = "LunarCore.xyz",
    SubTitle = "Universal Hub",
    Size = UDim2.fromOffset(620, 420),
    MinimumSize = Vector2.new(250, 200),
    Transparency = 0,
    Icon = "rbxassetid://",
})

local ScriptSettings = ({
    NotificationKey = Enum.KeyCode.LeftControl
})

-- SAFE LOAD (FIX NIL ERROR)
local function SafeLoad(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not response then
        Window:Notify({
            Title = "Error",
            Description = "Failed to fetch script",
            Duration = 5,
            Type = "Error"
        })
        return
    end

    local func, err = loadstring(response)

    if not func then
        Window:Notify({
            Title = "Loadstring Error",
            Description = tostring(err),
            Duration = 5,
            Type = "Error"
        })
        return
    end

    func()
end

-- TAB
local Main = Window:AddTab("Scripts")

Main:New("Title")({
    Title = "LunarCore Loader",
})

-- AR2 BUTTON
Main:New("Button")({
    Title = "Apocalypse Rising 2",
    Description = "Load AR2 Script",
    Callback = function()
        SafeLoad("https://raw.githubusercontent.com/DeviceHB21/er-grg-eg/refs/heads/main/brtnrnrtntrnrtn.lua")
    end,
})

-- PROJECT DELTA BUTTON
Main:New("Button")({
    Title = "Project Delta",
    Description = "Load PD Script",
    Callback = function()
        SafeLoad("https://raw.githubusercontent.com/DeviceHB21/er-grg-eg/refs/heads/main/pd.lua")
    end,
})

-- SETTINGS TAB
local Settings = Window:AddTab("Settings")

Settings:New("Title")({
    Title = "UI Settings"
})

Settings:New("Dropdown")({
    Title = "Theme",
    Options = { "Light", "Dark", "Midnight", "Rose", "Emerald" },
    Default = "Dark",
    Callback = function(Theme)
        Window:SetTheme(Theme)
    end,
})

Settings:New("Button")({
    Title = "Destroy GUI",
    Description = "Close UI",
    Callback = function()
        Window:Destroy();
    end,
})

-- DEFAULT
Window:SetTab("Scripts")
Window:SetTheme("Dark")

-- KEYBIND NOTIFY
UserInputService.InputBegan:Connect(function(Input)
    if (Modal:IsCorrectInput(Input, ScriptSettings.NotificationKey)) then
        Window:Notify({
            Title = "LunarCore.xyz",
            Description = "Loader Ready",
            Duration = 5,
            Type = "Success"
        })
    end
end)

-- START NOTIFY
Window:Notify({
    Title = "LunarCore.xyz",
    Description = "Loaded successfully",
    Duration = 6,
    Type = "Success"
})
