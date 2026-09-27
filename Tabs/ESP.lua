return function(Window)
    local Tab = Window:CreateTab("ESP", "V")

    Tab:Section("ESP")

    Tab:Toggle("ESP", false, function(state)
        print("[DXPanel] ESP:", state)
    end)

    return Tab
end
