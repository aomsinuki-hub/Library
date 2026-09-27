-- DXPanel Loader
-- รันไฟล์นี้ไฟล์เดียว
-- Library: aomsinuki-hub/Library

local BASE_URL =
    "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"

local function LoadRemote(path)
    local ok, source = pcall(function()
        return game:HttpGet(BASE_URL .. path)
    end)

    assert(ok, "DXPanel HTTP Error: " .. tostring(source))

    local fn, err = loadstring(source)
    assert(fn, "DXPanel Compile Error [" .. path .. "]: " .. tostring(err))

    local ok2, result = pcall(fn)
    assert(ok2, "DXPanel Runtime Error [" .. path .. "]: " .. tostring(result))

    return result
end

-- 1) โหลด Library
local DXPanel = LoadRemote("DXPanelLib.lua")
assert(type(DXPanel) == "table" and type(DXPanel.new) == "function",
    "DXPanelLib.lua ไม่ได้คืนค่า DXPanel")

-- 2) สร้าง Window
local Window = DXPanel.new({
    Name = "DXPanel",
    Title = "DX",
    Subtitle = "PANEL",
    Description = "DXPanel Interface",
})

-- 3) Core ที่แชร์ให้ Tab ภายนอกใช้
local Core = {}

function Core:Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title or "DXPanel"),
            Text = tostring(text or ""),
            Duration = duration or 3,
        })
    end)
end

function Core:Load(path)
    return LoadRemote(path)
end

-- 4) รายการ Tab ที่จะโหลดจาก GitHub
-- Overview และ Settings ไม่ต้องใส่ เพราะ Library สร้างเอง
local Tabs = {
    "Tabs/Main.lua",
    -- "Tabs/Farm.lua",
    -- "Tabs/Egg.lua",
}

-- 5) โหลด Tab ทีละไฟล์
for _, path in ipairs(Tabs) do
    local tabFactory = LoadRemote(path)

    if type(tabFactory) == "function" then
        local ok, err = pcall(tabFactory, Window, Core)

        if not ok then
            warn("[DXPanel] Tab failed: " .. path .. "\n" .. tostring(err))
        end
    else
        warn("[DXPanel] Tab ต้อง return function(Window, Core): " .. path)
    end
end

print("[DXPanel] Loader loaded successfully")
return Window
