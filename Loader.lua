--============================================================
-- DX PANEL LOADER
-- Loader is the outer layer.
-- It loads the Library, then loads external GitHub TAB scripts.
-- No FuncsV4 is required.
--============================================================

local LIB_URL = "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/DXPanelLib.lua"

-- Add GitHub TAB script URLs here.
-- Each script must return: function(Window, Core)
local TAB_URLS = {
    -- "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/Tabs/Main.lua",
    -- "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/Tabs/Farm.lua",
}

local function LoadRemote(url, name)
    assert(type(url) == "string" and url ~= "", "Missing URL: " .. tostring(name))

    local okHttp, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not okHttp then
        error("[DXLoader] HttpGet failed for " .. tostring(name) .. ": " .. tostring(source))
    end

    local chunk, compileError = loadstring(source, "@" .. tostring(name))
    if not chunk then
        error("[DXLoader] Compile failed for " .. tostring(name) .. ": " .. tostring(compileError))
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        error("[DXLoader] Run failed for " .. tostring(name) .. ": " .. tostring(result))
    end

    return result
end

--============================================================
-- CORE API
--============================================================

local Unloaded = false
local Connections = {}
local Enabled = {}
local Count = {}

local Core = {}

function Core:Connect(signal, callback, key)
    local connection
    connection = signal:Connect(function(...)
        if Unloaded then
            if connection then
                connection:Disconnect()
            end
            return
        end

        local ok, err = pcall(callback, ...)
        if not ok then
            warn("[DXLoader] " .. tostring(err))
        end
    end)

    if key then
        Connections[key] = connection
    end

    return connection
end

function Core:Disconnect(key)
    local connection = Connections[key]
    if connection then
        connection:Disconnect()
        Connections[key] = nil
    end
end

function Core:SetEnabled(key, value)
    Enabled[key] = value == true
end

function Core:IsEnabled(key)
    return Enabled[key] == true
end

function Core:StartLoop(key, callback, interval)
    interval = interval or 0

    task.spawn(function()
        while not Unloaded do
            if Enabled[key] then
                local ok, err = pcall(callback)
                if not ok then
                    warn("[DXLoader:" .. tostring(key) .. "] " .. tostring(err))
                end
            end
            task.wait(interval)
        end
    end)
end

function Core:Fallback(value, key, callback)
    local n = Count[key] or 0

    if value ~= nil then
        n += 1
        Count[key] = n
    end

    if n > 1 and not Enabled[key] and callback then
        pcall(callback)
    end
end

function Core:Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title or "Notice"),
            Text = tostring(text or ""),
            Icon = "rbxassetid://0",
            Duration = duration or 4,
        })
    end)
end

function Core:Unload()
    if Unloaded then
        return
    end

    Unloaded = true

    for key, connection in pairs(Connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
        Connections[key] = nil
    end

    Enabled = {}
end

Core.Connections = Connections
Core.Enabled = Enabled
Core.Count = Count

--============================================================
-- LOAD LIBRARY
--============================================================

local DXPanel = LoadRemote(LIB_URL, "DXPanelLib")
assert(type(DXPanel) == "table" and type(DXPanel.new) == "function", "DXPanelLib.new was not found")

local Window = DXPanel.new({
    Name = "DXPanel",
    Title = "DX",
    Subtitle = "PANEL",
    Description = "GitHub Loader",
    Size = {
        defW = 620,
        defH = 380,
    },
})

--============================================================
-- LOAD GITHUB TABS
--============================================================

for index, url in ipairs(TAB_URLS) do
    local ok, err = pcall(function()
        local TabFactory = LoadRemote(url, "Tab_" .. index)

        assert(type(TabFactory) == "function", "Tab script must return function(Window, Core)")

        -- The external script creates ONLY its own tab(s).
        TabFactory(Window, Core)
    end)

    if not ok then
        warn("[DXLoader] Tab " .. tostring(index) .. " failed: " .. tostring(err))
    end
end

-- Settings is owned by DXPanelLib and is deliberately created LAST.
if type(Window.CreateSettingsTab) == "function" then
    local ok, err = pcall(function()
        Window:CreateSettingsTab()
    end)
    if not ok then
        warn("[DXLoader] Settings failed: " .. tostring(err))
    end
end

_G.DXPanelLoader = {
    Window = Window,
    Core = Core,
    Unload = function()
        Core:Unload()
        Window:Destroy()
    end,
}

Core:Notify("DX Panel", "Loaded", 3)
