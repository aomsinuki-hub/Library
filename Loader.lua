-- Loader.lua
-- Loader จะโหลด Core + Library systems + สแกน Tabs จาก GitHub อัตโนมัติ
--
-- เพิ่ม Tab ใหม่:
--   สร้างไฟล์ .lua ในโฟลเดอร์ Tabs บน GitHub
--   แล้ว return function(Window) ... end
-- ไม่ต้องแก้ Loader.lua

local BASE = "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"
local API  = "https://api.github.com/repos/aomsinuki-hub/Library/contents/"

local function http(url)
    assert(game and game.HttpGet, "HttpGet is not available")
    return game:HttpGet(url)
end

local function run(url, ...)
    local source = http(url)
    local fn, err = loadstring(source)
    assert(fn, "Load error: " .. tostring(err))
    return fn(...)
end

-- Core
local DXPanel = run(BASE .. "Library/DXPanelLib.lua")

local Window = DXPanel.new({
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

-- Overview ต้องอยู่บนสุด
run(BASE .. "Library/Overview.lua")(Window)

-- สแกน Tabs ใน GitHub อัตโนมัติ
local function loadTabs()
    local HttpService = game:GetService("HttpService")
    local raw = http(API .. "Tabs?ref=main")

    local ok, list = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not ok or type(list) ~= "table" then
        warn("[DXPanel] GitHub Tabs scan failed")
        return
    end

    local files = {}

    for _, item in ipairs(list) do
        if item.type == "file"
            and type(item.name) == "string"
            and item.name:lower():sub(-4) == ".lua"
        then
            table.insert(files, item.name)
        end
    end

    table.sort(files, function(a, b)
        return a:lower() < b:lower()
    end)

    for _, name in ipairs(files) do
        local okTab, result = pcall(function()
            return run(BASE .. "Tabs/" .. name, Window)
        end)

        if not okTab then
            warn("[DXPanel] Failed tab:", name, result)
        end
    end
end

loadTabs()

-- Egg ESP เป็น Library system แยก
run(BASE .. "Library/EggESP.lua")(Window)

-- Settings ต้องอยู่ล่างสุด
run(BASE .. "Library/Settings.lua")(Window)

Window:Open()

return Window
