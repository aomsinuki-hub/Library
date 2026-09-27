return function(Window, Core)

    local Tab = Window:CreateTab("Main", "M")

    Tab:Section("MAIN")

    Tab:Button("Test", function()
        print("[DXPanel] Main Test OK")

        if Core and Core.Notify then
            Core:Notify(
                "DXPanel",
                "Main Tab ทำงานแล้ว",
                3
            )
        end
    end)

    Tab:Toggle("Test Toggle", false, function(value)
        print("[DXPanel] Toggle:", value)
    end)

end
