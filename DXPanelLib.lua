--============================================================
-- DXPanel NEON RED / BLACK — SIMPLE EDIT VERSION (+ Theme Color v3)
-- ICON UPDATED ONLY
--============================================================

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================
-- CONFIG
--============================================================

local SIZE = {
    minW = 400, minH = 250,
    maxW = 850, maxH = 560,
    defW = 600, defH = 370,
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

local ThemedButtons  = {}
local ThemedToggles  = {}
local ThemedFill     = {}
local ThemedText     = {}
local ThemedStroke   = {}
local ThemedLineGrad = {}

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

local old = PlayerGui:FindFirstChild("DXPanel")

if old then
    old:Destroy()
end

local Gui = New("ScreenGui", {
    Name = "DXPanel",
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

local DXTitle = New("TextLabel", {
    Position = UDim2.new(0, 15, 0, 15),
    Size = UDim2.new(1, -30, 0, 28),
    BackgroundTransparency = 1,
    Text = "DX",
    Font = Enum.Font.GothamBlack,
    TextSize = 26,
    TextColor3 = COLOR.red,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 20,
}, Sidebar)

RegisterText(DXTitle, "red")

New("TextLabel", {
    Position = UDim2.new(0, 52, 0, 18),
    Size = UDim2.new(1, -60, 0, 22),
    BackgroundTransparency = 1,
    Text = "PANEL",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = COLOR.white,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 20,
}, Sidebar)

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
    Text = "DXPanel Premium Interface",
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

local ActivateTab

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

    -- Activated works for mouse, touch, and gamepad.
    Button.Activated:Connect(function()
        ActivateTab(name)
    end)

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
-- OVERVIEW
--============================================================

do
    local Overview = CreatePage("Overview")

    -- ICON 1
    CreateTab(
        "Overview",
        "124620632231839"
    )

    Section(
        Overview,
        "OVERVIEW"
    )

    local Card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = COLOR.innerBg,
        BorderSizePixel = 0,
        ZIndex = 50,
    }, Overview)

    Corner(Card, 12)

    Stroke(
        Card,
        COLOR.innerBorder,
        1.5,
        0
    )

    Gradient(Card, ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            COLOR.innerBgHover
        ),

        ColorSequenceKeypoint.new(
            1,
            COLOR.innerBg
        ),
    }), 90)

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
    }, Card)

    New("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Card)

    local HeaderRow = New("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        LayoutOrder = 1
    }, Card)

    local Avatar = New("ImageLabel", {
        Size = UDim2.fromOffset(64, 64),
        BackgroundColor3 = COLOR.black,
        BorderSizePixel = 0,
        ZIndex = 55,
    }, HeaderRow)

    Corner(Avatar, 32)

    local AvatarStroke = Stroke(
        Avatar,
        COLOR.red,
        2,
        0
    )

    RegisterStroke(
        AvatarStroke,
        "red"
    )

    New("TextLabel", {
        Position = UDim2.new(0, 78, 0, 2),
        Size = UDim2.new(1, -160, 0, 22),
        BackgroundTransparency = 1,
        Text = Player.DisplayName,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = COLOR.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 55,
    }, HeaderRow)

    New("TextLabel", {
        Position = UDim2.new(0, 78, 0, 25),
        Size = UDim2.new(1, -160, 0, 16),
        BackgroundTransparency = 1,
        Text = "@" .. Player.Name,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = COLOR.grey,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 55,
    }, HeaderRow)

    New("TextLabel", {
        Position = UDim2.new(0, 78, 0, 45),
        Size = UDim2.new(1, -160, 0, 14),
        BackgroundTransparency = 1,
        Text = "Account Age: " .. Player.AccountAge .. " days",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = COLOR.grey,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 55,
    }, HeaderRow)

    local Badge = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 4),
        Size = UDim2.fromOffset(74, 20),
        BackgroundColor3 = Color3.fromRGB(15, 35, 20),
        BorderSizePixel = 0,
        ZIndex = 55,
    }, HeaderRow)

    Corner(Badge, 10)

    Stroke(
        Badge,
        Color3.fromRGB(60, 160, 80),
        1,
        0.2
    )

    local BadgeDot = New("Frame", {
        Position = UDim2.new(0, 8, 0.5, -3),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = Color3.fromRGB(100, 220, 125),
        BorderSizePixel = 0,
        ZIndex = 60,
    }, Badge)

    Corner(BadgeDot, 6)

    New("TextLabel", {
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = "ONLINE",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(100, 220, 125),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 60,
    }, Badge)

    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(
                Player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size180x180
            )
        end)

        if ok then
            Avatar.Image = content
        end
    end)

    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = COLOR.border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = 2,
    }, Card)

    local StatsHolder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 3,
    }, Card)

    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, StatsHolder)

    local function StatRow(label)
        local Row = New("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1
        }, StatsHolder)

        local Dot = New("Frame", {
            Position = UDim2.new(0, 2, 0.5, -3),
            Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = COLOR.redBright,
            BorderSizePixel = 0,
        }, Row)

        Corner(Dot, 6)

        RegisterFill(
            Dot,
            "redBright"
        )

        New("TextLabel", {
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(0.6, -16, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = COLOR.grey,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, Row)

        local Value = New("TextLabel", {
            Position = UDim2.new(0.6, 0, 0, 0),
            Size = UDim2.new(0.4, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextColor3 = COLOR.white,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, Row)

        return Value
    end

    local PlayersValue = StatRow("Players Online")
    local PingValue = StatRow("Ping")
    local PlaceValue = StatRow("Place ID")

    local function UpdatePlayers()
        PlayersValue.Text =
            #Players:GetPlayers()
            .. " / "
            .. Players.MaxPlayers
    end

    UpdatePlayers()

    Players.PlayerAdded:Connect(
        UpdatePlayers
    )

    Players.PlayerRemoving:Connect(
        UpdatePlayers
    )

    PlaceValue.Text = tostring(
        game.PlaceId
    )

    task.spawn(function()
        local Stats = game:GetService("Stats")

        while Card.Parent do
            local ok, ping = pcall(function()
                return Stats.Network.ServerStatsItem[
                    "Data Ping"
                ]:GetValue()
            end)

            PingValue.Text =
                ok
                and (math.floor(ping) .. " ms")
                or "N/A"

            task.wait(1)
        end
    end)
end

--============================================================
--============================================================
-- SETTINGS
-- Deferred so Loader can place Settings after GitHub tabs.
--============================================================

local function CreateSettings()
    if Pages["Settings"] or Tabs["Settings"] then
        return Pages["Settings"]
    end

        local Settings = CreatePage("Settings")

        CreateTab("Settings", "78494414238159")

        local function Card(title, desc)
            local Box = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = COLOR.innerBg,
                BorderSizePixel = 0,
                ZIndex = 50,
            }, Settings)

            Corner(Box, 12)
            local BoxStroke = Stroke(Box, COLOR.innerBorder, 1.5, 0)
            RegisterStroke(BoxStroke, "innerBorder")

            Gradient(Box, ColorSequence.new({
                ColorSequenceKeypoint.new(0, COLOR.innerBgHover),
                ColorSequenceKeypoint.new(1, COLOR.innerBg),
            }), 90)

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
                PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            }, Box)

            New("UIListLayout", {
                Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
            }, Box)

            New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
                Text = title, Font = Enum.Font.GothamBold, TextSize = 14,
                TextColor3 = COLOR.white, TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1, ZIndex = 55,
            }, Box)

            if desc then
                New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 17), BackgroundTransparency = 1,
                    Text = desc, Font = Enum.Font.Gotham, TextSize = 10,
                    TextColor3 = COLOR.grey, TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 2, ZIndex = 55,
                }, Box)
            end
            return Box
        end

        -- Theme Color
        do
            local ThemeCard = Card("Theme Color", "เปลี่ยนสีหลักของ DXPanel และองค์ประกอบที่ใช้ Theme")

            local ColorRow = New("Frame", {
                Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, LayoutOrder = 3,
            }, ThemeCard)

            local ColorBox = New("Frame", {
                Size = UDim2.new(1, -52, 1, 0), BackgroundColor3 = COLOR.sidebar,
                BorderSizePixel = 0, ZIndex = 55,
            }, ColorRow)
            Corner(ColorBox, 10)

            local ColorBoxStroke = Stroke(ColorBox, COLOR.innerBorder, 1.5, 0)
            local ColorBoxAccent = New("Frame", {
                Position = UDim2.new(0, 8, 0, 6), Size = UDim2.new(0, 3, 1, -12),
                BackgroundColor3 = COLOR.redBright, BorderSizePixel = 0, ZIndex = 60,
            }, ColorBox)
            Corner(ColorBoxAccent, 3)
            RegisterFill(ColorBoxAccent, "redBright")

            local ColorInput = New("TextBox", {
                Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -28, 1, 0),
                BackgroundTransparency = 1, Text = "",
                PlaceholderText = "#FF2D4B  หรือ  FF2D4B",
                Font = Enum.Font.GothamMedium, TextSize = 11,
                TextColor3 = COLOR.white, PlaceholderColor3 = COLOR.grey,
                TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 65,
            }, ColorBox)

            local Preview = New("TextButton", {
                Position = UDim2.new(1, -42, 0, 0), Size = UDim2.fromOffset(42, 42),
                BackgroundColor3 = COLOR.red, BorderSizePixel = 0, AutoButtonColor = false,
                Text = "", LayoutOrder = 2, ZIndex = 65,
            }, ColorRow)
            Corner(Preview, 10)
            Stroke(Preview, COLOR.innerBorder, 1.5, 0)

            local function HexToColor3(hex)
                hex = tostring(hex or ""):gsub("#", ""):gsub("%s", "")
                if #hex ~= 6 then return nil end
                local r = tonumber(hex:sub(1, 2), 16)
                local g = tonumber(hex:sub(3, 4), 16)
                local b = tonumber(hex:sub(5, 6), 16)
                if not (r and g and b) then return nil end
                return Color3.fromRGB(r, g, b)
            end

            local function ApplyColor(c)
                if not c then
                    Tween(ColorBoxStroke, 0.1, {Color = Color3.fromRGB(220, 40, 60)})
                    task.delay(0.25, function()
                        if ColorBoxStroke.Parent then
                            Tween(ColorBoxStroke, 0.2, {Color = COLOR.innerBorder})
                        end
                    end)
                    return
                end
                Actions.SetThemeColor(c)
                Preview.BackgroundColor3 = c
                ColorInput.Text = ""
            end

            ColorInput.FocusLost:Connect(function(enterPressed)
                if enterPressed then ApplyColor(HexToColor3(ColorInput.Text)) end
            end)

            local PresetRow = New("Frame", {
                Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 4,
            }, ThemeCard)
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, PresetRow)

            local Presets = {
                {"RED", Color3.fromRGB(235, 30, 52)},
                {"BLUE", Color3.fromRGB(35, 125, 235)},
                {"GREEN", Color3.fromRGB(35, 195, 115)},
                {"PURPLE", Color3.fromRGB(145, 65, 235)},
                {"GOLD", Color3.fromRGB(230, 170, 45)},
                {"CYAN", Color3.fromRGB(25, 195, 215)},
            }

            for _, preset in ipairs(Presets) do
                local Swatch = New("TextButton", {
                    Size = UDim2.fromOffset(34, 34), BackgroundColor3 = preset[2],
                    BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 55,
                }, PresetRow)
                Corner(Swatch, 17)
                Stroke(Swatch, COLOR.border, 1.5, 0.15)
                Swatch.MouseButton1Click:Connect(function()
                    ApplyColor(preset[2])
                    Preview.BackgroundColor3 = preset[2]
                end)
            end
        end

        -- Delete GUI
        do
            local DeleteCard = Card("Interface", "ลบ DXPanel และปุ่มเปิด/ปิดทั้งหมดออกจากหน้าจอ")

            local DeleteButton = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Color3.fromRGB(45, 12, 18),
                BorderSizePixel = 0, AutoButtonColor = false, Text = "DELETE GUI",
                Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = COLOR.white,
                LayoutOrder = 3, ZIndex = 55,
            }, DeleteCard)
            Corner(DeleteButton, 10)
            Stroke(DeleteButton, Color3.fromRGB(190, 35, 55), 1.5, 0.15)

            DeleteButton.MouseEnter:Connect(function()
                Tween(DeleteButton, 0.15, {BackgroundColor3 = Color3.fromRGB(75, 15, 25)})
            end)
            DeleteButton.MouseLeave:Connect(function()
                Tween(DeleteButton, 0.15, {BackgroundColor3 = Color3.fromRGB(45, 12, 18)})
            end)
            DeleteButton.MouseButton1Click:Connect(function()
                Gui:Destroy()
            end)
        end

    return Settings
