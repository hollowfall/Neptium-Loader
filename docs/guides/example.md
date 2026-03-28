# 📋 Full Example

A complete script showcasing every feature of Aura X.

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8qz/Aura-X/main/Source.lua"))()

-- Watermark with auto FPS/Ping
local gameName = "Game"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

Library:CreateWatermark({
    Text = "Aura X",
    GameName = gameName,
    AutoUpdate = true
})

-- Set toggle key
Library:SetToggleKey(Enum.KeyCode.RightControl)

-- Welcome notification
Library:Notify({ Title = "Aura X", Content = "Loaded!", Duration = 3 })

-- Create window
local Window = Library:CreateWindow({ Title = "Aura X" })

------------------------------------------------------------
-- COMBAT TAB
------------------------------------------------------------
local Combat = Window:CreateTab("Combat")

local AimSect = Combat:CreateSection({ Name = "Aim Assist", Side = "Left" })

AimSect:CreateToggle({
    Name = "Enabled",
    Default = false,
    Flag = "AimEnabled",
    Callback = function(v)
        Library:Notify({ Title = "Aim", Content = v and "ON" or "OFF", Duration = 2 })
    end
})

AimSect:CreateSlider({
    Name = "FOV",
    Min = 0, Max = 360, Default = 180,
    Suffix = "°", Flag = "AimFOV"
})

AimSect:CreateSlider({
    Name = "Smoothing",
    Min = 1, Max = 100, Default = 5,
    Suffix = "%", Flag = "Smooth"
})

AimSect:CreateDropdown({
    Name = "Hit Box",
    Options = {"Head", "Torso", "Random"},
    Default = "Head",
    Flag = "HitBox"
})

AimSect:CreateKeybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.E,
    Flag = "AimKey"
})

local MiscSect = Combat:CreateSection({ Name = "Misc", Side = "Right" })

MiscSect:CreateToggle({ Name = "Trigger Bot", Flag = "TriggerBot" })
MiscSect:CreateToggle({ Name = "No Recoil", Flag = "NoRecoil" })
MiscSect:CreateToggle({ Name = "No Spread", Flag = "NoSpread" })

MiscSect:CreateSlider({
    Name = "Fire Rate",
    Min = 1, Max = 20, Default = 10,
    Flag = "FireRate"
})

MiscSect:CreateButton({
    Name = "Kill All",
    Callback = function()
        Library:Notify({ Title = "Warning", Content = "Risky feature!", Duration = 3 })
    end
})

------------------------------------------------------------
-- VISUALS TAB
------------------------------------------------------------
local Visuals = Window:CreateTab("Visuals")

local ESPSect = Visuals:CreateSection({ Name = "ESP", Side = "Left" })

ESPSect:CreateToggle({ Name = "Box ESP", Flag = "BoxESP" })
ESPSect:CreateToggle({ Name = "Name ESP", Flag = "NameESP" })
ESPSect:CreateToggle({ Name = "Health Bar", Flag = "HealthBar" })
ESPSect:CreateToggle({ Name = "Tracers", Flag = "Tracers" })

ESPSect:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(130, 90, 210),
    Flag = "ESPColor"
})

ESPSect:CreateSlider({
    Name = "Max Distance",
    Min = 100, Max = 5000, Default = 2000,
    Increment = 100, Flag = "ESPDist"
})

local ChamsSect = Visuals:CreateSection({ Name = "Chams", Side = "Right" })

ChamsSect:CreateToggle({ Name = "Enabled", Flag = "Chams" })

ChamsSect:CreateDropdown({
    Name = "Type",
    Options = {"Flat", "Shaded", "Wireframe"},
    Default = "Flat",
    Flag = "ChamsType"
})

ChamsSect:CreateColorPicker({
    Name = "Visible",
    Default = Color3.fromRGB(130, 90, 210),
    Flag = "ChamsVis"
})

ChamsSect:CreateColorPicker({
    Name = "Hidden",
    Default = Color3.fromRGB(200, 80, 80),
    Flag = "ChamsHid"
})

------------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------------
local Settings = Window:CreateTab("Settings")

local UISect = Settings:CreateSection({ Name = "UI Settings", Side = "Left" })

UISect:CreateLabel("Press RightCtrl to toggle")

UISect:CreateKeybind({
    Name = "Toggle Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
        Library:SetToggleKey(key)
        Library:Notify({ Title = "Key", Content = key.Name, Duration = 2 })
    end
})

UISect:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Library:Notify({ Title = "Bye", Content = "Unloading...", Duration = 1 })
        task.delay(1, function() Library:Destroy() end)
    end
})

UISect:CreateButton({
    Name = "Copy Discord",
    Callback = function()
        pcall(function() setclipboard("discord.gg/example") end)
        Library:Notify({ Title = "Copied!", Content = "Invite copied", Duration = 2 })
    end
})

local InfoSect = Settings:CreateSection({ Name = "Info", Side = "Right" })

InfoSect:CreateLabel("Aura X v1.0")
InfoSect:CreateLabel("Drawing API Library")
InfoSect:CreateLabel("PC & Mobile")

InfoSect:CreateButton({
    Name = "Test Notification",
    Callback = function()
        Library:Notify({ Title = "Test", Content = "It works!", Duration = 3 })
    end
})

Library:Notify({ Title = "Ready", Content = "All modules loaded", Duration = 3 })
```
