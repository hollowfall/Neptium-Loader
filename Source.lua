local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local Viewport = Camera.ViewportSize

if getgenv and getgenv()._DrawLib then pcall(function() getgenv()._DrawLib:Destroy() end) end

local Library = {}
Library.Windows = {}
Library.Notifications = {}
Library.Toggled = true
Library.MobileLocked = false
Library.OpenDropdown = nil
Library.Flags = {}
Library._conns = {}
Library._allDraw = {}
Library._dTypes = {}

local T = {
    Accent = Color3.fromRGB(120, 80, 200),
    WinBg = Color3.fromRGB(20, 20, 32),
    WinBorder = Color3.fromRGB(55, 50, 80),
    TitleBg = Color3.fromRGB(26, 26, 40),
    TabBg = Color3.fromRGB(24, 24, 38),
    TabBorder = Color3.fromRGB(50, 48, 72),
    SectBg = Color3.fromRGB(26, 26, 40),
    SectBorder = Color3.fromRGB(50, 48, 72),
    ElemBg = Color3.fromRGB(32, 32, 48),
    ElemBorder = Color3.fromRGB(55, 52, 78),
    Text = Color3.fromRGB(225, 225, 235),
    Dim = Color3.fromRGB(160, 158, 175),
    OnColor = Color3.fromRGB(120, 80, 200),
    OffColor = Color3.fromRGB(40, 40, 58),
    DDBg = Color3.fromRGB(28, 28, 44),
    NotBg = Color3.fromRGB(22, 22, 36),
    WmBg = Color3.fromRGB(20, 20, 32),
}

local S = 1
if IsMobile then S = math.clamp(math.min(Viewport.X/610, Viewport.Y/520), 0.45, 1) end
local WW = math.floor(570*S)
local WH = math.floor(420*S)
local FS = math.floor(13*S)
local FSS = math.floor(11*S)
local FSL = math.floor(15*S)
local EH = math.floor(20*S)
local PAD = math.floor(6*S)
local TTH = math.floor(24*S)
local TBH = math.floor(22*S)
local SHH = math.floor(20*S)
local SLH = math.floor(10*S)
local TGS = math.floor(14*S)
local BTH = math.floor(24*S)

local topInset = 36
pcall(function() topInset = game:GetService("GuiService"):GetGuiInset().Y end)

local function cr(cls, p)
    local d = Drawing.new(cls)
    for k,v in pairs(p) do d[k]=v end
    table.insert(Library._allDraw, d)
    if cls=="Line" then Library._dTypes[d]="l"
    elseif cls=="Triangle" then Library._dTypes[d]="t"
    else Library._dTypes[d]="p" end
    return d
end

local function mv(d, dt)
    local t = Library._dTypes[d]
    if t=="p" then d.Position=d.Position+dt
    elseif t=="l" then d.From=d.From+dt; d.To=d.To+dt
    elseif t=="t" then d.PointA=d.PointA+dt; d.PointB=d.PointB+dt; d.PointC=d.PointC+dt end
end

local function mvAll(drs, dt) for _,d in pairs(drs) do mv(d,dt) end end
local function vis(drs, v) for _,d in pairs(drs) do d.Visible=v end end
local function ib(pos,tl,sz) return pos.X>=tl.X and pos.X<=tl.X+sz.X and pos.Y>=tl.Y and pos.Y<=tl.Y+sz.Y end

function Library:CreateWatermark(cfg)
    cfg = cfg or {}
    local txt = cfg.Text or "Library"
    local tmp = Drawing.new("Text"); tmp.Text=txt; tmp.Size=FSL; tmp.Font=Drawing.Fonts.UI
    local tw = tmp.TextBounds.X; tmp:Remove()
    local wmW=tw+24; local wmH=FSL+12; local wx=10; local wy=topInset+8
    self._wm = {}
    self._wm.bg = cr("Square",{Position=Vector2.new(wx,wy),Size=Vector2.new(wmW,wmH),Color=T.WmBg,Filled=true,Visible=true,ZIndex=50000})
    self._wm.bdr = cr("Square",{Position=Vector2.new(wx,wy),Size=Vector2.new(wmW,wmH),Color=T.WinBorder,Filled=false,Thickness=1,Visible=true,ZIndex=50001})
    self._wm.acc = cr("Line",{From=Vector2.new(wx,wy),To=Vector2.new(wx+wmW,wy),Color=T.Accent,Thickness=2,Visible=true,ZIndex=50002})
    self._wm.lbl = cr("Text",{Text=txt,Size=FSL,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(wx+12,wy+5),Visible=true,ZIndex=50003})
    self._wmBottom = wy+wmH+4
    if IsMobile then self:_mkMobile() end
