# 🌀 Aura X

A fully-featured Roblox UI Library built **entirely with the Drawing API**.  
No ScreenGui, no GUI instances — just raw Drawing objects.

## Features

- 🎨 **Pure Drawing API** — Undetectable by standard anti-cheats
- 📱 **Cross-Platform** — Works on PC and Mobile
- 🪟 **Draggable Windows** — Smooth title bar dragging
- 📑 **Tab System** — Organize features into tabs
- 📦 **Sections** — Two-column layout (Left/Right)
- 🔘 **Toggles, Sliders, Dropdowns, Buttons, Labels, Keybinds, Color Pickers**
- 🔔 **Notification System** — Stacking, auto-dismiss
- 💧 **Watermark** — Auto FPS & Ping display
- 🔑 **Keybindable UI Toggle**
- 🏷️ **Flag System** — Access element values by name

## Installation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8qz/Aura-X/main/Source.lua"))()
```

## Quick Example

```lua
local Library = loadstring(game:HttpGet("URL"))()

Library:CreateWatermark({ Text = "Aura X", AutoUpdate = true })

local Window = Library:CreateWindow({ Title = "My Script" })
local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection({ Name = "Combat", Side = "Left" })

Section:CreateToggle({
    Name = "Aimbot",
    Flag = "Aimbot",
    Callback = function(v) print(v) end
})

Section:CreateSlider({
    Name = "FOV",
    Min = 0, Max = 360, Default = 180,
    Suffix = "°", Flag = "FOV"
})
```

?> Head over to [Getting Started](getting-started.md) for a full walkthrough.
