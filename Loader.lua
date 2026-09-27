-- DXPanel Auto-Scan Loader
-- สแกนโฟลเดอร์ Tabs ใน GitHub อัตโนมัติ
-- เพิ่ม/ลบไฟล์ .lua ใน Tabs ได้โดยไม่ต้องแก้ Loader

local HttpService = game:GetService("HttpService")

local BASE_URL =
    "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"

local API_URL =
    "https://api.github.com/repos/aomsinuki-hub/Library/contents/Tabs"

local function HttpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    assert(ok, "[DXPanel] HTTP Error: " .. tostring(result))
    return result
end

local function LoadRemote(path)
    local source = HttpGet(BASE_URL .. path)

    local fn, compileError = loadstring(source)
    assert(fn, "[DXPanel] Compile Error [" .. path .. "]: " .. tostring(compileError))

    local ok, result = pcall(fn)
    assert(ok, "[DXPanel] Runtime Error [" .. path .. "]: " .. tostring(result))

    return result
end

-- Library สร้าง Overview / Settings เอง
local DXPanel = LoadRemote("DXPanelLib.lua")

assert(
    type(DXPanel) == "table" and type(DXPanel.new) == "function",
    "[DXPanel] DXPanelLib.lua ไม่ได้ return DXPanel ที่ถูกต้อง"
)

local Window = DXPanel.new({
    Name = "DXPanel",
    Title = "DX",
    Subtitle = "Panel",
    Description = "DXPanel Interface",
})

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

-- สแกน GitHub แบบ recursive:
-- Tabs/Main.lua
-- Tabs/Farm.lua
-- Tabs/Egg.lua
-- Tabs/SubFolder/ESP.lua ฯลฯ
local function ScanTabs(apiUrl, relativePath, found)
    local response = HttpGet(apiUrl)

    local ok, entries = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    assert(ok and type(entries) == "table",
        "[DXPanel] GitHub API response ไม่ถูกต้อง: " .. apiUrl)

    for _, entry in ipairs(entries) do
        if entry.type == "file" then
            local name = tostring(entry.name or "")

            if name:sub(-4):lower() == ".lua" then
                table.insert(found, relativePath .. name)
            end

        elseif entry.type == "dir" then
            local name = tostring(entry.name or "")
            local nextRelative = relativePath .. name .. "/"
            local nextApi = entry.url

            if type(nextApi) == "string" and nextApi ~= "" then
                ScanTabs(nextApi, nextRelative, found)
            end
        end
    end
end

local function GetAllTabs()
    local found = {}
    ScanTabs(API_URL, "Tabs/", found)

    table.sort(found, function(a, b)
        return a:lower() < b:lower()
    end)

    return found
end

local Tabs = GetAllTabs()

print("[DXPanel] Scanned Tabs: " .. tostring(#Tabs))

for _, path in ipairs(Tabs) do
    task.spawn(function()
        local ok, result = pcall(function()
            return LoadRemote(path)
        end)

        if not ok then
            warn("[DXPanel] Failed to load " .. path .. "\n" .. tostring(result))
            return
        end

        if type(result) ~= "function" then
            warn("[DXPanel] Skipped " .. path .. ": ต้อง return function(Window, Core)")
            return
        end

        local tabOk, tabError = pcall(result, Window, Core)

        if not tabOk then
            warn("[DXPanel] Tab Error " .. path .. "\n" .. tostring(tabError))
        else
            print("[DXPanel] Loaded Tab: " .. path)
        end
    end)
end

print("[DXPanel] Auto-scan complete")
return Window
