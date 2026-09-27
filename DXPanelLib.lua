--============================================================
-- DXPanel LIBRARY — NEON RED / BLACK (ModuleScript version)
--
-- USAGE:
--   local DXPanel = require(path.to.DXPanelLib)
--   local Window  = DXPanel.new({
--       Name        = "MyPanel",       -- ScreenGui name (unique per window)
--       Title       = "DX",            -- big logo text top-left
--       Subtitle    = "PANEL",         -- small text next to logo
--       Description = "My Interface",  -- header subtitle text
--       Size        = { defW = 600, defH = 370 }, -- optional, merges with defaults
--   })
--
--   local Tab = Window:CreateTab("Settings", "gear")
--   Tab:Section("GENERAL")
--   Tab:Button("Click me", function() end)
--   Tab:Toggle("Enable X", false, function(state) end)
--   Tab:Dropdown("Mode", {"Easy","Hard"}, "Easy", function(choice) end)
--
--   Window:SetThemeColor(Color3.fromRGB(80, 140, 255))
--   Window:SetPulse(true)
--   Window:Destroy()
--============================================================

local DXPanel = {}

function DXPanel.new(config)
    config = config or {}

    local Players       = game:GetService("Players")
    local UIS           = game:GetService("UserInputService")
    local TweenService  = game:GetService("TweenService")

    local Player    = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    --========================================================
    -- CONFIG
    --========================================================

    local WINDOW_NAME      = config.Name or "DXPanel"
    local TITLE_TEXT       = config.Title or "DX"
    local SUBTITLE_TEXT    = config.Subtitle or "PANEL"
    local DESCRIPTION_TEXT = config.Description or (WINDOW_NAME .. " Interface")
    local TOGGLE_RICH_TEXT = config.ToggleText
        or ('D<font color="rgb(255,60,80)">X</font>')

    local userSize = config.Size or {}

    local SIZE = {
        minW = userSize.minW or 400, minH = userSize.minH or 250,
        maxW = userSize.maxW or 850, maxH = userSize.maxH or 560,
        defW = userSize.defW or 600, defH = userSize.defH or 370,
    }

    local COLOR = {
    red        = Color3.fromRGB(235, 30, 52),
    redBright  = Color3.fromRGB(255, 70, 90),
    redSoft    = Color3.fromRGB(255, 110, 125),
    redDark    = Color3.fromRGB(90, 8, 18),
    neon       = Color3.fromRGB(255, 45, 75),

    black      = Color3.fromRGB(8, 8, 11),
    black2     = Color3.fromRGB(14, 10, 12),
    sidebar    = Color3.fromRGB(12, 12, 16),
    sidebar2   = Color3.fromRGB(16, 12, 14),

    innerBg          = Color3.fromRGB(25, 12, 17),
    innerBgHover     = Color3.fromRGB(55, 15, 25),
    innerBorder      = Color3.fromRGB(75, 30, 42),
    innerBorderHover = Color3.fromRGB(255, 35, 60),

    switchOff    = Color3.fromRGB(35, 35, 42),
    switchBorder = Color3.fromRGB(85, 40, 52),

    white  = Color3.fromRGB(245, 245, 248),
    grey   = Color3.fromRGB(145, 145, 155),
    border = Color3.fromRGB(62, 43, 51),
}

local Cfg = {
    Animate = true,
    Pulse = true
}

local Actions = {}

local ThemedButtons   = {}
local ThemedToggles   = {}
local ThemedDropdowns = {}
local ThemedFill      = {}
local ThemedText      = {}
local ThemedStroke    = {}
local ThemedLineGrad  = {}

--============================================================
-- HELPERS
--============================================================

local function New(class, props, parent)
    local obj = Instance.new(class)

    for k, v in pairs(props or {}) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function Corner(obj, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, obj)
end

local function Stroke(obj, color, thickness, transparency)
    return New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function Gradient(obj, colorSeq, rotation, transparency)
    return New("UIGradient", {
        Color = colorSeq,
        Rotation = rotation or 0,
        Transparency = transparency
    }, obj)
end

local function Tween(obj, time, props, style, direction)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(
            Cfg.Animate and (time or 0.2) or 0,
            style or Enum.EasingStyle.Quart,
            direction or Enum.EasingDirection.Out
        ),
        props
    )

    t:Play()
    return t
end

--============================================================
-- NEON
--============================================================

local function NeonLayers(parent, radius, color, specs)
    local list = {}

    for i, s in ipairs(specs) do
        local f = New("Frame", {
            Name = "NeonLayer" .. i,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = i,
        }, parent)

        Corner(f, radius)

        local st = New("UIStroke", {
            Color = color,
            Thickness = s[1],
            Transparency = s[2],
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, f)

        table.insert(list, {
            Frame = f,
            Stroke = st,
            Bright = s[2],
            Dim = s[3]
        })
    end

    return list
end

local SpinTweens = {}

local function Spin(grad, seconds)
    grad.Rotation = 0

    local t = TweenService:Create(
        grad,
        TweenInfo.new(
            seconds,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.In,
            -1
        ),
        {
            Rotation = 360
        }
    )

    t:Play()
    table.insert(SpinTweens, t)

    return t
end

local function BuildNeonSequence(c)
    local h, s, v = Color3.toHSV(c)

    return ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            Color3.fromHSV(h, s, math.min(v + 0.35, 1))
        ),

        ColorSequenceKeypoint.new(
            0.25,
            Color3.fromHSV(
                h,
                math.max(s - 0.35, 0),
                math.min(v + 0.55, 1)
            )
        ),

        ColorSequenceKeypoint.new(0.5, c),

        ColorSequenceKeypoint.new(
            0.75,
            Color3.fromHSV(
                h,
                s,
                math.max(v - 0.55, 0.1)
            )
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromHSV(
                h,
                s,
                math.min(v + 0.35, 1)
            )
        ),
    })
end

local function BuildLineSequence(c)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, c),
        ColorSequenceKeypoint.new(0.25, COLOR.border),
        ColorSequenceKeypoint.new(1, COLOR.border),
    })
end

local NeonSequence = BuildNeonSequence(COLOR.red)

--============================================================
-- THEME REGISTRY
--============================================================

local function RegisterFill(obj, shade)
    table.insert(ThemedFill, {
        Obj = obj,
        Shade = shade
    })
end

local function RegisterText(obj, shade)
    table.insert(ThemedText, {
        Obj = obj,
        Shade = shade
    })
end

local function RegisterStroke(obj, shade)
    table.insert(ThemedStroke, {
        Obj = obj,
        Shade = shade
    })
end

--============================================================
-- ROOT GUI
--============================================================