end

function Library:UpdateWatermark(txt)
    if not self._wm then return end
    self._wm.lbl.Text=txt
    local tw=self._wm.lbl.TextBounds.X; local nw=tw+24
    self._wm.bg.Size=Vector2.new(nw,self._wm.bg.Size.Y)
    self._wm.bdr.Size=Vector2.new(nw,self._wm.bdr.Size.Y)
    self._wm.acc.To=Vector2.new(self._wm.acc.From.X+nw,self._wm.acc.From.Y)
end

function Library:_mkMobile()
    local y=self._wmBottom or (topInset+40)
    local bw,bh=math.floor(72*S),math.floor(28*S)
    self._mobTog={
        bg=cr("Square",{Position=Vector2.new(10,y),Size=Vector2.new(bw,bh),Color=T.ElemBg,Filled=true,Visible=true,ZIndex=50001}),
        bdr=cr("Square",{Position=Vector2.new(10,y),Size=Vector2.new(bw,bh),Color=T.Accent,Filled=false,Thickness=1,Visible=true,ZIndex=50002}),
        lbl=cr("Text",{Text="Toggle UI",Size=FSS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(10+bw/2,y+bh/2-FSS/2),Center=true,Visible=true,ZIndex=50003}),
    }
    local lx=10+bw+6
    self._mobLck={
        bg=cr("Square",{Position=Vector2.new(lx,y),Size=Vector2.new(bw,bh),Color=T.ElemBg,Filled=true,Visible=true,ZIndex=50001}),
        bdr=cr("Square",{Position=Vector2.new(lx,y),Size=Vector2.new(bw,bh),Color=T.Accent,Filled=false,Thickness=1,Visible=true,ZIndex=50002}),
        lbl=cr("Text",{Text="Lock: OFF",Size=FSS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(lx+bw/2,y+bh/2-FSS/2),Center=true,Visible=true,ZIndex=50003}),
    }
end

function Library:_chkMobile(pos)
    if not IsMobile then return false end
    if self._mobTog and ib(pos,self._mobTog.bg.Position,self._mobTog.bg.Size) then
        self.Toggled=not self.Toggled
        for _,w in ipairs(self.Windows) do w:SetVisible(self.Toggled) end
        return true
    end
    if self._mobLck and ib(pos,self._mobLck.bg.Position,self._mobLck.bg.Size) then
        self.MobileLocked=not self.MobileLocked
        self._mobLck.lbl.Text=self.MobileLocked and "Lock: ON" or "Lock: OFF"
        self._mobLck.bdr.Color=self.MobileLocked and Color3.fromRGB(200,80,80) or T.Accent
        return true
    end
    return false
end

function Library:Notify(cfg)
    cfg=cfg or {}
    local ttl=cfg.Title or "Notice"
    local cnt=cfg.Content or ""
    local dur=cfg.Duration or 3
    local nw,nh=math.floor(220*S),math.floor(52*S)
    local nx=Viewport.X-nw-12
    local ny=10+#self.Notifications*(nh+6)
    local n={d={},_exp=tick()+dur}
    n.d.bg=cr("Square",{Position=Vector2.new(nx,ny),Size=Vector2.new(nw,nh),Color=T.NotBg,Filled=true,Visible=true,ZIndex=60000})
    n.d.bdr=cr("Square",{Position=Vector2.new(nx,ny),Size=Vector2.new(nw,nh),Color=T.Accent,Filled=false,Thickness=1,Visible=true,ZIndex=60001})
    n.d.acc=cr("Line",{From=Vector2.new(nx,ny),To=Vector2.new(nx,ny+nh),Color=T.Accent,Thickness=3,Visible=true,ZIndex=60002})
    n.d.ttl=cr("Text",{Text=ttl,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(nx+10,ny+4),Visible=true,ZIndex=60003})
    n.d.cnt=cr("Text",{Text=cnt,Size=FSS,Font=Drawing.Fonts.UI,Color=T.Dim,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(nx+10,ny+6+FS),Visible=true,ZIndex=60003})
    table.insert(self.Notifications,n)
