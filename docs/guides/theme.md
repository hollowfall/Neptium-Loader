# 🎨 Theme & Colors

Aura X uses a dark navy palette with purple accents.

## Color Palette

| Name | RGB | Hex | Used For |
|------|-----|-----|----------|
| Accent | `130, 90, 210` | `#825AD2` | Top bar, toggles, sliders, active tabs |
| Window BG | `18, 18, 28` | `#12121C` | Main background |
| Title BG | `22, 22, 34` | `#161622` | Title bar |
| Tab BG | `20, 20, 32` | `#141420` | Tab bar |
| Section BG | `24, 24, 36` | `#181824` | Section fill |
| Section Header | `28, 28, 42` | `#1C1C2A` | Section header strip |
| Element BG | `30, 30, 44` | `#1E1E2C` | Buttons, sliders, dropdowns |
| Text | `240, 240, 248` | `#F0F0F8` | Primary text |
| Dim Text | `175, 172, 195` | `#AFACC3` | Labels, secondary text |
| Border | `60, 55, 90` | `#3C375A` | Window & section outlines |
| Inner Border | `35, 33, 50` | `#232132` | Inner outline (depth effect) |
| Dividers | `42, 40, 60` | `#2A283C` | Lines between elements |

## Visual Features

- **Double borders** — Outer + inner border on window, sections, buttons
- **Section header backgrounds** — Slightly lighter strip behind section names
- **Divider lines** — Subtle separators between every element
- **Text outlines** — All text has black outline for readability
- **Accent top line** — Purple line across window top
- **Tab underline** — Active tab has purple underline indicator

## Customizing Colors

You can modify the theme table `T` inside the library source code. It's defined near the top of the file:

```lua
local T = {
    Accent = Color3.fromRGB(130, 90, 210),  -- Change this for a different accent
    WinBg = Color3.fromRGB(18, 18, 28),
    -- ... etc
}
```

?> Want a blue theme? Change `Accent` to `Color3.fromRGB(70, 130, 230)` and adjust related colors.