local old = PlayerGui:FindFirstChild(WINDOW_NAME)

if old then
    old:Destroy()
end

local Gui = New("ScreenGui", {
    Name = WINDOW_NAME,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local function Viewport()
    local s = Gui.AbsoluteSize

    if s.X < 50 or s.Y < 50 then
        local cam = workspace.CurrentCamera
        s = cam and cam.ViewportSize or Vector2.new(1280, 720)
    end

    return s
end

--============================================================
-- PANEL SIZE / POSITION
--============================================================

local PanelSize
local PanelPos

local function ClampSize(w, h)
    local vp = Viewport()

    local maxW = math.min(SIZE.maxW, vp.X - 8)
    local maxH = math.min(SIZE.maxH, vp.Y - 8)

    local minW = math.min(SIZE.minW, maxW)
    local minH = math.min(SIZE.minH, maxH)

    return
        math.clamp(w, minW, maxW),
        math.clamp(h, minH, maxH)
end

local function ClampPos(x, y)
    local vp = Viewport()

    return
        math.clamp(
            x,
            0,
            math.max(0, vp.X - PanelSize.X)
        ),

        math.clamp(
            y,
            0,
            math.max(0, vp.Y - PanelSize.Y)
        )
end

do
    local cw, ch = ClampSize(
        SIZE.defW,
        SIZE.defH
    )

    PanelSize = Vector2.new(cw, ch)

    PanelPos = Vector2.new(
        (Viewport().X - cw) / 2,
        (Viewport().Y - ch) / 2
    )
end

local Root = New("Frame", {
    Name = "Root",
    Position = UDim2.fromOffset(
        PanelPos.X,
        PanelPos.Y
    ),
    Size = UDim2.fromOffset(
        PanelSize.X,
        PanelSize.Y
    ),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
}, Gui)

local function ApplyPanel()
    Root.Size = UDim2.fromOffset(
        PanelSize.X,
        PanelSize.Y
    )

    Root.Position = UDim2.fromOffset(
        PanelPos.X,
        PanelPos.Y
    )
end

local function SetPanelPos(v)
    local x, y = ClampPos(
        v.X,
        v.Y
    )

    PanelPos = Vector2.new(x, y)

    Root.Position = UDim2.fromOffset(
        x,
        y
    )
end

local function SetPanelSize(w, h)
    local cw, ch = ClampSize(w, h)

    PanelSize = Vector2.new(
        cw,
        ch
    )

    Root.Size = UDim2.fromOffset(
        cw,
        ch
    )

    SetPanelPos(PanelPos)
end

local function FitPanel(w, h, recenter)
    local cw, ch = ClampSize(w, h)

    PanelSize = Vector2.new(
        cw,
        ch
    )

    local vp = Viewport()

    if recenter then
        PanelPos = Vector2.new(
            (vp.X - cw) / 2,
            (vp.Y - ch) / 2
        )
    else
        local x, y = ClampPos(
            PanelPos.X,
            PanelPos.Y
        )

        PanelPos = Vector2.new(x, y)
    end

    Tween(Root, 0.25, {
        Size = UDim2.fromOffset(
            PanelSize.X,
            PanelSize.Y
        ),

        Position = UDim2.fromOffset(
            PanelPos.X,
            PanelPos.Y
        ),
    })
end

--============================================================
-- MAIN FRAME
--============================================================

local MainGlow = NeonLayers(
    Root,
    16,
    COLOR.neon,
    {
        { 3, 0.70, 0.82 },
        { 7, 0.82, 0.90 },
        { 12, 0.90, 0.95 },
        { 18, 0.95, 0.98 },
    }
)

local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLOR.black,
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 10,
}, Root)

Corner(Main, 16)

Gradient(Main, ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLOR.black2),
    ColorSequenceKeypoint.new(0.55, COLOR.black),
    ColorSequenceKeypoint.new(
        1,
        Color3.fromRGB(6, 6, 8)
    ),
}), 65)

local MainStroke = Stroke(
    Main,
    COLOR.neon,
    2,
    0
)

local MainStrokeGrad = Gradient(
    MainStroke,
    NeonSequence,
    0
)

Spin(MainStrokeGrad, 5)

--============================================================
-- SIDEBAR
--============================================================

local Sidebar = New("Frame", {
    Position = UDim2.new(0, 2, 0, 4),
    Size = UDim2.new(0, 145, 1, -6),
    BackgroundColor3 = COLOR.sidebar,
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 11,
}, Main)

Corner(Sidebar, 14)

Gradient(Sidebar, ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLOR.sidebar2),
    ColorSequenceKeypoint.new(1, COLOR.sidebar),
}), 80)

New("Frame", {
    Position = UDim2.new(1, -1, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = COLOR.border,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ZIndex = 15,
}, Sidebar)

-- Single non-overlapping logo/title label.
-- RichText keeps DX red and Panel white without creating two labels
-- at overlapping positions.
local DXTitle = New("TextLabel", {
    Position = UDim2.new(0, 15, 0, 12),
    Size = UDim2.new(1, -30, 0, 38),
    BackgroundTransparency = 1,
    Text = '<font color="rgb(235,30,52)">' .. tostring(TITLE_TEXT) .. '</font> <font color="rgb(245,245,250)">' .. tostring(SUBTITLE_TEXT) .. '</font>',
    RichText = true,
    Font = Enum.Font.GothamBlack,
    TextSize = 26,
    TextColor3 = COLOR.white,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 20,
}, Sidebar)

-- Do not register this RichText label in the theme registry; its two
-- embedded colors are intentional.

local LogoLine = New("Frame", {
    Position = UDim2.new(0, 15, 0, 49),
    Size = UDim2.fromOffset(35, 2),
    BackgroundColor3 = COLOR.red,
    BorderSizePixel = 0,
    ZIndex = 20,
}, Sidebar)

Corner(LogoLine, 2)

Gradient(LogoLine, ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLOR.redBright),
    ColorSequenceKeypoint.new(1, COLOR.redDark),
}), 0)

local Online = New("TextLabel", {
    Position = UDim2.new(0, 15, 0, 55),
    Size = UDim2.new(1, -30, 0, 18),
    BackgroundTransparency = 1,
    Text = "●  ONLINE",
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(100, 220, 125),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 20,
}, Sidebar)

task.spawn(function()
    while Online.Parent do
        Tween(
            Online,
            1.0,
            {
                TextTransparency = 0.55
            },
            Enum.EasingStyle.Sine
        )

        task.wait(1)

        Tween(
            Online,
            1.0,
            {
                TextTransparency = 0
            },
            Enum.EasingStyle.Sine
        )

        task.wait(1)
    end
end)

