-- Library/EggESP.lua
-- Plot Egg ESP เป็น Library system แยกจาก Core

return function(Window)
    local ESP = Window:CreatePlotEggESP({
        PLOTS_FOLDER = "Plots",
        EGGS_FOLDER = "Eggs",
        OWNER_ATTRIBUTE = "OwnerUserId",
        MAX_DISTANCE = 500,
        UPDATE_INTERVAL = 0.25,
        CREATE_TAB = false,
    })

    local Tab = Window:CreateTab("Egg ESP", "E")

    Tab:Section("PLOT EGG ESP")

    Tab:Toggle("Plot Egg ESP", false, function(state)
        ESP:SetEnabled(state)
    end)

    Tab:Section("RENDER DISTANCE")

    Tab:Slider("Distance", 50, 2000, ESP:GetDistance(), function(value)
        ESP:SetDistance(value)
    end)

    Tab:Button("Refresh Eggs", function()
        ESP:Refresh()
    end)

    Tab:Button("Clear ESP", function()
        ESP:Clear()
    end)

    return Tab, ESP
end
