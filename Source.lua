--[[
    Drawing UI Library v1.0
    Pure Drawing API (Drawing.new) — No ScreenGui / Roblox GUI instances
    Cross-platform: PC & Mobile
]]

local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local Players = game:GetService("Players")
local HS  = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ── Platform ──
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local Viewport = Camera.ViewportSize
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    Viewport = Camera.ViewportSize
end)

-- ── Mouse state ──
local Mouse = { Position = Vector2.new(0,0), Down = false }
local Connections = {}

-- ── ZIndex counter ──
local ZCounter = 0
local function nextZ()
    ZCounter = ZCounter + 1
    return ZCounter
end

-- ── Utility ──
local function inBounds(pos, tl, size)
    return pos.X >= tl.X and pos.X <= tl.X + size.X
       and pos.Y >= tl.Y and pos.Y <= tl.Y + size.Y
end

local function clamp(v, lo, hi)
    return math.clamp(v, lo, hi)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function round(v)
    return math.floor(v + 0.5)
end

local function uid()
    return HS:GenerateGUID(false)
end

local function deepCopy(t)
    local c = {}
    for k,v in pairs(t) do c[k] = type(v)=="table" and deepCopy(v) or v end
    return c
end

-- ── Drawing helper ──
local AllDrawings = {}
local function new(class, props)
    local obj = Drawing.new(class)
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    table.insert(AllDrawings, obj)
    return obj
end

-- ══════════════════════════════════════════
--  LIBRARY
-- ══════════════════════════════════════════
local Library = {}
Library.__index = Library
Library.Windows = {}
Library.Notifications = {}
Library.Toggled = true
Library.MobileLocked = false
Library.OpenDropdown = nil -- only one open at a time
Library.FocusedTextbox = nil
Library.Flags = {}

-- ── Theme ──
Library.Theme = {
    Accent              = Color3.fromRGB(120, 80, 200),
    AccentDark          = Color3.fromRGB(85, 55, 155),
    WindowBackground    = Color3.fromRGB(20, 20, 32),
    WindowBorder        = Color3.fromRGB(55, 50, 80),
    TitleBar            = Color3.fromRGB(26, 26, 40),
    TabBackground       = Color3.fromRGB(24, 24, 38),
    TabActive           = Color3.fromRGB(34, 34, 52),
    TabBorder           = Color3.fromRGB(50, 48, 72),
    SectionBackground   = Color3.fromRGB(26, 26, 40),
    SectionBorder       = Color3.fromRGB(50, 48, 72),
    ElementBackground   = Color3.fromRGB(32, 32, 48),
    ElementBorder       = Color3.fromRGB(55, 52, 78),
    Text                = Color3.fromRGB(225, 225, 235),
    DimText             = Color3.fromRGB(160, 158, 175),
    DisabledText        = Color3.fromRGB(110, 108, 125),
    SliderFill          = Color3.fromRGB(120, 80, 200),
    ToggleOn            = Color3.fromRGB(120, 80, 200),
    ToggleOff           = Color3.fromRGB(40, 40, 58),
    DropdownBg          = Color3.fromRGB(28, 28, 44),
    NotifyBg            = Color3.fromRGB(22, 22, 36),
    NotifyBorder        = Color3.fromRGB(120, 80, 200),
}
local T = Library.Theme

-- ── Scale factor for mobile ──
local Scale = 1
local WinW, WinH = 570, 420
if IsMobile then
    Scale = math.min(Viewport.X / (WinW + 40), Viewport.Y / (WinH + 100))
    Scale = math.clamp(Scale, 0.45, 1)
    WinW = math.floor(WinW * Scale)
    WinH = math.floor(WinH * Scale)
end
local FontSize     = math.floor(13 * Scale)
local FontSizeSm   = math.floor(11 * Scale)
local FontSizeLg   = math.floor(15 * Scale)
local ElemH        = math.floor(18 * Scale)
local Pad          = math.floor(6 * Scale)
local TitleH       = math.floor(24 * Scale)
local TabH         = math.floor(22 * Scale)
local SectHeaderH  = math.floor(20 * Scale)
local SliderH      = math.floor(10 * Scale)
local ToggleSize   = math.floor(14 * Scale)
local BtnH         = math.floor(22 * Scale)
local DropArrowSz  = math.floor(6 * Scale)

-- ══════════════════════════════════════════
--  WATERMARK
-- ══════════════════════════════════════════
function Library:CreateWatermark(text)
    text = text or "Library"
    local wm = {}
    wm.Text = new("Text", {
        Text = text,
        Size = FontSizeLg,
        Font = Drawing.Fonts.UI,
        Color = T.Text,
        Outline = true,
        OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(10, 6),
        Visible = true,
        ZIndex = 50000,
    })
    wm.AccentLine = new("Line", {
        From = Vector2.new(8, 4 + FontSizeLg + 4),
        To = Vector2.new(8 + wm.Text.TextBounds.X + 8, 4 + FontSizeLg + 4),
        Color = T.Accent,
        Thickness = 2,
        Visible = true,
        ZIndex = 50000,
    })
    self.Watermark = wm
    self.WatermarkBottomY = 4 + FontSizeLg + 8

    -- Mobile buttons
    if IsMobile then
        self:_CreateMobileButtons()
    end
    return wm
end

function Library:UpdateWatermark(text)
    if self.Watermark then
        self.Watermark.Text.Text = text
        self.Watermark.AccentLine.To = Vector2.new(8 + self.Watermark.Text.TextBounds.X + 8, self.Watermark.AccentLine.From.Y)
    end
end