local TabHolder = New("Frame", {
    Position = UDim2.new(0, 9, 0, 88),
    Size = UDim2.new(1, -18, 1, -98),
    BackgroundTransparency = 1,
    ZIndex = 20,
}, Sidebar)

New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
}, TabHolder)

--============================================================
-- CONTENT / HEADER
--============================================================

local Content = New("Frame", {
    Position = UDim2.new(0, 145, 0, 4),
    Size = UDim2.new(1, -145, 1, -6),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 11,
}, Main)

local Header = New("Frame", {
    Position = UDim2.new(0, 15, 0, 9),
    Size = UDim2.new(1, -30, 0, 38),
    BackgroundTransparency = 1,
    Active = true,
    ZIndex = 25,
}, Content)

local Title = New("TextLabel", {
    Size = UDim2.new(1, -55, 0, 22),
    BackgroundTransparency = 1,
    Text = "Dashboard",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = COLOR.white,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 30,
}, Header)

New("TextLabel", {
    Position = UDim2.new(0, 0, 0, 21),
    Size = UDim2.new(1, -55, 0, 14),
    BackgroundTransparency = 1,
    Text = DESCRIPTION_TEXT,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = COLOR.grey,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 30,
}, Header)

local Close = New("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 2),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = Color3.fromRGB(24, 19, 23),
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = COLOR.grey,
    ZIndex = 100,
}, Header)

Corner(Close, 9)

local CloseStroke = Stroke(
    Close,
    COLOR.border,
    1,
    0.1
)

Close.MouseEnter:Connect(function()
    Tween(Close, 0.15, {
        BackgroundColor3 = Color3.fromRGB(70, 12, 20),
        TextColor3 = COLOR.redBright,
        Rotation = 90
    })

    Tween(CloseStroke, 0.15, {
        Color = COLOR.red
    })
end)

Close.MouseLeave:Connect(function()
    Tween(Close, 0.15, {
        BackgroundColor3 = Color3.fromRGB(24, 19, 23),
        TextColor3 = COLOR.grey,
        Rotation = 0
    })

    Tween(CloseStroke, 0.15, {
        Color = COLOR.border
    })
end)

local PageHolder = New("Frame", {
    Position = UDim2.new(0, 15, 0, 57),
    Size = UDim2.new(1, -30, 1, -69),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 15,
}, Content)

local Pages = {}
local Tabs = {}
local FirstTabName = nil
local ActivateTab

--============================================================
-- PAGE
--============================================================

local function CreatePage(name)
    local Page = New("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = COLOR.red,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
    }, PageHolder)

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    }, Page)

    local Layout = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Page)

    Layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(
            0,
            Layout.AbsoluteContentSize.Y + 10
        )
    end)

    table.insert(ThemedFill, {
        Obj = Page,
        Shade = "red",
        Prop = "ScrollBarImageColor3"
    })

    Pages[name] = Page

    return Page
end

--============================================================
-- CUSTOM ICON BUILDERS
-- ยังคงอยู่ตามระบบเดิม
--============================================================

local function BuildHouseIcon(parent, color)
    local Wrap = New("Frame", {
        Position = UDim2.new(0, 9, 0.5, -9),
        Size = UDim2.fromOffset(19, 19),
        BackgroundTransparency = 1,
        ZIndex = 40,
    }, parent)

    local RoofClip = New("Frame", {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromOffset(19, 9),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 41,
    }, Wrap)

    local Roof = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 1, -1),
        Size = UDim2.fromOffset(13, 13),
        Rotation = 45,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = 41,
    }, RoofClip)

    Corner(Roof, 3)

    local Chimney = New("Frame", {
        Position = UDim2.new(0, 13, 0, 0),
        Size = UDim2.fromOffset(3, 6),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = 39,
    }, Wrap)

    Corner(Chimney, 1)

    local Body = New("Frame", {
        Position = UDim2.new(0, 2, 0, 8),
        Size = UDim2.fromOffset(15, 11),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = 41,
    }, Wrap)

    Corner(Body, 3)

    local Door = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 1, 1, 0),
        Size = UDim2.fromOffset(4, 7),
        BackgroundColor3 = COLOR.black,
        BorderSizePixel = 0,
        ZIndex = 42,
    }, Body)

    Corner(Door, 1)

    local Window = New("Frame", {
        Position = UDim2.new(0, 3, 0, 2),
        Size = UDim2.fromOffset(4, 4),
        BackgroundColor3 = COLOR.black,
        BorderSizePixel = 0,
        ZIndex = 42,
    }, Body)

    Corner(Window, 1)

    return Wrap, {
        Roof,
        Chimney,
        Body
    }
end

local function BuildGearIcon(parent, color)
    local Wrap = New("Frame", {
        Position = UDim2.new(0, 9, 0.5, -9),
        Size = UDim2.fromOffset(19, 19),
        BackgroundTransparency = 1,
        ZIndex = 40,
    }, parent)

    local parts = {}

    for i = 1, 8 do
        local Tooth = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(4, 18),
            Rotation = (i - 1) * 45,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            ZIndex = 40,
        }, Wrap)

        Corner(Tooth, 2)

        table.insert(parts, Tooth)
    end

    local Ring = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(13, 13),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = 41,
    }, Wrap)

    Corner(Ring, 7)

    table.insert(parts, Ring)

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(5, 5),
        BackgroundColor3 = COLOR.black,
        BorderSizePixel = 0,
        ZIndex = 42,
    }, Wrap)

    return Wrap, parts
end

--============================================================
-- TAB
--============================================================