end

function Library:_tickNotif()
    local now=tick(); local dirty=false
    for i=#self.Notifications,1,-1 do
        if now>=self.Notifications[i]._exp then
            for _,d in pairs(self.Notifications[i].d) do d:Remove() end
            table.remove(self.Notifications,i); dirty=true
        end
    end
    if dirty then
        local nh=math.floor(52*S)
        for i,n in ipairs(self.Notifications) do
            local ny=10+(i-1)*(nh+6); local nx=n.d.bg.Position.X
            n.d.bg.Position=Vector2.new(nx,ny); n.d.bdr.Position=Vector2.new(nx,ny)
            n.d.acc.From=Vector2.new(nx,ny); n.d.acc.To=Vector2.new(nx,ny+nh)
            n.d.ttl.Position=Vector2.new(nx+10,ny+4); n.d.cnt.Position=Vector2.new(nx+10,ny+6+FS)
        end
    end
end

function Library:CreateWindow(cfg)
    cfg=cfg or {}
    local w = {}
    w.Title=cfg.Title or "Window"
    w.Pos=cfg.Position or Vector2.new(math.floor(Viewport.X/2-WW/2),math.floor(Viewport.Y/2-WH/2))
    w.Size=Vector2.new(WW,WH)
    w.Tabs={}
    w.ActiveTab=nil
    w.Visible=true
    w._drag=false
    w._dragOff=Vector2.new(0,0)
    local p,s=w.Pos,w.Size
    local z=1000
    w.D={}
    w.D.bg=cr("Square",{Position=p,Size=s,Color=T.WinBg,Filled=true,Visible=true,ZIndex=z})
    w.D.bdr=cr("Square",{Position=p,Size=s,Color=T.WinBorder,Filled=false,Thickness=1,Visible=true,ZIndex=z+1})
    w.D.atop=cr("Line",{From=p,To=Vector2.new(p.X+s.X,p.Y),Color=T.Accent,Thickness=2,Visible=true,ZIndex=z+5})
    w.D.tbg=cr("Square",{Position=Vector2.new(p.X,p.Y+2),Size=Vector2.new(s.X,TTH),Color=T.TitleBg,Filled=true,Visible=true,ZIndex=z+2})
    w.D.ttx=cr("Text",{Text=w.Title,Size=FSL,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(p.X+8,p.Y+5),Visible=true,ZIndex=z+3})
    w.D.tbbg=cr("Square",{Position=Vector2.new(p.X,p.Y+2+TTH),Size=Vector2.new(s.X,TBH),Color=T.TabBg,Filled=true,Visible=true,ZIndex=z+2})
    w.D.tbln=cr("Line",{From=Vector2.new(p.X,p.Y+2+TTH+TBH),To=Vector2.new(p.X+s.X,p.Y+2+TTH+TBH),Color=T.TabBorder,Thickness=1,Visible=true,ZIndex=z+3})
    w._cY=p.Y+2+TTH+TBH+2
    w._cH=s.Y-(2+TTH+TBH+4)

    function w:SetVisible(v)
        self.Visible=v; vis(self.D,v)
        for _,tab in ipairs(self.Tabs) do
            tab.D.lbl.Visible=v
            tab.D.uln.Visible=v and tab==self.ActiveTab
            for _,sec in ipairs(tab.Sects) do
                local sv=v and tab==self.ActiveTab
                vis(sec.D,sv)
                for _,el in ipairs(sec.Elems) do vis(el.D,sv) end
            end
        end
    end

    function w:_applyDelta(dt)
        self.Pos=self.Pos+dt
        mvAll(self.D,dt)
        self._cY=self._cY+dt.Y
        for _,tab in ipairs(self.Tabs) do
            mvAll(tab.D,dt)
            tab._px=tab._px+dt.X; tab._py=tab._py+dt.Y
            for _,sec in ipairs(tab.Sects) do
                mvAll(sec.D,dt)
                sec._x=sec._x+dt.X; sec._y=sec._y+dt.Y; sec._esY=sec._esY+dt.Y
                for _,el in ipairs(sec.Elems) do
                    mvAll(el.D,dt)
                    el._ax=el._ax+dt.X; el._ay=el._ay+dt.Y
                    if el._tx then el._tx=el._tx+dt.X; el._ty=el._ty+dt.Y end
                    if el._bx then el._bx=el._bx+dt.X; el._by=el._by+dt.Y end
                end
            end
        end
    end

    function w:CreateTab(name)
        local tab={}; tab.Name=name or "Tab"; tab.Sects={}; tab.D={}
        local tmp=Drawing.new("Text"); tmp.Text=name; tmp.Size=FS; tmp.Font=Drawing.Fonts.UI
        tab._tw=math.floor(tmp.TextBounds.X+16*S); tmp:Remove()
        local tx=w.Pos.X+4
        for _,t in ipairs(w.Tabs) do tx=tx+t._tw+4 end
        local ty=w.Pos.Y+2+TTH
        tab._px=tx; tab._py=ty
        tab.D.lbl=cr("Text",{Text=name,Size=FS,Font=Drawing.Fonts.UI,Color=T.Dim,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(tx+math.floor(tab._tw/2),ty+4),Center=true,Visible=true,ZIndex=1010})
        tab.D.uln=cr("Line",{From=Vector2.new(tx,ty+TBH-2),To=Vector2.new(tx+tab._tw,ty+TBH-2),Color=T.Accent,Thickness=2,Visible=false,ZIndex=1011})
        table.insert(w.Tabs,tab)

        local function activateTab(t)
            for _,ot in ipairs(w.Tabs) do
                local isAct=ot==t
                ot.D.lbl.Color=isAct and T.Text or T.Dim
                ot.D.uln.Visible=isAct and w.Visible
                for _,sec in ipairs(ot.Sects) do
                    vis(sec.D,isAct and w.Visible)
                    for _,el in ipairs(sec.Elems) do vis(el.D,isAct and w.Visible) end
                end
            end
            w.ActiveTab=t
        end

        tab._click=function(pos)
            if ib(pos,Vector2.new(tab._px,tab._py),Vector2.new(tab._tw,TBH)) then
                activateTab(tab); return true
            end
            return false
        end

        if #w.Tabs==1 then activateTab(tab) end

        function tab:CreateSection(scfg)
            scfg=scfg or {}
            local sec={}; sec.Name=scfg.Name or "Section"; sec.Side=scfg.Side or "Left"; sec.Elems={}; sec.D={}
            local colW=math.floor((w.Size.X-PAD*3)/2)
            local px
            if sec.Side=="Left" then px=w.Pos.X+PAD else px=w.Pos.X+PAD*2+colW end
            local py=w._cY+PAD
            for _,s in ipairs(tab.Sects) do
                if s.Side==sec.Side then py=py+s._totH+PAD end
            end
            sec._x=px; sec._y=py; sec._w=colW; sec._totH=SHH+4; sec._esY=py+SHH+2
            local isAct=w.ActiveTab==tab
            sec.D.bdr=cr("Square",{Position=Vector2.new(px,py),Size=Vector2.new(colW,sec._totH),Color=T.SectBorder,Filled=false,Thickness=1,Visible=isAct,ZIndex=1020})
            sec.D.hdr=cr("Text",{Text=sec.Name,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(px+6,py+3),Visible=isAct,ZIndex=1021})
            sec._nY=sec._esY
            table.insert(tab.Sects,sec)

            local function recalcH()
                local h=SHH+4
                for _,el in ipairs(sec.Elems) do h=h+el._h+3 end
                sec._totH=h; sec.D.bdr.Size=Vector2.new(sec._w,h)
            end

            local elZ=1030
            local ew=colW-8

            function sec:CreateToggle(ecfg)
                ecfg=ecfg or {}
                local el={}; el.Type="Toggle"; el.Name=ecfg.Name or "Toggle"
                el.Value=ecfg.Default or false; el.CB=ecfg.Callback or function()end
                el.Flag=ecfg.Flag; el.D={}; el._h=EH
                local x,y=sec._x+4,sec._nY
                el._ax=x; el._ay=y; el._aw=ew
                el.D.lbl=cr("Text",{Text=el.Name,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x,y+2),Visible=isAct,ZIndex=elZ})
                el.D.box=cr("Square",{Position=Vector2.new(x+ew-TGS-2,y+2),Size=Vector2.new(TGS,TGS),Color=el.Value and T.OnColor or T.OffColor,Filled=true,Visible=isAct,ZIndex=elZ+1})
                el.D.bbdr=cr("Square",{Position=Vector2.new(x+ew-TGS-2,y+2),Size=Vector2.new(TGS,TGS),Color=T.ElemBorder,Filled=false,Thickness=1,Visible=isAct,ZIndex=elZ+2})
                el._click=function(pos)
                    if ib(pos,Vector2.new(el._ax,el._ay),Vector2.new(el._aw,EH)) then
                        el.Value=not el.Value
                        el.D.box.Color=el.Value and T.OnColor or T.OffColor
                        if el.Flag then Library.Flags[el.Flag]=el.Value end
                        el.CB(el.Value); return true
                    end; return false
                end
                sec._nY=sec._nY+EH+3; table.insert(sec.Elems,el); recalcH()
                if el.Flag then Library.Flags[el.Flag]=el.Value end; return el
            end

            function sec:CreateSlider(ecfg)
                ecfg=ecfg or {}
                local el={}; el.Type="Slider"; el.Name=ecfg.Name or "Slider"
                el.Min=ecfg.Min or 0; el.Max=ecfg.Max or 100
                el.Value=ecfg.Default or el.Min; el.Inc=ecfg.Increment or 1
                el.Suf=ecfg.Suffix or ""; el.CB=ecfg.Callback or function()end
                el.Flag=ecfg.Flag; el.D={}; el._h=EH+SLH+4; el._dragging=false
                local x,y=sec._x+4,sec._nY
                el._ax=x; el._ay=y; el._aw=ew
                el._tx=x+2; el._ty=y+EH+2; el._tw2=ew-4
                local frac=(el.Value-el.Min)/(el.Max-el.Min)
                local fillW=math.max(math.floor(frac*el._tw2),1)
                el.D.lbl=cr("Text",{Text=el.Name..": "..el.Value..el.Suf,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x,y),Visible=isAct,ZIndex=elZ})
                el.D.trk=cr("Square",{Position=Vector2.new(el._tx,el._ty),Size=Vector2.new(el._tw2,SLH),Color=T.ElemBg,Filled=true,Visible=isAct,ZIndex=elZ})
                el.D.tbdr=cr("Square",{Position=Vector2.new(el._tx,el._ty),Size=Vector2.new(el._tw2,SLH),Color=T.ElemBorder,Filled=false,Thickness=1,Visible=isAct,ZIndex=elZ+1})
                el.D.fill=cr("Square",{Position=Vector2.new(el._tx,el._ty),Size=Vector2.new(fillW,SLH),Color=T.OnColor,Filled=true,Visible=isAct,ZIndex=elZ+1})
                el._updVal=function(pos)
                    local rel=math.clamp((pos.X-el._tx)/el._tw2,0,1)
                    local raw=el.Min+rel*(el.Max-el.Min)
                    raw=math.floor(raw/el.Inc+0.5)*el.Inc
                    el.Value=math.clamp(raw,el.Min,el.Max)
                    local fw=math.max(math.floor(((el.Value-el.Min)/(el.Max-el.Min))*el._tw2),1)
                    el.D.fill.Size=Vector2.new(fw,SLH)
                    el.D.lbl.Text=el.Name..": "..el.Value..el.Suf
                    if el.Flag then Library.Flags[el.Flag]=el.Value end
                    el.CB(el.Value)
                end
                el._click=function(pos)
                    if ib(pos,Vector2.new(el._tx,el._ty),Vector2.new(el._tw2,SLH)) then
                        el._dragging=true; el._updVal(pos); return true
                    end; return false
                end
                sec._nY=sec._nY+el._h+3; table.insert(sec.Elems,el); recalcH()
                if el.Flag then Library.Flags[el.Flag]=el.Value end; return el
            end

            function sec:CreateDropdown(ecfg)
                ecfg=ecfg or {}
                local el={}; el.Type="Dropdown"; el.Name=ecfg.Name or "Dropdown"
                el.Options=ecfg.Options or {}; el.Value=ecfg.Default or (el.Options[1] or "")
                el.CB=ecfg.Callback or function()end; el.Flag=ecfg.Flag
                el.D={}; el._h=EH+EH+4; el._open=false; el._optD={}
                local x,y=sec._x+4,sec._nY
                el._ax=x; el._ay=y; el._aw=ew
                el._bx=x; el._by=y+EH+2; el._bw=ew
                el.D.lbl=cr("Text",{Text=el.Name,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x,y),Visible=isAct,ZIndex=elZ})
                el.D.box=cr("Square",{Position=Vector2.new(x,y+EH+2),Size=Vector2.new(ew,EH),Color=T.ElemBg,Filled=true,Visible=isAct,ZIndex=elZ})
                el.D.bbdr=cr("Square",{Position=Vector2.new(x,y+EH+2),Size=Vector2.new(ew,EH),Color=T.ElemBorder,Filled=false,Thickness=1,Visible=isAct,ZIndex=elZ+1})
                el.D.sel=cr("Text",{Text=tostring(el.Value),Size=FSS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x+4,y+EH+4),Visible=isAct,ZIndex=elZ+2})
                local ax=x+ew-12; local ay=y+EH+6
                el.D.arr=cr("Triangle",{PointA=Vector2.new(ax,ay),PointB=Vector2.new(ax+8,ay),PointC=Vector2.new(ax+4,ay+6),Color=T.Dim,Filled=true,Visible=isAct,ZIndex=elZ+2})
                el._close=function()
                    el._open=false
                    for _,od in ipairs(el._optD) do od.bg:Remove(); od.lbl:Remove() end
                    el._optD={}
                    if Library.OpenDropdown==el then Library.OpenDropdown=nil end
                end
                el._openDD=function()
                    if Library.OpenDropdown and Library.OpenDropdown~=el then Library.OpenDropdown._close() end
                    el._open=true; Library.OpenDropdown=el
                    for i,opt in ipairs(el.Options) do
                        local oy=el._by+EH+(i-1)*EH
                        local od={}
                        od.bg=cr("Square",{Position=Vector2.new(el._bx,oy),Size=Vector2.new(el._bw,EH),Color=T.DDBg,Filled=true,Visible=true,ZIndex=55000})
                        od.lbl=cr("Text",{Text=tostring(opt),Size=FSS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(el._bx+4,oy+3),Visible=true,ZIndex=55001})
                        od._val=opt
                        table.insert(el._optD,od)
                    end
                end
                el._click=function(pos)
                    if el._open then
                        for _,od in ipairs(el._optD) do
                            if ib(pos,od.bg.Position,od.bg.Size) then
                                el.Value=od._val; el.D.sel.Text=tostring(od._val)
                                if el.Flag then Library.Flags[el.Flag]=el.Value end
                                el.CB(el.Value); el._close(); return true
                            end
                        end
                        el._close(); return true
                    end
                    if ib(pos,Vector2.new(el._bx,el._by),Vector2.new(el._bw,EH)) then
                        el._openDD(); return true
                    end
                    return false
                end
                sec._nY=sec._nY+el._h+3; table.insert(sec.Elems,el); recalcH()
                if el.Flag then Library.Flags[el.Flag]=el.Value end; return el
            end

            function sec:CreateButton(ecfg)
                ecfg=ecfg or {}
                local el={}; el.Type="Button"; el.Name=ecfg.Name or "Button"
                el.CB=ecfg.Callback or function()end; el.D={}; el._h=BTH
                local x,y=sec._x+4,sec._nY
                el._ax=x; el._ay=y; el._aw=ew
                el.D.bg=cr("Square",{Position=Vector2.new(x,y),Size=Vector2.new(ew,BTH),Color=T.ElemBg,Filled=true,Visible=isAct,ZIndex=elZ})
                el.D.bbdr=cr("Square",{Position=Vector2.new(x,y),Size=Vector2.new(ew,BTH),Color=T.ElemBorder,Filled=false,Thickness=1,Visible=isAct,ZIndex=elZ+1})
                el.D.lbl=cr("Text",{Text=el.Name,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x+math.floor(ew/2),y+4),Center=true,Visible=isAct,ZIndex=elZ+2})
                el._click=function(pos)
                    if ib(pos,Vector2.new(el._ax,el._ay),Vector2.new(el._aw,BTH)) then
                        el.D.bg.Color=T.Accent
                        task.delay(0.15,function() pcall(function() el.D.bg.Color=T.ElemBg end) end)
                        el.CB(); return true
                    end; return false
                end
                sec._nY=sec._nY+BTH+3; table.insert(sec.Elems,el); recalcH(); return el
            end

            function sec:CreateLabel(txt)
                local el={}; el.Type="Label"; el.D={}; el._h=FS+4
                local x,y=sec._x+4,sec._nY
                el._ax=x; el._ay=y; el._aw=ew
                el.D.lbl=cr("Text",{Text=txt or "",Size=FS,Font=Drawing.Fonts.UI,Color=T.Dim,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x,y),Visible=isAct,ZIndex=elZ})
                el._click=function() return false end
                el.SetText=function(_,t) el.D.lbl.Text=t end
                sec._nY=sec._nY+el._h+3; table.insert(sec.Elems,el); recalcH(); return el
            end

            function sec:CreateKeybind(ecfg)
                ecfg=ecfg or {}
                local el={}; el.Type="Keybind"; el.Name=ecfg.Name or "Keybind"
                el.Value=ecfg.Default or Enum.KeyCode.Unknown
                el.CB=ecfg.Callback or function()end; el.Flag=ecfg.Flag
                el.D={}; el._h=EH; el._listening=false
                local x,y=sec._x+4,sec._nY
                local kbW=math.floor(60*S)
                el._ax=x; el._ay=y; el._aw=ew; el._kbW=kbW
                el.D.lbl=cr("Text",{Text=el.Name,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x,y+2),Visible=isAct,ZIndex=elZ})
                el.D.kbg=cr("Square",{Position=Vector2.new(x+ew-kbW,y),Size=Vector2.new(kbW,EH),Color=T.ElemBg,Filled=true,Visible=isAct,ZIndex=elZ})
                el.D.kbdr=cr("Square",{Position=Vector2.new(x+ew-kbW,y),Size=Vector2.new(kbW,EH),Color=T.ElemBorder,Filled=false,Thickness=1,Visible=isAct,ZIndex=elZ+1})
                local kn=el.Value==Enum.KeyCode.Unknown and "None" or el.Value.Name
                el.D.ktx=cr("Text",{Text=kn,Size=FSS,Font=Drawing.Fonts.UI,Color=T.Dim,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x+ew-kbW+math.floor(kbW/2),y+3),Center=true,Visible=isAct,ZIndex=elZ+2})
                el._click=function(pos)
                    if ib(pos,Vector2.new(el._ax+el._aw-el._kbW,el._ay),Vector2.new(el._kbW,EH)) then
                        el._listening=true; el.D.ktx.Text="..."; el.D.ktx.Color=T.Accent; return true
                    end; return false
                end
                el._key=function(kc)
                    if not el._listening then return false end
                    if kc==Enum.KeyCode.Escape then el.Value=Enum.KeyCode.Unknown; el.D.ktx.Text="None"
                    else el.Value=kc; el.D.ktx.Text=kc.Name end
                    el.D.ktx.Color=T.Dim; el._listening=false
                    if el.Flag then Library.Flags[el.Flag]=el.Value end; el.CB(el.Value); return true
                end
                sec._nY=sec._nY+EH+3; table.insert(sec.Elems,el); recalcH()
                if el.Flag then Library.Flags[el.Flag]=el.Value end; return el
            end

            function sec:CreateColorPicker(ecfg)
                ecfg=ecfg or {}
                local el={}; el.Type="Color"; el.Name=ecfg.Name or "Color"
                el.Value=ecfg.Default or Color3.fromRGB(120,80,200)
                el.CB=ecfg.Callback or function()end; el.Flag=ecfg.Flag
                el.D={}; el._h=EH
                local x,y=sec._x+4,sec._nY
                local cpS=math.floor(14*S)
                el._ax=x; el._ay=y; el._aw=ew
                el.D.lbl=cr("Text",{Text=el.Name,Size=FS,Font=Drawing.Fonts.UI,Color=T.Text,Outline=true,OutlineColor=Color3.new(0,0,0),Position=Vector2.new(x,y+2),Visible=isAct,ZIndex=elZ})
                el.D.cbox=cr("Square",{Position=Vector2.new(x+ew-cpS-2,y+2),Size=Vector2.new(cpS,cpS),Color=el.Value,Filled=true,Visible=isAct,ZIndex=elZ+1})
                el.D.cbdr=cr("Square",{Position=Vector2.new(x+ew-cpS-2,y+2),Size=Vector2.new(cpS,cpS),Color=T.ElemBorder,Filled=false,Thickness=1,Visible=isAct,ZIndex=elZ+2})
                el._click=function() return false end
                el.SetColor=function(_,c) el.Value=c; el.D.cbox.Color=c; if el.Flag then Library.Flags[el.Flag]=c end; el.CB(c) end
                sec._nY=sec._nY+EH+3; table.insert(sec.Elems,el); recalcH()
                if el.Flag then Library.Flags[el.Flag]=el.Value end; return el
            end

            return sec
        end
        return tab
    end
    table.insert(Library.Windows,w)
    return w