-- ══════════════════════════════════════════
--  MOBILE BUTTONS
-- ══════════════════════════════════════════
function Library:_CreateMobileButtons()
    local y = (self.WatermarkBottomY or 30) + 4
    local btnW, btnH = 70, 28
    -- Toggle UI btn
    self._MobileToggleBtn = {
        Bg = new("Square", {
            Position = Vector2.new(8, y),
            Size = Vector2.new(btnW, btnH),
            Color = T.ElementBackground,
            Filled = true, Visible = true, ZIndex = 50001,
        }),
        Border = new("Square", {
            Position = Vector2.new(8, y),
            Size = Vector2.new(btnW, btnH),
            Color = T.Accent,
            Filled = false, Thickness = 1, Visible = true, ZIndex = 50002,
        }),
        Label = new("Text", {
            Text = "Toggle UI",
            Size = FontSizeSm,
            Font = Drawing.Fonts.UI,
            Color = T.Text,
            Outline = true, OutlineColor = Color3.new(0,0,0),
            Position = Vector2.new(8 + btnW/2, y + 6),
            Center = true, Visible = true, ZIndex = 50003,
        }),
    }
    -- Lock btn
    self._MobileLockBtn = {
        Bg = new("Square", {
            Position = Vector2.new(8 + btnW + 6, y),
            Size = Vector2.new(btnW, btnH),
            Color = T.ElementBackground,
            Filled = true, Visible = true, ZIndex = 50001,
        }),
        Border = new("Square", {
            Position = Vector2.new(8 + btnW + 6, y),
            Size = Vector2.new(btnW, btnH),
            Color = T.Accent,
            Filled = false, Thickness = 1, Visible = true, ZIndex = 50002,
        }),
        Label = new("Text", {
            Text = "Lock: OFF",
            Size = FontSizeSm,
            Font = Drawing.Fonts.UI,
            Color = T.Text,
            Outline = true, OutlineColor = Color3.new(0,0,0),
            Position = Vector2.new(8 + btnW + 6 + btnW/2, y + 6),
            Center = true, Visible = true, ZIndex = 50003,
        }),
    }
end

function Library:_HandleMobileButtons(pos)
    if not IsMobile then return false end
    -- Toggle
    local tb = self._MobileToggleBtn
    if tb and inBounds(pos, tb.Bg.Position, tb.Bg.Size) then
        self.Toggled = not self.Toggled
        for _, win in ipairs(self.Windows) do
            win:SetVisible(self.Toggled)
        end
        return true
    end
    -- Lock
    local lb = self._MobileLockBtn
    if lb and inBounds(pos, lb.Bg.Position, lb.Bg.Size) then
        self.MobileLocked = not self.MobileLocked
        lb.Label.Text = "Lock: " .. (self.MobileLocked and "ON" or "OFF")
        lb.Border.Color = self.MobileLocked and Color3.fromRGB(200, 80, 80) or T.Accent
        return true
    end
    return false
end

-- ══════════════════════════════════════════
--  NOTIFICATIONS
-- ══════════════════════════════════════════
function Library:Notify(options)
    local title    = options.Title or "Notification"
    local content  = options.Content or ""
    local duration = options.Duration or 3
    local nw = math.floor(220 * Scale)
    local nh = math.floor(50 * Scale)
    local px = Viewport.X - nw - 12
    local py = 10 + #self.Notifications * (nh + 6)

    local n = {}
    n.Bg = new("Square", {
        Position = Vector2.new(px, py), Size = Vector2.new(nw, nh),
        Color = T.NotifyBg, Filled = true, Visible = true, ZIndex = 60000,
    })
    n.Border = new("Square", {
        Position = Vector2.new(px, py), Size = Vector2.new(nw, nh),
        Color = T.NotifyBorder, Filled = false, Thickness = 1, Visible = true, ZIndex = 60001,
    })
    n.AccentLine = new("Line", {
        From = Vector2.new(px, py), To = Vector2.new(px, py + nh),
        Color = T.Accent, Thickness = 2, Visible = true, ZIndex = 60002,
    })
    n.Title = new("Text", {
        Text = title, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(px + 8, py + 4), Visible = true, ZIndex = 60003,
    })
    n.Content = new("Text", {
        Text = content, Size = FontSizeSm, Font = Drawing.Fonts.UI,
        Color = T.DimText, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(px + 8, py + 4 + FontSize + 4), Visible = true, ZIndex = 60003,
    })
    n._removeAt = tick() + duration
    table.insert(self.Notifications, n)
end

function Library:_TickNotifications()
    local now = tick()
    local removed = false
    for i = #self.Notifications, 1, -1 do
        local n = self.Notifications[i]
        if now >= n._removeAt then
            n.Bg:Remove(); n.Border:Remove(); n.AccentLine:Remove()
            n.Title:Remove(); n.Content:Remove()
            table.remove(self.Notifications, i)
            removed = true
        end
    end
    if removed then
        for i, n in ipairs(self.Notifications) do
            local py = 10 + (i-1) * (math.floor(50*Scale) + 6)
            local px = n.Bg.Position.X
            n.Bg.Position = Vector2.new(px, py)
            n.Border.Position = Vector2.new(px, py)
            n.AccentLine.From = Vector2.new(px, py)
            n.AccentLine.To = Vector2.new(px, py + n.Bg.Size.Y)
            n.Title.Position = Vector2.new(px + 8, py + 4)
            n.Content.Position = Vector2.new(px + 8, py + 4 + FontSize + 4)
        end
    end
end

-- ══════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════
local Window = {}
Window.__index = Window

