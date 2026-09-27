--============================================================
-- DXPanel Loader.lua
-- ใช้กับ DXPanelLib.lua ตัวปัจจุบันของคุณ
--
-- โครงสร้างที่รองรับ:
--
-- Library/
--   Loader.lua
--   Library/
--      DXPanelLib.lua
--      Overview.lua        (ถ้ามี จะโหลดอันนี้ก่อน)
--      EggESP.lua
--      Settings.lua
--   Tabs/
--      Main.lua
--      Farm.lua
--      Egg.lua
--      ESP.lua
--      ...ไฟล์ใหม่...
--
-- เพิ่มไฟล์ใน Tabs/ แล้ว Loader จะสแกนให้เอง
-- ไม่ต้องแก้ Loader.lua
--============================================================

local BASE = "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"
local API  = "https://api.github.com/repos/aomsinuki-hub/Library/contents/"

local function log(...)
    print("[DXPanel]", ...)
end

local function safeHttp(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        error("HttpGet failed: " .. tostring(result))
    end

    if type(result) ~= "string" or result == "" then
        error("Empty response: " .. tostring(url))
    end

    return result
end

local function loadURL(url, ...)
    local source = safeHttp(url)

    local fn, err = loadstring(source)
    if not fn then
        error("loadstring failed: " .. tostring(err))
    end

    return fn(...)
end

local function loadOptional(label, url, ...)
    local ok, result = pcall(function()
        return loadURL(url, ...)
    end)

    if ok then
        log(label .. " loaded")
        return true, result
    end

    warn("[DXPanel] " .. label .. " failed: " .. tostring(result))
    return false, nil
end

--============================================================
-- 1. LOAD CORE
--============================================================

local okCore, DXPanel = pcall(function()
    return loadURL(BASE .. "Library/DXPanelLib.lua")
end)

if not okCore or type(DXPanel) ~= "table" or type(DXPanel.new) ~= "function" then
    error("[DXPanel] DXPanelLib.lua ไม่ได้คืน DXPanel.new()")
end

log("DXPanelLib OK")

--============================================================
-- 2. CREATE WINDOW
--============================================================

local okWindow, Window = pcall(function()
    return DXPanel.new({
        Name = "DXPanel",
        Title = "DX",
        Subtitle = "PANEL",
        Description = "DXPanel Premium Interface",
        Size = {
            defW = 720,
            defH = 460,
            minW = 400,
            minH = 260,
            maxW = 900,
            maxH = 650,
        },
    })
end)

if not okWindow or not Window then
    error("[DXPanel] สร้าง Window ไม่สำเร็จ: " .. tostring(Window))
end

log("Window OK")

--============================================================
-- 3. OVERVIEW — บังคับสร้างก่อนเสมอ
--============================================================

local function makeFallbackOverview()
    local Tab = Window:CreateTab("Overview", "house")

    Tab:Section("OVERVIEW")

    Tab:Button("DXPanel", function()
        print("[DXPanel] Overview")
    end)

    Tab:Section("STATUS")

    Tab:Button("Panel Loaded", function()
        print("[DXPanel] Panel is running")
    end)

    return Tab
end

-- ถ้ามี Overview.lua ให้ใช้ของเดิม
local overviewOK = loadOptional(
    "Overview",
    BASE .. "Library/Overview.lua",
    Window
)

-- ถ้าไฟล์ Overview โหลดไม่ได้ ต้องสร้างแท็บเอง
-- เพื่อไม่ให้เกิดหน้า Dashboard ว่าง
if not overviewOK then
    makeFallbackOverview()
    log("Fallback Overview created")
end

--============================================================
-- 4. AUTO SCAN TABS
--============================================================

local function getGitHubFolder(folder)
    local url = API .. folder .. "?ref=main"

    local raw = safeHttp(url)

    local HttpService = game:GetService("HttpService")

    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not ok or type(data) ~= "table" then
        error("GitHub API JSON decode failed")
    end

    return data
end

local function loadTabsFromFolder(folder)
    local data = getGitHubFolder(folder)
    local names = {}

    for _, item in ipairs(data) do
        if type(item) == "table"
            and item.type == "file"
            and type(item.name) == "string"
            and item.name:lower():sub(-4) == ".lua"
        then
            table.insert(names, item.name)
        end
    end

    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)

    for _, name in ipairs(names) do
        local lower = name:lower()

        -- ไฟล์พิเศษโหลดแยกด้านล่าง
        if lower ~= "overview.lua"
            and lower ~= "settings.lua"
            and lower ~= "setting.lua"
            and lower ~= "eggesp.lua"
        then
            local url = BASE .. folder .. "/" .. name

            local ok = loadOptional(
                "Tab " .. name,
                url,
                Window
            )

            if not ok then
                warn("[DXPanel] ข้าม Tab: " .. name)
            end
        end
    end

    return #names
end

local tabsLoaded = false

-- ลอง Tabs/ ก่อน
do
    local ok, count = pcall(function()
        return loadTabsFromFolder("Tabs")
    end)

    if ok then
        tabsLoaded = true
        log("Auto scan Tabs/ OK")
    else
        warn("[DXPanel] Tabs/ scan failed: " .. tostring(count))
    end
end

-- รองรับกรณีผู้ใช้เก็บ Tab ไว้ใน Library/Tabs/
if not tabsLoaded then
    local ok, count = pcall(function()
        return loadTabsFromFolder("Library/Tabs")
    end)

    if ok then
        tabsLoaded = true
        log("Auto scan Library/Tabs/ OK")
    else
        warn("[DXPanel] Library/Tabs/ scan failed: " .. tostring(count))
    end
end

--============================================================
-- 5. EGG ESP
--============================================================

loadOptional(
    "Egg ESP",
    BASE .. "Library/EggESP.lua",
    Window
)

--============================================================
-- 6. SETTINGS — โหลดท้ายสุด
--============================================================

local settingsOK = loadOptional(
    "Settings",
    BASE .. "Library/Settings.lua",
    Window
)

-- ถ้า Settings.lua ไม่มี ให้สร้างขั้นต่ำแทน
if not settingsOK then
    local Settings = Window:CreateTab("Settings", "gear")

    Settings:Section("THEME COLOR")

    local colors = {
        {"Red",    Color3.fromRGB(235, 30, 52)},
        {"Purple", Color3.fromRGB(145, 70, 255)},
        {"Blue",   Color3.fromRGB(55, 125, 255)},
        {"Cyan",   Color3.fromRGB(40, 220, 220)},
        {"Green",  Color3.fromRGB(45, 220, 110)},
        {"Orange", Color3.fromRGB(255, 145, 40)},
        {"Pink",   Color3.fromRGB(255, 70, 170)},
        {"White",  Color3.fromRGB(235, 235, 240)},
    }

    for _, item in ipairs(colors) do
        local name = item[1]
        local color = item[2]

        Settings:Button(name, function()
            pcall(function()
                Window:SetThemeColor(color)
            end)
        end)
    end

    Settings:Section("PANEL")

    Settings:Button("Delete DXPanel", function()
        Window:Destroy()
    end)
end

--============================================================
-- 7. OPEN
--============================================================

local okOpen, openErr = pcall(function()
    Window:Open()
end)

if not okOpen then
    warn("[DXPanel] Window:Open() failed: " .. tostring(openErr))
else
    log("DXPanel READY")
end

return Window
