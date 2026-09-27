-- DXPanel Loader
-- Overview -> auto-scanned GitHub Tabs -> Settings
-- Add a .lua file under Tabs/ and restart; no Loader edit needed.

local HttpService = game:GetService("HttpService")

_G.DXPanelDeferSettings = true

local BASE =
    "https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"

local TABS_API =
    "https://api.github.com/repos/aomsinuki-hub/Library/contents/Tabs"

local TABS_RAW =
    BASE .. "Tabs/"

local function Load(url)
    local source = game:HttpGet(url)
    local fn, err = loadstring(source)

    assert(
        fn,
        "Compile error: " .. tostring(err)
    )

    return fn()
end

-- Library -> creates Overview.
local ok, DX = pcall(function()
    return Load(BASE .. "DXPanelLib.lua")
end)

_G.DXPanelDeferSettings = nil

assert(ok, "[DXPanel] Library load failed: " .. tostring(DX))
assert(type(DX) == "table", "[DXPanel] Library did not return a table.")

-- Scan GitHub Tabs folder.
local okList, files = pcall(function()
    return HttpService:JSONDecode(
        game:HttpGet(TABS_API)
    )
end)

local loadedCount = 0

if okList and type(files) == "table" then
    local names = {}

    for _, file in ipairs(files) do
        local name = file.name

        if file.type == "file"
            and type(name) == "string"
            and name:sub(-4):lower() == ".lua"
        then
            local lower = name:lower()

            if lower ~= "overview.lua"
                and lower ~= "settings.lua"
            then
                table.insert(names, name)
            end
        end
    end

    -- Keep your normal order first.
    local priority = {
        ["main.lua"] = 1,
        ["farm.lua"] = 2,
        ["egg.lua"] = 3,
        ["esp.lua"] = 4,
    }

    table.sort(names, function(a, b)
        local pa = priority[a:lower()] or 1000
        local pb = priority[b:lower()] or 1000

        if pa ~= pb then
            return pa < pb
        end

        return a:lower() < b:lower()
    end)

    for _, fileName in ipairs(names) do
        local path = TABS_RAW .. fileName

        local success, result = pcall(function()
            return Load(path)
        end)

        if not success then
            warn("[DXPanel] Failed to load " .. fileName .. ": " .. tostring(result))
        elseif type(result) == "function" then
            local ran, err = pcall(
                result,
                DX,
                {
                    Notify = function(_, title, text, duration)
                        pcall(function()
                            game:GetService("StarterGui"):SetCore(
                                "SendNotification",
                                {
                                    Title = tostring(title or "DXPanel"),
                                    Text = tostring(text or ""),
                                    Duration = duration or 3,
                                }
                            )
                        end)
                    end,
                }
            )

            if ran then
                loadedCount += 1
            else
                warn("[DXPanel] Tab error " .. fileName .. ": " .. tostring(err))
            end
        else
            warn("[DXPanel] " .. fileName .. " must return function(Window, Core)")
        end
    end
else
    warn("[DXPanel] GitHub Tabs scan failed: " .. tostring(files))
end

-- Settings must always be last.
if type(DX.CreateSettings) == "function" then
    DX:CreateSettings()
end

-- Return to Overview after all tabs are created.
if type(DX.ActivateTab) == "function" then
    DX:ActivateTab("Overview")
end

print("[DXPanel] Loaded. GitHub tabs: " .. tostring(loadedCount))

return DX