function Library:CreateWindow(options)
    options = options or {}
    local self2 = setmetatable({}, Window)
    self2.Library = Library
    self2.Title = options.Title or "Window"
    self2.Size = options.Size or Vector2.new(WinW, WinH)
    self2.Position = options.Position or Vector2.new(
        math.floor(Viewport.X/2 - WinW/2),
        math.floor(Viewport.Y/2 - WinH/2)
    )
    self2.Tabs = {}
    self2.ActiveTab = nil
    self2.Visible = true
    self2.Dragging = false
    self2.DragOffset = Vector2.new(0,0)
    self2.Elements = {} -- all interactive elements for input
    self2._zBase = nextZ() * 100

    -- Draw
    local p = self2.Position
    local s = self2.Size
    local z = self2._zBase

    self2.Drawings = {}
    -- Background
    self2.Drawings.Bg = new("Square", {
        Position = p, Size = s, Color = T.WindowBackground,
        Filled = true, Visible = true, ZIndex = z,
    })
    -- Border
    self2.Drawings.Border = new("Square", {
        Position = p, Size = s, Color = T.WindowBorder,
        Filled = false, Thickness = 1, Visible = true, ZIndex = z+1,
    })
    -- Title bar accent line
    self2.Drawings.AccentTop = new("Line", {
        From = p, To = Vector2.new(p.X + s.X, p.Y),
        Color = T.Accent, Thickness = 2, Visible = true, ZIndex = z+2,
    })
    -- Title bar bg
    self2.Drawings.TitleBg = new("Square", {
        Position = Vector2.new(p.X, p.Y + 2),
        Size = Vector2.new(s.X, TitleH),
        Color = T.TitleBar, Filled = true, Visible = true, ZIndex = z+1,
    })
    -- Title text
    self2.Drawings.TitleText = new("Text", {
        Text = self2.Title, Size = FontSizeLg, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(p.X + 8, p.Y + 4),
        Visible = true, ZIndex = z+3,
    })
    -- Tab bar bg
    self2.Drawings.TabBarBg = new("Square", {
        Position = Vector2.new(p.X, p.Y + 2 + TitleH),
        Size = Vector2.new(s.X, TabH),
        Color = T.TabBackground, Filled = true, Visible = true, ZIndex = z+1,
    })
    -- Tab bar bottom line
    self2.Drawings.TabBarLine = new("Line", {
        From = Vector2.new(p.X, p.Y + 2 + TitleH + TabH),
        To = Vector2.new(p.X + s.X, p.Y + 2 + TitleH + TabH),
        Color = T.TabBorder, Thickness = 1, Visible = true, ZIndex = z+2,
    })
    -- Content area Y start
    self2.ContentY = p.Y + 2 + TitleH + TabH + 2
    self2.ContentH = s.Y - (2 + TitleH + TabH + 2)

    table.insert(Library.Windows, self2)
    return self2
end

function Window:_UpdatePositions()
    local p = self.Position
    local s = self.Size
    local d = self.Drawings
    d.Bg.Position = p; d.Bg.Size = s
    d.Border.Position = p; d.Border.Size = s
    d.AccentTop.From = p; d.AccentTop.To = Vector2.new(p.X + s.X, p.Y)
    d.TitleBg.Position = Vector2.new(p.X, p.Y+2)
    d.TitleText.Position = Vector2.new(p.X+8, p.Y+4)
    d.TabBarBg.Position = Vector2.new(p.X, p.Y+2+TitleH)
    d.TabBarLine.From = Vector2.new(p.X, p.Y+2+TitleH+TabH)
    d.TabBarLine.To = Vector2.new(p.X+s.X, p.Y+2+TitleH+TabH)
    self.ContentY = p.Y + 2 + TitleH + TabH + 2

    -- Tabs
    local tx = p.X + 4
    for _, tab in ipairs(self.Tabs) do
        tab:_UpdatePosition(tx)
        tx = tx + tab._width + 4
    end
    if self.ActiveTab then
        self.ActiveTab:_UpdateElementPositions()
    end
end

function Window:SetVisible(vis)
    self.Visible = vis
    for _, dr in pairs(self.Drawings) do dr.Visible = vis end
    for _, tab in ipairs(self.Tabs) do tab:_SetAllVisible(vis and tab == self.ActiveTab) end
    -- Tab labels always match window visibility
    for _, tab in ipairs(self.Tabs) do
        tab.Drawings.Label.Visible = vis
        if tab.Drawings.Underline then tab.Drawings.Underline.Visible = vis and tab == self.ActiveTab end
    end
end

function Window:_HandleDrag(pos, phase)
    if IsMobile and Library.MobileLocked then return false end
    if phase == "began" then
        local tp = self.Drawings.TitleBg.Position
        local ts = Vector2.new(self.Size.X, TitleH)
        if inBounds(pos, tp, ts) then
            self.Dragging = true
            self.DragOffset = pos - self.Position
            return true
        end
    elseif phase == "changed" and self.Dragging then
        self.Position = pos - self.DragOffset
        self:_UpdatePositions()
        return true
    elseif phase == "ended" then
        self.Dragging = false
    end
    return false
end

-- ══════════════════════════════════════════
--  TAB
-- ══════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name)
    local tab = setmetatable({}, Tab)
    tab.Name = name or "Tab"
    tab.Window = self
    tab.Sections = {}
    tab.Active = false
    tab.Drawings = {}
    tab._width = 0

    local z = self._zBase + 5
    -- Measure text
    local tmp = new("Text", {
        Text = name, Size = FontSize, Font = Drawing.Fonts.UI,
        Visible = false,
    })
    tab._width = math.floor(tmp.TextBounds.X + 16 * Scale)
    tmp:Remove()

    -- Tab label
    local tx = self.Position.X + 4
    for _, t in ipairs(self.Tabs) do tx = tx + t._width + 4 end
    local ty = self.Position.Y + 2 + TitleH

    tab.Drawings.Label = new("Text", {
        Text = name, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.DimText, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(tx + math.floor(tab._width/2), ty + 3),
        Center = true, Visible = self.Visible, ZIndex = z+2,
    })
    tab.Drawings.Underline = new("Line", {
        From = Vector2.new(tx, ty + TabH - 2),
        To = Vector2.new(tx + tab._width, ty + TabH - 2),
        Color = T.Accent, Thickness = 2,
        Visible = false, ZIndex = z+3,
    })
    tab._posX = tx
    tab._posY = ty

    table.insert(self.Tabs, tab)

    -- Activate first tab
    if #self.Tabs == 1 then
        self.ActiveTab = tab
        tab:_Activate()
    end

    return tab