local function CreateTab(name, icon)
    local Button = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(24, 19, 23),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = #Tabs + 1,
        ZIndex = 30,
    }, TabHolder)

    Corner(Button, 9)

    Gradient(Button, ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            Color3.fromRGB(75, 12, 20)
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromRGB(50, 8, 14)
        ),
    }), 90)

    local Bar = New("Frame", {
        Position = UDim2.new(0, 0, 0.5, -9),
        Size = UDim2.fromOffset(3, 18),
        BackgroundColor3 = COLOR.red,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 40,
    }, Button)

    Corner(Bar, 3)

    local iconTable =
        type(icon) == "table"
        and icon
        or nil

    local iconStr =
        iconTable
        and iconTable.Id
        or icon

    local isImage =
        type(iconStr) == "string"
        and (
            iconStr:match("^rbxassetid://")
            or iconStr:match("^https?://")
            or iconStr:match("^%d+$")
        )

    local isCustom =
        iconStr == "house"
        or iconStr == "gear"

    local Icon
    local iconParts

    if isCustom then

        local builder =
            iconStr == "house"
            and BuildHouseIcon
            or BuildGearIcon

        Icon, iconParts =
            builder(
                Button,
                COLOR.grey
            )

    elseif isImage then

        local imageId =
            iconStr:match("^%d+$")
            and ("rbxassetid://" .. iconStr)
            or iconStr

        Icon = New("ImageLabel", {
            Position = UDim2.new(0, 11, 0.5, -9),
            Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1,

            Image = imageId,

            ImageColor3 = COLOR.grey,

            ImageRectOffset =
                iconTable
                and iconTable.Rect
                or nil,

            ImageRectSize =
                iconTable
                and iconTable.Size
                or nil,

            ZIndex = 40,
        }, Button)

    else

        Icon = New("TextLabel", {
            Position = UDim2.new(0, 11, 0, 0),
            Size = UDim2.fromOffset(20, 36),
            BackgroundTransparency = 1,
            Text = icon,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = COLOR.grey,
            ZIndex = 40,
        }, Button)

    end

    local Label = New("TextLabel", {
        Position = UDim2.new(0, 37, 0, 0),
        Size = UDim2.new(1, -42, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = COLOR.grey,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 40,
    }, Button)

    Tabs[name] = {
        Button = Button,
        Icon = Icon,
        Label = Label,
        Bar = Bar,
        IsImage = isImage,
        IsCustom = isCustom,
        IconParts = iconParts
    }

    Button.MouseEnter:Connect(function()
        if not Button:GetAttribute("Active") then
            Tween(Button, 0.15, {
                BackgroundTransparency = 0.72
            })

            Tween(Label, 0.15, {
                TextColor3 = COLOR.white
            })
        end
    end)

    Button.MouseLeave:Connect(function()
        if not Button:GetAttribute("Active") then
            Tween(Button, 0.15, {
                BackgroundTransparency = 1
            })

            Tween(Label, 0.15, {
                TextColor3 = COLOR.grey
            })
        end
    end)

    Button.MouseButton1Click:Connect(function()
        ActivateTab(name)
    end)

    if not FirstTabName then
        FirstTabName = name
        ActivateTab(name)
    end

    return Button
end

ActivateTab = function(name)
    for tabName, tab in pairs(Tabs) do
        local active = tabName == name

        tab.Button:SetAttribute(
            "Active",
            active
        )

        Tween(tab.Button, 0.18, {
            BackgroundTransparency =
                active and 0.15 or 1
        })

        if tab.IsCustom then

            for _, part in ipairs(tab.IconParts) do
                Tween(part, 0.18, {
                    BackgroundColor3 =
                        active
                        and COLOR.redSoft
                        or COLOR.grey
                })
            end

        elseif tab.IsImage then

            Tween(tab.Icon, 0.18, {
                ImageColor3 =
                    active
                    and COLOR.redSoft
                    or COLOR.grey
            })

        else

            Tween(tab.Icon, 0.18, {
                TextColor3 =
                    active
                    and COLOR.redSoft
                    or COLOR.grey
            })

        end

        Tween(tab.Label, 0.18, {
            TextColor3 =
                active
                and COLOR.white
                or COLOR.grey
        })

        Tween(tab.Bar, 0.18, {
            BackgroundTransparency =
                active and 0 or 1
        })

        if Pages[tabName] then
            Pages[tabName].Visible = active
        end

        if active then
            Title.Text = tabName
        end
    end
end

--============================================================
-- SECTION
--============================================================

local function Section(parent, text)
    local Holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 29),
        BackgroundTransparency = 1
    }, parent)

    local Label = New("TextLabel", {
        Position = UDim2.new(0, 3, 0, 5),
        Size = UDim2.new(1, -6, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = COLOR.redSoft,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Holder)

    RegisterText(Label, "redSoft")

    local Line = New("Frame", {
        Position = UDim2.new(0, 3, 1, -1),
        Size = UDim2.new(1, -6, 0, 1),
        BackgroundColor3 = COLOR.border,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
    }, Holder)

    local LineGrad = Gradient(
        Line,
        BuildLineSequence(COLOR.red),
        0
    )

    table.insert(
        ThemedLineGrad,
        LineGrad
    )

    return Holder
end

--============================================================
-- BUTTON
--============================================================

local function Button(parent, text, callback)
    local Btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = COLOR.innerBg,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 50,
    }, parent)

    Corner(Btn, 10)

    local S = Stroke(
        Btn,
        COLOR.innerBorder,
        1.5,
        0
    )

    local Accent = New("Frame", {
        Position = UDim2.new(0, 8, 0, 6),
        Size = UDim2.new(0, 3, 1, -12),
        BackgroundColor3 = COLOR.redBright,
        BorderSizePixel = 0,
        ZIndex = 55,
    }, Btn)

    Corner(Accent, 3)

    local Dot = New("Frame", {
        Position = UDim2.new(0, 18, 0.5, -3),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = COLOR.redBright,
        BorderSizePixel = 0,
        ZIndex = 55,
    }, Btn)

    Corner(Dot, 6)

    local Label = New("TextLabel", {
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -42, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = COLOR.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 60,
    }, Btn)

    local function SetVisual(hover)
        Tween(Btn, 0.15, {
            BackgroundColor3 =
                hover
                and COLOR.innerBgHover
                or COLOR.innerBg
        })

        Tween(S, 0.15, {
            Color =
                hover
                and COLOR.innerBorderHover
                or COLOR.innerBorder,

            Thickness =
                hover
                and 1.8
                or 1.5
        })

        Tween(Accent, 0.15, {
            BackgroundColor3 =
                hover
                and COLOR.redSoft
                or COLOR.redBright
        })

        Tween(Dot, 0.15, {
            BackgroundColor3 =
                hover
                and COLOR.redSoft
                or COLOR.redBright
        })

        Tween(Label, 0.15, {
            TextColor3 =
                hover
                and Color3.fromRGB(255, 255, 255)
                or COLOR.white
        })
    end

    Btn.MouseEnter:Connect(function()
        SetVisual(true)
    end)

    Btn.MouseLeave:Connect(function()
        SetVisual(false)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(callback)
        end
    end)

    table.insert(ThemedButtons, {
        Stroke = S,
        Accent = Accent,
        Dot = Dot
    })

    return Btn
end

--============================================================
-- TOGGLE
--============================================================

