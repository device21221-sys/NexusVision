local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "NexusVisionHub",
    SubTitle = "by NexusVision Team",
    TabWidth = 200,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Our scripts", Icon = "settings" }),
    Other = Window:AddTab({ Title = "Other scripts", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "Thanks For Use Script",
        SubContent = "", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })

    Tabs.Main:AddButton({
        Title = "Apocalypse Rising 2",
        Description = "by NexusVision team",
        Callback = function()
            Window:Dialog({
                Title = "Load Script?",
                Content = "Confirm/Cancel",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/DeviceHB21/er-grg-eg/refs/heads/main/brtnrnrtntrnrtn.lua"))()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()

                        end
                    }
                }
            })
        end
    })
        Tabs.Main:AddButton({
        Title = "Arsenal",
        Description = "by NexusVision team",
        Callback = function()
            Window:Dialog({
                Title = "Load Script?",
                Content = "Confirm/Cancel",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/DeviceHB21/er-grg-eg/refs/heads/main/nxvsarsenal"))()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()

                        end
                    }
                }
            })
        end
    })
        Tabs.Main:AddButton({
        Title = "Counter Blox",
        Description = "by NexusVision team",
        Callback = function()
            Window:Dialog({
                Title = "Load Script?",
                Content = "Confirm/Cancel",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/DeviceHB21/er-grg-eg/refs/heads/main/ctblox.lua"))()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()

                        end
                    }
                }
            })
        end
    })
end

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "NexusVisionHub",
    Content = "The script has been loaded.",
    Duration = 8
})
