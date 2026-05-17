# Neptium

A minimal, dark UI library for Roblox exploits. Tabs, toggles, sliders, dropdowns, inputs, buttons — all in one require.

---

## Loading

```lua
local Neptium = loadstring(game:HttpGet("https://raw.githubusercontent.com/hollowfall/Neptium-Loader/refs/heads/Sc/Source.lua"))()
```

---

## Creating a Window

```lua
local Win = Neptium:CreateWindow({
    Title = "My Script",
    Subtitle = "v1.0",
    MinimizeKey = Enum.KeyCode.RightShift
})
```

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Neptium"` | Window title shown in the topbar |
| `Subtitle` | string | `"v1.0"` | Smaller text next to the title |
| `MinimizeKey` | KeyCode | `RightShift` | Key that toggles minimize |

The three dots in the top-left corner work like macOS window controls. Red closes the GUI, yellow minimizes it to a small dock button on the left side of the screen. Clicking that button restores the window.

---

## Tabs

```lua
local Tab = Win:CreateTab("Combat", "sword")
```

The second argument is an icon label (optional). Tabs appear in the sidebar. The first tab created is selected by default.

---

## Elements

All elements are methods on a Tab object.

---

### Button

```lua
Tab:CreateButton("Teleport", "Teleports to the nearest player", function()
    -- callback
end)
```

The description is optional. If you skip it, just pass the callback as the second argument:

```lua
Tab:CreateButton("Teleport", function()
    -- callback
end)
```

---

### Toggle

```lua
local toggle = Tab:CreateToggle("God Mode", "Makes you unkillable", false, function(state)
    print(state) -- true or false
end)
```

Description and default value are both optional. The argument order is flexible — if you pass a boolean as the second argument it's treated as the default value, not the description.

```lua
-- No description, default true
local toggle = Tab:CreateToggle("Fly", true, function(state)
    -- state = true/false
end)
```

**Methods:**

```lua
toggle:Set(true)   -- set the value programmatically
toggle:Get()       -- returns current state
```

---

### Slider

```lua
local slider = Tab:CreateSlider("Walk Speed", {
    Min = 0,
    Max = 500,
    Default = 16,
    Step = 1,
    Suffix = " speed"
}, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

| Option | Type | Default | Description |
|---|---|---|---|
| `Min` | number | `0` | Minimum value |
| `Max` | number | `100` | Maximum value |
| `Default` | number | `Min` | Starting value |
| `Step` | number | `1` | Snap increment |
| `Suffix` | string | `""` | Text appended to the value label |

**Methods:**

```lua
slider:Set(100)   -- set the value
slider:Get()      -- returns current value
```

---

### Dropdown

```lua
local dropdown = Tab:CreateDropdown("Team", {"Attackers", "Defenders", "Spectators"}, "Attackers", function(selected)
    print(selected)
end)
```

The third argument (default selection) is optional and falls back to the first option.

**Methods:**

```lua
dropdown:Set("Defenders")                        -- change selection
dropdown:Get()                                   -- returns current selection
dropdown:Refresh({"Option A", "Option B"})       -- replace the options list
```

---

### Input

```lua
local input = Tab:CreateInput("Username", "Enter username...", function(text, enterPressed)
    if enterPressed then
        print(text)
    end
end)
```

The callback fires when the textbox loses focus. `enterPressed` is `true` if the user pressed Enter, `false` if they clicked away.

**Methods:**

```lua
input:Get()          -- returns current text
input:Set("hello")   -- set text programmatically
```

---

### Label

```lua
local label = Tab:CreateLabel("Status: idle")
label:SetText("Status: running")
```

A read-only text row. Use `:SetText()` to update it at runtime.

---

### Separator

```lua
Tab:CreateSeparator("Settings")
Tab:CreateSeparator()   -- line with no text
```

Thin divider line used to group elements visually. The text is optional and renders uppercase.

---

## Full Example

```lua
local Neptium = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local Win = Neptium:CreateWindow({
    Title = "Aimbot",
    Subtitle = "v1.0",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Combat = Win:CreateTab("Combat")
local Misc = Win:CreateTab("Misc")

Combat:CreateSeparator("Aimbot")

local toggle = Combat:CreateToggle("Enabled", false, function(state)
    print("aimbot:", state)
end)

local fov = Combat:CreateSlider("FOV", {
    Min = 10,
    Max = 500,
    Default = 120,
    Suffix = " px"
}, function(value)
    print("fov:", value)
end)

local smoothing = Combat:CreateSlider("Smoothing", {
    Min = 0,
    Max = 1,
    Default = 0.5,
    Step = 0.01
}, function(value)
    print("smoothing:", value)
end)

Combat:CreateSeparator("Target")

local part = Combat:CreateDropdown("Hitbox", {"Head", "Torso", "Closest"}, "Head", function(selected)
    print("target:", selected)
end)

Misc:CreateButton("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

local statusLabel = Misc:CreateLabel("Status: idle")

Misc:CreateButton("Update Status", function()
    statusLabel:SetText("Status: running")
end)
```
