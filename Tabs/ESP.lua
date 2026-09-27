return function(Window)
    local Tab = Window:CreateTab("Egg", "E")

    Tab:Section("EGG")

    Tab:Button("Test Egg", function()
        print("[DXPanel] Egg tab")
    end)

    return Tab
end
