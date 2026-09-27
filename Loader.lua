
-- DXPanel Loader.lua
-- โหลด Core -> Overview -> Tabs -> Egg ESP -> Settings
-- Tabs ที่มีอยู่จะโหลดแน่นอน แม้ GitHub API สแกนไม่ได้
-- เพิ่มไฟล์ .lua ใน Tabs/ แล้ว Loader จะพยายามโหลดให้อัตโนมัติ

local BASE = "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"
local API  = "https://api.github.com/repos/aomsinuki-hub/Library/contents/Tabs?ref=main"

local function fetch(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then error(tostring(result)) end
    return result
end

local function loadRemote(url, ...)
    local source = fetch(url)
    local fn, err = loadstring(source)
    if not fn then
        error("compile error: " .. tostring(err))
    end
    return fn(...)
end

local function safe(label, fn)
    local ok, result = pcall(fn)
    if not ok then
        warn("[DXPanel] " .. label .. " FAILED:", result)
        return false, result
    end
    print("[DXPanel] " .. label .. " OK")
    return true, result
end

-- 1) Core
local okCore, DXPanel = safe("Core", function()
    return loadRemote(BASE .. "Library/DXPanelLib.lua")
end)

if not okCore or type(DXPanel) ~= "table" or type(DXPanel.new) ~= "function" then
    error("[DXPanel] DXPanelLib.lua ไม่สามารถโหลดได้")
end

-- 2) Window
local okWindow, Window = safe("Window", function()
    return DXPanel.new({
        Name = "DXPanel",
        Title = "DX",
        Subtitle = "PANEL",
        Description = "DXPanel Premium Interface",
        Size = {
            defW = 720, defH = 460,
            minW = 400, minH = 260,
            maxW = 900, maxH = 650,
        },
    })
end)

if not okWindow or not Window then
    error("[DXPanel] สร้าง Window ไม่สำเร็จ")
end

-- 3) Overview
safe("Overview", function()
    local f = loadRemote(BASE .. "Library/Overview.lua")
    assert(type(f) == "function", "Overview.lua ต้อง return function(Window)")
    f(Window)
end)

-- 4) Known tabs: โหลดแน่นอนก่อน
local knownTabs = {
    "Main.lua",
    "Farm.lua",
    "Egg.lua",
    "ESP.lua",
}

local loaded = {}

for _, fileName in ipairs(knownTabs) do
    local key = fileName:lower()
    if not loaded[key] then
        local ok = safe("Tab/" .. fileName, function()
            local f = loadRemote(BASE .. "Tabs/" .. fileName)
            assert(type(f) == "function", fileName .. " ต้อง return function(Window)")
            f(Window)
        end)
        if ok then loaded[key] = true end
    end
end

-- 5) Auto-scan GitHub Tabs/
-- ถ้า API ใช้ไม่ได้ ไม่ทำให้ Tab ที่โหลดไปแล้วหาย
safe("AutoScan Tabs", function()
    local HttpService = game:GetService("HttpService")
    local data = HttpService:JSONDecode(fetch(API))

    assert(type(data) == "table", "GitHub API ไม่ได้คืนรายการไฟล์")

    for _, item in ipairs(data) do
        if type(item) == "table"
            and item.type == "file"
            and type(item.name) == "string"
            and item.name:lower():sub(-4) == ".lua"
        then
            local key = item.name:lower()

            if not loaded[key] then
                local ok = safe("AutoTab/" .. item.name, function()
                    local f = loadRemote(BASE .. "Tabs/" .. item.name)
                    assert(type(f) == "function",
                        item.name .. " ต้อง return function(Window)")
                    f(Window)
                end)

                if ok then loaded[key] = true end
            end
        end
    end
end)

-- 6) Egg ESP
safe("Egg ESP", function()
    local f = loadRemote(BASE .. "Library/EggESP.lua")
    assert(type(f) == "function", "EggESP.lua ต้อง return function(Window)")
    f(Window)
end)

-- 7) Settings last
safe("Settings", function()
    local f = loadRemote(BASE .. "Library/Settings.lua")
    assert(type(f) == "function", "Settings.lua ต้อง return function(Window)")
    f(Window)
end)

-- 8) Open
safe("Open", function()
    Window:Open()
end)

print("[DXPanel] READY")
return Window
