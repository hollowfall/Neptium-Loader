# 🌀 Aura X — Drawing UI Library

A fully-featured Roblox UI Library built **entirely with the Drawing API** — no ScreenGui or GUI instances.  
Cross-platform support for **PC & Mobile**.

![Lua](https://img.shields.io/badge/Lua-Drawing%20API-blueviolet)
![Platform](https://img.shields.io/badge/Platform-PC%20%26%20Mobile-brightgreen)

---

## ⚡ Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8qz/Aura-X/refs/heads/Sc/Source.lua"))()

Library:CreateWatermark({ Text = "Aura X" })

local Window = Library:CreateWindow({ Title = "My Script" })
local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection({ Name = "Features", Side = "Left" })

Section:CreateToggle({
    Name = "Aimbot",
    Default = false,
    Flag = "AimbotEnabled",
    Callback = function(value)
        print("Aimbot:", value)
    end
})
```

---

## 📖 API Reference

### Library

#### `Library:CreateWatermark(config)`
Creates a watermark box below the Roblox logo. Auto-updates with FPS and Ping.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Text` | string | `"Library"` | Base name shown in watermark |
| `GameName` | string | `""` | Game name to display (optional) |
| `AutoUpdate` | boolean | `true` | Auto-show FPS & Ping |

```lua
Library:CreateWatermark({
    Text = "Aura X",
    GameName = "Arsenal",
    AutoUpdate = true
})
-- Result: "Aura X | Arsenal | 60 fps | 32ms"
```

#### `Library:UpdateWatermark(text)`
Manually update the watermark text.

```lua
Library:UpdateWatermark("Aura X | Custom Text")
```

#### `Library:SetToggleKey(keyCode)`
Change the key that shows/hides the UI. Default: `RightControl`.

```lua
Library:SetToggleKey(Enum.KeyCode.RightShift)
```

#### `Library:Notify(config)`
Show a notification in the top-right corner. Stacks automatically.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | string | `"Notice"` | Notification title |
| `Content` | string | `""` | Notification body text |
| `Duration` | number | `3` | Seconds before auto-dismiss |

```lua
Library:Notify({
    Title = "Success",
    Content = "Feature enabled!",
    Duration = 3
})
```

#### `Library:Destroy()`
Removes all drawings and disconnects all events. Full cleanup.

```lua
Library:Destroy()
```

#### `Library.Flags`
A table that stores all flagged element values. Access any element's value by its flag name.

```lua
print(Library.Flags["AimbotEnabled"]) -- true/false
print(Library.Flags["AimFOV"])        -- 185
print(Library.Flags["HitBox"])        -- "Head"
```

#### `Library.Toggled`
Boolean — whether the UI is currently visible. Read-only recommended.

---

### Window

#### `Library:CreateWindow(config)`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | string | `"Window"` | Window title text |
| `Position` | Vector2 | Center of screen | Starting position |

```lua
local Window = Library:CreateWindow({
    Title = "Aura X"
})
```

**Features:**
- Draggable by the title bar
- Toggle with `RightControl` (or custom key)
- On Mobile: use the Toggle UI / Lock buttons below the watermark

---

### Tab

#### `Window:CreateTab(name)`
Creates a tab. First tab is auto-activated.

```lua
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")
```

---

### Section / Groupbox

#### `Tab:CreateSection(config)`
Creates a section inside a tab. Supports two-column layout.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Section"` | Section header text |
| `Side` | string | `"Left"` | `"Left"` or `"Right"` column |

```lua
local Left = Tab:CreateSection({ Name = "Aim Assist", Side = "Left" })
local Right = Tab:CreateSection({ Name = "Settings", Side = "Right" })
```

> Multiple sections on the same side will stack vertically.

---

### Elements

All elements are created inside a Section.

---

#### 🔘 Toggle

```lua
local toggle = Section:CreateToggle({
    Name = "Enabled",
    Default = false,
    Flag = "MyToggle",
    Callback = function(value)
        print("Toggle:", value)
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Toggle"` | Label text |
| `Default` | boolean | `false` | Initial state |
| `Flag` | string | `nil` | Key in `Library.Flags` |
| `Callback` | function | — | Called with `true`/`false` |

---

#### 🎚️ Slider

```lua
local slider = Section:CreateSlider({
    Name = "FOV",
    Min = 0,
    Max = 360,
    Default = 185,
    Increment = 1,
    Suffix = "°",
    Flag = "AimFOV",
    Callback = function(value)
        print("FOV:", value)
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Slider"` | Label text |
| `Min` | number | `0` | Minimum value |
| `Max` | number | `100` | Maximum value |
| `Default` | number | `Min` | Initial value |
| `Increment` | number | `1` | Step size |
| `Suffix` | string | `""` | Text after value (e.g. `°`, `%`) |
| `Flag` | string | `nil` | Key in `Library.Flags` |
| `Callback` | function | — | Called with new value |

---

#### 📋 Dropdown

```lua
local dropdown = Section:CreateDropdown({
    Name = "Hit Box",
    Options = {"Head", "Torso", "Random"},
    Default = "Head",
    Flag = "HitBox",
    Callback = function(value)
        print("Selected:", value)
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Dropdown"` | Label text |
| `Options` | table | `{}` | List of option strings |
| `Default` | string | First option | Initially selected |
| `Flag` | string | `nil` | Key in `Library.Flags` |
| `Callback` | function | — | Called with selected option |

---

#### 🔲 Button

```lua
Section:CreateButton({
    Name = "Execute",
    Callback = function()
        print("Button clicked!")
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Button"` | Button label |
| `Callback` | function | — | Called on click |

---

#### 📝 Label

```lua
local label = Section:CreateLabel("Hello World")

-- Update later:
label:SetText("Updated text")
```

---

#### ⌨️ Keybind

```lua
Section:CreateKeybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.E,
    Flag = "AimKey",
    Callback = function(newKey)
        print("Key set to:", newKey.Name)
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Keybind"` | Label text |
| `Default` | KeyCode | `Unknown` | Initial keybind |
| `Flag` | string | `nil` | Key in `Library.Flags` |
| `Callback` | function | — | Called with new KeyCode |

> Click the keybind box, then press any key to set it. Press `Escape` to clear.

---

#### 🎨 Color Picker

```lua
local picker = Section:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(130, 90, 210),
    Flag = "ESPColor",
    Callback = function(color)
        print("Color:", color)
    end
})

-- Update programmatically:
picker:SetColor(Color3.fromRGB(255, 0, 0))
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Color"` | Label text |
| `Default` | Color3 | Purple | Initial color |
| `Flag` | string | `nil` | Key in `Library.Flags` |
| `Callback` | function | — | Called with Color3 |

---

## 📱 Mobile Support

The library automatically detects mobile devices and:

- **Scales the UI** to fit the screen
- **Adds two buttons** below the watermark:
  - **Toggle UI** — show/hide the entire window
  - **Lock** — prevents accidental dragging when tapping elements

> On PC, press `RightControl` (or your custom key) to toggle the UI.

---

## 🎨 Theme

The default theme uses a dark navy/charcoal palette with purple accents. The colors are defined in the `T` table inside the library:

| Color | RGB | Used For |
|-------|-----|----------|
| Accent | `130, 90, 210` | Top bar, active tab, toggles, sliders |
| Window BG | `18, 18, 28` | Main window background |
| Section BG | `24, 24, 36` | Section fill |
| Element BG | `30, 30, 44` | Buttons, dropdowns, sliders |
| Text | `240, 240, 248` | Primary text (near white) |
| Dim Text | `175, 172, 195` | Secondary text, labels |
| Borders | `60, 55, 90` | Window & section outlines |

---

## 📋 Full Example

```lua
local Library = loadstring(game:HttpGet("YOUR_URL"))()

local gameName = "Game"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

Library:CreateWatermark({
    Text = "Aura X",
    GameName = gameName,
    AutoUpdate = true
})

Library:SetToggleKey(Enum.KeyCode.RightControl)
Library:Notify({ Title = "Aura X", Content = "Loaded!", Duration = 3 })

local Window = Library:CreateWindow({ Title = "Aura X" })

-- Combat Tab
local Combat = Window:CreateTab("Combat")
local AimSect = Combat:CreateSection({ Name = "Aim Assist", Side = "Left" })

AimSect:CreateToggle({ Name = "Enabled", Flag = "Aim", Callback = function(v) end })
AimSect:CreateSlider({ Name = "FOV", Min = 0, Max = 360, Default = 180, Suffix = "°", Flag = "FOV" })
AimSect:CreateDropdown({ Name = "Target", Options = {"Head","Torso"}, Default = "Head", Flag = "Target" })
AimSect:CreateKeybind({ Name = "Aim Key", Default = Enum.KeyCode.E, Flag = "AimKey" })

local MiscSect = Combat:CreateSection({ Name = "Misc", Side = "Right" })

MiscSect:CreateToggle({ Name = "Trigger Bot", Flag = "TriggerBot" })
MiscSect:CreateSlider({ Name = "Delay", Min = 0, Max = 500, Default = 50, Suffix = "ms", Flag = "TrigDelay" })

-- Visuals Tab
local Visuals = Window:CreateTab("Visuals")
local ESPSect = Visuals:CreateSection({ Name = "ESP", Side = "Left" })

ESPSect:CreateToggle({ Name = "Box ESP", Flag = "BoxESP" })
ESPSect:CreateToggle({ Name = "Name ESP", Flag = "NameESP" })
ESPSect:CreateColorPicker({ Name = "Color", Default = Color3.fromRGB(130, 90, 210), Flag = "ESPColor" })

-- Settings Tab
local Settings = Window:CreateTab("Settings")
local UISect = Settings:CreateSection({ Name = "UI", Side = "Left" })

UISect:CreateKeybind({
    Name = "Toggle Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key) Library:SetToggleKey(key) end
})

UISect:CreateButton({
    Name = "Unload",
    Callback = function()
        Library:Notify({ Title = "Bye", Content = "Unloading...", Duration = 1 })
        task.delay(1, function() Library:Destroy() end)
    end
})
```

---

## 🛠️ Using GitHub as Documentation

Your `README.md` file is automatically displayed on your repository's main page. To set this up:

1. Create a GitHub repository (e.g. `Aura-X`)
2. Add your `Library.lua` as `Source.lua`
3. Add this `README.md` file to the root
4. Push to GitHub

The raw URL for loading your library would be:
```
https://raw.githubusercontent.com/YOUR_USERNAME/Aura-X/main/Source.lua
```

> **Tip:** Use GitHub Pages for a fancier docs site, or just keep the README — it works great for most libraries.

---

## 📄 License

Free to use. Credit appreciated.
