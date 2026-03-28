# 📱 Mobile Support

Aura X automatically detects mobile devices and adapts the UI.

## Auto-Detection

```lua
-- Done automatically — no code needed
-- The library checks: UIS.TouchEnabled and not UIS.KeyboardEnabled
```

## What Changes on Mobile

| Feature | PC | Mobile |
|---------|-----|--------|
| UI Scale | 100% (570×430) | Auto-scaled to fit screen |
| Toggle UI | RightControl key | Toggle UI button |
| Prevent Drag | — | Lock button |
| Input | Mouse | Touch |

## Mobile Buttons

Two buttons appear **below the watermark** on mobile:

### Toggle UI
Shows/hides the entire window. Tap to toggle.

### Lock
Prevents the window from being dragged when tapping elements.  
When locked:
- The button border turns **red**
- The label shows **"Lock: ON"**
- Dragging the title bar is disabled
- All other interactions still work

## Tips for Mobile Scripts

1. **Use larger hit areas** — elements are auto-scaled but keep names short
2. **Avoid too many sections** — screen space is limited
3. **Test on mobile** — some executors handle touch differently
4. **Use the Lock button** — it prevents accidental drags when tapping toggles
