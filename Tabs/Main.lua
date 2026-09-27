return function(Window)
    local Tab = Window:CreateTab("Main", "M")

    Tab:Section("MAIN")

    Tab:Button("Test", function()
        print("[DXPanel] Main/Test")
    end)

    Tab:Toggle("Test Toggle", false, function(state)
        print("[DXPanel] Test Toggle:", state)
    end)

    return Tab
end
