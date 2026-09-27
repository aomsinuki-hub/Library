return function(Window)
    local Tab = Window:CreateTab("Farm", "F")

    Tab:Section("FARM")

    Tab:Toggle("Auto Farm", false, function(state)
        print("[DXPanel] Auto Farm:", state)
    end)

    return Tab
end
