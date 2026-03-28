# Window & Tabs

## Library:CreateWindow(config)

Creates the main draggable window.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | string | `"Window"` | Title bar text |
| `Position` | Vector2 | Center | Starting position |

```lua
local Window = Library:CreateWindow({ Title = "Aura X" })
```

The window is:
- **Draggable** by the title bar
- **Toggleable** with RightControl (or custom key)
- **Auto-centered** on screen

---

## Window:CreateTab(name)

Adds a tab to the window. The first tab is auto-selected.

```lua
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")
```

Click a tab name to switch between tabs.

---

## Tab:CreateSection(config)

Creates a grouped section inside a tab. Supports two-column layout.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Section"` | Header text |
| `Side` | string | `"Left"` | `"Left"` or `"Right"` |

```lua
local Left = Tab:CreateSection({ Name = "Aim Assist", Side = "Left" })
local Right = Tab:CreateSection({ Name = "Misc", Side = "Right" })
```

!> Sections on the same side **stack vertically**. Add elements to a section before creating the next one on the same side for correct spacing.

---

## Visual Structure

```
┌─ Window ──────────────────────────────────┐
│ 🟣 Aura X                                │ ← Title Bar (drag here)
├───────────────────────────────────────────┤
│ Combat │ Visuals │ Settings               │ ← Tabs
├───────────────────────────────────────────┤
│ ┌─ Aim Assist ──┐  ┌─ Misc ───────────┐  │
│ │ Enabled    [✓] │  │ No Recoil   [✓]  │  │
│ │────────────────│  │──────────────────│  │ ← Sections
│ │ FOV   ████░░░░ │  │ Speed  ████░░░░  │  │    with
│ │────────────────│  │──────────────────│  │    Elements
│ │ HitBox [Head▾] │  │ [ Execute ]      │  │
│ └────────────────┘  └──────────────────┘  │
└───────────────────────────────────────────┘
```