end

function Tab:_Activate()
    self.Active = true
    self.Drawings.Label.Color = T.Text
    self.Drawings.Underline.Visible = self.Window.Visible
    for _, sect in ipairs(self.Sections) do sect:_SetVisible(self.Window.Visible) end
end

function Tab:_Deactivate()
    self.Active = false
    self.Drawings.Label.Color = T.DimText
    self.Drawings.Underline.Visible = false
    for _, sect in ipairs(self.Sections) do sect:_SetVisible(false) end
end

function Tab:_SetAllVisible(vis)
    for _, sect in ipairs(self.Sections) do sect:_SetVisible(vis) end
end

function Tab:_UpdatePosition(tx)
    local ty = self.Window.Position.Y + 2 + TitleH
    self._posX = tx; self._posY = ty
    self.Drawings.Label.Position = Vector2.new(tx + math.floor(self._width/2), ty + 3)
    self.Drawings.Underline.From = Vector2.new(tx, ty + TabH - 2)
    self.Drawings.Underline.To = Vector2.new(tx + self._width, ty + TabH - 2)
end

function Tab:_UpdateElementPositions()
    for _, sect in ipairs(self.Sections) do
        sect:_Reflow()
    end
end

function Tab:_HandleClick(pos)
    if inBounds(pos, Vector2.new(self._posX, self._posY), Vector2.new(self._width, TabH)) then
        if self.Window.ActiveTab ~= self then
            if self.Window.ActiveTab then self.Window.ActiveTab:_Deactivate() end
            self.Window.ActiveTab = self
            self:_Activate()
        end
        return true
    end
    return false
end

-- ══════════════════════════════════════════
--  SECTION / GROUPBOX
-- ══════════════════════════════════════════
local Section = {}
Section.__index = Section

function Tab:CreateSection(options)
    options = options or {}
    local sect = setmetatable({}, Section)
    sect.Name = options.Name or "Section"
    sect.Side = options.Side or "Left"
    sect.Tab = self
    sect.Window = self.Window
    sect.Elements = {}
    sect.Drawings = {}
    sect.ScrollOffset = 0
    sect.ContentHeight = 0

    local win = self.Window
    local colW = math.floor((win.Size.X - Pad * 3) / 2)
    local px
    if sect.Side == "Left" then
        px = win.Position.X + Pad
    else
        px = win.Position.X + Pad * 2 + colW
    end
    local py = win.ContentY + Pad

    -- Stack below existing sections on same side
    for _, s in ipairs(self.Sections) do
        if s.Side == sect.Side then
            py = py + s._totalH + Pad
        end
    end

    sect._x = px; sect._y = py
    sect._w = colW; sect._h = math.floor(win.ContentH - Pad * 2)
    sect._totalH = 0

    local z = win._zBase + 10

    -- Section border
    sect.Drawings.Border = new("Square", {
        Position = Vector2.new(px, py),
        Size = Vector2.new(colW, SectHeaderH),
        Color = T.SectionBorder, Filled = false, Thickness = 1,
        Visible = self.Active, ZIndex = z,
    })
    -- Header text
    sect.Drawings.Header = new("Text", {
        Text = sect.Name, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(px + 6, py + 2),
        Visible = self.Active, ZIndex = z+1,
    })

    sect._elemStartY = py + SectHeaderH + 2
    sect._nextY = sect._elemStartY

    table.insert(self.Sections, sect)
    return sect
end

function Section:_SetVisible(vis)
    for _, d in pairs(self.Drawings) do d.Visible = vis end
    for _, elem in ipairs(self.Elements) do
        elem:_SetVisible(vis)
    end
end

function Section:_Reflow()
    local win = self.Window
    local colW = math.floor((win.Size.X - Pad*3)/2)
    local px
    if self.Side == "Left" then px = win.Position.X + Pad
    else px = win.Position.X + Pad*2 + colW end

    local py = win.ContentY + Pad
    for _, s in ipairs(self.Tab.Sections) do
        if s == self then break end
        if s.Side == self.Side then py = py + s._totalH + Pad end
    end

    self._x = px; self._y = py; self._w = colW
    self._elemStartY = py + SectHeaderH + 2
    self.Drawings.Border.Position = Vector2.new(px, py)
    self.Drawings.Border.Size = Vector2.new(colW, self._totalH)
    self.Drawings.Header.Position = Vector2.new(px+6, py+2)

    local ey = self._elemStartY
    for _, elem in ipairs(self.Elements) do
        elem:_SetPosition(px + 4, ey)
        ey = ey + elem._height + 3
    end
end

function Section:_RecalcHeight()
    local h = SectHeaderH + 2
    for _, elem in ipairs(self.Elements) do
        h = h + elem._height + 3
    end
    h = h + 4
    self._totalH = h
    self.Drawings.Border.Size = Vector2.new(self._w, h)
end

-- ══════════════════════════════════════════
--  ELEMENT BASE
-- ══════════════════════════════════════════
local Element = {}
Element.__index = Element

function Element:_SetVisible(vis)
    for _, d in pairs(self.Drawings) do
        if type(d) == "table" and d.Remove then d.Visible = vis
        elseif type(d) == "table" then
            for _, dd in pairs(d) do if type(dd)=="table" and dd.Remove then dd.Visible = vis end end
        end
    end
end