end

local activeSlider = nil

local function onBegan(input)
    local pos
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        pos=Vector2.new(input.Position.X,input.Position.Y)
    elseif input.UserInputType==Enum.UserInputType.Keyboard then
        if input.KeyCode==Enum.KeyCode.RightControl then
            Library.Toggled=not Library.Toggled
            for _,w in ipairs(Library.Windows) do w:SetVisible(Library.Toggled) end
            return
        end
        for _,w in ipairs(Library.Windows) do
            if w.ActiveTab then
                for _,sec in ipairs(w.ActiveTab.Sects) do
                    for _,el in ipairs(sec.Elems) do
                        if el.Type=="Keybind" and el._listening then el._key(input.KeyCode); return end
                    end
                end
            end
        end
        return
    else return end

    if Library:_chkMobile(pos) then return end
    if Library.OpenDropdown then
        if Library.OpenDropdown._click(pos) then return end
        Library.OpenDropdown._close()
    end

    for i=#Library.Windows,1,-1 do
        local w=Library.Windows[i]
        if not w.Visible then continue end
        if not (IsMobile and Library.MobileLocked) then
            local tp=w.D.tbg.Position; local ts=Vector2.new(w.Size.X,TTH)
            if ib(pos,tp,ts) then w._drag=true; w._dragOff=pos-w.Pos; return end
        end
        for _,tab in ipairs(w.Tabs) do if tab._click(pos) then return end end
        if w.ActiveTab then
            for _,sec in ipairs(w.ActiveTab.Sects) do
                for _,el in ipairs(sec.Elems) do
                    if el._click(pos) then
                        if el.Type=="Slider" and el._dragging then activeSlider=el end
                        return
                    end
                end
            end
        end
    end
end

local function onChanged(input)
    local pos
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        pos=Vector2.new(input.Position.X,input.Position.Y)
    else return end
    if activeSlider then activeSlider._updVal(pos); return end
    for _,w in ipairs(Library.Windows) do
        if w._drag then
            local np=pos-w._dragOff; local dt=np-w.Pos; w:_applyDelta(dt); return
        end
    end
end

local function onEnded(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        activeSlider=nil
        for _,w in ipairs(Library.Windows) do w._drag=false end
    end
end

table.insert(Library._conns, UIS.InputBegan:Connect(onBegan))
table.insert(Library._conns, UIS.InputChanged:Connect(onChanged))
table.insert(Library._conns, UIS.InputEnded:Connect(onEnded))
table.insert(Library._conns, RS.Heartbeat:Connect(function() Library:_tickNotif() end))

function Library:Destroy()
    for _,c in ipairs(self._conns) do c:Disconnect() end; self._conns={}
    for _,d in ipairs(self._allDraw) do pcall(function() d:Remove() end) end
    self._allDraw={}; self._dTypes={}; self.Windows={}; self.Notifications={}
end

if getgenv then getgenv()._DrawLib = Library end

return Library
