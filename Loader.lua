-- Loader.lua
local BASE = "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"

local function loadModule(path)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE .. path))()
    end)

    if not ok then
        warn("[DXPanel] โหลดไม่สำเร็จ:", path, result)
        return nil
    end

    return result
end

local Library = loadModule("Library/DXPanelLib.lua")

if not Library then
    error("[DXPanel] Library โหลดไม่สำเร็จ")
end

local Window = Library:CreateWindow({
    Title = "DX PANEL",
    Subtitle = "DXPanel Premium Interface",
})

-- โหลดระบบแต่ละแท็บ
local tabs = {
    "Overview.lua",
    "Main.lua",
    "Farm.lua",
    "Egg.lua",
    "ESP.lua",
    "EggESP.lua",
    "Settings.lua",
}

for _, file in ipairs(tabs) do
    local result = loadModule("Library/" .. file)

    if result and type(result) == "function" then
        local ok, err = pcall(function()
            result(Window)
        end)

        if not ok then
            warn("[DXPanel] " .. file .. " ERROR:", err)
        end
    end
end

print("[DXPanel] Loader OK")