local function Toggle(parent, text, enabled, callback)
    local state = enabled == true

    local Holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = COLOR.innerBg,
        BorderSizePixel = 0,
        ZIndex = 50,
    }, parent)

    Corner(Holder, 10)

    local HolderStroke = Stroke(
        Holder,
        COLOR.innerBorder,
        1.5,
        0
    )

    local Accent = New("Frame", {
        Position = UDim2.new(0, 8, 0, 6),
        Size = UDim2.new(0, 3, 1, -12),
        BackgroundColor3 = COLOR.redBright,
        BorderSizePixel = 0,
        ZIndex = 55,
    }, Holder)

    Corner(Accent, 3)

    New("TextLabel", {
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -88, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = COLOR.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 60,
    }, Holder)

    local Switch = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = COLOR.switchOff,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 70,
    }, Holder)

    Corner(Switch, 12)

    local SwitchStroke = Stroke(
        Switch,
        COLOR.switchBorder,
        1.4,
        0
    )

    local Knob = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.fromRGB(210, 210, 215),
        BorderSizePixel = 0,
        ZIndex = 75,
    }, Switch)

    Corner(Knob, 20)

    local function Update()
        if state then

            Tween(Switch, 0.18, {
                BackgroundColor3 = COLOR.red
            })

            Tween(SwitchStroke, 0.18, {
                Color = COLOR.redBright,
                Thickness = 1.6
            })

            Tween(Knob, 0.18, {
                Position = UDim2.new(
                    1,
                    -19,
                    0.5,
                    0
                ),

                BackgroundColor3 =
                    Color3.fromRGB(
                        255,
                        255,
                        255
                    )
            })

            Tween(HolderStroke, 0.18, {
                Color = COLOR.red,
                Thickness = 1.7
            })

            Tween(Accent, 0.18, {
                BackgroundColor3 = COLOR.redSoft
            })

        else

            Tween(Switch, 0.18, {
                BackgroundColor3 =
                    COLOR.switchOff
            })

            Tween(SwitchStroke, 0.18, {
                Color = COLOR.switchBorder,
                Thickness = 1.4
            })

            Tween(Knob, 0.18, {
                Position = UDim2.new(
                    0,
                    3,
                    0.5,
                    0
                ),

                BackgroundColor3 =
                    Color3.fromRGB(
                        190,
                        190,
                        195
                    )
            })

            Tween(HolderStroke, 0.18, {
                Color = COLOR.innerBorder,
                Thickness = 1.5
            })

            Tween(Accent, 0.18, {
                BackgroundColor3 =
                    COLOR.redBright
            })
        end
    end

    Holder.MouseEnter:Connect(function()
        if not state then

            Tween(Holder, 0.15, {
                BackgroundColor3 =
                    COLOR.innerBgHover
            })

            Tween(HolderStroke, 0.15, {
                Color = COLOR.redBright,
                Thickness = 1.7
            })
        end
    end)

    Holder.MouseLeave:Connect(function()
        if not state then

            Tween(Holder, 0.15, {
                BackgroundColor3 =
                    COLOR.innerBg
            })

            Tween(HolderStroke, 0.15, {
                Color = COLOR.innerBorder,
                Thickness = 1.5
            })
        end
    end)

    local api = {}

    function api.Get()
        return state
    end

    function api.Set(value, silent)
        state = value == true

        Update()

        if callback and not silent then
            task.spawn(
                callback,
                state
            )
        end
    end

    Switch.MouseButton1Click:Connect(function()
        api.Set(not state)
    end)

    Update()

    table.insert(ThemedToggles, {
        Holder = Holder,
        Stroke = HolderStroke,
        Accent = Accent,
        Switch = Switch,
        SwitchStroke = SwitchStroke,
        GetState = api.Get,
    })

    return Holder, api
end

--============================================================
-- DROPDOWN
--============================================================

local function Dropdown(parent, text, options, default, callback)
    options = options or {}

    local selected = default or options[1]
    local open = false

    local function OptionsHeight()
        local n = #options
        if n == 0 then return 0 end
        return (n * 30) + ((n - 1) * 4)
    end

    local function ClosedHeight()
        return 42
    end

    local function OpenedHeight()
        return 42 + 8 + OptionsHeight()
    end

    local Holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, ClosedHeight()),
        BackgroundColor3 = COLOR.innerBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 50,
    }, parent)

    Corner(Holder, 10)

    local HolderStroke = Stroke(
        Holder,
        COLOR.innerBorder,
        1.5,
        0
    )

    local Accent = New("Frame", {
        Position = UDim2.new(0, 8, 0, 6),
        Size = UDim2.new(0, 3, 0, 30),
        BackgroundColor3 = COLOR.redBright,
        BorderSizePixel = 0,
        ZIndex = 55,
    }, Holder)

    Corner(Accent, 3)

    New("TextLabel", {
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -120, 0, 42),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = COLOR.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 60,
    }, Holder)

    local ValueLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -34, 0, 0),
        Size = UDim2.new(0, 90, 0, 42),
        BackgroundTransparency = 1,
        Text = tostring(selected or "—"),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COLOR.redSoft,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 60,
    }, Holder)

    local Arrow = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0, 21),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        Text = "\226\150\190",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLOR.grey,
        ZIndex = 60,
    }, Holder)

    local List = New("Frame", {
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 0, OptionsHeight()),
        BackgroundTransparency = 1,
        ZIndex = 55,
    }, Holder)

    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, List)

    local SetOpen

    local ClickArea = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 65,
    }, Holder)

    ClickArea.MouseButton1Click:Connect(function()
        SetOpen(not open)
    end)

    Holder.MouseEnter:Connect(function()
        if not open then
            Tween(HolderStroke, 0.15, {
                Color = COLOR.innerBorderHover
            })
        end
    end)

    Holder.MouseLeave:Connect(function()
        if not open then
            Tween(HolderStroke, 0.15, {
                Color = COLOR.innerBorder
            })
        end
    end)

    local optionButtons = {}

    for i, opt in ipairs(options) do
        local OptBtn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = COLOR.innerBg,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = i,
            ZIndex = 56,
        }, List)

        Corner(OptBtn, 8)

        local OptStroke = Stroke(
            OptBtn,
            COLOR.innerBorder,
            1,
            0
        )

        local OptLabel = New("TextLabel", {
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(opt),
            Font = Enum.Font.GothamMedium,
            TextSize = 10,
            TextColor3 = COLOR.grey,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 57,
        }, OptBtn)

        OptBtn.MouseEnter:Connect(function()
            Tween(OptBtn, 0.12, {
                BackgroundColor3 = COLOR.innerBgHover
            })

            Tween(OptStroke, 0.12, {
                Color = COLOR.innerBorderHover
            })

            Tween(OptLabel, 0.12, {
                TextColor3 = COLOR.white
            })
        end)

        OptBtn.MouseLeave:Connect(function()
            Tween(OptBtn, 0.12, {
                BackgroundColor3 = COLOR.innerBg
            })

            Tween(OptStroke, 0.12, {
                Color = COLOR.innerBorder
            })

            Tween(OptLabel, 0.12, {
                TextColor3 = COLOR.grey
            })
        end)

        OptBtn.MouseButton1Click:Connect(function()
            selected = opt
            ValueLabel.Text = tostring(opt)
            SetOpen(false)

            if callback then
                task.spawn(callback, opt)
            end
        end)

        table.insert(optionButtons, {
            Btn = OptBtn,
            Stroke = OptStroke,
            Label = OptLabel,
        })
    end

    SetOpen = function(state)
        open = state

        Tween(Holder, 0.2, {
            Size = UDim2.new(
                1, 0, 0,
                open and OpenedHeight() or ClosedHeight()
            )
        }, Enum.EasingStyle.Quart)

        Tween(Arrow, 0.2, {
            Rotation = open and 180 or 0
        })

        Tween(HolderStroke, 0.2, {
            Color = open and COLOR.redBright or COLOR.innerBorder,
            Thickness = open and 1.7 or 1.5
        })

        Tween(Accent, 0.2, {
            BackgroundColor3 = open and COLOR.redSoft or COLOR.redBright
        })
    end

    table.insert(ThemedDropdowns, {
        Holder = Holder,
        Stroke = HolderStroke,
        Accent = Accent,
        ValueLabel = ValueLabel,
        OptionButtons = optionButtons,
        GetOpen = function() return open end,
    })

    local api = {}

    function api.Get()
        return selected
    end

    function api.Set(value, silent)
        selected = value
        ValueLabel.Text = tostring(value)

        if callback and not silent then
            task.spawn(callback, value)
        end
    end

    return Holder, api
