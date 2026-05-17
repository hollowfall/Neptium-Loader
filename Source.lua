local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local TargetGui = (gethui and gethui()) or CoreGui

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 50)
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 5)
    c.Parent = parent
    return c
end

function Library:CreateWindow(config)
    config = config or {}
    local title       = config.Title or "Neptium"
    local subtitle    = config.Subtitle or "v2.1"
    local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift

    local Win = {}
    local minimized = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Neptium_" .. math.random(1000, 9999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = TargetGui

    local Root = Instance.new("Frame")
    Root.Name = "Root"
    Root.Size = UDim2.new(0, 560, 0, 380)
    Root.Position = UDim2.new(0.5, -280, 0.5, -190)
    Root.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Root.BorderSizePixel = 0
    Root.ClipsDescendants = true
    Root.Parent = ScreenGui
    addCorner(Root, 8)
    addStroke(Root, Color3.fromRGB(40, 40, 40), 1)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 38)
    Topbar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Root

    local TopStroke = Instance.new("Frame")
    TopStroke.Size = UDim2.new(1, 0, 0, 1)
    TopStroke.Position = UDim2.new(0, 0, 1, -1)
    TopStroke.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    TopStroke.BorderSizePixel = 0
    TopStroke.Parent = Topbar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0.5, -100, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Parent = Topbar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 200, 1, 0)
    SubLabel.Position = UDim2.new(0.5, 106, 0, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Text = subtitle
    SubLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
    SubLabel.TextSize = 11
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Topbar

    local dotData = {
        { color = Color3.fromRGB(255, 95, 86),  hover = Color3.fromRGB(255, 130, 120), symbol = "✕" },
        { color = Color3.fromRGB(255, 189, 46),  hover = Color3.fromRGB(255, 210, 90),  symbol = "−" },
        { color = Color3.fromRGB(40, 201, 64),   hover = Color3.fromRGB(80, 230, 100),  symbol = "+" },
    }

    local dots = {}
    for i, d in ipairs(dotData) do
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 13, 0, 13)
        Dot.Position = UDim2.new(0, 10 + (i - 1) * 19, 0.5, -6)
        Dot.BackgroundColor3 = d.color
        Dot.BorderSizePixel = 0
        Dot.Parent = Topbar
        addCorner(Dot, 7)

        local Symbol = Instance.new("TextLabel")
        Symbol.Size = UDim2.new(1, 0, 1, 0)
        Symbol.BackgroundTransparency = 1
        Symbol.Font = Enum.Font.GothamBold
        Symbol.Text = d.symbol
        Symbol.TextColor3 = Color3.fromRGB(100, 40, 30)
        Symbol.TextSize = 8
        Symbol.TextTransparency = 1
        Symbol.Parent = Dot

        local DotBtn = Instance.new("TextButton")
        DotBtn.Size = UDim2.new(1, 0, 1, 0)
        DotBtn.BackgroundTransparency = 1
        DotBtn.Text = ""
        DotBtn.Parent = Dot

        dots[i] = { frame = Dot, symbol = Symbol, btn = DotBtn }
    end

    local function showDotSymbols(show)
        for _, d in ipairs(dots) do
            tween(d.symbol, { TextTransparency = show and 0 or 1 }, 0.1)
        end
    end

    Topbar.MouseEnter:Connect(function() showDotSymbols(true) end)
    Topbar.MouseLeave:Connect(function() showDotSymbols(false) end)

    local DockButton = Instance.new("TextButton")
    DockButton.Size = UDim2.new(0, 110, 0, 30)
    DockButton.Position = UDim2.new(0.5, -55, 1, -50)
    DockButton.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    DockButton.BorderSizePixel = 0
    DockButton.Font = Enum.Font.GothamBold
    DockButton.Text = title
    DockButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    DockButton.TextSize = 12
    DockButton.Visible = false
    DockButton.Parent = ScreenGui
    addCorner(DockButton, 8)
    addStroke(DockButton, Color3.fromRGB(50, 50, 50), 1)

    local function doMinimize()
        minimized = true
        local targetPos = DockButton.AbsolutePosition
        tween(Root, {
            Size = UDim2.new(0, 110, 0, 30),
            Position = UDim2.new(0, targetPos.X, 0, targetPos.Y),
            BackgroundTransparency = 0
        }, 0.28)
        task.delay(0.15, function()
            Root.Visible = false
            DockButton.Size = UDim2.new(0, 0, 0, 30)
            DockButton.BackgroundTransparency = 1
            DockButton.TextTransparency = 1
            DockButton.Visible = true
            tween(DockButton, {
                Size = UDim2.new(0, 110, 0, 30),
                BackgroundTransparency = 0,
                TextTransparency = 0
            }, 0.22)
        end)
    end

    local savedPos = Root.Position
    local savedSize = Root.Size

    local function doRestore()
        minimized = false
        tween(DockButton, {
            Size = UDim2.new(0, 0, 0, 30),
            BackgroundTransparency = 1,
            TextTransparency = 1
        }, 0.18)
        task.delay(0.18, function()
            DockButton.Visible = false
            Root.Size = UDim2.new(0, 560, 0, 30)
            Root.Position = savedPos
            Root.Visible = true
            tween(Root, {
                Size = savedSize,
                BackgroundTransparency = 0
            }, 0.26)
        end)
    end

    dots[1].btn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    dots[2].btn.MouseButton1Click:Connect(function()
        if minimized then
            doRestore()
        else
            savedPos = Root.Position
            savedSize = Root.Size
            doMinimize()
        end
    end)

    dots[3].btn.MouseButton1Click:Connect(function()
        print("[Neptium] Maximize placeholder")
    end)

    DockButton.MouseButton1Click:Connect(function()
        doRestore()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == minimizeKey then
            if minimized then
                doRestore()
            else
                savedPos = Root.Position
                savedSize = Root.Size
                doMinimize()
            end
        end
    end)

    local dragging, dragStart, startPos, dragInput
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 120, 1, -38)
    Sidebar.Position = UDim2.new(0, 0, 0, 38)
    Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Root

    local SideStroke = Instance.new("Frame")
    SideStroke.Size = UDim2.new(0, 1, 1, 0)
    SideStroke.Position = UDim2.new(1, -1, 0, 0)
    SideStroke.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    SideStroke.BorderSizePixel = 0
    SideStroke.Parent = Sidebar

    local SideList = Instance.new("UIListLayout")
    SideList.SortOrder = Enum.SortOrder.LayoutOrder
    SideList.Padding = UDim.new(0, 2)
    SideList.Parent = Sidebar

    local SidePad = Instance.new("UIPadding")
    SidePad.PaddingTop = UDim.new(0, 8)
    SidePad.PaddingLeft = UDim.new(0, 6)
    SidePad.PaddingRight = UDim.new(0, 6)
    SidePad.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -120, 1, -38)
    ContentArea.Position = UDim2.new(0, 120, 0, 38)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Root

    local activeTab = nil
    local tabButtons = {}

    function Win:CreateTab(tabName, icon)
        local Tab = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = Sidebar
        addCorner(TabBtn, 5)

        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 2, 0.6, 0)
        AccentBar.AnchorPoint = Vector2.new(0, 0.5)
        AccentBar.Position = UDim2.new(0, 0, 0.5, 0)
        AccentBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        AccentBar.BackgroundTransparency = 1
        AccentBar.BorderSizePixel = 0
        AccentBar.Parent = TabBtn
        addCorner(AccentBar, 2)

        local TabIcon = Instance.new("TextLabel")
        TabIcon.Size = UDim2.new(0, 18, 1, 0)
        TabIcon.Position = UDim2.new(0, 10, 0, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Text = icon or ""
        TabIcon.TextColor3 = Color3.fromRGB(100, 100, 100)
        TabIcon.Font = Enum.Font.GothamSemibold
        TabIcon.TextSize = 13
        TabIcon.Parent = TabBtn

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, icon and -34 or -14, 1, 0)
        TabLabel.Position = UDim2.new(0, icon and 32 or 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.Text = tabName
        TabLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        Page.Visible = false
        Page.Parent = ContentArea

        local PageList = Instance.new("UIListLayout")
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 6)
        PageList.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 10)
        PagePad.PaddingLeft = UDim.new(0, 10)
        PagePad.PaddingRight = UDim.new(0, 10)
        PagePad.PaddingBottom = UDim.new(0, 10)
        PagePad.Parent = Page

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end)

        local function setActive(state)
            if state then
                tween(TabBtn, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(22, 22, 22)})
                tween(TabLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)})
                tween(TabIcon, {TextColor3 = Color3.fromRGB(255, 255, 255)})
                tween(AccentBar, {BackgroundTransparency = 0})
                Page.Visible = true
            else
                tween(TabBtn, {BackgroundTransparency = 1})
                tween(TabLabel, {TextColor3 = Color3.fromRGB(100, 100, 100)})
                tween(TabIcon, {TextColor3 = Color3.fromRGB(100, 100, 100)})
                tween(AccentBar, {BackgroundTransparency = 1})
                Page.Visible = false
            end
        end

        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= Tab then
                tween(TabLabel, {TextColor3 = Color3.fromRGB(190, 190, 190)})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= Tab then
                tween(TabLabel, {TextColor3 = Color3.fromRGB(100, 100, 100)})
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if activeTab and activeTab ~= Tab then
                tabButtons[activeTab](false)
            end
            activeTab = Tab
            tabButtons[Tab](true)
        end)

        tabButtons[Tab] = setActive

        if not activeTab then
            activeTab = Tab
            setActive(true)
        end

        local function makeContainer(h)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1, 0, 0, h or 36)
            F.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            F.BorderSizePixel = 0
            F.Parent = Page
            addCorner(F, 5)
            addStroke(F, Color3.fromRGB(35, 35, 35), 1)
            return F
        end

        function Tab:CreateSeparator(text)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1, 0, 0, 18)
            F.BackgroundTransparency = 1
            F.Parent = Page

            if text and text ~= "" then
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(0, 0, 1, 0)
                Lbl.AutomaticSize = Enum.AutomaticSize.X
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.GothamBold
                Lbl.Text = text:upper()
                Lbl.TextColor3 = Color3.fromRGB(60, 60, 60)
                Lbl.TextSize = 10
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = F

                local Line = Instance.new("Frame")
                Line.AnchorPoint = Vector2.new(0, 0.5)
                Line.Position = UDim2.new(0, 0, 0.5, 0)
                Line.Size = UDim2.new(1, 0, 0, 1)
                Line.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Line.BorderSizePixel = 0
                Line.ZIndex = 0
                Line.Parent = F
            else
                local Line = Instance.new("Frame")
                Line.AnchorPoint = Vector2.new(0, 0.5)
                Line.Position = UDim2.new(0, 0, 0.5, 0)
                Line.Size = UDim2.new(1, 0, 0, 1)
                Line.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Line.BorderSizePixel = 0
                Line.Parent = F
            end
        end

        function Tab:CreateLabel(text)
            local F = makeContainer(30)
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1, -12, 1, 0)
            L.Position = UDim2.new(0, 12, 0, 0)
            L.BackgroundTransparency = 1
            L.Font = Enum.Font.Gotham
            L.Text = text or ""
            L.TextColor3 = Color3.fromRGB(130, 130, 130)
            L.TextSize = 12
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.Parent = F
            return {
                SetText = function(_, t) L.Text = t end
            }
        end

        function Tab:CreateButton(name, desc, callback)
            if type(desc) == "function" then callback = desc desc = nil end
            local F = makeContainer(desc and 48 or 36)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 0, 20)
            Label.Position = UDim2.new(0, 12, desc and 0.15 or 0, desc and 0 or 0)
            Label.AnchorPoint = desc and Vector2.new(0,0) or Vector2.new(0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = F

            if desc then
                Label.Position = UDim2.new(0, 12, 0, 10)
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -50, 0, 14)
                Desc.Position = UDim2.new(0, 12, 0, 26)
                Desc.BackgroundTransparency = 1
                Desc.Font = Enum.Font.Gotham
                Desc.Text = desc
                Desc.TextColor3 = Color3.fromRGB(80, 80, 80)
                Desc.TextSize = 11
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Parent = F
            end

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -38, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "›"
            Arrow.TextColor3 = Color3.fromRGB(60, 60, 60)
            Arrow.TextSize = 18
            Arrow.Parent = F

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = F

            Btn.MouseEnter:Connect(function()
                tween(F, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)})
                tween(Arrow, {TextColor3 = Color3.fromRGB(200, 200, 200)})
            end)
            Btn.MouseLeave:Connect(function()
                tween(F, {BackgroundColor3 = Color3.fromRGB(18, 18, 18)})
                tween(Arrow, {TextColor3 = Color3.fromRGB(60, 60, 60)})
            end)
            Btn.MouseButton1Click:Connect(function()
                tween(F, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                task.delay(0.12, function() tween(F, {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}) end)
                if callback then callback() end
            end)
        end

        function Tab:CreateToggle(name, desc, default, callback)
            if type(desc) == "boolean" then callback = default default = desc desc = nil end
            if type(desc) == "function" then callback = desc desc = nil default = false end
            local toggled = default or false

            local F = makeContainer(desc and 48 or 36)

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -60, 0, 20)
            NameLabel.Position = UDim2.new(0, 12, desc and 0 or 0, desc and 10 or 0)
            NameLabel.AnchorPoint = Vector2.new(0, desc and 0 or 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Font = Enum.Font.GothamSemibold
            NameLabel.Text = name
            NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            NameLabel.TextSize = 13
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = F

            if not desc then
                NameLabel.Size = UDim2.new(1, -60, 1, 0)
                NameLabel.Position = UDim2.new(0, 12, 0, 0)
            else
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -60, 0, 14)
                Desc.Position = UDim2.new(0, 12, 0, 26)
                Desc.BackgroundTransparency = 1
                Desc.Font = Enum.Font.Gotham
                Desc.Text = desc
                Desc.TextColor3 = Color3.fromRGB(80, 80, 80)
                Desc.TextSize = 11
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Parent = F
            end

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0, 36, 0, 18)
            Track.AnchorPoint = Vector2.new(1, 0.5)
            Track.Position = UDim2.new(1, -12, 0.5, 0)
            Track.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Track.BorderSizePixel = 0
            Track.Parent = F
            addCorner(Track, 9)
            addStroke(Track, Color3.fromRGB(55, 55, 55), 1)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12)
            Knob.AnchorPoint = Vector2.new(0, 0.5)
            Knob.Position = UDim2.new(0, 3, 0.5, 0)
            Knob.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Knob.BorderSizePixel = 0
            Knob.Parent = Track
            addCorner(Knob, 6)

            local function refreshVisual()
                if toggled then
                    tween(Track, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                    tween(Knob, {Position = UDim2.new(0, 21, 0.5, 0), BackgroundColor3 = Color3.fromRGB(10, 10, 10)})
                else
                    tween(Track, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)})
                    tween(Knob, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Color3.fromRGB(90, 90, 90)})
                end
            end

            refreshVisual()

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = F

            Btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                refreshVisual()
                if callback then callback(toggled) end
            end)

            return {
                Set = function(_, val)
                    toggled = val
                    refreshVisual()
                    if callback then callback(toggled) end
                end,
                Get = function() return toggled end,
            }
        end

        function Tab:CreateSlider(name, config2, callback)
            config2 = config2 or {}
            local min     = config2.Min or 0
            local max     = config2.Max or 100
            local default = config2.Default or min
            local suffix  = config2.Suffix or ""
            local step    = config2.Step or 1
            local value   = math.clamp(default, min, max)

            local F = makeContainer(52)

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -80, 0, 18)
            NameLabel.Position = UDim2.new(0, 12, 0, 8)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Font = Enum.Font.GothamSemibold
            NameLabel.Text = name
            NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            NameLabel.TextSize = 13
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = F

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 60, 0, 18)
            ValLabel.Position = UDim2.new(1, -72, 0, 8)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Font = Enum.Font.GothamSemibold
            ValLabel.Text = tostring(value) .. suffix
            ValLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            ValLabel.TextSize = 12
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = F

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -24, 0, 4)
            Track.Position = UDim2.new(0, 12, 0, 34)
            Track.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Track.BorderSizePixel = 0
            Track.Parent = F
            addCorner(Track, 2)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            addCorner(Fill, 2)

            local Handle = Instance.new("Frame")
            Handle.Size = UDim2.new(0, 10, 0, 10)
            Handle.AnchorPoint = Vector2.new(0.5, 0.5)
            Handle.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
            Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Handle.BorderSizePixel = 0
            Handle.Parent = Track
            addCorner(Handle, 5)

            local DragZone = Instance.new("TextButton")
            DragZone.Size = UDim2.new(1, 0, 0, 20)
            DragZone.Position = UDim2.new(0, 0, 0, -8)
            DragZone.BackgroundTransparency = 1
            DragZone.Text = ""
            DragZone.Parent = Track

            local draggingSlider = false

            local function updateValue(input)
                local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local raw = min + (max - min) * rel
                local stepped = math.floor(raw / step + 0.5) * step
                value = math.clamp(stepped, min, max)
                local pct = (value - min) / (max - min)
                tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                tween(Handle, {Position = UDim2.new(pct, 0, 0.5, 0)}, 0.05)
                ValLabel.Text = tostring(math.round(value * 100) / 100) .. suffix
                if callback then callback(value) end
            end

            DragZone.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    updateValue(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(input)
                end
            end)

            return {
                Set = function(_, v)
                    value = math.clamp(v, min, max)
                    local pct = (value - min) / (max - min)
                    tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                    tween(Handle, {Position = UDim2.new(pct, 0, 0.5, 0)}, 0.05)
                    ValLabel.Text = tostring(value) .. suffix
                end,
                Get = function() return value end,
            }
        end

        function Tab:CreateDropdown(name, options, default, callback)
            local selected = default or options[1] or "None"
            local open = false

            local Wrapper = Instance.new("Frame")
            Wrapper.Size = UDim2.new(1, 0, 0, 36)
            Wrapper.BackgroundTransparency = 1
            Wrapper.ClipsDescendants = false
            Wrapper.Parent = Page

            local F = Instance.new("Frame")
            F.Size = UDim2.new(1, 0, 0, 36)
            F.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            F.BorderSizePixel = 0
            F.ZIndex = 2
            F.Parent = Wrapper
            addCorner(F, 5)
            addStroke(F, Color3.fromRGB(35, 35, 35), 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 2
            Label.Parent = F

            local Selected = Instance.new("TextLabel")
            Selected.Size = UDim2.new(0.45, -30, 1, 0)
            Selected.Position = UDim2.new(0.55, 0, 0, 0)
            Selected.BackgroundTransparency = 1
            Selected.Font = Enum.Font.Gotham
            Selected.Text = selected
            Selected.TextColor3 = Color3.fromRGB(130, 130, 130)
            Selected.TextSize = 12
            Selected.TextXAlignment = Enum.TextXAlignment.Right
            Selected.ZIndex = 2
            Selected.Parent = F

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -26, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "⌄"
            Arrow.TextColor3 = Color3.fromRGB(80, 80, 80)
            Arrow.TextSize = 14
            Arrow.ZIndex = 2
            Arrow.Parent = F

            local DropList = Instance.new("Frame")
            DropList.Size = UDim2.new(1, 0, 0, 0)
            DropList.Position = UDim2.new(0, 0, 1, 4)
            DropList.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            DropList.BorderSizePixel = 0
            DropList.ClipsDescendants = true
            DropList.ZIndex = 10
            DropList.Visible = false
            DropList.Parent = Wrapper
            addCorner(DropList, 5)
            addStroke(DropList, Color3.fromRGB(40, 40, 40), 1)

            local DropScroll = Instance.new("ScrollingFrame")
            DropScroll.Size = UDim2.new(1, 0, 1, 0)
            DropScroll.BackgroundTransparency = 1
            DropScroll.BorderSizePixel = 0
            DropScroll.ScrollBarThickness = 2
            DropScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
            DropScroll.ZIndex = 10
            DropScroll.Parent = DropList

            local DropLayout = Instance.new("UIListLayout")
            DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropLayout.Parent = DropScroll

            local function buildOptions()
                for _, child in ipairs(DropScroll:GetChildren()) do
                    if not child:IsA("UIListLayout") then child:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local Opt = Instance.new("TextButton")
                    Opt.Size = UDim2.new(1, 0, 0, 30)
                    Opt.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                    Opt.BackgroundTransparency = opt == selected and 0 or 1
                    Opt.BorderSizePixel = 0
                    Opt.Font = Enum.Font.GothamSemibold
                    Opt.Text = "  " .. opt
                    Opt.TextColor3 = opt == selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
                    Opt.TextSize = 12
                    Opt.TextXAlignment = Enum.TextXAlignment.Left
                    Opt.ZIndex = 10
                    Opt.Parent = DropScroll

                    Opt.MouseEnter:Connect(function()
                        if opt ~= selected then tween(Opt, {TextColor3 = Color3.fromRGB(220, 220, 220)}) end
                    end)
                    Opt.MouseLeave:Connect(function()
                        if opt ~= selected then tween(Opt, {TextColor3 = Color3.fromRGB(150, 150, 150)}) end
                    end)
                    Opt.MouseButton1Click:Connect(function()
                        selected = opt
                        Selected.Text = opt
                        buildOptions()
                        open = false
                        tween(DropList, {Size = UDim2.new(1, 0, 0, 0)})
                        tween(Arrow, {Rotation = 0})
                        task.delay(0.2, function() DropList.Visible = false end)
                        if callback then callback(selected) end
                    end)
                end
                DropScroll.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)
            end

            buildOptions()

            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 1, 0)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = ""
            MainBtn.ZIndex = 3
            MainBtn.Parent = F

            MainBtn.MouseButton1Click:Connect(function()
                open = not open
                local count = math.min(#options, 5)
                if open then
                    DropList.Visible = true
                    DropList.Size = UDim2.new(1, 0, 0, 0)
                    tween(DropList, {Size = UDim2.new(1, 0, 0, count * 30)}, 0.2)
                    tween(Arrow, {Rotation = 180}, 0.2)
                    Wrapper.Size = UDim2.new(1, 0, 0, 36 + count * 30 + 8)
                else
                    tween(DropList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    tween(Arrow, {Rotation = 0}, 0.2)
                    task.delay(0.2, function() DropList.Visible = false end)
                    Wrapper.Size = UDim2.new(1, 0, 0, 36)
                end
            end)

            return {
                Set = function(_, v)
                    selected = v
                    Selected.Text = v
                    buildOptions()
                end,
                Get = function() return selected end,
                Refresh = function(_, newOptions)
                    options = newOptions
                    buildOptions()
                end
            }
        end

        function Tab:CreateInput(name, placeholder, callback)
            local F = makeContainer(36)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.4, 0, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = F

            local InputBG = Instance.new("Frame")
            InputBG.Size = UDim2.new(0.55, 0, 0, 24)
            InputBG.AnchorPoint = Vector2.new(1, 0.5)
            InputBG.Position = UDim2.new(1, -10, 0.5, 0)
            InputBG.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            InputBG.BorderSizePixel = 0
            InputBG.Parent = F
            addCorner(InputBG, 4)
            addStroke(InputBG, Color3.fromRGB(45, 45, 45), 1)

            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -10, 1, 0)
            Input.Position = UDim2.new(0, 8, 0, 0)
            Input.BackgroundTransparency = 1
            Input.Font = Enum.Font.Gotham
            Input.PlaceholderText = placeholder or "Enter value..."
            Input.PlaceholderColor3 = Color3.fromRGB(65, 65, 65)
            Input.Text = ""
            Input.TextColor3 = Color3.fromRGB(200, 200, 200)
            Input.TextSize = 12
            Input.TextXAlignment = Enum.TextXAlignment.Left
            Input.ClearTextOnFocus = false
            Input.Parent = InputBG

            Input.Focused:Connect(function()
                tween(InputBG, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
            end)
            Input.FocusLost:Connect(function(enter)
                tween(InputBG, {BackgroundColor3 = Color3.fromRGB(12, 12, 12)})
                if callback then callback(Input.Text, enter) end
            end)

            return {
                Get = function() return Input.Text end,
                Set = function(_, v) Input.Text = v end,
            }
        end

        return Tab
    end

    return Win
end

local UI = Library:CreateWindow({
    Title = "Neptium",
    Subtitle = "v2.1 loader",
    MinimizeKey = Enum.KeyCode.RightShift,
})

local CombatTab = UI:CreateTab("Combat", "⚔")

CombatTab:CreateToggle("Aim Assist", "Helps lock on to targets", false, function(v)
    print("Aim Assist:", v)
end)

CombatTab:CreateSlider("FOV Size", {
    Min = 10, Max = 500, Default = 120, Suffix = " px", Step = 5
}, function(v)
    print("FOV:", v)
end)

CombatTab:CreateToggle("Silent Aim", nil, false, function(v)
    print("Silent Aim:", v)
end)

CombatTab:CreateSeparator("PREDICTION")

CombatTab:CreateSlider("Smoothness", {
    Min = 0, Max = 100, Default = 50, Suffix = "%", Step = 1
}, function(v)
    print("Smoothness:", v)
end)

CombatTab:CreateDropdown("Hitbox", {"Head", "Torso", "Random"}, "Head", function(v)
    print("Hitbox:", v)
end)

local VisualTab = UI:CreateTab("Visual", "👁")

VisualTab:CreateToggle("ESP Boxes", nil, false, function(v) print("ESP:", v) end)
VisualTab:CreateToggle("Chams", "See through walls", false, function(v) print("Chams:", v) end)
VisualTab:CreateToggle("Tracer Lines", nil, false, function(v) print("Tracers:", v) end)
VisualTab:CreateSeparator("COLORS")
VisualTab:CreateLabel("→ Color pickers coming in v2.2")

local MiscTab = UI:CreateTab("Misc", "⚙")

MiscTab:CreateSlider("Walk Speed", {
    Min = 16, Max = 300, Default = 16, Suffix = " u/s", Step = 2
}, function(v)
    local p = game.Players.LocalPlayer
    if p.Character and p.Character:FindFirstChild("Humanoid") then
        p.Character.Humanoid.WalkSpeed = v
    end
end)

MiscTab:CreateToggle("Infinite Jump", nil, false, function(v)
    print("InfJump:", v)
end)

MiscTab:CreateInput("Custom Script", "Enter loadstring URL...", function(text, enter)
    if enter and text ~= "" then print("Execute:", text) end
end)

MiscTab:CreateSeparator()

MiscTab:CreateButton("Destroy UI", "Close the Neptium interface", function()
    for _, gui in ipairs(TargetGui:GetChildren()) do
        if gui.Name:match("^Neptium_") then gui:Destroy() end
    end
end)

print("[Neptium v2.1] Loaded successfully.")