end

if not rawget(_G, "DXPanelDeferSettings") then
    CreateSettings()
end

-- TAB CONNECTIONS
--============================================================

for name, tab in pairs(Tabs) do
    tab.Button.MouseButton1Click:Connect(
        function()
            ActivateTab(name)
        end
    )
end

ActivateTab("Overview")

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
        'D<font color="rgb(255,60,80)">X</font>',

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

--============================================================
-- PUBLIC API
--============================================================
local DXPanelAPI = {}

function DXPanelAPI:CreateTab(name, icon)
    name = tostring(name or "Tab")

    if name == "Overview" or name == "Settings" then
        return nil, "Reserved tab name"
    end

    local page = CreatePage(name)
    CreateTab(name, icon or "")

    return {
        Name = name,
        Page = page,

        Section = function(_, text)
            return Section(page, text)
        end,

        Button = function(_, text, callback)
            return Button(page, text, callback)
        end,

        Toggle = function(_, text, default, callback)
            return Toggle(page, text, default, callback)
        end,

        AddSection = function(_, text)
            return Section(page, text)
        end,

        AddButton = function(_, text, callback)
            return Button(page, text, callback)
        end,

        AddToggle = function(_, text, default, callback)
            return Toggle(page, text, default, callback)
        end,
    }
end

function DXPanelAPI:CreateSettings()
    return CreateSettings()
end

function DXPanelAPI:ActivateTab(name)
    return ActivateTab(name)
end

function DXPanelAPI:SetThemeColor(color3)
    return Actions.SetThemeColor(color3)
end

function DXPanelAPI:SetPulse(on)
    return Actions.SetPulse(on)
end

function DXPanelAPI:Refit()
    return Actions.Refit()
end

function DXPanelAPI:Open()
    return OpenPanel()
end

function DXPanelAPI:Close()
    return ClosePanel()
end

function DXPanelAPI:Destroy()
    if Gui and Gui.Parent then
        Gui:Destroy()
    end
end

--============================================================
-- LOADED
--============================================================

print(
    "[DXPanel] Loaded successfully (theme-color v3)"
)
