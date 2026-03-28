# Library

The main `Library` object is returned when you load the script.

```lua
local Library = loadstring(game:HttpGet("URL"))()
```

---

## Library:CreateWatermark(config)

Creates a watermark box below the Roblox logo.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Text` | string | `"Library"` | Base name |
| `GameName` | string | `""` | Game name to show |
| `AutoUpdate` | boolean | `true` | Show live FPS & Ping |

```lua
Library:CreateWatermark({
    Text = "Aura X",
    GameName = "Arsenal",
    AutoUpdate = true
})
```

---

## Library:UpdateWatermark(text)

Manually set the watermark text.

```lua
Library:UpdateWatermark("Custom Text Here")
```

---

## Library:SetToggleKey(keyCode)

Change the key to show/hide the UI.

```lua
Library:SetToggleKey(Enum.KeyCode.Home)
```

> Default: `Enum.KeyCode.RightControl`

---

## Library:Notify(config)

Show a notification in the top-right corner. Multiple notifications stack.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | string | `"Notice"` | Bold title text |
| `Content` | string | `""` | Body text |
| `Duration` | number | `3` | Seconds visible |

```lua
Library:Notify({
    Title = "Success",
    Content = "Feature enabled!",
    Duration = 3
})
```

---

## Library:CreateWindow(config)

Creates the main UI window. See [Window & Tabs](window.md).

---

## Library:Destroy()

Full cleanup — removes all drawings, disconnects all events.

```lua
Library:Destroy()
```

---

## Library.Flags

A table storing all flagged element values. Use this to read element states from anywhere in your code.

```lua
print(Library.Flags["AimEnabled"])  -- true/false
print(Library.Flags["FOV"])         -- 180
print(Library.Flags["HitBox"])      -- "Head"
```

---

## Library.Toggled

`boolean` — Whether the UI is currently visible.

---

## Library.ToggleKey

`Enum.KeyCode` — Current toggle key. Change with `SetToggleKey()`.
