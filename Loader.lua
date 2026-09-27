--[[
    DXPanel Loader
    ------------------------------------------------
    โครงสร้าง GitHub ที่รองรับ:

    Library/
    ├─ Loader.lua
    ├─ Library/
    │  ├─ DXPanelLib.lua
    │  ├─ Overview.lua
    │  ├─ EggESP.lua
    │  └─ Settings.lua
    └─ Tabs/
       ├─ Main.lua
       ├─ Farm.lua
       ├─ Egg.lua
       └─ ESP.lua

    เพิ่ม Tab ใหม่:
      1. สร้างไฟล์ .lua ใน Tabs/
      2. ให้ไฟล์ return function(Window) ... end
      3. ไม่ต้องแก้ Loader.lua
--]]

local BASE = "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"
local API  = "https://api.github.com/repos/aomsinuki-hub/Library/contents/"

local function log(...)
    print("[DXPanel]", ...)
end

local function warnx(...)
    warn("[DXPanel]", ...)
end

local function http(url)
    assert(game and game.HttpGet, "HttpGet is not available")
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        error("HttpGet failed: " .. tostring(result))
    end

    return result
end

local function loadSource(url)
    local source = http(url)

    if type(source) ~= "string" or source == "" then
        error("Empty source: " .. url)
    end

    local fn, err = loadstring(source)

    if not fn then
        error("loadstring failed: " .. tostring(err))
    end

    return fn
end

local function run(url, ...)
    local fn = loadSource(url)
    return fn(...)
end

local function runOptional(label, url, ...)
    local ok, result = pcall(function()
        return run(url, ...)
    end)

    if ok then
        log(label .. " loaded")
        return true, result
    end

    warnx(label .. " failed:", result)
    return false, nil
end

-- =========================================================
-- 1. Core
-- =========================================================

local okCore, DXPanel = pcall(function()
    return run(BASE .. "Library/DXPanelLib.lua")
end)

if not okCore or not DXPanel then
    error("[DXPanel] DXPanelLib.lua โหลดไม่สำเร็จ: " .. tostring(DXPanel))
end

log("DXPanelLib loaded")

-- =========================================================
-- 2. Create Window
-- =========================================================

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

log("Window created")

-- =========================================================
-- 3. Overview — ต้องเป็น Tab แรก
-- =========================================================

runOptional(
    "Overview",
    BASE .. "Library/Overview.lua",
    Window
)

-- =========================================================
-- 4. Auto Scan Tabs
-- =========================================================

local function scanTabs()
    local HttpService = game:GetService("HttpService")

    local raw = http(API .. "Tabs?ref=main")

    local okJSON, list = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not okJSON then
        error("GitHub API JSON decode failed: " .. tostring(list))
    end

    if type(list) ~= "table" then
        error("GitHub API returned invalid data")
    end

    local files = {}

    for _, item in ipairs(list) do
        if type(item) == "table"
            and item.type == "file"
            and type(item.name) == "string"
            and item.name:lower():sub(-4) == ".lua"
        then
            table.insert(files, item.name)
        end
    end

    table.sort(files, function(a, b)
        return a:lower() < b:lower()
    end)

    log("Found " .. tostring(#files) .. " Tab file(s)")

    for _, name in ipairs(files) do
        -- กันไม่ให้ไฟล์พิเศษถูกโหลดซ้ำ
        local lower = name:lower()

        if lower ~= "overview.lua"
            and lower ~= "setting.lua"
            and lower ~= "settings.lua"
            and lower ~= "eggESP.lua"
        then
            local okTab, err = pcall(function()
                run(BASE .. "Tabs/" .. name, Window)
            end)

            if okTab then
                log("Tab loaded:", name)
            else
                warnx("Tab failed:", name, err)
            end
        end
    end
end

local okScan, scanErr = pcall(scanTabs)

if not okScan then
    warnx("Tab scan failed:", scanErr)
    warnx("ตรวจว่า GitHub repo มีโฟลเดอร์ Tabs และเปิดการเข้าถึง GitHub API ได้")
end

-- =========================================================
-- 5. Library Systems
-- =========================================================

runOptional(
    "Egg ESP",
    BASE .. "Library/EggESP.lua",
    Window
)

-- =========================================================
-- 6. Settings — ต้องเป็น Tab สุดท้าย
-- =========================================================

runOptional(
    "Settings",
    BASE .. "Library/Settings.lua",
    Window
)

-- =========================================================
-- 7. Open
-- =========================================================

local okOpen, openErr = pcall(function()
    Window:Open()
end)

if not okOpen then
    warnx("Window:Open() failed:", openErr)
else
    log("DXPanel opened")
end

return Window
