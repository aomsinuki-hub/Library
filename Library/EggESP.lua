-- Library/EggESP.lua
-- Plot Egg ESP แบบแยก Library
-- FIX: ไม่เรียก Window:CreatePlotEggESP() เพราะ DXPanelLib ไม่มี API นี้
-- ใช้ Window:CreateTab() + ระบบ ESP ภายในไฟล์นี้แทน

return function(Window)
    --========================================================
    -- CONFIG: แก้ชื่อโครงสร้างเกมตรงนี้ได้ง่าย
    --========================================================
    local CONFIG = {
        PLOTS_FOLDER = "Plots",
        EGGS_FOLDER = "Eggs",

        -- Attribute ที่ใช้ระบุเจ้าของ Plot
        OWNER_ATTRIBUTE = "OwnerUserId",

        -- ถ้า Plot ใช้ Attribute เป็นชื่อผู้เล่นแทน UserId
        OWNER_NAME_ATTRIBUTE = "Owner",

        MAX_DISTANCE = 500,

        -- เวลาปรับข้อความระยะห่าง ไม่ได้ใช้สแกน Workspace ทั้งหมด
        DISTANCE_UPDATE = 0.25,

        TEXT_SIZE = 13,
        MAX_TEXT_DISTANCE = 500,

        CREATE_TAB = true,
    }

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local LocalPlayer = Players.LocalPlayer

    local Enabled = false
    local Distance = CONFIG.MAX_DISTANCE

    local Tracked = {}
    local Connections = {}

    --========================================================
    -- HELPERS
    --========================================================

    local function disconnectAll()
        for _, connection in pairs(Connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        table.clear(Connections)
    end

    local function getCharacterRoot()
        local character = LocalPlayer.Character
        if not character then
            return nil
        end

        return character:FindFirstChild("HumanoidRootPart")
            or character.PrimaryPart
    end

    local function getNumber(object, names)
        for _, name in ipairs(names) do
            local attr = object:GetAttribute(name)

            if typeof(attr) == "number" then
                return attr
            end

            local child = object:FindFirstChild(name, true)

            if child then
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    return child.Value
                end

                local value = child:GetAttribute("Value")
                if typeof(value) == "number" then
                    return value
                end
            end
        end

        return nil
    end

    local function getString(object, names)
        for _, name in ipairs(names) do
            local attr = object:GetAttribute(name)

            if attr ~= nil then
                return tostring(attr)
            end

            local child = object:FindFirstChild(name, true)

            if child then
                if child:IsA("StringValue") then
                    return child.Value
                end

                local value = child:GetAttribute("Value")
                if value ~= nil then
                    return tostring(value)
                end
            end
        end

        return nil
    end

    local function getEggPart(egg)
        if egg:IsA("BasePart") then
            return egg
        end

        if egg:IsA("Model") then
            return egg.PrimaryPart
                or egg:FindFirstChildWhichIsA("BasePart", true)
        end

        return egg:FindFirstChildWhichIsA("BasePart", true)
    end

    local function getPlotOwner(plot)
        -- UserId แบบตัวเลข
        local userId = plot:GetAttribute(CONFIG.OWNER_ATTRIBUTE)

        if typeof(userId) == "number" then
            return userId == LocalPlayer.UserId
        end

        if typeof(userId) == "string" then
            if tonumber(userId) == LocalPlayer.UserId then
                return true
            end

            if userId == LocalPlayer.Name then
                return true
            end

            if userId == LocalPlayer.DisplayName then
                return true
            end
        end

        -- Owner แบบชื่อ
        local owner = plot:GetAttribute(CONFIG.OWNER_NAME_ATTRIBUTE)

        if owner ~= nil then
            owner = tostring(owner)

            if owner == LocalPlayer.Name
                or owner == LocalPlayer.DisplayName then
                return true
            end
        end

        -- ObjectValue / StringValue ที่ชื่อ Owner
        for _, name in ipairs({"Owner", "OwnerPlayer", "Player", "OwnerUserId"}) do
            local valueObject = plot:FindFirstChild(name)

            if valueObject then
                if valueObject:IsA("ObjectValue") and valueObject.Value then
                    if valueObject.Value == LocalPlayer then
                        return true
                    end
                elseif valueObject:IsA("StringValue") then
                    if valueObject.Value == LocalPlayer.Name
                        or valueObject.Value == LocalPlayer.DisplayName then
                        return true
                    end
                elseif valueObject:IsA("IntValue")
                    or valueObject:IsA("NumberValue") then
                    if valueObject.Value == LocalPlayer.UserId then
                        return true
                    end
                end
            end
        end

        return false
    end

    local function getValueText(value)
        if value == nil then
            return "N/A"
        end

        if typeof(value) == "number" then
            if math.abs(value) >= 1000000 then
                return string.format("%.2fM", value / 1000000)
            elseif math.abs(value) >= 1000 then
                return string.format("%.2fK", value / 1000)
            end

            return string.format("%.2f", value)
        end

        return tostring(value)
    end

    --========================================================
    -- BILLBOARD
    --========================================================

    local function removeESP(egg)
        local data = Tracked[egg]

        if not data then
            return
        end

        if data.Billboard then
            pcall(function()
                data.Billboard:Destroy()
            end)
        end

        Tracked[egg] = nil
    end

    local function createESP(egg)
        if not egg or not egg.Parent then
            return
        end

        if Tracked[egg] then
            return
        end

        local part = getEggPart(egg)

        if not part then
            return
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DX_EggESP"
        billboard.Adornee = part
        billboard.Size = UDim2.fromOffset(230, 125)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = CONFIG.MAX_TEXT_DISTANCE
        billboard.ResetOnSpawn = false
        billboard.Parent = part

        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundColor3 = Color3.fromRGB(8, 8, 11)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        frame.Parent = billboard

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 35, 60)
        stroke.Thickness = 1.5
        stroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Info"
        label.Position = UDim2.fromOffset(8, 6)
        label.Size = UDim2.new(1, -16, 1, -12)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(245, 245, 250)
        label.TextSize = CONFIG.TEXT_SIZE
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.TextWrapped = true
        label.Parent = frame

        Tracked[egg] = {
            Billboard = billboard,
            Label = label,
            Part = part,
        }
    end

    local function updateESP(egg, data)
        if not egg or not egg.Parent then
            removeESP(egg)
            return
        end

        if not data or not data.Billboard or not data.Billboard.Parent then
            removeESP(egg)
            return
        end

        local root = getCharacterRoot()

        if not root or not data.Part or not data.Part.Parent then
            data.Billboard.Enabled = false
            return
        end

        local distance = (root.Position - data.Part.Position).Magnitude

        if distance > Distance then
            data.Billboard.Enabled = false
            return
        end

        data.Billboard.Enabled = Enabled

        local name = getString(egg, {
            "EggName",
            "Name",
            "Egg",
            "DisplayName",
        }) or egg.Name

        local rarity = getString(egg, {
            "Rarity",
            "Rare",
        }) or "N/A"

        local mutation = getString(egg, {
            "Mutation",
            "Mutate",
        }) or "None"

        local weight = getNumber(egg, {
            "Weight",
            "WeightKg",
            "Kg",
        })

        local value = getNumber(egg, {
            "Value",
            "Price",
            "Income",
            "SellValue",
        })

        data.Label.Text =
            tostring(name)
            .. "\nRarity: " .. tostring(rarity)
            .. "\nMutation: " .. tostring(mutation)
            .. "\nWeight: " .. getValueText(weight) .. " Kg"
            .. "\nValue: " .. getValueText(value)
            .. "\nDistance: " .. string.format("%.1f", distance) .. " studs"
    end

    --========================================================
    -- PLOT / EGG DISCOVERY
    --========================================================

    local function connectEggsFolder(eggsFolder)
        if not eggsFolder then
            return
        end

        for _, egg in ipairs(eggsFolder:GetChildren()) do
            createESP(egg)
        end

        table.insert(Connections, eggsFolder.ChildAdded:Connect(function(egg)
            task.defer(function()
                if Enabled then
                    createESP(egg)
                end
            end)
        end))

        table.insert(Connections, eggsFolder.ChildRemoved:Connect(function(egg)
            removeESP(egg)
        end))
    end

    local function findMyPlot()
        local plots = workspace:FindFirstChild(CONFIG.PLOTS_FOLDER)

        if not plots then
            return nil
        end

        for _, plot in ipairs(plots:GetChildren()) do
            if getPlotOwner(plot) then
                return plot
            end
        end

        return nil
    end

    local function refresh()
        for egg in pairs(Tracked) do
            removeESP(egg)
        end

        disconnectAll()

        if not Enabled then
            return
        end

        local plot = findMyPlot()

        if not plot then
            return
        end

        local eggsFolder = plot:FindFirstChild(CONFIG.EGGS_FOLDER)

        if eggsFolder then
            connectEggsFolder(eggsFolder)
        end

        -- เผื่อ Eggs ถูกสร้างช้าหลัง Plot ถูกโหลด
        table.insert(Connections, plot.ChildAdded:Connect(function(child)
            if child.Name == CONFIG.EGGS_FOLDER then
                connectEggsFolder(child)
            end
        end))
    end

    local function setEnabled(state)
        Enabled = state == true

        if Enabled then
            refresh()
        else
            for egg in pairs(Tracked) do
                removeESP(egg)
            end

            disconnectAll()
        end
    end

    local function setDistance(value)
        Distance = math.clamp(
            tonumber(value) or CONFIG.MAX_DISTANCE,
            10,
            2000
        )

        for egg, data in pairs(Tracked) do
            updateESP(egg, data)
        end
    end

    --========================================================
    -- UPDATE เฉพาะ Egg ที่กำลัง Track
    -- ไม่สแกน Workspace ทุกเฟรม
    --========================================================

    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if not Enabled then
            return
        end

        local now = os.clock()

        if not Connections._LastUpdate then
            Connections._LastUpdate = now
            return
        end

        if now - Connections._LastUpdate < CONFIG.DISTANCE_UPDATE then
            return
        end

        Connections._LastUpdate = now

        for egg, data in pairs(Tracked) do
            updateESP(egg, data)
        end
    end))

    --========================================================
    -- UI TAB
    --========================================================

    local Tab = Window:CreateTab("Egg ESP", "E")

    Tab:Section("PLOT EGG ESP")

    Tab:Toggle("Plot Egg ESP", false, function(state)
        setEnabled(state)
    end)

    Tab:Section("ESP DETAILS")

    Tab:Slider("Distance", 50, 2000, Distance, function(value)
        setDistance(value)
    end)

    Tab:Button("Refresh Eggs", function()
        refresh()
    end)

    Tab:Button("Clear ESP", function()
        for egg in pairs(Tracked) do
            removeESP(egg)
        end
    end)

    -- API ให้ Loader/ระบบอื่นเรียกได้
    return {
        Tab = Tab,
        SetEnabled = setEnabled,
        SetDistance = setDistance,
        Refresh = refresh,

        Clear = function()
            for egg in pairs(Tracked) do
                removeESP(egg)
            end
        end,

        GetDistance = function()
            return Distance
        end,

        IsEnabled = function()
            return Enabled
        end,
    }
end
