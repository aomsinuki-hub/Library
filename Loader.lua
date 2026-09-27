--// DXPanel Loader
--// GitHub Auto Tab Loader
--// Overview + Settings = DXPanelLib
--// Main/Farm/Egg/ESP/etc. = GitHub /Tabs/

local HttpService = game:GetService("HttpService")

--==================================================
-- CONFIG
--==================================================

local OWNER = "aomsinuki-hub"
local REPO = "Library"
local BRANCH = "main"

local RAW_BASE =
    "https://raw.githubusercontent.com/"
    .. OWNER .. "/"
    .. REPO .. "/refs/heads/"
    .. BRANCH .. "/"

local TABS_API =
    "https://api.github.com/repos/"
    .. OWNER .. "/"
    .. REPO .. "/contents/Tabs?ref="
    .. BRANCH

--==================================================
-- HELPERS
--==================================================

local function request(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        warn("[DXPanel] HttpGet failed:", url)
        warn("[DXPanel] Error:", result)
        return nil
    end

    return result
end

local function runCode(code, name)
    if type(code) ~= "string" then
        warn("[DXPanel] Invalid code:", name)
        return nil
    end

    local fn, err = loadstring(code)

    if not fn then
        warn("[DXPanel] loadstring failed:", name)
        warn("[DXPanel] Error:", err)
        return nil
    end

    return fn
end

--==================================================
-- LOAD DX PANEL LIBRARY
--==================================================

print("[DXPanel] Loading DXPanelLib...")

local libraryCode = request(
    RAW_BASE .. "DXPanelLib.lua"
)

if not libraryCode then
    warn("[DXPanel] Cannot load DXPanelLib.lua")
    return
end

local libraryLoader = runCode(
    libraryCode,
    "DXPanelLib.lua"
)

if not libraryLoader then
    return
end

local okLibrary, Library = pcall(libraryLoader)

if not okLibrary then
    warn("[DXPanel] DXPanelLib crashed:")
    warn(Library)
    return
end

if not Library then
    warn("[DXPanel] DXPanelLib returned nil")
    return
end

print("[DXPanel] DXPanelLib loaded")

--==================================================
-- CREATE WINDOW
--==================================================

local Window

if type(Library.CreateWindow) == "function" then

    local ok, result = pcall(function()
        return Library:CreateWindow({
            Title = "DXPanel",
            Subtitle = "DXPanel Premium Interface"
        })
    end)

    if ok then
        Window = result
    else
        warn("[DXPanel] CreateWindow failed:")
        warn(result)
        return
    end

elseif type(Library.Create) == "function" then

    local ok, result = pcall(function()
        return Library:Create({
            Title = "DXPanel"
        })
    end)

    if ok then
        Window = result
    else
        warn("[DXPanel] Library:Create failed:")
        warn(result)
        return
    end

elseif Library.Window then

    Window = Library.Window

else

    warn("[DXPanel] Cannot find Window creator in DXPanelLib")
    warn("[DXPanel] Expected Library:CreateWindow()")
    return

end

if not Window then
    warn("[DXPanel] Window is nil")
    return
end

print("[DXPanel] Window created")

--==================================================
-- OVERVIEW
--==================================================
-- Overview MUST be created first.
-- The actual Overview system stays inside DXPanelLib.

if type(Library.CreateOverview) == "function" then

    local ok, err = pcall(function()
        Library:CreateOverview(Window)
    end)

    if not ok then
        warn("[DXPanel] Overview error:", err)
    end

elseif type(Library.SetupOverview) == "function" then

    local ok, err = pcall(function()
        Library:SetupOverview(Window)
    end)

    if not ok then
        warn("[DXPanel] Overview error:", err)
    end

else

    print("[DXPanel] Overview is handled by DXPanelLib")

end

--==================================================
-- GET TAB LIST FROM GITHUB
--==================================================

print("[DXPanel] Scanning GitHub Tabs...")

local apiResult = request(TABS_API)

if not apiResult then
    warn("[DXPanel] Cannot scan Tabs folder")
    return
end

local files

local okDecode, decodeResult = pcall(function()
    return HttpService:JSONDecode(apiResult)
end)

if not okDecode then
    warn("[DXPanel] GitHub API JSON decode failed")
    warn(decodeResult)
    return
end

files = decodeResult

if type(files) ~= "table" then
    warn("[DXPanel] GitHub API returned invalid data")
    return
end

--==================================================
-- FILTER TAB FILES
--==================================================

local tabFiles = {}

for _, file in ipairs(files) do

    if type(file) == "table"
    and file.type == "file"
    and type(file.name) == "string"
    then

        local lowerName = file.name:lower()

        if lowerName:sub(-4) == ".lua" then

            -- Overview / Settings are reserved
            if lowerName ~= "overview.lua"
            and lowerName ~= "settings.lua"
            then

                table.insert(tabFiles, file)

            end
        end
    end
end

--==================================================
-- SORT TABS
--==================================================
-- Keeps the result stable.
-- Overview is already created.
-- Settings will remain at the bottom.

table.sort(tabFiles, function(a, b)

    return a.name:lower() < b.name:lower()

end)

print(
    "[DXPanel] Found "
    .. tostring(#tabFiles)
    .. " tab(s)"
)

--==================================================
-- LOAD TABS
--==================================================

for _, file in ipairs(tabFiles) do

    local fileName = file.name

    print("[DXPanel] Loading Tab:", fileName)

    local rawURL

    if type(file.download_url) == "string" then
        rawURL = file.download_url
    else
        rawURL =
            RAW_BASE
            .. "Tabs/"
            .. fileName
    end

    local tabCode = request(rawURL)

    if tabCode then

        local tabLoader = runCode(
            tabCode,
            "Tabs/" .. fileName
        )

        if tabLoader then

            local okTab, result = pcall(function()

                return tabLoader(
                    Window,
                    Library
                )

            end)

            if not okTab then

                warn(
                    "[DXPanel] Tab crashed:",
                    fileName
                )

                warn(result)

            else

                print(
                    "[DXPanel] Tab loaded:",
                    fileName
                )

            end
        end
    end

end

--==================================================
-- SETTINGS
--==================================================
-- Settings MUST be last.
-- The actual Settings system stays inside DXPanelLib.

if type(Library.CreateSettings) == "function" then

    local ok, err = pcall(function()
        Library:CreateSettings(Window)
    end)

    if not ok then
        warn("[DXPanel] Settings error:", err)
    end

elseif type(Library.SetupSettings) == "function" then

    local ok, err = pcall(function()
        Library:SetupSettings(Window)
    end)

    if not ok then
        warn("[DXPanel] Settings error:", err)
    end

else

    print("[DXPanel] Settings is handled by DXPanelLib")

end

--==================================================
-- DONE
--==================================================

print("================================")
print("[DXPanel] Loader finished")
print("[DXPanel] Overview")
print("[DXPanel] " .. tostring(#tabFiles) .. " GitHub Tab(s)")
print("[DXPanel] Settings")
print("================================")