end


--============================================================
-- DRAG SYSTEM
--============================================================

local function Draggable(handle, opts)
    local dragging = false
    local moved = false

    local startInput
    local startPointer
    local startValue

    local function finish()
        if not dragging then
            return
        end

        dragging = false

        if not moved and opts.onClick then
            opts.onClick()
        end
    end

    handle.InputBegan:Connect(
        function(input)

            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            if opts.canStart
                and not opts.canStart() then
                return
            end

            dragging = true
            moved = false

            startInput = input

            startPointer =
                Vector2.new(
                    input.Position.X,
                    input.Position.Y
                )

            startValue = opts.get()

            input.Changed:Connect(
                function()
                    if input.UserInputState ==
                        Enum.UserInputState.End then
                        finish()
                    end
                end
            )
        end
    )

    UIS.InputChanged:Connect(
        function(input)
            if not dragging then
                return
            end

            local t =
                input.UserInputType

            if t ==
                Enum.UserInputType.MouseMovement
                or (
                    t ==
                        Enum.UserInputType.Touch
                    and input == startInput
                ) then

                local delta =
                    Vector2.new(
                        input.Position.X,
                        input.Position.Y
                    )
                    - startPointer

                if not moved
                    and delta.Magnitude < 5 then
                    return
                end

                moved = true

                opts.set(
                    startValue + delta
                )
            end
        end
    )

    UIS.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or (
                    input.UserInputType ==
                        Enum.UserInputType.Touch
                    and input == startInput
                ) then

                finish()
            end
        end
    )
end

--============================================================
-- FLOATING TOGGLE
--============================================================

local TOGGLE = 58

local ToggleCenter = Vector2.new(
    Viewport().X - 52,
    Viewport().Y * 0.72
)

local ToggleRoot = New("Frame", {
    Name = "FloatingToggle",

    AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        ),

    Position =
        UDim2.fromOffset(
            ToggleCenter.X,
            ToggleCenter.Y
        ),

    Size =
        UDim2.fromOffset(
            TOGGLE,
            TOGGLE
        ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ZIndex = 200,

}, Gui)

local ToggleGlow = NeonLayers(
    ToggleRoot,
    16,
    COLOR.neon,
    {
        { 3, 0.65, 0.80 },
        { 7, 0.80, 0.90 },
        { 12, 0.90, 0.96 },
    }
)

local ToggleButton = New("TextButton", {
    Name = "Body",

    Size =
        UDim2.fromScale(
            1,
            1
        ),

    BackgroundColor3 =
        Color3.fromRGB(
            10,
            10,
            14
        ),

    BorderSizePixel = 0,

    AutoButtonColor = false,

    Text = "",

    ZIndex = 10,

}, ToggleRoot)

Corner(
    ToggleButton,
    16
)

Gradient(
    ToggleButton,
    ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            Color3.fromRGB(
                26,
                12,
                16
            )
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromRGB(
                8,
                8,
                11
            )
        ),
    }),
    90
)

local ToggleStroke = Stroke(
    ToggleButton,
    COLOR.neon,
    2,
    0
)

local ToggleStrokeGrad = Gradient(
    ToggleStroke,
    NeonSequence,
    0
)

Spin(
    ToggleStrokeGrad,
    4
)

local ToggleLabel = New("TextLabel", {
    AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        ),

    Position =
        UDim2.new(
            0.5,
            0,
            0.5,
            -2
        ),

    Size =
        UDim2.fromScale(
            1,
            0.7
        ),

    BackgroundTransparency = 1,

    RichText = true,

    Text =
        TOGGLE_RICH_TEXT,

    Font =
        Enum.Font.GothamBlack,

    TextSize = 24,

    TextColor3 =
        COLOR.white,

    ZIndex = 12,

}, ToggleButton)

local ToggleLabelStroke = New("UIStroke", {
    Color = COLOR.neon,
    Thickness = 1.4,
    Transparency = 0.45,
    ApplyStrokeMode =
        Enum.ApplyStrokeMode.Contextual
}, ToggleLabel)

RegisterStroke(
    ToggleLabelStroke,
    "neon"
)

local ToggleBar = New("Frame", {
    AnchorPoint =
        Vector2.new(
            0.5,
            1
        ),

    Position =
        UDim2.new(
            0.5,
            0,
            1,
            -8
        ),

    Size =
        UDim2.fromOffset(
            22,
            2
        ),

    BackgroundColor3 =
        COLOR.neon,

    BorderSizePixel = 0,

    ZIndex = 12,

}, ToggleButton)

Corner(
    ToggleBar,
    2
)

Gradient(
    ToggleBar,
    ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            COLOR.redDark
        ),

        ColorSequenceKeypoint.new(
            0.5,
            COLOR.redSoft
        ),

        ColorSequenceKeypoint.new(
            1,
            COLOR.redDark
        ),
    }),
    0
)

