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
	local subtitle    = config.Subtitle or "v2.2"
	local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift

	local Win = {}
	local minimized = false
	local savedPos, savedSize

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Neptium_" .. math.random(1000, 9999)
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false
	ScreenGui.DisplayOrder = 999
	ScreenGui.Parent = TargetGui

	local Root = Instance.new("Frame")
	Root.Name = "Root"
	Root.Size = UDim2.new(0, 580, 0, 400)
	Root.Position = UDim2.new(0.5, -290, 0.5, -200)
	Root.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	Root.BorderSizePixel = 0
	Root.ClipsDescendants = false
	Root.Parent = ScreenGui
	addCorner(Root, 9)
	addStroke(Root, Color3.fromRGB(45, 45, 45), 1)

	local RootClip = Instance.new("Frame")
	RootClip.Name = "RootClip"
	RootClip.Size = UDim2.new(1, 0, 1, 0)
	RootClip.BackgroundTransparency = 1
	RootClip.ClipsDescendants = true
	RootClip.BorderSizePixel = 0
	RootClip.Parent = Root
	addCorner(RootClip, 9)

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 40)
	Topbar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Topbar.BorderSizePixel = 0
	Topbar.ZIndex = 2
	Topbar.Parent = RootClip

	local TopDivider = Instance.new("Frame")
	TopDivider.Size = UDim2.new(1, 0, 0, 1)
	TopDivider.Position = UDim2.new(0, 0, 1, -1)
	TopDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	TopDivider.BorderSizePixel = 0
	TopDivider.ZIndex = 2
	TopDivider.Parent = Topbar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, 0, 1, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 13
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
	TitleLabel.ZIndex = 2
	TitleLabel.Parent = Topbar

	local SubLabel = Instance.new("TextLabel")
	SubLabel.Size = UDim2.new(0, 120, 1, 0)
	SubLabel.Position = UDim2.new(0.5, 52, 0, 0)
	SubLabel.BackgroundTransparency = 1
	SubLabel.Font = Enum.Font.Gotham
	SubLabel.Text = subtitle
	SubLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
	SubLabel.TextSize = 11
	SubLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubLabel.ZIndex = 2
	SubLabel.Parent = Topbar

	local dotData = {
		{ color = Color3.fromRGB(255, 95,  86),  symbol = "x" },
		{ color = Color3.fromRGB(255, 189, 46),  symbol = "-" },
		{ color = Color3.fromRGB(40,  201, 64),  symbol = "+" },
	}

	local dots = {}
	for i, d in ipairs(dotData) do
		local Dot = Instance.new("Frame")
		Dot.Size = UDim2.new(0, 13, 0, 13)
		Dot.Position = UDim2.new(0, 10 + (i - 1) * 19, 0.5, -6)
		Dot.BackgroundColor3 = d.color
		Dot.BorderSizePixel = 0
		Dot.ZIndex = 3
		Dot.Parent = Topbar
		addCorner(Dot, 7)

		local Sym = Instance.new("TextLabel")
		Sym.Size = UDim2.new(1, 0, 1, 0)
		Sym.BackgroundTransparency = 1
		Sym.Font = Enum.Font.GothamBold
		Sym.Text = d.symbol
		Sym.TextColor3 = Color3.fromRGB(80, 30, 20)
		Sym.TextSize = 7
		Sym.TextTransparency = 1
		Sym.ZIndex = 4
		Sym.Parent = Dot

		local DotBtn = Instance.new("TextButton")
		DotBtn.Size = UDim2.new(1, 0, 1, 0)
		DotBtn.BackgroundTransparency = 1
		DotBtn.Text = ""
		DotBtn.ZIndex = 5
		DotBtn.Parent = Dot

		dots[i] = { frame = Dot, sym = Sym, btn = DotBtn }
	end

	local function showSymbols(v)
		for _, d in ipairs(dots) do
			tween(d.sym, { TextTransparency = v and 0 or 1 }, 0.1)
		end
	end
	Topbar.MouseEnter:Connect(function() showSymbols(true) end)
	Topbar.MouseLeave:Connect(function() showSymbols(false) end)

	local DockBtn = Instance.new("TextButton")
	DockBtn.Size = UDim2.new(0, 100, 0, 28)
	DockBtn.Position = UDim2.new(0, -110, 0.5, -14)
	DockBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	DockBtn.BorderSizePixel = 0
	DockBtn.Font = Enum.Font.GothamBold
	DockBtn.Text = title
	DockBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	DockBtn.TextSize = 12
	DockBtn.BackgroundTransparency = 1
	DockBtn.TextTransparency = 1
	DockBtn.Visible = false
	DockBtn.ZIndex = 10
	DockBtn.Parent = ScreenGui
	addCorner(DockBtn, 8)
	addStroke(DockBtn, Color3.fromRGB(50, 50, 50), 1)

	local function doMinimize()
		minimized = true
		savedPos  = Root.Position
		savedSize = Root.Size

		DockBtn.Position = UDim2.new(0, -110, 0.5, -14)
		DockBtn.Size = UDim2.new(0, 100, 0, 28)
		DockBtn.BackgroundTransparency = 1
		DockBtn.TextTransparency = 1
		DockBtn.Visible = true

		tween(Root, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.22)
		task.delay(0.12, function()
			tween(DockBtn, { Position = UDim2.new(0, 8, 0.5, -14), BackgroundTransparency = 0, TextTransparency = 0 }, 0.22)
		end)
		task.delay(0.25, function()
			Root.Visible = false
		end)
	end

	local function doRestore()
		minimized = false
		tween(DockBtn, { Position = UDim2.new(0, -110, 0.5, -14), BackgroundTransparency = 1, TextTransparency = 1 }, 0.18)
		task.delay(0.18, function()
			DockBtn.Visible = false
			Root.Visible = true
			Root.Size = UDim2.new(0, 0, 0, 0)
			Root.Position = savedPos
			Root.BackgroundTransparency = 1
			tween(Root, { Size = savedSize, BackgroundTransparency = 0 }, 0.26)
		end)
	end

	dots[1].btn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	dots[2].btn.MouseButton1Click:Connect(function()
		if minimized then doRestore() else doMinimize() end
	end)
	dots[3].btn.MouseButton1Click:Connect(function() end)

	DockBtn.MouseButton1Click:Connect(function() doRestore() end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == minimizeKey then
			if minimized then doRestore() else doMinimize() end
		end
	end)

	local dragging, dragStart, startPos, dragInput
	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			dragStart = input.Position
			startPos  = Root.Position
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
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 130, 1, -40)
	Sidebar.Position = UDim2.new(0, 0, 0, 40)
	Sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
	Sidebar.BorderSizePixel = 0
	Sidebar.ZIndex = 2
	Sidebar.Parent = RootClip

	local SideDivider = Instance.new("Frame")
	SideDivider.Size = UDim2.new(0, 1, 1, 0)
	SideDivider.Position = UDim2.new(1, 0, 0, 0)
	SideDivider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	SideDivider.BorderSizePixel = 0
	SideDivider.ZIndex = 3
	SideDivider.Parent = Sidebar

	local SideList = Instance.new("UIListLayout")
	SideList.SortOrder = Enum.SortOrder.LayoutOrder
	SideList.Padding = UDim.new(0, 2)
	SideList.Parent = Sidebar

	local SidePad = Instance.new("UIPadding")
	SidePad.PaddingTop    = UDim.new(0, 8)
	SidePad.PaddingLeft   = UDim.new(0, 7)
	SidePad.PaddingRight  = UDim.new(0, 7)
	SidePad.Parent = Sidebar

	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, -130, 1, -40)
	ContentArea.Position = UDim2.new(0, 130, 0, 40)
	ContentArea.BackgroundTransparency = 1
	ContentArea.ClipsDescendants = false
	ContentArea.ZIndex = 3
	ContentArea.Parent = Root

	local ContentClip = Instance.new("Frame")
	ContentClip.Name = "ContentClip"
	ContentClip.Size = UDim2.new(1, 0, 1, 0)
	ContentClip.BackgroundTransparency = 1
	ContentClip.ClipsDescendants = true
	ContentClip.ZIndex = 3
	ContentClip.Parent = ContentArea

	local activeTab  = nil
	local tabButtons = {}

	function Win:CreateTab(tabName, icon)
		local Tab = {}

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 34)
		TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		TabBtn.BackgroundTransparency = 1
		TabBtn.AutoButtonColor = false
		TabBtn.Text = ""
		TabBtn.BorderSizePixel = 0
		TabBtn.ZIndex = 3
		TabBtn.Parent = Sidebar
		addCorner(TabBtn, 6)

		local AccentBar = Instance.new("Frame")
		AccentBar.Size = UDim2.new(0, 2, 0.55, 0)
		AccentBar.AnchorPoint = Vector2.new(0, 0.5)
		AccentBar.Position = UDim2.new(0, 0, 0.5, 0)
		AccentBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		AccentBar.BackgroundTransparency = 1
		AccentBar.BorderSizePixel = 0
		AccentBar.ZIndex = 4
		AccentBar.Parent = TabBtn
		addCorner(AccentBar, 2)

		local TabIcon = Instance.new("TextLabel")
		TabIcon.Size = UDim2.new(0, 20, 1, 0)
		TabIcon.Position = UDim2.new(0, 10, 0, 0)
		TabIcon.BackgroundTransparency = 1
		TabIcon.Text = icon or ""
		TabIcon.TextColor3 = Color3.fromRGB(90, 90, 90)
		TabIcon.Font = Enum.Font.GothamSemibold
		TabIcon.TextSize = 13
		TabIcon.ZIndex = 4
		TabIcon.Parent = TabBtn

		local TabLabel = Instance.new("TextLabel")
		TabLabel.Size = UDim2.new(1, icon and -36 or -16, 1, 0)
		TabLabel.Position = UDim2.new(0, icon and 34 or 12, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Font = Enum.Font.GothamSemibold
		TabLabel.Text = tabName
		TabLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
		TabLabel.TextSize = 12
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.ZIndex = 4
		TabLabel.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 55)
		Page.ScrollingDirection = Enum.ScrollingDirection.Y
		Page.Visible = false
		Page.ZIndex = 3
		Page.Parent = ContentClip

		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 6)
		PageList.Parent = Page

		local PagePad = Instance.new("UIPadding")
		PagePad.PaddingTop    = UDim.new(0, 10)
		PagePad.PaddingLeft   = UDim.new(0, 10)
		PagePad.PaddingRight  = UDim.new(0, 12)
		PagePad.PaddingBottom = UDim.new(0, 10)
		PagePad.Parent = Page

		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
		end)

		local function setActive(state)
			if state then
				tween(TabBtn,    { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(22, 22, 22) })
				tween(TabLabel,  { TextColor3 = Color3.fromRGB(255, 255, 255) })
				tween(TabIcon,   { TextColor3 = Color3.fromRGB(255, 255, 255) })
				tween(AccentBar, { BackgroundTransparency = 0 })
				Page.Visible = true
			else
				tween(TabBtn,    { BackgroundTransparency = 1 })
				tween(TabLabel,  { TextColor3 = Color3.fromRGB(90, 90, 90) })
				tween(TabIcon,   { TextColor3 = Color3.fromRGB(90, 90, 90) })
				tween(AccentBar, { BackgroundTransparency = 1 })
				Page.Visible = false
			end
		end

		TabBtn.MouseEnter:Connect(function()
			if activeTab ~= Tab then tween(TabLabel, { TextColor3 = Color3.fromRGB(180, 180, 180) }) end
		end)
		TabBtn.MouseLeave:Connect(function()
			if activeTab ~= Tab then tween(TabLabel, { TextColor3 = Color3.fromRGB(90, 90, 90) }) end
		end)
		TabBtn.MouseButton1Click:Connect(function()
			if activeTab and activeTab ~= Tab then tabButtons[activeTab](false) end
			activeTab = Tab
			tabButtons[Tab](true)
		end)

		tabButtons[Tab] = setActive
		if not activeTab then activeTab = Tab setActive(true) end

		local function makeRow(h)
			local F = Instance.new("Frame")
			F.Size = UDim2.new(1, 0, 0, h or 36)
			F.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
			F.BorderSizePixel = 0
			F.ZIndex = 3
			F.Parent = Page
			addCorner(F, 6)
			addStroke(F, Color3.fromRGB(32, 32, 32), 1)
			return F
		end

		function Tab:CreateSeparator(text)
			local F = Instance.new("Frame")
			F.Size = UDim2.new(1, 0, 0, 20)
			F.BackgroundTransparency = 1
			F.ZIndex = 3
			F.Parent = Page

			local Line = Instance.new("Frame")
			Line.AnchorPoint = Vector2.new(0, 0.5)
			Line.Position = UDim2.new(0, 0, 0.5, 0)
			Line.Size = UDim2.new(1, 0, 0, 1)
			Line.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
			Line.BorderSizePixel = 0
			Line.ZIndex = 3
			Line.Parent = F

			if text and text ~= "" then
				local Lbl = Instance.new("TextLabel")
				Lbl.Size = UDim2.new(0, 0, 1, 0)
				Lbl.AutomaticSize = Enum.AutomaticSize.X
				Lbl.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
				Lbl.Font = Enum.Font.GothamBold
				Lbl.Text = "  " .. text:upper() .. "  "
				Lbl.TextColor3 = Color3.fromRGB(55, 55, 55)
				Lbl.TextSize = 10
				Lbl.TextXAlignment = Enum.TextXAlignment.Left
				Lbl.ZIndex = 4
				Lbl.Parent = F
			end
		end

		function Tab:CreateLabel(text)
			local F = makeRow(30)
			local L = Instance.new("TextLabel")
			L.Size = UDim2.new(1, -12, 1, 0)
			L.Position = UDim2.new(0, 12, 0, 0)
			L.BackgroundTransparency = 1
			L.Font = Enum.Font.Gotham
			L.Text = text or ""
			L.TextColor3 = Color3.fromRGB(120, 120, 120)
			L.TextSize = 12
			L.TextXAlignment = Enum.TextXAlignment.Left
			L.ZIndex = 4
			L.Parent = F
			return { SetText = function(_, t) L.Text = t end }
		end

		function Tab:CreateButton(name, desc, callback)
			if type(desc) == "function" then callback = desc desc = nil end
			local F = makeRow(desc and 50 or 36)

			local NameLbl = Instance.new("TextLabel")
			NameLbl.BackgroundTransparency = 1
			NameLbl.Font = Enum.Font.GothamSemibold
			NameLbl.Text = name
			NameLbl.TextColor3 = Color3.fromRGB(215, 215, 215)
			NameLbl.TextSize = 13
			NameLbl.TextXAlignment = Enum.TextXAlignment.Left
			NameLbl.ZIndex = 4
			NameLbl.Parent = F

			if desc then
				NameLbl.Size = UDim2.new(1, -46, 0, 18)
				NameLbl.Position = UDim2.new(0, 12, 0, 9)
				local DescLbl = Instance.new("TextLabel")
				DescLbl.Size = UDim2.new(1, -46, 0, 14)
				DescLbl.Position = UDim2.new(0, 12, 0, 28)
				DescLbl.BackgroundTransparency = 1
				DescLbl.Font = Enum.Font.Gotham
				DescLbl.Text = desc
				DescLbl.TextColor3 = Color3.fromRGB(70, 70, 70)
				DescLbl.TextSize = 11
				DescLbl.TextXAlignment = Enum.TextXAlignment.Left
				DescLbl.ZIndex = 4
				DescLbl.Parent = F
			else
				NameLbl.Size = UDim2.new(1, -46, 1, 0)
				NameLbl.Position = UDim2.new(0, 12, 0, 0)
			end

			local Arrow = Instance.new("TextLabel")
			Arrow.Size = UDim2.new(0, 28, 1, 0)
			Arrow.Position = UDim2.new(1, -36, 0, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Font = Enum.Font.GothamBold
			Arrow.Text = ">"
			Arrow.TextColor3 = Color3.fromRGB(55, 55, 55)
			Arrow.TextSize = 14
			Arrow.ZIndex = 4
			Arrow.Parent = F

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.AutoButtonColor = false
			Btn.Text = ""
			Btn.ZIndex = 5
			Btn.Parent = F

			Btn.MouseEnter:Connect(function()
				tween(F, { BackgroundColor3 = Color3.fromRGB(23, 23, 23) })
				tween(Arrow, { TextColor3 = Color3.fromRGB(190, 190, 190) })
			end)
			Btn.MouseLeave:Connect(function()
				tween(F, { BackgroundColor3 = Color3.fromRGB(17, 17, 17) })
				tween(Arrow, { TextColor3 = Color3.fromRGB(55, 55, 55) })
			end)
			Btn.MouseButton1Click:Connect(function()
				tween(F, { BackgroundColor3 = Color3.fromRGB(28, 28, 28) })
				task.delay(0.12, function() tween(F, { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }) end)
				if callback then callback() end
			end)
		end

		function Tab:CreateToggle(name, desc, default, callback)
			if type(desc) == "boolean" then callback = default default = desc desc = nil end
			if type(desc) == "function" then callback = desc desc = nil default = false end
			local toggled = default or false

			local F = makeRow(desc and 50 or 36)

			local NameLbl = Instance.new("TextLabel")
			NameLbl.BackgroundTransparency = 1
			NameLbl.Font = Enum.Font.GothamSemibold
			NameLbl.Text = name
			NameLbl.TextColor3 = Color3.fromRGB(215, 215, 215)
			NameLbl.TextSize = 13
			NameLbl.TextXAlignment = Enum.TextXAlignment.Left
			NameLbl.ZIndex = 4
			NameLbl.Parent = F

			if desc then
				NameLbl.Size = UDim2.new(1, -68, 0, 18)
				NameLbl.Position = UDim2.new(0, 12, 0, 9)
				local DescLbl = Instance.new("TextLabel")
				DescLbl.Size = UDim2.new(1, -68, 0, 14)
				DescLbl.Position = UDim2.new(0, 12, 0, 28)
				DescLbl.BackgroundTransparency = 1
				DescLbl.Font = Enum.Font.Gotham
				DescLbl.Text = desc
				DescLbl.TextColor3 = Color3.fromRGB(70, 70, 70)
				DescLbl.TextSize = 11
				DescLbl.TextXAlignment = Enum.TextXAlignment.Left
				DescLbl.ZIndex = 4
				DescLbl.Parent = F
			else
				NameLbl.Size = UDim2.new(1, -68, 1, 0)
				NameLbl.Position = UDim2.new(0, 12, 0, 0)
			end

			local Track = Instance.new("Frame")
			Track.Size = UDim2.new(0, 38, 0, 20)
			Track.AnchorPoint = Vector2.new(1, 0.5)
			Track.Position = UDim2.new(1, -12, 0.5, 0)
			Track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
			Track.BorderSizePixel = 0
			Track.ZIndex = 4
			Track.Parent = F
			addCorner(Track, 10)
			addStroke(Track, Color3.fromRGB(50, 50, 50), 1)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 14, 0, 14)
			Knob.AnchorPoint = Vector2.new(0, 0.5)
			Knob.Position = UDim2.new(0, 3, 0.5, 0)
			Knob.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			Knob.BorderSizePixel = 0
			Knob.ZIndex = 5
			Knob.Parent = Track
			addCorner(Knob, 7)

			local function refresh()
				if toggled then
					tween(Track, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
					tween(Knob,  { Position = UDim2.new(0, 21, 0.5, 0), BackgroundColor3 = Color3.fromRGB(10, 10, 10) })
				else
					tween(Track, { BackgroundColor3 = Color3.fromRGB(28, 28, 28) })
					tween(Knob,  { Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Color3.fromRGB(90, 90, 90) })
				end
			end
			refresh()

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.AutoButtonColor = false
			Btn.Text = ""
			Btn.ZIndex = 6
			Btn.Parent = F
			Btn.MouseButton1Click:Connect(function()
				toggled = not toggled
				refresh()
				if callback then callback(toggled) end
			end)

			return {
				Set = function(_, v) toggled = v refresh() if callback then callback(toggled) end end,
				Get = function() return toggled end,
			}
		end

		function Tab:CreateSlider(name, cfg, callback)
			cfg = cfg or {}
			local min     = cfg.Min or 0
			local max     = cfg.Max or 100
			local default = cfg.Default or min
			local suffix  = cfg.Suffix or ""
			local step    = cfg.Step or 1
			local value   = math.clamp(default, min, max)

			local F = makeRow(54)

			local NameLbl = Instance.new("TextLabel")
			NameLbl.Size = UDim2.new(1, -80, 0, 18)
			NameLbl.Position = UDim2.new(0, 12, 0, 8)
			NameLbl.BackgroundTransparency = 1
			NameLbl.Font = Enum.Font.GothamSemibold
			NameLbl.Text = name
			NameLbl.TextColor3 = Color3.fromRGB(215, 215, 215)
			NameLbl.TextSize = 13
			NameLbl.TextXAlignment = Enum.TextXAlignment.Left
			NameLbl.ZIndex = 4
			NameLbl.Parent = F

			local ValLbl = Instance.new("TextLabel")
			ValLbl.Size = UDim2.new(0, 65, 0, 18)
			ValLbl.Position = UDim2.new(1, -76, 0, 8)
			ValLbl.BackgroundTransparency = 1
			ValLbl.Font = Enum.Font.GothamSemibold
			ValLbl.Text = tostring(value) .. suffix
			ValLbl.TextColor3 = Color3.fromRGB(140, 140, 140)
			ValLbl.TextSize = 12
			ValLbl.TextXAlignment = Enum.TextXAlignment.Right
			ValLbl.ZIndex = 4
			ValLbl.Parent = F

			local TrackBG = Instance.new("Frame")
			TrackBG.Size = UDim2.new(1, -24, 0, 4)
			TrackBG.Position = UDim2.new(0, 12, 0, 36)
			TrackBG.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
			TrackBG.BorderSizePixel = 0
			TrackBG.ZIndex = 4
			TrackBG.Parent = F
			addCorner(TrackBG, 2)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Fill.BorderSizePixel = 0
			Fill.ZIndex = 5
			Fill.Parent = TrackBG
			addCorner(Fill, 2)

			local Handle = Instance.new("Frame")
			Handle.Size = UDim2.new(0, 11, 0, 11)
			Handle.AnchorPoint = Vector2.new(0.5, 0.5)
			Handle.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
			Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Handle.BorderSizePixel = 0
			Handle.ZIndex = 6
			Handle.Parent = TrackBG
			addCorner(Handle, 6)

			local DragZone = Instance.new("TextButton")
			DragZone.Size = UDim2.new(1, 0, 0, 22)
			DragZone.Position = UDim2.new(0, 0, 0, -9)
			DragZone.BackgroundTransparency = 1
			DragZone.AutoButtonColor = false
			DragZone.Text = ""
			DragZone.ZIndex = 7
			DragZone.Parent = TrackBG

			local draggingSlider = false

			local function updateVal(input)
				local rel     = math.clamp((input.Position.X - TrackBG.AbsolutePosition.X) / TrackBG.AbsoluteSize.X, 0, 1)
				local raw     = min + (max - min) * rel
				local stepped = math.floor(raw / step + 0.5) * step
				value = math.clamp(stepped, min, max)
				local pct = (value - min) / (max - min)
				tween(Fill,   { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
				tween(Handle, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.05)
				ValLbl.Text = tostring(math.round(value * 100) / 100) .. suffix
				if callback then callback(value) end
			end

			DragZone.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = true
					updateVal(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then updateVal(input) end
			end)

			return {
				Set = function(_, v)
					value = math.clamp(v, min, max)
					local pct = (value - min) / (max - min)
					tween(Fill,   { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
					tween(Handle, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.05)
					ValLbl.Text = tostring(value) .. suffix
				end,
				Get = function() return value end,
			}
		end

		function Tab:CreateDropdown(name, options, default, callback)
			local selected = default or options[1] or "None"
			local open     = false

			local Wrapper = Instance.new("Frame")
			Wrapper.Size = UDim2.new(1, 0, 0, 36)
			Wrapper.BackgroundTransparency = 1
			Wrapper.ClipsDescendants = false
			Wrapper.ZIndex = 20
			Wrapper.Parent = Page

			local F = Instance.new("Frame")
			F.Size = UDim2.new(1, 0, 0, 36)
			F.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
			F.BorderSizePixel = 0
			F.ZIndex = 20
			F.Parent = Wrapper
			addCorner(F, 6)
			addStroke(F, Color3.fromRGB(32, 32, 32), 1)

			local NameLbl = Instance.new("TextLabel")
			NameLbl.Size = UDim2.new(0.5, 0, 1, 0)
			NameLbl.Position = UDim2.new(0, 12, 0, 0)
			NameLbl.BackgroundTransparency = 1
			NameLbl.Font = Enum.Font.GothamSemibold
			NameLbl.Text = name
			NameLbl.TextColor3 = Color3.fromRGB(215, 215, 215)
			NameLbl.TextSize = 13
			NameLbl.TextXAlignment = Enum.TextXAlignment.Left
			NameLbl.ZIndex = 21
			NameLbl.Parent = F

			local SelLbl = Instance.new("TextLabel")
			SelLbl.Size = UDim2.new(0.45, -26, 1, 0)
			SelLbl.Position = UDim2.new(0.55, 0, 0, 0)
			SelLbl.BackgroundTransparency = 1
			SelLbl.Font = Enum.Font.Gotham
			SelLbl.Text = selected
			SelLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
			SelLbl.TextSize = 12
			SelLbl.TextXAlignment = Enum.TextXAlignment.Right
			SelLbl.ZIndex = 21
			SelLbl.Parent = F

			local ArrowLbl = Instance.new("TextLabel")
			ArrowLbl.Size = UDim2.new(0, 20, 1, 0)
			ArrowLbl.Position = UDim2.new(1, -24, 0, 0)
			ArrowLbl.BackgroundTransparency = 1
			ArrowLbl.Font = Enum.Font.GothamBold
			ArrowLbl.Text = "v"
			ArrowLbl.TextColor3 = Color3.fromRGB(75, 75, 75)
			ArrowLbl.TextSize = 11
			ArrowLbl.ZIndex = 21
			ArrowLbl.Parent = F

			local DropFrame = Instance.new("Frame")
			DropFrame.Size = UDim2.new(1, 0, 0, 0)
			DropFrame.Position = UDim2.new(0, 0, 1, 4)
			DropFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
			DropFrame.BorderSizePixel = 0
			DropFrame.ClipsDescendants = true
			DropFrame.ZIndex = 50
			DropFrame.Visible = false
			DropFrame.Parent = ScreenGui
			addCorner(DropFrame, 6)
			addStroke(DropFrame, Color3.fromRGB(38, 38, 38), 1)

			local DropScroll = Instance.new("ScrollingFrame")
			DropScroll.Size = UDim2.new(1, 0, 1, 0)
			DropScroll.BackgroundTransparency = 1
			DropScroll.BorderSizePixel = 0
			DropScroll.ScrollBarThickness = 2
			DropScroll.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 55)
			DropScroll.ZIndex = 51
			DropScroll.Parent = DropFrame

			local DropLayout = Instance.new("UIListLayout")
			DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
			DropLayout.Parent = DropScroll

			local function getDropAbsPos()
				local fAbsPos = F.AbsolutePosition
				local fAbsSize = F.AbsoluteSize
				return UDim2.new(0, fAbsPos.X, 0, fAbsPos.Y + fAbsSize.Y + 4)
			end

			local function buildOptions()
				for _, c in ipairs(DropScroll:GetChildren()) do
					if not c:IsA("UIListLayout") then c:Destroy() end
				end
				for _, opt in ipairs(options) do
					local Opt = Instance.new("TextButton")
					Opt.Size = UDim2.new(1, 0, 0, 30)
					Opt.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					Opt.BackgroundTransparency = opt == selected and 0 or 1
					Opt.BorderSizePixel = 0
					Opt.AutoButtonColor = false
					Opt.Font = Enum.Font.GothamSemibold
					Opt.Text = "  " .. opt
					Opt.TextColor3 = opt == selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
					Opt.TextSize = 12
					Opt.TextXAlignment = Enum.TextXAlignment.Left
					Opt.ZIndex = 52
					Opt.Parent = DropScroll

					Opt.MouseEnter:Connect(function()
						if opt ~= selected then tween(Opt, { TextColor3 = Color3.fromRGB(210, 210, 210) }) end
					end)
					Opt.MouseLeave:Connect(function()
						if opt ~= selected then tween(Opt, { TextColor3 = Color3.fromRGB(140, 140, 140) }) end
					end)
					Opt.MouseButton1Click:Connect(function()
						selected = opt
						SelLbl.Text = opt
						buildOptions()
						open = false
						tween(DropFrame, { Size = UDim2.new(DropFrame.Size.X.Scale, DropFrame.Size.X.Offset, 0, 0) }, 0.18)
						tween(ArrowLbl,  { Rotation = 0 }, 0.18)
						task.delay(0.18, function() DropFrame.Visible = false end)
						Wrapper.Size = UDim2.new(1, 0, 0, 36)
						if callback then callback(selected) end
					end)
				end
				DropScroll.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)
			end
			buildOptions()

			local MainBtn = Instance.new("TextButton")
			MainBtn.Size = UDim2.new(1, 0, 1, 0)
			MainBtn.BackgroundTransparency = 1
			MainBtn.AutoButtonColor = false
			MainBtn.Text = ""
			MainBtn.ZIndex = 22
			MainBtn.Parent = F

			MainBtn.MouseButton1Click:Connect(function()
				open = not open
				local count = math.min(#options, 5)
				if open then
					local absPos = getDropAbsPos()
					local absWidth = F.AbsoluteSize.X
					DropFrame.Position = absPos
					DropFrame.Size = UDim2.new(0, absWidth, 0, 0)
					DropFrame.Visible = true
					tween(DropFrame, { Size = UDim2.new(0, absWidth, 0, count * 30) }, 0.2)
					tween(ArrowLbl,  { Rotation = 180 }, 0.2)
				else
					tween(DropFrame, { Size = UDim2.new(DropFrame.Size.X.Scale, DropFrame.Size.X.Offset, 0, 0) }, 0.18)
					tween(ArrowLbl,  { Rotation = 0 }, 0.18)
					task.delay(0.18, function() DropFrame.Visible = false end)
					Wrapper.Size = UDim2.new(1, 0, 0, 36)
				end
			end)

			return {
				Set = function(_, v) selected = v SelLbl.Text = v buildOptions() end,
				Get = function() return selected end,
				Refresh = function(_, newOpts) options = newOpts buildOptions() end,
			}
		end

		function Tab:CreateInput(name, placeholder, callback)
			local F = makeRow(36)

			local NameLbl = Instance.new("TextLabel")
			NameLbl.Size = UDim2.new(0.4, 0, 1, 0)
			NameLbl.Position = UDim2.new(0, 12, 0, 0)
			NameLbl.BackgroundTransparency = 1
			NameLbl.Font = Enum.Font.GothamSemibold
			NameLbl.Text = name
			NameLbl.TextColor3 = Color3.fromRGB(215, 215, 215)
			NameLbl.TextSize = 13
			NameLbl.TextXAlignment = Enum.TextXAlignment.Left
			NameLbl.ZIndex = 4
			NameLbl.Parent = F

			local InputBG = Instance.new("Frame")
			InputBG.Size = UDim2.new(0.55, 0, 0, 24)
			InputBG.AnchorPoint = Vector2.new(1, 0.5)
			InputBG.Position = UDim2.new(1, -10, 0.5, 0)
			InputBG.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
			InputBG.BorderSizePixel = 0
			InputBG.ZIndex = 4
			InputBG.Parent = F
			addCorner(InputBG, 4)
			addStroke(InputBG, Color3.fromRGB(42, 42, 42), 1)

			local Input = Instance.new("TextBox")
			Input.Size = UDim2.new(1, -10, 1, 0)
			Input.Position = UDim2.new(0, 8, 0, 0)
			Input.BackgroundTransparency = 1
			Input.Font = Enum.Font.Gotham
			Input.PlaceholderText = placeholder or "Enter value..."
			Input.PlaceholderColor3 = Color3.fromRGB(58, 58, 58)
			Input.Text = ""
			Input.TextColor3 = Color3.fromRGB(200, 200, 200)
			Input.TextSize = 12
			Input.TextXAlignment = Enum.TextXAlignment.Left
			Input.ClearTextOnFocus = false
			Input.ZIndex = 5
			Input.Parent = InputBG

			Input.Focused:Connect(function() tween(InputBG, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }) end)
			Input.FocusLost:Connect(function(enter)
				tween(InputBG, { BackgroundColor3 = Color3.fromRGB(11, 11, 11) })
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

return Library
