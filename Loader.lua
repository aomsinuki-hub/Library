--============================================================
-- DXPanel Loader
-- Loads DXPanelLib once, then automatically loads every .lua
-- file inside the GitHub Tabs/ folder.
--============================================================

local HttpService = game:GetService("HttpService")

local OWNER  = "aomsinuki-hub"
local REPO   = "Library"
local BRANCH = "main"
local TABDIR = "Tabs"

local LIB_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/refs/heads/%s/DXPanelLib.lua",
    OWNER, REPO, BRANCH
)

local API_URL = string.format(
    "https://api.github.com/repos/%s/%s/contents/%s?ref=%s",
    OWNER, REPO, TABDIR, BRANCH
)

local function get(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        error("[DXPanel Loader] HttpGet failed: " .. tostring(result))
    end

    return result
end

local function run(source, chunkName, ...)
    local compiler = loadstring
    if not compiler then
        error("[DXPanel Loader] loadstring is not available")
    end

    local fn, compileError = compiler(source, chunkName)
    if not fn then
        error("[DXPanel Loader] Compile error in " .. chunkName .. ": " .. tostring(compileError))
    end

    return fn(...)
end

-- Tell the library NOT to create Settings yet.
-- Loader creates it after every GitHub tab has been loaded,
-- so Settings is always the last tab.
_G.DXPanelDeferSettings = true

local DXPanel
local okLib, libResult = pcall(function()
    return run(get(LIB_URL), "@DXPanelLib", nil)
end)

_G.DXPanelDeferSettings = nil

if not okLib then
    error(tostring(libResult))
end

DXPanel = libResult

if type(DXPanel) ~= "table" then
    error("[DXPanel Loader] DXPanelLib did not return its API table")
end

-- Public API for tab files.
_G.DXPanel = DXPanel

local function loadTabFile(fileName, rawUrl)
    local source = get(rawUrl)

    local ok, result = pcall(function()
        -- Tab files may either:
        --   1) use: local DX = ...
        --   2) use: local DX = _G.DXPanel
        --   3) return function(DX) ... end
        -- All three are supported.
        local returned = run(source, "@Tabs/" .. fileName, DXPanel)

        if type(returned) == "function" then
            return returned(DXPanel)
        end

        if type(returned) == "table" and type(returned.Init) == "function" then
            return returned:Init(DXPanel)
        end

        return returned
    end)

    if not ok then
        warn("[DXPanel Loader] Failed: " .. fileName .. "\n" .. tostring(result))
        return false
    end

    print("[DXPanel Loader] Loaded tab: " .. fileName)
    return true
end

-- GitHub Contents API gives us every file in Tabs/ automatically.
local body = get(API_URL)
local entries = HttpService:JSONDecode(body)

if type(entries) ~= "table" then
    error("[DXPanel Loader] GitHub returned an invalid directory listing")
end

local files = {}

for _, entry in ipairs(entries) do
    if type(entry) == "table"
        and entry.type == "file"
        and type(entry.name) == "string"
        and entry.name:lower():sub(-4) == ".lua"
        and type(entry.download_url) == "string" then
        table.insert(files, {
            name = entry.name,
            url = entry.download_url,
        })
    end
end

table.sort(files, function(a, b)
    return a.name:lower() < b.name:lower()
end)

for _, file in ipairs(files) do
    loadTabFile(file.name, file.url)
end

-- Settings is created AFTER all GitHub tabs.
-- Therefore the order is always:
-- Overview -> GitHub Tabs -> Settings
DXPanel:CreateSettings()
DXPanel:ActivateTab("Overview")

print(string.format(
    "[DXPanel Loader] Ready | %d GitHub tab(s) loaded",
    #files
))
