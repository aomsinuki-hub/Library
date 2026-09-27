local HttpService = game:GetService("HttpService")

_G.DXPanelDeferSettings = true

local LIB_URL =
    "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/DXPanelLib.lua"

local TABS_API =
    "https://api.github.com/repos/aomsinuki-hub/Library/contents/Tabs"

local TABS_RAW =
    "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/Tabs/"

local function load(url)
    local source = game:HttpGet(url)
    local fn, err = loadstring(source)
    assert(fn, err)
    return fn()
end

local ok, DX = pcall(function()
    return load(LIB_URL)
end)

_G.DXPanelDeferSettings = nil

if not ok then
    error("[DXPanel] Library load failed: " .. tostring(DX))
end

local okList, files = pcall(function()
    return HttpService:JSONDecode(game:HttpGet(TABS_API))
end)

if okList and type(files) == "table" then
    local names = {}

    for _, file in ipairs(files) do
        local name = file.name
        if file.type == "file"
            and type(name) == "string"
            and name:sub(-4):lower() == ".lua"
            and name:lower() ~= "overview.lua"
            and name:lower() ~= "settings.lua"
        then
            table.insert(names, name)
        end
    end

    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)

    for _, fileName in ipairs(names) do
        local success, result = pcall(function()
            return load(TABS_RAW .. fileName)
        end)

        if success then
            if type(result) == "function" then
                local ran, err = pcall(result, DX)
                if not ran then
                    warn("[DXPanel] " .. fileName .. ": " .. tostring(err))
                end
            elseif type(result) == "table" and type(result.Load) == "function" then
                local ran, err = pcall(result.Load, result, DX)
                if not ran then
                    warn("[DXPanel] " .. fileName .. ": " .. tostring(err))
                end
            end
        else
            warn("[DXPanel] Failed to load " .. fileName .. ": " .. tostring(result))
        end
    end
else
    warn("[DXPanel] GitHub Tabs scan failed:", files)
end

-- Settings is always created last.
DX:CreateSettings()

return DX
