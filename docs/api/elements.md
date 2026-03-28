# Elements

All elements are created inside a [Section](window.md#tabcreatesectionconfig).  
Every element supports an optional `Flag` to store its value in `Library.Flags`.

---

## Toggle

A checkbox toggle — click anywhere on the row to flip it.

```lua
Section:CreateToggle({
    Name = "Enabled",
    Default = false,
    Flag = "MyToggle",
    Callback = function(value)
        print(value) -- true/false
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Toggle"` | Label |
| `Default` | boolean | `false` | Initial state |
| `Flag` | string | — | Key in `Library.Flags` |
| `Callback` | function | — | Fires with `true`/`false` |

---

## Slider

A draggable slider bar with live value display.

```lua
Section:CreateSlider({
    Name = "FOV",
    Min = 0,
    Max = 360,
    Default = 180,
    Increment = 5,
    Suffix = "°",
    Flag = "AimFOV",
    Callback = function(value)
        print(value) -- number
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Slider"` | Label |
| `Min` | number | `0` | Minimum value |
| `Max` | number | `100` | Maximum value |
| `Default` | number | `Min` | Starting value |
| `Increment` | number | `1` | Step size |
| `Suffix` | string | `""` | Text after value (`°`, `%`, `ms`) |
| `Flag` | string | — | Key in `Library.Flags` |
| `Callback` | function | — | Fires with new number |

---

## Dropdown

A selectable dropdown list. Only one can be open at a time.

```lua
Section:CreateDropdown({
    Name = "Hit Box",
    Options = {"Head", "Torso", "Random"},
    Default = "Head",
    Flag = "HitBox",
    Callback = function(value)
        print(value) -- string
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Dropdown"` | Label |
| `Options` | table | `{}` | List of strings |
| `Default` | string | First option | Pre-selected |
| `Flag` | string | — | Key in `Library.Flags` |
| `Callback` | function | — | Fires with selected string |

---

## Button

A clickable button with a flash animation on press.

```lua
Section:CreateButton({
    Name = "Execute",
    Callback = function()
        print("Clicked!")
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Button"` | Button label |
| `Callback` | function | — | Fires on click |

---

## Label

Static text line. Can be updated later.

```lua
local label = Section:CreateLabel("Hello World")

-- Update text:
label:SetText("New text here")
```

---

## Keybind

Click the box, then press any key to bind it. Press `Escape` to clear.

```lua
Section:CreateKeybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.E,
    Flag = "AimKey",
    Callback = function(keyCode)
        print(keyCode.Name) -- "E"
    end
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Keybind"` | Label |
| `Default` | KeyCode | `Unknown` | Initial key |
| `Flag` | string | — | Key in `Library.Flags` |
| `Callback` | function | — | Fires with `Enum.KeyCode` |

> **Tip:** Use this to let users set the UI toggle key:
> ```lua
> Section:CreateKeybind({
>     Name = "Toggle Key",
>     Default = Enum.KeyCode.RightControl,
>     Callback = function(key) Library:SetToggleKey(key) end
> })
> ```

---

## Color Picker

Shows a color preview box. Update programmatically with `:SetColor()`.

```lua
local picker = Section:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(130, 90, 210),
    Flag = "ESPColor",
    Callback = function(color)
        print(color) -- Color3
    end
})

-- Change color from code:
picker:SetColor(Color3.fromRGB(255, 0, 0))
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | `"Color"` | Label |
| `Default` | Color3 | Purple | Initial color |
| `Flag` | string | — | Key in `Library.Flags` |
| `Callback` | function | — | Fires with `Color3` |