local ToggleDot = New("Frame", {
    AnchorPoint =
        Vector2.new(
            1,
            0
        ),

    Position =
        UDim2.new(
            1,
            -7,
            0,
            7
        ),

    Size =
        UDim2.fromOffset(
            6,
            6
        ),

    BackgroundColor3 =
        COLOR.redBright,

    BorderSizePixel = 0,

    ZIndex = 12,

}, ToggleButton)

Corner(
    ToggleDot,
    6
)

local function SetToggleCenter(v)
    local vp = Viewport()

    local half =
        TOGGLE / 2 + 4

    ToggleCenter = Vector2.new(
        math.clamp(
            v.X,
            half,
            math.max(
                half,
                vp.X - half
            )
        ),

        math.clamp(
            v.Y,
            half,
            math.max(
                half,
                vp.Y - half
            )
        )
    )

    ToggleRoot.Position =
        UDim2.fromOffset(
            ToggleCenter.X,
            ToggleCenter.Y
        )
end

ToggleButton.MouseEnter:Connect(
    function()
        Tween(
            ToggleRoot,
            0.18,
            {
                Size =
                    UDim2.fromOffset(
                        TOGGLE + 6,
                        TOGGLE + 6
                    )
            }
        )

        Tween(
            ToggleStroke,
            0.18,
            {
                Thickness = 2.6
            }
        )
    end
)

ToggleButton.MouseLeave:Connect(
    function()
        Tween(
            ToggleRoot,
            0.18,
            {
                Size =
                    UDim2.fromOffset(
                        TOGGLE,
                        TOGGLE
                    )
            }
        )

        Tween(
            ToggleStroke,
            0.18,
            {
                Thickness = 2
            }
        )
    end
)

--============================================================
-- THEME COLOR
--============================================================

function Actions.SetThemeColor(newColor)
    local h, s, v =
        Color3.toHSV(newColor)

    COLOR.red = newColor
    COLOR.neon = newColor

    COLOR.redBright =
        Color3.fromHSV(
            h,
            0.55,
            1
        )

    COLOR.redSoft =
        Color3.fromHSV(
            h,
            0.35,
            1
        )

    local seq =
        BuildNeonSequence(
            newColor
        )

    local shadeMap = {
        red = newColor,
        redBright = COLOR.redBright,
        redSoft = COLOR.redSoft,
        neon = newColor
    }

    MainStroke.Color =
        newColor

    MainStrokeGrad.Color =
        seq

    ToggleStroke.Color =
        newColor

    ToggleStrokeGrad.Color =
        seq

    ToggleBar.BackgroundColor3 =
        newColor

    ToggleDot.BackgroundColor3 =
        COLOR.redBright

    for _, layer in ipairs(MainGlow) do
        layer.Stroke.Color =
            newColor
    end

    for _, layer in ipairs(ToggleGlow) do
        layer.Stroke.Color =
            newColor
    end

    LogoLine.BackgroundColor3 =
        newColor

    for _, tab in pairs(Tabs) do

        if tab.Button:GetAttribute(
            "Active"
        ) then

            if tab.IsCustom then

                for _, part in ipairs(
                    tab.IconParts
                ) do
                    part.BackgroundColor3 =
                        COLOR.redSoft
                end

            elseif tab.IsImage then

                tab.Icon.ImageColor3 =
                    COLOR.redSoft

            else

                tab.Icon.TextColor3 =
                    COLOR.redSoft

            end

            tab.Bar.BackgroundColor3 =
                newColor
        end
    end

    for _, b in ipairs(ThemedButtons) do

        Tween(
            b.Stroke,
            0.2,
            {
                Color =
                    COLOR.innerBorder
            }
        )

        Tween(
            b.Accent,
            0.2,
            {
                BackgroundColor3 =
                    COLOR.redBright
            }
        )

        Tween(
            b.Dot,
            0.2,
            {
                BackgroundColor3 =
                    COLOR.redBright
            }
        )
    end

    for _, t in ipairs(ThemedToggles) do

        if t.GetState() then

            Tween(
                t.Switch,
                0.2,
                {
                    BackgroundColor3 =
                        COLOR.red
                }
            )

            Tween(
                t.SwitchStroke,
                0.2,
                {
                    Color =
                        COLOR.redBright
                }
            )

            Tween(
                t.Stroke,
                0.2,
                {
                    Color =
                        newColor
                }
            )

            Tween(
                t.Accent,
                0.2,
                {
                    BackgroundColor3 =
                        COLOR.redSoft
                }
            )

        else

            Tween(
                t.Stroke,
                0.2,
                {
                    Color =
                        COLOR.innerBorder
                }
            )

            Tween(
                t.Accent,
                0.2,
                {
                    BackgroundColor3 =
                        COLOR.redBright
                }
            )
        end
    end

    for _, d in ipairs(ThemedDropdowns) do

        Tween(
            d.ValueLabel,
            0.2,
            {
                TextColor3 = COLOR.redSoft
            }
        )

        if d.GetOpen() then

            Tween(
                d.Stroke,
                0.2,
                {
                    Color = COLOR.redBright
                }
            )

            Tween(
                d.Accent,
                0.2,
                {
                    BackgroundColor3 = COLOR.redSoft
                }
            )

        else

            Tween(
                d.Stroke,
                0.2,
                {
                    Color = COLOR.innerBorder
                }
            )

            Tween(
                d.Accent,
                0.2,
                {
                    BackgroundColor3 = COLOR.redBright
                }
            )
        end
    end

    for _, e in ipairs(ThemedFill) do

        if e.Prop then

            Tween(
                e.Obj,
                0.2,
                {
                    [e.Prop] =
                        shadeMap[e.Shade]
                }
            )

        else

            Tween(
                e.Obj,
                0.2,
                {
                    BackgroundColor3 =
                        shadeMap[e.Shade]
                }
            )
        end
    end

    for _, e in ipairs(ThemedText) do

        Tween(
            e.Obj,
            0.2,
            {
                TextColor3 =
                    shadeMap[e.Shade]
            }
        )
    end

    for _, e in ipairs(ThemedStroke) do

        Tween(
            e.Obj,
            0.2,
            {
                Color =
                    shadeMap[e.Shade]
            }
        )
    end

    for _, g in ipairs(ThemedLineGrad) do
        g.Color =
            BuildLineSequence(
                newColor
            )
    end
end

--============================================================
-- OPEN / CLOSE
--============================================================

local PanelVisible = true
local Animating = false
local AnimToken = 0

local POP = 26

local function SetToggleState(open)
    Tween(
        ToggleDot,
        0.2,
        {
            BackgroundColor3 =
                open
                and COLOR.redBright
                or Color3.fromRGB(
                    90,
                    90,
                    100
                )
        }
    )

    Tween(
        ToggleLabel,
        0.2,
        {
            TextTransparency =
                open
                and 0
                or 0.4
        }
    )
