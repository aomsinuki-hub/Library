--============================================================
-- DXPanel Universal Loader
-- Delta / Executor
--
-- โหลด:
--   DXPanelLib.lua
--   Taps/AutoSteal.lua
--   Taps/EggESP.lua
--
-- Overview + Settings อยู่ใน DXPanelLib แล้ว
--============================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local BASE =
    "https://raw.githubusercontent.com/aomsinuki-hub/DXPanel/main/"

local CACHE_BUST =
    "?t=" .. tostring(os.time())

--============================================================
-- HTTP
--============================================================

local function HTTP(url)

    -- Delta / executor ที่รองรับ game:HttpGet
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and type(result) == "string" and #result > 0 then
        return result
    end

    -- Executor request API
    local requestFunc

    if type(request) == "function" then
        requestFunc = request

    elseif type(http_request) == "function" then
        requestFunc = http_request

    elseif syn and type(syn.request) == "function" then
        requestFunc = syn.request
    end

    if not requestFunc then
        error(
            "[DXPanel] ไม่พบ HTTP API ของ Executor"
        )
    end

    local okRequest, response =
        pcall(function()
            return requestFunc({
                Url = url,
                Method = "GET"
            })
        end)

    if not okRequest then
        error(
            "[DXPanel] HTTP Request Failed:\n"
            .. tostring(response)
        )
    end

    if type(response) ~= "table" then
        error(
            "[DXPanel] HTTP Response ไม่ถูกต้อง"
        )
    end

    local status =
        tonumber(
            response.StatusCode
            or response.Status
            or 0
        )

    if status ~= 0
        and (status < 200 or status >= 300)
    then
        error(
            "[DXPanel] HTTP "
            .. tostring(status)
            .. "\n"
            .. url
        )
    end

    if type(response.Body) ~= "string"
        or #response.Body == 0
    then
        error(
            "[DXPanel] ได้ไฟล์ว่าง:\n"
            .. url
        )
    end

    return response.Body
end


--============================================================
-- LOAD LUA
--============================================================

local function LOAD(url, name)

    print(
        "[DXPanel] Loading: "
        .. name
    )

    local source =
        HTTP(url .. CACHE_BUST)

    local okCompile, fn =
        pcall(loadstring, source)

    if not okCompile
        or type(fn) ~= "function"
    then
        error(
            "[DXPanel] Compile Failed: "
            .. name
            .. "\n"
            .. tostring(fn)
        )
    end

    local okRun, result =
        pcall(fn)

    if not okRun then
        error(
            "[DXPanel] Run Failed: "
            .. name
            .. "\n"
            .. tostring(result)
        )
    end

    return result
end


--============================================================
-- DXPanelLib
--============================================================

print("[DXPanel] =======================")
print("[DXPanel] DXPanel Loader")
print("[DXPanel] Player:", LocalPlayer.Name)
print("[DXPanel] =======================")


local LibrarySource =
    HTTP(
        BASE
        .. "DXPanelLib.lua"
        .. CACHE_BUST
    )


-- DXPanelLib ของคุณต้องคืน DXPanelAPI
-- ถ้าไฟล์ GitHub ยังไม่มี return ให้เติมตรงนี้
LibrarySource =
    LibrarySource
    .. "\nreturn DXPanelAPI"


local okCompile, LibraryFunction =
    pcall(
        loadstring,
        LibrarySource
    )

if not okCompile
    or type(LibraryFunction) ~= "function"
then
    error(
        "[DXPanel] DXPanelLib Compile Failed\n"
        .. tostring(LibraryFunction)
    )
end


local okLibrary, Library =
    pcall(LibraryFunction)

if not okLibrary
    or type(Library) ~= "table"
then
    error(
        "[DXPanel] DXPanelAPI ไม่ถูกต้อง\n"
        .. tostring(Library)
    )
end


print(
    "[DXPanel] DXPanelLib OK"
)


--============================================================
-- TAPS
--============================================================

local TAP_LIST = {

    {
        Name = "Auto Steal",
        File = "AutoSteal.lua",
        Icon = "A"
    },

    {
        Name = "Egg ESP",
        File = "EggESP.lua",
        Icon = "E"
    }

}


--============================================================
-- CREATE + LOAD TAPS
--============================================================

for _, TapInfo in ipairs(TAP_LIST) do

    print(
        "[DXPanel] Creating Tap:",
        TapInfo.Name
    )


    local okTab, Tab =
        pcall(function()

            return Library:CreateTab(
                TapInfo.Name,
                TapInfo.Icon
            )

        end)


    if not okTab or not Tab then

        warn(
            "[DXPanel] CreateTab Failed:",
            TapInfo.Name
        )

        continue
    end


    local TapURL =
        BASE
        .. "Taps/"
        .. TapInfo.File


    local okSource, Source =
        pcall(function()
            return HTTP(
                TapURL
                .. CACHE_BUST
            )
        end)


    if not okSource then

        warn(
            "[DXPanel] โหลด Tap ไม่ได้:",
            TapInfo.File
        )

        warn(Source)

        continue
    end


    local okTapCompile, TapFunction =
        pcall(
            loadstring,
            Source
        )


    if not okTapCompile
        or type(TapFunction) ~= "function"
    then

        warn(
            "[DXPanel] Tap Compile Failed:",
            TapInfo.File
        )

        continue
    end


    local okTapRun, TapModule =
        pcall(TapFunction)


    if not okTapRun then

        warn(
            "[DXPanel] Tap Run Failed:",
            TapInfo.File
        )

        warn(TapModule)

        continue
    end


    -- Tap ต้อง return function(Tab)
    if type(TapModule) == "function" then

        local okInit, InitError =
            pcall(function()

                TapModule(Tab)

            end)


        if not okInit then

            warn(
                "[DXPanel] Tap Init Failed:",
                TapInfo.Name
            )

            warn(InitError)

        else

            print(
                "[DXPanel] Tap Loaded:",
                TapInfo.Name
            )

        end

    else

        warn(
            "[DXPanel] "
            .. TapInfo.File
            .. " ต้อง return function(Tab)"
        )

    end

end


--============================================================
-- OPEN OVERVIEW
--============================================================

pcall(function()

    if Library.ActivateTab then
        Library:ActivateTab("Overview")
    end

end)


--============================================================
-- DONE
--============================================================

print("")
print("[DXPanel] =======================")
print("[DXPanel] LOADED")
print("[DXPanel] -----------------------")
print("[DXPanel] Overview")
print("[DXPanel] Auto Steal")
print("[DXPanel] Egg ESP")
print("[DXPanel] Settings")
print("[DXPanel] =======================")
print("")

return Library