-- ══════════════════════════════════════════
--  TOGGLE
-- ══════════════════════════════════════════
function Section:CreateToggle(options)
    options = options or {}
    local elem = setmetatable({}, {__index = Element})
    elem.Type = "Toggle"
    elem.Name = options.Name or "Toggle"
    elem.Value = options.Default or false
    elem.Callback = options.Callback or function() end
    elem.Flag = options.Flag
    elem.Section = self
    elem.Drawings = {}
    elem._height = ElemH

    local z = self.Window._zBase + 20
    local x = self._x + 4
    local y = self._nextY
    local w = self._w - 8

    -- Label
    elem.Drawings.Label = new("Text", {
        Text = elem.Name, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x, y + 1), Visible = self.Tab.Active, ZIndex = z+1,
    })
    -- Toggle box
    elem.Drawings.Box = new("Square", {
        Position = Vector2.new(x + w - ToggleSize - 2, y + 1),
        Size = Vector2.new(ToggleSize, ToggleSize),
        Color = elem.Value and T.ToggleOn or T.ToggleOff,
        Filled = true, Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.BoxBorder = new("Square", {
        Position = Vector2.new(x + w - ToggleSize - 2, y + 1),
        Size = Vector2.new(ToggleSize, ToggleSize),
        Color = T.ElementBorder, Filled = false, Thickness = 1,
        Visible = self.Tab.Active, ZIndex = z+2,
    })

    elem._SetPosition = function(self2, nx, ny)
        self2.Drawings.Label.Position = Vector2.new(nx, ny+1)
        self2.Drawings.Box.Position = Vector2.new(nx + w - ToggleSize - 2, ny+1)
        self2.Drawings.BoxBorder.Position = Vector2.new(nx + w - ToggleSize - 2, ny+1)
        self2._x = nx; self2._y = ny
    end
    elem._x = x; elem._y = y

    elem.HandleClick = function(self2, pos)
        if inBounds(pos, Vector2.new(self2._x, self2._y), Vector2.new(w, ElemH)) then
            self2.Value = not self2.Value
            self2.Drawings.Box.Color = self2.Value and T.ToggleOn or T.ToggleOff
            if self2.Flag then Library.Flags[self2.Flag] = self2.Value end
            self2.Callback(self2.Value)
            return true
        end
        return false
    end

    self._nextY = self._nextY + ElemH + 3
    table.insert(self.Elements, elem)
    self:_RecalcHeight()
    if elem.Flag then Library.Flags[elem.Flag] = elem.Value end
    return elem
end

-- ══════════════════════════════════════════
--  SLIDER
-- ══════════════════════════════════════════
function Section:CreateSlider(options)
    options = options or {}
    local elem = setmetatable({}, {__index = Element})
    elem.Type = "Slider"
    elem.Name = options.Name or "Slider"
    elem.Min = options.Min or 0
    elem.Max = options.Max or 100
    elem.Value = options.Default or elem.Min
    elem.Increment = options.Increment or 1
    elem.Suffix = options.Suffix or ""
    elem.Callback = options.Callback or function() end
    elem.Flag = options.Flag
    elem.Section = self
    elem.Drawings = {}
    elem._height = ElemH + SliderH + 4
    elem._dragging = false

    local z = self.Window._zBase + 20
    local x = self._x + 4
    local y = self._nextY
    local w = self._w - 8
    local fillW = math.floor(((elem.Value - elem.Min) / (elem.Max - elem.Min)) * (w - 4))

    elem.Drawings.Label = new("Text", {
        Text = elem.Name .. ": " .. tostring(elem.Value) .. elem.Suffix,
        Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x, y), Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.Track = new("Square", {
        Position = Vector2.new(x + 2, y + ElemH + 2),
        Size = Vector2.new(w - 4, SliderH),
        Color = T.ElementBackground, Filled = true,
        Visible = self.Tab.Active, ZIndex = z,
    })
    elem.Drawings.TrackBorder = new("Square", {
        Position = Vector2.new(x + 2, y + ElemH + 2),
        Size = Vector2.new(w - 4, SliderH),
        Color = T.ElementBorder, Filled = false, Thickness = 1,
        Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.Fill = new("Square", {
        Position = Vector2.new(x + 2, y + ElemH + 2),
        Size = Vector2.new(math.max(fillW, 1), SliderH),
        Color = T.SliderFill, Filled = true,
        Visible = self.Tab.Active, ZIndex = z+1,
    })

    elem._trackX = x + 2
    elem._trackY = y + ElemH + 2
    elem._trackW = w - 4

    elem._SetPosition = function(self2, nx, ny)
        self2.Drawings.Label.Position = Vector2.new(nx, ny)
        self2.Drawings.Track.Position = Vector2.new(nx+2, ny+ElemH+2)
        self2.Drawings.TrackBorder.Position = Vector2.new(nx+2, ny+ElemH+2)
        self2.Drawings.Fill.Position = Vector2.new(nx+2, ny+ElemH+2)
        self2._trackX = nx+2; self2._trackY = ny+ElemH+2
        self2._x = nx; self2._y = ny
    end
    elem._x = x; elem._y = y

    elem._UpdateValue = function(self2, pos)
        local rel = clamp((pos.X - self2._trackX) / self2._trackW, 0, 1)
        local raw = self2.Min + rel * (self2.Max - self2.Min)
        raw = math.floor(raw / self2.Increment + 0.5) * self2.Increment
        self2.Value = clamp(raw, self2.Min, self2.Max)
        local fillW2 = math.floor(((self2.Value - self2.Min)/(self2.Max - self2.Min)) * self2._trackW)
        self2.Drawings.Fill.Size = Vector2.new(math.max(fillW2, 1), SliderH)
        self2.Drawings.Label.Text = self2.Name .. ": " .. tostring(self2.Value) .. self2.Suffix
        if self2.Flag then Library.Flags[self2.Flag] = self2.Value end
        self2.Callback(self2.Value)
    end

    elem.HandleClick = function(self2, pos)
        if inBounds(pos, Vector2.new(self2._trackX, self2._trackY), Vector2.new(self2._trackW, SliderH)) then
            self2._dragging = true
            self2:_UpdateValue(pos)
            return true
        end
        return false
    end

    self._nextY = self._nextY + elem._height + 3
    table.insert(self.Elements, elem)
    self:_RecalcHeight()
    if elem.Flag then Library.Flags[elem.Flag] = elem.Value end
    return elem
end

-- ══════════════════════════════════════════
--  DROPDOWN
-- ══════════════════════════════════════════
function Section:CreateDropdown(options)
    options = options or {}
    local elem = setmetatable({}, {__index = Element})
    elem.Type = "Dropdown"
    elem.Name = options.Name or "Dropdown"
    elem.Options = options.Options or {}
    elem.Value = options.Default or (elem.Options[1] or "")
    elem.Callback = options.Callback or function() end
    elem.Flag = options.Flag
    elem.Section = self
    elem.Drawings = {}
    elem._height = ElemH + ElemH + 4
    elem._open = false
    elem._optDrawings = {}

    local z = self.Window._zBase + 20
    local x = self._x + 4
    local y = self._nextY
    local w = self._w - 8

    elem.Drawings.Label = new("Text", {
        Text = elem.Name, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x, y), Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.Box = new("Square", {
        Position = Vector2.new(x, y + ElemH + 2),
        Size = Vector2.new(w, ElemH),
        Color = T.ElementBackground, Filled = true,
        Visible = self.Tab.Active, ZIndex = z,
    })
    elem.Drawings.BoxBorder = new("Square", {
        Position = Vector2.new(x, y + ElemH + 2),
        Size = Vector2.new(w, ElemH),
        Color = T.ElementBorder, Filled = false, Thickness = 1,
        Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.Selected = new("Text", {
        Text = tostring(elem.Value), Size = FontSizeSm, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x + 4, y + ElemH + 4),
        Visible = self.Tab.Active, ZIndex = z+2,
    })
    -- Arrow
    elem.Drawings.Arrow = new("Triangle", {
        PointA = Vector2.new(x + w - 14, y + ElemH + 6),
        PointB = Vector2.new(x + w - 6, y + ElemH + 6),
        PointC = Vector2.new(x + w - 10, y + ElemH + 14),
        Color = T.DimText, Filled = true,
        Visible = self.Tab.Active, ZIndex = z+2,
    })

    elem._boxX = x; elem._boxY = y + ElemH + 2
    elem._boxW = w

    elem._SetPosition = function(self2, nx, ny)
        self2.Drawings.Label.Position = Vector2.new(nx, ny)
        self2.Drawings.Box.Position = Vector2.new(nx, ny+ElemH+2)
        self2.Drawings.BoxBorder.Position = Vector2.new(nx, ny+ElemH+2)
        self2.Drawings.Selected.Position = Vector2.new(nx+4, ny+ElemH+4)
        self2.Drawings.Arrow.PointA = Vector2.new(nx+w-14, ny+ElemH+6)
        self2.Drawings.Arrow.PointB = Vector2.new(nx+w-6, ny+ElemH+6)
        self2.Drawings.Arrow.PointC = Vector2.new(nx+w-10, ny+ElemH+14)
        self2._boxX = nx; self2._boxY = ny+ElemH+2
        self2._x = nx; self2._y = ny
    end
    elem._x = x; elem._y = y

    elem._CloseDropdown = function(self2)
        self2._open = false
        for _, od in ipairs(self2._optDrawings) do
            od.Bg:Remove(); od.Label:Remove()
        end
        self2._optDrawings = {}
        if Library.OpenDropdown == self2 then Library.OpenDropdown = nil end
    end

    elem._OpenDropdown = function(self2)
        if Library.OpenDropdown and Library.OpenDropdown ~= self2 then
            Library.OpenDropdown:_CloseDropdown()
        end
        self2._open = true
        Library.OpenDropdown = self2
        local oz = 55000
        for i, opt in ipairs(self2.Options) do
            local oy = self2._boxY + ElemH + (i-1) * ElemH
            local od = {}
            od.Bg = new("Square", {
                Position = Vector2.new(self2._boxX, oy),
                Size = Vector2.new(self2._boxW, ElemH),
                Color = T.DropdownBg, Filled = true,
                Visible = true, ZIndex = oz,
            })
            od.Label = new("Text", {
                Text = tostring(opt), Size = FontSizeSm, Font = Drawing.Fonts.UI,
                Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
                Position = Vector2.new(self2._boxX + 4, oy + 2),
                Visible = true, ZIndex = oz+1,
            })
            od._value = opt
            table.insert(self2._optDrawings, od)
        end
    end

    elem.HandleClick = function(self2, pos)
        -- Check option clicks first
        if self2._open then
            for _, od in ipairs(self2._optDrawings) do
                if inBounds(pos, od.Bg.Position, od.Bg.Size) then
                    self2.Value = od._value
                    self2.Drawings.Selected.Text = tostring(od._value)
                    if self2.Flag then Library.Flags[self2.Flag] = self2.Value end
                    self2.Callback(self2.Value)
                    self2:_CloseDropdown()
                    return true
                end
            end
            self2:_CloseDropdown()
            return true
        end
        -- Toggle open
        if inBounds(pos, Vector2.new(self2._boxX, self2._boxY), Vector2.new(self2._boxW, ElemH)) then
            self2:_OpenDropdown()
            return true
        end
        return false
    end

    self._nextY = self._nextY + elem._height + 3
    table.insert(self.Elements, elem)
    self:_RecalcHeight()
    if elem.Flag then Library.Flags[elem.Flag] = elem.Value end
    return elem
end

-- ══════════════════════════════════════════
--  BUTTON
-- ══════════════════════════════════════════
function Section:CreateButton(options)
    options = options or {}
    local elem = setmetatable({}, {__index = Element})
    elem.Type = "Button"
    elem.Name = options.Name or "Button"
    elem.Callback = options.Callback or function() end
    elem.Section = self
    elem.Drawings = {}
    elem._height = BtnH

    local z = self.Window._zBase + 20
    local x = self._x + 4
    local y = self._nextY
    local w = self._w - 8

    elem.Drawings.Bg = new("Square", {
        Position = Vector2.new(x, y),
        Size = Vector2.new(w, BtnH),
        Color = T.ElementBackground, Filled = true,
        Visible = self.Tab.Active, ZIndex = z,
    })
    elem.Drawings.Border = new("Square", {
        Position = Vector2.new(x, y),
        Size = Vector2.new(w, BtnH),
        Color = T.ElementBorder, Filled = false, Thickness = 1,
        Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.Label = new("Text", {
        Text = elem.Name, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x + math.floor(w/2), y + 3),
        Center = true, Visible = self.Tab.Active, ZIndex = z+2,
    })

    elem._SetPosition = function(self2, nx, ny)
        self2.Drawings.Bg.Position = Vector2.new(nx, ny)
        self2.Drawings.Border.Position = Vector2.new(nx, ny)
        self2.Drawings.Label.Position = Vector2.new(nx + math.floor(w/2), ny+3)
        self2._x = nx; self2._y = ny
    end
    elem._x = x; elem._y = y

    elem.HandleClick = function(self2, pos)
        if inBounds(pos, Vector2.new(self2._x, self2._y), Vector2.new(w, BtnH)) then
            -- Flash effect
            self2.Drawings.Bg.Color = T.Accent
            task.delay(0.15, function()
                if self2.Drawings.Bg then self2.Drawings.Bg.Color = T.ElementBackground end
            end)
            self2.Callback()
            return true
        end
        return false
    end

    self._nextY = self._nextY + BtnH + 3
    table.insert(self.Elements, elem)
    self:_RecalcHeight()
    return elem
end

-- ══════════════════════════════════════════
--  LABEL
-- ══════════════════════════════════════════
function Section:CreateLabel(text)
    local elem = setmetatable({}, {__index = Element})
    elem.Type = "Label"
    elem.Drawings = {}
    elem._height = math.floor(FontSize + 4)

    local z = self.Window._zBase + 20
    local x = self._x + 4
    local y = self._nextY

    elem.Drawings.Text = new("Text", {
        Text = text or "", Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.DimText, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x, y), Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem._SetPosition = function(self2, nx, ny)
        self2.Drawings.Text.Position = Vector2.new(nx, ny)
        self2._x = nx; self2._y = ny
    end
    elem._x = x; elem._y = y
    elem.HandleClick = function() return false end

    self._nextY = self._nextY + elem._height + 3
    table.insert(self.Elements, elem)
    self:_RecalcHeight()
    return elem
end

-- ══════════════════════════════════════════
--  KEYBIND
-- ══════════════════════════════════════════
function Section:CreateKeybind(options)
    options = options or {}
    local elem = setmetatable({}, {__index = Element})
    elem.Type = "Keybind"
    elem.Name = options.Name or "Keybind"
    elem.Value = options.Default or Enum.KeyCode.Unknown
    elem.Callback = options.Callback or function() end
    elem.Flag = options.Flag
    elem.Section = self
    elem.Drawings = {}
    elem._height = ElemH
    elem._listening = false

    local z = self.Window._zBase + 20
    local x = self._x + 4
    local y = self._nextY
    local w = self._w - 8
    local kbW = math.floor(60 * Scale)

    elem.Drawings.Label = new("Text", {
        Text = elem.Name, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x, y+1), Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.KeyBox = new("Square", {
        Position = Vector2.new(x + w - kbW, y),
        Size = Vector2.new(kbW, ElemH),
        Color = T.ElementBackground, Filled = true,
        Visible = self.Tab.Active, ZIndex = z,
    })
    elem.Drawings.KeyBorder = new("Square", {
        Position = Vector2.new(x + w - kbW, y),
        Size = Vector2.new(kbW, ElemH),
        Color = T.ElementBorder, Filled = false, Thickness = 1,
        Visible = self.Tab.Active, ZIndex = z+1,
    })
    local keyName = elem.Value == Enum.KeyCode.Unknown and "None" or elem.Value.Name
    elem.Drawings.KeyText = new("Text", {
        Text = keyName, Size = FontSizeSm, Font = Drawing.Fonts.UI,
        Color = T.DimText, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x + w - kbW + math.floor(kbW/2), y+3),
        Center = true, Visible = self.Tab.Active, ZIndex = z+2,
    })

    elem._SetPosition = function(self2, nx, ny)
        self2.Drawings.Label.Position = Vector2.new(nx, ny+1)
        self2.Drawings.KeyBox.Position = Vector2.new(nx+w-kbW, ny)
        self2.Drawings.KeyBorder.Position = Vector2.new(nx+w-kbW, ny)
        self2.Drawings.KeyText.Position = Vector2.new(nx+w-kbW+math.floor(kbW/2), ny+3)
        self2._x = nx; self2._y = ny
    end
    elem._x = x; elem._y = y

    elem.HandleClick = function(self2, pos)
        if inBounds(pos, Vector2.new(self2._x + w - kbW, self2._y), Vector2.new(kbW, ElemH)) then
            self2._listening = true
            self2.Drawings.KeyText.Text = "..."
            self2.Drawings.KeyText.Color = T.Accent
            return true
        end
        return false
    end

    elem._KeyPressed = function(self2, keyCode)
        if self2._listening then
            if keyCode == Enum.KeyCode.Escape then
                self2.Value = Enum.KeyCode.Unknown
                self2.Drawings.KeyText.Text = "None"
            else
                self2.Value = keyCode
                self2.Drawings.KeyText.Text = keyCode.Name
            end
            self2.Drawings.KeyText.Color = T.DimText
            self2._listening = false
            if self2.Flag then Library.Flags[self2.Flag] = self2.Value end
            self2.Callback(self2.Value)
            return true
        end
        return false
    end

    self._nextY = self._nextY + ElemH + 3
    table.insert(self.Elements, elem)
    self:_RecalcHeight()
    if elem.Flag then Library.Flags[elem.Flag] = elem.Value end
    return elem
end

-- ══════════════════════════════════════════
--  COLOR PICKER (mini)
-- ══════════════════════════════════════════
function Section:CreateColorPicker(options)
    options = options or {}
    local elem = setmetatable({}, {__index = Element})
    elem.Type = "ColorPicker"
    elem.Name = options.Name or "Color"
    elem.Value = options.Default or Color3.fromRGB(120, 80, 200)
    elem.Callback = options.Callback or function() end
    elem.Flag = options.Flag
    elem.Section = self
    elem.Drawings = {}
    elem._height = ElemH

    local z = self.Window._zBase + 20
    local x = self._x + 4
    local y = self._nextY
    local w = self._w - 8
    local cpSz = math.floor(14 * Scale)

    elem.Drawings.Label = new("Text", {
        Text = elem.Name, Size = FontSize, Font = Drawing.Fonts.UI,
        Color = T.Text, Outline = true, OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(x, y+1), Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.ColorBox = new("Square", {
        Position = Vector2.new(x + w - cpSz - 2, y + 1),
        Size = Vector2.new(cpSz, cpSz),
        Color = elem.Value, Filled = true,
        Visible = self.Tab.Active, ZIndex = z+1,
    })
    elem.Drawings.ColorBorder = new("Square", {
        Position = Vector2.new(x + w - cpSz - 2, y + 1),
        Size = Vector2.new(cpSz, cpSz),
        Color = T.ElementBorder, Filled = false, Thickness = 1,
        Visible = self.Tab.Active, ZIndex = z+2,
    })

    elem._SetPosition = function(self2, nx, ny)
        self2.Drawings.Label.Position = Vector2.new(nx, ny+1)
        self2.Drawings.ColorBox.Position = Vector2.new(nx+w-cpSz-2, ny+1)
        self2.Drawings.ColorBorder.Position = Vector2.new(nx+w-cpSz-2, ny+1)
        self2._x = nx; self2._y = ny
    end
    elem._x = x; elem._y = y
    elem.HandleClick = function() return false end

    elem.SetColor = function(self2, color)
        self2.Value = color
        self2.Drawings.ColorBox.Color = color
        if self2.Flag then Library.Flags[self2.Flag] = self2.Value end
        self2.Callback(color)
    end

    self._nextY = self._nextY + ElemH + 3
    table.insert(self.Elements, elem)
    self:_RecalcHeight()
    if elem.Flag then Library.Flags[elem.Flag] = elem.Value end
    return elem
end

-- ══════════════════════════════════════════
--  INPUT HANDLING
-- ══════════════════════════════════════════
local activeSlider = nil

local function handleInputBegan(input)
    local pos
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        pos = Vector2.new(input.Position.X, input.Position.Y)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        pos = Vector2.new(input.Position.X, input.Position.Y)
    else
        -- Keyboard for keybinds
        if input.UserInputType == Enum.UserInputType.Keyboard then
            -- Toggle UI with RightControl
            if input.KeyCode == Enum.KeyCode.RightControl then
                Library.Toggled = not Library.Toggled
                for _, win in ipairs(Library.Windows) do win:SetVisible(Library.Toggled) end
                return
            end
            -- Keybind listening
            for _, win in ipairs(Library.Windows) do
                if win.ActiveTab then
                    for _, sect in ipairs(win.ActiveTab.Sections) do
                        for _, elem in ipairs(sect.Elements) do
                            if elem.Type == "Keybind" and elem._listening then
                                elem:_KeyPressed(input.KeyCode)
                                return
                            end
                        end
                    end
                end
            end
        end
        return
    end

    Mouse.Position = pos
    Mouse.Down = true

    -- Mobile buttons
    if Library:_HandleMobileButtons(pos) then return end

    -- Close open dropdown if clicking outside
    if Library.OpenDropdown then
        local dd = Library.OpenDropdown
        if dd:HandleClick(pos) then return end
        dd:_CloseDropdown()
    end

    -- Process windows (reverse order for top-most first)
    for i = #Library.Windows, 1, -1 do
        local win = Library.Windows[i]
        if not win.Visible then continue end

        -- Drag?
        if win:_HandleDrag(pos, "began") then return end

        -- Tab click
        for _, tab in ipairs(win.Tabs) do
            if tab:_HandleClick(pos) then return end
        end

        -- Element click
        if win.ActiveTab then
            for _, sect in ipairs(win.ActiveTab.Sections) do
                for _, elem in ipairs(sect.Elements) do
                    if elem.HandleClick and elem:HandleClick(pos) then
                        if elem.Type == "Slider" and elem._dragging then
                            activeSlider = elem
                        end
                        return
                    end
                end
            end
        end
    end
end

local function handleInputChanged(input)
    local pos
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        pos = Vector2.new(input.Position.X, input.Position.Y)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        pos = Vector2.new(input.Position.X, input.Position.Y)
    else
        return
    end
    Mouse.Position = pos

    -- Slider drag
    if activeSlider then
        activeSlider:_UpdateValue(pos)
        return
    end

    -- Window drag
    for _, win in ipairs(Library.Windows) do
        if win.Dragging then
            win:_HandleDrag(pos, "changed")
            return
        end
    end
end

local function handleInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        Mouse.Down = false
        activeSlider = nil
        for _, win in ipairs(Library.Windows) do
            win:_HandleDrag(Mouse.Position, "ended")
        end
    end
end

table.insert(Connections, UIS.InputBegan:Connect(handleInputBegan))
table.insert(Connections, UIS.InputChanged:Connect(handleInputChanged))
table.insert(Connections, UIS.InputEnded:Connect(handleInputEnded))

-- ── Heartbeat for notifications ──
table.insert(Connections, RS.Heartbeat:Connect(function()
    Library:_TickNotifications()
end))

-- ══════════════════════════════════════════
--  CLEANUP
-- ══════════════════════════════════════════
function Library:Destroy()
    for _, c in ipairs(Connections) do c:Disconnect() end
    Connections = {}
    for _, d in ipairs(AllDrawings) do
        pcall(function() d:Remove() end)
    end
    AllDrawings = {}
    Library.Windows = {}
    Library.Notifications = {}
end

return Library
