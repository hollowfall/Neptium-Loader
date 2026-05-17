# Neptium UI Library v2.1

A clean, black/white minimalist UI library for Roblox exploit scripts.  
macOS-style traffic light window controls, animated dock minimize, and keyboard keybind support.

---

## Quick Start

```lua
local UI = Library:CreateWindow({
    Title       = "MyScript",
    Subtitle    = "v1.0",
    MinimizeKey = Enum.KeyCode.RightShift, -- optional, default: RightShift
})

local Tab = UI:CreateTab("Main", "⚙")
```

Paste the full library source at the top of your script, then use the API below.

---

## CreateWindow

```lua
Library:CreateWindow(config)
```

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Neptium"` | Window title shown in the topbar center |
| `Subtitle` | string | `"v2.1"` | Small text shown to the right of the title |
| `MinimizeKey` | KeyCode | `RightShift` | Keyboard key to toggle minimize/restore |

**Returns:** `Win` — used to create tabs.

---

## Traffic Light Buttons

The three macOS-style dots in the top-left corner do:

| Dot | Color | Action |
|---|---|---|
| Red | `#FF5F56` | Destroy the entire ScreenGui |
| Yellow | `#FFBD2E` | Minimize to a small dock button |
| Green | `#28C940` | Reserved (placeholder, hook as needed) |

Symbols (`✕` `−` `+`) appear on hover. The dot area is on the left side of the topbar.

---

## Minimize & Restore

When minimized the full window collapses into a small floating pill button labeled with your `Title`.  
Click that pill **or** press the `MinimizeKey` to restore it with a smooth scale-in animation.

To change the keybind:

```lua
Library:CreateWindow({
    MinimizeKey = Enum.KeyCode.Insert,
})
```

Any valid `Enum.KeyCode` works.

---

## Tabs

```lua
local Tab = Win:CreateTab("Tab Name", "icon")
```

`icon` is any string — emoji or short text displayed on the sidebar button.  
The first tab created is auto-selected.

---

## Elements

All elements are created on a `Tab` object.

### Toggle

```lua
Tab:CreateToggle(name, desc, default, callback)
```

`desc` is optional. `default` is `true`/`false`. `callback(value: boolean)`.

```lua
local myToggle = Tab:CreateToggle("Speed Hack", "Makes you fast", false, function(v)
    -- v is true or false
end)

myToggle:Set(true)   -- force on
myToggle:Get()       -- returns current state
```

---

### Slider

```lua
Tab:CreateSlider(name, config, callback)
```

Config table:

| Key | Default | Description |
|---|---|---|
| `Min` | `0` | Minimum value |
| `Max` | `100` | Maximum value |
| `Default` | `Min` | Starting value |
| `Step` | `1` | Snap increment |
| `Suffix` | `""` | Unit label appended to the value (e.g. `" px"`) |

```lua
local mySlider = Tab:CreateSlider("FOV", {
    Min = 10, Max = 360, Default = 90, Step = 5, Suffix = "°"
}, function(v)
    -- v is the current number
end)

mySlider:Set(180)
mySlider:Get()
```

---

### Button

```lua
Tab:CreateButton(name, desc, callback)
```

`desc` is optional. Click fires `callback()`.

```lua
Tab:CreateButton("Teleport", "Go to spawn", function()
    -- your logic
end)
```

---

### Dropdown

```lua
Tab:CreateDropdown(name, options, default, callback)
```

`options` is a table of strings. `default` is the initially selected string.

```lua
local dd = Tab:CreateDropdown("Mode", {"A", "B", "C"}, "A", function(v)
    print(v)
end)

dd:Set("B")
dd:Get()
dd:Refresh({"X", "Y"})  -- replace option list at runtime
```

---

### Input

```lua
Tab:CreateInput(name, placeholder, callback)
```

`callback(text: string, enterPressed: boolean)` fires on focus lost.

```lua
local inp = Tab:CreateInput("Name", "Enter your name...", function(text, enter)
    if enter then print(text) end
end)

inp:Get()
inp:Set("hello")
```

---

### Label

```lua
Tab:CreateLabel(text)
```

Static display text. Returns `{ SetText(text) }`.

```lua
local lbl = Tab:CreateLabel("Status: idle")
lbl:SetText("Status: active")
```

---

### Separator

```lua
Tab:CreateSeparator()          -- plain line
Tab:CreateSeparator("SECTION") -- line with uppercase label
```

---

## Hooking the Green Button

The green dot currently just prints a placeholder. To hook it yourself, find this block in the source and replace the `print`:

```lua
dots[3].btn.MouseButton1Click:Connect(function()
    -- your maximize / fullscreen logic here
end)
```

---

## Destroy the UI

```lua
for _, gui in ipairs(TargetGui:GetChildren()) do
    if gui.Name:match("^Neptium_") then gui:Destroy() end
end
```

Or use a button:

```lua
Tab:CreateButton("Close", function()
    for _, gui in ipairs(TargetGui:GetChildren()) do
        if gui.Name:match("^Neptium_") then gui:Destroy() end
    end
end)
```

---

## Full Example

```lua
local UI = Library:CreateWindow({
    Title       = "Aimbot",
    Subtitle    = "v1.0",
    MinimizeKey = Enum.KeyCode.Delete,
})

local Combat = UI:CreateTab("Combat", "⚔")

Combat:CreateToggle("Silent Aim", nil, false, function(enabled)
    -- toggle logic
end)

Combat:CreateSlider("Smoothness", {
    Min = 1, Max = 100, Default = 50, Suffix = "%"
}, function(v)
    -- update smoothness
end)

Combat:CreateSeparator("TARGETING")

Combat:CreateDropdown("Hitpart", {"Head", "Torso", "Random"}, "Head", function(part)
    -- update hitpart
end)

local Misc = UI:CreateTab("Misc", "⚙")

Misc:CreateButton("Destroy UI", function()
    for _, gui in ipairs(TargetGui:GetChildren()) do
        if gui.Name:match("^Neptium_") then gui:Destroy() end
    end
end)
```