end

local function OpenPanel()
    PanelVisible = true
    Animating = true

    AnimToken += 1

    local token =
        AnimToken

    Root.Visible = true

    Root.Size =
        UDim2.fromOffset(
            PanelSize.X - POP,
            PanelSize.Y - POP
        )

    Root.Position =
        UDim2.fromOffset(
            PanelPos.X + POP / 2,
            PanelPos.Y + POP / 2
        )

    Tween(
        Root,
        0.28,
        {
            Size =
                UDim2.fromOffset(
                    PanelSize.X,
                    PanelSize.Y
                ),

            Position =
                UDim2.fromOffset(
                    PanelPos.X,
                    PanelPos.Y
                ),
        },
        Enum.EasingStyle.Back
    )

    SetToggleState(true)

    task.delay(
        0.32,
        function()
            if token == AnimToken then
                Animating = false
                ApplyPanel()
            end
        end
    )
end

local function ClosePanel()
    PanelVisible = false
    Animating = true

    AnimToken += 1

    local token =
        AnimToken

    Tween(
        Root,
        0.2,
        {
            Size =
                UDim2.fromOffset(
                    PanelSize.X - POP,
                    PanelSize.Y - POP
                ),

            Position =
                UDim2.fromOffset(
                    PanelPos.X + POP / 2,
                    PanelPos.Y + POP / 2
                ),
        },
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
    )

    SetToggleState(false)

    task.delay(
        0.24,
        function()
            if token == AnimToken then
                Animating = false
                Root.Visible = false
                ApplyPanel()
            end
        end
    )
end

--============================================================
-- DRAG BINDINGS
--============================================================

local function CanMovePanel()
    return
        PanelVisible
        and not Animating
end

Draggable(
    ToggleButton,
    {
        get = function()
            return ToggleCenter
        end,

        set = SetToggleCenter,

        onClick = function()
            if PanelVisible then
                ClosePanel()
            else
                OpenPanel()
            end
        end,
    }
)

local PanelDrag = {
    get = function()
        return PanelPos
    end,

    set = SetPanelPos,

    canStart = CanMovePanel
}

Draggable(
    Header,
    PanelDrag
)

Draggable(
    Sidebar,
    PanelDrag
)

Close.MouseButton1Click:Connect(
    function()
        if PanelVisible then
            ClosePanel()
        end
    end
)

--============================================================
-- RESIZE HANDLE
--============================================================

local Resize = New("TextButton", {
    Name = "ResizeHandle",

    AnchorPoint =
        Vector2.new(
            1,
            1
        ),

    Position =
        UDim2.new(
            1,
            -2,
            1,
            -2
        ),

    Size =
        UDim2.fromOffset(
            28,
            28
        ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    AutoButtonColor = false,

    Text = "",

    ZIndex = 100,

}, Main)

Draggable(
    Resize,
    {
        get = function()
            return PanelSize
        end,

        set = function(v)
            SetPanelSize(
                v.X,
                v.Y
            )
        end,

        canStart = CanMovePanel,
    }
)

--============================================================
-- REFIT / PULSE
--============================================================

function Actions.Refit()
    SetPanelSize(
        PanelSize.X,
        PanelSize.Y
    )

    SetToggleCenter(
        ToggleCenter
    )
end

Gui:GetPropertyChangedSignal(
    "AbsoluteSize"
):Connect(
    Actions.Refit
)

Actions.Refit()

function Actions.SetPulse(on)
    Cfg.Pulse = on

    for _, t in ipairs(
        SpinTweens
    ) do

        if on then
            t:Play()
        else
            t:Pause()
        end

    end
end

local PulseList = {}

for _, layer in ipairs(
    MainGlow
) do
    table.insert(
        PulseList,
        layer
    )
end

for _, layer in ipairs(
    ToggleGlow
) do
    table.insert(
        PulseList,
        layer
    )
end

task.spawn(function()
    local dim = false

    while Gui.Parent do

        if Cfg.Pulse then

            for _, layer in ipairs(
                PulseList
            ) do

                Tween(
                    layer.Stroke,
                    1.2,
                    {
                        Transparency =
                            dim
                            and layer.Dim
                            or layer.Bright
                    },
                    Enum.EasingStyle.Sine
                )
            end
        end

        dim = not dim

        task.wait(1.2)
    end
end)

    --========================================================
    -- PUBLIC API
    --========================================================

    local Window = {
        ScreenGui = Gui,
        Root = Root,
    }

    -- Create a tab (sidebar entry + its own scrollable content page).
    -- icon: "house" / "gear" (built-in vector icons), an image id/url,
    -- or any short text string to use as a text icon.
    function Window:CreateTab(name, icon)
        local Page = CreatePage(name)
        CreateTab(name, icon)

        local Tab = {
            Name = name,
            Page = Page,
        }

        function Tab:Section(text)
            return Section(self.Page, text)
        end

        function Tab:Button(text, callback)
            return Button(self.Page, text, callback)
        end

        function Tab:Toggle(text, default, callback)
            return Toggle(self.Page, text, default, callback)
        end

        function Tab:Dropdown(text, options, default, callback)
            return Dropdown(self.Page, text, options, default, callback)
        end

        return Tab
    end

    -- Re-tint the whole panel (accent color, glows, active tab, etc).
    function Window:SetThemeColor(color3)
        Actions.SetThemeColor(color3)
    end

    -- Turn the ambient neon pulse animation on/off.
    function Window:SetPulse(on)
        Actions.SetPulse(on)
    end

    -- Re-apply current size/position (e.g. after the viewport changes).
    function Window:Refit()
        Actions.Refit()
    end

    function Window:Open()
        OpenPanel()
    end

    function Window:Close()
        ClosePanel()
    end

    -- Fully removes the panel and its floating toggle from PlayerGui.
    function Window:Destroy()
        Gui:Destroy()
    end

    --========================================================
    -- BUILT-IN TABS
    -- Overview and Settings belong to the Library itself.
    -- External GitHub scripts should only create their own tabs.
    --========================================================

    do
        local Overview = Window:CreateTab("Overview", "house")
        Overview:Section("DX PANEL")
        Overview:Button("Library loaded", function()
            print("DXPanel Library loaded")
        end)

        local Settings = Window:CreateTab("Settings", "gear")
        Settings:Section("PANEL SETTINGS")
        Settings:Toggle("Neon Pulse", true, function(state)
            Actions.SetPulse(state)
        end)
        Settings:Button("Open Panel", function()
            OpenPanel()
        end)
        Settings:Button("Close Panel", function()
            ClosePanel()
        end)
    end

    return Window
end

return DXPanel
