# ⚡ Getting Started

## Step 1 — Load the Library

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8qz/Aura-X/main/Source.lua"))()
```

## Step 2 — Create a Watermark

The watermark appears below the Roblox logo. It can auto-display FPS and Ping.

```lua
Library:CreateWatermark({
    Text = "Aura X",
    GameName = "Arsenal",
    AutoUpdate = true
})
```

This shows: `Aura X | Arsenal | 60 fps | 32ms`

## Step 3 — Create a Window

```lua
local Window = Library:CreateWindow({ Title = "Aura X" })
```

The window is **draggable** by its title bar and centered on screen by default.

## Step 4 — Add Tabs

```lua
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")
```

The first tab is automatically selected.

## Step 5 — Add Sections

Each tab supports a **two-column layout** with `"Left"` and `"Right"` sides.

```lua
local AimSection = CombatTab:CreateSection({ Name = "Aim Assist", Side = "Left" })
local MiscSection = CombatTab:CreateSection({ Name = "Misc", Side = "Right" })
```

Multiple sections on the same side **stack vertically**.

## Step 6 — Add Elements

Now add interactive elements inside your sections:

```lua
AimSection:CreateToggle({
    Name = "Enabled",
    Default = false,
    Flag = "AimEnabled",
    Callback = function(value)
        print("Aim:", value)
    end
})

AimSection:CreateSlider({
    Name = "FOV",
    Min = 0, Max = 360, Default = 180,
    Suffix = "°",
    Flag = "AimFOV",
    Callback = function(value)
        print("FOV:", value)
    end
})

AimSection:CreateDropdown({
    Name = "Hit Box",
    Options = {"Head", "Torso", "Random"},
    Default = "Head",
    Flag = "HitBox",
    Callback = function(value)
        print("HitBox:", value)
    end
})
```

## Step 7 — Notifications

```lua
Library:Notify({
    Title = "Loaded",
    Content = "Aura X is ready!",
    Duration = 3
})
```

## Step 8 — Toggle Key

By default, press **RightControl** to toggle the UI. You can change it:

```lua
Library:SetToggleKey(Enum.KeyCode.RightShift)
```

Or let the user pick their own key with a Keybind element:

```lua
Section:CreateKeybind({
    Name = "UI Toggle Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
        Library:SetToggleKey(key)
    end
})
```

## Reading Flag Values

All elements with a `Flag` parameter store their value in `Library.Flags`:

```lua
if Library.Flags["AimEnabled"] then
    -- aimbot logic using Library.Flags["AimFOV"]
end
```

## Cleanup

To fully unload the library:

```lua
Library:Destroy()
```

This removes all drawings and disconnects all events.

?> Now check the [API Reference](api/library.md) for detailed docs on every method.
