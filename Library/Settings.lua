-- Library/Settings.lua
-- Settings ถูกโหลดเป็นตัวสุดท้าย จึงอยู่ล่างสุดของ Sidebar

return function(Window)
    local Tab = Window:CreateTab("Settings", "gear")

    Tab:Section("THEME COLOR")

    Tab:Button("Red", function()
        Window:SetThemeColor(Color3.fromRGB(235, 30, 52))
    end)
    Tab:Button("Purple", function()
        Window:SetThemeColor(Color3.fromRGB(150, 70, 255))
    end)
    Tab:Button("Blue", function()
        Window:SetThemeColor(Color3.fromRGB(55, 130, 255))
    end)
    Tab:Button("Cyan", function()
        Window:SetThemeColor(Color3.fromRGB(0, 220, 255))
    end)
    Tab:Button("Green", function()
        Window:SetThemeColor(Color3.fromRGB(40, 220, 110))
    end)
    Tab:Button("Orange", function()
        Window:SetThemeColor(Color3.fromRGB(255, 140, 30))
    end)

    Tab:Section("CUSTOM RGB")

    local r, g, b = 235, 30, 52

    local function apply()
        Window:SetThemeColor(Color3.fromRGB(r, g, b))
    end

    Tab:Slider("Red", 0, 255, r, function(v)
        r = math.clamp(math.floor(tonumber(v) or r), 0, 255)
        apply()
    end)

    Tab:Slider("Green", 0, 255, g, function(v)
        g = math.clamp(math.floor(tonumber(v) or g), 0, 255)
        apply()
    end)

    Tab:Slider("Blue", 0, 255, b, function(v)
        b = math.clamp(math.floor(tonumber(v) or b), 0, 255)
        apply()
    end)

    Tab:Section("PANEL")

    Tab:Toggle("Neon Pulse", true, function(state)
        Window:SetPulse(state)
    end)

    Tab:Button("Refit Panel", function()
        Window:Refit()
    end)

    Tab:Button("Close Panel", function()
        Window:Close()
    end)

    Tab:Section("DANGER ZONE")

    Tab:Button("Delete GUI", function()
        Window:Destroy()
    end)

    return Tab
end
